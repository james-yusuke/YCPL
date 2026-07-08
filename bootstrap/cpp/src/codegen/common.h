#pragma once

#include <llvm/ADT/ArrayRef.h>
#include <llvm/ADT/SmallVector.h>
#include <llvm/ADT/Twine.h>
#include <llvm/IR/Constants.h>
#include <llvm/IR/DataLayout.h>
#include <llvm/IR/GlobalValue.h>
#include <llvm/IR/GlobalVariable.h>
#include <llvm/IR/IRBuilder.h>
#include <llvm/IR/DerivedTypes.h>
#include <llvm/IR/Module.h>
#include <llvm/IR/Function.h>
#include <llvm/IR/Instructions.h>

namespace codegen
{
    using llvm::AllocaInst;
    using llvm::Argument;
    using llvm::ArrayType;
    using llvm::ArrayRef;
    using llvm::BasicBlock;
    using llvm::BitCastInst;
    using llvm::CallInst;
    using llvm::Constant;
    using llvm::ConstantAggregateZero;
    using llvm::ConstantArray;
    using llvm::ConstantExpr;
    using llvm::ConstantFP;
    using llvm::ConstantInt;
    using llvm::ConstantPointerNull;
    using llvm::DataLayout;
    using llvm::Function;
    using llvm::FunctionCallee;
    using llvm::FunctionType;
    using llvm::GetElementPtrInst;
    using llvm::GlobalValue;
    using llvm::GlobalVariable;
    using llvm::Instruction;
    using llvm::IntegerType;
    using llvm::IRBuilder;
    using llvm::LLVMContext;
    using llvm::LoadInst;
    using llvm::MaybeAlign;
    using llvm::Module;
    using llvm::PHINode;
    using llvm::PointerType;
    using llvm::SmallVector;
    using llvm::StructType;
    using llvm::Twine;
    using llvm::Type;
    using llvm::Value;
    using llvm::cast;
    using llvm::dyn_cast;
    using llvm::errs;

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

        inline llvm::FunctionCallee getRuntimeAlloc(llvm::Module *M)
        {
            llvm::LLVMContext &context = M->getContext();
            auto *allocTy = llvm::FunctionType::get(
                getI8PtrTy(context),
                {getI64Ty(context)},
                false);
            return M->getOrInsertFunction("yc_alloc", allocTy);
        }

        inline llvm::FunctionCallee getMalloc(llvm::Module *M)
        {
            return getRuntimeAlloc(M);
        }
    }
}
