#pragma once
#include "../codegen.h"
#include "../common.h"
#include <llvm/IR/Constants.h>
#include <llvm/IR/DerivedTypes.h>
#include <llvm/IR/Intrinsics.h>
#include <utility>

using namespace llvm;
using namespace codegen;

llvm::StructType *CodeGen::get_struct_type_from_value(Value *v, const std::string &varname)
{
    if (!v)
        return nullptr;

    if (auto *ai = llvm::dyn_cast<llvm::AllocaInst>(v))
    {
        if (auto *st = llvm::dyn_cast<llvm::StructType>(ai->getAllocatedType()))
            return st;
    }

    if (auto *gv = llvm::dyn_cast<llvm::GlobalVariable>(v))
    {
        if (auto *st = llvm::dyn_cast<llvm::StructType>(gv->getValueType()))
            return st;
    }

    if (v->getType()->isPointerTy())
    {
        auto *pt = llvm::dyn_cast<llvm::PointerType>(v->getType());
        if (pt)
        {
            if (auto *st = llvm::dyn_cast<llvm::StructType>(pt->getNonOpaquePointerElementType()))
                return st;
        }
    }

    if (!varname.empty())
    {
        return lookup_struct_type(varname);
    }

    return nullptr;
}

llvm::StructType *CodeGen::lookup_struct_type(const std::string &name)
{
    if (name.empty())
        return nullptr;

    auto it = struct_types.find(name);
    if (it == struct_types.end())
        return nullptr;

    return it->second;
}

std::pair<llvm::StructType *, llvm::Value *> CodeGen::deduce_struct_type_and_ptr(llvm::Value *v, const std::string &hintVarName)
{
    if (!v)
        return {nullptr, nullptr};

    if (auto *ai = dyn_cast<AllocaInst>(v))
    {
        Type *allocTy = ai->getAllocatedType();
        if (auto *st = dyn_cast<StructType>(allocTy))
        {
            return {st, ai};
        }
        if (auto *pt = dyn_cast<PointerType>(allocTy))
        {
            if (auto *st = dyn_cast<StructType>(pt))
            {

                Value *loadedPtr = builder.CreateLoad(pt, ai, ai->getName() + ".load");
                return {st, loadedPtr};
            }
        }
    }

    if (auto *gv = dyn_cast<GlobalVariable>(v))
    {
        Type *gvValTy = gv->getValueType();
        if (auto *st = dyn_cast<StructType>(gvValTy))
        {
            return {st, gv};
        }
        if (auto *pt = dyn_cast<PointerType>(gvValTy))
        {
            if (auto *st = dyn_cast<StructType>(pt))
            {
                Value *loadedPtr = builder.CreateLoad(pt, gv, gv->getName() + ".load");
                return {st, loadedPtr};
            }
        }
    }

    if (auto *pt = dyn_cast<PointerType>(v->getType()))
    {
        Type *elem = pt;
        if (auto *st = dyn_cast<StructType>(elem))
        {
            return {st, v};
        }
        if (auto *pt2 = dyn_cast<PointerType>(elem))
        {
            if (auto *st = dyn_cast<StructType>(pt2))
            {

                Value *loadedPtr = builder.CreateLoad(pt2, v, "doubleptr.load");
                return {st, loadedPtr};
            }
        }
    }

    if (auto *bc = dyn_cast<BitCastInst>(v))
        return deduce_struct_type_and_ptr(bc->getOperand(0), hintVarName);
    if (auto *li = dyn_cast<LoadInst>(v))
        return deduce_struct_type_and_ptr(li->getPointerOperand(), hintVarName);

    if (!hintVarName.empty())
    {
        auto it = struct_types.find(hintVarName);
        if (it != struct_types.end())
            return {it->second, v};
    }

    return {nullptr, nullptr};
}

