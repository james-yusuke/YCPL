#include "lexer.h"
#include <cctype>
#include <sstream>
#include <iomanip>
#include <algorithm>

namespace lex
{
    static const std::unordered_map<std::string, TokenType> keywords = {
        {"module", TokenType::KW_MODULE},
        {"package", TokenType::KW_PACKAGE},
        {"import", TokenType::KW_IMPORT},
        {"pub", TokenType::KW_PUB},
        {"extern", TokenType::KW_EXTERN},
        {"intrinsic", TokenType::KW_INTRINSIC},
        {"fn", TokenType::KW_FN},
        {"struct", TokenType::KW_STRUCT},
        {"enum", TokenType::KW_ENUM},
        {"interface", TokenType::KW_INTERFACE},
        {"const", TokenType::KW_CONST},
        {"mut", TokenType::KW_MUT},
        {"if", TokenType::KW_IF},
        {"else", TokenType::KW_ELSE},
        {"match", TokenType::KW_MATCH},
        {"for", TokenType::KW_FOR},
        {"in", TokenType::KW_IN},
        {"return", TokenType::KW_RETURN},
        {"break", TokenType::KW_BREAK},
        {"continue", TokenType::KW_CONTINUE},
        {"as", TokenType::KW_AS},
        {"is", TokenType::KW_IS},
        {"go", TokenType::KW_GO},
        {"defer", TokenType::KW_DEFER},
        {"select", TokenType::KW_SELECT},
        {"switch", TokenType::KW_SWITCH},
        {"true", TokenType::KW_TRUE},
        {"false", TokenType::KW_FALSE},
        {"none", TokenType::KW_NONE},
        {"or", TokenType::KW_OR},
        {"type", TokenType::KW_TYPE},
        {"importas", TokenType::KW_IMPORTAS},
        {"byte", TokenType::KW_BYTE},
    };

    Lexer::Lexer(const std::string &src_, std::function<void(int, int, const std::string &)> error_cb_)
        : src(src_), error_cb(error_cb_)
    {
        last_pos.line = line;
        last_pos.column = column;
    }

    bool Lexer::is_at_end() const { return current >= src.size(); }

    char Lexer::advance()
    {
        if (is_at_end())
            return '\0';
        char c = src[current++];
        if (c == '\n')
        {
            ++line;
            column = 1;
        }
        else
        {
            ++column;
        }
        return c;
    }

    char Lexer::peek_char(size_t ahead) const
    {
        size_t idx = current + ahead;
        if (idx >= src.size())
            return '\0';
        return src[idx];
    }

    char Lexer::peek_nonspace_char(size_t ahead) const
    {
        size_t idx = current;
        size_t found = 0;
        while (idx < src.size())
        {
            char ch = src[idx++];
            if (ch == ' ' || ch == '\t' || ch == '\r' || ch == '\n')
                continue;
            if (found == ahead)
                return ch;
            ++found;
        }
        return '\0';
    }

    bool Lexer::match(char expected)
    {
        if (is_at_end())
            return false;
        if (src[current] != expected)
            return false;

        ++current;
        if (expected == '\n')
        {
            ++line;
            column = 1;
        }
        else
        {
            ++column;
        }
        return true;
    }

    void Lexer::emit_error(const std::string &msg)
    {
        if (error_cb)
            error_cb(line, column, msg);
    }

    Token Lexer::make_token(TokenType type, const std::string &lexeme, Position start, Position end)
    {
        Token t;
        t.type = type;
        t.lexeme = lexeme;
        t.start = start;
        t.end = end;
        return t;
    }

    Token Lexer::make_token_single(TokenType type, const std::string &lexeme, Position start)
    {
        Position end = start;
        end.column = start.column + static_cast<int>(lexeme.size()) - 1;
        return make_token(type, lexeme, start, end);
    }

