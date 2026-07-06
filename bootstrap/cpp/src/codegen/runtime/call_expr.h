#pragma once
#include "../codegen.h"
#include "../common.h"
#include <llvm/IR/Constants.h>
#include <llvm/IR/DerivedTypes.h>
#include <llvm/IR/Intrinsics.h>
#include <llvm/ADT/SmallVector.h>
#include <llvm/ADT/Twine.h>

namespace codegen
{

static bool is_YCPL_std_intrinsic(const std::string &name)
{
    return name.rfind("__YCPL_std__", 0) == 0;
}

Value *CodeGen::codegen_std_intrinsic_call(const std::string &name, const ast::CallExpr *ce)
{
    if (name == "__YCPL_std__fmt_println")
        return codegen_println_call(ce);

    if (name == "__YCPL_std__fmt_printf")
        return codegen_printf_call(ce);

    if (name == "__YCPL_std__fmt_print")
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

    if (name.rfind("__YCPL_std__array_", 0) == 0)
        return codegen_array_intrinsic_call(name, ce);

    if (name == "__YCPL_std__mem_alloc" || name == "__YCPL_std__mem_calloc" || name == "__YCPL_std__mem_realloc" ||
        name == "__YCPL_std__mem_free" || name == "__YCPL_std__mem_copy" || name == "__YCPL_std__mem_set")
    {
        std::string c_name;
        if (name == "__YCPL_std__mem_alloc")
            c_name = "malloc";
        else if (name == "__YCPL_std__mem_calloc")
            c_name = "calloc";
        else if (name == "__YCPL_std__mem_realloc")
            c_name = "realloc";
        else if (name == "__YCPL_std__mem_free")
            c_name = "free";
        else if (name == "__YCPL_std__mem_copy")
            c_name = "memcpy";
        else
            c_name = "memset";

        Function *fn = get_or_declare_c_function(c_name);
        if (!fn)
        {
            error(c_name + " is not available");
            return nullptr;
        }

        std::vector<Value *> args;
        for (size_t i = 0; i < ce->args.size(); ++i)
        {
            Value *arg = codegen_expr(ce->args[i].get());
            if (!arg)
                return nullptr;

            if (c_name == "malloc")
            {
                args.push_back(coerce_to_i64(arg, "mem.alloc.size"));
            }
            else if (c_name == "calloc")
            {
                args.push_back(coerce_to_i64(arg, i == 0 ? "mem.calloc.count" : "mem.calloc.size"));
            }
            else if (c_name == "realloc")
            {
                args.push_back(i == 0 ? coerce_to_i8ptr(arg, "mem.realloc.ptr") : coerce_to_i64(arg, "mem.realloc.size"));
            }
            else if (c_name == "free")
            {
                args.push_back(coerce_to_i8ptr(arg, "mem.free.ptr"));
            }
            else if (c_name == "memcpy")
            {
                args.push_back(i < 2 ? coerce_to_i8ptr(arg, "mem.copy.ptr") : coerce_to_i64(arg, "mem.copy.size"));
            }
            else
            {
                if (i == 0)
                    args.push_back(coerce_to_i8ptr(arg, "mem.set.ptr"));
                else if (i == 1)
                    args.push_back(coerce_to_i32(arg, "mem.set.value"));
                else
                    args.push_back(coerce_to_i64(arg, "mem.set.size"));
            }
        }

        if (fn->getReturnType()->isVoidTy())
            return builder.CreateCall(fn, args);
        return builder.CreateCall(fn, args, "call_" + c_name);
    }

    if (name == "__YCPL_std__mem_sizeof")
    {
        if (ce->args.size() != 1)
        {
            error("mem.sizeof expects one type argument");
            return nullptr;
        }
        auto typeExpr = dynamic_cast<const ast::TypeExpr *>(ce->args[0].get());
        if (!typeExpr)
        {
            error("mem.sizeof expects a type argument");
            return nullptr;
        }

        Type *llvmTy = nullptr;
        if (dynamic_cast<const ast::ArrayType *>(typeExpr->type.get()))
            llvmTy = detail::getOrCreateRuntimeArrayHeaderType(context);
        else
            llvmTy = resolve_type_from_ast(typeExpr->type.get());
        if (!llvmTy)
        {
            error("mem.sizeof cannot resolve type");
            return nullptr;
        }
        const DataLayout &dl = module->getDataLayout();
        return ConstantInt::get(get_i64_type(), dl.getTypeAllocSize(llvmTy));
    }

    if (name == "__YCPL_std__str_len" || name == "__YCPL_std__str_cmp" || name == "__YCPL_std__str_copy" || name == "__YCPL_std__str_eq")
    {
        std::string c_name = name == "__YCPL_std__str_len" ? "strlen" : (name == "__YCPL_std__str_copy" ? "strcpy" : "strcmp");
        Function *fn = get_or_declare_c_function(c_name);
        if (!fn)
        {
            error(c_name + " is not available");
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
        Value *result = builder.CreateCall(fn, {a, b}, "call_" + c_name);
        if (name == "__YCPL_std__str_eq")
            return builder.CreateICmpEQ(result, ConstantInt::get(result->getType(), 0), "str.eq");
        return result;
    }

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

    if (name == "__YCPL_std__math_pow" || name == "__YCPL_std__math_sin" || name == "__YCPL_std__math_cos" || name == "__YCPL_std__math_sqrt")
    {
        std::string c_name;
        if (name == "__YCPL_std__math_pow")
            c_name = "pow";
        else if (name == "__YCPL_std__math_sin")
            c_name = "sin";
        else if (name == "__YCPL_std__math_cos")
            c_name = "cos";
        else
            c_name = "sqrt";

        Function *fn = get_or_declare_c_function(c_name);
        if (!fn)
        {
            error(c_name + " is not available");
            return nullptr;
        }

        if (c_name == "pow")
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
        return builder.CreateCall(fn, {coerce_to_double(codegen_expr(ce->args[0].get()), "math.arg")}, "call_" + c_name);
    }

    error("unknown std intrinsic: " + name);
    return nullptr;
}

Value *CodeGen::codegen_call(const ast::CallExpr *ce)
{
    if (auto ident = dynamic_cast<const ast::Ident *>(ce->callee.get()))
    {
        if (is_YCPL_std_intrinsic(ident->name))
        {
            return codegen_std_intrinsic_call(ident->name, ce);
        }

        if (ident->name == "println")
        {
            return codegen_println_call(ce);
        }
        else if (ident->name == "printf")
        {
            return codegen_printf_call(ce);
        }
        else if (ident->name == "sprintf")
        {
            return codegen_sprintf_call(ce);
        }
        else if (ident->name == "len")
        {
            return codegen_len_call(ce);
        }
        else if (ident->name == "append")
        {
            return codegen_append_call(ce);
        }
        else if (ident->name == "cast")
        {
            return codegen_cast_call(ce);
        }
        else if (ident->name == "new")
        {
            return codegen_new_call(ce);
        }
    }

    Value *calleeVal = codegen_expr(ce->callee.get());
    if (!calleeVal)
        return nullptr;

    Function *F = nullptr;
    if (auto gv = dyn_cast<GlobalValue>(calleeVal))
    {
        F = dyn_cast<Function>(gv);
    }

    if (!F)
    {
        if (auto id = dynamic_cast<const ast::Ident *>(ce->callee.get()))
        {
            auto it = function_protos.find(id->name);
            if (it != function_protos.end())
                F = it->second;
        }
    }

    if (!F)
    {
        error("call to unknown function");
        return nullptr;
    }

    std::vector<Value *> argsV;
    FunctionType *calleeType = F->getFunctionType();
    for (size_t i = 0; i < ce->args.size(); ++i)
    {
        Value *argv = codegen_expr(ce->args[i].get());
        if (!argv)
            return nullptr;

        if (i < calleeType->getNumParams())
        {
            Type *paramTy = calleeType->getParamType(static_cast<unsigned>(i));
            if (argv->getType() != paramTy)
            {
                if (argv->getType()->isIntegerTy() && paramTy->isIntegerTy())
                    argv = builder.CreateSExtOrTrunc(argv, paramTy, "call.arg.intcast");
                else if (argv->getType()->isIntegerTy() && paramTy->isFloatingPointTy())
                    argv = builder.CreateSIToFP(argv, paramTy, "call.arg.sitofp");
                else if (argv->getType()->isFloatingPointTy() && paramTy->isIntegerTy())
                    argv = builder.CreateFPToSI(argv, paramTy, "call.arg.fptosi");
                else if (argv->getType()->isPointerTy() && paramTy->isPointerTy())
                    argv = builder.CreatePointerCast(argv, paramTy, "call.arg.ptrcast");
                else if (argv->getType()->isPointerTy() && paramTy->isIntegerTy())
                    argv = builder.CreatePtrToInt(argv, paramTy, "call.arg.ptrtoint");
                else if (argv->getType()->isIntegerTy() && paramTy->isPointerTy())
                    argv = builder.CreateIntToPtr(argv, cast<PointerType>(paramTy), "call.arg.inttoptr");
            }
        }
        argsV.push_back(argv);
    }

    CallInst *callInst = builder.CreateCall(F, argsV);
    if (!F->getReturnType()->isVoidTy())
    {
        callInst->setName("calltmp");
        return callInst;
    }

    return nullptr;
}

}
