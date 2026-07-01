#pragma once
#include "../codegen.h"
#include "../common.h"
#include <llvm/IR/Constants.h>
#include <llvm/IR/DerivedTypes.h>
#include <llvm/IR/Intrinsics.h>

using namespace llvm;
using namespace codegen;

Value *CodeGen::codegen_index_addr(const ast::IndexExpr *ie)
{
    Module *M = module.get();

    const DataLayout &dl = M->getDataLayout();
    unsigned ptrSizeBits = dl.getPointerSizeInBits();
    uint64_t ptrSizeBytes = ptrSizeBits / 8;
    Type *ptrIntTy = IntegerType::get(context, ptrSizeBits);

    StructType *arrayStruct = detail::getOrCreateArrayStruct(context);
    PointerType *arrayPtrTy = detail::getPtrTy(context);

    Value *colVal = this->codegen_expr(ie->collection.get());
    if (!colVal)
    {
        errs() << "codegen_index_addr: colVal == nullptr\n";
        return nullptr;
    }

    Value *idxVal = this->codegen_expr(ie->index.get());
    if (!idxVal)
    {
        errs() << "codegen_index_addr: idxVal == nullptr\n";
        return nullptr;
    }

    if (auto *id = dynamic_cast<const ast::Ident *>(ie->collection.get()))
    {
        std::string *ll = lookup_local_type(id->name);
        if (ll)
        {
            ParsedType pt = parse_type_chain(*ll);
            if (pt.base == "string" && pt.array_depth == 0)
            {
                Type *i8Ty = Type::getInt8Ty(context);

                Value *charPtr = builder.CreateInBoundsGEP(i8Ty, colVal, {idxVal}, "char_ptr");
                return charPtr;
            }

            if (pt.base == "string_params" && pt.array_depth == 0)
            {
                Type *i8Ty = Type::getInt8Ty(context);
                Value *v = lookup_local(id->name);

                Type *i64Ty = detail::getI64Ty(context);
                if (!idxVal->getType()->isIntegerTy(64))
                {
                    if (idxVal->getType()->isIntegerTy())
                        idxVal = builder.CreateSExtOrTrunc(idxVal, i64Ty, "idx_i64");
                    else
                    {
                        errs() << "codegen_index_addr: index is not integer for string_params\n";
                        return nullptr;
                    }
                }

                Value *charPtr = builder.CreateInBoundsGEP(i8Ty, v, {idxVal}, "charptr_params");
                return charPtr;
            }
        }
    }

    {
        std::string collectionType = infer_expr_type_name(ie->collection.get());
        ParsedType pt = parse_type_chain(collectionType);
        if ((pt.base == "string" || pt.base == "string_params") && pt.array_depth == 0)
        {
            if (!colVal->getType()->isPointerTy())
            {
                error("string index address requires pointer string value");
                return nullptr;
            }

            Type *i8Ty = Type::getInt8Ty(context);
            if (!idxVal->getType()->isIntegerTy(64))
            {
                if (idxVal->getType()->isIntegerTy())
                    idxVal = builder.CreateSExtOrTrunc(idxVal, detail::getI64Ty(context), "idx_i64_string_expr");
                else
                {
                    error("string index is not integer");
                    return nullptr;
                }
            }
            return builder.CreateInBoundsGEP(i8Ty, colVal, {idxVal}, "char_ptr_expr_addr");
        }
    }

    Value *arrPtr = nullptr;
    if (colVal->getType()->isPointerTy())
    {
        arrPtr = builder.CreateBitCast(colVal, arrayPtrTy, "arr_cast");
    }
    else if (colVal->getType()->isStructTy())
    {
        Value *tmp = builder.CreateAlloca(colVal->getType(), nullptr, "arr_tmp");
        builder.CreateStore(colVal, tmp);
        arrPtr = tmp;
        if (arrPtr->getType() != arrayPtrTy)
            arrPtr = builder.CreateBitCast(arrPtr, arrayPtrTy, "arr_tmp_cast");
    }
    else if (colVal->getType()->isIntegerTy())
    {
        if (colVal->getType()->getIntegerBitWidth() != ptrSizeBits)
            colVal = builder.CreateSExtOrTrunc(colVal, ptrIntTy, "col_to_ptrint");
        arrPtr = builder.CreateIntToPtr(colVal, arrayPtrTy, "arr_from_intptr");
    }
    else
    {
        errs() << "codegen_index_addr: unsupported collection value type\n";
        return nullptr;
    }

    Type *i64Ty = detail::getI64Ty(context);
    if (!idxVal->getType()->isIntegerTy(64))
    {
        if (idxVal->getType()->isIntegerTy())
            idxVal = builder.CreateSExtOrTrunc(idxVal, i64Ty, "idx_i64");
        else
        {
            errs() << "codegen_index_addr: index is not integer\n";
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

    Type *i8Ty = Type::getInt8Ty(context);
    PointerType *i8PtrTy = detail::getPtrTy(context);

    Value *dataFieldPtr = detail::createStructFieldGEP(builder, arrayStruct, arrPtr, /*fieldNo=*/0, "data_field_ptr");
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
        Value *nestedArrPtr = builder.CreateBitCast(elemPtrI8, arrayPtrTy, "nested_array_ptr_addr");
        return nestedArrPtr;
    }

    if (staticElemIsArrayPtr)
    {
        PointerType *arrayPtrPtrTy = detail::getPtrTy(context);
        Value *typedPtr = builder.CreateBitCast(elemPtrI8, arrayPtrPtrTy, "elem_ptr_to_arrptr_addr");
        return typedPtr;
    }

    if (auto *CI = dyn_cast<ConstantInt>(elemSizeVal))
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
                Value *structPtr = builder.CreateBitCast(elemPtrI8, structPtrTy, "elem_struct_ptr_addr");
                return structPtr;
            }
        }

        if (esz == ptrSizeBytes)
        {
            PointerType *i8PtrPtrTy = detail::getPtrTy(context);
            Value *typedPtr = builder.CreateBitCast(elemPtrI8, i8PtrPtrTy, "elem_ptr_to_i8ptrptr_addr");
            return typedPtr;
        }

        if (esz == 8)
        {
            PointerType *i64PtrTy = detail::getPtrTy(context);
            return builder.CreateBitCast(elemPtrI8, i64PtrTy, "elem_ptr_i64_addr");
        }
        else if (esz == 4)
        {
            PointerType *i32PtrTy = detail::getPtrTy(context);
            return builder.CreateBitCast(elemPtrI8, i32PtrTy, "elem_ptr_i32_addr");
        }
        else if (esz == 2)
        {
            PointerType *i16PtrTy = detail::getPtrTy(context);
            return builder.CreateBitCast(elemPtrI8, i16PtrTy, "elem_ptr_i16_addr");
        }
        else if (esz == 1)
        {
            PointerType *i8PtrSingleTy = detail::getPtrTy(context);
            return builder.CreateBitCast(elemPtrI8, i8PtrSingleTy, "elem_ptr_i8_addr");
        }

        return elemPtrI8;
    }

    if (auto id = dynamic_cast<const ast::Ident *>(ie->collection.get()))
    {
        std::string *ll = lookup_local_type(id->name);
        if (ll)
        {
            ParsedType pt = parse_type_chain(*ll);

            if (pt.base == "struct")
            {
                PointerType *i8PtrPtrTy = detail::getPtrTy(context);
                Value *typedPtr = builder.CreateBitCast(elemPtrI8, i8PtrPtrTy, "elem_ptr_to_i8ptrptr_dyn");
                return typedPtr;
            }

            if (pt.base == "string" && pt.array_depth != 0)
            {
                PointerType *i8PtrPtrTy = detail::getPtrTy(context);
                Value *typedPtr = builder.CreateBitCast(elemPtrI8, i8PtrPtrTy, "elem_ptr_to_i8ptrptr_dyn_str");
                return typedPtr;
            }
        }
    }

    return elemPtrI8;
}
