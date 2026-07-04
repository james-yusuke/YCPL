#pragma once

#include "../common.h"

namespace codegen
{
    namespace detail
    {
        // Runtime representation for YCPL dynamic arrays and slices.
        // { data: *byte, len: i64, cap: i64, elem_size: i64 }
        enum class RuntimeArrayField : unsigned
        {
            Data = 0,
            Length = 1,
            Capacity = 2,
            ElementSize = 3,
        };

        inline llvm::StructType *getOrCreateRuntimeArrayHeaderType(llvm::LLVMContext &context)
        {
            static llvm::StructType *cached = nullptr;
            if (cached)
                return cached;

            cached = llvm::StructType::create(context, "YCPLArrayHeader");
            cached->setBody({
                getI8PtrTy(context),
                getI64Ty(context),
                getI64Ty(context),
                getI64Ty(context),
            });
            return cached;
        }

        inline llvm::Value *createRuntimeArrayFieldGEP(
            llvm::IRBuilder<> &builder,
            llvm::StructType *headerType,
            llvm::Value *headerPtr,
            RuntimeArrayField field,
            const llvm::Twine &name = "")
        {
            return createStructFieldGEP(builder, headerType, headerPtr, static_cast<unsigned>(field), name);
        }
    }
}
