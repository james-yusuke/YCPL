
#include "lexer/lexer.h"
#include "parser/parser.h"
#include "ast/printer.h"
#include "codegen/codegen.h"
#include "module/resolver.h"

#include <iostream>
#include <fstream>
#include <sstream>
#include <filesystem>
#include <vector>
#include <memory>

namespace fs = std::filesystem;

int main(int argc, char *argv[])
{
    using namespace lex;
    using namespace path;

    if (argc < 2)
    {
        std::cerr << "Usage: " << argv[0] << " <file1.yc> [file2.yc ...] | <dir>\n";
        return 1;
    }

    std::vector<fs::path> src_files;
    if (fs::is_directory(argv[1]) && argc == 2)
    {
        for (auto &it : fs::recursive_directory_iterator(argv[1]))
        {
            if (it.is_regular_file() && it.path().extension() == ".yc")
                src_files.push_back(it.path());
        }
    }
    else
    {
        for (int i = 1; i < argc; ++i)
        {
            fs::path p(argv[i]);
            if (fs::is_directory(p))
            {
                for (auto &it : fs::recursive_directory_iterator(p))
                {
                    if (it.is_regular_file() && it.path().extension() == ".yc")
                        src_files.push_back(it.path());
                }
            }
            else if (fs::is_regular_file(p))
            {
                src_files.push_back(p);
            }
            else
            {
                std::cerr << "No such file/dir: " << p << "\n";
            }
        }
    }

    if (src_files.empty())
    {
        std::cerr << "No .yc source files found.\n";
        return 1;
    }

    module::ModuleResolver resolver;
    resolver.set_project_root(fs::current_path());
    resolver.add_source_dir(".");
    for (const auto &p : src_files)
    {
        resolver.add_source_dir(p.parent_path());
    }

    if (!resolver.resolve_all(src_files))
    {
        std::cerr << "Module resolution failed\n";
        return 1;
    }

    auto merged = resolver.link_program();

    print_ast(*merged);

    codegen::CodeGen cg("yc");

    if (!cg.generate(*merged))
    {
        std::cerr << "codegen failed\n";
        return 1;
    }

    cg.dump_llvm_ir();
    cg.write_ir_to_file("out.ll");
    std::cout << "Wrote IR to out.ll\n";
    return 0;
}
