#pragma once
#include "../lexer/token.h"
#include <memory>
#include <vector>
#include <string>
#include <iostream>
#include <optional>

namespace ast
{

    using TokenType = lex::TokenType;

    struct Node
    {
        virtual ~Node() = default;
        virtual void print(std::ostream &os, int indent = 0) const = 0;
    };

    inline void print_indent(std::ostream &os, int indent)
    {
        for (int i = 0; i < indent; ++i)
            os << ' ';
    }

    struct StructDecl;
    struct StructField;
    struct Expr;

    struct Type : Node
    {
        virtual ~Type() = default;
    };

    struct NamedType : Type
    {

        std::string name;
        NamedType(const std::string &n) : name(n) {}
        void print(std::ostream &os, int indent = 0) const override;
    };

    struct PointerType : Type
    {
        std::unique_ptr<Type> base;
        PointerType(std::unique_ptr<Type> b) : base(std::move(b)) {}
        void print(std::ostream &os, int indent = 0) const override;
    };

    struct ArrayType : Type
    {
        std::unique_ptr<Type> elem;
        bool is_slice = false;
        size_t size = 0;

        ArrayType(std::unique_ptr<Type> e, bool slice, size_t sz = 0)
            : elem(std::move(e)), is_slice(slice), size(sz) {}

        void print(std::ostream &os, int indent = 0) const override;
    };

    struct FuncType : Type
    {
        std::vector<std::unique_ptr<Type>> params;
        std::unique_ptr<Type> ret;

        FuncType(std::vector<std::unique_ptr<Type>> p, std::unique_ptr<Type> r)
            : params(std::move(p)), ret(std::move(r)) {}

        void print(std::ostream &os, int indent = 0) const override;
    };

    struct Decl : Node
    {
    };

    struct Expr : Node
    {
    };

    struct Stmt : Node
    {
    };

    struct StructField
    {
        std::string name;

        std::unique_ptr<Type> type;

        std::shared_ptr<StructDecl> inline_struct;
        bool is_pub = false;

        StructField() = default;
        StructField(const std::string &n, std::unique_ptr<Type> t)
            : name(n), type(std::move(t)) {}

        void print(std::ostream &os, int indent = 0) const;
    };

    struct StructDecl : Decl
    {
        std::string name;

        std::vector<std::shared_ptr<StructField>> fields;

        std::vector<std::unique_ptr<Decl>> nested_decls;
        bool is_pub = false;

        StructDecl(const std::string &n = "") : name(n) {}
        void print(std::ostream &os, int indent = 0) const override;
    };

    struct Ident : Expr
    {
        std::string name;
        Ident(const std::string &n) : name(n) {}
        void print(std::ostream &os, int indent = 0) const override;
    };

    struct Literal : Expr
    {
        std::string raw;
        TokenType t;
        Literal(const std::string &r, TokenType tt) : raw(r), t(tt) {}
        void print(std::ostream &os, int indent = 0) const override;
    };

    struct TypeExpr : Expr
    {
        std::unique_ptr<Type> type;
        TypeExpr(std::unique_ptr<Type> t) : type(std::move(t)) {}
        void print(std::ostream &os, int indent = 0) const override;
    };

    struct UnaryExpr : Expr
    {
        std::string op;
        std::unique_ptr<Expr> rhs;
        UnaryExpr(const std::string &o, std::unique_ptr<Expr> r) : op(o), rhs(std::move(r)) {}
        void print(std::ostream &os, int indent = 0) const override;
    };

    struct BinaryExpr : Expr
    {
        std::string op;
        std::unique_ptr<Expr> left, right;
        BinaryExpr(const std::string &o, std::unique_ptr<Expr> l, std::unique_ptr<Expr> r)
            : op(o), left(std::move(l)), right(std::move(r)) {}
        void print(std::ostream &os, int indent = 0) const override;
    };

    struct CallExpr : Expr
    {
        std::unique_ptr<Expr> callee;
        std::vector<std::unique_ptr<Expr>> args;
        CallExpr(std::unique_ptr<Expr> c, std::vector<std::unique_ptr<Expr>> a)
            : callee(std::move(c)), args(std::move(a)) {}
        void print(std::ostream &os, int indent = 0) const override;
    };