    void Lexer::skip_whitespace_and_comments(std::vector<Token> &out, bool emit_newline)
    {
        for (;;)
        {
            char c = peek_char();
            if (c == ' ' || c == '\t' || c == '\r')
            {
                advance();
                continue;
            }
            if (c == '\n')
            {

                Position p{line, column};
                advance();
                Position q{line, column};
                if (emit_newline)
                {
                    out.push_back(make_token(TokenType::NEWLINE, "\n", p, q));
                }
                continue;
            }

            if (c == '/')
            {
                if (peek_char(1) == '/')
                {

                    Position p{line, column};

                    advance();
                    advance();
                    std::string lex = "//";
                    while (!is_at_end() && peek_char() != '\n')
                    {
                        lex.push_back(advance());
                    }
                    Position q{line, column};

                    continue;
                }
                else if (peek_char(1) == '*')
                {

                    Position p{line, column};
                    advance();
                    advance();
                    int depth = 1;
                    std::string lex = "/*";
                    while (!is_at_end() && depth > 0)
                    {
                        char ch = advance();
                        lex.push_back(ch);
                        if (ch == '/' && peek_char() == '*')
                        {
                            advance();
                            lex.push_back('*');
                            ++depth;
                        }
                        else if (ch == '*' && peek_char() == '/')
                        {
                            advance();
                            lex.push_back('/');
                            --depth;
                        }
                    }
                    if (depth != 0)
                    {
                        emit_error("unclosed block comment");
                    }
                    continue;
                }
            }
            break;
        }
    }

    Token Lexer::next_token()
    {
        std::vector<Token> tmp;
        skip_whitespace_and_comments(tmp, true);

        if (!tmp.empty())
        {
            Token t = tmp.front();

            return t;
        }
        if (is_at_end())
        {
            Position p{line, column};
            return make_token(TokenType::EOF_TOKEN, "", p, p);
        }
        return scan_token();
    }

    Token Lexer::scan_token()
    {
        Position start{line, column};
        char c = advance();

        switch (c)
        {
        case '(':
            return make_token_single(TokenType::LPAREN, "(", start);
        case ')':
            return make_token_single(TokenType::RPAREN, ")", start);
        case '{':
            return make_token_single(TokenType::LBRACE, "{", start);
        case '}':
            return make_token_single(TokenType::RBRACE, "}", start);
        case '[':
            return make_token_single(TokenType::LBRACK, "[", start);
        case ']':
            return make_token_single(TokenType::RBRACK, "]", start);
        case ',':
            return make_token_single(TokenType::COMMA, ",", start);
        case '.':
            if (peek_char() == '.' && peek_char(1) == '.')
            {
                advance();
                advance();
                return make_token(TokenType::ELLIPSIS, "...", start, Position{line, column});
            }
            return make_token_single(TokenType::DOT, ".", start);
        case ':':
        {
            if (peek_char() == '=')
            {
                advance();
                return make_token(TokenType::ASSIGN, ":=", start, Position{line, column});
            }
            return make_token_single(TokenType::COLON, ":", start);
        }
        case ';':
            return make_token_single(TokenType::SEMICOLON, ";", start);
        case '?':
            return make_token_single(TokenType::QUESTION, "?", start);
        case '+':
            if (peek_char() == '=')
            {
                advance();
                return make_token(TokenType::PLUS_ASSIGN, "+=", start, Position{line, column});
            }

            if (peek_char() == '+')
            {
                advance();
                return make_token(TokenType::PLUSPLUS, "++", start, Position{line, column});
            }

            return make_token_single(TokenType::PLUS, "+", start);
        case '-':
            if (peek_char() == '=')
            {
                advance();
                return make_token(TokenType::MINUS_ASSIGN, "-=", start, Position{line, column});
            }
            if (peek_char() == '>')
            {
                advance();
                return make_token(TokenType::ARROW, "->", start, Position{line, column});
            }

            if (peek_char() == '-')
            {
                advance();
                return make_token(TokenType::MINUSMINUS, "--", start, Position{line, column});
            }

            return make_token_single(TokenType::MINUS, "-", start);
        case '*':
            if (peek_char() == '=')
            {
                advance();
                return make_token(TokenType::MUL_ASSIGN, "*=", start, Position{line, column});
            }

            {
                char next = peek_nonspace_char();
                if (is_ident_start(next) || next == '*' || next == '&' || next == '(' || next == '[')
                {

                    return make_token_single(TokenType::DEREF, "*", start);
                }

                return make_token_single(TokenType::STAR, "*", start);
            }
        case '/':
            if (peek_char() == '=')
            {
                advance();
                return make_token(TokenType::DIV_ASSIGN, "/=", start, Position{line, column});
            }
            return make_token_single(TokenType::SLASH, "/", start);
        case '%':
            if (peek_char() == '=')
            {
                advance();
                return make_token(TokenType::MOD_ASSIGN, "%=", start, Position{line, column});
            }
            return make_token_single(TokenType::PERCENT, "%", start);
        case '^':
            return make_token_single(TokenType::CARET, "^", start);
        case '&':
            if (peek_char() == '&')
            {
                advance();
                return make_token(TokenType::AND, "&&", start, Position{line, column});
            }

            {
                char next = peek_nonspace_char();
                if (is_ident_start(next) || next == '*' || next == '&' || next == '(' || next == '[')
                {

                    return make_token_single(TokenType::ADDRESS_OF, "&", start);
                }

                return make_token_single(TokenType::BIT_AND, "&", start);
            }
        case '|':
            if (peek_char() == '|')
            {
                advance();
                return make_token(TokenType::OR, "||", start, Position{line, column});
            }
            return make_token_single(TokenType::BIT_OR, "|", start);
        case '!':
            if (peek_char() == '=')
            {
                advance();
                return make_token(TokenType::NEQ, "!=", start, Position{line, column});
            }
            return make_token_single(TokenType::BANG, "!", start);
        case '~':
            return make_token_single(TokenType::TILDE, "~", start);
        case '=':
            if (peek_char() == '=')
            {
                advance();
                return make_token(TokenType::EQ, "==", start, Position{line, column});
            }
            if (peek_char() == '>')
            {
                advance();
                return make_token(TokenType::ARROW_R, "=>", start, Position{line, column});
            }
            return make_token_single(TokenType::ASSIGN, "=", start);
        case '<':
            if (peek_char() == '=')
            {
                advance();
                return make_token(TokenType::LE, "<=", start, Position{line, column});
            }
            if (peek_char() == '<')
            {
                advance();
                return make_token(TokenType::SHL, "<<", start, Position{line, column});
            }
            return make_token_single(TokenType::LT, "<", start);
        case '>':
            if (peek_char() == '=')
            {
                advance();
                return make_token(TokenType::GE, ">=", start, Position{line, column});
            }
            if (peek_char() == '>')
            {
                advance();
                return make_token(TokenType::SHR, ">>", start, Position{line, column});
            }
            return make_token_single(TokenType::GT, ">", start);
        case '\'':
            return char_literal(start);
        case '"':
        case '`':
            return string_literal(start, c);
        default:
            if (std::isdigit(static_cast<unsigned char>(c)))
            {

                --current;
                if (column > 1)
                    --column;
                return number_literal(start);
            }
            if (is_ident_start(c))
            {

                --current;
                if (column > 1)
                    --column;
                return identifier_or_keyword(start);
            }
            break;
        }

        std::string s;
        s.push_back(c);
        emit_error(std::string("unexpected character '") + c + "'");
        return make_token(TokenType::ILLEGAL, s, start, Position{line, column});
    }

