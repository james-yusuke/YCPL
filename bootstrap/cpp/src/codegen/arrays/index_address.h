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
            TypeShape pt = parse_type_shape(*ll);
            if (pt.base == "string" && pt.array_rank == 0 && pt.pointer_depth == 0)
            {
                Type *i8Ty = Type::getInt8Ty(context);

                Value *charPtr = builder.CreateInBoundsGEP(i8Ty, colVal, {idxVal}, "char_ptr");
                return charPtr;
            }

            if (pt.base == "string_params" && pt.array_rank == 0 && pt.pointer_depth == 0)
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
        TypeShape pt = parse_type_shape(collectionType);
        if ((pt.base == "string" || pt.base == "string_params") && pt.array_rank == 0 && pt.pointer_depth == 0)
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

    Value *elemSizeVal = nullptr;
    Value *elemPtrI8 = checked_array_element_data_ptr_from_values(colVal, idxVal, &elemSizeVal, "index.addr");
    if (!elemPtrI8)
        return nullptr;

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
            TypeShape pt = parse_type_shape(*ll);

            if (pt.base == "struct")
            {
                PointerType *i8PtrPtrTy = detail::getPtrTy(context);
                Value *typedPtr = builder.CreateBitCast(elemPtrI8, i8PtrPtrTy, "elem_ptr_to_i8ptrptr_dyn");
                return typedPtr;
            }

            if (pt.base == "string" && pt.array_rank != 0)
            {
                PointerType *i8PtrPtrTy = detail::getPtrTy(context);
                Value *typedPtr = builder.CreateBitCast(elemPtrI8, i8PtrPtrTy, "elem_ptr_to_i8ptrptr_dyn_str");
                return typedPtr;
            }
        }
    }

    return elemPtrI8;
}
