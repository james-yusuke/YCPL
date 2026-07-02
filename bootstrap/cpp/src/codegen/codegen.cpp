#include "codegen.h"
#include "common.h"
#include <llvm/IR/Constants.h>
#include <llvm/IR/DerivedTypes.h>
#include <llvm/IR/Type.h>
#include <llvm/IR/GlobalVariable.h>
#include <llvm/IR/Function.h>
#include <llvm/IR/Verifier.h>
#include <llvm/Support/FileSystem.h>
#include <llvm/ADT/SmallVector.h>
#include <iostream>
#include <cassert>

#include "fmt/printf.h"
#include "fmt/println.h"
#include "fmt/sprintf.h"
#include "for/for.h"
#include "for/formula.h"
#include "for/iter.h"
#include "func/functions.h"
#include "func/type.h"
#include "if/if.h"
#include "struct/struct.h"
#include "struct/type.h"
#include "var/var.h"
#include "ffi/call.h"
#include "ffi/ffi.h"
#include "ffi/len.h"
#include "ffi/cast.h"
#include "ffi/new.h"
#include "expr/binary.h"
#include "expr/unary.h"
#include "assign/assign.h"
#include "array/addr.h"
#include "array/array.h"
#include "array/index.h"
#include "array/append.h"
#include "literal/literal.h"
#include "postfix/postfix.h"

using namespace llvm;

namespace codegen
{
    CodeGen::CodeGen(const std::string &module_name)
        : module(std::make_unique<Module>(module_name, context)), builder(context)
    {
        InitializeNativeTarget();
        InitializeNativeTargetAsmPrinter();
        InitializeNativeTargetAsmParser();
    }

    CodeGen::~CodeGen() = default;

    void CodeGen::error(const std::string &msg)
    {
        failed = true;
        std::cerr << "[codegen error] " << msg << "\n";
    }

    llvm::Value *CodeGen::castToSameIntType(llvm::Value *v, llvm::Type *targetType)
    {
        if (v->getType() == targetType)
            return v;
        return builder.CreateIntCast(v, targetType, true /*isSigned*/);
    }

    Type *CodeGen::get_int_type() { return Type::getInt32Ty(context); }
    Type *CodeGen::get_i64_type() { return Type::getInt64Ty(context); }
    Type *CodeGen::get_double_type() { return Type::getDoubleTy(context); }
    Type *CodeGen::get_void_type() { return Type::getVoidTy(context); }

    Type *CodeGen::get_i8ptr_type() { return detail::getPtrTy(context); }

    FunctionCallee CodeGen::get_printf()
    {
        Type *i8ptr = detail::getPtrTy(context);
        FunctionType *printfType = FunctionType::get(IntegerType::getInt32Ty(context), {i8ptr}, true);
        FunctionCallee callee = module->getOrInsertFunction("printf", printfType);
        if (auto *fn = dyn_cast<Function>(callee.getCallee()))
            function_protos["printf"] = fn;
        return callee;
    }

    Value *CodeGen::make_global_string(const std::string &str, const std::string &name)
    {
        GlobalVariable *gv = builder.CreateGlobalString(str, name.empty() ? ".str" : name);
        Constant *zero = ConstantInt::get(Type::getInt32Ty(context), 0);
        Constant *indices[] = {zero, zero};
        return ConstantExpr::getInBoundsGetElementPtr(gv->getValueType(), gv, indices);
    }

    Value *CodeGen::create_entry_alloca(Function *func, Type *type, const std::string &name)
    {
        IRBuilder<> tmp(&func->getEntryBlock(), func->getEntryBlock().begin());
        return tmp.CreateAlloca(type, nullptr, name);
    }

    void CodeGen::push_scope()
    {
        locals_stack_const.emplace_back();
        locals_stack_type.emplace_back();
        locals_stack.emplace_back();
    }
    
    void CodeGen::pop_scope()
    {
        if (!locals_stack.empty())
            locals_stack.pop_back();
        if (!locals_stack_type.empty())
            locals_stack_type.pop_back();
        if (!locals_stack_const.empty())
            locals_stack_const.pop_back();
    }

    void CodeGen::bind_local(const std::string &name, const std::string type, Value *v)
    {
        bind_local_const(name, type, v, false);
    }

    void CodeGen::bind_local_const(const std::string &name, const std::string type, Value *v, bool is_const)
    {
        if (locals_stack.empty() || locals_stack_type.empty())
            push_scope();
        locals_stack.back()[name] = v;
        locals_stack_type.back()[name] = type;
        locals_stack_const.back()[name] = is_const;
    }

