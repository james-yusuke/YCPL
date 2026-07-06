#pragma once

#include "../codegen.h"
#include "../common.h"

#include <llvm/IR/Constants.h>

namespace codegen
{

Value *CodeGen::codegen_string_intrinsic_call(const std::string &name, const ast::CallExpr *ce)
{
    if (name != "__YCPL_std__str_len" && name != "__YCPL_std__str_cmp" &&
        name != "__YCPL_std__str_copy" && name != "__YCPL_std__str_eq")
    {
        error("unknown str intrinsic: " + name);
        return nullptr;
    }

    std::string cName = name == "__YCPL_std__str_len" ? "strlen" : (name == "__YCPL_std__str_copy" ? "strcpy" : "strcmp");
    Function *fn = get_or_declare_c_function(cName);
    if (!fn)
    {
        error(cName + " is not available");
        return nullptr;
    }

    if (name == "__YCPL_std__str_len")
    {
        if (ce->args.size() != 1)
        {
            error("str.len expects 1 argument");
            return nullptr;
        }
        Value *s = coerce_to_i8ptr(codegen_expr(ce->args[0].get()), "str.len.ptr");
        return builder.CreateCall(fn, {s}, "call_strlen");
    }

    if (ce->args.size() != 2)
    {
        error("str function expects 2 arguments");
        return nullptr;
    }

    Value *a = coerce_to_i8ptr(codegen_expr(ce->args[0].get()), "str.arg.a");
    Value *b = coerce_to_i8ptr(codegen_expr(ce->args[1].get()), "str.arg.b");
    Value *result = builder.CreateCall(fn, {a, b}, "call_" + cName);
    if (name == "__YCPL_std__str_eq")
        return builder.CreateICmpEQ(result, ConstantInt::get(result->getType(), 0), "str.eq");
    return result;
}

}
