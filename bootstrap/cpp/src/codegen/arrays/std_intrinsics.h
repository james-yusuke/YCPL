#pragma once

#include "../codegen.h"
#include "../common.h"
#include "../types/type_shape.h"

#include <llvm/IR/Constants.h>
#include <llvm/IR/DerivedTypes.h>

namespace codegen
{

Value *CodeGen::codegen_array_intrinsic_call(const std::string &name, const ast::CallExpr *ce)
{
    if (name == "__YCPL_std__array_len")
        return codegen_len_call(ce);

    if (name == "__YCPL_std__array_append")
        return codegen_append_call(ce);

    if (name == "__YCPL_std__array_new")
    {
        if (ce->args.size() != 2)
        {
            error("array.new expects 2 arguments: array.new([]T, cap)");
            return nullptr;
        }

        const auto *typeExpr = dynamic_cast<const ast::TypeExpr *>(ce->args[0].get());
        if (!typeExpr)
        {
            error("array.new first argument must be an array type, e.g. []i32");
            return nullptr;
        }

        const ast::Type *elemAst = typeExpr->type.get();
        if (auto arrAst = dynamic_cast<const ast::ArrayType *>(elemAst))
            elemAst = arrAst->elem.get();
        else
        {
            error("array.new first argument must be an array type, e.g. []i32");
            return nullptr;
        }

        Type *elemTy = resolve_type_from_ast(elemAst);
        if (!elemTy)
        {
            error("array.new cannot resolve element type");
            return nullptr;
        }

        Module *M = module.get();
        const DataLayout &dl = M->getDataLayout();
        StructType *arrayStruct = detail::getOrCreateRuntimeArrayHeaderType(context);
        Type *arrayPtrTy = detail::getPtrTy(context);
        Type *i64Ty = get_i64_type();
        Type *i8ptrTy = get_i8ptr_type();

        Value *cap = coerce_to_i64(codegen_expr(ce->args[1].get()), "array.cap.i64");
        if (!cap)
            return nullptr;

        Value *zero = ConstantInt::get(i64Ty, 0);
        Value *one = ConstantInt::get(i64Ty, 1);
        Value *allocCap = builder.CreateSelect(builder.CreateICmpEQ(cap, zero, "array.cap.is_zero"), one, cap, "array.alloc_cap");

        uint64_t elemSize = dl.getTypeAllocSize(elemTy);
        Value *elemSizeVal = ConstantInt::get(i64Ty, elemSize);
        Value *dataBytes = builder.CreateMul(allocCap, elemSizeVal, "array.data_bytes");

        FunctionCallee mallocFn = detail::getMalloc(M);
        Value *structSize = ConstantInt::get(i64Ty, dl.getTypeAllocSize(arrayStruct));
        Value *rawStruct = builder.CreateCall(mallocFn, {structSize}, "array.struct.raw");
        Value *arrPtr = builder.CreatePointerCast(rawStruct, arrayPtrTy, "array.struct");
        Value *rawData = builder.CreateCall(mallocFn, {dataBytes}, "array.data.raw");
        Value *dataPtr = builder.CreatePointerCast(rawData, i8ptrTy, "array.data");
        builder.CreateMemSet(dataPtr, ConstantInt::get(Type::getInt8Ty(context), 0), dataBytes, MaybeAlign(1));

        builder.CreateStore(dataPtr, array_header_field_ptr(arrPtr, detail::RuntimeArrayField::Data, "array.new.data.ptr"));
        builder.CreateStore(zero, array_header_field_ptr(arrPtr, detail::RuntimeArrayField::Length, "array.new.len.ptr"));
        builder.CreateStore(cap, array_header_field_ptr(arrPtr, detail::RuntimeArrayField::Capacity, "array.new.cap.ptr"));
        builder.CreateStore(elemSizeVal, array_header_field_ptr(arrPtr, detail::RuntimeArrayField::ElementSize, "array.new.elem_size.ptr"));
        return arrPtr;
    }

    if (name == "__YCPL_std__array_cap")
    {
        if (ce->args.size() != 1)
        {
            error("array.cap expects 1 argument");
            return nullptr;
        }
        Value *arrPtr = array_header_ptr_from_expr(ce->args[0].get(), "array.cap.ptr");
        if (!arrPtr)
            return nullptr;
        Value *capPtr = array_header_field_ptr(arrPtr, detail::RuntimeArrayField::Capacity, "array.cap.ptr.field");
        Value *cap64 = builder.CreateLoad(get_i64_type(), capPtr, "array.cap64");
        return builder.CreateTrunc(cap64, get_int_type(), "array.cap32");
    }

    if (name == "__YCPL_std__array_get")
    {
        if (ce->args.size() != 2)
        {
            error("array.get expects 2 arguments");
            return nullptr;
        }
        Value *elemSize = nullptr;
        Value *elemPtrI8 = checked_array_element_data_ptr(ce->args[0].get(), ce->args[1].get(), &elemSize);
        if (!elemPtrI8)
            return nullptr;

        if (auto id = dynamic_cast<const ast::Ident *>(ce->args[0].get()))
        {
            if (std::string *typeHint = lookup_local_type(id->name))
            {
                TypeShape parsed = parse_type_shape(*typeHint);
                if (parsed.is_array())
                {
                    std::string elemTypeName = parsed.array_element_type_name();

                    Type *elemTy = parsed.array_rank > 1
                                       ? detail::getPtrTy(context)
                                       : resolve_llvm_type_name(elemTypeName);
                    if (elemTy)
                    {
                        Value *typedPtr = builder.CreatePointerCast(elemPtrI8, detail::getPtrTy(context), "array.get.typed.ptr");
                        return builder.CreateLoad(elemTy, typedPtr, "array.get.typed");
                    }
                }
            }
        }

        Type *i64Ty = get_i64_type();
        Function *F = builder.GetInsertBlock()->getParent();
        BasicBlock *case8BB = BasicBlock::Create(context, "array_get_case8", F);
        BasicBlock *check4BB = BasicBlock::Create(context, "array_get_check4", F);
        BasicBlock *case4BB = BasicBlock::Create(context, "array_get_case4", F);
        BasicBlock *check2BB = BasicBlock::Create(context, "array_get_check2", F);
        BasicBlock *case2BB = BasicBlock::Create(context, "array_get_case2", F);
        BasicBlock *case1BB = BasicBlock::Create(context, "array_get_case1", F);
        BasicBlock *afterBB = BasicBlock::Create(context, "array_get_after", F);

        builder.CreateCondBr(builder.CreateICmpEQ(elemSize, ConstantInt::get(i64Ty, 8)), case8BB, check4BB);

        builder.SetInsertPoint(case8BB);
        Value *v8 = builder.CreateLoad(i64Ty, builder.CreatePointerCast(elemPtrI8, detail::getPtrTy(context)), "array.get.i64");
        builder.CreateBr(afterBB);

        builder.SetInsertPoint(check4BB);
        builder.CreateCondBr(builder.CreateICmpEQ(elemSize, ConstantInt::get(i64Ty, 4)), case4BB, check2BB);

        builder.SetInsertPoint(case4BB);
        Value *v4raw = builder.CreateLoad(get_int_type(), builder.CreatePointerCast(elemPtrI8, detail::getPtrTy(context)), "array.get.i32");
        Value *v4 = builder.CreateSExt(v4raw, i64Ty, "array.get.i32.to_i64");
        builder.CreateBr(afterBB);

        builder.SetInsertPoint(check2BB);
        builder.CreateCondBr(builder.CreateICmpEQ(elemSize, ConstantInt::get(i64Ty, 2)), case2BB, case1BB);

        builder.SetInsertPoint(case2BB);
        Type *i16Ty = Type::getInt16Ty(context);
        Value *v2raw = builder.CreateLoad(i16Ty, builder.CreatePointerCast(elemPtrI8, detail::getPtrTy(context)), "array.get.i16");
        Value *v2 = builder.CreateSExt(v2raw, i64Ty, "array.get.i16.to_i64");
        builder.CreateBr(afterBB);

        builder.SetInsertPoint(case1BB);
        Type *i8Ty = Type::getInt8Ty(context);
        Value *v1raw = builder.CreateLoad(i8Ty, builder.CreatePointerCast(elemPtrI8, detail::getPtrTy(context)), "array.get.i8");
        Value *v1 = builder.CreateSExt(v1raw, i64Ty, "array.get.i8.to_i64");
        builder.CreateBr(afterBB);

        builder.SetInsertPoint(afterBB);
        PHINode *phi = builder.CreatePHI(i64Ty, 4, "array.get.result");
        phi->addIncoming(v8, case8BB);
        phi->addIncoming(v4, case4BB);
        phi->addIncoming(v2, case2BB);
        phi->addIncoming(v1, case1BB);
        return phi;
    }

    if (name == "__YCPL_std__array_set")
    {
        if (ce->args.size() != 3)
        {
            error("array.set expects 3 arguments");
            return nullptr;
        }
        Value *elemSize = nullptr;
        Value *elemPtrI8 = checked_array_element_data_ptr(ce->args[0].get(), ce->args[1].get(), &elemSize);
        Value *value = codegen_expr(ce->args[2].get());
        if (!elemPtrI8 || !value)
            return nullptr;

        Type *i8ptrTy = get_i8ptr_type();
        Value *tmp = builder.CreateAlloca(value->getType(), nullptr, value->getType()->isPointerTy() ? "array.set.ptr.tmp" : "array.set.tmp");
        builder.CreateStore(value, tmp);
        Value *srcPtr = builder.CreatePointerCast(tmp, i8ptrTy, value->getType()->isPointerTy() ? "array.set.src.ptr.value" : "array.set.src.i8");
        builder.CreateMemCpy(elemPtrI8, MaybeAlign(1), srcPtr, MaybeAlign(1), elemSize);
        return nullptr;
    }

    if (name == "__YCPL_std__array_free")
    {
        if (ce->args.size() != 1)
        {
            error("array.free expects 1 argument");
            return nullptr;
        }
        Value *arrPtr = array_header_ptr_from_expr(ce->args[0].get(), "array.free.ptr");
        if (!arrPtr)
            return nullptr;
        Value *dataPtrPtr = array_header_field_ptr(arrPtr, detail::RuntimeArrayField::Data, "array.free.data.ptr.ptr");
        Value *dataPtr = builder.CreateLoad(get_i8ptr_type(), dataPtrPtr, "array.free.data.ptr");
        Function *freeFn = get_or_declare_c_function("free");
        if (!freeFn)
        {
            error("free is not available");
            return nullptr;
        }
        builder.CreateCall(freeFn, {dataPtr});
        builder.CreateCall(freeFn, {builder.CreatePointerCast(arrPtr, get_i8ptr_type(), "array.free.struct.i8")});
        return nullptr;
    }

    return nullptr;
}

}
