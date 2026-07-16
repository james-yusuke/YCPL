#pragma once

#include "../codegen.h"

#include <llvm/IR/DerivedTypes.h>

namespace codegen
{

Value *CodeGen::coerce_to_i64(Value *value, const std::string &label)
{
    if (!value)
        return nullptr;

    Type *i64Ty = get_i64_type();
    if (value->getType()->isIntegerTy(64))
        return value;
    if (value->getType()->isIntegerTy())
        return value->getType()->isIntegerTy(1)
                   ? builder.CreateZExtOrTrunc(value, i64Ty, label)
                   : builder.CreateSExtOrTrunc(value, i64Ty, label);
    if (value->getType()->isPointerTy())
        return builder.CreatePtrToInt(value, i64Ty, label);
    if (value->getType()->isFloatingPointTy())
        return builder.CreateFPToSI(value, i64Ty, label);

    return value;
}

Value *CodeGen::coerce_to_i32(Value *value, const std::string &label)
{
    if (!value)
        return nullptr;

    Type *i32Ty = get_int_type();
    if (value->getType()->isIntegerTy(32))
        return value;
    if (value->getType()->isIntegerTy())
        return value->getType()->isIntegerTy(1)
                   ? builder.CreateZExtOrTrunc(value, i32Ty, label)
                   : builder.CreateSExtOrTrunc(value, i32Ty, label);
    if (value->getType()->isFloatingPointTy())
        return builder.CreateFPToSI(value, i32Ty, label);

    return value;
}

Value *CodeGen::promote_variadic_argument(Value *value, const std::string &label)
{
    if (!value)
        return nullptr;

    Type *type = value->getType();
    if (type->isIntegerTy(1))
        return builder.CreateZExt(value, get_int_type(), label + ".bool.i32");
    if (type->isIntegerTy() && type->getIntegerBitWidth() < 32)
        return builder.CreateSExt(value, get_int_type(), label + ".int.i32");
    if (type->isFloatTy())
        return builder.CreateFPExt(value, get_double_type(), label + ".double");
    return value;
}

Value *CodeGen::coerce_to_double(Value *value, const std::string &label)
{
    if (!value)
        return nullptr;

    Type *doubleTy = get_double_type();
    if (value->getType()->isDoubleTy())
        return value;
    if (value->getType()->isFloatTy())
        return builder.CreateFPExt(value, doubleTy, label);
    if (value->getType()->isIntegerTy())
        return builder.CreateSIToFP(value, doubleTy, label);

    return value;
}

Value *CodeGen::coerce_to_i8ptr(Value *value, const std::string &label)
{
    if (!value)
        return nullptr;

    Type *i8ptrTy = get_i8ptr_type();
    if (value->getType() == i8ptrTy)
        return value;
    if (value->getType()->isPointerTy())
        return builder.CreatePointerCast(value, i8ptrTy, label);
    if (value->getType()->isIntegerTy())
        return builder.CreateIntToPtr(coerce_to_i64(value, label + ".int"), cast<PointerType>(i8ptrTy), label);

    return value;
}

}
