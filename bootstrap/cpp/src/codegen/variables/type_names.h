#pragma once
#include "../codegen.h"
#include "../common.h"
#include "../types/type_shape.h"
#include <llvm/IR/LLVMContext.h>
#include <llvm/IR/Type.h>
#include <llvm/IR/DerivedTypes.h>
#include <llvm/IR/IRBuilder.h>
#include <string>
#include <stdexcept>

llvm::Type *codegen::CodeGen::resolve_llvm_type_name(const std::string &typeName)
{
    std::string resolvedTypeName = resolve_type_alias_name(typeName);
    TypeShape pt = parse_type_shape(resolvedTypeName);

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
    else if (pt.is_map_type())
    {
        ty = codegen::detail::getPtrTy(context);
    }
    else if (pt.is_vec_type())
    {
        ty = codegen::detail::getPtrTy(context);
    }
    else
    {
        ty = lookup_struct_type(pt.base);
        if (!ty)
        {
            return nullptr;
        }
    }

    for (int i = 0; i < pt.array_rank; ++i)
    {
        ty = detail::getPtrTy(context);
    }

    for (int i = 0; i < pt.pointer_depth; ++i)
    {
        ty = codegen::detail::getPtrTy(context);
    }

    return ty;
}
