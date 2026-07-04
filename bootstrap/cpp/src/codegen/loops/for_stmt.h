#pragma once
#include "../codegen.h"
#include "../common.h"
#include <llvm/IR/Constants.h>
#include <llvm/IR/DerivedTypes.h>
#include <llvm/IR/Intrinsics.h>

using namespace llvm;
using namespace codegen;

Value *CodeGen::codegen_forstmt(const ast::ForStmt *fs2)
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

    builder.SetInsertPoint(bodyBB);

    push_scope();
    if (fs2->body)
        codegen_block(fs2->body.get());
    pop_scope();

    if (!builder.GetInsertBlock()->getTerminator())
        builder.CreateBr(loopHeaderBB);

    break_targets.pop_back();
    continue_targets.pop_back();

    builder.SetInsertPoint(afterBB);

    return nullptr;
}
