
#pragma once

#include "../codegen.h"
#include "../common.h"
#include "../types/type_shape.h"
#include <llvm/IR/Constants.h>
#include <llvm/IR/DerivedTypes.h>
#include <llvm/IR/Intrinsics.h>

namespace codegen
{

Value *CodeGen::codegen_index(const ast::IndexExpr *ie)
{
    Module *M = module.get();

    const DataLayout &dl = M->getDataLayout();
    unsigned ptrSizeBits = dl.getPointerSizeInBits();
    uint64_t ptrSizeBytes = ptrSizeBits / 8;

    PointerType *arrayPtrTy = detail::getPtrTy(context);

    Value *colVal = codegen_expr(ie->collection.get());
    if (!colVal)
    {
        error("index: failed to lower collection expression");
        return nullptr;
    }

    Value *idxVal = codegen_expr(ie->index.get());
    if (!idxVal)
    {
        error("index: failed to lower index expression");
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

        TypeShape pt = parse_type_shape(*localType);

        if (pt.is_plain_string())
        {
            Value *v = lookup_local(id->name);
            Value *strPtr = builder.CreateLoad(builder.getPtrTy(), v, "string.local.ptr");
            return string_element_value(strPtr, idxVal, "string.index");
        }

        if (pt.is_string_params())
        {
            Value *v = lookup_local(id->name);
            return string_element_value(v, idxVal, "string.params.index");
        }

        if (pt.is_pointer_only())
        {
            Type *elemTy = resolve_llvm_type_name(pt.base);
            if (!elemTy)
            {
                error("index: cannot resolve pointer element type for " + id->name);
                return nullptr;
            }

            idxVal = coerce_index_to_i64(idxVal, "ptr_idx_i64");
            if (!idxVal)
                return nullptr;

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
        TypeShape pt = parse_type_shape(collectionType);
        if (pt.is_scalar_string_like())
        {
            return string_element_value(colVal, idxVal, "string.expr.index");
        }

        // Indexing is also valid for a raw typed pointer stored in a member or
        // returned from an expression.  The old ident-only path below missed
        // those cases and interpreted every pointer-valued member as a YCPL
        // dynamic-array header.
        if (pt.is_pointer_only())
        {
            Type *elemTy = resolve_llvm_type_name(pt.base);
            if (!elemTy)
            {
                error("index: cannot resolve pointer element type");
                return nullptr;
            }

            idxVal = coerce_index_to_i64(idxVal, "ptr_expr_idx_i64");
            if (!idxVal)
                return nullptr;

            Value *elemPtr = builder.CreateInBoundsGEP(elemTy, colVal, {idxVal}, "ptr_expr_index");
            Value *loaded = builder.CreateLoad(elemTy, elemPtr, "ptr_expr_index_load");
            if (elemTy->isIntegerTy(1))
                return builder.CreateZExt(loaded, builder.getInt32Ty(), "ptr_expr_index_bool_ext");
            if (elemTy->isIntegerTy(8))
                return builder.CreateZExt(loaded, builder.getInt32Ty(), "ptr_expr_index_i8_ext");
            return loaded;
        }
    }

    Value *elemSizeVal = nullptr;
    Value *elemPtrI8 = checked_array_element_data_ptr_from_values(colVal, idxVal, &elemSizeVal, "index");
    if (!elemPtrI8)
        return nullptr;

    TypeShape typedCollection = parse_type_shape(infer_expr_type_name(ie->collection.get()));
    if (typedCollection.is_vec_type())
    {
        Type *elementType = resolve_llvm_type_name(typedCollection.vec_element);
        if (!elementType)
        {
            error("index: cannot resolve Vec element type");
            return nullptr;
        }
        if (elementType->isStructTy())
            return builder.CreatePointerCast(elemPtrI8, detail::getPtrTy(context), "vec.index.struct");
        Value *loaded = builder.CreateLoad(elementType, builder.CreatePointerCast(elemPtrI8, detail::getPtrTy(context)), "vec.index.load");
        if (elementType->isIntegerTy(1))
            return builder.CreateZExt(loaded, builder.getInt32Ty(), "vec.index.bool");
        if (elementType->isIntegerTy(8))
            return builder.CreateZExt(loaded, builder.getInt32Ty(), "vec.index.byte");
        return loaded;
    }

    Type *i64Ty = detail::getI64Ty(context);
    PointerType *i8PtrTy = detail::getPtrTy(context);
    Function *F = builder.GetInsertBlock()->getParent();

    auto staticElementShape = infer_array_literal_element_shape(ie->collection.get());
    bool staticElemIsArrayStruct = staticElementShape.first;
    bool staticElemIsArrayPtr = staticElementShape.second;

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

            TypeShape pt = parse_type_shape(*ll);

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

                if (pt.is_array())
                {
                    Value *typedPtr = builder.CreateBitCast(elemPtrI8, detail::getPtrTy(context), "elem_struct_ptr_dyn");
                    return builder.CreateLoad(st, typedPtr, "load_struct_value_dyn");
                }
                else
                {

                    PointerType *structPtrTy = detail::getPtrTy(context);
                    Value *structPtr = builder.CreateBitCast(elemPtrI8, structPtrTy, "elem_struct_ptr_dyn");
                    return structPtr;
                }
            }

            if (pt.is_array_of("string"))
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

}
