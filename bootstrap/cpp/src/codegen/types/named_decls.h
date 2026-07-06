#pragma once
#include "../codegen.h"
#include "type_shape.h"

namespace codegen
{

void CodeGen::prepare_named_decls(const ast::Program &prog)
{
    type_aliases.clear();
    enum_values.clear();
    scoped_enum_values.clear();

    for (const auto &decl : prog.decls)
    {
        if (auto alias = dynamic_cast<const ast::TypeAliasDecl *>(decl.get()))
        {
            if (!alias->name.empty() && alias->target)
                type_aliases[alias->name] = resolve_type_name(const_cast<ast::Type *>(alias->target.get()));
            continue;
        }

        if (auto enumDecl = dynamic_cast<const ast::EnumDecl *>(decl.get()))
        {
            long long nextValue = 0;
            for (const auto &variant : enumDecl->variants)
            {
                if (variant.value)
                    nextValue = *variant.value;

                enum_values[variant.name] = nextValue;
                if (!enumDecl->name.empty())
                    scoped_enum_values[enumDecl->name + "." + variant.name] = nextValue;

                nextValue++;
            }
        }
    }
}

std::string CodeGen::resolve_type_alias_name(const std::string &typeName, int depth)
{
    if (typeName.empty() || depth > 32)
        return typeName;

    auto exact = type_aliases.find(typeName);
    if (exact != type_aliases.end())
        return resolve_type_alias_name(exact->second, depth + 1);

    TypeShape shape = parse_type_shape(typeName);
    auto baseAlias = type_aliases.find(shape.base);
    if (baseAlias == type_aliases.end())
        return typeName;

    std::string resolvedBase = resolve_type_alias_name(baseAlias->second, depth + 1);
    TypeShape resolvedShape = parse_type_shape(resolvedBase);
    resolvedShape.array_rank += shape.array_rank;
    resolvedShape.pointer_depth += shape.pointer_depth;
    return resolvedShape.full_name();
}

bool CodeGen::lookup_enum_value(const std::string &name, long long &value) const
{
    auto it = enum_values.find(name);
    if (it == enum_values.end())
        return false;
    value = it->second;
    return true;
}

bool CodeGen::lookup_scoped_enum_value(const std::string &typeName, const std::string &variant, long long &value) const
{
    auto it = scoped_enum_values.find(typeName + "." + variant);
    if (it == scoped_enum_values.end())
        return false;
    value = it->second;
    return true;
}

}