    struct ArrayLiteral : Expr
    {

        std::unique_ptr<Type> array_type;
        std::vector<std::unique_ptr<Expr>> elements;

        ArrayLiteral(std::vector<std::unique_ptr<Expr>> &&elems)
            : array_type(nullptr), elements(std::move(elems)) {}

        ArrayLiteral(std::unique_ptr<Type> t, std::vector<std::unique_ptr<Expr>> &&elems)
            : array_type(std::move(t)), elements(std::move(elems)) {}

        void print(std::ostream &os, int indent = 0) const override;
    };

    struct ByteArrayLiteral : Expr
    {
        std::vector<std::unique_ptr<Expr>> elems;

        ByteArrayLiteral(std::vector<std::unique_ptr<Expr>> &&e) : elems(std::move(e)) {}

        ByteArrayLiteral(const std::vector<uint8_t> &bytes)
        {
            elems.reserve(bytes.size());
            for (uint8_t b : bytes)
            {
                elems.emplace_back(
                    std::make_unique<Literal>(std::to_string(static_cast<int>(b)), TokenType::INT));
            }
        }

        void print(std::ostream &os, int indent = 0) const override;
    };

    struct MemberExpr : Expr
    {
        std::unique_ptr<Expr> object;
        std::string member;
        MemberExpr(std::unique_ptr<Expr> o, const std::string &m) : object(std::move(o)), member(m) {}
        MemberExpr() : object(nullptr), member() {}
        void print(std::ostream &os, int indent = 0) const override;
    };

    struct IndexExpr : Expr
    {
        std::unique_ptr<Expr> collection;
        std::unique_ptr<Expr> index;

        IndexExpr(std::unique_ptr<Expr> coll, std::unique_ptr<Expr> idx)
            : collection(std::move(coll)), index(std::move(idx)) {}
        void print(std::ostream &os, int indent = 0) const override;
    };

    struct PostfixExpr : Expr
    {
        std::string op;
        std::unique_ptr<Expr> lhs;
        PostfixExpr(const std::string &op_, std::unique_ptr<Expr> lhs_)
            : Expr(), op(op_), lhs(std::move(lhs_)) {}
        void print(std::ostream &os, int indent = 0) const override;
    };

    struct StructFieldInit
    {
        std::optional<std::string> name;
        std::unique_ptr<Expr> value;
        StructFieldInit(std::optional<std::string> n, std::unique_ptr<Expr> v) : name(n), value(std::move(v)) {}
    };

    struct StructLiteral : Expr
    {
        std::unique_ptr<Type> type;
        std::vector<StructFieldInit> inits;
        StructLiteral(std::unique_ptr<Type> t, std::vector<StructFieldInit> i) : type(std::move(t)), inits(std::move(i)) {}

        void print(std::ostream &os, int indent = 0) const override;
    };

    struct ExprStmt : Stmt
    {
        std::unique_ptr<Expr> expr;
        ExprStmt(std::unique_ptr<Expr> e) : expr(std::move(e)) {}
        void print(std::ostream &os, int indent = 0) const override;
    };

    struct ReturnStmt : Stmt
    {
        std::unique_ptr<Expr> expr;
        ReturnStmt(std::unique_ptr<Expr> e) : expr(std::move(e)) {}
        void print(std::ostream &os, int indent = 0) const override;
    };

    struct VarDecl : Stmt
    {
        std::string name;

        std::unique_ptr<Type> type;

        std::unique_ptr<Expr> init;
        bool is_const = false;
        bool is_mut = false;

        VarDecl(const std::string &n, std::unique_ptr<Expr> i) : name(n), type(nullptr), init(std::move(i)) {}

        VarDecl(const std::string &n, std::unique_ptr<Type> t, std::unique_ptr<Expr> i)
            : name(n), type(std::move(t)), init(std::move(i)) {}

