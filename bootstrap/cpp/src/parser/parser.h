#pragma once
#include "../lexer/token.h"
#include "../lexer/lexer.h"
#include "../ast/ast.h"
#include <memory>
#include <vector>
#include <string>
#include <functional>

namespace path
{
    using namespace lex;

    class Parser
    {
    public:
        Parser(Lexer &lx, std::function<void(int, int, const std::string &)> error_cb = nullptr);

        std::unique_ptr<ast::Program> parse_program();

    private:
        Lexer &lexer;
        Token cur;
        Token prev;
        std::function<void(int, int, const std::string &)> error_cb;
        int suppress_struct_literal_depth = 0;

        void advance();
        bool check(TokenType t) const;
        bool match(TokenType t);
        Token expect(TokenType t, const std::string &msg);
        void emit_error(const Token &at, const std::string &msg);

        void skip_newlines();

        std::unique_ptr<ast::Decl> parse_decl();
        std::unique_ptr<ast::Decl> parse_module_decl();
        std::unique_ptr<ast::Decl> parse_import_decl();
        std::unique_ptr<ast::Decl> parse_function_decl(bool is_pub, bool is_extern = false, bool is_intrinsic = false);
        std::unique_ptr<ast::Decl> parse_struct_decl(bool is_pub);
        std::unique_ptr<ast::Decl> parse_enum_decl(bool is_pub);
        std::unique_ptr<ast::Decl> parse_type_alias_decl(bool is_pub);

        std::unique_ptr<ast::Stmt> parse_stmt();
        std::unique_ptr<ast::Stmt> parse_switch_stmt();
        std::unique_ptr<ast::BlockStmt> parse_block();

        std::unique_ptr<ast::Stmt> parse_var_or_expr_stmt();

        std::unique_ptr<ast::Expr> parse_expression();
        std::unique_ptr<ast::Expr> parse_expression_without_struct_literals();
        std::unique_ptr<ast::Expr> parse_assignment();
        std::unique_ptr<ast::Expr> parse_logical_or();
        std::unique_ptr<ast::Expr> parse_logical_and();
        std::unique_ptr<ast::Expr> parse_equality();
        std::unique_ptr<ast::Expr> parse_comparison();
        std::unique_ptr<ast::Expr> parse_additive();
        std::unique_ptr<ast::Expr> parse_multiplicative();
        std::unique_ptr<ast::Expr> parse_unary();
        std::unique_ptr<ast::Expr> parse_primary();
        std::unique_ptr<ast::Expr> parse_array_literal();
        std::unique_ptr<ast::Expr> parse_byte_array_literal();
        std::unique_ptr<ast::Expr> parse_postfix(std::unique_ptr<ast::Expr> left);
        std::unique_ptr<ast::Expr> parse_call_arg_for(const ast::Expr *callee, size_t arg_index);
        std::unique_ptr<ast::Expr> parse_shift();
        std::unique_ptr<ast::Expr> parse_bitwise_and();
        std::unique_ptr<ast::Type> parse_type();

        bool is_at_end() const;
        Token peek_next();
    };

}
