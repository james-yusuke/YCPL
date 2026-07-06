#pragma once
#include "../codegen.h"
#include "../common.h"
#include <llvm/IR/Constants.h>
#include <llvm/IR/DerivedTypes.h>
#include <llvm/IR/Intrinsics.h>

namespace codegen
{

Value *CodeGen::codegen_unary(const ast::UnaryExpr *ue)
{
    if (!ue)
        return nullptr;

    if (ue->op == "++" || ue->op == "--")
    {

        const ast::Expr *target = ue->rhs.get();
        if (!target)
        {
            error("invalid operand for ++/--");
            return nullptr;
        }

        Value *ptr = nullptr;
        Type *destElemTy = nullptr;

        if (auto id = dynamic_cast<const ast::Ident *>(target))
        {
            ptr = lookup_local(id->name);
            if (!ptr)
            {
                error("unknown identifier in ++/--: " + id->name);
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
            error("++/-- requires an identifier or index expression on lhs");
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
            error("unsupported ++/-- target type");
            return nullptr;
        }

        Value *old = builder.CreateLoad(destElemTy, ptr, "pp_old");

        Value *newv = nullptr;
        if (destElemTy->isFloatingPointTy())
        {
            Value *one = ConstantFP::get(get_double_type(), 1.0);
            if (old->getType() != get_double_type())
            {

                if (!old->getType()->isFloatingPointTy())
                    old = builder.CreateSIToFP(old, get_double_type(), "pp_old_fconv");
            }
            if (ue->op == "++")
                newv = builder.CreateFAdd(old, one, "pp_inc");
            else
                newv = builder.CreateFSub(old, one, "pp_dec");

            if (destElemTy != get_double_type())
            {
                if (destElemTy->isIntegerTy())
                {
                    newv = builder.CreateFPToSI(newv, destElemTy, "pp_trunc_back");
                }
                else if (newv->getType()->isFloatingPointTy() && destElemTy->isFloatingPointTy())
                {
                    unsigned srcBits = newv->getType()->getPrimitiveSizeInBits();
                    unsigned dstBits = destElemTy->getPrimitiveSizeInBits();
                    if (srcBits < dstBits)
                        newv = builder.CreateFPExt(newv, destElemTy, "pp_fp_ext");
                    else if (srcBits > dstBits)
                        newv = builder.CreateFPTrunc(newv, destElemTy, "pp_fp_trunc");
                }
                else
                {

                    newv = builder.CreateBitCast(newv, destElemTy, "pp_fp_cast_back");
                }
            }
        }
        else if (destElemTy->isIntegerTy())
        {
            IntegerType *it = cast<IntegerType>(destElemTy);
            Value *one = ConstantInt::get(it, 1);
            if (ue->op == "++")
                newv = builder.CreateAdd(old, one, "pp_inc");
            else
                newv = builder.CreateSub(old, one, "pp_dec");
        }
        else
        {
            error("unsupported ++/-- element type");
            return nullptr;
        }

        builder.CreateStore(newv, ptr);

        return newv;
    }

    if (ue->op == "&")
    {
        const ast::Expr *target = ue->rhs.get();
        if (!target)
        {
            error("invalid operand for &");
            return nullptr;
        }

        if (auto id = dynamic_cast<const ast::Ident *>(target))
        {
            Value *loc = lookup_local(id->name);
            if (!loc)
            {
                error("unknown identifier in &: " + id->name);
                return nullptr;
            }

            return loc;
        }
        else if (auto ie = dynamic_cast<const ast::IndexExpr *>(target))
        {
            Value *addr = codegen_index_addr(ie);
            if (!addr)
                return nullptr;
            return addr;
        }
        else if (auto me = dynamic_cast<const ast::MemberExpr *>(target))
        {
            Value *addr = codegen_member_addr(me);
            if (!addr)
                return nullptr;
            return addr;
        }
        else
        {
            error("& operator requires an identifier or index expression");
            return nullptr;
        }
    }

    if (ue->op == "*")
    {
        const ast::Expr *target = ue->rhs.get();
        if (!target)
        {
            error("invalid operand for *");
            return nullptr;
        }

        Value *ptrVal = nullptr;

        if (auto id = dynamic_cast<const ast::Ident *>(target))
        {
            Value *loc = lookup_local(id->name);
            if (!loc)
            {
                error("unknown identifier in *: " + id->name);
                return nullptr;
            }

            if (auto *ai = dyn_cast<AllocaInst>(loc))
            {
                Type *allocated = ai->getAllocatedType();
                ptrVal = builder.CreateLoad(allocated, loc, id->name + ".ptrval");
            }
            else if (auto *gv = dyn_cast<GlobalVariable>(loc))
            {
                Type *gvTy = gv->getValueType();
                ptrVal = builder.CreateLoad(gvTy, loc, id->name + ".ptrval");
            }
            else
            {
                if (loc->getType()->isPointerTy())
                    ptrVal = loc;
                else
                {
                    error("identifier does not refer to pointer storage for *: " + id->name);
                    return nullptr;
                }
            }
        }

        else if (auto me = dynamic_cast<const ast::MemberExpr *>(target))
        {
            Value *fieldAddr = codegen_member_addr(me);
            if (!fieldAddr)
                return nullptr;

            std::string varname;
            if (auto id = dynamic_cast<const ast::Ident *>(me->object.get()))
                varname = id->name;

            llvm::StructType *st = get_struct_type_from_value(lookup_local(varname), varname);
            if (!st)
            {
                error("cannot deduce struct for member ptr deref");
                return nullptr;
            }

            const ast::StructDecl *sd = struct_decls[st->getName().str()];
            int idx = get_field_index(sd, me->member);
            llvm::Type *fieldTy = st->getElementType(idx);

            if (!fieldTy->isPointerTy())
            {
                error("member is not a pointer, cannot apply * to it: " + me->member);
                return nullptr;
            }

            ptrVal = builder.CreateLoad(fieldTy, fieldAddr, me->member + ".ptrval");
        }
        else
        {
            ptrVal = codegen_expr(target);
            if (!ptrVal)
                return nullptr;
        }

        if (!ptrVal->getType()->isPointerTy())
        {
            error("* operand expects a pointer value");
            return nullptr;
        }

        Type *targetType = Type::getInt32Ty(builder.getContext());
        Value *castedPtr = builder.CreateBitCast(ptrVal, detail::getPtrTy(context));

        Value *loaded = builder.CreateLoad(
            targetType,
            castedPtr,
            false,
            "deref_load");

        return loaded;
    }

    if (ue->op == "-")
    {
        Value *rv = codegen_expr(ue->rhs.get());
        if (!rv)
            return nullptr;
        if (rv->getType()->isFloatingPointTy())
        {
            return builder.CreateFNeg(rv, "negtmp");
        }
        else
        {
            return builder.CreateNeg(rv, "negtmp");
        }
    }
    else if (ue->op == "!")
    {
        Value *rv = codegen_expr(ue->rhs.get());
        if (!rv)
            return nullptr;
        if (rv->getType()->isFloatingPointTy())
        {
            auto zero = ConstantFP::get(get_double_type(), 0.0);
            auto cmp = builder.CreateFCmpUEQ(rv, zero, "notcmp");
            return builder.CreateZExt(cmp, get_int_type(), "notext");
        }
        else
        {
            auto zero = ConstantInt::get(rv->getType(), 0);
            auto cmp = builder.CreateICmpEQ(rv, zero, "notcmp");
            return builder.CreateZExt(cmp, get_int_type(), "notext");
        }
    }

    error("unsupported unary op: " + ue->op);
    return nullptr;
}

}
