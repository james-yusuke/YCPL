#pragma once
#include "../codegen.h"
#include "../common.h"
#include "../array/parse.h"
#include <llvm/IR/Constants.h>
#include <llvm/IR/DerivedTypes.h>
#include <llvm/IR/Intrinsics.h>
#include <llvm/ADT/SmallVector.h>
#include <llvm/ADT/Twine.h>

using namespace llvm;
using namespace codegen;

static std::string llvm_type_to_string(Type *t)
{
    std::string s;
    llvm::raw_string_ostream os(s);
    t->print(os);
    return os.str();
}

Value *CodeGen::codegen_cast_call(const ast::CallExpr *ce)
{
    if (ce->args.size() != 2)
    {
        error("cast requires exactly two arguments: cast(TYPE, value)");
        return nullptr;
    }

    llvm::Type *dstType = nullptr;
    if (auto astType = dynamic_cast<const ast::Type *>(ce->args[0].get()))
        dstType = resolve_type_from_ast_local(astType);
    else if (auto typeIdent = dynamic_cast<const ast::Ident *>(ce->args[0].get()))
        dstType = resolve_type_by_name(typeIdent->name);
    else
    {
        error("cast: first argument must be a type (type literal or type name)");
        return nullptr;
    }
    if (!dstType)
    {
        error("cast: unknown/unsupported destination type");
        return nullptr;
    }

    Value *srcVal = codegen_expr(ce->args[1].get());
    if (!srcVal)
        return nullptr;
    Type *srcType = srcVal->getType();

    if (srcType == dstType)
        return srcVal;

    LLVMContext &context = builder.getContext();
    Type *i8ptr = detail::getI8PtrTy(context);
    IntegerType *i32Ty = Type::getInt32Ty(context);

    auto is_string_like_type = [&](Type *t) -> bool
    {
        if (!t->isPointerTy())
            return false;
        Type *pe = t;
        if (pe->isIntegerTy(8))
            return true;
        if (pe->isArrayTy() && pe->getArrayElementType()->isIntegerTy(8))
            return true;
        return false;
    };

    auto is_string_like_value = [&](Value *v) -> bool
    {
        if (is_string_like_type(v->getType()))
            return true;

        if (auto *gv = dyn_cast<GlobalVariable>(v))
        {
            Type *gvTy = gv->getValueType();
            if (gvTy->isArrayTy() && gvTy->getArrayElementType()->isIntegerTy(8))
                return true;
        }

        if (auto *cex = dyn_cast<ConstantExpr>(v))
        {
            if (cex->getOpcode() == Instruction::GetElementPtr)
            {

                if (auto *base = dyn_cast<GlobalVariable>(cex->getOperand(0)))
                {
                    Type *baseTy = base->getValueType();
                    if (baseTy->isArrayTy() && baseTy->getArrayElementType()->isIntegerTy(8))
                        return true;
                }
            }

            for (unsigned i = 0; i < cex->getNumOperands(); ++i)
            {
                if (auto *op = dyn_cast<GlobalVariable>(cex->getOperand(i)))
                {
                    Type *opTy = op->getValueType();
                    if (opTy->isArrayTy() && opTy->getArrayElementType()->isIntegerTy(8))
                        return true;
                }
            }
        }

        return false;
    };

    auto to_cstr_i8ptr = [&](Value *v) -> Value *
    {
        return builder.CreateBitCast(v, i8ptr, "cstr");
    };

    if (is_string_like_value(srcVal))
    {

        if (dstType->isIntegerTy())
        {
            Value *cstr = to_cstr_i8ptr(srcVal);
            FunctionType *atoiFT = FunctionType::get(i32Ty, {i8ptr}, false);
            Function *atoiF = module->getFunction("atoi");
            if (!atoiF)
                atoiF = Function::Create(atoiFT, Function::ExternalLinkage, "atoi", module.get());

            Value *parsed = builder.CreateCall(atoiF, {cstr}, "atoi.res");

            unsigned dstBits = dstType->getIntegerBitWidth();
            if (dstBits == 32)
                return parsed;
            if (dstBits > 32)
                return builder.CreateSExt(parsed, dstType, "casttmp");
            return builder.CreateTrunc(parsed, dstType, "casttmp");
        }

        if (dstType->isFloatingPointTy())
        {
            Value *cstr = to_cstr_i8ptr(srcVal);
            FunctionType *atofFT = FunctionType::get(Type::getDoubleTy(context), {i8ptr}, false);
            Function *atofF = module->getFunction("atof");
            if (!atofF)
                atofF = Function::Create(atofFT, Function::ExternalLinkage, "atof", module.get());

            Value *parsed = builder.CreateCall(atofF, {cstr}, "atof.res");
            if (dstType == Type::getDoubleTy(context))
                return parsed;
            return builder.CreateFPCast(parsed, dstType, "casttmp");
        }
    }

    if (srcType->isPointerTy() && dstType->isPointerTy())
        return builder.CreateBitCast(srcVal, dstType, "casttmp");

    if (srcType->isIntegerTy() && dstType->isIntegerTy())
    {
        unsigned srcBits = srcType->getIntegerBitWidth();
        unsigned dstBits = dstType->getIntegerBitWidth();
        if (dstBits == srcBits)
            return builder.CreateBitCast(srcVal, dstType, "casttmp");
        if (dstBits > srcBits)
            return builder.CreateZExt(srcVal, dstType, "casttmp");
        return builder.CreateTrunc(srcVal, dstType, "casttmp");
    }

    if (srcType->isIntegerTy() && dstType->isPointerTy())
        return builder.CreateIntToPtr(srcVal, dstType, "casttmp");

    if (srcType->isPointerTy() && dstType->isIntegerTy())
        return builder.CreatePtrToInt(srcVal, dstType, "casttmp");

    if (srcType->isFloatingPointTy() && dstType->isFloatingPointTy())
        return builder.CreateFPCast(srcVal, dstType, "casttmp");

    if (srcType->isFloatingPointTy() && dstType->isIntegerTy())
        return builder.CreateFPToSI(srcVal, dstType, "casttmp");

    if (srcType->isIntegerTy() && dstType->isFloatingPointTy())
        return builder.CreateSIToFP(srcVal, dstType, "casttmp");

    if (srcType->getPrimitiveSizeInBits() == dstType->getPrimitiveSizeInBits())
        return builder.CreateBitCast(srcVal, dstType, "casttmp");

    error("unsupported cast from '" + llvm_type_to_string(srcType) + "' to '" + llvm_type_to_string(dstType) + "'");
    return nullptr;
}