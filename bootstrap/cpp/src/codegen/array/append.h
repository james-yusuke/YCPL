#pragma once
#include "../codegen.h"
#include "../common.h"
#include <llvm/IR/Constants.h>
#include <llvm/IR/DerivedTypes.h>
#include <llvm/IR/Intrinsics.h>

using namespace llvm;
using namespace codegen;

Value *CodeGen::codegen_append_call(const ast::CallExpr *ce)
{
    if (ce->args.size() != 2)
    {
        error("append expects 2 arguments (array, elem)");
        return nullptr;
    }

    Module *M = module.get();
    StructType *arrayStruct = detail::getOrCreateArrayStruct(context);
    PointerType *arrayPtrTy = detail::getPtrTy(context);
    Type *i64Ty = IntegerType::get(context, 64);
    Type *i32Ty = IntegerType::get(context, 32);
    Type *i8Ty = IntegerType::get(context, 8);
    Type *i8ptrTy = detail::getI8PtrTy(context);
    const DataLayout &dl = M->getDataLayout();
    unsigned ptrSizeBits = dl.getPointerSizeInBits();
    uint64_t ptrSizeBytes = ptrSizeBits / 8;

    Value *arr_lvalue_or_ptr = nullptr;
    const ast::IndexExpr *idxExpr = nullptr;

    auto e = ce->args[0].get();
    if (!e)
        return nullptr;

    if (auto id = dynamic_cast<const ast::Ident *>(e))
    {
        arr_lvalue_or_ptr = lookup_local(id->name);
        if (!arr_lvalue_or_ptr)
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
            arr_lvalue_or_ptr = lookup_local(id2->name);
            if (!arr_lvalue_or_ptr)
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
                arr_lvalue_or_ptr = v;
            else if (v->getType()->isIntegerTy())
            {
                Type *ptrIntTy = IntegerType::get(context, ptrSizeBits);
                if (v->getType() != ptrIntTy)
                    v = builder.CreateSExtOrTrunc(v, ptrIntTy, "col_to_ptrint_unary");
                arr_lvalue_or_ptr = builder.CreateIntToPtr(v, arrayPtrTy, "arr_from_intptr_unary");
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

    if (arr_lvalue_or_ptr && arr_lvalue_or_ptr->getType()->isPointerTy())
    {
        Type *pointee = arr_lvalue_or_ptr->getType();
        if (pointee->isPointerTy())
        {

            Value *loaded = builder.CreateLoad(pointee, arr_lvalue_or_ptr, "arr_loaded_from_ptr");
            if (loaded->getType() != arrayPtrTy)
                loaded = builder.CreatePointerCast(loaded, arrayPtrTy, "arr_loaded_cast");
            arr_lvalue_or_ptr = loaded;
        }
    }

    Value *arrValue = nullptr;

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

        SmallVector<Value *, 2> idxs_data;
        idxs_data.push_back(ConstantInt::get(i32Ty, 0));
        idxs_data.push_back(ConstantInt::get(i32Ty, 0));
        Value *parent_data_ptr_ptr = builder.CreateInBoundsGEP(arrayStruct, parentArrPtr, idxs_data, "parent_data_ptr_ptr");
        Value *parent_raw_ptr = builder.CreateLoad(i8ptrTy, parent_data_ptr_ptr, "parent_raw_ptr");
        if (parent_raw_ptr->getType() != i8ptrTy)
            parent_raw_ptr = builder.CreatePointerCast(parent_raw_ptr, i8ptrTy, "parent_raw_ptr_i8");

        SmallVector<Value *, 2> idxs_elem;
        idxs_elem.push_back(ConstantInt::get(i32Ty, 0));
        idxs_elem.push_back(ConstantInt::get(i32Ty, 3));
        Value *parent_elem_size_ptr = builder.CreateInBoundsGEP(arrayStruct, parentArrPtr, idxs_elem, "parent_elem_size_ptr");
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

        arrValue = phiArr;
    }
    else
    {

        if (llvm::isa<AllocaInst>(arr_lvalue_or_ptr))
        {
            AllocaInst *ai = cast<AllocaInst>(arr_lvalue_or_ptr);
            Type *allocated = ai->getAllocatedType();
            Value *loaded = builder.CreateLoad(allocated, arr_lvalue_or_ptr, "arr.loaded.raw");
            if (loaded->getType() != arrayPtrTy)
                arrValue = builder.CreatePointerCast(loaded, arrayPtrTy, "arr.as_arrayptr");
            else
                arrValue = loaded;
        }
        else if (llvm::isa<GlobalVariable>(arr_lvalue_or_ptr))
        {
            GlobalVariable *gv = cast<GlobalVariable>(arr_lvalue_or_ptr);
            Type *gty = gv->getValueType();
            Value *loaded = builder.CreateLoad(gty, arr_lvalue_or_ptr, "arr.loaded.raw");
            if (loaded->getType() != arrayPtrTy)
                arrValue = builder.CreatePointerCast(loaded, arrayPtrTy, "arr.as_arrayptr");
            else
                arrValue = loaded;
        }
        else
        {
            if (arr_lvalue_or_ptr->getType() != arrayPtrTy)
                arrValue = builder.CreatePointerCast(arr_lvalue_or_ptr, arrayPtrTy, "arr.struct.ptr");
            else
                arrValue = arr_lvalue_or_ptr;
        }
    }

    if (!arrValue)
        return nullptr;

    SmallVector<Value *, 2> idxs_data2;
    idxs_data2.push_back(ConstantInt::get(i32Ty, 0));
    idxs_data2.push_back(ConstantInt::get(i32Ty, 0));
    Value *dataPtrPtr = builder.CreateInBoundsGEP(arrayStruct, arrValue, idxs_data2, "data_ptr_ptr");

    SmallVector<Value *, 2> idxs_len;
    idxs_len.push_back(ConstantInt::get(i32Ty, 0));
    idxs_len.push_back(ConstantInt::get(i32Ty, 1));
    Value *lenPtr = builder.CreateInBoundsGEP(arrayStruct, arrValue, idxs_len, "len_ptr");

    SmallVector<Value *, 2> idxs_cap;
    idxs_cap.push_back(ConstantInt::get(i32Ty, 0));
    idxs_cap.push_back(ConstantInt::get(i32Ty, 2));
    Value *capPtr = builder.CreateInBoundsGEP(arrayStruct, arrValue, idxs_cap, "cap_ptr");

    SmallVector<Value *, 2> idxs_es;
    idxs_es.push_back(ConstantInt::get(i32Ty, 0));
    idxs_es.push_back(ConstantInt::get(i32Ty, 3));
    Value *elemSizePtr = builder.CreateInBoundsGEP(arrayStruct, arrValue, idxs_es, "elem_size_ptr");

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

    builder.SetInsertPoint(bbHasSpace);
    {
        Value *offsetBytes = builder.CreateMul(lenVal, elemSizeValFinal, "offset_bytes");
        SmallVector<Value *, 1> idxs_offset;
        idxs_offset.push_back(offsetBytes);
        Value *destI8Ptr = builder.CreateInBoundsGEP(i8Ty, rawDataPtr, idxs_offset, "slot_i8ptr");

        Constant *cPtrSize = ConstantInt::get(i64Ty, ptrSizeBytes);
        Value *isPtrArray = builder.CreateICmpEQ(elemSizeValFinal, cPtrSize, "is_ptr_array");

        BasicBlock *bbPtrMode = BasicBlock::Create(context, "append_ptr_mode", curFn);
        BasicBlock *bbCopyMode = BasicBlock::Create(context, "append_copy_mode", curFn);
        BasicBlock *bbAfterMode = BasicBlock::Create(context, "append_after_mode", curFn);

        bool elemIsPointerType = elem->getType()->isPointerTy();

        if (!elemIsPointerType)
        {
            builder.CreateBr(bbCopyMode);
        }
        else
        {
            builder.CreateCondBr(isPtrArray, bbPtrMode, bbCopyMode);
        }

        builder.SetInsertPoint(bbPtrMode);
        {
            Value *tmpI8 = make_elem_tmp_and_get_i8ptr(elem);
            builder.CreateMemCpy(destI8Ptr, MaybeAlign(1), tmpI8, MaybeAlign(1), elemSizeValFinal);
            builder.CreateBr(bbAfterMode);
        }

        builder.SetInsertPoint(bbCopyMode);
        {
            Value *tmpI8 = make_elem_tmp_and_get_i8ptr(elem);
            builder.CreateMemCpy(destI8Ptr, MaybeAlign(1), tmpI8, MaybeAlign(1), elemSizeValFinal);
            builder.CreateBr(bbAfterMode);
        }

        builder.SetInsertPoint(bbAfterMode);
        {
            Value *one64 = ConstantInt::get(i64Ty, 1);
            Value *newLen = builder.CreateAdd(lenVal, one64, "len_plus1");
            builder.CreateStore(newLen, lenPtr);
            builder.CreateBr(bbCont);
        }
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

        BasicBlock *bbPtrModeG = BasicBlock::Create(context, "append_ptr_mode_g", curFn);
        BasicBlock *bbCopyModeG = BasicBlock::Create(context, "append_copy_mode_g", curFn);
        BasicBlock *bbAfterModeG = BasicBlock::Create(context, "append_after_mode_g", curFn);
        Constant *cPtrSize2 = ConstantInt::get(i64Ty, ptrSizeBytes);
        Value *isPtrArrayGrow = builder.CreateICmpEQ(elemSizeValFinal, cPtrSize2, "is_ptr_array_grow");

        bool elemIsPointerType = elem->getType()->isPointerTy();

        if (!elemIsPointerType)
        {
            builder.CreateBr(bbCopyModeG);
        }
        else
        {
            builder.CreateCondBr(isPtrArrayGrow, bbPtrModeG, bbCopyModeG);
        }

        builder.SetInsertPoint(bbPtrModeG);
        {
            Value *tmpI8_2 = make_elem_tmp_and_get_i8ptr(elem);
            builder.CreateMemCpy(destI8PtrNew, MaybeAlign(1), tmpI8_2, MaybeAlign(1), elemSizeValFinal);
            builder.CreateBr(bbAfterModeG);
        }

        builder.SetInsertPoint(bbCopyModeG);
        {
            Value *tmpI8_2 = make_elem_tmp_and_get_i8ptr(elem);
            builder.CreateMemCpy(destI8PtrNew, MaybeAlign(1), tmpI8_2, MaybeAlign(1), elemSizeValFinal);
            builder.CreateBr(bbAfterModeG);
        }

        builder.SetInsertPoint(bbAfterModeG);
        {
            Value *newLenAfterGrow = builder.CreateAdd(lenVal, one64, "len_plus1_after_grow");
            builder.CreateStore(newLenAfterGrow, lenPtr);
            builder.CreateBr(bbCont);
        }
    }

    builder.SetInsertPoint(bbCont);

    return arrValue;
}
