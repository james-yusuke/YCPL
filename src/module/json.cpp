#include "json.h"
#include <stdexcept>

namespace module
{

    std::optional<JsonValue> SimpleJsonParser::parse(const std::string &input)
    {
        input_ = input;
        pos_ = 0;
        try
        {
            skip_whitespace();
            auto result = parse_value();
            skip_whitespace();
            return result;
        }
        catch (...)
        {
            return std::nullopt;
        }
    }

    void SimpleJsonParser::skip_whitespace()
    {
        while (pos_ < input_.size() && std::isspace(static_cast<unsigned char>(input_[pos_])))
            pos_++;
    }

    char SimpleJsonParser::peek() const
    {
        if (pos_ >= input_.size())
            return '\0';
        return input_[pos_];
    }

    char SimpleJsonParser::advance()
    {
        if (pos_ >= input_.size())
            return '\0';
        return input_[pos_++];
    }

    bool SimpleJsonParser::match(char c)
    {
        if (peek() == c)
        {
            pos_++;
            return true;
        }
        return false;
    }

    JsonValue SimpleJsonParser::parse_value()
    {
        skip_whitespace();
        char c = peek();

        if (c == 'n')
            return parse_null();
        if (c == 't' || c == 'f')
            return parse_bool();
        if (c == '-' || std::isdigit(static_cast<unsigned char>(c)))
            return parse_number();
        if (c == '"')
            return parse_string();
        if (c == '[')
            return parse_array();
        if (c == '{')
            return parse_object();

        throw std::runtime_error("Unexpected character");
    }

    JsonValue SimpleJsonParser::parse_null()
    {
        if (input_.substr(pos_, 4) == "null")
        {
            pos_ += 4;
            return JsonNull{};
        }
        throw std::runtime_error("Expected null");
    }

    JsonValue SimpleJsonParser::parse_bool()
    {
        if (input_.substr(pos_, 4) == "true")
        {
            pos_ += 4;
            return true;
        }
        if (input_.substr(pos_, 5) == "false")
        {
            pos_ += 5;
            return false;
        }
        throw std::runtime_error("Expected boolean");
    }

    JsonValue SimpleJsonParser::parse_number()
    {
        size_t start = pos_;
        if (peek() == '-')
            advance();
        while (std::isdigit(static_cast<unsigned char>(peek())))
            advance();
        if (peek() == '.')
        {
            advance();
            while (std::isdigit(static_cast<unsigned char>(peek())))
                advance();
        }
        if (peek() == 'e' || peek() == 'E')
        {
            advance();
            if (peek() == '+' || peek() == '-')
                advance();
            while (std::isdigit(static_cast<unsigned char>(peek())))
                advance();
        }
        return std::stod(input_.substr(start, pos_ - start));
    }

    JsonValue SimpleJsonParser::parse_string()
    {
        advance(); // skip opening quote
        std::string result;
        while (peek() != '"')
        {
            if (peek() == '\0')
                throw std::runtime_error("Unterminated string");
            if (peek() == '\\')
            {
                advance();
                char escaped = advance();
                switch (escaped)
                {
                case '"':
                    result += '"';
                    break;
                case '\\':
                    result += '\\';
                    break;
                case '/':
                    result += '/';
                    break;
                case 'b':
                    result += '\b';
                    break;
                case 'f':
                    result += '\f';
                    break;
                case 'n':
                    result += '\n';
                    break;
                case 'r':
                    result += '\r';
                    break;
                case 't':
                    result += '\t';
                    break;
                default:
                    result += escaped;
                }
            }
            else
            {
                result += advance();
            }
        }
        advance(); // skip closing quote
        return result;
    }

    JsonValue SimpleJsonParser::parse_array()
    {
        advance(); // skip '['
        JsonArray arr;
        skip_whitespace();
        if (peek() == ']')
        {
            advance();
            return arr;
        }
        while (true)
        {
            skip_whitespace();
            arr.push_back(parse_value());
            skip_whitespace();
            if (!match(','))
                break;
        }
        if (!match(']'))
            throw std::runtime_error("Expected ]");
        return arr;
    }

    JsonValue SimpleJsonParser::parse_object()
    {
        advance(); // skip '{'
        JsonObject obj;
        skip_whitespace();
        if (peek() == '}')
        {
            advance();
            return obj;
        }
        while (true)
        {
            skip_whitespace();
            auto key = parse_string();
            skip_whitespace();
            if (!match(':'))
                throw std::runtime_error("Expected :");
            skip_whitespace();
            auto value = parse_value();
            obj[std::get<JsonString>(key)] = std::move(value);
            skip_whitespace();
            if (!match(','))
                break;
        }
        if (!match('}'))
            throw std::runtime_error("Expected }");
        return obj;
    }

}
