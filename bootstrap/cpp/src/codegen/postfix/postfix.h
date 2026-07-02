#pragma once
#include "../codegen.h"
#include "../common.h"
#include <llvm/IR/Constants.h>
#include <llvm/IR/DerivedTypes.h>
#include <llvm/IR/Intrinsics.h>
#include <memory>
#include <string>
#include <vector>
#include <algorithm>

using namespace llvm;
using namespace codegen;

Value *CodeGen::codegen_postfix(const ast::PostfixExpr *pe)
{
    const ast::Expr *target = pe->lhs.get();
    if (!target)
    {
        error("invalid postfix expression");
        return nullptr;
    }

    Value *ptr = nullptr;
    Type *destElemTy = nullptr;

    if (auto id = dynamic_cast<const ast::Ident *>(target))
    {
        ptr = lookup_local(id->name);
        if (!ptr)
        {
            error("unknown identifier in postfix: " + id->name);
            return nullptr;
        }
    }
    else if (auto ie = dynamic_cast<const ast::IndexExpr *>(target))
    {
        ptr = codegen_index_addr(ie);
        if (!ptr)
            return nullptr;
    }
    else
    {
        error("postfix ++/-- requires an identifier or index expression on lhs");
        return nullptr;
    }

    if (auto *ai = dyn_cast<AllocaInst>(ptr))
    {
        destElemTy = ai->getAllocatedType();
    }
    else if (auto *gv = dyn_cast<GlobalVariable>(ptr))
    {
        destElemTy = gv->getValueType();
    }
    else
    {
        error("unsupported postfix ++/-- target type");
        return nullptr;
    }

    Value *old = builder.CreateLoad(destElemTy, ptr, "post_old");

    Value *newv = nullptr;
    if (destElemTy->isFloatingPointTy())
    {
        Value *one = ConstantFP::get(get_double_type(), 1.0);
        if (old->getType() != get_double_type())
        {
            if (!old->getType()->isFloatingPointTy())
                old = builder.CreateSIToFP(old, get_double_type(), "post_old_fconv");
        }
        if (pe->op == "++")
            newv = builder.CreateFAdd(old, one, "post_inc");
        else
            newv = builder.CreateFSub(old, one, "post_dec");

        if (destElemTy != get_double_type())
        {
            if (destElemTy->isIntegerTy())
            {
                newv = builder.CreateFPToSI(newv, destElemTy, "post_trunc_back");
            }
            else if (newv->getType()->isFloatingPointTy() && destElemTy->isFloatingPointTy())
            {
                unsigned srcBits = newv->getType()->getPrimitiveSizeInBits();
                unsigned dstBits = destElemTy->getPrimitiveSizeInBits();
                if (srcBits < dstBits)
                    newv = builder.CreateFPExt(newv, destElemTy, "post_fp_ext");
                else if (srcBits > dstBits)
                    newv = builder.CreateFPTrunc(newv, destElemTy, "post_fp_trunc");
            }
            else
            {
                newv = builder.CreateBitCast(newv, destElemTy, "post_fp_cast_back");
            }
        }
    }
    else if (destElemTy->isIntegerTy())
    {
        IntegerType *it = cast<IntegerType>(destElemTy);
        Value *one = ConstantInt::get(it, 1);
        if (pe->op == "++")
            newv = builder.CreateAdd(old, one, "post_inc");
        else
            newv = builder.CreateSub(old, one, "post_dec");
    }
    else
    {
        error("unsupported postfix ++/-- element type");
        return nullptr;
    }

    builder.CreateStore(newv, ptr);

    return old;
}