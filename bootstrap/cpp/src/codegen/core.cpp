#include "codegen.h"
#include "common.h"

#include <llvm/IR/Constants.h>
#include <llvm/IR/Function.h>
#include <llvm/IR/GlobalVariable.h>
#include <llvm/IR/Type.h>
#include <llvm/Support/FileSystem.h>

#include <iostream>

namespace codegen
{
    CodeGen::CodeGen(const std::string &module_name)
        : module(std::make_unique<Module>(module_name, context)), builder(context)
    {
        llvm::InitializeNativeTarget();
        llvm::InitializeNativeTargetAsmPrinter();
        llvm::InitializeNativeTargetAsmParser();
    }

    CodeGen::~CodeGen() = default;

    void CodeGen::error(const std::string &msg)
    {
        failed = true;
        std::cerr << "[codegen error] " << msg << "\n";
    }

    llvm::Value *CodeGen::cast_to_integer_type(llvm::Value *v, llvm::Type *targetType)
    {
        if (v->getType() == targetType)
            return v;
        return builder.CreateIntCast(v, targetType, true);
    }

    Type *CodeGen::get_int_type() { return Type::getInt32Ty(context); }
    Type *CodeGen::get_i64_type() { return Type::getInt64Ty(context); }
    Type *CodeGen::get_double_type() { return Type::getDoubleTy(context); }
    Type *CodeGen::get_void_type() { return Type::getVoidTy(context); }
    Type *CodeGen::get_i8ptr_type() { return detail::getPtrTy(context); }

    FunctionCallee CodeGen::get_printf()
    {
        Type *i8ptr = detail::getPtrTy(context);
        FunctionType *printfType = FunctionType::get(IntegerType::getInt32Ty(context), {i8ptr}, true);
        FunctionCallee callee = module->getOrInsertFunction("printf", printfType);
        if (auto *fn = dyn_cast<Function>(callee.getCallee()))
            function_protos["printf"] = fn;
        return callee;
    }

    Value *CodeGen::make_global_string(const std::string &str, const std::string &name)
    {
        GlobalVariable *gv = builder.CreateGlobalString(str, name.empty() ? ".str" : name);
        Constant *zero = ConstantInt::get(Type::getInt32Ty(context), 0);
        Constant *indices[] = {zero, zero};
        return ConstantExpr::getInBoundsGetElementPtr(gv->getValueType(), gv, indices);
    }

    Value *CodeGen::create_entry_alloca(Function *func, Type *type, const std::string &name)
    {
        IRBuilder<> tmp(&func->getEntryBlock(), func->getEntryBlock().begin());
        return tmp.CreateAlloca(type, nullptr, name);
    }

    FunctionCallee CodeGen::get_runtime_void_fn(const std::string &name)
    {
        FunctionType *fnType = FunctionType::get(get_void_type(), {}, false);
        return module->getOrInsertFunction(name, fnType);
    }

    FunctionCallee CodeGen::get_runtime_ptr_fn(const std::string &name)
    {
        Type *ptrTy = detail::getPtrTy(context);
        FunctionType *fnType = FunctionType::get(ptrTy, {ptrTy}, false);
        return module->getOrInsertFunction(name, fnType);
    }

    void CodeGen::emit_runtime_function_entry(bool is_main)
    {
        runtime_scope_depth = 0;
        if (is_main)
            builder.CreateCall(get_runtime_void_fn("yc_runtime_init"));
        builder.CreateCall(get_runtime_void_fn("yc_frame_push"));
    }

    void CodeGen::emit_runtime_function_exit(bool is_main)
    {
        emit_runtime_scope_unwind(0);
        builder.CreateCall(get_runtime_void_fn("yc_frame_pop"));
        if (is_main)
            builder.CreateCall(get_runtime_void_fn("yc_runtime_shutdown"));
    }

    Value *CodeGen::emit_runtime_move_to_parent(Value *value)
    {
        return emit_runtime_move_to_ancestor(value, 1);
    }

    Value *CodeGen::emit_runtime_move_to_ancestor(Value *value, size_t levels)
    {
        if (!value || !value->getType()->isPointerTy() || levels == 0)
            return value;
        Type *ptrTy = detail::getPtrTy(context);
        Type *sizeTy = Type::getInt64Ty(context);
        FunctionType *moveType = FunctionType::get(ptrTy, {ptrTy, sizeTy}, false);
        FunctionCallee moveFn = module->getOrInsertFunction("yc_move_to_ancestor", moveType);
        Value *moved = builder.CreateCall(moveFn, {
            builder.CreatePointerCast(value, ptrTy, "runtime.move.ptr"),
            ConstantInt::get(sizeTy, levels),
        }, "runtime.move");
        if (moved->getType() != value->getType())
            return builder.CreatePointerCast(moved, value->getType(), "runtime.move.cast");
        return moved;
    }

    void CodeGen::emit_runtime_escape_aggregate(Value *value, size_t levels)
    {
        if (!value)
            return;
        Type *type = value->getType();
        if (type->isPointerTy())
        {
            emit_runtime_move_to_ancestor(value, levels);
            return;
        }
        if (auto *structType = dyn_cast<StructType>(type))
        {
            for (unsigned i = 0; i < structType->getNumElements(); ++i)
                emit_runtime_escape_aggregate(builder.CreateExtractValue(value, {i}, "runtime.escape.field"), levels);
            return;
        }
        if (auto *arrayType = dyn_cast<ArrayType>(type))
        {
            for (uint64_t i = 0; i < arrayType->getNumElements(); ++i)
                emit_runtime_escape_aggregate(builder.CreateExtractValue(value, {static_cast<unsigned>(i)}, "runtime.escape.element"), levels);
        }
    }

    void CodeGen::emit_runtime_scope_unwind(size_t target_depth)
    {
        if (target_depth > runtime_scope_depth)
            target_depth = runtime_scope_depth;
        for (size_t depth = runtime_scope_depth; depth > target_depth; --depth)
            builder.CreateCall(get_runtime_void_fn("yc_frame_pop"));
    }

    void CodeGen::emit_runtime_move_frame_to_parent()
    {
        builder.CreateCall(get_runtime_void_fn("yc_move_frame_to_parent"));
    }

    void CodeGen::dump_llvm_ir()
    {
        llvm::verifyModule(*module.get());
        module->print(llvm::outs(), nullptr);
    }

    bool CodeGen::write_ir_to_file(const std::string &path)
    {
        std::error_code EC;
        llvm::raw_fd_ostream dest(path, EC, llvm::sys::fs::OF_None);
        if (EC)
        {
            std::cerr << "Could not open file: " << EC.message() << "\n";
            return false;
        }
        module->print(dest, nullptr);
        return true;
    }
}
