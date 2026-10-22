#include "llvm_bridge.h"
#include <atomic>
#include <llvm/Config/llvm-config.h>
#include <llvm/IR/Constants.h>
#include <llvm/IR/DerivedTypes.h>
#include <llvm/IR/IRBuilder.h>
#include <llvm/IR/Module.h>
#include <llvm/IR/Verifier.h>
#include <llvm/MC/TargetRegistry.h>
#include <llvm/Support/TargetSelect.h>
#include <llvm/Support/raw_ostream.h>
#include <llvm/Target/TargetMachine.h>
#include <llvm/TargetParser/Host.h>
#include <stdexcept>
#include <type_traits>
#include <vector>
#if LLVM_VERSION_MAJOR != 22
#error "YCPL Rust bootstrap requires LLVM 22"
#endif
namespace ycpl::rust_seed
{
using namespace llvm;
static std::atomic<std::uint64_t> next_session{1};
static StringRef str(rust::Str s) { return {s.data(), s.size()}; }
struct Session::Impl
{
    LLVMContext context;
    Module module;
    IRBuilder<> builder;
    const std::uint64_t id;
    std::vector<Type *> types{nullptr};
    std::vector<Value *> values{nullptr};
    std::vector<BasicBlock *> blocks{nullptr};
    Impl(rust::Str n) : module(str(n), context), builder(context), id(next_session.fetch_add(1))
    {
        if (id > UINT32_MAX)
            throw std::runtime_error("LLVM session id exhausted");
        static const bool initialized = []
        {
            if (InitializeNativeTarget() || InitializeNativeTargetAsmPrinter())
                throw std::runtime_error("LLVM native target initialization failed");
            return true;
        }();
        (void)initialized;
        const Triple triple(sys::getProcessTriple());
        std::string error;
        const auto *target = TargetRegistry::lookupTarget(triple, error);
        if (!target)
            throw std::runtime_error("LLVM native target unavailable: " + error);
        std::unique_ptr<TargetMachine> machine(
            target->createTargetMachine(triple, "generic", "", TargetOptions(), Reloc::PIC_));
        if (!machine)
            throw std::runtime_error("LLVM native target machine unavailable");
        module.setTargetTriple(machine->getTargetTriple());
        module.setDataLayout(machine->createDataLayout());
    }
    template <class T> std::uint64_t add(std::vector<T *> &v, T *x)
    {
        if (!x)
            return 0;
        if (v.size() >= (UINT32_MAX >> 2))
            throw std::runtime_error("LLVM handle space exhausted");
        v.push_back(x);
        return (id << 32) | ((v.size() - 1) << 2) | kind<T>();
    }
    template <class T> static constexpr std::uint32_t kind()
    {
        if constexpr (std::is_same_v<T, Type>)
            return 1;
        if constexpr (std::is_same_v<T, Value>)
            return 2;
        return 3;
    }
    template <class T> T *get(const std::vector<T *> &v, std::uint64_t h) const
    {
        auto i = std::uint32_t(h) >> 2;
        if ((h >> 32) != id || (h & 3) != kind<T>() || !i || i >= v.size())
            throw std::runtime_error("invalid or foreign LLVM handle");
        return v[i];
    }
    Type *t(std::uint64_t h) const { return get(types, h); }
    Value *v(std::uint64_t h) const { return get(values, h); }
    BasicBlock *b(std::uint64_t h) const { return get(blocks, h); }
};
Session::Session(rust::Str n) : p(std::make_unique<Impl>(n)) {}
Session::~Session() = default;
std::unique_ptr<Session> new_session(rust::Str n) { return std::make_unique<Session>(n); }
std::uint64_t Session::type_create(std::uint8_t k, std::uint64_t n,
                                   rust::Slice<const std::uint64_t> a, rust::Str name)
{
    std::vector<Type *> args;
    for (auto h : a)
        args.push_back(p->t(h));
    Type *t = nullptr;
    switch (k)
    {
    case 0:
        t = Type::getVoidTy(p->context);
        break;
    case 1:
        if (!n || n > 65536)
            throw std::runtime_error("invalid integer width");
        t = Type::getIntNTy(p->context, n);
        break;
    case 2:
        t = Type::getFloatTy(p->context);
        break;
    case 3:
        t = Type::getDoubleTy(p->context);
        break;
    case 4:
        t = PointerType::get(p->context, 0);
        break;
    case 5:
    {
        auto s = StructType::getTypeByName(p->context, str(name));
        t = s ? s : StructType::create(p->context, str(name));
        break;
    }
    case 6:
        if (args.size() != 1 || !ArrayType::isValidElementType(args[0]))
            throw std::runtime_error("invalid array type");
        t = ArrayType::get(args[0], n);
        break;
    case 7:
        if (args.empty() || !FunctionType::isValidReturnType(args[0]))
            throw std::runtime_error("invalid function type");
        for (size_t i = 1; i < args.size(); i++)
            if (!FunctionType::isValidArgumentType(args[i]))
                throw std::runtime_error("invalid function parameter");
        t = FunctionType::get(args[0], ArrayRef<Type *>(args).drop_front(), n != 0);
        break;
    default:
        throw std::runtime_error("unknown LLVM type operation");
    }
    return p->add(p->types, t);
}
void Session::type_body(std::uint64_t h, rust::Slice<const std::uint64_t> f)
{
    auto t = dyn_cast<StructType>(p->t(h));
    if (!t || !t->isOpaque())
        throw std::runtime_error("struct already defined or invalid");
    std::vector<Type *> fields;
    for (auto i : f)
    {
        auto ft = p->t(i);
        if (!StructType::isValidElementType(ft))
            throw std::runtime_error("invalid field type");
        fields.push_back(ft);
    }
    t->setBody(fields);
}
std::uint64_t Session::type_size(std::uint64_t h) const
{
    auto t = p->t(h);
    if (!t->isSized())
        throw std::runtime_error("unsized LLVM type");
    return p->module.getDataLayout().getTypeAllocSize(t);
}
std::uint64_t Session::constant(std::uint8_t k, std::uint64_t h, std::uint64_t bits, double real,
                                rust::Str text)
{
    Type *t = p->t(h);
    Value *v = nullptr;
    if (k == 0)
    {
        if (!t->isIntegerTy())
            throw std::runtime_error("integer constant type");
        v = ConstantInt::get(t, bits, true);
    }
    else if (k == 1)
    {
        if (!t->isFloatingPointTy())
            throw std::runtime_error("real constant type");
        v = ConstantFP::get(t, real);
    }
    else if (k == 2 && t->isFirstClassType())
        v = Constant::getNullValue(t);
    else if (k == 3)
        v = p->builder.CreateGlobalString(str(text), ".str", 0, &p->module);
    else
        throw std::runtime_error("unknown constant operation");
    return p->add(p->values, v);
}
std::uint64_t Session::function(rust::Str name, std::uint64_t h)
{
    auto t = dyn_cast<FunctionType>(p->t(h));
    if (!t)
        throw std::runtime_error("expected function type");
    auto f = p->module.getFunction(str(name));
    if (f && f->getFunctionType() != t)
        throw std::runtime_error("incompatible function redeclaration");
    if (!f)
        f = Function::Create(t, Function::ExternalLinkage, str(name), p->module);
    return p->add(p->values, static_cast<Value *>(f));
}
std::uint64_t Session::parameter(std::uint64_t h, std::uint32_t i)
{
    auto f = dyn_cast<Function>(p->v(h));
    if (!f || i >= f->arg_size())
        throw std::runtime_error("invalid function parameter");
    return p->add(p->values, static_cast<Value *>(f->getArg(i)));
}
std::uint64_t Session::block(std::uint64_t h, rust::Str n)
{
    auto f = dyn_cast<Function>(p->v(h));
    if (!f)
        throw std::runtime_error("invalid block function");
    return p->add(p->blocks, BasicBlock::Create(p->context, str(n), f));
}
void Session::position(std::uint64_t h) { p->builder.SetInsertPoint(p->b(h)); }
bool Session::terminated() const
{
    auto b = p->builder.GetInsertBlock();
    return !b || b->getTerminator();
}
std::uint64_t Session::instruction(rust::Str op, std::uint64_t th,
                                   rust::Slice<const std::uint64_t> a, rust::Str name,
                                   std::uint64_t aux)
{
    auto o = str(op);
    auto n = str(name);
    auto &B = p->builder;
    Type *t = th ? p->t(th) : nullptr;
    auto V = [&](size_t i)
    {
        if (i >= a.size())
            throw std::runtime_error("missing instruction operand");
        return p->v(a[i]);
    };
    auto BB = [&](size_t i)
    {
        if (i >= a.size())
            throw std::runtime_error("missing block operand");
        auto block = p->b(a[i]);
        if (!B.GetInsertBlock() || block->getParent() != B.GetInsertBlock()->getParent())
            throw std::runtime_error("branch to a foreign function");
        return block;
    };
    if (!B.GetInsertBlock() || B.GetInsertBlock()->getTerminator())
        throw std::runtime_error("instruction after terminator or without block");
    Value *r = nullptr;
    if (o == "alloca")
    {
        if (!t || !t->isSized())
            throw std::runtime_error("unsized alloca");
        IRBuilder<> E(&B.GetInsertBlock()->getParent()->getEntryBlock(),
                      B.GetInsertBlock()->getParent()->getEntryBlock().begin());
        r = E.CreateAlloca(t, nullptr, n);
    }
    else if (o == "load")
    {
        if (!V(0)->getType()->isPointerTy() || !t || !t->isSized())
            throw std::runtime_error("invalid load");
        r = B.CreateLoad(t, V(0), n);
    }
    else if (o == "store")
    {
        if (!V(1)->getType()->isPointerTy())
            throw std::runtime_error("invalid store");
        r = B.CreateStore(V(0), V(1));
    }
    else if (o == "gep")
    {
        if (!V(0)->getType()->isPointerTy() || !t || !t->isSized())
            throw std::runtime_error("invalid GEP");
        std::vector<Value *> i;
        for (size_t k = 1; k < a.size(); k++)
        {
            if (!V(k)->getType()->isIntegerTy())
                throw std::runtime_error("invalid GEP index");
            i.push_back(V(k));
        }
        r = B.CreateGEP(t, V(0), i, n);
    }
    else if (o == "field")
    {
        auto s = dyn_cast_or_null<StructType>(t);
        if (!s || s->isOpaque() || aux >= s->getNumElements() || !V(0)->getType()->isPointerTy())
            throw std::runtime_error("invalid field GEP");
        r = B.CreateStructGEP(t, V(0), aux, n);
    }
    else if (o == "call")
    {
        auto ft = dyn_cast_or_null<FunctionType>(t);
        if (!ft || !V(0)->getType()->isPointerTy() || a.size() - 1 < ft->getNumParams() ||
            (!ft->isVarArg() && a.size() - 1 != ft->getNumParams()))
            throw std::runtime_error("invalid call arity");
        std::vector<Value *> args;
        for (size_t k = 1; k < a.size(); k++)
        {
            auto v = V(k);
            if (k <= ft->getNumParams() && v->getType() != ft->getParamType(k - 1))
                throw std::runtime_error("invalid call argument type");
            args.push_back(v);
        }
        r = B.CreateCall(ft, V(0), args, ft->getReturnType()->isVoidTy() ? StringRef() : n);
    }
    else if (o == "ret")
    {
        if (a.empty())
            r = B.CreateRetVoid();
        else
            r = B.CreateRet(V(0));
    }
    else if (o == "br")
        r = B.CreateBr(BB(0));
    else if (o == "cond")
    {
        if (!V(0)->getType()->isIntegerTy(1))
            throw std::runtime_error("invalid branch condition");
        r = B.CreateCondBr(V(0), BB(1), BB(2));
    }
    else if (o == "unreachable")
        r = B.CreateUnreachable();
    else if (o == "switch")
    {
        auto v = V(0);
        if (!v->getType()->isIntegerTy() || a.size() % 2)
            throw std::runtime_error("invalid switch");
        auto s = B.CreateSwitch(v, BB(1), (a.size() - 2) / 2);
        for (size_t k = 2; k < a.size(); k += 2)
        {
            auto c = dyn_cast<ConstantInt>(V(k));
            if (!c || c->getType() != v->getType())
                throw std::runtime_error("invalid switch case");
            s->addCase(c, BB(k + 1));
        }
        r = s;
    }
    else if (o == "extract" || o == "insert")
    {
        auto aggregate = V(0)->getType();
        Type *element = nullptr;
        if (auto st = dyn_cast<StructType>(aggregate);
            st && !st->isOpaque() && aux < st->getNumElements())
            element = st->getElementType(aux);
        else if (auto at = dyn_cast<ArrayType>(aggregate); at && aux < at->getNumElements())
            element = at->getElementType();
        if (!element || (o == "insert" && V(1)->getType() != element))
            throw std::runtime_error("invalid aggregate element");
        r = o == "extract" ? B.CreateExtractValue(V(0), {unsigned(aux)}, n)
                           : B.CreateInsertValue(V(0), V(1), {unsigned(aux)}, n);
    }
    else if (o == "select")
    {
        if (!V(0)->getType()->isIntegerTy(1) || V(1)->getType() != V(2)->getType())
            throw std::runtime_error("invalid select");
        r = B.CreateSelect(V(0), V(1), V(2), n);
    }
    else if (o == "memcpy")
        r = B.CreateMemCpy(V(0), MaybeAlign(1), V(1), MaybeAlign(1), V(2));
    else if (o == "memset")
        r = B.CreateMemSet(V(0), V(1), V(2), MaybeAlign(1));
    else if (o == "cast")
    {
        if (!t)
            throw std::runtime_error("missing cast type");
        auto v = V(0);
        auto from = v->getType();
        if (from == t)
            r = v;
        else if (from->isIntegerTy() && t->isIntegerTy())
            r = B.CreateIntCast(v, t, aux != 0, n);
        else if (from->isIntegerTy() && t->isFloatingPointTy())
            r = aux ? B.CreateSIToFP(v, t, n) : B.CreateUIToFP(v, t, n);
        else if (from->isFloatingPointTy() && t->isIntegerTy())
            r = B.CreateFPToSI(v, t, n);
        else if (from->isFloatingPointTy() && t->isFloatingPointTy())
            r = B.CreateFPCast(v, t, n);
        else if (from->isPointerTy() && t->isIntegerTy())
            r = B.CreatePtrToInt(v, t, n);
        else if (from->isIntegerTy() && t->isPointerTy())
            r = B.CreateIntToPtr(v, t, n);
        else if (from->isPointerTy() && t->isPointerTy())
            r = B.CreatePointerCast(v, t, n);
        else
            throw std::runtime_error("invalid cast");
    }
    else
    {
        auto x = V(0), y = V(1);
        if (x->getType() != y->getType())
            throw std::runtime_error("binary operand type mismatch");
        bool fp = x->getType()->isFloatingPointTy();
        bool integer = x->getType()->isIntegerTy();
        bool comparison =
            o == "eq" || o == "ne" || o == "lt" || o == "le" || o == "gt" || o == "ge";
        bool bitwise =
            o == "and" || o == "or" || o == "xor" || o == "shl" || o == "shr" || o == "ugt";
        if ((!fp && !integer && !(comparison && x->getType()->isPointerTy())) ||
            (bitwise && !integer))
            throw std::runtime_error("invalid binary operand type");
        if (o == "add")
            r = fp ? B.CreateFAdd(x, y, n) : B.CreateAdd(x, y, n);
        else if (o == "sub")
            r = fp ? B.CreateFSub(x, y, n) : B.CreateSub(x, y, n);
        else if (o == "mul")
            r = fp ? B.CreateFMul(x, y, n) : B.CreateMul(x, y, n);
        else if (o == "div")
            r = fp ? B.CreateFDiv(x, y, n) : B.CreateSDiv(x, y, n);
        else if (o == "rem")
            r = fp ? B.CreateFRem(x, y, n) : B.CreateSRem(x, y, n);
        else if (o == "and")
            r = B.CreateAnd(x, y, n);
        else if (o == "or")
            r = B.CreateOr(x, y, n);
        else if (o == "xor")
            r = B.CreateXor(x, y, n);
        else if (o == "shl")
            r = B.CreateShl(x, y, n);
        else if (o == "shr")
            r = B.CreateAShr(x, y, n);
        else if (o == "eq")
            r = fp ? B.CreateFCmpOEQ(x, y, n) : B.CreateICmpEQ(x, y, n);
        else if (o == "ne")
            r = fp ? B.CreateFCmpONE(x, y, n) : B.CreateICmpNE(x, y, n);
        else if (o == "lt")
            r = fp ? B.CreateFCmpOLT(x, y, n) : B.CreateICmpSLT(x, y, n);
        else if (o == "le")
            r = fp ? B.CreateFCmpOLE(x, y, n) : B.CreateICmpSLE(x, y, n);
        else if (o == "gt")
            r = fp ? B.CreateFCmpOGT(x, y, n) : B.CreateICmpSGT(x, y, n);
        else if (o == "ge")
            r = fp ? B.CreateFCmpOGE(x, y, n) : B.CreateICmpSGE(x, y, n);
        else if (o == "ugt")
            r = B.CreateICmpUGT(x, y, n);
        else
            throw std::runtime_error("unknown LLVM instruction");
    }
    return p->add(p->values, r);
}
void Session::verify() const
{
    std::string s;
    raw_string_ostream out(s);
    if (verifyModule(p->module, &out))
        throw std::runtime_error("LLVM verification failed: " + s);
}
rust::String Session::ir() const
{
    verify();
    std::string s;
    raw_string_ostream out(s);
    p->module.print(out, nullptr);
    return rust::String(s);
}
} // namespace ycpl::rust_seed
