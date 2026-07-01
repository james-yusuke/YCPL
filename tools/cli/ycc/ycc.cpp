#include "../../src/lexer/lexer.h"
#include "../../src/parser/parser.h"
#include "../../src/ast/printer.h"
#include "../../src/codegen/codegen.h"
#include "../../src/module/resolver.h"

#include <iostream>
#include <fstream>
#include <sstream>
#include <filesystem>
#include <vector>
#include <memory>

namespace fs = std::filesystem;

static void print_help(const char *exec)
{
    std::cout << "Usage:\n"
                 "  "
              << exec << " [options] <file.yc | dir>\n"
                         "  "
              << exec << " [options] <file1.yc file2.yc ...>\n"
                         "\n"
                         "Modes:\n"
                         "  ll                Emit LLVM IR only\n"
                         "  debug             Show tokens, AST, and LLVM IR\n"
                         "  build             Build project from YCPL.json\n"
                         "  help              Show this help\n"
                         "\n"
                         "Options:\n"
                         "  -o <dir>          Output directory (default: current directory)\n"
                         "\n"
                         "Examples:\n"
                         "  "
              << exec << " main.yc\n"
                         "  "
              << exec << " src/ -o build\n"
                         "  "
              << exec << " build              # Uses YCPL.json\n"
                         "  "
              << exec << " ll main.yc\n";
}

static std::vector<fs::path> collect_sources(const std::vector<std::string> &inputs)
{
    std::vector<fs::path> result;
    for (auto &arg : inputs)
    {
        fs::path p(arg);
        if (fs::is_directory(p))
        {
            for (auto &it : fs::recursive_directory_iterator(p))
            {
                if (it.is_regular_file() && it.path().extension() == ".yc")
                    result.push_back(it.path());
            }
        }
        else if (fs::is_regular_file(p))
        {
            if (p.extension() == ".yc")
                result.push_back(p);
        }
        else
        {
            std::cerr << "No such file/dir: " << p << "\n";
        }
    }
    return result;
}

static std::unique_ptr<ast::Program> compile_frontend_simple(
    const std::vector<fs::path> &sources,
    bool debug_ast = false)
{
    module::ModuleResolver resolver;
    resolver.set_project_root(fs::current_path());
    resolver.add_source_dir(".");
    for (const auto &p : sources)
    {
        resolver.add_source_dir(p.parent_path());
    }

    if (!resolver.resolve_all(sources))
    {
        std::cerr << "Module resolution failed\n";
        return nullptr;
    }

    auto merged = resolver.link_program();

    if (debug_ast)
    {
        std::cout << "--- AST (merged) ---\n";
        print_ast(*merged);
    }

    return merged;
}

static fs::path find_YCPL_json()
{
    fs::path cwd = fs::current_path();
    fs::path search = cwd;
    
    for (int i = 0; i < 10; i++)
    {
        fs::path config = search / "YCPL.json";
        if (fs::exists(config))
        {
            return config;
        }
        
        fs::path parent = search.parent_path();
        if (parent == search)
            break;
        search = parent;
    }
    
    return {};
}

int main(int argc, char *argv[])
{
    using namespace lex;
    using namespace path;

    if (argc < 2)
    {
        print_help(argv[0]);
        return 1;
    }

    std::string mode = argv[1];
    bool emit_ir_only = false;
    bool debug = false;
    bool use_project_mode = false;
    fs::path output_dir = ".";

    std::vector<std::string> inputs;

    for (int i = 1; i < argc; ++i)
    {
        std::string arg = argv[i];
        if (arg == "-o" || arg == "--output")
        {
            if (i + 1 >= argc)
            {
                std::cerr << arg << " requires a folder path\n";
                return 1;
            }
            output_dir = argv[i + 1];
            i++;
        }
        else if (arg == "help")
        {
            print_help(argv[0]);
            return 0;
        }
        else if (arg == "ll")
        {
            emit_ir_only = true;
        }
        else if (arg == "debug")
        {
            debug = true;
        }
        else if (arg == "build")
        {
            use_project_mode = true;
        }
        else
        {
            inputs.push_back(arg);
        }
    }

    if (!fs::exists(output_dir))
    {
        fs::create_directories(output_dir);
    }

    std::unique_ptr<ast::Program> program;
    std::vector<fs::path> src_files;

    if (use_project_mode)
    {
        fs::path config_path = find_YCPL_json();
        if (config_path.empty())
        {
            std::cerr << "Error: YCPL.json not found\n";
            return 1;
        }

        std::cout << "Using config: " << config_path << "\n";

        auto config = module::ProjectConfig::load(config_path);
        if (!config)
        {
            std::cerr << "Error: Failed to load YCPL.json\n";
            return 1;
        }

        std::cout << "Project: " << config->name << " v" << config->version << "\n";

        fs::path project_root = config_path.parent_path();
        
        module::ModuleResolver resolver;
        resolver.set_project_root(project_root);
        
        for (const auto &src_dir : config->src_dirs)
        {
            resolver.add_source_dir(src_dir);
        }

        std::vector<fs::path> sources;
        for (const auto &src_dir : config->src_dirs)
        {
            fs::path full_dir = project_root / src_dir;
            if (fs::exists(full_dir))
            {
                for (auto &it : fs::recursive_directory_iterator(full_dir))
                {
                    if (it.is_regular_file() && it.path().extension() == ".yc")
                        sources.push_back(it.path());
                }
            }
        }

        if (sources.empty())
        {
            std::cerr << "No source files found\n";
            return 1;
        }

        std::cout << "Found " << sources.size() << " source file(s)\n";

        if (!resolver.resolve_all(sources))
        {
            std::cerr << "Module resolution failed\n";
            return 1;
        }

        program = resolver.link_program();
        
        output_dir = project_root / config->output_dir;
        if (!fs::exists(output_dir))
        {
            fs::create_directories(output_dir);
        }

        src_files = sources;
    }
    else
    {
        if (inputs.empty())
        {
            std::cerr << "No source files specified\n";
            return 1;
        }

        src_files = collect_sources(inputs);
        if (src_files.empty())
        {
            std::cerr << "No .yc source files found.\n";
            return 1;
        }

        program = compile_frontend_simple(src_files, debug);
    }

    if (!program)
        return 1;

    codegen::CodeGen cg("yc");
    if (!cg.generate(*program))
    {
        std::cerr << "codegen failed\n";
        return 1;
    }

    if (emit_ir_only || debug)
    {
        std::cout << "--- LLVM IR ---\n";
        cg.dump_llvm_ir();
    }

    fs::path base = src_files.size() == 1 ? src_files[0] : fs::path("merged");
    fs::path out_file = output_dir / (base.stem().string() + ".ll");

    cg.write_ir_to_file(out_file.string());
    std::cout << "Wrote IR to " << out_file << "\n";

    return 0;
}
