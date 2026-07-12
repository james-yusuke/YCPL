#pragma once
#include "../codegen.h"
#include "../common.h"
#include <llvm/IR/Constants.h>
#include <llvm/IR/DerivedTypes.h>

namespace codegen
{

Value *CodeGen::codegen_switchstmt(const ast::SwitchStmt *ss)
{
    if (!ss)
        return nullptr;

    Function *F = builder.GetInsertBlock()->getParent();
    Value *switchValue = codegen_expr(ss->value.get());
    if (!switchValue)
        return nullptr;

    if (!switchValue->getType()->isIntegerTy())
    {
        error("switch expression must be an integer, bool, char, or enum value");
        return nullptr;
    }

    Type *switchTy = get_int_type();
    if (switchValue->getType() != switchTy)
        switchValue = builder.CreateSExtOrTrunc(switchValue, switchTy, "switch.value.cast");

    std::vector<ConstantInt *> caseConstants;
    caseConstants.reserve(ss->cases.size());
    for (const auto &caseNode : ss->cases)
    {
        Value *caseValue = codegen_expr(caseNode.value.get());
        auto *caseConst = llvm::dyn_cast_or_null<ConstantInt>(caseValue);
        if (!caseConst)
        {
            error("switch case value must be a constant integer, char, bool, or enum value");
            caseConstants.push_back(ConstantInt::get(cast<IntegerType>(switchTy), 0, true));
            continue;
        }

        caseConstants.push_back(ConstantInt::get(
            cast<IntegerType>(switchTy),
            caseConst->getSExtValue(),
            true));
    }

    BasicBlock *afterBB = BasicBlock::Create(context, "switch.end", F);
    BasicBlock *defaultBB = ss->default_body
                                ? BasicBlock::Create(context, "switch.default", F)
                                : afterBB;

    std::vector<BasicBlock *> caseBlocks;
    caseBlocks.reserve(ss->cases.size());
    for (size_t i = 0; i < ss->cases.size(); ++i)
        caseBlocks.push_back(BasicBlock::Create(context, "switch.case", F));

    auto *switchInst = builder.CreateSwitch(
        switchValue,
        defaultBB,
        static_cast<unsigned>(ss->cases.size()));

    for (size_t i = 0; i < ss->cases.size(); ++i)
        switchInst->addCase(caseConstants[i], caseBlocks[i]);

    break_targets.push_back(afterBB);
    break_defer_depths.push_back(deferred_scopes.size());
    break_runtime_depths.push_back(runtime_scope_depth);

    for (size_t i = 0; i < ss->cases.size(); ++i)
    {
        builder.SetInsertPoint(caseBlocks[i]);
        if (ss->cases[i].body)
            codegen_block(ss->cases[i].body.get());
        if (!builder.GetInsertBlock()->getTerminator())
            builder.CreateBr(afterBB);
    }

    if (ss->default_body)
    {
        builder.SetInsertPoint(defaultBB);
        codegen_block(ss->default_body.get());
        if (!builder.GetInsertBlock()->getTerminator())
            builder.CreateBr(afterBB);
    }

    break_targets.pop_back();
    break_defer_depths.pop_back();
    break_runtime_depths.pop_back();
    builder.SetInsertPoint(afterBB);
    return nullptr;
}

}
