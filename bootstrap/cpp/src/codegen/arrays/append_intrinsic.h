#pragma once
#include "../codegen.h"
#include "../common.h"
#include <llvm/IR/Constants.h>
#include <llvm/IR/DerivedTypes.h>
#include <llvm/IR/Intrinsics.h>

namespace codegen
{

Value *CodeGen::codegen_append_call(const ast::CallExpr *ce)
{
    if (ce->args.size() != 2)
    {
        error("append expects 2 arguments (array, elem)");
        return nullptr;
    }

    Module *M = module.get();
    StructType *arrayStruct = detail::getOrCreateRuntimeArrayHeaderType(context);
    PointerType *arrayPtrTy = detail::getPtrTy(context);
    Type *i64Ty = IntegerType::get(context, 64);
    Type *i8Ty = IntegerType::get(context, 8);
    Type *i8ptrTy = detail::getI8PtrTy(context);
    const DataLayout &dl = M->getDataLayout();
    unsigned ptrSizeBits = dl.getPointerSizeInBits();
    uint64_t ptrSizeBytes = ptrSizeBits / 8;

    Value *array_target_value = nullptr;
    const ast::IndexExpr *idxExpr = nullptr;

    auto e = ce->args[0].get();
    if (!e)
        return nullptr;

    if (auto id = dynamic_cast<const ast::Ident *>(e))
    {
        array_target_value = lookup_local(id->name);
        if (!array_target_value)
            return nullptr;

    }
    else if (auto ie = dynamic_cast<const ast::IndexExpr *>(e))
    {
        idxExpr = ie;
    }
    else if (auto ue = dynamic_cast<const ast::UnaryExpr *>(e))
    {

        if (auto id2 = dynamic_cast<const ast::Ident *>(ue->rhs.get()))
        {
            array_target_value = lookup_local(id2->name);
            if (!array_target_value)
                return nullptr;
        }
        else if (auto ie2 = dynamic_cast<const ast::IndexExpr *>(ue->rhs.get()))
        {
            idxExpr = ie2;
        }
        else
        {

            Value *v = codegen_unary(ue);
            if (!v)
                return nullptr;
            if (v->getType()->isPointerTy())
                array_target_value = v;
            else if (v->getType()->isIntegerTy())
            {
                Type *ptrIntTy = IntegerType::get(context, ptrSizeBits);
                if (v->getType() != ptrIntTy)
                    v = builder.CreateSExtOrTrunc(v, ptrIntTy, "col_to_ptrint_unary");
                array_target_value = builder.CreateIntToPtr(v, arrayPtrTy, "arr_from_intptr_unary");
            }
            else
            {
                error("append: unsupported unary expr as first argument");
                return nullptr;
            }
        }
    }
    else
    {
        error("append: first argument must be ident, index expr, or unary(* )");
        return nullptr;
    }

    Value *elem = codegen_expr(ce->args[1].get());
    if (!elem)
        return nullptr;

    bool elemPointerCopiesPointee = dynamic_cast<const ast::StructLiteral *>(ce->args[1].get()) != nullptr;

    if (array_target_value && array_target_value->getType()->isPointerTy())
    {
        Type *pointee = array_target_value->getType();
        if (pointee->isPointerTy())
        {

            Value *loaded = builder.CreateLoad(pointee, array_target_value, "arr_loaded_from_ptr");
            if (loaded->getType() != arrayPtrTy)
                loaded = builder.CreatePointerCast(loaded, arrayPtrTy, "arr_loaded_cast");
            array_target_value = loaded;
        }
    }

    Value *array_header_ptr = nullptr;

    if (idxExpr)
    {
        Value *colVal = this->codegen_expr(idxExpr->collection.get());
        if (!colVal)
            return nullptr;
        Value *idxVal = this->codegen_expr(idxExpr->index.get());
        if (!idxVal)
            return nullptr;

        if (!idxVal->getType()->isIntegerTy(64))
            idxVal = builder.CreateSExtOrTrunc(idxVal, i64Ty, "idx_i64");

        Value *parentArrPtr = nullptr;
        if (colVal->getType()->isPointerTy())
        {
            parentArrPtr = builder.CreatePointerCast(colVal, arrayPtrTy, "parent_arr_cast");
        }
        else if (colVal->getType()->isStructTy())
        {
            Value *tmp = builder.CreateAlloca(colVal->getType(), nullptr, "arr_tmp");
            builder.CreateStore(colVal, tmp);
            parentArrPtr = tmp;
            if (parentArrPtr->getType() != arrayPtrTy)
                parentArrPtr = builder.CreatePointerCast(parentArrPtr, arrayPtrTy, "arr_tmp_cast");
        }
        else if (colVal->getType()->isIntegerTy())
        {
            Type *ptrIntTy = IntegerType::get(context, ptrSizeBits);
            if (colVal->getType() != ptrIntTy)
                colVal = builder.CreateSExtOrTrunc(colVal, ptrIntTy, "col_to_ptrint");
            parentArrPtr = builder.CreateIntToPtr(colVal, arrayPtrTy, "arr_from_intptr");
        }
        else
        {
            errs() << "append: unsupported collection value type in index expr\n";
            return nullptr;
        }

        Value *parent_data_ptr_ptr = array_header_field_ptr(parentArrPtr, detail::RuntimeArrayField::Data, "parent_data_ptr_ptr");
        Value *parent_raw_ptr = builder.CreateLoad(i8ptrTy, parent_data_ptr_ptr, "parent_raw_ptr");
        if (parent_raw_ptr->getType() != i8ptrTy)
            parent_raw_ptr = builder.CreatePointerCast(parent_raw_ptr, i8ptrTy, "parent_raw_ptr_i8");

        Value *parent_elem_size_ptr = array_header_field_ptr(parentArrPtr, detail::RuntimeArrayField::ElementSize, "parent_elem_size_ptr");
        Value *parent_elem_size = builder.CreateLoad(i64Ty, parent_elem_size_ptr, "parent_elem_size");

        Value *offsetBytes = builder.CreateMul(idxVal, parent_elem_size, "offset_bytes");
        SmallVector<Value *, 1> idxs_offset;
        idxs_offset.push_back(offsetBytes);
        Value *elem_slot_i8 = builder.CreateInBoundsGEP(i8Ty, parent_raw_ptr, idxs_offset, "elem_slot_i8");

        Constant *cArrayStructSize = ConstantInt::get(i64Ty, dl.getTypeAllocSize(arrayStruct));
        Constant *cPtrSize = ConstantInt::get(i64Ty, ptrSizeBytes);

        Value *isStructSize = builder.CreateICmpEQ(parent_elem_size, cArrayStructSize, "is_array_struct_size");
        Value *isPtrSize = builder.CreateICmpEQ(parent_elem_size, cPtrSize, "is_ptr_size");

        Function *curFn = builder.GetInsertBlock()->getParent();
        BasicBlock *bbStruct = BasicBlock::Create(context, "idx_is_array_struct", curFn);
        BasicBlock *bbCheckPtr = BasicBlock::Create(context, "idx_check_ptr", curFn);
        BasicBlock *bbPtr = BasicBlock::Create(context, "idx_is_ptr", curFn);
        BasicBlock *bbFb = BasicBlock::Create(context, "idx_fallback", curFn);
        BasicBlock *bbCont = BasicBlock::Create(context, "idx_norm_cont", curFn);

        builder.CreateCondBr(isStructSize, bbStruct, bbCheckPtr);

        builder.SetInsertPoint(bbStruct);
        Value *asArrayStruct = builder.CreatePointerCast(elem_slot_i8, arrayPtrTy, "elem_as_array_struct");
        builder.CreateBr(bbCont);

        builder.SetInsertPoint(bbCheckPtr);
        builder.CreateCondBr(isPtrSize, bbPtr, bbFb);

        builder.SetInsertPoint(bbPtr);
        Value *asArrayPtrPtr = builder.CreatePointerCast(elem_slot_i8, detail::getPtrTy(context), "elem_as_arrayptr_ptr");
        Value *loadedArrPtr = builder.CreateLoad(arrayPtrTy, asArrayPtrPtr, "elem_loaded_arrayptr");
        builder.CreateBr(bbCont);

        builder.SetInsertPoint(bbFb);
        Value *asArrayStructFb = builder.CreatePointerCast(elem_slot_i8, arrayPtrTy, "elem_as_array_struct_fb");
        builder.CreateBr(bbCont);

        builder.SetInsertPoint(bbCont);
        PHINode *phiArr = builder.CreatePHI(arrayPtrTy, 3, "idx_arrptr_phi");
        phiArr->addIncoming(asArrayStruct, bbStruct);
        phiArr->addIncoming(loadedArrPtr, bbPtr);
        phiArr->addIncoming(asArrayStructFb, bbFb);

        array_header_ptr = phiArr;
    }
    else
    {
        array_header_ptr = array_header_ptr_from_storage_or_value(array_target_value, "append.array");
    }

    if (!array_header_ptr)
        return nullptr;

    Value *dataPtrPtr = array_header_field_ptr(array_header_ptr, detail::RuntimeArrayField::Data, "data_ptr_ptr");
    Value *lenPtr = array_header_field_ptr(array_header_ptr, detail::RuntimeArrayField::Length, "len_ptr");
    Value *capPtr = array_header_field_ptr(array_header_ptr, detail::RuntimeArrayField::Capacity, "cap_ptr");
    Value *elemSizePtr = array_header_field_ptr(array_header_ptr, detail::RuntimeArrayField::ElementSize, "elem_size_ptr");

    Value *lenVal = builder.CreateLoad(i64Ty, lenPtr, "len");
    Value *capVal = builder.CreateLoad(i64Ty, capPtr, "cap");
    Value *elemSizeValFinal = builder.CreateLoad(i64Ty, elemSizePtr, "elem_size");

    Value *rawDataPtr = builder.CreateLoad(i8ptrTy, dataPtrPtr, "raw_data_ptr");
    if (rawDataPtr->getType() != i8ptrTy)
        rawDataPtr = builder.CreatePointerCast(rawDataPtr, i8ptrTy, "raw_data_as_i8ptr");

    Value *cmpHasSpace = builder.CreateICmpULT(lenVal, capVal, "has_space");
    Function *curFn = builder.GetInsertBlock()->getParent();
    BasicBlock *bbHasSpace = BasicBlock::Create(context, "append_has_space", curFn);
    BasicBlock *bbGrow = BasicBlock::Create(context, "append_grow", curFn);
    BasicBlock *bbCont = BasicBlock::Create(context, "append_cont", curFn);
    builder.CreateCondBr(cmpHasSpace, bbHasSpace, bbGrow);

    auto make_elem_tmp_and_get_i8ptr = [&](Value *val) -> Value *
    {
        Value *tmpAlloca = builder.CreateAlloca(i8Ty, elemSizeValFinal, "elem_tmp");
        Value *tmpI8Ptr = builder.CreatePointerCast(tmpAlloca, i8ptrTy, "elem_tmp_i8ptr");

        builder.CreateMemSet(tmpI8Ptr, ConstantInt::get(i8Ty, 0), elemSizeValFinal, MaybeAlign(1));

        uint64_t srcSizeStatic = 0;
        Value *valSizeConst = nullptr;
        Value *srcI8Ptr = nullptr;

        if (val->getType()->isPointerTy())
        {
            if (elemPointerCopiesPointee)
            {
                srcSizeStatic = ptrSizeBytes;
                valSizeConst = elemSizeValFinal;
                srcI8Ptr = builder.CreatePointerCast(val, i8ptrTy, "elem_src_i8ptr_from_pointee");
            }
            else
            {
                srcSizeStatic = ptrSizeBytes;
                valSizeConst = ConstantInt::get(i64Ty, srcSizeStatic);
                Value *srcAlloca = builder.CreateAlloca(val->getType(), nullptr, "elem_src_ptr_tmp");
                builder.CreateStore(val, srcAlloca);
                srcI8Ptr = builder.CreatePointerCast(srcAlloca, i8ptrTy, "elem_src_i8ptr_from_ptr_value");
            }
        }
        else
        {

            srcSizeStatic = dl.getTypeAllocSize(val->getType());
            valSizeConst = ConstantInt::get(i64Ty, srcSizeStatic);
            Value *srcAlloca = builder.CreateAlloca(val->getType(), nullptr, "elem_src_tmp");
            builder.CreateStore(val, srcAlloca);
            srcI8Ptr = builder.CreatePointerCast(srcAlloca, i8ptrTy, "elem_src_i8ptr");
        }

        Value *cmpElemLess = builder.CreateICmpULT(elemSizeValFinal, valSizeConst, "cmp_elem_less_val");
        Value *copySize = builder.CreateSelect(cmpElemLess, elemSizeValFinal, valSizeConst, "copy_size");
        builder.CreateMemCpy(tmpI8Ptr, MaybeAlign(1), srcI8Ptr, MaybeAlign(1), copySize);

        return tmpI8Ptr;
    };

    auto copy_elem_into_slot = [&](Value *destI8Ptr)
    {
        Value *tmpI8 = make_elem_tmp_and_get_i8ptr(elem);
        builder.CreateMemCpy(destI8Ptr, MaybeAlign(1), tmpI8, MaybeAlign(1), elemSizeValFinal);
    };

    builder.SetInsertPoint(bbHasSpace);
    {
        Value *offsetBytes = builder.CreateMul(lenVal, elemSizeValFinal, "offset_bytes");
        SmallVector<Value *, 1> idxs_offset;
        idxs_offset.push_back(offsetBytes);
        Value *destI8Ptr = builder.CreateInBoundsGEP(i8Ty, rawDataPtr, idxs_offset, "slot_i8ptr");

        copy_elem_into_slot(destI8Ptr);

        Value *one64 = ConstantInt::get(i64Ty, 1);
        Value *newLen = builder.CreateAdd(lenVal, one64, "len_plus1");
        builder.CreateStore(newLen, lenPtr);
        builder.CreateBr(bbCont);
    }

    builder.SetInsertPoint(bbGrow);
    {
        Value *zero64 = ConstantInt::get(i64Ty, 0);
        Value *one64 = ConstantInt::get(i64Ty, 1);

        Value *capIsZero = builder.CreateICmpEQ(capVal, zero64, "cap_is_zero");
        Value *capDbl = builder.CreateMul(capVal, ConstantInt::get(i64Ty, 2), "cap_dbl");
        Value *newCap = builder.CreateSelect(capIsZero, one64, capDbl, "new_cap");

        Value *newBytes = builder.CreateMul(newCap, elemSizeValFinal, "new_bytes");
        FunctionCallee mallocFn = detail::getMalloc(M);
        Value *newRawOpaque = builder.CreateCall(mallocFn, {newBytes}, "new_data_raw_opaque");
        Value *newRawData = builder.CreatePointerCast(newRawOpaque, i8ptrTy, "new_data_raw_i8");

        Value *oldBytesToCopy = builder.CreateMul(lenVal, elemSizeValFinal, "bytes_to_copy");

        Value *rawDataIsNull = builder.CreateICmpEQ(rawDataPtr, ConstantPointerNull::get(cast<PointerType>(rawDataPtr->getType())), "raw_data_is_null");
        Value *lenNotZero = builder.CreateICmpNE(lenVal, zero64, "len_not_zero");
        Value *needCopy = builder.CreateAnd(lenNotZero, builder.CreateNot(rawDataIsNull), "need_copy");

        BasicBlock *bbDoCopy = BasicBlock::Create(context, "append_do_copy", curFn);
        BasicBlock *bbNoCopy = BasicBlock::Create(context, "append_no_copy", curFn);
        builder.CreateCondBr(needCopy, bbDoCopy, bbNoCopy);

        builder.SetInsertPoint(bbDoCopy);
        builder.CreateMemCpy(newRawData, MaybeAlign(1), rawDataPtr, MaybeAlign(1), oldBytesToCopy);
        builder.CreateBr(bbNoCopy);

        builder.SetInsertPoint(bbNoCopy);
        builder.CreateStore(newRawData, dataPtrPtr);
        builder.CreateStore(newCap, capPtr);

        Value *offsetBytes2 = builder.CreateMul(lenVal, elemSizeValFinal, "offset_bytes_new");
        SmallVector<Value *, 1> idxs_offset2;
        idxs_offset2.push_back(offsetBytes2);
        Value *destI8PtrNew = builder.CreateInBoundsGEP(i8Ty, newRawData, idxs_offset2, "slot_new_i8ptr");

        copy_elem_into_slot(destI8PtrNew);

        Value *newLenAfterGrow = builder.CreateAdd(lenVal, one64, "len_plus1_after_grow");
        builder.CreateStore(newLenAfterGrow, lenPtr);
        builder.CreateBr(bbCont);
    }

    builder.SetInsertPoint(bbCont);

    return array_header_ptr;
}

}
