#pragma once
#include "../codegen.h"
#include "../common.h"

namespace codegen
{

static bool is_YCPL_std_intrinsic(const std::string &name)
{
    return name.rfind("__YCPL_std__", 0) == 0;
}

static std::string canonical_YCPL_std_intrinsic(const std::string &name)
{
    return name;
}

Value *CodeGen::codegen_std_intrinsic_call(const std::string &name, const ast::CallExpr *ce)
{
    const std::string canonical = canonical_YCPL_std_intrinsic(name);

    if (canonical == "__YCPL_std__fmt_println")
        return codegen_println_call(ce);

    if (canonical == "__YCPL_std__fmt_printf")
        return codegen_printf_call(ce);

    if (canonical == "__YCPL_std__fmt_print")
        return codegen_print_call(ce);

    if (canonical.rfind("__YCPL_std__array_", 0) == 0)
        return codegen_array_intrinsic_call(canonical, ce);

    if (canonical.rfind("__YCPL_std__mem_", 0) == 0)
        return codegen_memory_intrinsic_call(canonical, ce);

    if (canonical.rfind("__YCPL_std__str_", 0) == 0)
        return codegen_string_intrinsic_call(canonical, ce);

    if (canonical.rfind("__YCPL_std__math_", 0) == 0)
        return codegen_math_intrinsic_call(canonical, ce);

    error("unknown std intrinsic: " + name);
    return nullptr;
}

Value *CodeGen::codegen_call(const ast::CallExpr *ce)
{
    if (auto member = dynamic_cast<const ast::MemberExpr *>(ce->callee.get()))
    {
        TypeShape shape = parse_type_shape(infer_expr_type_name(member->object.get()));
        if (shape.is_vec_type())
            return codegen_vec_method(member, ce);
    }

    if (auto ident = dynamic_cast<const ast::Ident *>(ce->callee.get()))
    {
        if (ident->name == "__YCPL_c__llvm_vec_data_i64")
        {
            if (ce->args.size() != 1)
            {
                error("c.llvm.vec_data_i64 expects one Vec argument");
                return nullptr;
            }
            Value *header = codegen_expr(ce->args[0].get());
            if (!header)
                return nullptr;
            Value *dataAddress = array_header_field_ptr(header, detail::RuntimeArrayField::Data, "llvm.vec.data.ptr");
            return builder.CreateLoad(get_i8ptr_type(), dataAddress, "llvm.vec.data");
        }

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
