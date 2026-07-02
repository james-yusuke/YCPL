#pragma once
#include "ast.h"
#include <iostream>

inline void print_ast(const ast::Program &p)
{
    p.print(std::cout, 0);
}
