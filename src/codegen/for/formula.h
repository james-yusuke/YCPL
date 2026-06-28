#pragma once
#include "../codegen.h"
#include "../common.h"
#include <llvm/IR/Constants.h>
#include <llvm/IR/DerivedTypes.h>
#include <llvm/IR/Intrinsics.h>
#include <llvm/IR/Verifier.h>

using namespace llvm;
using namespace codegen;

Value *CodeGen::codegen_forcstmt(const ast::ForCStyleStmt *fcs)
{
    Function *F = builder.GetInsertBlock()->getParent();

    if (fcs->init)
    {
        codegen_stmt(fcs->init.get());
    }

    BasicBlock *condBB = BasicBlock::Create(context, "for.cond", F);
    BasicBlock *bodyBB = BasicBlock::Create(context, "for.body", F);
    BasicBlock *incBB = BasicBlock::Create(context, "for.inc", F);
    BasicBlock *afterBB = BasicBlock::Create(context, "for.after", F);

    builder.CreateBr(condBB);

    builder.SetInsertPoint(condBB);
    if (fcs->cond)
    {
        Value *condv = codegen_expr(fcs->cond.get());
        if (!condv)
            return nullptr;

        Value *cmp = builder.CreateICmpNE(
            condv,
            ConstantInt::get(condv->getType(), 0),
            "forcond");
        builder.CreateCondBr(cmp, bodyBB, afterBB);
    }
    else
    {

        builder.CreateBr(bodyBB);
    }

    builder.SetInsertPoint(bodyBB);

    break_targets.push_back(afterBB);
    continue_targets.push_back(incBB);

    if (fcs->body)
    {
        codegen_block(fcs->body.get());
    }

    if (!builder.GetInsertBlock()->getTerminator())
    {
        builder.CreateBr(incBB);
    }

    break_targets.pop_back();
    continue_targets.pop_back();

    if (!builder.GetInsertBlock()->getTerminator())
    {
        builder.CreateBr(incBB);
    }

    builder.SetInsertPoint(incBB);
    if (fcs->post)
    {
        codegen_expr(fcs->post.get());
    }
    builder.CreateBr(condBB);

    builder.SetInsertPoint(afterBB);

    return nullptr;
}
