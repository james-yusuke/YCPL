#pragma once

#include "../codegen.h"
#include "../common.h"

#include <llvm/IR/Constants.h>
#include <llvm/IR/DerivedTypes.h>
#include <llvm/IR/GlobalVariable.h>
#include <llvm/IR/Instructions.h>

using namespace llvm;
using namespace codegen;

Value *CodeGen::array_header_ptr_from_value(Value *value, const std::string &label)
{
    if (!value)
        return nullptr;

    Module *M = module.get();
    const DataLayout &dataLayout = M->getDataLayout();
    Type *arrayHeaderPtrTy = detail::getPtrTy(context);

    if (value->getType()->isPointerTy())
        return builder.CreatePointerCast(value, arrayHeaderPtrTy, label);

    if (value->getType()->isStructTy())
    {
        Value *tmp = builder.CreateAlloca(value->getType(), nullptr, label + ".tmp");
        builder.CreateStore(value, tmp);
        return builder.CreatePointerCast(tmp, arrayHeaderPtrTy, label);
    }

    if (value->getType()->isIntegerTy())
    {
        unsigned pointerBits = dataLayout.getPointerSizeInBits();
        Type *pointerIntTy = IntegerType::get(context, pointerBits);
        if (value->getType() != pointerIntTy)
            value = builder.CreateSExtOrTrunc(value, pointerIntTy, label + ".ptrint");
        return builder.CreateIntToPtr(value, cast<PointerType>(arrayHeaderPtrTy), label);
    }

    error("array: unsupported array value");
    return nullptr;
}

Value *CodeGen::array_header_ptr_from_storage_or_value(Value *value, const std::string &label)
{
    if (!value)
        return nullptr;

    Type *arrayHeaderPtrTy = detail::getPtrTy(context);

    if (isa<AllocaInst>(value))
    {
        AllocaInst *alloca = cast<AllocaInst>(value);
        Value *loaded = builder.CreateLoad(alloca->getAllocatedType(), value, label + ".loaded");
        if (loaded->getType() != arrayHeaderPtrTy)
            return builder.CreatePointerCast(loaded, arrayHeaderPtrTy, label + ".ptr");
        return loaded;
    }

    if (isa<GlobalVariable>(value))
    {
        GlobalVariable *global = cast<GlobalVariable>(value);
        Value *loaded = builder.CreateLoad(global->getValueType(), value, label + ".loaded");
        if (loaded->getType() != arrayHeaderPtrTy)
            return builder.CreatePointerCast(loaded, arrayHeaderPtrTy, label + ".ptr");
        return loaded;
    }

    if (value->getType() != arrayHeaderPtrTy)
        return builder.CreatePointerCast(value, arrayHeaderPtrTy, label + ".ptr");
    return value;
}

Value *CodeGen::array_header_ptr_from_expr(const ast::Expr *expr, const std::string &label)
{
    return array_header_ptr_from_value(codegen_expr(expr), label);
}

Value *CodeGen::array_header_field_ptr(Value *arrayHeaderPtr, detail::RuntimeArrayField field, const std::string &label)
{
    StructType *arrayHeaderTy = detail::getOrCreateRuntimeArrayHeaderType(context);
    return detail::createRuntimeArrayFieldGEP(builder, arrayHeaderTy, arrayHeaderPtr, field, label);
}

Value *CodeGen::checked_array_element_data_ptr(const ast::Expr *arrayExpr, const ast::Expr *indexExpr, Value **elementSizeOut)
{
    if (!arrayExpr || !indexExpr)
        return nullptr;

    Value *collectionValue = codegen_expr(arrayExpr);
    if (!collectionValue)
        return nullptr;

    Value *indexValue = codegen_expr(indexExpr);
    if (!indexValue)
        return nullptr;

    return checked_array_element_data_ptr_from_values(collectionValue, indexValue, elementSizeOut, "array");
}

Value *CodeGen::checked_array_element_data_ptr_from_values(Value *collectionValue, Value *indexValue, Value **elementSizeOut, const std::string &label)
{
    if (!collectionValue || !indexValue)
        return nullptr;

    Module *M = module.get();
    Type *i64Ty = get_i64_type();
    Type *i8Ty = Type::getInt8Ty(context);
    Type *i8ptrTy = get_i8ptr_type();

    Value *arrayHeaderPtr = array_header_ptr_from_value(collectionValue, label + ".ptr");
    if (!arrayHeaderPtr)
        return nullptr;

    indexValue = coerce_to_i64(indexValue, label + ".idx.i64");
    if (!indexValue)
        return nullptr;

    Value *lenPtr = array_header_field_ptr(arrayHeaderPtr, detail::RuntimeArrayField::Length, label + ".len.ptr");
    Value *lenValue = builder.CreateLoad(i64Ty, lenPtr, label + ".len");
    Value *inRange = builder.CreateICmpULT(indexValue, lenValue, label + ".idx.in_range");

    Function *function = builder.GetInsertBlock()->getParent();
    BasicBlock *okBlock = BasicBlock::Create(context, label + ".idx.ok", function);
    BasicBlock *oobBlock = BasicBlock::Create(context, label + ".idx.oob", function);
    builder.CreateCondBr(inRange, okBlock, oobBlock);

    builder.SetInsertPoint(oobBlock);
    FunctionType *abortTy = FunctionType::get(Type::getVoidTy(context), {}, false);
    FunctionCallee abortFn = M->getOrInsertFunction("abort", abortTy);
    builder.CreateCall(abortFn, {});
    builder.CreateUnreachable();

    builder.SetInsertPoint(okBlock);
    Value *dataPtrPtr = array_header_field_ptr(arrayHeaderPtr, detail::RuntimeArrayField::Data, label + ".data.ptr.ptr");
    Value *dataPtr = builder.CreateLoad(i8ptrTy, dataPtrPtr, label + ".data.ptr");
    Value *elementSizePtr = array_header_field_ptr(arrayHeaderPtr, detail::RuntimeArrayField::ElementSize, label + ".elem_size.ptr");
    Value *elementSize = builder.CreateLoad(i64Ty, elementSizePtr, label + ".elem_size");
    if (elementSizeOut)
        *elementSizeOut = elementSize;

    Value *offset = builder.CreateMul(indexValue, elementSize, label + ".elem.offset");
    return builder.CreateInBoundsGEP(i8Ty, dataPtr, {offset}, label + ".elem.i8");
}
