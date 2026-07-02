#include "ast.h"

namespace ast
{

    void NamedType::print(std::ostream &os, int indent) const
    {
        print_indent(os, indent);
        os << "NamedType(" << name << ")\n";
    }

    void PointerType::print(std::ostream &os, int indent) const
    {
        print_indent(os, indent);
        os << "PointerType[\n";
        if (base)
            base->print(os, indent + 2);
        print_indent(os, indent);
        os << "]\n";
    }

    void ArrayType::print(std::ostream &os, int indent) const
    {
        print_indent(os, indent);
        if (!is_slice)
        {
            os << "ArrayType[\n";
            if (elem)
                elem->print(os, indent + 2);

            print_indent(os, indent + 2);
            os << "size: " << size << "\n";
            print_indent(os, indent);
            os << "]\n";
        }
        else
        {
            os << "SliceType[\n";
            if (elem)
                elem->print(os, indent + 2);
            print_indent(os, indent);
            os << "]\n";
        }
    }

    void FuncType::print(std::ostream &os, int indent) const
    {
        print_indent(os, indent);
        os << "FuncType[\n";
        print_indent(os, indent + 2);
        os << "params:\n";
        for (const auto &p : params)
        {
            if (p)
                p->print(os, indent + 4);
        }
        print_indent(os, indent + 2);
        os << "ret:\n";
        if (ret)
            ret->print(os, indent + 4);
        print_indent(os, indent);
        os << "]\n";
    }

    void StructField::print(std::ostream &os, int indent) const
    {
        print_indent(os, indent);
        os << "StructField(" << name << ")\n";
        if (type)
        {
            print_indent(os, indent + 2);
            os << "type:\n";
            type->print(os, indent + 4);
        }
        if (inline_struct)
        {
            print_indent(os, indent + 2);
            os << "inline_struct:\n";
            inline_struct->print(os, indent + 4);
        }
    }

    void StructDecl::print(std::ostream &os, int indent) const
    {
        print_indent(os, indent);
        os << "StructDecl(" << name << ")\n";
        print_indent(os, indent + 2);
        os << "fields:\n";
        for (const auto &f : fields)
        {
            if (f)
                f->print(os, indent + 4);
        }
        if (!nested_decls.empty())
        {
            print_indent(os, indent + 2);
            os << "nested_decls:\n";
            for (const auto &d : nested_decls)
            {
                if (d)
                    d->print(os, indent + 4);
            }
        }
    }

    void Ident::print(std::ostream &os, int indent) const
    {
        print_indent(os, indent);
        os << "Ident(" << name << ")\n";
    }

    void Literal::print(std::ostream &os, int indent) const
    {
        print_indent(os, indent);
        os << "Literal(" << raw << ", token=" << static_cast<int>(t) << ")\n";
    }

    void TypeExpr::print(std::ostream &os, int indent) const
    {
        print_indent(os, indent);
        os << "TypeExpr\n";
        if (type)
            type->print(os, indent + 2);
    }

    void UnaryExpr::print(std::ostream &os, int indent) const
    {
        print_indent(os, indent);
        os << "UnaryExpr(" << op << ")\n";
        if (rhs)
            rhs->print(os, indent + 2);
    }

    void BinaryExpr::print(std::ostream &os, int indent) const
    {
        print_indent(os, indent);
        os << "BinaryExpr(" << op << ")\n";
        if (left)
            left->print(os, indent + 2);
        if (right)
            right->print(os, indent + 2);
    }

    void CallExpr::print(std::ostream &os, int indent) const
    {
        print_indent(os, indent);
        os << "CallExpr\n";
        if (callee)
            callee->print(os, indent + 2);
        if (!args.empty())
        {
            print_indent(os, indent + 2);
            os << "args:\n";
            for (const auto &a : args)
                if (a)
                    a->print(os, indent + 4);
        }
    }

    void ArrayLiteral::print(std::ostream &os, int indent) const
    {
        print_indent(os, indent);
        if (array_type)
        {
            os << "ArrayLiteral(type:\n";
            array_type->print(os, indent + 2);
            print_indent(os, indent + 0);
            os << "elements:\n";
        }
        else
        {
            os << "ArrayLiteral[\n";
        }
        for (const auto &e : elements)
            if (e)
                e->print(os, indent + 2);
        print_indent(os, indent);
        os << "]\n";
    }

    void ByteArrayLiteral::print(std::ostream &os, int indent) const
    {
        print_indent(os, indent);
        os << "ByteArrayLiteral[\n";
        for (const auto &e : elems)
        {
            e->print(os, indent + 2);
        }
        print_indent(os, indent);
        os << "]\n";
    }

    void MemberExpr::print(std::ostream &os, int indent) const
    {
        print_indent(os, indent);
        os << "MemberExpr(" << member << ")\n";
        if (object)
            object->print(os, indent + 2);
    }

    void IndexExpr::print(std::ostream &os, int indent) const
    {
        print_indent(os, indent);
        os << "IndexExpr\n";
        if (collection)
            collection->print(os, indent + 2);
        if (index)
            index->print(os, indent + 2);
    }

    void PostfixExpr::print(std::ostream &os, int indent) const
    {
        print_indent(os, indent);
        os << "PostfixExpr(" << op << ")\n";
        if (lhs)
            lhs->print(os, indent + 2);
    }

