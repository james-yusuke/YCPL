#pragma once
#include "../codegen.h"
#include "../common.h"
#include <llvm/IR/Constants.h>
#include <llvm/IR/DerivedTypes.h>
#include <llvm/IR/Intrinsics.h>

namespace codegen
{

Value *CodeGen::codegen_ifstmt(const ast::IfStmt *ifs)
{
    Value *condV = codegen_expr(ifs->cond.get());
    if (!condV)
        return nullptr;

    Value *condBool = nullptr;
    if (condV->getType()->isFloatingPointTy())
    {
        condBool = builder.CreateFCmpONE(condV, ConstantFP::get(get_double_type(), 0.0), "ifcond");
    }
    else
    {
        Type *condTy = condV->getType();
        if (!condTy->isIntegerTy())
        {
            error("if condition must be integer, bool, or floating point");
            return nullptr;
        }
        condBool = builder.CreateICmpNE(condV, ConstantInt::get(condTy, 0), "ifcond");
    }

    Function *F = builder.GetInsertBlock()->getParent();
    BasicBlock *thenBB = BasicBlock::Create(context, "then", F);
    BasicBlock *elseBB = ifs->else_blk ? BasicBlock::Create(context, "else") : nullptr;
    BasicBlock *mergeBB = BasicBlock::Create(context, "ifcont");

    if (ifs->else_blk)
        builder.CreateCondBr(condBool, thenBB, elseBB);
    else
        builder.CreateCondBr(condBool, thenBB, mergeBB);

    builder.SetInsertPoint(thenBB);
    push_scope();
    codegen_block(ifs->then_blk.get());
    pop_scope();
    if (!builder.GetInsertBlock()->getTerminator())
        builder.CreateBr(mergeBB);

    if (ifs->else_blk)
    {
        elseBB->insertInto(F);
        builder.SetInsertPoint(elseBB);
        push_scope();
        codegen_block(ifs->else_blk.get());
        pop_scope();
        if (!builder.GetInsertBlock()->getTerminator())
            builder.CreateBr(mergeBB);
    }

    mergeBB->insertInto(F);
    builder.SetInsertPoint(mergeBB);

    return nullptr;
}

}
