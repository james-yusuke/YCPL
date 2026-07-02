
#include "../codegen.h"
#include "../common.h"
#include "parse.h"
#include <llvm/IR/Constants.h>
#include <llvm/IR/DerivedTypes.h>
#include <llvm/IR/Intrinsics.h>

using namespace llvm;
using namespace codegen;

Value *CodeGen::codegen_index(const ast::IndexExpr *ie)
{
    Module *M = module.get();

    const DataLayout &dl = M->getDataLayout();
    unsigned ptrSizeBits = dl.getPointerSizeInBits();
    uint64_t ptrSizeBytes = ptrSizeBits / 8;
    Type *ptrIntTy = IntegerType::get(context, ptrSizeBits);

    StructType *arrayStruct = detail::getOrCreateArrayStruct(context);
    PointerType *arrayPtrTy = detail::getPtrTy(context);

    Value *colVal = codegen_expr(ie->collection.get());
    if (!colVal)
    {
        errs() << "codegen_index: colVal == nullptr\n";
        return nullptr;
    }

    Value *idxVal = codegen_expr(ie->index.get());
    if (!idxVal)
    {
        errs() << "codegen_index: idxVal == nullptr\n";
        return nullptr;
    }

    if (auto id = dynamic_cast<const ast::Ident *>(ie->collection.get()))
    {

        std::string *localType = lookup_local_type(id->name);
        if (!localType)
        {
            error("index: unknown collection type for " + id->name);
            return nullptr;
        }

        ParsedType pt = parse_type_chain(localType->c_str());

        if (pt.base == "string" && pt.array_depth == 0 && pt.pointer_depth == 0)
        {
            Value *v = lookup_local(id->name);

            Value *strPtr = builder.CreateLoad(builder.getPtrTy(), v);

            Value *charPtr = builder.CreateInBoundsGEP(
                builder.getInt8Ty(),
                strPtr,
                {idxVal});

            Value *ch = builder.CreateLoad(builder.getInt8Ty(), charPtr);

            return builder.CreateZExt(ch, builder.getInt32Ty());
        }

        if (pt.base == "string_params" && pt.array_depth == 0 && pt.pointer_depth == 0)
        {
            Type *i8Ty = llvm::Type::getInt8Ty(context);

            Value *v = lookup_local(id->name);
            Value *charPtr = builder.CreateInBoundsGEP(
                i8Ty,
                v,
                {idxVal});
            Value *ch = builder.CreateLoad(i8Ty, charPtr);
            return builder.CreateZExt(ch, builder.getInt32Ty());
        }

        if (pt.pointer_depth > 0 && pt.array_depth == 0)
        {
            Type *elemTy = getLLVMType(pt.base);
            if (!elemTy)
            {
                error("index: cannot resolve pointer element type for " + id->name);
                return nullptr;
            }

            if (!idxVal->getType()->isIntegerTy(64))
            {
                if (idxVal->getType()->isIntegerTy())
                    idxVal = builder.CreateSExtOrTrunc(idxVal, detail::getI64Ty(context), "ptr_idx_i64");
                else
                {
                    error("pointer index is not integer");
                    return nullptr;
                }
            }

            Value *elemPtr = builder.CreateInBoundsGEP(elemTy, colVal, {idxVal}, "ptr_index");
            Value *loaded = builder.CreateLoad(elemTy, elemPtr, "ptr_index_load");
            if (elemTy->isIntegerTy(1))
                return builder.CreateZExt(loaded, builder.getInt32Ty(), "ptr_index_bool_ext");
            if (elemTy->isIntegerTy(8))
                return builder.CreateZExt(loaded, builder.getInt32Ty(), "ptr_index_i8_ext");
            return loaded;
        }
    }

    {
        std::string collectionType = infer_expr_type_name(ie->collection.get());
        ParsedType pt = parse_type_chain(collectionType);
        if ((pt.base == "string" || pt.base == "string_params") && pt.array_depth == 0 && pt.pointer_depth == 0)
        {
            if (!colVal->getType()->isPointerTy())
            {
                error("string index requires pointer string value");
                return nullptr;
            }

            Type *i8Ty = llvm::Type::getInt8Ty(context);
            Value *charPtr = builder.CreateInBoundsGEP(i8Ty, colVal, {idxVal}, "char_ptr_expr");
            Value *ch = builder.CreateLoad(i8Ty, charPtr);
            return builder.CreateZExt(ch, builder.getInt32Ty());
        }
    }

    Value *arrPtr = nullptr;
    if (colVal->getType()->isPointerTy())
    {
        arrPtr = builder.CreateBitCast(colVal, arrayPtrTy, "arr_cast");
    }

    else if (colVal->getType()->isStructTy())
    {

        Function *CurF = builder.GetInsertBlock()->getParent();
        IRBuilder<> TmpB(&CurF->getEntryBlock(), CurF->getEntryBlock().getFirstInsertionPt());

        Value *tmp = TmpB.CreateAlloca(arrayStruct, nullptr, "arr_tmp_as_arrayStruct");

        if (colVal->getType() == arrayStruct)
        {
            builder.CreateStore(colVal, tmp);
        }
        else
        {

            Value *tmpAsColTy = builder.CreateBitCast(tmp, detail::getPtrTy(context), "arr_tmp_cast_for_store");
            builder.CreateStore(colVal, tmpAsColTy);
        }

        arrPtr = tmp;
    }

    else if (colVal->getType()->isIntegerTy())
    {

        if (colVal->getType()->getIntegerBitWidth() != ptrSizeBits)
            colVal = builder.CreateSExtOrTrunc(colVal, ptrIntTy, "col_to_ptrint");
        arrPtr = builder.CreateIntToPtr(colVal, arrayPtrTy, "arr_from_intptr");
    }
    else
    {
        errs() << "codegen_index: unsupported collection value type\n";
        return nullptr;
    }

    Type *i64Ty = detail::getI64Ty(context);
    if (!idxVal->getType()->isIntegerTy(64))
    {
        if (idxVal->getType()->isIntegerTy())
            idxVal = builder.CreateSExtOrTrunc(idxVal, i64Ty, "idx_i64");
        else
        {
            errs() << "codegen_index: index is not integer\n";
            return nullptr;
        }
    }

    Value *lenFieldPtr = detail::createStructFieldGEP(builder, arrayStruct, arrPtr, /*fieldNo=*/1, "len_ptr");
    Value *lenVal = builder.CreateLoad(i64Ty, lenFieldPtr, "len");
    Value *inRange = builder.CreateICmpULT(idxVal, lenVal, "idx_in_range");

    Function *F = builder.GetInsertBlock()->getParent();
    BasicBlock *okBB = BasicBlock::Create(context, "idx_ok", F);
    BasicBlock *oobBB = BasicBlock::Create(context, "idx_oob", F);

    builder.CreateCondBr(inRange, okBB, oobBB);

    builder.SetInsertPoint(oobBB);
    {
        FunctionType *abortTy = FunctionType::get(Type::getVoidTy(context), {}, false);
        FunctionCallee abortFn = M->getOrInsertFunction("abort", abortTy);
        builder.CreateCall(abortFn, {});
        builder.CreateUnreachable();
    }

    builder.SetInsertPoint(okBB);

    Value *dataFieldPtr = detail::createStructFieldGEP(builder, arrayStruct, arrPtr, /*fieldNo=*/0, "data_field_ptr");
    Type *i8Ty = Type::getInt8Ty(context);
    PointerType *i8PtrTy = detail::getPtrTy(context);

    Value *dataPtr = builder.CreateLoad(i8PtrTy, dataFieldPtr, "data_ptr");
    Value *elemSizePtr = detail::createStructFieldGEP(builder, arrayStruct, arrPtr, /*fieldNo=*/3, "elem_size_ptr");
    Value *elemSizeVal = builder.CreateLoad(i64Ty, elemSizePtr, "elem_size");

    Value *offsetBytes = builder.CreateMul(idxVal, elemSizeVal, "offset_bytes");

    SmallVector<Value *, 1> idxs;
    idxs.push_back(offsetBytes);
    Value *elemPtrI8 = builder.CreateInBoundsGEP(i8Ty, dataPtr, idxs, "elem_ptr_i8");

    bool staticElemIsArrayStruct = false;
    bool staticElemIsArrayPtr = false;

    const ast::Expr *collExpr = ie->collection.get();
    if (const ast::ArrayLiteral *al = dynamic_cast<const ast::ArrayLiteral *>(collExpr))
    {
        if (!al->elements.empty())
        {
            const ast::Expr *firstElem = al->elements[0].get();
            if (dynamic_cast<const ast::ArrayLiteral *>(firstElem))
                staticElemIsArrayStruct = true;
            else if (dynamic_cast<const ast::IndexExpr *>(firstElem))
                staticElemIsArrayPtr = true;
        }
    }

    if (staticElemIsArrayStruct)
    {
        Value *nestedArrPtr = builder.CreateBitCast(elemPtrI8, arrayPtrTy, "nested_array_ptr");
        return nestedArrPtr;
    }

    if (staticElemIsArrayPtr)
    {
        PointerType *arrayPtrPtrTy = detail::getPtrTy(context);
        Value *typedPtr = builder.CreateBitCast(elemPtrI8, arrayPtrPtrTy, "elem_ptr_to_arrptr");
        Value *loadedArrPtr = builder.CreateLoad(arrayPtrTy, typedPtr, "load_arrptr");
        return loadedArrPtr;
    }

    if (ConstantInt *CI = dyn_cast<ConstantInt>(elemSizeVal))
    {
        uint64_t esz = CI->getZExtValue();

        for (auto &kv : struct_types)
        {
            StructType *st = kv.second;
            if (!st || st->isOpaque())
                continue;
            uint64_t stSize = dl.getTypeAllocSize(st);
            if (stSize == esz)
            {
                PointerType *structPtrTy = detail::getPtrTy(context);
                Value *structPtr = builder.CreateBitCast(elemPtrI8, structPtrTy, "elem_struct_ptr");
                return structPtr;
            }
        }

        if (esz == ptrSizeBytes)
        {

            PointerType *i8PtrPtrTy = detail::getPtrTy(context);
            Value *typedPtr = builder.CreateBitCast(elemPtrI8, i8PtrPtrTy, "elem_ptr_to_i8ptrptr");
            Value *loadedPtrAsI8Ptr = builder.CreateLoad(i8PtrTy, typedPtr, "load_ptr_as_i8ptr");
            return loadedPtrAsI8Ptr;
        }
    }
    else
    {
        if (auto id = dynamic_cast<const ast::Ident *>(ie->collection.get()))
        {
            std::string *ll = lookup_local_type(id->name);

            ParsedType pt = parse_type_chain(*ll);

            if (struct_types.find(pt.base) != struct_types.end())
            {
                StructType *st = struct_types[pt.base];
                if (!st || st->isOpaque())
                {

                    PointerType *i8PtrPtrTy = detail::getPtrTy(context);
                    Value *typedPtr = builder.CreateBitCast(elemPtrI8, i8PtrPtrTy, "elem_ptr_to_i8ptrptr_dyn_fallback");
                    Value *loadedPtrAsI8Ptr = builder.CreateLoad(i8PtrTy, typedPtr, "load_ptr_as_i8ptr_dyn_fallback");
                    return loadedPtrAsI8Ptr;
                }

                if (pt.array_depth > 0)
                {
                    PointerType *structPtrTy = detail::getPtrTy(context);
                    PointerType *structPtrPtrTy = detail::getPtrTy(context);

                    Value *typedPtr = builder.CreateBitCast(elemPtrI8, structPtrPtrTy, "elem_ptr_to_structptrptr_dyn");
                    Value *loadedStructPtr = builder.CreateLoad(structPtrTy, typedPtr, "load_structptr_dyn");

                    Value *isNull = builder.CreateICmpEQ(loadedStructPtr, ConstantPointerNull::get(structPtrTy), "is_null_loaded");

                    BasicBlock *curBB = builder.GetInsertBlock();
                    Function *F = curBB->getParent();
                    BasicBlock *notNullBB = BasicBlock::Create(context, "loaded_notnull", F);
                    BasicBlock *nullBB = BasicBlock::Create(context, "loaded_null", F);
                    BasicBlock *contBB = BasicBlock::Create(context, "loaded_cont", F);

                    builder.CreateCondBr(isNull, nullBB, notNullBB);

                    builder.SetInsertPoint(nullBB);
                    Value *nullRet = ConstantPointerNull::get(structPtrTy);
                    builder.CreateBr(contBB);

                    builder.SetInsertPoint(notNullBB);

                    FunctionCallee mallocFn = detail::getMalloc(M);

                    uint64_t stSize = dl.getTypeAllocSize(st);
                    Value *sizeConst = ConstantInt::get(detail::getI64Ty(context), stSize);

                    Value *raw = builder.CreateCall(mallocFn, {sizeConst}, "malloc_tok");

                    Value *dstStructPtr = builder.CreateBitCast(raw, structPtrTy, "malloc_cast_to_structptr");

                    Value *dst_i8 = builder.CreateBitCast(dstStructPtr, i8PtrTy, "dst_i8");
                    Value *src_i8 = builder.CreateBitCast(loadedStructPtr, i8PtrTy, "src_i8");
                    builder.CreateMemCpy(dst_i8, /*DstAlign=*/MaybeAlign(), src_i8, /*SrcAlign=*/MaybeAlign(), sizeConst);

                    builder.CreateBr(contBB);

                    builder.SetInsertPoint(contBB);
                    PHINode *phi = builder.CreatePHI(structPtrTy, 2, "loaded_structptr_copied");
                    phi->addIncoming(nullRet, nullBB);
                    phi->addIncoming(dstStructPtr, notNullBB);

                    return phi;
                }
                else
                {

                    PointerType *structPtrTy = detail::getPtrTy(context);
                    Value *structPtr = builder.CreateBitCast(elemPtrI8, structPtrTy, "elem_struct_ptr_dyn");
                    return structPtr;
                }
            }

            if (pt.base == "string" && pt.array_depth != 0)
            {
                PointerType *i8PtrPtrTy = detail::getPtrTy(context);
                Value *typedPtr = builder.CreateBitCast(elemPtrI8, i8PtrPtrTy, "elem_ptr_to_i8ptrptr_dyn");
                Value *loadedStrPtr = builder.CreateLoad(i8PtrTy, typedPtr, "load_strptr_dyn");
                return loadedStrPtr;
            }
        }
    }

    BasicBlock *case8BB = BasicBlock::Create(context, "case8", F);
    BasicBlock *doLoad4BB = BasicBlock::Create(context, "doLoad4", F);
    BasicBlock *case4BB = BasicBlock::Create(context, "case4", F);
    BasicBlock *doLoad2BB = BasicBlock::Create(context, "doLoad2", F);
    BasicBlock *case2BB = BasicBlock::Create(context, "case2", F);
    BasicBlock *doLoad1BB = BasicBlock::Create(context, "doLoad1", F);
    BasicBlock *case1BB = BasicBlock::Create(context, "case1", F);
    BasicBlock *defaultBB = BasicBlock::Create(context, "case_default", F);
    BasicBlock *afterBB = BasicBlock::Create(context, "idx_after", F);

    Value *is8 = builder.CreateICmpEQ(elemSizeVal, ConstantInt::get(i64Ty, 8), "is8");
    builder.CreateCondBr(is8, case8BB, doLoad4BB);

    builder.SetInsertPoint(case8BB);
    Value *caseVal8;
    {
        Type *i64Local = IntegerType::get(context, 64);
        PointerType *i64PtrTy = detail::getPtrTy(context);
        Value *typedPtr = builder.CreateBitCast(elemPtrI8, i64PtrTy, "elem_ptr_i64");
        caseVal8 = builder.CreateLoad(i64Local, typedPtr, "load_i64");
        if (!caseVal8->getType()->isIntegerTy(64))
            caseVal8 = builder.CreateSExtOrTrunc(caseVal8, i64Ty, "caseVal8_i64");
        builder.CreateBr(afterBB);
    }

    builder.SetInsertPoint(doLoad4BB);
    Value *is4 = builder.CreateICmpEQ(elemSizeVal, ConstantInt::get(i64Ty, 4), "is4");
    builder.CreateCondBr(is4, case4BB, doLoad2BB);

    builder.SetInsertPoint(case4BB);
    Value *caseVal4;
    {
        Type *i32Local = IntegerType::get(context, 32);
        PointerType *i32PtrTy = detail::getPtrTy(context);
        Value *typedPtr = builder.CreateBitCast(elemPtrI8, i32PtrTy, "elem_ptr_i32");
        Value *loaded32 = builder.CreateLoad(i32Local, typedPtr, "load_i32");
        caseVal4 = builder.CreateSExt(loaded32, i64Ty, "sext_i32_to_i64");
        builder.CreateBr(afterBB);
    }

    builder.SetInsertPoint(doLoad2BB);
    Value *is2 = builder.CreateICmpEQ(elemSizeVal, ConstantInt::get(i64Ty, 2), "is2");
    builder.CreateCondBr(is2, case2BB, doLoad1BB);

    builder.SetInsertPoint(case2BB);
    Value *caseVal2;
    {
        Type *i16Local = IntegerType::get(context, 16);
        PointerType *i16PtrTy = detail::getPtrTy(context);
        Value *typedPtr = builder.CreateBitCast(elemPtrI8, i16PtrTy, "elem_ptr_i16");
        Value *loaded16 = builder.CreateLoad(i16Local, typedPtr, "load_i16");
        caseVal2 = builder.CreateSExt(loaded16, i64Ty, "sext_i16_to_i64");
        builder.CreateBr(afterBB);
    }

    builder.SetInsertPoint(doLoad1BB);
    Value *is1 = builder.CreateICmpEQ(elemSizeVal, ConstantInt::get(i64Ty, 1), "is1");
    builder.CreateCondBr(is1, case1BB, defaultBB);

    builder.SetInsertPoint(case1BB);
    Value *caseVal1;
    {
        Type *i8Local = IntegerType::get(context, 8);
        PointerType *i8LocalPtrTy = detail::getPtrTy(context);
        Value *typedPtr = builder.CreateBitCast(elemPtrI8, i8LocalPtrTy, "elem_ptr_i8");
        Value *loaded8 = builder.CreateLoad(i8Local, typedPtr, "load_i8");
        caseVal1 = builder.CreateSExt(loaded8, i64Ty, "sext_i8_to_i64");
        builder.CreateBr(afterBB);
    }

    builder.SetInsertPoint(defaultBB);
    Value *caseValDef;
    {
        PointerType *i8PtrPtrTy = detail::getPtrTy(context);
        Value *typedPtr = builder.CreateBitCast(elemPtrI8, i8PtrPtrTy, "elem_ptr_to_i8ptrptr");
        Value *loadedPtrAsI8Ptr = builder.CreateLoad(i8PtrTy, typedPtr, "load_ptr_as_i8ptr");
        caseValDef = builder.CreatePtrToInt(loadedPtrAsI8Ptr, i64Ty, "ptrtoint_loaded_default");
        builder.CreateBr(afterBB);
    }

    builder.SetInsertPoint(afterBB);
    PHINode *phi = builder.CreatePHI(i64Ty, 5, "idx_result");
    phi->addIncoming(caseVal8, case8BB);
    phi->addIncoming(caseVal4, case4BB);
    phi->addIncoming(caseVal2, case2BB);
    phi->addIncoming(caseVal1, case1BB);
    phi->addIncoming(caseValDef, defaultBB);

    return phi;
}