    Token Lexer::identifier_or_keyword(Position start)
    {
        size_t st = current;

        char c = advance();
        while (is_ident_part(peek_char()))
            advance();
        size_t ed = current;
        std::string lex = src.substr(st, ed - st);

        auto it = keywords.find(lex);
        if (it != keywords.end())
        {
            return make_token(it->second, lex, start, Position{line, column});
        }
        return make_token(TokenType::IDENT, lex, start, Position{line, column});
    }

    Token Lexer::number_literal(Position start)
    {
        size_t st = current;
        bool is_float = false;

        if (peek_char() == '0' && (peek_char(1) | 0x20) == 'x')
        {
            advance();
            advance();
            while (std::isxdigit(static_cast<unsigned char>(peek_char())))
                advance();
            std::string lex = src.substr(st, current - st);
            return make_token(TokenType::INT, lex, start, Position{line, column});
        }

        else if (peek_char() == '0' && (peek_char(1) | 0x20) == 'b')
        {
            advance();
            advance();
            while (peek_char() == '0' || peek_char() == '1')
                advance();
            std::string lex = src.substr(st, current - st);
            return make_token(TokenType::INT, lex, start, Position{line, column});
        }

        else if (peek_char() == '0' && std::isdigit(static_cast<unsigned char>(peek_char(1))))
        {

            advance();

            bool invalid_octal_digit = false;
            while (std::isdigit(static_cast<unsigned char>(peek_char())))
            {
                char p = peek_char();
                if (p >= '0' && p <= '7')
                {
                    advance();
                }
                else
                {

                    invalid_octal_digit = true;

                    while (std::isdigit(static_cast<unsigned char>(peek_char())))
                        advance();
                    break;
                }
            }
            if (invalid_octal_digit)
            {
                emit_error("invalid digit in octal literal");
            }
            std::string lex = src.substr(st, current - st);
            return make_token(TokenType::INT, lex, start, Position{line, column});
        }
        else
        {

            while (std::isdigit(static_cast<unsigned char>(peek_char())))
                advance();
            if (peek_char() == '.' && std::isdigit(static_cast<unsigned char>(peek_char(1))))
            {
                is_float = true;
                advance();
                while (std::isdigit(static_cast<unsigned char>(peek_char())))
                    advance();
            }

            if ((peek_char() == 'e' || peek_char() == 'E'))
            {
                is_float = true;
                advance();
                if (peek_char() == '+' || peek_char() == '-')
                    advance();
                if (!std::isdigit(static_cast<unsigned char>(peek_char())))
                {
                    emit_error("malformed exponent in number literal");
                }
                while (std::isdigit(static_cast<unsigned char>(peek_char())))
                    advance();
            }
            std::string lex = src.substr(st, current - st);
            return make_token(is_float ? TokenType::FLOAT : TokenType::INT, lex, start, Position{line, column});
        }
    }

