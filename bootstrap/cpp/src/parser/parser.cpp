#include "parser.h"
#include <iostream>
#include <sstream>
#include <cctype>
#include <memory>

static std::string decode_string_literal_content(const std::string &lexeme)
{
    if (lexeme.size() < 2)
        return "";

    char quote = lexeme.front();
    bool is_raw = (quote == '`');
    std::string out;
    if (is_raw)
    {
        if (lexeme.size() >= 2)
            out = lexeme.substr(1, lexeme.size() - 2);
        return out;
    }

    size_t i = 1;
    size_t end = lexeme.size() - 1;
    while (i < end)
    {
        char c = lexeme[i++];
        if (c == '\\' && i < end)
        {
            char esc = lexeme[i++];
            switch (esc)
            {
            case 'n':
                out.push_back('\n');
                break;
            case 'r':
                out.push_back('\r');
                break;
            case 't':
                out.push_back('\t');
                break;
            case '\\':
                out.push_back('\\');
                break;
            case '"':
                out.push_back('"');
                break;
            case '\'':
                out.push_back('\'');
                break;
            case 'x':
            {
                int val = 0;
                int digits = 0;
                while (i < end && digits < 2 && std::isxdigit(static_cast<unsigned char>(lexeme[i])))
                {
                    char hx = lexeme[i++];
                    val <<= 4;
                    if (hx >= '0' && hx <= '9')
                        val += hx - '0';
                    else if (hx >= 'a' && hx <= 'f')
                        val += 10 + (hx - 'a');
                    else if (hx >= 'A' && hx <= 'F')
                        val += 10 + (hx - 'A');
                    ++digits;
                }
                out.push_back(static_cast<char>(val & 0xFF));
                break;
            }
            default:
                out.push_back(esc);
                break;
            }
        }
        else
        {
            out.push_back(c);
        }
    }
    return out;
}

namespace path
{
    using namespace ast;
    using namespace lex;

    static std::string callee_path_for_parser(const ast::Expr *expr)
    {
        if (auto id = dynamic_cast<const ast::Ident *>(expr))
        {
            return id->name;
        }
        if (auto member = dynamic_cast<const ast::MemberExpr *>(expr))
        {
            std::string base = callee_path_for_parser(member->object.get());
            if (base.empty())
                return member->member;
            return base + "." + member->member;
        }
        return "";
    }

    static bool ends_with_for_parser(const std::string &value, const std::string &suffix)
    {
        return value.size() >= suffix.size() && value.compare(value.size() - suffix.size(), suffix.size(), suffix) == 0;
    }

    Parser::Parser(Lexer &lx, std::function<void(int, int, const std::string &)> error_cb_)
        : lexer(lx), error_cb(error_cb_)
    {
        cur = lexer.next_token();
    }

    void Parser::advance()
    {
        prev = cur;
        cur = lexer.next_token();
    }

    bool Parser::check(TokenType t) const
    {
        return cur.type == t;
    }

    bool Parser::match(TokenType t)
    {
        if (check(t))
        {
            advance();
            return true;
        }
        return false;
    }

    Token Parser::expect(TokenType t, const std::string &msg)
    {
        if (check(t))
        {
            Token got = cur;
            advance();
            return got;
        }
        emit_error(cur, msg);
        return Token{t, "", cur.start, cur.end};
    }

    void Parser::emit_error(const Token &at, const std::string &msg)
    {
        if (error_cb)
        {
            error_cb(at.start.line, at.start.column, msg);
        }
        else
        {
            std::cerr << "[parser error] " << at.start.line << ":" << at.start.column << " " << msg << "\n";
        }
    }

    bool Parser::is_at_end() const
    {
        return cur.type == TokenType::EOF_TOKEN;
    }

    Token Parser::peek_next()
    {
        return lexer.peek(1);
    }

    void Parser::skip_newlines()
    {
        while (match(TokenType::NEWLINE))
        {
        }
    }

    std::unique_ptr<Program> Parser::parse_program()
    {
        auto prog = std::make_unique<Program>();

        while (!is_at_end())
        {
            if (check(TokenType::KW_MODULE) || check(TokenType::KW_PACKAGE))
            {
                auto d = parse_module_decl();
                if (d)
                    prog->decls.push_back(std::move(d));
                skip_newlines();
                continue;
            }

            if (check(TokenType::KW_IMPORT))
            {
                auto d = parse_import_decl();
                if (d)
                    prog->decls.push_back(std::move(d));
                skip_newlines();
                continue;
            }

            auto d = parse_decl();
            if (d)
                prog->decls.push_back(std::move(d));
            skip_newlines();
        }
        return prog;
    }

    std::unique_ptr<Decl> Parser::parse_decl()
    {
        bool is_pub = false;
        if (check(TokenType::KW_PUB))
        {
            is_pub = true;
            advance();
        }

        if (check(TokenType::KW_STRUCT))
        {
            return parse_struct_decl(is_pub);
        }

        if (check(TokenType::KW_ENUM))
        {
            return parse_enum_decl(is_pub);
        }

        if (check(TokenType::KW_TYPE))
        {
            return parse_type_alias_decl(is_pub);
        }

        bool is_extern = false;
        bool is_intrinsic = false;
        if (check(TokenType::KW_EXTERN) || check(TokenType::KW_INTRINSIC))
        {
            is_extern = check(TokenType::KW_EXTERN);
            is_intrinsic = check(TokenType::KW_INTRINSIC);
            advance();
        }

        if (check(TokenType::KW_FN))
        {
            return parse_function_decl(is_pub, is_extern, is_intrinsic);
        }

        auto stmt = parse_stmt();
        if (stmt)
        {
            return std::make_unique<StmtDecl>(std::move(stmt));
        }
        return nullptr;
    }

