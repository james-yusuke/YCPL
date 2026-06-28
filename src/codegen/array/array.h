#pragma once
#include "../codegen.h"
#include "../common.h"
#include <llvm/IR/Constants.h>
#include <llvm/IR/DerivedTypes.h>
#include <llvm/IR/Intrinsics.h>

using namespace llvm;
using namespace codegen;

Value *CodeGen::codegen_array(const ast::ArrayLiteral *alit)
{
    Module *M = module.get();
    DataLayout dl(M);

    std::vector<Value *> elemVals;
    elemVals.reserve(alit->elements.size());
    for (const auto &e : alit->elements)
    {
        Value *v = this->codegen_expr(e.get());
        if (!v)
            return nullptr;
        elemVals.push_back(v);
    }

    Type *elemTy = nullptr;
    if (elemVals.empty())
    {
        elemTy = IntegerType::get(context, 64);
    }
    else
    {
        elemTy = elemVals[0]->getType();
    }

    StructType *arrayStruct = detail::getOrCreateArrayStruct(context);
    PointerType *arrayPtrTy = PointerType::getUnqual(arrayStruct);
    Type *i64Ty = IntegerType::get(context, 64);
    Type *i32Ty = IntegerType::get(context, 32);
    Type *i8ptrTy = detail::getI8PtrTy(context);

    DataLayout &dataLayout = dl;
    uint64_t elemSizeBytes = (uint64_t)dataLayout.getTypeAllocSize(elemTy);
    Value *elemSizeConst = detail::constInt64(builder, elemSizeBytes);

    uint64_t len = elemVals.size();
    Value *lenVal = detail::constInt64(builder, len);

    uint64_t allocElems = (len > 0) ? len : 1;
    Value *allocElemsVal = detail::constInt64(builder, allocElems);

    Value *totalBytes = builder.CreateMul(elemSizeConst, allocElemsVal, "total_bytes");

    FunctionCallee mallocFn = detail::getMalloc(M);

    uint64_t structSize = (uint64_t)dataLayout.getTypeAllocSize(arrayStruct);
    Value *structSizeVal = detail::constInt64(builder, structSize);
    Value *rawStructPtr = builder.CreateCall(mallocFn, {structSizeVal}, "array_struct_raw");
    Value *arrPtr = builder.CreatePointerCast(rawStructPtr, arrayPtrTy, "array_struct");

    Value *rawDataOpaque = builder.CreateCall(mallocFn, {totalBytes}, "array_data_raw_opaque");
    Value *rawDataPtr = builder.CreatePointerCast(rawDataOpaque, i8ptrTy, "array_data_raw_i8");

    Value *zero32 = ConstantInt::get(i32Ty, 0);
    Value *idxData = ConstantInt::get(i32Ty, 0);
    Value *idxLen = ConstantInt::get(i32Ty, 1);
    Value *idxCap = ConstantInt::get(i32Ty, 2);
    Value *idxElem = ConstantInt::get(i32Ty, 3);

    Value *dataPtrPtr = builder.CreateInBoundsGEP(arrayStruct, arrPtr, {zero32, idxData}, "data_ptr_ptr");
    Value *lenPtr = builder.CreateInBoundsGEP(arrayStruct, arrPtr, {zero32, idxLen}, "len_ptr");
    Value *capPtr = builder.CreateInBoundsGEP(arrayStruct, arrPtr, {zero32, idxCap}, "cap_ptr");
    Value *elemSizePtr = builder.CreateInBoundsGEP(arrayStruct, arrPtr, {zero32, idxElem}, "elem_size_ptr");

    builder.CreateStore(rawDataPtr, dataPtrPtr);
    builder.CreateStore(lenVal, lenPtr);
    builder.CreateStore(allocElemsVal, capPtr);
    builder.CreateStore(elemSizeConst, elemSizePtr);

    if (len > 0)
    {
        PointerType *elemPtrTy = PointerType::getUnqual(elemTy);
        Value *typedDataPtr = builder.CreatePointerCast(rawDataPtr, elemPtrTy, "typed_data");
        for (uint64_t i = 0; i < len; ++i)
        {
            Value *elemVal = elemVals[i];
            Value *index = detail::constInt64(builder, i);
            Value *slot = builder.CreateInBoundsGEP(elemTy, typedDataPtr, index, "slot_ptr");

            if (elemVal->getType() != elemTy)
            {
                if (elemVal->getType()->isPointerTy() && elemTy->isPointerTy())
                    elemVal = builder.CreateBitCast(elemVal, elemTy);
                else if (elemVal->getType()->isIntegerTy() && elemTy->isIntegerTy())
                {
                    unsigned sb = elemVal->getType()->getIntegerBitWidth();
                    unsigned db = elemTy->getIntegerBitWidth();
                    if (sb < db)
                        elemVal = builder.CreateSExt(elemVal, elemTy);
                    else if (sb > db)
                        elemVal = builder.CreateTrunc(elemVal, elemTy);
                }
                else if (elemVal->getType()->isFloatingPointTy() && elemTy->isIntegerTy())
                    elemVal = builder.CreateFPToSI(elemVal, elemTy);
                else if (elemVal->getType()->isIntegerTy() && elemTy->isFloatingPointTy())
                    elemVal = builder.CreateSIToFP(elemVal, elemTy);
                else
                    elemVal = builder.CreateBitCast(elemVal, elemTy);
            }
            builder.CreateStore(elemVal, slot);
        }
    }
    else
    {

        PointerType *elemPtrTy = PointerType::getUnqual(elemTy);
        Value *typedDataPtr = builder.CreatePointerCast(rawDataPtr, elemPtrTy, "typed_data_for_init");
        Value *index0 = detail::constInt64(builder, 0);
        Value *slot0 = builder.CreateInBoundsGEP(elemTy, typedDataPtr, index0, "slot0");
        Value *nullVal = Constant::getNullValue(elemTy);
        builder.CreateStore(nullVal, slot0);
    }

    return arrPtr;
}