    Token Lexer::string_literal(Position start, char quote)
    {
        size_t st = current - 1;
        std::ostringstream sb;
        sb << quote;
        bool is_raw = (quote == '`');
        if (is_raw)
        {

            while (!is_at_end() && peek_char() != '`')
            {
                sb << advance();
            }
            if (is_at_end())
            {
                emit_error("unterminated raw string literal");
                return make_token(TokenType::ILLEGAL, sb.str(), start, Position{line, column});
            }
            sb << advance();
            std::string lex = src.substr(st, (current)-st);
            return make_token(TokenType::STRING, lex, start, Position{line, column});
        }
        else
        {

            while (!is_at_end())
            {
                char ch = advance();
                if (ch == '\\')
                {

                    sb << '\\';
                    if (is_at_end())
                    {
                        emit_error("unterminated escape in string");
                        break;
                    }
                    char esc = advance();
                    sb << esc;
                    continue;
                }
                if (ch == '"')
                {

                    std::string lex = src.substr(st, current - st);
                    return make_token(TokenType::STRING, lex, start, Position{line, column});
                }
                sb << ch;
            }
            emit_error("unterminated string literal");
            return make_token(TokenType::ILLEGAL, sb.str(), start, Position{line, column});
        }
    }

    Token Lexer::char_literal(Position start)
    {
        size_t st = current - 1;
        std::ostringstream sb;
        sb << '\'';
        if (is_at_end())
        {
            emit_error("unterminated char literal");
            return make_token(TokenType::ILLEGAL, "'", start, Position{line, column});
        }
        char ch = advance();
        if (ch == '\\')
        {
            sb << '\\';
            if (is_at_end())
            {
                emit_error("unterminated char escape");
                return make_token(TokenType::ILLEGAL, sb.str(), start, Position{line, column});
            }
            char esc = advance();
            sb << esc;
        }
        else
        {
            sb << ch;
        }
        if (peek_char() != '\'')
        {
            emit_error("unterminated/invalid char literal");

            while (!is_at_end() && peek_char() != '\'')
                advance();
        }
        if (peek_char() == '\'')
        {
            advance();
            sb << '\'';
        }
        std::string lex = src.substr(st, current - st);
        return make_token(TokenType::CHAR, lex, start, Position{line, column});
    }

    bool Lexer::is_ident_start(char c) const
    {
        return (std::isalpha(static_cast<unsigned char>(c)) || c == '_');
    }
    bool Lexer::is_ident_part(char c) const
    {
        return (std::isalnum(static_cast<unsigned char>(c)) || c == '_');
    }

    Token Lexer::peek(int k)
    {

        Lexer copy = *this;
        Token t;
        for (int i = 0; i < k; i++)
            t = copy.next_token();
        return t;
    }

    std::vector<Token> Lexer::tokenize_all()
    {
        std::vector<Token> out;
        for (;;)
        {
            Token t = next_token();
            out.push_back(t);
            if (t.type == TokenType::EOF_TOKEN)
                break;
        }
        return out;
    }

}
