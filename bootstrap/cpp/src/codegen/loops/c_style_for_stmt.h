#pragma once
#include "../codegen.h"
#include "../common.h"
#include <llvm/IR/Constants.h>
#include <llvm/IR/DerivedTypes.h>
#include <llvm/IR/Intrinsics.h>
#include <llvm/IR/Verifier.h>

namespace codegen
{

Value *CodeGen::codegen_c_style_for_loop(const ast::ForCStyleStmt *forStmt)
{
    Function *F = builder.GetInsertBlock()->getParent();

    if (forStmt->init)
    {
        codegen_stmt(forStmt->init.get());
    }

    BasicBlock *condBB = BasicBlock::Create(context, "for.cond", F);
    BasicBlock *bodyBB = BasicBlock::Create(context, "for.body", F);
    BasicBlock *incBB = BasicBlock::Create(context, "for.inc", F);
    BasicBlock *afterBB = BasicBlock::Create(context, "for.after", F);

    builder.CreateBr(condBB);

    builder.SetInsertPoint(condBB);
    if (forStmt->cond)
    {
        Value *condv = codegen_expr(forStmt->cond.get());
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
    break_defer_depths.push_back(deferred_scopes.size());
    continue_defer_depths.push_back(deferred_scopes.size());
    break_runtime_depths.push_back(runtime_scope_depth);
    continue_runtime_depths.push_back(runtime_scope_depth);

    push_scope();
    if (forStmt->body)
    {
        codegen_block(forStmt->body.get());
    }
    pop_scope();

    if (!builder.GetInsertBlock()->getTerminator())
    {
        builder.CreateBr(incBB);
    }

    break_targets.pop_back();
    continue_targets.pop_back();
    break_defer_depths.pop_back();
    continue_defer_depths.pop_back();
    break_runtime_depths.pop_back();
    continue_runtime_depths.pop_back();

    if (!builder.GetInsertBlock()->getTerminator())
    {
        builder.CreateBr(incBB);
    }

    builder.SetInsertPoint(incBB);
    if (forStmt->post)
    {
        codegen_expr(forStmt->post.get());
    }
    builder.CreateBr(condBB);

    builder.SetInsertPoint(afterBB);

    return nullptr;
}

}
