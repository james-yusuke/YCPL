#include "codegen.h"

#include <llvm/IR/Constants.h>
#include <llvm/IR/DerivedTypes.h>

namespace codegen
{
    Value *CodeGen::codegen_expr(const ast::Expr *e)
    {
        if (!e)
            return nullptr;
        if (auto lit = dynamic_cast<const ast::Literal *>(e))
            return codegen_literal(lit);
        if (dynamic_cast<const ast::TypeExpr *>(e))
        {
            error("type expression is only valid in intrinsic calls");
            return nullptr;
        }
        if (auto id = dynamic_cast<const ast::Ident *>(e))
            return codegen_ident(id);
        if (auto ue = dynamic_cast<const ast::UnaryExpr *>(e))
            return codegen_unary(ue);
        if (auto be = dynamic_cast<const ast::BinaryExpr *>(e))
            return codegen_binary(be);
        if (auto ce = dynamic_cast<const ast::CallExpr *>(e))
            return codegen_call(ce);
        if (auto alit = dynamic_cast<const ast::ArrayLiteral *>(e))
            return codegen_array(alit);
        if (auto sl = dynamic_cast<const ast::StructLiteral *>(e))
            return codegen_struct_literal(sl);
        if (auto me = dynamic_cast<const ast::MemberExpr *>(e))
            return codegen_member(me);
        if (auto bal = dynamic_cast<const ast::ByteArrayLiteral *>(e))
            return codegen_byte_array(bal);
        if (auto pe = dynamic_cast<const ast::PostfixExpr *>(e))
            return codegen_postfix(pe);
        if (auto ie = dynamic_cast<const ast::IndexExpr *>(e))
            return codegen_index(ie);

        error("unhandled expr node");
        return nullptr;
    }

    Value *CodeGen::codegen_block(const ast::BlockStmt *blk)
    {
        if (!blk)
            return nullptr;
        for (const auto &s : blk->stmts)
            codegen_stmt(s.get());
        return nullptr;
    }

    Value *CodeGen::codegen_stmt(const ast::Stmt *s)
    {
        if (!s)
            return nullptr;
        if (auto es = dynamic_cast<const ast::ExprStmt *>(s))
            return codegen_expr(es->expr.get());

        if (auto rs = dynamic_cast<const ast::ReturnStmt *>(s))
        {
            Value *rv = nullptr;
            if (rs->expr)
                rv = codegen_expr(rs->expr.get());
            Function *F = builder.GetInsertBlock()->getParent();
            Type *retTy = F ? F->getReturnType() : nullptr;
            if (!rv)
            {
                if (retTy && !retTy->isVoidTy())
                {
                    error("non-void function requires a return value");
                    builder.CreateRet(Constant::getNullValue(retTy));
                }
                else
                    builder.CreateRetVoid();
            }
            else if (retTy && retTy->isVoidTy())
            {
                error("void function cannot return a value");
                builder.CreateRetVoid();
            }
            else
            {
                if (retTy && rv->getType() != retTy)
                {
                    if (rv->getType()->isIntegerTy() && retTy->isIntegerTy())
                        rv = builder.CreateSExtOrTrunc(rv, retTy, "return.intcast");
                    else if (rv->getType()->isIntegerTy() && retTy->isFloatingPointTy())
                        rv = builder.CreateSIToFP(rv, retTy, "return.sitofp");
                    else if (rv->getType()->isFloatingPointTy() && retTy->isIntegerTy())
                        rv = builder.CreateFPToSI(rv, retTy, "return.fptosi");
                    else if (rv->getType()->isPointerTy() && retTy->isPointerTy())
                        rv = builder.CreatePointerCast(rv, retTy, "return.ptrcast");
                    else if (rv->getType()->isPointerTy() && retTy->isIntegerTy())
                        rv = builder.CreatePtrToInt(rv, retTy, "return.ptrtoint");
                    else if (rv->getType()->isIntegerTy() && retTy->isPointerTy())
                        rv = builder.CreateIntToPtr(rv, cast<PointerType>(retTy), "return.inttoptr");
                    else if (retTy->isStructTy() && rv->getType()->isPointerTy())
                    {
                        auto *ptrTy = cast<PointerType>(rv->getType());
                        (void)ptrTy;
                        rv = builder.CreateLoad(retTy, rv, "return.load_struct");
                    }
                    else
                    {
                        error("return value type does not match function return type");
                        rv = Constant::getNullValue(retTy);
                    }
                }
                builder.CreateRet(rv);
            }
            return nullptr;
        }

        if (auto vd = dynamic_cast<const ast::VarDecl *>(s))
            return codegen_vardecl(vd);
        if (auto as = dynamic_cast<const ast::AssignStmt *>(s))
            return codegen_assign(as);
        if (auto ifs = dynamic_cast<const ast::IfStmt *>(s))
            return codegen_ifstmt(ifs);

        if (dynamic_cast<const ast::BreakStmt *>(s))
        {
            if (break_targets.empty())
            {
                error("break used outside of loop");
                return nullptr;
            }
            builder.CreateBr(break_targets.back());

            Function *F = builder.GetInsertBlock()->getParent();
            BasicBlock *cont = BasicBlock::Create(context, "after.break", F);
            builder.SetInsertPoint(cont);
            return nullptr;
        }

        if (dynamic_cast<const ast::ContinueStmt *>(s))
        {
            if (continue_targets.empty())
            {
                error("continue used outside of loop");
                return nullptr;
            }
            builder.CreateBr(continue_targets.back());
            Function *F = builder.GetInsertBlock()->getParent();
            BasicBlock *cont = BasicBlock::Create(context, "after.continue", F);
            builder.SetInsertPoint(cont);
            return nullptr;
        }

        if (auto forInStmt = dynamic_cast<const ast::ForInStmt *>(s))
            return codegen_for_in_loop(forInStmt);
        if (auto cStyleForStmt = dynamic_cast<const ast::ForCStyleStmt *>(s))
            return codegen_c_style_for_loop(cStyleForStmt);
        if (auto forStmt = dynamic_cast<const ast::ForStmt *>(s))
            return codegen_for_loop(forStmt);

        error("unhandled stmt type in codegen");
        return nullptr;
    }
}
