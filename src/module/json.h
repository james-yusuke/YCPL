#pragma once

#include <string>
#include <vector>
#include <unordered_map>
#include <variant>
#include <optional>
#include <fstream>
#include <sstream>

namespace module
{

    struct JsonValue;
    using JsonNull = std::monostate;
    using JsonBool = bool;
    using JsonNumber = double;
    using JsonString = std::string;
    using JsonArray = std::vector<JsonValue>;
    using JsonObject = std::unordered_map<std::string, JsonValue>;
    using JsonVariant = std::variant<JsonNull, JsonBool, JsonNumber, JsonString, JsonArray, JsonObject>;

    struct JsonValue : JsonVariant
    {
        using JsonVariant::JsonVariant;
        using JsonVariant::operator=;

        bool is_null() const { return std::holds_alternative<JsonNull>(*this); }
        bool is_bool() const { return std::holds_alternative<JsonBool>(*this); }
        bool is_number() const { return std::holds_alternative<JsonNumber>(*this); }
        bool is_string() const { return std::holds_alternative<JsonString>(*this); }
        bool is_array() const { return std::holds_alternative<JsonArray>(*this); }
        bool is_object() const { return std::holds_alternative<JsonObject>(*this); }

        bool as_bool() const { return std::get<JsonBool>(*this); }
        double as_number() const { return std::get<JsonNumber>(*this); }
        const std::string &as_string() const { return std::get<JsonString>(*this); }
        const JsonArray &as_array() const { return std::get<JsonArray>(*this); }
        const JsonObject &as_object() const { return std::get<JsonObject>(*this); }

        const JsonValue *get(const std::string &key) const
        {
            if (!is_object())
                return nullptr;
            auto &obj = as_object();
            auto it = obj.find(key);
            if (it != obj.end())
                return &it->second;
            return nullptr;
        }

        std::string value(const std::string &key, const std::string &default_val) const
        {
            auto v = get(key);
            if (v && v->is_string())
                return v->as_string();
            return default_val;
        }

        double value(const std::string &key, double default_val) const
        {
            auto v = get(key);
            if (v && v->is_number())
                return v->as_number();
            return default_val;
        }
    };

    class SimpleJsonParser
    {
    public:
        std::optional<JsonValue> parse(const std::string &input);

    private:
        std::string input_;
        size_t pos_ = 0;

        void skip_whitespace();
        char peek() const;
        char advance();
        bool match(char c);

        JsonValue parse_value();
        JsonValue parse_null();
        JsonValue parse_bool();
        JsonValue parse_number();
        JsonValue parse_string();
        JsonValue parse_array();
        JsonValue parse_object();
    };

    inline std::optional<JsonValue> parse_json(const std::string &input)
    {
        SimpleJsonParser parser;
        return parser.parse(input);
    }

    inline std::optional<JsonValue> load_json_file(const std::string &path)
    {
        std::ifstream file(path);
        if (!file.is_open())
            return std::nullopt;
        std::stringstream buf;
        buf << file.rdbuf();
        return parse_json(buf.str());
    }

}