    void StructLiteral::print(std::ostream &os, int indent) const
    {
        print_indent(os, indent);
        os << "StructLiteral\n";
        if (type)
        {
            print_indent(os, indent + 2);
            os << "type:\n";
            type->print(os, indent + 4);
        }
        if (!inits.empty())
        {
            print_indent(os, indent + 2);
            os << "inits:\n";
            for (const auto &init : inits)
            {
                if (init.name.has_value())
                {
                    print_indent(os, indent + 4);
                    os << "field: " << init.name.value() << "\n";
                }
                if (init.value)
                    init.value->print(os, indent + 6);
            }
        }
    }

    void ExprStmt::print(std::ostream &os, int indent) const
    {
        print_indent(os, indent);
        os << "ExprStmt\n";
        if (expr)
            expr->print(os, indent + 2);
    }

    void ReturnStmt::print(std::ostream &os, int indent) const
    {
        print_indent(os, indent);
        os << "ReturnStmt\n";
        if (expr)
            expr->print(os, indent + 2);
    }

    void VarDecl::print(std::ostream &os, int indent) const
    {
        print_indent(os, indent);
        os << "VarDecl(" << name << ")\n";
        if (is_const || is_mut)
        {
            print_indent(os, indent + 2);
            os << (is_const ? "const" : "mut") << "\n";
        }
        if (type)
        {
            print_indent(os, indent + 2);
            os << "type:\n";
            type->print(os, indent + 4);
        }
        if (init)
        {
            print_indent(os, indent + 2);
            os << "init:\n";
            init->print(os, indent + 4);
        }
    }

    void AssignStmt::print(std::ostream &os, int indent) const
    {
        print_indent(os, indent);
        os << "AssignStmt(" << op << ")\n";
        if (target)
            target->print(os, indent + 2);
        if (value)
            value->print(os, indent + 2);
    }

    void BlockStmt::print(std::ostream &os, int indent) const
    {
        print_indent(os, indent);
        os << "BlockStmt\n";
        for (const auto &s : stmts)
            if (s)
                s->print(os, indent + 2);
    }

    void IfStmt::print(std::ostream &os, int indent) const
    {
        print_indent(os, indent);
        os << "IfStmt\n";
        if (cond)
            cond->print(os, indent + 2);
        if (then_blk)
            then_blk->print(os, indent + 2);
        if (else_blk)
            else_blk->print(os, indent + 2);
    }

    void ForInStmt::print(std::ostream &os, int indent) const
    {
        print_indent(os, indent);
        os << "ForInStmt(" << var << ")\n";
        if (var_type)
        {
            print_indent(os, indent + 2);
            os << "var_type:\n";
            var_type->print(os, indent + 4);
        }
        if (iterable)
        {
            print_indent(os, indent + 2);
            os << "iterable:\n";
            iterable->print(os, indent + 4);
        }
        if (body)
        {
            print_indent(os, indent + 2);
            os << "body:\n";
            body->print(os, indent + 4);
        }
    }

    void ForStmt::print(std::ostream &os, int indent) const
    {
        print_indent(os, indent);
        os << "ForStmt\n";
        if (body)
            body->print(os, indent + 2);
    }

    void ForCStyleStmt::print(std::ostream &os, int indent) const
    {
        print_indent(os, indent);
        os << "ForCStyleStmt\n";
        if (init)
            init->print(os, indent + 2);
        if (cond)
            cond->print(os, indent + 2);
        if (post)
            post->print(os, indent + 2);
        if (body)
            body->print(os, indent + 2);
    }

    void BreakStmt::print(std::ostream &os, int indent) const
    {
        print_indent(os, indent);
        os << "BreakStmt\n";
    }

    void ContinueStmt::print(std::ostream &os, int indent) const
    {
        print_indent(os, indent);
        os << "ContinueStmt\n";
    }

    void ModuleDecl::print(std::ostream &os, int indent) const
    {
        print_indent(os, indent);
        os << "ModuleDecl(" << name << ")\n";
    }

    void ImportDecl::print(std::ostream &os, int indent) const
    {
        print_indent(os, indent);
        os << "ImportDecl(" << path << ")\n";
    }

    void FuncDecl::print(std::ostream &os, int indent) const
    {
        print_indent(os, indent);
        os << "FuncDecl(" << name << ")\n";
        if (!params.empty())
        {
            print_indent(os, indent + 2);
            os << "params:\n";
            for (const auto &p : params)
            {
                print_indent(os, indent + 4);
                os << p.name << " :\n";
                os << int(p.variadic) << "\n";
                if (p.type)
                    p.type->print(os, indent + 6);
            }
        }
        if (ret_type)
        {
            print_indent(os, indent + 2);
            os << "ret_type:\n";
            ret_type->print(os, indent + 4);
        }
        if (is_pub)
        {
            print_indent(os, indent + 2);
            os << "pub\n";
        }
        if (is_extern)
        {
            print_indent(os, indent + 2);
            os << "extern";
            if (extern_name)
                os << " as " << *extern_name;
            os << "\n";
        }
        if (is_intrinsic)
        {
            print_indent(os, indent + 2);
            os << "intrinsic\n";
        }
        if (body)
        {
            print_indent(os, indent + 2);
            os << "body:\n";
            body->print(os, indent + 4);
        }
    }

    void StmtDecl::print(std::ostream &os, int indent) const
    {
        print_indent(os, indent);
        os << "StmtDecl\n";
        if (stmt)
            stmt->print(os, indent + 2);
    }

    void Program::print(std::ostream &os, int indent) const
    {
        print_indent(os, indent);
        os << "Program\n";
        for (const auto &d : decls)
            if (d)
                d->print(os, indent + 2);
    }

}