    std::unique_ptr<Decl> Parser::parse_module_decl()
    {
        if (check(TokenType::KW_MODULE))
            advance();
        else if (check(TokenType::KW_PACKAGE))
            advance();
        else
        {
            emit_error(cur, "expected 'module' or 'package'");
            return nullptr;
        }

        std::string full;
        Token t = expect(TokenType::IDENT, "expected module/package name");
        full = t.lexeme;
        while (match(TokenType::DOT))
        {
            Token part = expect(TokenType::IDENT, "expected identifier in module/package name");
            full += ".";
            full += part.lexeme;
        }

        match(TokenType::NEWLINE);

        return std::make_unique<ModuleDecl>(full);
    }

    std::unique_ptr<Decl> Parser::parse_import_decl()
    {
        expect(TokenType::KW_IMPORT, "expected 'import'");

        std::string full;
        std::vector<std::string> parts;

        if (check(TokenType::STRING))
        {
            Token strTk = cur;
            advance();
            std::string raw = strTk.lexeme;
            if (raw.size() >= 2 && raw.front() == '"' && raw.back() == '"')
            {
                full = raw.substr(1, raw.size() - 2);
            }
            else
            {
                full = raw;
            }
            size_t start = 0;
            size_t pos = full.find('/');
            while (pos != std::string::npos)
            {
                parts.push_back(full.substr(start, pos - start));
                start = pos + 1;
                pos = full.find('/', start);
            }
            parts.push_back(full.substr(start));
        }
        else
        {
            Token first = expect(TokenType::IDENT, "expected import path");
            full = first.lexeme;
            parts.push_back(first.lexeme);

            while (match(TokenType::DOT))
            {
                Token p = expect(TokenType::IDENT, "expected identifier in import path");
                full += ".";
                full += p.lexeme;
                parts.push_back(p.lexeme);
            }
        }

        std::optional<std::string> alias = std::nullopt;
        if (check(TokenType::KW_AS))
        {
            advance();
            Token aliasTk = expect(TokenType::IDENT, "expected alias after 'as'");
            alias = aliasTk.lexeme;
        }

        match(TokenType::NEWLINE);

        auto imp = std::make_unique<ImportDecl>(full, alias);
        imp->path_parts = std::move(parts);
        return imp;
    }

    std::unique_ptr<BlockStmt> Parser::parse_block()
    {
        expect(TokenType::LBRACE, "expected '{' to start block");
        auto blk = std::make_unique<BlockStmt>();
        skip_newlines();
        while (!check(TokenType::RBRACE) && !is_at_end())
        {
            auto s = parse_stmt();
            if (s)
                blk->stmts.push_back(std::move(s));
            skip_newlines();
        }
        expect(TokenType::RBRACE, "expected '}' to end block");
        return blk;
    }

    std::unique_ptr<Stmt> Parser::parse_switch_stmt()
    {
        expect(TokenType::KW_SWITCH, "expected 'switch'");
        auto value = parse_expression_without_struct_literals();
        expect(TokenType::LBRACE, "expected '{' to start switch");

        std::vector<SwitchCase> cases;
        std::unique_ptr<BlockStmt> defaultBody = nullptr;

        skip_newlines();
        while (!check(TokenType::RBRACE) && !is_at_end())
        {
            if (!check(TokenType::IDENT))
            {
                emit_error(cur, "expected 'case' or 'default' in switch");
                advance();
                skip_newlines();
                continue;
            }

            Token label = cur;
            advance();

            if (label.lexeme == "case")
            {
                auto caseValue = parse_expression_without_struct_literals();
                auto caseBody = parse_block();
                cases.emplace_back(std::move(caseValue), std::move(caseBody));
            }
            else if (label.lexeme == "default")
            {
                if (defaultBody)
                {
                    emit_error(label, "duplicate default in switch");
                }
                defaultBody = parse_block();
            }
            else
            {
                emit_error(label, "expected 'case' or 'default' in switch");
                if (check(TokenType::LBRACE))
                    parse_block();
            }

            skip_newlines();
        }

        expect(TokenType::RBRACE, "expected '}' to close switch");
        return std::make_unique<SwitchStmt>(std::move(value), std::move(cases), std::move(defaultBody));
    }

