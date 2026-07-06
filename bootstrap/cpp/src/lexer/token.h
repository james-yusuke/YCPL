// Lexer/token.h
#pragma once
#include <string>
#include <unordered_map>
#include <iostream>

namespace lex
{
    enum class TokenType
    {
        // special
        ILLEGAL,
        EOF_TOKEN,

        // literals
        IDENT,
        INT,
        FLOAT,
        CHAR,
        STRING,
        BOOL,
        NONE,

        KW_MODULE,
        KW_PACKAGE,
        KW_IMPORT,
        KW_PUB,
        KW_EXTERN,
        KW_INTRINSIC,
        KW_FN,
        KW_STRUCT,
        KW_ENUM,
        KW_CONST,
        KW_IF,
        KW_ELSE,
        KW_FOR,
        KW_IN,
        KW_RETURN,
        KW_BREAK,
        KW_CONTINUE,
        KW_AS,
        KW_SWITCH,
        KW_TRUE,
        KW_FALSE,
        KW_NONE,
        KW_TYPE,

        // punctuation
        LPAREN,
        RPAREN,
        LBRACE,
        RBRACE,
        LBRACK,
        RBRACK,
        COMMA,
        DOT,
        COLON,
        SEMICOLON,
        ARROW,
        QUESTION,

        // operators
        PLUS,
        MINUS,
        STAR,
        SLASH,
        PERCENT,
        CARET,
        AMP,
        PIPE,
        BANG,
        TILDE,
        ASSIGN,
        PLUS_ASSIGN,
        MINUS_ASSIGN,
        MUL_ASSIGN,
        DIV_ASSIGN,
        MOD_ASSIGN,
        EQ,
        NEQ,
        LT,
        GT,
        LE,
        GE,
        AND,
        OR,
        BIT_AND,
        BIT_OR,
        BIT_XOR,
        SHL, // << 追加
        SHR, // >> 追加
        ARROW_R,
        NEWLINE,

        PLUSPLUS,
        MINUSMINUS,

        DEREF,
        ADDRESS_OF,

        KW_BYTE,
        ELLIPSIS,
    };

    struct Position
    {
        int line = 1;
        int column = 1;
    };

    struct Token
    {
        TokenType type = TokenType::ILLEGAL;
        std::string lexeme;
        Position start;
        Position end;
    };

    inline std::string token_type_to_string(TokenType t)
    {
        static const std::unordered_map<TokenType, std::string> names{
            {TokenType::ILLEGAL, "ILLEGAL"},
            {TokenType::EOF_TOKEN, "EOF"},
            {TokenType::IDENT, "IDENT"},
            {TokenType::INT, "INT"},
            {TokenType::FLOAT, "FLOAT"},
            {TokenType::CHAR, "CHAR"},
            {TokenType::STRING, "STRING"},
            {TokenType::BOOL, "BOOL"},
            {TokenType::NONE, "NONE"},
            {TokenType::KW_MODULE, "module"},
            {TokenType::KW_PACKAGE, "package"},
            {TokenType::KW_IMPORT, "import"},
            {TokenType::KW_PUB, "pub"},
            {TokenType::KW_EXTERN, "extern"},
            {TokenType::KW_INTRINSIC, "intrinsic"},
            {TokenType::KW_FN, "fn"},
            {TokenType::KW_STRUCT, "struct"},
            {TokenType::KW_ENUM, "enum"},
            {TokenType::KW_CONST, "const"},
            {TokenType::KW_IF, "if"},
            {TokenType::KW_ELSE, "else"},
            {TokenType::KW_FOR, "for"},
            {TokenType::KW_IN, "in"},
            {TokenType::KW_RETURN, "return"},
            {TokenType::KW_BREAK, "break"},
            {TokenType::KW_CONTINUE, "continue"},
            {TokenType::KW_AS, "as"},
            {TokenType::KW_SWITCH, "switch"},
            {TokenType::KW_TRUE, "true"},
            {TokenType::KW_FALSE, "false"},
            {TokenType::KW_NONE, "none"},
            {TokenType::KW_TYPE, "type"},
            {TokenType::LPAREN, "("},
            {TokenType::RPAREN, ")"},
            {TokenType::LBRACE, "{"},
            {TokenType::RBRACE, "}"},
            {TokenType::LBRACK, "["},
            {TokenType::RBRACK, "]"},
            {TokenType::COMMA, ","},
            {TokenType::DOT, "."},
            {TokenType::COLON, ":"},
            {TokenType::SEMICOLON, ";"},
            {TokenType::ARROW, "->"},
            {TokenType::QUESTION, "?"},
            {TokenType::PLUS, "+"},
            {TokenType::MINUS, "-"},
            {TokenType::STAR, "*"},
            {TokenType::SLASH, "/"},
            {TokenType::PERCENT, "%"},
            {TokenType::CARET, "^"},
            {TokenType::AMP, "&"},
            {TokenType::PIPE, "|"},
            {TokenType::BANG, "!"},
            {TokenType::TILDE, "~"},
            {TokenType::ASSIGN, "="},
            {TokenType::PLUS_ASSIGN, "+="},
            {TokenType::MINUS_ASSIGN, "-="},
            {TokenType::MUL_ASSIGN, "*="},
            {TokenType::DIV_ASSIGN, "/="},
            {TokenType::MOD_ASSIGN, "%="},
            {TokenType::EQ, "=="},
            {TokenType::NEQ, "!="},
            {TokenType::LT, "<"},
            {TokenType::GT, ">"},
            {TokenType::LE, "<="},
            {TokenType::GE, ">="},
            {TokenType::AND, "&&"},
            {TokenType::OR, "||"},
            {TokenType::BIT_AND, "&"},
            {TokenType::BIT_OR, "|"},
            {TokenType::BIT_XOR, "^"},
            {TokenType::SHL, "<<"},
            {TokenType::SHR, ">>"},
            {TokenType::ARROW_R, "=>"},
            {TokenType::NEWLINE, "NEWLINE"},
            {TokenType::PLUSPLUS, "++"},
            {TokenType::MINUSMINUS, "--"},
            {TokenType::DEREF, "*"},
            {TokenType::ADDRESS_OF, "&"},
            {TokenType::KW_BYTE, "byte"},
            {TokenType::ELLIPSIS, "..."},
        };
        auto it = names.find(t);
        if (it != names.end())
            return it->second;
        return "UNKNOWN";
    }

    inline std::ostream &operator<<(std::ostream &os, const Token &tk)
    {
        os << token_type_to_string(tk.type) << " '" << tk.lexeme << "'"
           << " (" << tk.start.line << ":" << tk.start.column << "-" << tk.end.line << ":" << tk.end.column << ")";
        return os;
    }
}
