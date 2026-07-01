#pragma once
#include "../codegen.h"
#include "../common.h"
#include "../array/parse.h"
#include <llvm/IR/Constants.h>
#include <llvm/IR/DerivedTypes.h>
#include <llvm/IR/Intrinsics.h>
#include <llvm/ADT/SmallVector.h>
#include <llvm/ADT/Twine.h>

using namespace llvm;
using namespace codegen;

Value *CodeGen::codegen_len_call(const ast::CallExpr *ce)
{
    if (ce->args.size() != 1)
    {
        error("len expects 1 argument");
        return nullptr;
    }

    Value *arr = codegen_expr(ce->args[0].get());
    if (!arr)
        return nullptr;

    bool isStr = false;

    if (const auto id = dynamic_cast<const ast::Ident *>(ce->args[0].get()))
    {
        if (*lookup_local_type(id->name) == std::string("string"))
        {
            isStr = true;
        }
    }
    else if (const auto as = dynamic_cast<const ast::IndexExpr *>(ce->args[0].get()))
    {
        if (const auto id = dynamic_cast<const ast::Ident *>(as->collection.get()))
        {
            ParsedType pt = parse_type_chain(*lookup_local_type(id->name));
            if (pt.base == std::string("string"))
            {
                isStr = true;
            }
        }
    }

    Module *M = module.get();
    const DataLayout &dl = M->getDataLayout();

    StructType *arrayStruct = detail::getOrCreateArrayStruct(context);
    Type *arrayPtrTy = detail::getPtrTy(context);

    Type *arrTy = arr->getType();

    Value *zero32 = ConstantInt::get(IntegerType::get(context, 32), 0);
    Value *idxLen = ConstantInt::get(IntegerType::get(context, 32), 1);

    if (arrTy->isPointerTy() && isStr)
    {

        Type *i8PtrTy = detail::getPtrTy(context, arrTy->getPointerAddressSpace());
        Value *strPtr = builder.CreateBitCast(arr, i8PtrTy, "str_cast");

        unsigned ptrBits = dl.getPointerSizeInBits();
        Type *sizeTTy = IntegerType::get(context, ptrBits);

        FunctionType *strlenTy = FunctionType::get(sizeTTy, {i8PtrTy}, false);
        FunctionCallee strlenFunc = M->getOrInsertFunction("strlen", strlenTy);

        Value *lenSizeT = builder.CreateCall(strlenFunc, {strPtr}, "strlen_call");

        Type *i32Ty = IntegerType::get(context, 32);
        Value *lenI32 = nullptr;
        if (ptrBits > 32)
        {
            lenI32 = builder.CreateTrunc(lenSizeT, i32Ty, "strlen_trunc");
        }
        else if (ptrBits < 32)
        {
            lenI32 = builder.CreateZExt(lenSizeT, i32Ty, "strlen_zext");
        }
        else
        {
            lenI32 = lenSizeT;
        }

        return lenI32;
    }

    if (arrTy->isPointerTy())
    {

        arr = builder.CreateBitCast(arr, arrayPtrTy, "arr_cast");
    }
    else if (arrTy->isIntegerTy())
    {

        unsigned ptrBits = dl.getPointerSizeInBits();
        if (arrTy->getIntegerBitWidth() == ptrBits)
        {

            arr = builder.CreateIntToPtr(arr, arrayPtrTy, "arr_inttoptr");
        }
        else
        {

            error("len: integer argument has wrong width (not pointer-sized)");
            return nullptr;
        }
    }
    else if (arrTy->isStructTy())
    {

        Value *allocaInst = builder.CreateAlloca(arrayStruct, nullptr, "arr_tmp_byval");
        builder.CreateStore(arr, allocaInst);
        arr = allocaInst;
    }
    else
    {
        error("len: unsupported argument type");
        return nullptr;
    }

    Value *lenPtr = builder.CreateInBoundsGEP(arrayStruct, arr, {zero32, idxLen}, "len_ptr");

    Type *i64Ty = detail::getI64Ty(context);
    Type *i32Ty = IntegerType::get(context, 32);
    Value *len64 = builder.CreateLoad(i64Ty, lenPtr, "len");
    Value *lenVal = builder.CreateTrunc(len64, i32Ty, "len_i32");

    return lenVal;
}
