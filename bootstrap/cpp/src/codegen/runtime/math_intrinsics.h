#pragma once

#include "../codegen.h"
#include "../common.h"

#include <llvm/IR/Constants.h>

namespace codegen
{

Value *CodeGen::codegen_math_intrinsic_call(const std::string &name, const ast::CallExpr *ce)
{
    if (name == "__YCPL_std__math_abs")
    {
        if (ce->args.size() != 1)
        {
            error("math.abs expects 1 argument");
            return nullptr;
        }
        Value *arg = codegen_expr(ce->args[0].get());
        if (!arg)
            return nullptr;
        if (arg->getType()->isIntegerTy())
        {
            Value *zero = ConstantInt::get(arg->getType(), 0);
            return builder.CreateSelect(builder.CreateICmpSLT(arg, zero), builder.CreateNeg(arg), arg, "math.abs");
        }

        Function *fabsFn = get_or_declare_c_function("fabs");
        if (!fabsFn)
        {
            error("fabs is not available");
            return nullptr;
        }
        return builder.CreateCall(fabsFn, {coerce_to_double(arg, "math.abs.double")}, "call_fabs");
    }

    if (name != "__YCPL_std__math_pow" && name != "__YCPL_std__math_sin" &&
        name != "__YCPL_std__math_cos" && name != "__YCPL_std__math_sqrt")
    {
        error("unknown math intrinsic: " + name);
        return nullptr;
    }

    std::string cName;
    if (name == "__YCPL_std__math_pow")
        cName = "pow";
    else if (name == "__YCPL_std__math_sin")
        cName = "sin";
    else if (name == "__YCPL_std__math_cos")
        cName = "cos";
    else
        cName = "sqrt";

    Function *fn = get_or_declare_c_function(cName);
    if (!fn)
    {
        error(cName + " is not available");
        return nullptr;
    }

    if (cName == "pow")
    {
        if (ce->args.size() != 2)
        {
            error("math.pow expects 2 arguments");
            return nullptr;
        }
        return builder.CreateCall(fn, {coerce_to_double(codegen_expr(ce->args[0].get()), "math.pow.a"), coerce_to_double(codegen_expr(ce->args[1].get()), "math.pow.b")}, "call_pow");
    }

    if (ce->args.size() != 1)
    {
        error("math function expects 1 argument");
        return nullptr;
    }
    return builder.CreateCall(fn, {coerce_to_double(codegen_expr(ce->args[0].get()), "math.arg")}, "call_" + cName);
}

}
