#pragma once

#include "../codegen.h"
#include "../common.h"
#include "../types/type_shape.h"

#include <llvm/IR/Constants.h>
#include <llvm/IR/DerivedTypes.h>

#include <functional>
#include <limits>

namespace codegen
{

namespace
{
inline void emit_vec_abort_if(CodeGen *, IRBuilder<> &builder, Module *module, Value *condition, const Twine &label)
{
    Function *function = builder.GetInsertBlock()->getParent();
    BasicBlock *abortBlock = BasicBlock::Create(module->getContext(), label + ".abort", function);
    BasicBlock *okBlock = BasicBlock::Create(module->getContext(), label + ".ok", function);
    builder.CreateCondBr(condition, abortBlock, okBlock);
    builder.SetInsertPoint(abortBlock);
    FunctionType *abortType = FunctionType::get(Type::getVoidTy(module->getContext()), {}, false);
    builder.CreateCall(module->getOrInsertFunction("abort", abortType), {});
    builder.CreateUnreachable();
    builder.SetInsertPoint(okBlock);
}
}

Value *CodeGen::codegen_vec_literal(const ast::VecLiteral *literal)
{
    if (!literal || !literal->elem_type)
    {
        error("Vec literal requires an element type");
        return nullptr;
    }

    Type *elementType = resolve_type_from_ast(literal->elem_type.get());
    if (!elementType || !elementType->isSized())
    {
        error("Vec element type must be a sized type");
        return nullptr;
    }

    Module *M = module.get();
    const DataLayout &layout = M->getDataLayout();
    Type *i64Type = get_i64_type();
    Type *i8Type = Type::getInt8Ty(context);
    Type *pointerType = get_i8ptr_type();
    StructType *headerType = detail::getOrCreateRuntimeArrayHeaderType(context);

    Value *capacity = ConstantInt::get(i64Type, 0);
    if (literal->capacity)
    {
        Value *rawCapacity = codegen_expr(literal->capacity.get());
        if (!rawCapacity || !rawCapacity->getType()->isIntegerTy())
        {
            error("Vec capacity must be an integer");
            return nullptr;
        }
        capacity = coerce_to_i64(rawCapacity, "vec.capacity.i64");
    }

    uint64_t elementSize = layout.getTypeAllocSize(elementType);
    if (elementSize == 0)
        elementSize = 1;
    Value *elementSizeValue = ConstantInt::get(i64Type, elementSize);

    Value *negative = builder.CreateICmpSLT(capacity, ConstantInt::get(i64Type, 0), "vec.capacity.negative");
    emit_vec_abort_if(this, builder, M, negative, "vec.capacity");

    const uint64_t maxCapacity = static_cast<uint64_t>(std::numeric_limits<int64_t>::max()) / elementSize;
    Value *tooLarge = builder.CreateICmpUGT(capacity, ConstantInt::get(i64Type, maxCapacity), "vec.capacity.overflow");
    emit_vec_abort_if(this, builder, M, tooLarge, "vec.capacity.overflow");

    Value *one = ConstantInt::get(i64Type, 1);
    Value *allocationCapacity = builder.CreateSelect(
        builder.CreateICmpEQ(capacity, ConstantInt::get(i64Type, 0), "vec.capacity.zero"),
        one,
        capacity,
        "vec.allocation.capacity");
    Value *dataBytes = builder.CreateMul(allocationCapacity, elementSizeValue, "vec.data.bytes");

    Function *allocate = get_or_declare_c_function("yc_calloc");
    if (!allocate)
    {
        error("Vec requires yc_calloc");
        return nullptr;
    }
    Value *rawHeader = builder.CreateCall(
        allocate,
        {
            ConstantInt::get(i64Type, 1),
            ConstantInt::get(i64Type, layout.getTypeAllocSize(headerType)),
        },
        "vec.header.raw");
    Value *headerNull = builder.CreateICmpEQ(rawHeader, ConstantPointerNull::get(cast<PointerType>(rawHeader->getType())), "vec.header.null");
    emit_vec_abort_if(this, builder, M, headerNull, "vec.header.oom");
    Value *header = builder.CreatePointerCast(rawHeader, detail::getPtrTy(context), "vec.header");

    Value *rawData = builder.CreateCall(allocate, {allocationCapacity, elementSizeValue}, "vec.data.raw");
    Value *dataNull = builder.CreateICmpEQ(rawData, ConstantPointerNull::get(cast<PointerType>(rawData->getType())), "vec.data.null");
    emit_vec_abort_if(this, builder, M, dataNull, "vec.data.oom");
    Value *data = builder.CreatePointerCast(rawData, pointerType, "vec.data");
    builder.CreateMemSet(data, ConstantInt::get(i8Type, 0), dataBytes, MaybeAlign(1));

    builder.CreateStore(data, array_header_field_ptr(header, detail::RuntimeArrayField::Data, "vec.data.ptr"));
    builder.CreateStore(ConstantInt::get(i64Type, 0), array_header_field_ptr(header, detail::RuntimeArrayField::Length, "vec.len.ptr"));
    builder.CreateStore(capacity, array_header_field_ptr(header, detail::RuntimeArrayField::Capacity, "vec.cap.ptr"));
    builder.CreateStore(elementSizeValue, array_header_field_ptr(header, detail::RuntimeArrayField::ElementSize, "vec.elem_size.ptr"));

    if (Function *attach = get_or_declare_c_function("yc_attach_child"))
        builder.CreateCall(attach, {builder.CreatePointerCast(header, pointerType), data});
    return header;
}

Value *CodeGen::codegen_vec_method(const ast::MemberExpr *member, const ast::CallExpr *call)
{
    if (!member || !call)
        return nullptr;

    TypeShape vecShape = parse_type_shape(infer_expr_type_name(member->object.get()));
    if (!vecShape.is_vec_type())
    {
        error("Vec method called on a non-Vec value");
        return nullptr;
    }

    const std::string &name = member->member;
    if (name == "push")
    {
        if (call->args.size() != 1)
        {
            error("Vec.push expects exactly one value");
            return nullptr;
        }
        const std::string actualType = infer_expr_type_name(call->args[0].get());
        if (!actualType.empty())
        {
            const TypeShape actualShape = parse_type_shape(actualType);
            const TypeShape expectedShape = parse_type_shape(vecShape.vec_element);
            if (actualShape.full_name() != expectedShape.full_name())
            {
                error("Vec.push value type does not match element type");
                return nullptr;
            }
        }
        return codegen_append_value(member->object.get(), call->args[0].get(), true);
    }

    if (name == "reserve")
    {
        if (call->args.size() != 1)
        {
            error("Vec.reserve expects exactly one capacity");
            return nullptr;
        }

        Value *requestedValue = codegen_expr(call->args[0].get());
        if (!requestedValue || !requestedValue->getType()->isIntegerTy())
        {
            error("Vec.reserve capacity must be an integer");
            return nullptr;
        }
        Value *requested = coerce_to_i64(requestedValue, "vec.reserve.requested");
        Module *M = module.get();
        emit_vec_abort_if(this, builder, M,
            builder.CreateICmpSLT(requested, ConstantInt::get(get_i64_type(), 0), "vec.reserve.negative"),
            "vec.reserve.negative");

        Type *elementType = resolve_llvm_type_name(vecShape.vec_element);
        if (!elementType || !elementType->isSized())
        {
            error("Vec.reserve cannot resolve the element type");
            return nullptr;
        }
        uint64_t elementSize = M->getDataLayout().getTypeAllocSize(elementType);
        if (elementSize == 0)
            elementSize = 1;
        uint64_t maximum = static_cast<uint64_t>(std::numeric_limits<int64_t>::max()) / elementSize;
        emit_vec_abort_if(this, builder, M,
            builder.CreateICmpUGT(requested, ConstantInt::get(get_i64_type(), maximum), "vec.reserve.overflow"),
            "vec.reserve.overflow");

        Value *header = array_header_ptr_from_expr(member->object.get(), "vec.reserve.header");
        if (!header)
            return nullptr;
        Value *capacityPtr = array_header_field_ptr(header, detail::RuntimeArrayField::Capacity, "vec.reserve.cap.ptr");
        Value *oldCapacity = builder.CreateLoad(get_i64_type(), capacityPtr, "vec.reserve.old_cap");
        Function *function = builder.GetInsertBlock()->getParent();
        BasicBlock *grow = BasicBlock::Create(context, "vec.reserve.grow", function);
        BasicBlock *done = BasicBlock::Create(context, "vec.reserve.done", function);
        builder.CreateCondBr(builder.CreateICmpUGT(requested, oldCapacity), grow, done);

        builder.SetInsertPoint(grow);
        Value *dataPtrPtr = array_header_field_ptr(header, detail::RuntimeArrayField::Data, "vec.reserve.data.ptr.ptr");
        Value *oldData = builder.CreateLoad(get_i8ptr_type(), dataPtrPtr, "vec.reserve.old_data");
        Value *bytes = builder.CreateMul(requested, ConstantInt::get(get_i64_type(), elementSize), "vec.reserve.bytes");
        Function *allocate = get_or_declare_c_function("yc_alloc");
        if (!allocate)
        {
            error("Vec.reserve requires yc_alloc");
            return nullptr;
        }
        Value *newData = builder.CreateCall(allocate, {bytes}, "vec.reserve.new_data");
        emit_vec_abort_if(this, builder, M,
            builder.CreateICmpEQ(newData, ConstantPointerNull::get(cast<PointerType>(newData->getType())), "vec.reserve.oom"),
            "vec.reserve.oom");
        Value *length = builder.CreateLoad(get_i64_type(), array_header_field_ptr(header, detail::RuntimeArrayField::Length, "vec.reserve.len.ptr"), "vec.reserve.len");
        Value *copyBytes = builder.CreateMul(length, ConstantInt::get(get_i64_type(), elementSize), "vec.reserve.copy_bytes");
        builder.CreateMemCpy(newData, MaybeAlign(1), oldData, MaybeAlign(1), copyBytes);
        builder.CreateStore(newData, dataPtrPtr);
        builder.CreateStore(requested, capacityPtr);
        if (Function *replace = get_or_declare_c_function("yc_replace_child"))
            builder.CreateCall(replace, {builder.CreatePointerCast(header, get_i8ptr_type()), oldData, newData});
        if (Function *release = get_or_declare_c_function("yc_release"))
            builder.CreateCall(release, {oldData});
        builder.CreateBr(done);
        builder.SetInsertPoint(done);
        return nullptr;
    }

    if (!call->args.empty())
    {
        error("Vec." + name + " does not accept arguments");
        return nullptr;
    }

    Value *header = array_header_ptr_from_expr(member->object.get(), "vec.method.header");
    if (!header)
        return nullptr;

    if (name == "len" || name == "capacity")
    {
        detail::RuntimeArrayField field = name == "len"
            ? detail::RuntimeArrayField::Length
            : detail::RuntimeArrayField::Capacity;
        Value *value = builder.CreateLoad(get_i64_type(), array_header_field_ptr(header, field, "vec." + name + ".ptr"), "vec." + name + ".i64");
        return builder.CreateTrunc(value, get_int_type(), "vec." + name + ".i32");
    }

    if (name == "as_slice")
        return header;

    if (name == "clear")
    {
        Type *elementType = resolve_llvm_type_name(vecShape.vec_element);
        Value *lenPtr = array_header_field_ptr(header, detail::RuntimeArrayField::Length, "vec.clear.len.ptr");
        Value *length = builder.CreateLoad(get_i64_type(), lenPtr, "vec.clear.len");

        if (elementType)
        {
            Value *data = builder.CreateLoad(get_i8ptr_type(), array_header_field_ptr(header, detail::RuntimeArrayField::Data, "vec.clear.data.ptr.ptr"), "vec.clear.data");
            Function *function = builder.GetInsertBlock()->getParent();
            Value *indexSlot = create_entry_alloca(function, get_i64_type(), "vec.clear.index");
            builder.CreateStore(ConstantInt::get(get_i64_type(), 0), indexSlot);
            BasicBlock *condition = BasicBlock::Create(context, "vec.clear.cond", function);
            BasicBlock *body = BasicBlock::Create(context, "vec.clear.body", function);
            BasicBlock *done = BasicBlock::Create(context, "vec.clear.done", function);
            builder.CreateBr(condition);
            builder.SetInsertPoint(condition);
            Value *index = builder.CreateLoad(get_i64_type(), indexSlot, "vec.clear.index.value");
            builder.CreateCondBr(builder.CreateICmpULT(index, length), body, done);
            builder.SetInsertPoint(body);
            Value *offset = builder.CreateMul(index, ConstantInt::get(get_i64_type(), module->getDataLayout().getTypeAllocSize(elementType)), "vec.clear.offset");
            Value *slot = builder.CreateInBoundsGEP(Type::getInt8Ty(context), data, {offset}, "vec.clear.slot");
            Value *item = builder.CreateLoad(elementType, slot, "vec.clear.item");
            Function *release = get_or_declare_c_function("yc_release");
            std::function<void(Value *)> releaseManagedChildren = [&](Value *value)
            {
                if (!value || !release)
                    return;
                Type *valueType = value->getType();
                if (valueType->isPointerTy())
                {
                    builder.CreateCall(release, {builder.CreatePointerCast(value, get_i8ptr_type(), "vec.clear.child")});
                    return;
                }
                if (auto *structType = dyn_cast<StructType>(valueType))
                {
                    for (unsigned field = 0; field < structType->getNumElements(); ++field)
                        releaseManagedChildren(builder.CreateExtractValue(value, {field}, "vec.clear.field"));
                    return;
                }
                if (auto *arrayType = dyn_cast<ArrayType>(valueType))
                {
                    for (uint64_t itemIndex = 0; itemIndex < arrayType->getNumElements(); ++itemIndex)
                        releaseManagedChildren(builder.CreateExtractValue(value, {static_cast<unsigned>(itemIndex)}, "vec.clear.element"));
                }
            };
            releaseManagedChildren(item);
            builder.CreateStore(Constant::getNullValue(elementType), slot);
            builder.CreateStore(builder.CreateAdd(index, ConstantInt::get(get_i64_type(), 1)), indexSlot);
            builder.CreateBr(condition);
            builder.SetInsertPoint(done);
        }

        builder.CreateStore(ConstantInt::get(get_i64_type(), 0), lenPtr);
        return nullptr;
    }

    error("unknown Vec method: " + name);
    return nullptr;
}

}
