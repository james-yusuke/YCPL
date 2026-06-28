#pragma once
#include "../codegen.h"
#include "../common.h"
#include <llvm/IR/Constants.h>
#include <llvm/IR/DerivedTypes.h>
#include <llvm/IR/Intrinsics.h>
#include <llvm/ADT/SmallVector.h>
#include <llvm/ADT/Twine.h>

using namespace llvm;
using namespace codegen;

Value *CodeGen::codegen_sprintf_call(const ast::CallExpr *ce)
{

    if (ce->args.size() < 2)
    {
        error("sprintf requires destination buffer and format string");
        return nullptr;
    }

    Value *destArg = codegen_expr(ce->args[0].get());
    if (!destArg)
        return nullptr;

    Value *fmtArg = codegen_expr(ce->args[1].get());
    if (!fmtArg)
        return nullptr;

    Type *i8Ty = Type::getInt8Ty(context);
    PointerType *i8PtrTy = PointerType::getUnqual(i8Ty);

    if (destArg->getType() != i8PtrTy)
    {
        if (destArg->getType()->isPointerTy())
        {
            destArg = builder.CreateBitCast(destArg, i8PtrTy, "sprintf.dest.cast");
        }
        else
        {
            error("sprintf: destination argument must be a pointer");
            return nullptr;
        }
    }

    if (fmtArg->getType() != i8PtrTy)
    {
        if (fmtArg->getType()->isPointerTy())
        {
            fmtArg = builder.CreateBitCast(fmtArg, i8PtrTy, "sprintf.fmt.cast");
        }
        else
        {
            error("sprintf: format argument must be a pointer");
            return nullptr;
        }
    }

    std::vector<Value *> argsV;
    argsV.push_back(destArg);
    argsV.push_back(fmtArg);

    for (size_t i = 2; i < ce->args.size(); ++i)
    {
        Value *v = codegen_expr(ce->args[i].get());
        if (!v)
            return nullptr;
        argsV.push_back(v);
    }

    FunctionType *sprintfTy = FunctionType::get(
        Type::getInt32Ty(context),
        {i8PtrTy, i8PtrTy},
        /*isVarArg=*/true);
    FunctionCallee sprintfFn = module->getOrInsertFunction("sprintf", sprintfTy);

    return builder.CreateCall(sprintfFn, ArrayRef<Value *>(argsV), "call_sprintf");
}
