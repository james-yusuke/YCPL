#pragma once

#include <llvm/IR/IRBuilder.h>
#include <llvm/IR/DerivedTypes.h>
#include <llvm/IR/Module.h>
#include <llvm/IR/Function.h>

namespace codegen
{
    namespace detail
    {
        inline llvm::Type *getI8PtrTy(llvm::LLVMContext &context)
        {
            return llvm::PointerType::get(llvm::IntegerType::get(context, 8), 0);
        }

        inline llvm::Type *getI64Ty(llvm::LLVMContext &context)
        {
            return llvm::IntegerType::get(context, 64);
        }

        inline llvm::StructType *getOrCreateArrayStruct(llvm::LLVMContext &context)
        {
            static llvm::StructType *cached = nullptr;
            if (cached)
                return cached;

            cached = llvm::StructType::create(context, "Array_internal");
            cached->setBody(
                getI8PtrTy(context),
                getI64Ty(context),
                getI64Ty(context),
                getI64Ty(context));
            return cached;
        }

        inline llvm::Value *constInt64(llvm::IRBuilder<> &B, uint64_t v)
        {
            return llvm::ConstantInt::get(getI64Ty(B.getContext()), v);
        }

        inline llvm::FunctionCallee getMalloc(llvm::Module *M)
        {
            llvm::LLVMContext &context = M->getContext();
            auto *mallocTy = llvm::FunctionType::get(
                getI8PtrTy(context),
                {getI64Ty(context)},
                false);
            return M->getOrInsertFunction("malloc", mallocTy);
        }
    }
}