    std::unique_ptr<Stmt> Parser::parse_stmt()
    {
        skip_newlines();

        if (check(TokenType::KW_BREAK))
        {
            advance();
            match(TokenType::NEWLINE);
            return std::make_unique<BreakStmt>();
        }

        if (check(TokenType::KW_CONTINUE))
        {
            advance();
            match(TokenType::NEWLINE);
            return std::make_unique<ContinueStmt>();
        }

        if (check(TokenType::KW_RETURN))
        {
            advance();
            std::unique_ptr<Expr> expr = nullptr;
            if (!check(TokenType::NEWLINE) && !check(TokenType::RBRACE) && !check(TokenType::EOF_TOKEN))
                expr = parse_expression();
            match(TokenType::NEWLINE);
            return std::make_unique<ReturnStmt>(std::move(expr));
        }

        if (check(TokenType::KW_IF))
        {
            advance();
            std::unique_ptr<Expr> cond;
            if (check(TokenType::IDENT) && lexer.peek(1).type == TokenType::LBRACE)
            {
                Token id = cur;
                advance();
                cond = std::make_unique<Ident>(id.lexeme);
            }
            else
            {
                cond = parse_expression_without_struct_literals();
            }
            auto then_blk = parse_block();
            std::unique_ptr<BlockStmt> else_blk = nullptr;
            if (check(TokenType::KW_ELSE))
            {
                advance();
                if (check(TokenType::LBRACE))
                {
                    else_blk = parse_block();
                }
                else if (check(TokenType::KW_IF))
                {
                    auto nested_if = parse_stmt();
                    auto tempBlock = std::make_unique<BlockStmt>();
                    tempBlock->stmts.push_back(std::move(nested_if));
                    else_blk = std::move(tempBlock);
                }
            }
            return std::make_unique<IfStmt>(std::move(cond), std::move(then_blk), std::move(else_blk));
        }

        if (check(TokenType::KW_SWITCH))
        {
            return parse_switch_stmt();
        }

        if (check(TokenType::KW_FOR))
        {
            advance();

            if (check(TokenType::LPAREN))
            {
                advance();

                std::unique_ptr<Stmt> initStmt = nullptr;
                if (!check(TokenType::SEMICOLON))
                {

                    if (check(TokenType::IDENT) && lexer.peek(1).type == TokenType::COLON)
                    {
                        Token id = cur;
                        advance();
                        advance();
                        std::unique_ptr<ast::Type> annotated_type = parse_type();

                        if (check(TokenType::ASSIGN) && (cur.lexeme == ":=" || cur.lexeme == "="))
                        {
                            advance();
                            auto rhs = parse_expression();
                            initStmt = std::make_unique<VarDecl>(id.lexeme, std::move(annotated_type), std::move(rhs));
                        }
                        else
                        {
                            emit_error(cur, "expected ':=' or '=' after type annotation in for-init");
                            initStmt = std::make_unique<VarDecl>(id.lexeme, std::move(annotated_type), std::make_unique<Literal>("", TokenType::ILLEGAL));
                        }
                    }

                    else if (check(TokenType::IDENT) && lexer.peek(1).type == TokenType::ASSIGN && lexer.peek(1).lexeme == ":=")
                    {
                        Token id = cur;
                        advance();
                        advance();
                        auto rhs = parse_expression();
                        initStmt = std::make_unique<VarDecl>(id.lexeme, std::move(rhs));
                    }
                    else
                    {

                        auto e = parse_expression();
                        initStmt = std::make_unique<ExprStmt>(std::move(e));
                    }
                }
                expect(TokenType::SEMICOLON, "expected ';' after for-init");

                std::unique_ptr<Expr> condExpr = nullptr;
                if (!check(TokenType::SEMICOLON))
                {
                    condExpr = parse_expression();
                }
                expect(TokenType::SEMICOLON, "expected ';' after for-cond");

                std::unique_ptr<Expr> postExpr = nullptr;
                if (!check(TokenType::RPAREN))
                {
                    postExpr = parse_expression();
                }
                expect(TokenType::RPAREN, "expected ')' after for clauses");

                auto body = parse_block();
                return std::make_unique<ForCStyleStmt>(std::move(initStmt), std::move(condExpr), std::move(postExpr), std::move(body));
            }

            if (check(TokenType::IDENT))
            {
                Token id = cur;
                advance();
                expect(TokenType::KW_IN, "expected 'in' in for loop");
                std::unique_ptr<Expr> iterable;
                if (check(TokenType::IDENT) && lexer.peek(1).type == TokenType::LBRACE)
                {
                    Token iterableId = cur;
                    advance();
                    iterable = std::make_unique<Ident>(iterableId.lexeme);
                }
                else
                {
                    iterable = parse_expression_without_struct_literals();
                }
                auto body = parse_block();
                return std::make_unique<ForInStmt>(id.lexeme, std::move(iterable), std::move(body));
            }
            else
            {
                auto body = parse_block();
                return std::make_unique<ForStmt>(std::move(body));
            }
        }

        if (check(TokenType::KW_CONST))
        {
            advance();

            Token id = expect(TokenType::IDENT, "expected identifier after 'const'");
            std::unique_ptr<ast::Type> annotated_type = nullptr;

            if (check(TokenType::COLON))
            {
                advance();
                annotated_type = parse_type();
            }

            if (check(TokenType::ASSIGN) && (cur.lexeme == ":=" || cur.lexeme == "="))
            {
                advance();
                auto rhs = parse_expression();
                match(TokenType::NEWLINE);
                auto decl = annotated_type
                                ? std::make_unique<VarDecl>(id.lexeme, std::move(annotated_type), std::move(rhs))
                                : std::make_unique<VarDecl>(id.lexeme, std::move(rhs));
                decl->is_const = true;
                return decl;
            }

            emit_error(cur, "expected ':=' or '=' after const declaration");
            return nullptr;
        }

        if (check(TokenType::LBRACE))
        {
            return parse_block();
        }

        auto lhs = parse_expression();

        if (auto ident = dynamic_cast<Ident *>(lhs.get()))
        {
            if (check(TokenType::COLON))
            {
                advance();

                std::unique_ptr<ast::Type> annotated_type = parse_type();

                if (check(TokenType::ASSIGN) && (cur.lexeme == ":=" || cur.lexeme == "="))
                {
                    Token assignTk = cur;
                    advance();
                    auto rhs = parse_expression();
                    match(TokenType::NEWLINE);

                    return std::make_unique<VarDecl>(ident->name, std::move(annotated_type), std::move(rhs));
                }
                else
                {
                    emit_error(cur, "expected ':=' or '=' after type annotation in variable declaration");
                    return nullptr;
                }
            }
        }

        if (check(TokenType::ASSIGN) || check(TokenType::PLUS_ASSIGN) || check(TokenType::MINUS_ASSIGN) ||
            check(TokenType::MUL_ASSIGN) || check(TokenType::DIV_ASSIGN) || check(TokenType::MOD_ASSIGN))
        {
            Token assignTk = cur;
            std::string op = assignTk.lexeme;
            advance();

            auto rhs = parse_expression();
            match(TokenType::NEWLINE);

            if (op == ":=")
            {
                if (auto ident = dynamic_cast<Ident *>(lhs.get()))
                {
                    return std::make_unique<VarDecl>(ident->name, std::move(rhs));
                }
                else
                {
                    emit_error(assignTk, "':=' can only be used with an identifier on the left-hand side");
                    return nullptr;
                }
            }
            else
            {
                if (op == "+=")
                    op = "+";
                else if (op == "-=")
                    op = "-";
                else if (op == "*=")
                    op = "*";
                else if (op == "/=")
                    op = "/";
                else if (op == "%=")
                    op = "%";
                else
                    op = "=";
                return std::make_unique<AssignStmt>(std::move(lhs), std::move(rhs), op);
            }
        }

        match(TokenType::NEWLINE);
        return std::make_unique<ExprStmt>(std::move(lhs));
    }