std::pair<llvm::StructType *, llvm::Value *> CodeGen::resolve_struct_and_ptr(llvm::Value *v, const std::string &hintVarName)
{

    if (!v)
        return {nullptr, nullptr};

    if (auto *ai = dyn_cast<AllocaInst>(v))
    {
        Type *allocTy = ai->getAllocatedType();

        if (auto *st = dyn_cast<StructType>(allocTy))
        {
            return {st, ai};
        }

        if (auto *pt = dyn_cast<PointerType>(allocTy))
        {
            Type *elem = pt;

            if (elem && isa<StructType>(elem))
            {
                auto *st = cast<StructType>(elem);
                Value *loaded = builder.CreateLoad(pt, ai, ai->getName() + ".loaded");
                return {st, loaded};
            }

            if (!hintVarName.empty())
            {
                auto it = struct_types.find(hintVarName);
                if (it != struct_types.end())
                {
                    StructType *st = it->second;

                    Value *loadedOpaque = builder.CreateLoad(pt, ai, ai->getName() + ".loaded_opaque");

                    Type *expectedPtrTy = st->getPointerTo();
                    Value *casted = builder.CreateBitCast(loadedOpaque, expectedPtrTy, ai->getName() + ".bitcast_to_structptr");

                    return {st, casted};
                }
            }
        }
    }

    if (auto *gv = dyn_cast<GlobalVariable>(v))
    {
        Type *gvValTy = gv->getValueType();

        if (auto *st = dyn_cast<StructType>(gvValTy))
        {
            return {st, gv};
        }
        if (auto *pt = dyn_cast<PointerType>(gvValTy))
        {
            Type *elem = pt;
            if (elem && isa<StructType>(elem))
            {
                auto *st = cast<StructType>(elem);
                Value *loaded = builder.CreateLoad(pt, gv, gv->getName() + ".loaded");
                return {st, loaded};
            }

            if (!hintVarName.empty())
            {
                auto it = struct_types.find(hintVarName);
                if (it != struct_types.end())
                {
                    StructType *st = it->second;
                    Value *loadedOpaque = builder.CreateLoad(pt, gv, gv->getName() + ".loaded_opaque");
                    Value *casted = builder.CreateBitCast(loadedOpaque, st->getPointerTo(), gv->getName() + ".bitcast_to_structptr");
                    return {st, casted};
                }
            }
        }
    }

    llvm::Type *vt = v->getType();

    if (auto *st = llvm::dyn_cast<llvm::StructType>(vt))
    {
        Function *curF = builder.GetInsertBlock()->getParent();
        llvm::IRBuilder<> tmp(&curF->getEntryBlock(), curF->getEntryBlock().begin());
        llvm::AllocaInst *all = tmp.CreateAlloca(st, nullptr, (hintVarName.empty() ? "tmp.struct" : (hintVarName + ".tmp")).c_str());
        builder.CreateStore(v, all);
        return {st, all};
    }

    if (auto *arg = dyn_cast<Argument>(v))
    {
        if (auto *pt = dyn_cast<PointerType>(arg->getType()))
        {
            Type *elem = pt;
            if (elem && isa<StructType>(elem))
            {
                return {cast<StructType>(elem), arg};
            }

            if (!hintVarName.empty())
            {
                auto it = struct_types.find(hintVarName);
                if (it != struct_types.end())
                {
                    StructType *st = it->second;

                    Value *casted = builder.CreateBitCast(arg, st->getPointerTo(), arg->getName() + ".bitcast_to_structptr");

                    return {st, casted};
                }
            }
        }
    }

    if (v->getType()->isPointerTy())
    {
        Type *elem = cast<PointerType>(v->getType());
        if (elem && isa<StructType>(elem))
        {
            return {cast<StructType>(elem), v};
        }
        if (elem && isa<PointerType>(elem))
        {
            Type *inner = cast<PointerType>(elem);
            if (inner && isa<StructType>(inner))
            {
                Value *loaded = builder.CreateLoad(cast<PointerType>(elem), v, "loaded_doubleptr");
                return {cast<StructType>(inner), loaded};
            }
        }

        if (!hintVarName.empty())
        {
            auto it = struct_types.find(hintVarName);
            if (it != struct_types.end())
            {
                StructType *st = it->second;
                Value *casted = builder.CreateBitCast(v, st->getPointerTo(), "opaque_bitcast_to_structptr");

                return {st, casted};
            }
        }
    }

    if (auto *li = dyn_cast<LoadInst>(v))
    {
        return resolve_struct_and_ptr(li->getPointerOperand(), hintVarName);
    }
    if (auto *bc = dyn_cast<BitCastInst>(v))
    {
        return resolve_struct_and_ptr(bc->getOperand(0), hintVarName);
    }

    for (const auto &kv : struct_types)
    {
        if (kv.second->hasName())
        {
            return {lookup_struct_type(kv.second->getName().str()), v};
        }
    }

    return {nullptr, nullptr};
}
