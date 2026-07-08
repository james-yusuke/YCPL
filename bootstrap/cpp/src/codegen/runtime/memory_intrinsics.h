#pragma once

#include "../codegen.h"
#include "../common.h"

#include <llvm/IR/Constants.h>
#include <llvm/IR/DerivedTypes.h>

namespace codegen
{

Value *CodeGen::codegen_memory_intrinsic_call(const std::string &name, const ast::CallExpr *ce)
{
    if (name == "__YCPL_std__mem_alloc" || name == "__YCPL_std__mem_calloc" || name == "__YCPL_std__mem_realloc" ||
        name == "__YCPL_std__mem_free" || name == "__YCPL_std__mem_copy" || name == "__YCPL_std__mem_set")
    {
        std::string cName;
        if (name == "__YCPL_std__mem_alloc")
            cName = "yc_alloc";
        else if (name == "__YCPL_std__mem_calloc")
            cName = "yc_calloc";
        else if (name == "__YCPL_std__mem_realloc")
            cName = "yc_realloc";
        else if (name == "__YCPL_std__mem_free")
            cName = "yc_release";
        else if (name == "__YCPL_std__mem_copy")
            cName = "memcpy";
        else
            cName = "memset";

        Function *fn = get_or_declare_c_function(cName);
        if (!fn)
        {
            error(cName + " is not available");
            return nullptr;
        }

        std::vector<Value *> args;
        for (size_t i = 0; i < ce->args.size(); ++i)
        {
            Value *arg = codegen_expr(ce->args[i].get());
            if (!arg)
                return nullptr;

            if (cName == "yc_alloc")
                args.push_back(coerce_to_i64(arg, "mem.alloc.size"));
            else if (cName == "yc_calloc")
                args.push_back(coerce_to_i64(arg, i == 0 ? "mem.calloc.count" : "mem.calloc.size"));
            else if (cName == "yc_realloc")
                args.push_back(i == 0 ? coerce_to_i8ptr(arg, "mem.realloc.ptr") : coerce_to_i64(arg, "mem.realloc.size"));
            else if (cName == "yc_release")
                args.push_back(coerce_to_i8ptr(arg, "mem.free.ptr"));
            else if (cName == "memcpy")
                args.push_back(i < 2 ? coerce_to_i8ptr(arg, "mem.copy.ptr") : coerce_to_i64(arg, "mem.copy.size"));
            else if (i == 0)
                args.push_back(coerce_to_i8ptr(arg, "mem.set.ptr"));
            else if (i == 1)
                args.push_back(coerce_to_i32(arg, "mem.set.value"));
            else
                args.push_back(coerce_to_i64(arg, "mem.set.size"));
        }

        if (fn->getReturnType()->isVoidTy())
            return builder.CreateCall(fn, args);
        return builder.CreateCall(fn, args, "call_" + cName);
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

        return ConstantInt::get(get_i64_type(), module->getDataLayout().getTypeAllocSize(llvmTy));
    }

    error("unknown mem intrinsic: " + name);
    return nullptr;
}

}