    std::unique_ptr<Expr> Parser::parse_expression()
    {
        return parse_logical_or();
    }

    std::unique_ptr<Expr> Parser::parse_expression_without_struct_literals()
    {
        ++suppress_struct_literal_depth;
        auto expr = parse_expression();
        --suppress_struct_literal_depth;
        return expr;
    }

    std::unique_ptr<Expr> Parser::parse_logical_or()
    {
        auto left = parse_logical_and();
        while (check(TokenType::OR))
        {
            Token op = cur;
            advance();
            auto right = parse_logical_and();
            left = std::make_unique<BinaryExpr>(op.lexeme, std::move(left), std::move(right));
        }
        return left;
    }

    std::unique_ptr<Expr> Parser::parse_logical_and()
    {
        auto left = parse_bitwise_or();
        while (check(TokenType::AND))
        {
            Token op = cur;
            advance();
            auto right = parse_bitwise_or();
            left = std::make_unique<BinaryExpr>(op.lexeme, std::move(left), std::move(right));
        }
        return left;
    }

    std::unique_ptr<Expr> Parser::parse_bitwise_or()
    {
        auto left = parse_bitwise_xor();
        while (check(TokenType::BIT_OR) || check(TokenType::PIPE))
        {
            Token op = cur;
            advance();
            auto right = parse_bitwise_xor();
            left = std::make_unique<BinaryExpr>(op.lexeme, std::move(left), std::move(right));
        }
        return left;
    }

    std::unique_ptr<Expr> Parser::parse_bitwise_xor()
    {
        auto left = parse_bitwise_and();
        while (check(TokenType::BIT_XOR) || check(TokenType::CARET))
        {
            Token op = cur;
            advance();
            auto right = parse_bitwise_and();
            left = std::make_unique<BinaryExpr>(op.lexeme, std::move(left), std::move(right));
        }
        return left;
    }

    std::unique_ptr<Expr> Parser::parse_bitwise_and()
    {

        auto left = parse_equality();

        while (check(TokenType::BIT_AND) || check(TokenType::ADDRESS_OF) || check(TokenType::AMP))
        {
            Token op = cur;
            advance();
            auto right = parse_equality();
            left = std::make_unique<BinaryExpr>(op.lexeme, std::move(left), std::move(right));
        }
        return left;
    }

    std::unique_ptr<Expr> Parser::parse_equality()
    {
        auto left = parse_comparison();
        while (check(TokenType::EQ) || check(TokenType::NEQ))
        {
            Token op = cur;
            advance();
            auto right = parse_comparison();
            left = std::make_unique<BinaryExpr>(op.lexeme, std::move(left), std::move(right));
        }
        return left;
    }

    std::unique_ptr<Expr> Parser::parse_comparison()
    {
        auto left = parse_shift();
        while (check(TokenType::LT) || check(TokenType::GT) || check(TokenType::LE) || check(TokenType::GE))
        {
            Token op = cur;
            advance();
            auto right = parse_shift();
            left = std::make_unique<BinaryExpr>(op.lexeme, std::move(left), std::move(right));
        }
        return left;
    }

    std::unique_ptr<Expr> Parser::parse_additive()
    {
        auto left = parse_multiplicative();
        while (check(TokenType::PLUS) || check(TokenType::MINUS))
        {
            Token op = cur;
            advance();
            auto right = parse_multiplicative();
            left = std::make_unique<BinaryExpr>(op.lexeme, std::move(left), std::move(right));
        }
        return left;
    }

    std::unique_ptr<Expr> Parser::parse_multiplicative()
    {
        auto left = parse_unary();
        while (check(TokenType::STAR) || check(TokenType::DEREF) || check(TokenType::SLASH) || check(TokenType::PERCENT))
        {
            Token op = cur;

            if (op.type == TokenType::DEREF)
                op.lexeme = "*";
            advance();
            auto right = parse_unary();
            left = std::make_unique<BinaryExpr>(op.lexeme, std::move(left), std::move(right));
        }
        return left;
    }

