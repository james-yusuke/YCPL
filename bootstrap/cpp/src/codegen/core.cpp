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
        if (is_main)
            builder.CreateCall(get_runtime_void_fn("yc_runtime_init"));
        builder.CreateCall(get_runtime_void_fn("yc_frame_push"));
    }

    void CodeGen::emit_runtime_function_exit(bool is_main)
    {
        builder.CreateCall(get_runtime_void_fn("yc_frame_pop"));
        if (is_main)
            builder.CreateCall(get_runtime_void_fn("yc_runtime_shutdown"));
    }

    Value *CodeGen::emit_runtime_move_to_parent(Value *value)
    {
        if (!value || !value->getType()->isPointerTy())
            return value;
        Value *moved = builder.CreateCall(get_runtime_ptr_fn("yc_move_to_parent"), {builder.CreatePointerCast(value, detail::getPtrTy(context), "runtime.move.ptr")}, "runtime.move");
        if (moved->getType() != value->getType())
            return builder.CreatePointerCast(moved, value->getType(), "runtime.move.cast");
        return moved;
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
