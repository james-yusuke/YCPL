#pragma once
#include "../codegen.h"
#include "../common.h"
#include <llvm/IR/Constants.h>
#include <llvm/IR/DerivedTypes.h>
#include <llvm/IR/Intrinsics.h>
#include <llvm/ADT/SmallVector.h>
#include <llvm/ADT/Twine.h>

using namespace llvm;
using namespace codegen;

Value *CodeGen::codegen_new_call(const ast::CallExpr *ce)
{
    if (ce->args.size() != 1)
    {
        error("new expects one type argument, e.g. new([]T)");
        return nullptr;
    }

    const ast::Expr *typeArg = ce->args[0].get();

    const ast::ArrayLiteral *arrLit = dynamic_cast<const ast::ArrayLiteral *>(typeArg);
    const ast::ArrayType *arrType = dynamic_cast<const ast::ArrayType *>(typeArg);

    const ast::Type *elemAstType = nullptr;
    if (arrLit)
    {
        elemAstType = arrLit->array_type.get();
    }
    else if (arrType)
    {
        elemAstType = arrType->elem.get();
    }
    else
    {
        error("new currently supports array type like new([]T)");
        return nullptr;
    }

    llvm::Type *elemTy = resolve_type_from_ast(elemAstType);
    if (!elemTy)
    {
        error("cannot determine element LLVM type for new()");
        return nullptr;
    }

    LLVMContext &ctx = builder.getContext();

    PointerType *i8ptrTy = Type::getInt8Ty(context)->getPointerTo();
    Type *i64 = Type::getInt64Ty(ctx);

    StructType *sliceTy = StructType::get(ctx, {i8ptrTy, i64, i64, i64});
    PointerType *slicePtrTy = PointerType::getUnqual(sliceTy);

    const DataLayout &dl = module->getDataLayout();
    uint64_t sliceSizeBytes = dl.getTypeAllocSize(sliceTy);

    FunctionCallee mallocF = detail::getMalloc(module.get());
    Value *sizeVal = ConstantInt::get(i64, sliceSizeBytes);
    Value *rawMem = builder.CreateCall(mallocF, {sizeVal}, "rawmem");

    Value *slicePtr = builder.CreateBitCast(rawMem, slicePtrTy, "sliceptr");

    Value *dataGep = builder.CreateConstGEP2_32(sliceTy, slicePtr, 0, 0, "slice.data.gep");
    builder.CreateStore(ConstantPointerNull::get(i8ptrTy), dataGep);

    Value *lenGep = builder.CreateConstGEP2_32(sliceTy, slicePtr, 0, 1, "slice.len.gep");
    builder.CreateStore(ConstantInt::get(i64, 0), lenGep);

    Value *capGep = builder.CreateConstGEP2_32(sliceTy, slicePtr, 0, 2, "slice.cap.gep");
    builder.CreateStore(ConstantInt::get(i64, 0), capGep);

    uint64_t elemSizeBytes = dl.getTypeAllocSize(elemTy);
    Value *elemSizeGep = builder.CreateConstGEP2_32(sliceTy, slicePtr, 0, 3, "slice.elem_size.gep");
    builder.CreateStore(ConstantInt::get(i64, (uint64_t)elemSizeBytes), elemSizeGep);

    return rawMem;
}
