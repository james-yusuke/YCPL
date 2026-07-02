#pragma once
#include "../codegen.h"
#include "../common.h"
#include <llvm/IR/Constants.h>
#include <llvm/IR/DerivedTypes.h>
#include <llvm/IR/Intrinsics.h>

using namespace llvm;
using namespace codegen;

Value *CodeGen::codegen_binary(const ast::BinaryExpr *be)
{
    if (!be)
        return nullptr;

    auto to_bool = [&](Value *v, const std::string &name) -> Value *
    {
        if (!v)
            return nullptr;
        if (v->getType()->isIntegerTy())
            return builder.CreateICmpNE(v, ConstantInt::get(v->getType(), 0), name);
        if (v->getType()->isFloatingPointTy())
            return builder.CreateFCmpONE(v, ConstantFP::get(v->getType(), 0.0), name);
        if (v->getType()->isPointerTy())
            return builder.CreateICmpNE(v, ConstantPointerNull::get(cast<PointerType>(v->getType())), name);
        error("logical operator requires integer, bool, float, or pointer operand");
        return nullptr;
    };

    if (be->op == "&&" || be->op == "||")
    {
        Function *F = builder.GetInsertBlock()->getParent();
        BasicBlock *rhsBB = BasicBlock::Create(context, be->op == "&&" ? "land.rhs" : "lor.rhs", F);
        BasicBlock *mergeBB = BasicBlock::Create(context, be->op == "&&" ? "land.end" : "lor.end", F);

        Value *L = codegen_expr(be->left.get());
        Value *Lbool = to_bool(L, "lhsbool");
        if (!Lbool)
            return nullptr;
        BasicBlock *lhsEndBB = builder.GetInsertBlock();

        if (be->op == "&&")
            builder.CreateCondBr(Lbool, rhsBB, mergeBB);
        else
            builder.CreateCondBr(Lbool, mergeBB, rhsBB);

        builder.SetInsertPoint(rhsBB);
        Value *R = codegen_expr(be->right.get());
        Value *Rbool = to_bool(R, "rhsbool");
        if (!Rbool)
            return nullptr;
        BasicBlock *rhsEndBB = builder.GetInsertBlock();
        builder.CreateBr(mergeBB);

        builder.SetInsertPoint(mergeBB);
        PHINode *phi = builder.CreatePHI(Type::getInt1Ty(context), 2, be->op == "&&" ? "landtmp" : "lortmp");
        if (be->op == "&&")
        {
            phi->addIncoming(ConstantInt::getFalse(context), lhsEndBB);
            phi->addIncoming(Rbool, rhsEndBB);
        }
        else
        {
            phi->addIncoming(ConstantInt::getTrue(context), lhsEndBB);
            phi->addIncoming(Rbool, rhsEndBB);
        }
        return builder.CreateZExt(phi, get_int_type());
    }

    Value *L = codegen_expr(be->left.get());
    Value *R = codegen_expr(be->right.get());
    if (!L || !R)
        return nullptr;

    bool is_fp = L->getType()->isFloatingPointTy() || R->getType()->isFloatingPointTy();
    if (is_fp)
    {
        if (!L->getType()->isFloatingPointTy())
            L = builder.CreateSIToFP(L, get_double_type(), "sitofp_l");
        if (!R->getType()->isFloatingPointTy())
            R = builder.CreateSIToFP(R, get_double_type(), "sitofp_r");

        if (be->op == "/" || be->op == "%")
        {

            Value *isZero = builder.CreateFCmpUEQ(R, ConstantFP::get(get_double_type(), 0.0), "div_zero_cmp");
            Function *F = builder.GetInsertBlock()->getParent();
            BasicBlock *okBB = BasicBlock::Create(builder.getContext(), "div_ok", F);
            BasicBlock *badBB = BasicBlock::Create(builder.getContext(), "div_by_zero", F);

            builder.CreateCondBr(isZero, badBB, okBB);

            builder.SetInsertPoint(badBB);
            {
                FunctionType *abortTy = FunctionType::get(Type::getVoidTy(builder.getContext()), {}, false);
                FunctionCallee abortFn = module->getOrInsertFunction("abort", abortTy);
                builder.CreateCall(abortFn, {});
                builder.CreateUnreachable();
            }

            builder.SetInsertPoint(okBB);
        }

        Type *type = L->getType();
        if (type->isFloatingPointTy())
        {
            if (be->op == "+")
                return builder.CreateFAdd(L, R, "addtmp");
            if (be->op == "-")
                return builder.CreateFSub(L, R, "subtmp");
            if (be->op == "*")
                return builder.CreateFMul(L, R, "multmp");
            if (be->op == "/")
                return builder.CreateFDiv(L, R, "divtmp");
            if (be->op == "%")
                return builder.CreateFRem(L, R, "remtmp");
        }
        else if (type->isIntegerTy())
        {

            llvm::Type *targetType = nullptr;
            if (L->getType()->getIntegerBitWidth() >= R->getType()->getIntegerBitWidth())
                targetType = L->getType();
            else
                targetType = R->getType();

            L = castToSameIntType(L, targetType);
            R = castToSameIntType(R, targetType);

            if (be->op == "+")
                return builder.CreateAdd(L, R, "addtmp");
            if (be->op == "-")
                return builder.CreateSub(L, R, "subtmp");
            if (be->op == "*")
                return builder.CreateMul(L, R, "multmp");
            if (be->op == "/")
                return builder.CreateSDiv(L, R, "divtmp");
            if (be->op == "%")
                return builder.CreateSRem(L, R, "remtmp");

            if (be->op == "<<")
                return builder.CreateShl(L, R, "shltmp");
            if (be->op == ">>")

                return builder.CreateAShr(L, R, "shrtmp");
        }
        else if (type->isPointerTy())
        {
            if (be->op == "+")
            {
                if (R->getType()->isIntegerTy())
                    return builder.CreateGEP(type, L, R, "ptraddtmp");
                else
                    error("pointer addition requires integer");
            }
            else if (be->op == "-")
            {
                if (R->getType()->isIntegerTy())
                    return builder.CreateGEP(type, L, builder.CreateNeg(R), "ptrsubtmp");
                else
                    error("pointer subtraction requires integer");
            }
        }
        else
        {
            error("unsupported operand type for binary operator");
        }

        if (be->op == ">")
            return builder.CreateZExt(builder.CreateFCmpUGT(L, R, "cmptmp"), get_int_type());
        if (be->op == "<")
            return builder.CreateZExt(builder.CreateFCmpULT(L, R, "cmptmp"), get_int_type());
        if (be->op == ">=")
            return builder.CreateZExt(builder.CreateFCmpUGE(L, R, "cmptmp"), get_int_type());
        if (be->op == "<=")
            return builder.CreateZExt(builder.CreateFCmpULE(L, R, "cmptmp"), get_int_type());
    }
    else
    {

        if (be->op == "/" || be->op == "%")
        {
            Value *zero = ConstantInt::get(R->getType(), 0);
            Value *isZero = builder.CreateICmpEQ(R, zero, "div_zero_cmp_int");

            Function *F = builder.GetInsertBlock()->getParent();
            BasicBlock *okBB = BasicBlock::Create(builder.getContext(), "div_ok", F);
            BasicBlock *badBB = BasicBlock::Create(builder.getContext(), "div_by_zero", F);

            builder.CreateCondBr(isZero, badBB, okBB);

            builder.SetInsertPoint(badBB);
            {
                FunctionType *abortTy = FunctionType::get(Type::getVoidTy(builder.getContext()), {}, false);
                FunctionCallee abortFn = module->getOrInsertFunction("abort", abortTy);
                builder.CreateCall(abortFn, {});
                builder.CreateUnreachable();
            }

            builder.SetInsertPoint(okBB);
        }

        Type *type = L->getType();

        if (type->isFloatingPointTy())
        {
            if (be->op == "+")
                return builder.CreateFAdd(L, R, "addtmp");
            if (be->op == "-")
                return builder.CreateFSub(L, R, "subtmp");
            if (be->op == "*")
                return builder.CreateFMul(L, R, "multmp");
            if (be->op == "/")
                return builder.CreateFDiv(L, R, "divtmp");
            if (be->op == "%")
                return builder.CreateFRem(L, R, "remtmp");
        }
        else if (type->isIntegerTy())
        {

            llvm::Type *targetType = nullptr;
            if (L->getType()->getIntegerBitWidth() >= R->getType()->getIntegerBitWidth())
            {
                targetType = L->getType();
            }
            else
            {
                targetType = R->getType();
            }

            L = castToSameIntType(L, targetType);
            R = castToSameIntType(R, targetType);

            if (be->op == "+")
                return builder.CreateAdd(L, R, "addtmp");
            if (be->op == "-")
                return builder.CreateSub(L, R, "subtmp");
            if (be->op == "*")
                return builder.CreateMul(L, R, "multmp");
            if (be->op == "/")
                return builder.CreateSDiv(L, R, "divtmp");
            if (be->op == "%")
                return builder.CreateSRem(L, R, "remtmp");

            if (be->op == "<<")
                return builder.CreateShl(L, R, "shltmp");
            if (be->op == ">>")
                return builder.CreateAShr(L, R, "shrtmp");
        }
        else if (type->isPointerTy())
        {
            if (be->op == "+")
            {
                if (R->getType()->isIntegerTy())
                    return builder.CreateGEP(builder.getInt8Ty(), L, R, "ptraddtmp");
                else
                    error("pointer addition requires integer");
            }
            else if (be->op == "-")
            {
                if (R->getType()->isIntegerTy())
                    return builder.CreateGEP(builder.getInt8Ty(), L, builder.CreateNeg(R), "ptrsubtmp");
                else
                    error("pointer subtraction requires integer");
            }
        }
        else
        {
            error("unsupported operand type for binary operator");
        }

        if (L->getType()->isPointerTy() || R->getType()->isPointerTy())
        {
            if (!L->getType()->isPointerTy() || !R->getType()->isPointerTy())
            {
                error("pointer comparison requires pointer operands");
                return nullptr;
            }

            if (L->getType() != R->getType())
                R = builder.CreateBitCast(R, L->getType(), "ptr_cmp_cast");

            if (be->op == "==")
                return builder.CreateZExt(builder.CreateICmpEQ(L, R, "cmptmp"), get_int_type());
            if (be->op == "!=")
                return builder.CreateZExt(builder.CreateICmpNE(L, R, "cmptmp"), get_int_type());
            error("unsupported pointer comparison for " + be->op);
        }
        else
        {
            llvm::Type *targetType = nullptr;

            if (L->getType()->getIntegerBitWidth() >= R->getType()->getIntegerBitWidth())
            {
                targetType = L->getType();
            }
            else
            {
                targetType = R->getType();
            }

            L = castToSameIntType(L, targetType);
            R = castToSameIntType(R, targetType);

            if (be->op == ">")
                return builder.CreateZExt(builder.CreateICmpSGT(L, R, "cmptmp"), get_int_type());
            if (be->op == "<")
                return builder.CreateZExt(builder.CreateICmpSLT(L, R, "cmptmp"), get_int_type());
            if (be->op == ">=")
                return builder.CreateZExt(builder.CreateICmpSGE(L, R, "cmptmp"), get_int_type());
            if (be->op == "<=")
                return builder.CreateZExt(builder.CreateICmpSLE(L, R, "cmptmp"), get_int_type());
            if (be->op == "==")
                return builder.CreateZExt(builder.CreateICmpEQ(L, R, "cmptmp"), get_int_type());
            if (be->op == "!=")
                return builder.CreateZExt(builder.CreateICmpNE(L, R, "cmptmp"), get_int_type());
        }
    }

    error("unsupported binary op: " + be->op);
    return nullptr;
}
