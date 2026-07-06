#pragma once

#include "../codegen.h"
#include "../common.h"

#include <llvm/ADT/SmallVector.h>

namespace codegen
{

Value *CodeGen::codegen_print_call(const ast::CallExpr *ce)
{
    if (ce->args.empty())
        return nullptr;

    SmallVector<Value *, 8> printfArgs;
    std::string fmtStr;
    for (size_t i = 0; i < ce->args.size(); ++i)
    {
        Value *arg = codegen_expr(ce->args[i].get());
        if (!arg)
            return nullptr;

        if (arg->getType()->isPointerTy())
        {
            fmtStr += "%s";
            arg = coerce_to_i8ptr(arg, "fmt.print.ptr");
        }
        else if (arg->getType()->isFloatingPointTy())
        {
            fmtStr += "%f";
            arg = coerce_to_double(arg, "fmt.print.double");
        }
        else if (arg->getType()->isIntegerTy())
        {
            fmtStr += "%lld";
            arg = coerce_to_i64(arg, "fmt.print.i64");
        }
        else
        {
            fmtStr += "%p";
            arg = coerce_to_i8ptr(arg, "fmt.print.anyptr");
        }

        if (i + 1 < ce->args.size())
            fmtStr += " ";
        printfArgs.push_back(arg);
    }

    SmallVector<Value *, 8> callArgs;
    callArgs.push_back(make_global_string(fmtStr, ".fmt.print"));
    for (Value *arg : printfArgs)
        callArgs.push_back(arg);
    return builder.CreateCall(get_printf(), callArgs, "call_fmt_print");
}

}
