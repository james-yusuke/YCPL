#pragma once

#include <string>

// Codegen stores local type hints as compact names such as "i32[]*" across
// scopes. Keep suffix parsing and reconstruction here so arrays, indexing,
// assignment, and loop lowering agree on the same shape semantics.
struct TypeShape
{
    std::string base;
    int array_rank = 0;
    int pointer_depth = 0;

    bool is_array() const
    {
        return array_rank > 0;
    }

    bool is_pointer() const
    {
        return pointer_depth > 0;
    }

    bool is_pointer_only() const
    {
        return pointer_depth > 0 && array_rank == 0;
    }

    bool has_indirection() const
    {
        return is_array() || is_pointer();
    }

    bool is_scalar_named(const std::string &name) const
    {
        return base == name && array_rank == 0 && pointer_depth == 0;
    }

    bool is_plain_string() const
    {
        return is_scalar_named("string");
    }

    bool is_string_params() const
    {
        return is_scalar_named("string_params");
    }

    bool is_scalar_string_like() const
    {
        return is_plain_string() || is_string_params();
    }

    bool is_array_of(const std::string &name) const
    {
        return base == name && array_rank > 0;
    }

    std::string name_with_suffixes(int arrays, int pointers) const
    {
        std::string result = base;
        for (int i = 0; i < arrays; ++i)
            result += "[]";
        for (int i = 0; i < pointers; ++i)
            result += "*";
        return result;
    }

    std::string full_name() const
    {
        return name_with_suffixes(array_rank, pointer_depth);
    }

    std::string array_element_type_name() const
    {
        int elementArrayRank = array_rank > 0 ? array_rank - 1 : 0;
        return name_with_suffixes(elementArrayRank, pointer_depth);
    }
};

inline TypeShape parse_type_shape(const std::string &name)
{
    TypeShape shape;
    shape.base = name;

    while (true)
    {
        if (shape.base.size() >= 2 &&
            shape.base.substr(shape.base.size() - 2) == "[]")
        {
            shape.base = shape.base.substr(0, shape.base.size() - 2);
            shape.array_rank++;
            continue;
        }

        if (!shape.base.empty() && shape.base.back() == '*')
        {
            shape.base.pop_back();
            shape.pointer_depth++;
            continue;
        }

        break;
    }

    return shape;
}
