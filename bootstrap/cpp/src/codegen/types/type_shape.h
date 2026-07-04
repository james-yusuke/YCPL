#pragma once

#include <string>

struct TypeShape
{
    std::string base;
    int array_rank;
    int pointer_depth;
};

static TypeShape parse_type_shape(const std::string &name)
{
    TypeShape shape;
    shape.base = name;
    shape.array_rank = 0;
    shape.pointer_depth = 0;

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
