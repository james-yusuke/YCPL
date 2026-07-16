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
        locals_stack_runtime_depth.push_back(runtime_scope_depth);
        deferred_scopes.emplace_back();
    }

    void CodeGen::pop_scope()
    {
        emit_current_deferred_statements();
        if (!deferred_scopes.empty())
            deferred_scopes.pop_back();
        if (!locals_stack.empty())
            locals_stack.pop_back();
        if (!locals_stack_type.empty())
            locals_stack_type.pop_back();
        if (!locals_stack_const.empty())
            locals_stack_const.pop_back();
        if (!locals_stack_runtime_depth.empty())
            locals_stack_runtime_depth.pop_back();
    }

    void CodeGen::emit_deferred_scopes_to_depth(size_t keepDepth)
    {
        if (emitting_deferred)
            return;
        if (!builder.GetInsertBlock() || builder.GetInsertBlock()->getTerminator())
            return;

        emitting_deferred = true;
        if (keepDepth > deferred_scopes.size())
            keepDepth = deferred_scopes.size();

        for (int scopeIndex = static_cast<int>(deferred_scopes.size()) - 1; scopeIndex >= static_cast<int>(keepDepth); --scopeIndex)
        {
            auto &scopeDefers = deferred_scopes[static_cast<size_t>(scopeIndex)];
            for (int stmtIndex = static_cast<int>(scopeDefers.size()) - 1; stmtIndex >= 0; --stmtIndex)
            {
                const ast::Stmt *stmt = scopeDefers[static_cast<size_t>(stmtIndex)];
                if (stmt && !builder.GetInsertBlock()->getTerminator())
                    codegen_stmt(stmt);
            }
            scopeDefers.clear();
        }
        emitting_deferred = false;
    }

    void CodeGen::emit_current_deferred_statements()
    {
        if (deferred_scopes.empty())
            return;
        emit_deferred_scopes_to_depth(deferred_scopes.size() - 1);
    }

    void CodeGen::emit_deferred_statements()
    {
        emit_deferred_scopes_to_depth(0);
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

    size_t CodeGen::local_scope_escape_levels(const std::string &name) const
    {
        if (locals_stack.empty())
            return 0;
        for (int i = static_cast<int>(locals_stack.size()) - 1; i >= 0; --i)
        {
            if (locals_stack[static_cast<size_t>(i)].find(name) != locals_stack[static_cast<size_t>(i)].end())
            {
                size_t targetDepth = i < static_cast<int>(locals_stack_runtime_depth.size())
                    ? locals_stack_runtime_depth[static_cast<size_t>(i)]
                    : runtime_scope_depth;
                return runtime_scope_depth > targetDepth ? runtime_scope_depth - targetDepth : 0;
            }
        }
        return 0;
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

        if (auto literal = dynamic_cast<const ast::Literal *>(expr))
        {
            switch (literal->t)
            {
            case lex::TokenType::INT:
                return "i32";
            case lex::TokenType::FLOAT:
                return "double";
            case lex::TokenType::CHAR:
                return "char";
            case lex::TokenType::STRING:
                return "string";
            case lex::TokenType::BOOL:
                return "bool";
            case lex::TokenType::NONE:
                return "none";
            default:
                return "";
            }
        }

        if (auto structure = dynamic_cast<const ast::StructLiteral *>(expr))
            return resolve_type_name(const_cast<ast::Type *>(structure->type.get()));

        if (auto vec = dynamic_cast<const ast::VecLiteral *>(expr))
            return "Vec<" + resolve_type_name(vec->elem_type.get()) + ">";

        if (auto call = dynamic_cast<const ast::CallExpr *>(expr))
        {
            if (auto calleeIdent = dynamic_cast<const ast::Ident *>(call->callee.get()))
            {
                auto result = function_return_types.find(calleeIdent->name);
                if (result != function_return_types.end())
                    return result->second;
            }
            if (auto calleeMember = dynamic_cast<const ast::MemberExpr *>(call->callee.get()))
            {
                TypeShape objectShape = parse_type_shape(infer_expr_type_name(calleeMember->object.get()));
                if (objectShape.is_vec_type())
                {
                    if (calleeMember->member == "as_slice")
                        return parse_type_shape(objectShape.vec_element).full_name() + "[]";
                    if (calleeMember->member == "push" || calleeMember->member == "len" || calleeMember->member == "capacity")
                        return "i32";
                }
            }
        }

        if (auto index = dynamic_cast<const ast::IndexExpr *>(expr))
        {
            TypeShape collectionShape = parse_type_shape(infer_expr_type_name(index->collection.get()));
            if (collectionShape.is_vec_type())
                return collectionShape.vec_element;
            if (collectionShape.is_array())
                return collectionShape.array_element_type_name();
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
