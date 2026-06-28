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

Value *CodeGen::codegen_println_call(const ast::CallExpr *ce)
{
    FunctionCallee printfFn = get_printf();

    if (ce->args.empty())
    {
        Value *fmt = make_global_string("\n", ".fmtln");
        return builder.CreateCall(printfFn, {fmt}, "call_printf");
    }

    std::string fmtStr;
    SmallVector<Value *, 8> printfArgs;

    for (size_t i = 0; i < ce->args.size(); ++i)
    {
        Value *arg = codegen_expr(ce->args[i].get());
        if (!arg)
            return nullptr;

        bool isLast = (i + 1 == ce->args.size());

        if (arg->getType()->isPointerTy())
        {

            fmtStr += "%s";

            if (arg->getType() != get_i8ptr_type())
                arg = builder.CreateBitCast(arg, get_i8ptr_type(), "cast_to_i8ptr");
            printfArgs.push_back(arg);
        }
        else if (arg->getType()->isFloatingPointTy())
        {

            fmtStr += "%f";
            if (arg->getType()->isFloatTy())
                arg = builder.CreateFPExt(arg, Type::getDoubleTy(context), "cast_double");
            else if (!arg->getType()->isDoubleTy())
                arg = builder.CreateFPCast(arg, Type::getDoubleTy(context), "cast_double");
            printfArgs.push_back(arg);
        }
        else if (arg->getType()->isIntegerTy())
        {
            fmtStr += "%lld";
            if (!arg->getType()->isIntegerTy(64))
                arg = builder.CreateIntCast(arg, get_i64_type(), !arg->getType()->isIntegerTy(1), "cast_i64");
            printfArgs.push_back(arg);
        }
        else
        {
            fmtStr += "%p";
            if (!arg->getType()->isPointerTy())
                arg = builder.CreateBitCast(arg, get_i8ptr_type(), "cast_ptr");
            printfArgs.push_back(arg);
        }

        if (!isLast)
            fmtStr += " ";
    }

    fmtStr += "\n";
    Value *fmt = make_global_string(fmtStr.c_str(), ".fmt");

    SmallVector<Value *, 8> callArgs;
    callArgs.push_back(fmt);
    for (Value *v : printfArgs)
        callArgs.push_back(v);

    return builder.CreateCall(printfFn, callArgs, "call_printf");
}
