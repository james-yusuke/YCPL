#pragma once
#include "../codegen.h"
#include "../common.h"
#include <llvm/IR/Constants.h>
#include <llvm/IR/DerivedTypes.h>
#include <llvm/IR/Intrinsics.h>
#include <functional>

namespace codegen
{

Value *CodeGen::codegen_assign(const ast::AssignStmt *as)
{
    Value *ptr = nullptr;

    auto e = as->target.get();

    if (!e)
        return nullptr;

    std::function<std::string(const ast::Expr *)> base_const_ident;
    base_const_ident = [&](const ast::Expr *expr) -> std::string
    {
        if (auto id = dynamic_cast<const ast::Ident *>(expr))
            return is_local_const(id->name) ? id->name : std::string();
        if (auto member = dynamic_cast<const ast::MemberExpr *>(expr))
            return base_const_ident(member->object.get());
        return "";
    };

    std::function<std::string(const ast::Expr *)> base_target_ident;
    base_target_ident = [&](const ast::Expr *expr) -> std::string
    {
        if (auto id = dynamic_cast<const ast::Ident *>(expr))
            return id->name;
        if (auto member = dynamic_cast<const ast::MemberExpr *>(expr))
            return base_target_ident(member->object.get());
        if (auto index = dynamic_cast<const ast::IndexExpr *>(expr))
            return base_target_ident(index->collection.get());
        return "";
    };

    auto escape_rhs_to_target_scope = [&](Value *value)
    {
        if (!value || as->op != "=")
            return;
        std::string targetName = base_target_ident(as->target.get());
        size_t levels = targetName.empty() ? 0 : local_scope_escape_levels(targetName);
        if (levels > 0)
            emit_runtime_escape_aggregate(value, levels);
    };

    std::string constName = base_const_ident(e);
    if (!constName.empty())
    {
        error("cannot assign to const binding: " + constName);
        return nullptr;
    }

    auto cast_for_store = [&](Value *value, Type *destTy) -> Value *
    {
        if (!value || !destTy || value->getType() == destTy)
            return value;

        if (value->getType()->isIntegerTy() && destTy->isPointerTy())
            return builder.CreateIntToPtr(value, cast<PointerType>(destTy), "assign_inttoptr");
        if (value->getType()->isPointerTy() && destTy->isIntegerTy())
            return builder.CreatePtrToInt(value, destTy, "assign_ptrtoint");
        if (value->getType()->isFloatingPointTy() && destTy->isIntegerTy())
            return builder.CreateFPToSI(value, destTy, "assign_fp2i");
        if (value->getType()->isIntegerTy() && destTy->isFloatingPointTy())
            return builder.CreateSIToFP(value, destTy, "assign_i2fp");
        if (value->getType()->isIntegerTy() && destTy->isIntegerTy())
            return builder.CreateIntCast(value, destTy, true, "assign_intcast");
        if (value->getType()->isPointerTy() && destTy->isPointerTy())
            return builder.CreateBitCast(value, destTy, "assign_bitcast");
        return value;
    };

    auto apply_compound = [&](Value *current, Value *rhs, const std::string &op) -> Value *
    {
        if (op == "=")
            return rhs;
        if (!current || !rhs)
            return nullptr;

        rhs = cast_for_store(rhs, current->getType());

        if (current->getType()->isFloatingPointTy())
        {
            if (op == "+")
                return builder.CreateFAdd(current, rhs, "compound.add");
            if (op == "-")
                return builder.CreateFSub(current, rhs, "compound.sub");
            if (op == "*")
                return builder.CreateFMul(current, rhs, "compound.mul");
            if (op == "/")
                return builder.CreateFDiv(current, rhs, "compound.div");
            if (op == "%")
                return builder.CreateFRem(current, rhs, "compound.rem");
        }
        else if (current->getType()->isIntegerTy())
        {
            if (op == "+")
                return builder.CreateAdd(current, rhs, "compound.add");
            if (op == "-")
                return builder.CreateSub(current, rhs, "compound.sub");
            if (op == "*")
                return builder.CreateMul(current, rhs, "compound.mul");
            if (op == "/")
                return builder.CreateSDiv(current, rhs, "compound.div");
            if (op == "%")
                return builder.CreateSRem(current, rhs, "compound.rem");
        }

        error("compound assignment requires integer or floating point target");
        return nullptr;
    };

    auto value_is_none = [&]() -> bool
    {
        auto lit = dynamic_cast<const ast::Literal *>(as->value.get());
        return lit && lit->t == lex::TokenType::NONE;
    };

    auto infer_index_store_type = [&](const ast::IndexExpr *ie) -> Type *
    {
        if (!ie)
            return nullptr;

        std::string collectionType;
        if (auto id = dynamic_cast<const ast::Ident *>(ie->collection.get()))
        {
            if (auto *localType = lookup_local_type(id->name))
                collectionType = *localType;
        }

        if (collectionType.empty())
            collectionType = infer_expr_type_name(ie->collection.get());
        if (collectionType.empty())
            return nullptr;

        TypeShape pt = parse_type_shape(collectionType);
        if (pt.is_scalar_string_like())
            return Type::getInt8Ty(context);

        if (pt.has_indirection())
        {
            Type *elemTy = resolve_llvm_type_name(pt.base);
            if (elemTy)
                return elemTy;
        }

        return nullptr;
    };

    if (auto ue = dynamic_cast<const ast::UnaryExpr *>(e))
    {
        if (ue->op == "&")
        {
            if (auto innerId = dynamic_cast<const ast::Ident *>(ue->rhs.get()))
            {
                ptr = lookup_local(innerId->name);
                if (!ptr)
                {
                    error("unknown identifier in & LHS: " + innerId->name);
                    return nullptr;
                }
            }
            else if (auto innerIe = dynamic_cast<const ast::IndexExpr *>(ue->rhs.get()))
            {
                ptr = codegen_index_addr(innerIe);
                if (!ptr)
                    return nullptr;
            }
            else
            {
                error("& LHS requires an identifier or index expression");
                return nullptr;
            }
        }

        else if (ue->op == "*")
        {

            Value *pval = codegen_expr(ue->rhs.get());
            if (!pval)
                return nullptr;
            if (!pval->getType()->isPointerTy())
            {
                error("* LHS requires pointer value");
                return nullptr;
            }

            if (auto *ai = dyn_cast<AllocaInst>(pval))
            {

                ptr = builder.CreateLoad(ai->getAllocatedType(), ai, "deref_load_ptr");
            }
            else if (auto *gv = dyn_cast<GlobalVariable>(pval))
            {

                ptr = builder.CreateLoad(gv->getValueType(), gv, "deref_load_ptr");
            }
            else
            {

                ptr = pval;
            }
        }

        else
        {
            error("unsupported unary on LHS: " + ue->op);
            return nullptr;
        }
    }

    else if (auto me = dynamic_cast<const ast::MemberExpr *>(as->target.get()))
    {
        Value *addr = codegen_member_addr(me);
        if (!addr)
            return nullptr;
        Value *rv = codegen_expr(as->value.get());
        if (!rv)
            return nullptr;

        llvm::Type *elemTy = nullptr;

        if (auto *ai = dyn_cast<AllocaInst>(addr))
        {
            elemTy = ai->getAllocatedType();
        }
        else if (auto *gv = dyn_cast<GlobalVariable>(addr))
        {
            elemTy = gv->getValueType();
        }
        else if (auto *gep = dyn_cast<GetElementPtrInst>(addr))
        {

            elemTy = gep->getResultElementType();
        }
        else if (addr->getType()->isPointerTy())
        {

            if (auto *pt = dyn_cast<PointerType>(addr->getType()))
            {

                elemTy = pt;
            }
        }

        if (!elemTy)
        {

            std::string addrTyStr;
            {
                std::string s;
                llvm::raw_string_ostream rso(s);
                addr->getType()->print(rso);
                addrTyStr = rso.str();
            }
            std::string rvTyStr;
            {
                std::string s;
                llvm::raw_string_ostream rso(s);
                rv->getType()->print(rso);
                rvTyStr = rso.str();
            }

            error("assign to member: cannot determine element type for member addr; addrType=" + addrTyStr + " rvType=" + rvTyStr);
            return nullptr;
        }

        if (rv->getType() != elemTy)
        {

            if (rv->getType()->isIntegerTy() && elemTy->isIntegerTy())
            {
                rv = builder.CreateIntCast(rv, elemTy, true /*isSigned*/, "cast_int_field");
            }

            else if (rv->getType()->isFloatingPointTy() && elemTy->isFloatingPointTy())
            {
                rv = builder.CreateFPExt(rv, elemTy, "cast_fp_field");
            }

            else if (rv->getType()->isIntegerTy() && elemTy->isFloatingPointTy())
            {
                rv = builder.CreateSIToFP(rv, elemTy, "int_to_fp_field");
            }

            else if (rv->getType()->isFloatingPointTy() && elemTy->isIntegerTy())
            {
                rv = builder.CreateFPToSI(rv, elemTy, "fp_to_int_field");
            }

            else if (rv->getType()->isPointerTy() && elemTy->isPointerTy())
            {
                if (rv->getType() != elemTy)
                    rv = builder.CreateBitCast(rv, elemTy, "bitcast_ptr_field");
            }

            else if (rv->getType()->isPointerTy() && elemTy->isStructTy())
            {

                rv = builder.CreateLoad(elemTy, rv, "load_struct_for_store");
            }
            else
            {
                std::string elemTyStr;
                {
                    std::string s;
                    llvm::raw_string_ostream rso(s);
                    elemTy->print(rso);
                    elemTyStr = rso.str();
                }

                std::string rvTyStr;
                {
                    std::string s;
                    llvm::raw_string_ostream rso(s);
                    rv->getType()->print(rso);
                    rvTyStr = rso.str();
                }
                error("assign to member: type mismatch (elem=" + elemTyStr + ", rhs=" + rvTyStr + ")");
                return nullptr;
            }
        }

        if (as->op != "=")
        {
            Value *current = builder.CreateLoad(elemTy, addr, "compound.member.current");
            rv = apply_compound(current, rv, as->op);
            if (!rv)
                return nullptr;
        }

        escape_rhs_to_target_scope(rv);
        builder.CreateStore(rv, addr);
        return rv;
    }

    else if (auto id = dynamic_cast<const ast::Ident *>(e))
    {
        ptr = lookup_local(id->name);
        if (!ptr)
        {
            return nullptr;
        }
    }
    else if (auto ie = dynamic_cast<const ast::IndexExpr *>(e))
    {
        ptr = codegen_index_addr(ie);
        if (!ptr)
        {
            return nullptr;
        }
    }
    else if (auto sl = dynamic_cast<const ast::StructLiteral *>(e))
    {
        ptr = codegen_struct_literal(sl);
        if (!ptr)
        {
            return nullptr;
        }
    }

    if (!ptr)
    {
        error("unsupported assignment target (could not resolve pointer)");
        return nullptr;
    }

    Value *rhs = codegen_expr(as->value.get());
    if (!rhs)
        return nullptr;

    Value *storePtr = nullptr;
    Type *destElemTy = nullptr;
    Value *pointeePtr = nullptr;

    if (auto *ai = dyn_cast<AllocaInst>(ptr))
    {
        if (auto ue = dynamic_cast<const ast::UnaryExpr *>(e); ue && ue->op == "*")
        {
            pointeePtr = builder.CreateLoad(ai->getAllocatedType(), ai, "deref_load_ptr");
        }
        else
        {
            destElemTy = ai->getAllocatedType();
            storePtr = ptr;
        }
    }
    else if (auto *gv = dyn_cast<GlobalVariable>(ptr))
    {
        if (auto ue = dynamic_cast<const ast::UnaryExpr *>(e); ue && ue->op == "*")
        {
            pointeePtr = builder.CreateLoad(gv->getValueType(), gv, "deref_load_ptr");
        }
        else
        {
            destElemTy = gv->getValueType();
            storePtr = ptr;
        }
    }
    else if (ptr->getType()->isPointerTy())
    {

        storePtr = ptr;
    }

    Value *storeVal = rhs;

    if (!destElemTy)
    {
        if (auto ie = dynamic_cast<const ast::IndexExpr *>(e))
            destElemTy = infer_index_store_type(ie);
    }

    if (destElemTy)
    {
        if (value_is_none() && !destElemTy->isPointerTy())
        {
            error("none can only be assigned to pointer or string variables");
            return nullptr;
        }

        if (as->op != "=")
        {
            Value *current = builder.CreateLoad(destElemTy, storePtr, "compound.current");
            storeVal = apply_compound(current, storeVal, as->op);
            if (!storeVal)
                return nullptr;
        }

        if (storeVal->getType() != destElemTy)
        {

            if (storeVal->getType()->isIntegerTy() && destElemTy->isPointerTy())
            {
                if (auto *CI = dyn_cast<ConstantInt>(storeVal))
                {

                    if (CI->isZero())
                    {
                        storeVal = ConstantPointerNull::get(cast<PointerType>(destElemTy));
                    }
                    else
                    {

                        storeVal = ConstantExpr::getIntToPtr(CI, cast<PointerType>(destElemTy));
                    }
                }
                else
                {

                    storeVal = builder.CreateIntToPtr(storeVal, cast<PointerType>(destElemTy), "assign_inttoptr");
                }
            }

            else if (storeVal->getType()->isPointerTy() && destElemTy->isIntegerTy())
            {
                storeVal = builder.CreatePtrToInt(storeVal, destElemTy, "assign_ptrtoint");
            }
            else if (storeVal->getType()->isFloatingPointTy() && destElemTy->isIntegerTy())
            {
                storeVal = builder.CreateFPToSI(storeVal, destElemTy, "assign_fp2i");
            }
            else if (storeVal->getType()->isIntegerTy() && destElemTy->isFloatingPointTy())
            {
                storeVal = builder.CreateSIToFP(storeVal, destElemTy, "assign_i2fp");
            }
            else if (storeVal->getType()->isIntegerTy() && destElemTy->isIntegerTy())
            {
                unsigned sb = storeVal->getType()->getIntegerBitWidth();
                unsigned db = destElemTy->getIntegerBitWidth();
                if (sb < db)
                    storeVal = builder.CreateSExt(storeVal, destElemTy, "assign_sext");
                else if (sb > db)
                    storeVal = builder.CreateTrunc(storeVal, destElemTy, "assign_trunc");
            }
            else if (storeVal->getType()->isPointerTy() && destElemTy->isPointerTy())
            {
                if (storeVal->getType() != destElemTy)
                    storeVal = builder.CreateBitCast(storeVal, destElemTy, "assign_bitcast");
            }
            else
            {
                std::string msg = "unsupported assignment type: ";
                std::string lhs_t;
                llvm::raw_string_ostream lss(lhs_t);
                destElemTy->print(lss);
                std::string rhs_t;
                llvm::raw_string_ostream rss(rhs_t);
                storeVal->getType()->print(rss);
                error(msg + "lhs=" + lss.str() + " rhs=" + rss.str());
                return nullptr;
            }
        }

        escape_rhs_to_target_scope(storeVal);
        builder.CreateStore(storeVal, storePtr);
        return nullptr;
    }

    if (pointeePtr)
    {

        PointerType *targetPtrTy = detail::getPtrTy(context);
        Value *lhsCast = pointeePtr;
        if (pointeePtr->getType() != targetPtrTy)
            lhsCast = builder.CreateBitCast(pointeePtr, targetPtrTy, "deref_ptr_bitcast");
        builder.CreateStore(storeVal, lhsCast);
        return nullptr;
    }

    if (storePtr && storePtr->getType()->isPointerTy())
    {
        if (as->op != "=")
        {
            Type *loadTy = storeVal->getType();
            Value *loadPtr = storePtr;
            PointerType *targetPtrTy = detail::getPtrTy(context);
            if (loadPtr->getType() != targetPtrTy)
                loadPtr = builder.CreateBitCast(loadPtr, targetPtrTy, "compound.ptr.bitcast");
            Value *current = builder.CreateLoad(loadTy, loadPtr, "compound.ptr.current");
            storeVal = apply_compound(current, storeVal, as->op);
            if (!storeVal)
                return nullptr;
        }

        if (storeVal->getType()->isPointerTy() && storeVal->getType() != storePtr->getType())
        {
            Value *vc = builder.CreateBitCast(storeVal, storePtr->getType(), "assign_ptr_bitcast_rhs");
            escape_rhs_to_target_scope(vc);
            builder.CreateStore(vc, storePtr);
            return nullptr;
        }

        PointerType *targetPtrTy = detail::getPtrTy(context);
        Value *lhsCast = storePtr;
        if (storePtr->getType() != targetPtrTy)
            lhsCast = builder.CreateBitCast(storePtr, targetPtrTy, "assign_ptr_bitcast");
        escape_rhs_to_target_scope(storeVal);
        builder.CreateStore(storeVal, lhsCast);
        return nullptr;
    }

    {
        std::string msg = "unsupported assignment target: ";
        std::string lhs_t;
        llvm::raw_string_ostream lss(lhs_t);
        ptr->getType()->print(lss);
        error(msg + lss.str());
        return nullptr;
    }
}

}