    std::unique_ptr<Expr> Parser::parse_unary()
    {

        if (check(TokenType::BANG) || check(TokenType::MINUS) || check(TokenType::PLUS) ||
            check(TokenType::PLUSPLUS) || check(TokenType::MINUSMINUS) ||
            check(TokenType::DEREF) || check(TokenType::ADDRESS_OF))
        {
            Token op = cur;
            advance();
            auto rhs = parse_unary();

            std::string op_lex = op.lexeme;
            if (op.type == TokenType::DEREF)
                op_lex = "*";
            else if (op.type == TokenType::ADDRESS_OF)
                op_lex = "&";

            return std::make_unique<UnaryExpr>(op_lex, std::move(rhs));
        }

        if (check(TokenType::LBRACK))
        {

            Token t0 = cur;
            Token next1 = lexer.peek(1);
            Token next2 = lexer.peek(2);
            Token next3 = lexer.peek(3);

            if (next1.type == TokenType::RBRACK && next2.type == TokenType::IDENT && next3.type == TokenType::LBRACE)
            {

                advance();
                advance();

                Token typeTk = expect(TokenType::IDENT, "expected type name after '[]' in typed array literal");

                expect(TokenType::LBRACE, "expected '{' to start typed array literal");

                std::vector<std::unique_ptr<Expr>> elems;
                skip_newlines();
                if (!check(TokenType::RBRACE))
                {
                    while (true)
                    {
                        skip_newlines();
                        auto elem = parse_expression();
                        if (elem)
                            elems.push_back(std::move(elem));
                        skip_newlines();

                        if (match(TokenType::COMMA))
                        {
                            skip_newlines();
                            if (check(TokenType::RBRACE))
                                break;
                            else
                                continue;
                        }
                        else
                        {
                            break;
                        }
                    }
                }
                expect(TokenType::RBRACE, "expected '}' to close typed array literal");

                std::unique_ptr<ast::Type> elemType = std::make_unique<ast::NamedType>(typeTk.lexeme);
                auto arrType = std::make_unique<ast::ArrayType>(
                    std::move(elemType),
                    true);

                auto node = std::make_unique<ast::ArrayLiteral>(std::move(arrType), std::move(elems));
                return parse_postfix(std::move(node));
            }

            auto arrLit = parse_array_literal();
            return parse_postfix(std::move(arrLit));
        }

        return parse_primary();
    }

    std::unique_ptr<Expr> Parser::parse_array_literal()
    {
        expect(TokenType::LBRACK, "expected '[' to start array literal");
        std::vector<std::unique_ptr<Expr>> elems;

        skip_newlines();
        if (!check(TokenType::RBRACK))
        {
            while (true)
            {
                skip_newlines();
                auto elem = parse_expression();
                if (elem)
                    elems.push_back(std::move(elem));
                skip_newlines();

                if (match(TokenType::COMMA))
                {
                    skip_newlines();
                    if (check(TokenType::RBRACK))
                        break;
                    else
                        continue;
                }
                else
                {
                    break;
                }
            }
        }

        expect(TokenType::RBRACK, "expected ']' to close array literal");
        return std::make_unique<ArrayLiteral>(std::move(elems));
    }

    std::unique_ptr<Expr> Parser::parse_byte_array_literal()
    {
        expect(TokenType::LBRACK, "expected '[' to start byte array literal");
        std::vector<std::unique_ptr<Expr>> elems;

        skip_newlines();
        if (!check(TokenType::RBRACK))
        {
            while (true)
            {
                skip_newlines();
                auto elem = parse_expression();
                if (elem)
                    elems.push_back(std::move(elem));
                skip_newlines();

                if (match(TokenType::COMMA))
                {
                    skip_newlines();
                    if (check(TokenType::RBRACK))
                        break;
                    else
                        continue;
                }
                else
                {
                    break;
                }
            }
        }

        expect(TokenType::RBRACK, "expected ']' to close byte array literal");
        return std::make_unique<ast::ByteArrayLiteral>(std::move(elems));
    }

    std::unique_ptr<Expr> Parser::parse_postfix(std::unique_ptr<Expr> left)
    {
        while (true)
        {
            if (check(TokenType::LPAREN))
            {
                advance();
                std::vector<std::unique_ptr<Expr>> args;
                skip_newlines();
                if (!check(TokenType::RPAREN))
                {
                    size_t arg_index = 0;
                    while (true)
                    {
                        skip_newlines();
                        args.push_back(parse_call_arg_for(left.get(), arg_index));
                        skip_newlines();
                        ++arg_index;
                        if (match(TokenType::COMMA))
                            continue;
                        break;
                    }
                }
                expect(TokenType::RPAREN, "expected ')' in call");
                left = std::make_unique<CallExpr>(std::move(left), std::move(args));
                continue;
            }

            if (check(TokenType::LBRACK))
            {
                advance();
                auto idxExpr = parse_expression();
                expect(TokenType::RBRACK, "expected ']' after index");
                left = std::make_unique<IndexExpr>(std::move(left), std::move(idxExpr));
                continue;
            }

            if (check(TokenType::PLUSPLUS) || check(TokenType::MINUSMINUS))
            {
                Token op = cur;
                advance();
                left = std::make_unique<PostfixExpr>(op.lexeme, std::move(left));
                continue;
            }

            if (check(TokenType::DOT))
            {
                advance();
                Token memberTk = expect(TokenType::IDENT, "expected member name after '.'");
                left = std::make_unique<MemberExpr>(std::move(left), memberTk.lexeme);
                continue;
            }

            break;
        }

        return left;
    }

