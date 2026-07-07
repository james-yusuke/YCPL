#include "codegen.h"
#include "types/type_shape.h"
#include "common.h"

namespace codegen
{
    void CodeGen::push_scope()
    {
        locals_stack_const.emplace_back();
        locals_stack_type.emplace_back();
        locals_stack.emplace_back();
    }

    void CodeGen::pop_scope()
    {
        if (!locals_stack.empty())
            locals_stack.pop_back();
        if (!locals_stack_type.empty())
            locals_stack_type.pop_back();
        if (!locals_stack_const.empty())
            locals_stack_const.pop_back();
    }

    void CodeGen::emit_deferred_statements()
    {
        if (emitting_deferred)
            return;
        if (!builder.GetInsertBlock() || builder.GetInsertBlock()->getTerminator())
            return;

        emitting_deferred = true;
        for (int i = static_cast<int>(deferred_stmts.size()) - 1; i >= 0; --i)
        {
            const ast::Stmt *stmt = deferred_stmts[static_cast<size_t>(i)];
            if (stmt && !builder.GetInsertBlock()->getTerminator())
                codegen_stmt(stmt);
        }
        emitting_deferred = false;
    }

    void CodeGen::bind_local(const std::string &name, const std::string type, llvm::Value *v)
    {
        bind_local_const(name, type, v, false);
    }

    void CodeGen::bind_local_const(const std::string &name, const std::string type, llvm::Value *v, bool is_const)
    {
        if (locals_stack.empty() || locals_stack_type.empty())
            push_scope();
        locals_stack.back()[name] = v;
        locals_stack_type.back()[name] = type;
        locals_stack_const.back()[name] = is_const;
    }

    std::string *CodeGen::lookup_local_type(const std::string &name)
    {
        for (int i = static_cast<int>(locals_stack_type.size()) - 1; i >= 0; --i)
        {
            auto &m = locals_stack_type[i];
            auto it = m.find(name);
            if (it != m.end())
                return &it->second;
        }

        return nullptr;
    }

    std::string CodeGen::infer_expr_type_name(const ast::Expr *expr)
    {
        if (!expr)
            return "";

        if (auto id = dynamic_cast<const ast::Ident *>(expr))
        {
            if (auto *ty = lookup_local_type(id->name))
                return *ty;
            return "";
        }

        if (auto member = dynamic_cast<const ast::MemberExpr *>(expr))
        {
            std::string objectType = infer_expr_type_name(member->object.get());
            auto pt = parse_type_shape(objectType);
            auto it = struct_decls.find(pt.base);
            if (it == struct_decls.end() || !it->second)
                return "";

            for (const auto &field : it->second->fields)
            {
                if (field && field->name == member->member)
                    return resolve_type_name(const_cast<ast::Type *>(field->type.get()));
            }
        }

        return "";
    }

    bool CodeGen::is_local_const(const std::string &name)
    {
        for (int i = static_cast<int>(locals_stack_const.size()) - 1; i >= 0; --i)
        {
            auto &m = locals_stack_const[i];
            auto it = m.find(name);
            if (it != m.end())
                return it->second;
        }
        return false;
    }

    llvm::Value *CodeGen::lookup_local(const std::string &name)
    {
        for (int i = static_cast<int>(locals_stack.size()) - 1; i >= 0; --i)
        {
            auto &m = locals_stack[i];
            auto it = m.find(name);
            if (it != m.end())
                return it->second;
        }

        auto fIt = function_protos.find(name);
        if (fIt != function_protos.end())
            return fIt->second;
        return nullptr;
    }
}