    std::string *CodeGen::lookup_local_type(const std::string &name)
    {
        for (int i = (int)locals_stack_type.size() - 1; i >= 0; --i)
        {
            auto &m = locals_stack_type[i];
            auto it = m.find(name);
            if (it != m.end())
                return &it->second;
        }

        return nullptr;
    }

    std::string CodeGen::infer_expr_type_name(const ast::Expr *expr)
    {
        if (!expr)
            return "";

        if (auto id = dynamic_cast<const ast::Ident *>(expr))
        {
            if (auto *ty = lookup_local_type(id->name))
                return *ty;
            return "";
        }

        if (auto member = dynamic_cast<const ast::MemberExpr *>(expr))
        {
            std::string objectType = infer_expr_type_name(member->object.get());
            auto pt = parse_type_chain(objectType);
            auto it = struct_decls.find(pt.base);
            if (it == struct_decls.end() || !it->second)
                return "";

            for (const auto &field : it->second->fields)
            {
                if (field && field->name == member->member)
                    return resolve_type_name(const_cast<ast::Type *>(field->type.get()));
            }
            return "";
        }

        return "";
    }

    bool CodeGen::is_local_const(const std::string &name)
    {
        for (int i = (int)locals_stack_const.size() - 1; i >= 0; --i)
        {
            auto &m = locals_stack_const[i];
            auto it = m.find(name);
            if (it != m.end())
                return it->second;
        }
        return false;
    }

    Value *CodeGen::lookup_local(const std::string &name)
    {
        for (int i = (int)locals_stack.size() - 1; i >= 0; --i)
        {
            auto &m = locals_stack[i];
            auto it = m.find(name);
            if (it != m.end())
                return it->second;
        }

        auto fIt = function_protos.find(name);
        if (fIt != function_protos.end())
            return fIt->second;
        return nullptr;
    }

    Value *CodeGen::codegen_expr(const ast::Expr *e)
    {
        if (!e)
            return nullptr;
        if (auto lit = dynamic_cast<const ast::Literal *>(e))
            return codegen_literal(lit);
        if (dynamic_cast<const ast::TypeExpr *>(e))
        {
            error("type expression is only valid in intrinsic calls");
            return nullptr;
        }
        if (auto id = dynamic_cast<const ast::Ident *>(e))
            return codegen_ident(id);
        if (auto ue = dynamic_cast<const ast::UnaryExpr *>(e))
            return codegen_unary(ue);
        if (auto be = dynamic_cast<const ast::BinaryExpr *>(e))
            return codegen_binary(be);
        if (auto ce = dynamic_cast<const ast::CallExpr *>(e))
            return codegen_call(ce);
        if (auto alit = dynamic_cast<const ast::ArrayLiteral *>(e))
            return codegen_array(alit);
        if (auto sl = dynamic_cast<const ast::StructLiteral *>(e))
            return codegen_struct_literal(sl);
        if (auto me = dynamic_cast<const ast::MemberExpr *>(e))
            return codegen_member(me);
        if (auto bal = dynamic_cast<const ast::ByteArrayLiteral *>(e))
            return codegen_byte_array(bal);
        if (auto pe = dynamic_cast<const ast::PostfixExpr *>(e))
            return codegen_postfix(pe);
        if (auto ie = dynamic_cast<const ast::IndexExpr *>(e))
            return codegen_index(ie);
        else
            error("unhandled expr node");
        return nullptr;
    }

    Value *CodeGen::codegen_block(const ast::BlockStmt *blk)
    {
        if (!blk)
            return nullptr;
        for (const auto &s : blk->stmts)
            codegen_stmt(s.get());
        return nullptr;
    }

