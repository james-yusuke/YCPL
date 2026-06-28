#pragma once
#include "iostream"

struct ParsedType
{
    std::string base;
    int array_depth;
    int pointer_depth;
};

static ParsedType parse_type_chain(const std::string &name)
{
    ParsedType pt;
    pt.base = name;
    pt.array_depth = 0;
    pt.pointer_depth = 0;

    while (true)
    {
        if (pt.base.size() >= 2 &&
            pt.base.substr(pt.base.size() - 2) == "[]")
        {
            pt.base = pt.base.substr(0, pt.base.size() - 2);
            pt.array_depth++;
            continue;
        }

        if (!pt.base.empty() && pt.base.back() == '*')
        {
            pt.base.pop_back();
            pt.pointer_depth++;
            continue;
        }

        break;
    }

    return pt;
}
