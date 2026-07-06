#pragma once
#include "../codegen.h"
#include "../common.h"
#include <llvm/IR/Constants.h>
#include <llvm/IR/DerivedTypes.h>
#include <llvm/IR/Intrinsics.h>

namespace codegen
{

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
        error("index address: failed to lower collection expression");
        return nullptr;
    }

    Value *idxVal = this->codegen_expr(ie->index.get());
    if (!idxVal)
    {
        error("index address: failed to lower index expression");
        return nullptr;
    }

    if (auto *id = dynamic_cast<const ast::Ident *>(ie->collection.get()))
    {
        std::string *ll = lookup_local_type(id->name);
        if (ll)
        {
            TypeShape pt = parse_type_shape(*ll);
            if (pt.is_plain_string())
            {
                return string_element_addr(colVal, idxVal, "string.index.addr");
            }

            if (pt.is_string_params())
            {
                Value *v = lookup_local(id->name);
                return string_element_addr(v, idxVal, "string.params.index.addr");
            }
        }
    }

    {
        std::string collectionType = infer_expr_type_name(ie->collection.get());
        TypeShape pt = parse_type_shape(collectionType);
        if (pt.is_scalar_string_like())
        {
            if (!colVal->getType()->isPointerTy())
            {
                error("string index address requires pointer string value");
                return nullptr;
            }

            return string_element_addr(colVal, idxVal, "string.expr.index.addr");
        }
    }

    Value *elemSizeVal = nullptr;
    Value *elemPtrI8 = checked_array_element_data_ptr_from_values(colVal, idxVal, &elemSizeVal, "index.addr");
    if (!elemPtrI8)
        return nullptr;

    auto staticElementShape = infer_array_literal_element_shape(ie->collection.get());
    bool staticElemIsArrayStruct = staticElementShape.first;
    bool staticElemIsArrayPtr = staticElementShape.second;

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

            if (pt.is_array_of("string"))
            {
                PointerType *i8PtrPtrTy = detail::getPtrTy(context);
                Value *typedPtr = builder.CreateBitCast(elemPtrI8, i8PtrPtrTy, "elem_ptr_to_i8ptrptr_dyn_str");
                return typedPtr;
            }
        }
    }

    return elemPtrI8;
}

}