    std::unique_ptr<Expr> Parser::parse_call_arg_for(const ast::Expr *callee, size_t arg_index)
    {
        std::string path = callee_path_for_parser(callee);

        if (arg_index == 0)
        {
            if ((path == "array.new" || ends_with_for_parser(path, ".new")) && check(TokenType::LBRACK) && lexer.peek(1).type == TokenType::RBRACK)
            {
                return std::make_unique<ast::TypeExpr>(parse_type());
            }

            if ((path == "mem.sizeof" || ends_with_for_parser(path, ".sizeof")) &&
                (check(TokenType::IDENT) || check(TokenType::LBRACK) || check(TokenType::DEREF) || check(TokenType::ADDRESS_OF) || check(TokenType::KW_BYTE)))
            {
                return std::make_unique<ast::TypeExpr>(parse_type());
            }
        }

        return parse_expression();
    }

    std::unique_ptr<Expr> Parser::parse_shift()
    {
        auto left = parse_additive();
        while (check(TokenType::SHL) || check(TokenType::SHR))
        {
            Token op = cur;
            advance();
            auto right = parse_additive();
            left = std::make_unique<BinaryExpr>(op.lexeme, std::move(left), std::move(right));
        }
        return left;
    }

    std::unique_ptr<Expr> Parser::parse_primary()
    {
        if (check(TokenType::INT) || check(TokenType::FLOAT) || check(TokenType::STRING) || check(TokenType::CHAR))
        {
            Token tk = cur;
            advance();
            auto lit = std::make_unique<Literal>(tk.lexeme, tk.type);
            return parse_postfix(std::move(lit));
        }

        if (check(TokenType::KW_TRUE) || check(TokenType::KW_FALSE))
        {
            Token tk = cur;
            advance();
            auto lit = std::make_unique<Literal>(tk.lexeme, TokenType::BOOL);
            return parse_postfix(std::move(lit));
        }

        if (check(TokenType::KW_NONE))
        {
            Token tk = cur;
            advance();
            auto lit = std::make_unique<Literal>(tk.lexeme, TokenType::NONE);
            return parse_postfix(std::move(lit));
        }

        if (check(TokenType::LBRACK))
        {
            auto arrLit = parse_array_literal();
            return parse_postfix(std::move(arrLit));
        }

        if (check(TokenType::IDENT))
        {
            Token id = cur;
            advance();

            std::unique_ptr<Expr> result;

            if (check(TokenType::LPAREN))
            {
                advance();
                std::vector<std::unique_ptr<Expr>> args;
                skip_newlines();
                if (!check(TokenType::RPAREN))
                {
                    size_t arg_index = 0;
                    while (true)
                    {
                        skip_newlines();
                        ast::Ident callee(id.lexeme);
                        args.push_back(parse_call_arg_for(&callee, arg_index));
                        skip_newlines();
                        ++arg_index;
                        if (match(TokenType::COMMA))
                            continue;
                        break;
                    }
                }
                expect(TokenType::RPAREN, "expected ')' in call");
                result = std::make_unique<CallExpr>(std::make_unique<Ident>(id.lexeme), std::move(args));
            }

            else if (check(TokenType::LBRACE) && suppress_struct_literal_depth == 0)
            {
                advance();
                std::vector<ast::StructFieldInit> inits;
                skip_newlines();
                if (!check(TokenType::RBRACE))
                {
                    while (true)
                    {
                        skip_newlines();

                        if (check(TokenType::IDENT) && peek_next().type == TokenType::COLON)
                        {
                            Token nameTk = cur;
                            advance();
                            expect(TokenType::COLON, "expected ':' in struct field init");
                            auto val = parse_expression();
                            inits.emplace_back(std::optional<std::string>(nameTk.lexeme), std::move(val));
                        }
                        else
                        {

                            auto val = parse_expression();
                            inits.emplace_back(std::optional<std::string>(std::nullopt), std::move(val));
                        }

                        skip_newlines();
                        if (match(TokenType::COMMA))
                        {
                            skip_newlines();
                            if (check(TokenType::RBRACE))
                                break;
                            else
                                continue;
                        }
                        else
                        {
                            break;
                        }
                    }
                }
                expect(TokenType::RBRACE, "expected '}' to close struct literal");

                result = std::make_unique<ast::StructLiteral>(std::make_unique<ast::NamedType>(id.lexeme), std::move(inits));
            }
            else
            {

                result = std::make_unique<Ident>(id.lexeme);
            }

            return parse_postfix(std::move(result));
        }

        if (check(TokenType::LPAREN))
        {
            advance();
            auto e = parse_expression();
            expect(TokenType::RPAREN, "expected ')'");
            return parse_postfix(std::move(e));
        }

        if (check(TokenType::KW_BYTE) || (check(TokenType::IDENT) && cur.lexeme == "byte"))
        {
            advance();

            if (check(TokenType::LBRACK))
            {
                auto byteArr = parse_byte_array_literal();
                return parse_postfix(std::move(byteArr));
            }

            if (check(TokenType::STRING))
            {
                Token strTk = cur;
                advance();

                std::string content = decode_string_literal_content(strTk.lexeme);
                std::vector<uint8_t> bytes;
                bytes.reserve(content.size());
                for (unsigned char ch : content)
                    bytes.push_back(static_cast<uint8_t>(ch));

                auto node = std::make_unique<ast::ByteArrayLiteral>(bytes);
                return parse_postfix(std::move(node));
            }

            emit_error(cur, "expected '[' or string literal after 'byte'");

            auto empty = std::make_unique<ast::ByteArrayLiteral>(std::vector<std::unique_ptr<Expr>>{});
            return parse_postfix(std::move(empty));
        }

        emit_error(cur, "unexpected token in expression");
        advance();
        return parse_postfix(std::make_unique<Literal>("", TokenType::ILLEGAL));
    }

