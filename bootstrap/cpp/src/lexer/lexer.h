
#pragma once
#include "token.h"
#include <string>
#include <functional>
#include <vector>

namespace lex
{
    class Lexer
    {
    public:
        Lexer(const std::string &src, std::function<void(int, int, const std::string &)> error_cb = nullptr);

        Token next_token();

        Token peek(int k = 1);

        std::vector<Token> tokenize_all();

    private:
        std::string src;
        size_t current = 0;
        int line = 1;
        int column = 1;
        Position last_pos{};
        std::function<void(int, int, const std::string &)> error_cb;

        bool is_at_end() const;
        char advance();
        char peek_char(size_t ahead = 0) const;
        char peek_nonspace_char(size_t ahead = 0) const;
        bool match(char expected);
        void emit_error(const std::string &msg);

        Token make_token(TokenType type, const std::string &lexeme, Position start, Position end);
        Token make_token_single(TokenType type, const std::string &lexeme, Position start);

        void skip_whitespace_and_comments(std::vector<Token> &out, bool emit_newline);
        Token scan_token();

        Token identifier_or_keyword(Position start);
        Token number_literal(Position start);
        Token string_literal(Position start, char quote);
        Token char_literal(Position start);
        bool is_ident_start(char c) const;
        bool is_ident_part(char c) const;
    };
}