    Value *CodeGen::codegen_stmt(const ast::Stmt *s)
    {
        if (!s)
            return nullptr;
        if (auto es = dynamic_cast<const ast::ExprStmt *>(s))
        {
            return codegen_expr(es->expr.get());
        }
        if (auto rs = dynamic_cast<const ast::ReturnStmt *>(s))
        {
            Value *rv = nullptr;
            if (rs->expr)
                rv = codegen_expr(rs->expr.get());
            Function *F = builder.GetInsertBlock()->getParent();
            Type *retTy = F ? F->getReturnType() : nullptr;
            if (!rv)
            {
                if (retTy && !retTy->isVoidTy())
                {
                    error("non-void function requires a return value");
                    builder.CreateRet(Constant::getNullValue(retTy));
                }
                else
                    builder.CreateRetVoid();
            }
            else if (retTy && retTy->isVoidTy())
            {
                error("void function cannot return a value");
                builder.CreateRetVoid();
            }
            else
            {
                if (retTy && rv->getType() != retTy)
                {
                    if (rv->getType()->isIntegerTy() && retTy->isIntegerTy())
                        rv = builder.CreateSExtOrTrunc(rv, retTy, "return.intcast");
                    else if (rv->getType()->isIntegerTy() && retTy->isFloatingPointTy())
                        rv = builder.CreateSIToFP(rv, retTy, "return.sitofp");
                    else if (rv->getType()->isFloatingPointTy() && retTy->isIntegerTy())
                        rv = builder.CreateFPToSI(rv, retTy, "return.fptosi");
                    else if (rv->getType()->isPointerTy() && retTy->isPointerTy())
                        rv = builder.CreatePointerCast(rv, retTy, "return.ptrcast");
                    else if (rv->getType()->isPointerTy() && retTy->isIntegerTy())
                        rv = builder.CreatePtrToInt(rv, retTy, "return.ptrtoint");
                    else if (rv->getType()->isIntegerTy() && retTy->isPointerTy())
                        rv = builder.CreateIntToPtr(rv, cast<PointerType>(retTy), "return.inttoptr");
                    else if (retTy->isStructTy() && rv->getType()->isPointerTy())
                    {
                        auto *ptrTy = cast<PointerType>(rv->getType());
                        (void)ptrTy;
                        rv = builder.CreateLoad(retTy, rv, "return.load_struct");
                    }
                    else
                    {
                        error("return value type does not match function return type");
                        rv = Constant::getNullValue(retTy);
                    }
                }
                builder.CreateRet(rv);
            }
            return nullptr;
        }
        if (auto vd = dynamic_cast<const ast::VarDecl *>(s))
        {
            return codegen_vardecl(vd);
        }

        if (auto as = dynamic_cast<const ast::AssignStmt *>(s))
        {
            return codegen_assign(as);
        }

        if (auto ifs = dynamic_cast<const ast::IfStmt *>(s))
        {
            return codegen_ifstmt(ifs);
        }

        if (dynamic_cast<const ast::BreakStmt *>(s))
        {
            if (break_targets.empty())
            {
                error("break used outside of loop");
                return nullptr;
            }
            builder.CreateBr(break_targets.back());

            Function *F = builder.GetInsertBlock()->getParent();
            BasicBlock *cont = BasicBlock::Create(context, "after.break", F);
            builder.SetInsertPoint(cont);
            return nullptr;
        }

        if (dynamic_cast<const ast::ContinueStmt *>(s))
        {
            if (continue_targets.empty())
            {
                error("continue used outside of loop");
                return nullptr;
            }
            builder.CreateBr(continue_targets.back());
            Function *F = builder.GetInsertBlock()->getParent();
            BasicBlock *cont = BasicBlock::Create(context, "after.continue", F);
            builder.SetInsertPoint(cont);
            return nullptr;
        }

        if (auto fs = dynamic_cast<const ast::ForInStmt *>(s))
        {
            return codegen_forinstmt(fs);
        }

        if (auto fcs = dynamic_cast<const ast::ForCStyleStmt *>(s))
        {
            return codegen_forcstmt(fcs);
        }

        if (auto fs2 = dynamic_cast<const ast::ForStmt *>(s))
        {
            return codegen_forstmt(fs2);
        }

        error("unhandled stmt type in codegen");
        return nullptr;
    }

    bool CodeGen::generate(const ast::Program &prog)
    {
        failed = false;

        prepare_struct_types(prog);

        std::vector<const ast::FuncDecl *> funcPtrs;
        for (const auto &d : prog.decls)
        {
            if (auto fd = dynamic_cast<const ast::FuncDecl *>(d.get()))
            {
                funcPtrs.push_back(fd);
            }
        }
        if (!funcPtrs.empty())
            predeclare_functions(funcPtrs);

        for (const auto &d : prog.decls)
        {
            if (auto fd = dynamic_cast<const ast::FuncDecl *>(d.get()))
            {
                codegen_function_decl(fd);
            }
        }

        for (const auto &d : prog.decls)
        {
            if (dynamic_cast<const ast::StmtDecl *>(d.get()))
            {
                error("top-level statements are not supported in codegen (please define fn main)");
            }
        }

        if (verifyModule(*module, &errs()))
        {
            error("module verification failed");
            return false;
        }

        return !failed;
    }

    void CodeGen::dump_llvm_ir()
    {
        llvm::verifyModule(*module.get());
        module->print(llvm::outs(), nullptr);
    }

    bool CodeGen::write_ir_to_file(const std::string &path)
    {
        std::error_code EC;
        raw_fd_ostream dest(path, EC, sys::fs::OF_None);
        if (EC)
        {
            std::cerr << "Could not open file: " << EC.message() << "\n";
            return false;
        }
        module->print(dest, nullptr);
        return true;
    }
}