    std::unique_ptr<Decl> Parser::parse_struct_decl(bool is_pub)
    {
        expect(TokenType::KW_STRUCT, "expected 'struct'");
        Token nameTk = expect(TokenType::IDENT, "expected struct name");
        std::string name = nameTk.lexeme;

        expect(TokenType::LBRACE, "expected '{' after struct name");

        auto sdecl = std::make_unique<ast::StructDecl>(name);
        sdecl->is_pub = is_pub;

        skip_newlines();
        while (!check(TokenType::RBRACE) && !is_at_end())
        {
            Token fieldNameTk = expect(TokenType::IDENT, "expected field name in struct");
            std::string fieldName = fieldNameTk.lexeme;

            auto field = std::make_shared<ast::StructField>();
            field->name = fieldName;

            if (check(TokenType::KW_STRUCT))
            {
                advance();
                expect(TokenType::LBRACE, "expected '{' for inline struct in field");
                auto inlineStruct = std::make_shared<ast::StructDecl>("");
                skip_newlines();
                while (!check(TokenType::RBRACE) && !is_at_end())
                {
                    Token fn = expect(TokenType::IDENT, "expected field name in inline struct");
                    std::string fnname = fn.lexeme;

                    std::unique_ptr<ast::Type> ft = parse_type();

                    auto inlineField = std::make_shared<ast::StructField>();
                    inlineField->name = fnname;
                    inlineField->type = std::move(ft);
                    inlineStruct->fields.push_back(std::move(inlineField));

                    match(TokenType::NEWLINE);
                    skip_newlines();
                }
                expect(TokenType::RBRACE, "expected '}' after inline struct");
                field->inline_struct = inlineStruct;
            }
            else
            {
                field->type = parse_type();
            }

            sdecl->fields.push_back(std::move(field));

            match(TokenType::NEWLINE);
            skip_newlines();
        }

        expect(TokenType::RBRACE, "expected '}' to close struct");
        return sdecl;
    }

    std::unique_ptr<Decl> Parser::parse_enum_decl(bool is_pub)
    {
        expect(TokenType::KW_ENUM, "expected 'enum'");
        Token nameTk = expect(TokenType::IDENT, "expected enum name");
        expect(TokenType::LBRACE, "expected '{' after enum name");

        std::vector<EnumVariant> variants;
        long long nextValue = 0;

        skip_newlines();
        while (!check(TokenType::RBRACE) && !is_at_end())
        {
            Token variantTk = expect(TokenType::IDENT, "expected enum variant name");
            std::optional<long long> explicitValue = std::nullopt;

            if (check(TokenType::ASSIGN) && cur.lexeme == "=")
            {
                advance();
                bool neg = false;
                if (check(TokenType::MINUS))
                {
                    neg = true;
                    advance();
                }
                Token valueTk = expect(TokenType::INT, "expected integer enum value");
                try
                {
                    long long parsed = std::stoll(valueTk.lexeme, nullptr, 0);
                    explicitValue = neg ? -parsed : parsed;
                    nextValue = *explicitValue;
                }
                catch (...)
                {
                    emit_error(valueTk, "invalid integer enum value");
                    explicitValue = nextValue;
                }
            }

            variants.emplace_back(variantTk.lexeme, explicitValue);
            nextValue++;

            skip_newlines();
            if (match(TokenType::COMMA))
                skip_newlines();
            else
                match(TokenType::NEWLINE);
            skip_newlines();
        }

        expect(TokenType::RBRACE, "expected '}' to close enum");
        return std::make_unique<EnumDecl>(nameTk.lexeme, std::move(variants), is_pub);
    }

    std::unique_ptr<Decl> Parser::parse_type_alias_decl(bool is_pub)
    {
        expect(TokenType::KW_TYPE, "expected 'type'");
        Token nameTk = expect(TokenType::IDENT, "expected type alias name");
        if (check(TokenType::ASSIGN) && cur.lexeme == "=")
            advance();
        auto target = parse_type();
        match(TokenType::NEWLINE);
        return std::make_unique<TypeAliasDecl>(nameTk.lexeme, std::move(target), is_pub);
    }

