#pragma once
#include "../codegen.h"
#include "../common.h"
#include "../types/type_shape.h"
#include "type_names.h"
#include <llvm/IR/Constants.h>
#include <llvm/IR/DerivedTypes.h>
#include <llvm/IR/Intrinsics.h>

namespace codegen
{

std::string CodeGen::resolve_type_name(ast::Type *tp)
{
    TypeShape shape;

    while (tp)
    {

        if (auto *nt = dynamic_cast<ast::NamedType *>(tp))
        {
            shape.base = nt->name;
            return shape.full_name();
        }

        if (auto *at = dynamic_cast<ast::ArrayType *>(tp))
        {
            shape.array_rank++;
            tp = at->elem.get();
            continue;
        }

        if (auto *mt = dynamic_cast<ast::MapType *>(tp))
        {
            std::string keyName = resolve_type_name(mt->key.get());
            std::string valueName = resolve_type_name(mt->value.get());
            shape.base = "Map<" + keyName + "," + valueName + ">";
            return shape.full_name();
        }

        if (auto *pt = dynamic_cast<ast::PointerType *>(tp))
        {
            shape.pointer_depth++;
            tp = pt->base.get();
            continue;
        }

        return {};
    }

    return {};
}

static bool is_primitive_or_empty_type(ast::Type *t)
{
    if (!t)
        return true;

    if (auto *nt = dynamic_cast<ast::NamedType *>(t))
    {
        const std::string &nm = nt->name;
        if (nm.empty())
            return true;
        if (nm == "i32" || nm == "f32" || nm == "bool")
            return true;
        return false;
    }

    return false;
}

static bool is_none_literal_expr(const ast::Expr *e)
{
    auto lit = dynamic_cast<const ast::Literal *>(e);
    return lit && lit->t == lex::TokenType::NONE;
}

Value *CodeGen::codegen_vardecl(const ast::VarDecl *vd)
{
    Function *F = builder.GetInsertBlock()->getParent();
    Type *ty = get_int_type();

    ast::Type *tp = vd->type.get();
    bool hasExplicitType = tp != nullptr;

    std::string t = resolve_type_name(tp);

    if (!t.empty())
    {
        if (Type *tx = resolve_llvm_type_name(t))
        {
            ty = tx;
        }
        else if (hasExplicitType)
        {
            error("unknown type: " + t);
            return nullptr;
        }
    }

    if (vd->init)
    {
            if (auto sl = dynamic_cast<const ast::StructLiteral *>(vd->init.get()))
            {
            llvm::Value *addr = codegen_struct_literal(sl);
            if (!addr)
                return nullptr;
            std::string structTypeName = resolve_type_name(sl->type.get());
            bind_local_const(vd->name, structTypeName.empty() ? t : structTypeName, addr, vd->is_const);
            return addr;
        }
        else
        {
            if (!hasExplicitType && is_none_literal_expr(vd->init.get()))
            {
                error("none requires an explicit pointer or string type");
                return nullptr;
            }

            if (auto alit = dynamic_cast<const ast::ArrayLiteral *>(vd->init.get()))
            {
                ast::Type *tp = alit->array_type.get();
                if (!is_primitive_or_empty_type(tp))
                {
                }
            }

            Value *initV = codegen_expr(vd->init.get());
            if (!initV)
                return nullptr;

            if (!hasExplicitType)
            {
                if (auto call = dynamic_cast<const ast::CallExpr *>(vd->init.get()))
                {
                    if (auto callee = dynamic_cast<const ast::Ident *>(call->callee.get()))
                    {
                        if (callee->name == "__YCPL_std__array_new" && !call->args.empty())
                        {
                            if (auto typeExpr = dynamic_cast<const ast::TypeExpr *>(call->args[0].get()))
                                t = resolve_type_name(typeExpr->type.get());
                        }
                    }
                }
            }

            Type *it = initV->getType();
            if (!hasExplicitType && it->isFloatingPointTy())
            {
                ty = get_double_type();
                t = "i32";
            }
            else if (!hasExplicitType && it->isPointerTy())
            {
                ty = it;
            }
            else if (!hasExplicitType && it->isIntegerTy(1))
            {
                ty = Type::getInt1Ty(builder.getContext());
                t = "bool";
            }
            else if (!hasExplicitType && it->isIntegerTy())
            {
                ty = it->isIntegerTy(64) ? get_i64_type() : get_int_type();
                t = it->isIntegerTy(64) ? "i64" : "i32";
            }
            else if (!hasExplicitType && it->isStructTy())
            {
                ty = it;
                if (auto *st = llvm::dyn_cast<llvm::StructType>(it))
                {
                    if (st->hasName())
                        t = st->getName().str();
                }
            }

            if (hasExplicitType && is_none_literal_expr(vd->init.get()) && !ty->isPointerTy())
            {
                error("none can only initialize pointer or string variables");
                return nullptr;
            }

            Value *alloca = create_entry_alloca(F, ty, vd->name);
            bind_local_const(vd->name, t, alloca, vd->is_const);

            Value *storeVal = initV;
            if (storeVal->getType() != ty)
            {
                if (storeVal->getType()->isFloatingPointTy() && ty->isIntegerTy())
                    storeVal = builder.CreateFPToSI(storeVal, ty);
                else if (storeVal->getType()->isIntegerTy() && ty->isFloatingPointTy())
                    storeVal = builder.CreateSIToFP(storeVal, ty);
                else if (storeVal->getType()->isIntegerTy() && ty->isIntegerTy())
                    storeVal = builder.CreateIntCast(storeVal, ty, true);
                else
                {
                    if (storeVal->getType()->isPointerTy() && ty->isPointerTy() && storeVal->getType() != ty)
                        storeVal = builder.CreateBitCast(storeVal, ty);
                }
            }
            builder.CreateStore(storeVal, alloca);
            return alloca;
        }
    }
    else
    {
        Value *alloca = create_entry_alloca(F, ty, vd->name);
        builder.CreateStore(Constant::getNullValue(ty), alloca);
        bind_local_const(vd->name, t, alloca, vd->is_const);
        return alloca;
    }
}

}