        VarDecl(const std::string &n, std::unique_ptr<Type> t)
            : name(n), type(std::move(t)), init(nullptr) {}

        void print(std::ostream &os, int indent = 0) const override;
    };

    struct AssignStmt : Stmt
    {
        std::unique_ptr<Expr> target;
        std::unique_ptr<Expr> value;
        std::string op = "=";
        AssignStmt(std::unique_ptr<Expr> target_, std::unique_ptr<Expr> value_, const std::string &op_ = "=")
            : target(std::move(target_)), value(std::move(value_)), op(op_) {}
        void print(std::ostream &os, int indent = 0) const override;
    };

    struct BlockStmt : Stmt
    {
        std::vector<std::unique_ptr<Stmt>> stmts;
        void print(std::ostream &os, int indent = 0) const override;
    };

    struct IfStmt : Stmt
    {
        std::unique_ptr<Expr> cond;
        std::unique_ptr<BlockStmt> then_blk;
        std::unique_ptr<BlockStmt> else_blk;
        IfStmt(std::unique_ptr<Expr> c, std::unique_ptr<BlockStmt> t, std::unique_ptr<BlockStmt> e)
            : cond(std::move(c)), then_blk(std::move(t)), else_blk(std::move(e)) {}
        void print(std::ostream &os, int indent = 0) const override;
    };

    struct ForInStmt : Stmt
    {
        std::string var;

        std::unique_ptr<Type> var_type;

        std::unique_ptr<Expr> iterable;
        std::unique_ptr<BlockStmt> body;

        ForInStmt(const std::string &v, std::unique_ptr<Expr> it, std::unique_ptr<BlockStmt> b)
            : var(v), var_type(nullptr), iterable(std::move(it)), body(std::move(b)) {}

        ForInStmt(const std::string &v, std::unique_ptr<Type> vt, std::unique_ptr<Expr> it, std::unique_ptr<BlockStmt> b)
            : var(v), var_type(std::move(vt)), iterable(std::move(it)), body(std::move(b)) {}

        void print(std::ostream &os, int indent = 0) const override;
    };

    struct ForStmt : Stmt
    {
        std::unique_ptr<BlockStmt> body;
        ForStmt(std::unique_ptr<BlockStmt> b) : body(std::move(b)) {}
        void print(std::ostream &os, int indent = 0) const override;
    };

    struct ForCStyleStmt : Stmt
    {
        std::unique_ptr<Stmt> init;
        std::unique_ptr<Expr> cond;
        std::unique_ptr<Expr> post;
        std::unique_ptr<BlockStmt> body;

        ForCStyleStmt(std::unique_ptr<Stmt> init_,
                      std::unique_ptr<Expr> cond_,
                      std::unique_ptr<Expr> post_,
                      std::unique_ptr<BlockStmt> body_)
            : init(std::move(init_)), cond(std::move(cond_)), post(std::move(post_)), body(std::move(body_)) {}

        void print(std::ostream &os, int indent = 0) const override;
    };

    struct BreakStmt : Stmt
    {
        BreakStmt() {}
        void print(std::ostream &os, int indent = 0) const override;
    };

    struct ContinueStmt : Stmt
    {
        ContinueStmt() {}
        void print(std::ostream &os, int indent = 0) const override;
    };

    struct PackageDecl : Decl
    {
        std::string name;
        PackageDecl(const std::string &n) : name(n) {}
        void print(std::ostream &os, int indent = 0) const override;
    };

    using ModuleDecl = PackageDecl;

    struct ImportDecl : Decl
    {

        std::string path;

        std::vector<std::string> path_parts;

        std::optional<std::string> alias;

        ImportDecl(const std::string &p) : path(p) {}
        ImportDecl(const std::string &p, const std::optional<std::string> &a) : path(p), alias(a) {}

        void print(std::ostream &os, int indent = 0) const override;
    };

    struct Param
    {
        std::string name;
        std::unique_ptr<Type> type;
        bool variadic = false;

        Param(std::string n, std::unique_ptr<Type> t, bool v = false)
            : name(std::move(n)), type(std::move(t)), variadic(v) {}
    };

