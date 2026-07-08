#pragma once
#include "../codegen.h"
#include "../common.h"
#include <llvm/IR/Constants.h>
#include <llvm/IR/DerivedTypes.h>
#include <llvm/IR/Intrinsics.h>

namespace codegen
{

Value *CodeGen::codegen_for_loop(const ast::ForStmt *forStmt)
{
    Function *F = builder.GetInsertBlock()->getParent();

    BasicBlock *loopHeaderBB = BasicBlock::Create(context, "for.loop", F);
    BasicBlock *bodyBB = BasicBlock::Create(context, "for.body", F);
    BasicBlock *afterBB = BasicBlock::Create(context, "for.end", F);

    if (!builder.GetInsertBlock()->getTerminator())
        builder.CreateBr(loopHeaderBB);

    builder.SetInsertPoint(loopHeaderBB);

    if (!builder.GetInsertBlock()->getTerminator())
        builder.CreateBr(bodyBB);


    break_targets.push_back(afterBB);
    continue_targets.push_back(loopHeaderBB);
    break_defer_depths.push_back(deferred_scopes.size());
    continue_defer_depths.push_back(deferred_scopes.size());

    builder.SetInsertPoint(bodyBB);

    push_scope();
    if (forStmt->body)
        codegen_block(forStmt->body.get());
    pop_scope();

    if (!builder.GetInsertBlock()->getTerminator())
        builder.CreateBr(loopHeaderBB);

    break_targets.pop_back();
    continue_targets.pop_back();
    break_defer_depths.pop_back();
    continue_defer_depths.pop_back();

    builder.SetInsertPoint(afterBB);

    return nullptr;
}

}
