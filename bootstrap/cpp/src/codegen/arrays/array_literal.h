#pragma once
#include "../codegen.h"
#include "../common.h"
#include <llvm/IR/Constants.h>
#include <llvm/IR/DerivedTypes.h>
#include <llvm/IR/Intrinsics.h>

namespace codegen
{

Value *CodeGen::codegen_array(const ast::ArrayLiteral *alit)
{
    Module *M = module.get();
    const DataLayout &dl = M->getDataLayout();

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

    StructType *arrayHeaderTy = detail::getOrCreateRuntimeArrayHeaderType(context);
    PointerType *arrayHeaderPtrTy = detail::getPtrTy(context);
    Type *i8ptrTy = detail::getI8PtrTy(context);

    const DataLayout &dataLayout = dl;
    uint64_t elemSizeBytes = (uint64_t)dataLayout.getTypeAllocSize(elemTy);
    Value *elemSizeConst = detail::constInt64(builder, elemSizeBytes);

    uint64_t len = elemVals.size();
    Value *lenVal = detail::constInt64(builder, len);

    uint64_t allocElems = (len > 0) ? len : 1;
    Value *allocElemsVal = detail::constInt64(builder, allocElems);

    Value *totalBytes = builder.CreateMul(elemSizeConst, allocElemsVal, "total_bytes");

    FunctionCallee mallocFn = detail::getMalloc(M);

    uint64_t headerSizeBytes = (uint64_t)dataLayout.getTypeAllocSize(arrayHeaderTy);
    Value *headerSizeValue = detail::constInt64(builder, headerSizeBytes);
    Value *rawHeaderPtr = builder.CreateCall(mallocFn, {headerSizeValue}, "array_header_raw");
    Value *arrayHeaderPtr = builder.CreatePointerCast(rawHeaderPtr, arrayHeaderPtrTy, "array_header");

    Value *rawDataOpaque = builder.CreateCall(mallocFn, {totalBytes}, "array_data_raw_opaque");
    Value *rawDataPtr = builder.CreatePointerCast(rawDataOpaque, i8ptrTy, "array_data_raw_i8");

    Value *dataPtrPtr = array_header_field_ptr(arrayHeaderPtr, detail::RuntimeArrayField::Data, "data_ptr_ptr");
    Value *lenPtr = array_header_field_ptr(arrayHeaderPtr, detail::RuntimeArrayField::Length, "len_ptr");
    Value *capPtr = array_header_field_ptr(arrayHeaderPtr, detail::RuntimeArrayField::Capacity, "cap_ptr");
    Value *elemSizePtr = array_header_field_ptr(arrayHeaderPtr, detail::RuntimeArrayField::ElementSize, "elem_size_ptr");

    builder.CreateStore(rawDataPtr, dataPtrPtr);
    builder.CreateStore(lenVal, lenPtr);
    builder.CreateStore(allocElemsVal, capPtr);
    builder.CreateStore(elemSizeConst, elemSizePtr);

    if (len > 0)
    {
        PointerType *elemPtrTy = detail::getPtrTy(context);
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

        PointerType *elemPtrTy = detail::getPtrTy(context);
        Value *typedDataPtr = builder.CreatePointerCast(rawDataPtr, elemPtrTy, "typed_data_for_init");
        Value *index0 = detail::constInt64(builder, 0);
        Value *slot0 = builder.CreateInBoundsGEP(elemTy, typedDataPtr, index0, "slot0");
        Value *nullVal = Constant::getNullValue(elemTy);
        builder.CreateStore(nullVal, slot0);
    }

    return arrayHeaderPtr;
}

}