    struct FuncDecl : Decl
    {
        std::string name;
        std::string module_name;
        std::string link_name;
        std::optional<std::string> receiver_name;
        std::vector<Param> params;
        std::unique_ptr<Type> ret_type;
        bool is_pub = false;
        bool is_extern = false;
        bool is_intrinsic = false;
        std::optional<std::string> extern_name;
        std::unique_ptr<BlockStmt> body;

        FuncDecl(const std::string &n,
                 std::vector<Param> p,
                 std::unique_ptr<Type> r,
                 bool pub,
                 std::unique_ptr<BlockStmt> b,
                 bool ext = false,
                 bool intr = false,
                 std::optional<std::string> external = std::nullopt,
                 const std::optional<std::string> &recv = std::nullopt)
            : name(n), receiver_name(recv), params(std::move(p)), ret_type(std::move(r)), is_pub(pub), is_extern(ext), is_intrinsic(intr), extern_name(std::move(external)), body(std::move(b)) {}

        void print(std::ostream &os, int indent = 0) const override;
    };

    struct StmtDecl : Decl
    {
        std::unique_ptr<Stmt> stmt;
        StmtDecl(std::unique_ptr<Stmt> s) : stmt(std::move(s)) {}
        void print(std::ostream &os, int indent = 0) const override;
    };

    struct Program : Node
    {
        std::vector<std::unique_ptr<Decl>> decls;
        void print(std::ostream &os, int indent = 0) const override;
    };

    inline void print_expr_kind(const Expr *e, std::ostream &os = std::cout)
    {
        if (!e)
        {
            os << "Expr: <null>\n";
            return;
        }

        if (auto p = dynamic_cast<const Ident *>(e))
        {
            os << "Expr: Ident (name = \"" << p->name << "\")\n";
            return;
        }
        if (auto p = dynamic_cast<const Literal *>(e))
        {
            os << "Expr: Literal (raw = \"" << p->raw << "\"";
            os << ", token = " << static_cast<int>(p->t) << ")\n";
            return;
        }
        if (dynamic_cast<const TypeExpr *>(e))
        {
            os << "Expr: TypeExpr\n";
            return;
        }
        if (auto p = dynamic_cast<const UnaryExpr *>(e))
        {
            os << "Expr: UnaryExpr (op = \"" << p->op << "\")\n";
            return;
        }
        if (auto p = dynamic_cast<const BinaryExpr *>(e))
        {
            os << "Expr: BinaryExpr (op = \"" << p->op << "\")\n";
            return;
        }
        if (auto p = dynamic_cast<const CallExpr *>(e))
        {
            os << "Expr: CallExpr (args = " << p->args.size() << ")\n";
            return;
        }
        if (auto p = dynamic_cast<const ArrayLiteral *>(e))
        {
            os << "Expr: ArrayLiteral (elements = " << p->elements.size() << ")\n";
            return;
        }
        if (auto p = dynamic_cast<const ByteArrayLiteral *>(e))
        {
            os << "Expr: ByteArrayLiteral (elems = " << p->elems.size() << ")\n";
            return;
        }
        if (auto p = dynamic_cast<const MemberExpr *>(e))
        {
            os << "Expr: MemberExpr (member = \"" << p->member << "\")\n";
            return;
        }
        if (auto p = dynamic_cast<const IndexExpr *>(e))
        {
            os << "Expr: IndexExpr\n";
            return;
        }
        if (auto p = dynamic_cast<const PostfixExpr *>(e))
        {
            os << "Expr: PostfixExpr (op = \"" << p->op << "\")\n";
            return;
        }
        if (auto p = dynamic_cast<const StructLiteral *>(e))
        {
            os << "Expr: StructLiteral (fields = " << p->inits.size() << ")\n";
            return;
        }

        os << "Expr: <unknown concrete type>\n";
    }

    inline void print_expr_kind(const std::unique_ptr<Expr> &ue, std::ostream &os = std::cout)
    {
        print_expr_kind(ue.get(), os);
    }

}
