#pragma once
#include "../codegen.h"
#include "../common.h"
#include "../array/parse.h"
#include <llvm/IR/LLVMContext.h>
#include <llvm/IR/Type.h>
#include <llvm/IR/DerivedTypes.h>
#include <llvm/IR/IRBuilder.h>
#include <string>
#include <stdexcept>

llvm::Type *CodeGen::getLLVMType(const std::string &typeName)
{
    using namespace llvm;

    ParsedType pt = parse_type_chain(typeName);

    Type *ty = nullptr;

    if (pt.base == "i32")
    {
        ty = Type::getInt32Ty(context);
    }
    else if (pt.base == "i64")
    {
        ty = Type::getInt64Ty(context);
    }
    else if (pt.base == "f32")
    {
        ty = Type::getFloatTy(context);
    }
    else if (pt.base == "f64" || pt.base == "float" || pt.base == "double")
    {
        ty = Type::getDoubleTy(context);
    }
    else if (pt.base == "bool")
    {
        ty = Type::getInt1Ty(context);
    }
    else if (pt.base == "char")
    {
        ty = Type::getInt8Ty(context);
    }
    else if (pt.base == "string")
    {
        ty = codegen::detail::getI8PtrTy(context);
    }
    else if (pt.base == "byte")
    {
        ty = Type::getInt8Ty(context);
    }
    else
    {
        ty = lookup_struct_type(pt.base);
        if (!ty)
        {
            return nullptr;
        }
    }

    for (int i = 0; i < pt.array_depth; ++i)
    {
        ty = detail::getPtrTy(context);
    }

    for (int i = 0; i < pt.pointer_depth; ++i)
    {
        ty = codegen::detail::getPtrTy(context);
    }

    return ty;
}
