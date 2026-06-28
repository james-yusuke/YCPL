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

Value *CodeGen::codegen_printf_call(const ast::CallExpr *ce)
{
    if (ce->args.empty())
    {
        error("printf requires at least format string");
        return nullptr;
    }
    Value *fmtArg = codegen_expr(ce->args[0].get());
    if (!fmtArg)
        return nullptr;
    std::vector<Value *> argsV;
    argsV.push_back(fmtArg);
    for (size_t i = 1; i < ce->args.size(); ++i)
    {
        Value *v = codegen_expr(ce->args[i].get());
        if (!v)
            return nullptr;
        argsV.push_back(v);
    }
    FunctionCallee printfFn = get_printf();
    return builder.CreateCall(printfFn, argsV, "call_printf");
}
