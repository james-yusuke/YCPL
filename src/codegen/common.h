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
            return llvm::PointerType::get(context, 0);
        }

        inline llvm::PointerType *getPtrTy(llvm::LLVMContext &context, unsigned addressSpace = 0)
        {
            return llvm::PointerType::get(context, addressSpace);
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
            cached->setBody({
                getI8PtrTy(context),
                getI64Ty(context),
                getI64Ty(context),
                getI64Ty(context),
            });
            return cached;
        }

        inline llvm::Value *constInt64(llvm::IRBuilder<> &B, uint64_t v)
        {
            return llvm::ConstantInt::get(getI64Ty(B.getContext()), v);
        }

        inline llvm::Value *createStructFieldGEP(llvm::IRBuilder<> &B, llvm::Type *Ty, llvm::Value *Ptr, unsigned fieldNo, const llvm::Twine &Name = "")
        {
            llvm::Value *idxs[] = {
                llvm::ConstantInt::get(llvm::Type::getInt32Ty(B.getContext()), 0),
                llvm::ConstantInt::get(llvm::Type::getInt32Ty(B.getContext()), fieldNo),
            };
            return B.CreateGEP(Ty, Ptr, idxs, Name);
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