    std::unique_ptr<ast::Type> Parser::parse_type()
    {

        std::string ptr_prefix;
        while (check(TokenType::DEREF) || check(TokenType::ADDRESS_OF))
        {
            if (check(TokenType::DEREF))
            {
                ptr_prefix.push_back('*');
                advance();
            }
            else
            {
                ptr_prefix.push_back('&');
                advance();
            }
        }

        if (check(TokenType::LBRACK))
        {
            int array_depth = 0;
            while (check(TokenType::LBRACK))
            {
                advance();
                expect(TokenType::RBRACK, "expected ']' after '[' in array type");
                ++array_depth;
            }

            std::unique_ptr<ast::Type> base;
            if (check(TokenType::KW_BYTE) || (check(TokenType::IDENT) && cur.lexeme == "byte"))
            {
                advance();
                base = std::make_unique<ast::NamedType>("byte");
            }
            else
            {
                Token elemTk = expect(TokenType::IDENT, "expected element type after '[]'");
                base = std::make_unique<ast::NamedType>(elemTk.lexeme);
            }

            for (int i = 0; i < array_depth; ++i)
            {
                base = std::make_unique<ast::ArrayType>(std::move(base), true);
            }

            std::unique_ptr<ast::Type> arrType = std::move(base);

            for (size_t i = 0; i < ptr_prefix.size(); ++i)
            {
                arrType = std::make_unique<ast::PointerType>(std::move(arrType));
            }

            return arrType;
        }

        std::unique_ptr<ast::Type> base;
        if (check(TokenType::KW_BYTE) || (check(TokenType::IDENT) && cur.lexeme == "byte"))
        {
            advance();
            base = std::make_unique<ast::NamedType>("byte");
        }
        else
        {
            Token t = expect(TokenType::IDENT, "expected type name");
            base = std::make_unique<ast::NamedType>(t.lexeme);
        }

        for (size_t i = 0; i < ptr_prefix.size(); ++i)
        {
            base = std::make_unique<ast::PointerType>(std::move(base));
        }
        return base;
    }

    std::unique_ptr<Decl> Parser::parse_function_decl(bool is_pub, bool is_extern, bool is_intrinsic)
    {
        expect(TokenType::KW_FN, "expected 'fn'");

        Token firstTk = expect(TokenType::IDENT, "expected function or method name");
        std::optional<std::string> receiverName;
        std::string funcName;

        if (check(TokenType::DOT))
        {
            receiverName = firstTk.lexeme;
            advance();
            Token methodTk = expect(TokenType::IDENT, "expected method name after '.'");
            funcName = methodTk.lexeme;
        }
        else
        {
            funcName = firstTk.lexeme;
        }

        expect(TokenType::LPAREN, "expected '(' after fn name");

        auto consume_ellipsis = [&]() -> bool
        {
            if (check(TokenType::ELLIPSIS))
            {
                advance();
                return true;
            }

            if (check(TokenType::DOT) && lexer.peek(1).type == TokenType::DOT && lexer.peek(2).type == TokenType::DOT)
            {
                advance();
                advance();
                advance();
                return true;
            }
            return false;
        };

        std::vector<Param> params;
        if (!check(TokenType::RPAREN))
        {
            while (true)
            {
                std::string prefix_before_name;
                while (check(TokenType::DEREF) || check(TokenType::ADDRESS_OF))
                {
                    if (check(TokenType::DEREF))
                    {
                        prefix_before_name.push_back('*');
                        advance();
                    }
                    else
                    {
                        prefix_before_name.push_back('&');
                        advance();
                    }
                }

                Token id = expect(TokenType::IDENT, "expected parameter name");

                bool is_variadic = false;
                if (consume_ellipsis())
                {
                    is_variadic = true;
                }

                std::unique_ptr<ast::Type> typePtr;

                if (check(TokenType::LBRACK) || check(TokenType::IDENT) || check(TokenType::KW_BYTE) || check(TokenType::DEREF) || check(TokenType::ADDRESS_OF))
                {
                    typePtr = parse_type();
                }
                else
                {
                    if (is_variadic)
                    {

                        typePtr = std::make_unique<ast::NamedType>("any");
                    }
                    else if (!prefix_before_name.empty())
                    {

                        std::unique_ptr<ast::Type> base = std::make_unique<ast::NamedType>("int");
                        for (size_t i = 0; i < prefix_before_name.size(); ++i)
                        {
                            base = std::make_unique<ast::PointerType>(std::move(base));
                        }
                        typePtr = std::move(base);
                    }
                    else
                    {
                        emit_error(cur, "expected parameter type after name (use: 'name type', e.g. 'x int')");
                        typePtr = std::make_unique<ast::NamedType>("int");
                    }
                }

                params.push_back(Param{id.lexeme, std::move(typePtr), is_variadic});

                if (is_variadic)
                {
                    if (match(TokenType::COMMA))
                    {
                        emit_error(cur, "variadic parameter must be the last parameter");

                        while (!check(TokenType::RPAREN) && !is_at_end())
                            advance();
                    }
                    break;
                }

                if (match(TokenType::COMMA))
                    continue;
                break;
            }
        }
        expect(TokenType::RPAREN, "expected ')' after params");

        std::unique_ptr<ast::Type> ret_type_ptr = nullptr;
        if (check(TokenType::IDENT) || check(TokenType::LBRACK) || check(TokenType::DEREF) || check(TokenType::ADDRESS_OF) || check(TokenType::KW_BYTE))
        {
            ret_type_ptr = parse_type();
        }

        std::optional<std::string> externName = std::nullopt;
        if (check(TokenType::KW_AS))
        {
            advance();
            Token nameTk = expect(TokenType::STRING, "expected string literal after 'as'");
            std::string raw = nameTk.lexeme;
            if (raw.size() >= 2 && raw.front() == '"' && raw.back() == '"')
                externName = raw.substr(1, raw.size() - 2);
            else
                externName = raw;
        }

        std::unique_ptr<BlockStmt> body = nullptr;
        if (check(TokenType::LBRACE))
        {
            body = parse_block();
        }
        else if (!is_extern && !is_intrinsic)
        {
            emit_error(cur, "expected function body");
            body = std::make_unique<BlockStmt>();
        }

        return std::make_unique<FuncDecl>(funcName, std::move(params), std::move(ret_type_ptr), is_pub, std::move(body), is_extern, is_intrinsic, std::move(externName), receiverName);
    }

}
