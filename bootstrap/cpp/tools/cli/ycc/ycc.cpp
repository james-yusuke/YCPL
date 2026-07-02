#include "src/lexer/lexer.h"
#include "src/parser/parser.h"
#include "src/ast/printer.h"
#include "src/codegen/codegen.h"
#include "src/module/resolver.h"

#include <iostream>
#include <fstream>
#include <sstream>
#include <filesystem>
#include <vector>
#include <memory>
#include <cstdlib>
#include <cstdio>
#include <array>

namespace fs = std::filesystem;

enum class OutputMode
{
    BuildNative,
    EmitIR,
    Debug
};

static void print_help(const char *exec)
{
    std::cout << "Usage:\n"
                 "  "
              << exec << " build [options] <file.yc | dir>\n"
                         "  "
              << exec << " build-ir [options] <file1.yc file2.yc ...>\n"
                         "\n"
                         "Modes:\n"
                         "  build             Build a native executable (default)\n"
                         "  build-ir          Emit LLVM IR only\n"
                         "  ll                Alias for build-ir\n"
                         "  debug             Show tokens, AST, and LLVM IR\n"
                         "  help              Show this help\n"
                         "\n"
                         "Options:\n"
                         "  -o <dir>          Output directory (default: current directory)\n"
                         "  --keep-obj        Keep the intermediate object file when building native\n"
                         "  --link-llvm       Link LLVM C API libraries from llvm-config\n"
                         "\n"
                         "Examples:\n"
                         "  "
              << exec << " build main.yc -o build\n"
                         "  "
              << exec << " build-ir src/ -o build\n"
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

static std::string shell_quote(const fs::path &path)
{
    std::string text = path.string();
    std::string quoted = "'";
    for (char ch : text)
    {
        if (ch == '\'')
            quoted += "'\\''";
        else
            quoted += ch;
    }
    quoted += "'";
    return quoted;
}

static std::string shell_quote(const std::string &text)
{
    return shell_quote(fs::path(text));
}

static bool executable_exists(const fs::path &path)
{
    return fs::exists(path) && !fs::is_directory(path);
}

static std::string capture_command_output(const std::string &command)
{
    std::array<char, 256> buffer{};
    std::string output;
    FILE *pipe = popen(command.c_str(), "r");
    if (!pipe)
        return "";

    while (fgets(buffer.data(), static_cast<int>(buffer.size()), pipe) != nullptr)
        output += buffer.data();
    pclose(pipe);

    return output;
}

static std::string trim_text(const std::string &text)
{
    const std::string whitespace = " \t\r\n";
    size_t start = text.find_first_not_of(whitespace);
    if (start == std::string::npos)
        return "";
    size_t end = text.find_last_not_of(whitespace);
    return text.substr(start, end - start + 1);
}

static std::string llvm_config_bindir(const fs::path &llvm_config)
{
    if (!executable_exists(llvm_config))
        return "";

    std::string command = shell_quote(llvm_config) + " --bindir 2>/dev/null";
    return trim_text(capture_command_output(command));
}

static std::string find_llvm_config_command()
{
    if (const char *llvm_config = std::getenv("LLVM_CONFIG"))
    {
        fs::path config_path(llvm_config);
        if (executable_exists(config_path))
            return config_path.string();
    }

    std::vector<fs::path> candidates = {
        "/opt/homebrew/opt/llvm@22/bin/llvm-config",
        "/opt/homebrew/opt/llvm/bin/llvm-config",
        "/usr/local/opt/llvm@22/bin/llvm-config",
        "/usr/local/opt/llvm/bin/llvm-config",
        "/usr/lib/llvm-22/bin/llvm-config",
    };

    for (const auto &candidate : candidates)
    {
        if (executable_exists(candidate))
            return candidate.string();
    }

    for (const std::string &candidate : {"llvm-config-22", "llvm-config22", "llvm-config"})
    {
        std::string probe = "command -v " + shell_quote(candidate) + " 2>/dev/null";
        std::string found = trim_text(capture_command_output(probe));
        if (!found.empty())
            return found;
    }

    return "";
}

static std::string command_from_env_or_path(const char *env_name, const std::string &tool)
{
    if (const char *explicit_tool = std::getenv(env_name))
    {
        if (explicit_tool[0] != '\0')
            return explicit_tool;
    }

    if (const char *llvm_bindir = std::getenv("LLVM_BINDIR"))
    {
        fs::path candidate = fs::path(llvm_bindir) / tool;
        if (executable_exists(candidate))
            return candidate.string();
    }

    if (const char *llvm_config = std::getenv("LLVM_CONFIG"))
    {
        fs::path config_path(llvm_config);
        if (executable_exists(config_path))
        {
            std::string bindir = llvm_config_bindir(config_path);
            if (!bindir.empty())
            {
                fs::path candidate = fs::path(bindir) / tool;
                if (executable_exists(candidate))
                    return candidate.string();
            }

            fs::path candidate = config_path.parent_path() / tool;
            if (executable_exists(candidate))
                return candidate.string();
        }
    }

    std::vector<fs::path> candidates = {
        fs::path("/opt/homebrew/opt/llvm@22/bin") / tool,
        fs::path("/opt/homebrew/opt/llvm/bin") / tool,
        fs::path("/usr/local/opt/llvm@22/bin") / tool,
        fs::path("/usr/local/opt/llvm/bin") / tool,
        fs::path("/usr/lib/llvm-22/bin") / tool,
    };

    for (const auto &candidate : candidates)
    {
        if (executable_exists(candidate))
            return candidate.string();
    }

    return tool;
}

static bool run_shell_command(const std::string &command)
{
    int rc = std::system(command.c_str());
    return rc == 0;
}

static std::vector<std::string> split_flags(const char *flags)
{
    std::vector<std::string> result;
    if (!flags)
        return result;

    std::istringstream iss(flags);
    std::string part;
    while (iss >> part)
        result.push_back(part);
    return result;
}

static std::vector<std::string> split_flags(const std::string &flags)
{
    std::vector<std::string> result;
    std::istringstream iss(flags);
    std::string part;
    while (iss >> part)
        result.push_back(part);
    return result;
}

struct LlvmLinkFlags
{
    std::vector<std::string> ldflags;
    std::vector<std::string> libs;
};

static LlvmLinkFlags llvm_link_flags()
{
    LlvmLinkFlags flags;
    std::string llvm_config = find_llvm_config_command();
    if (llvm_config.empty())
        return flags;

    flags.ldflags = split_flags(capture_command_output(shell_quote(llvm_config) + " --ldflags 2>/dev/null"));
    flags.libs = split_flags(capture_command_output(shell_quote(llvm_config) + " --libs core --system-libs 2>/dev/null"));
    return flags;
}

static bool module_references_llvm_c_api(const llvm::Module *module)
{
    if (!module)
        return false;

    for (const auto &fn : module->functions())
    {
        if (fn.isDeclaration() && fn.getName().starts_with("LLVM"))
            return true;
    }

    return false;
}

static bool build_native_executable(const fs::path &ll_file, const fs::path &binary_file, const fs::path &object_file, bool keep_obj, bool link_llvm)
{
    std::string llc = command_from_env_or_path("LLC", "llc");
    std::string clang = command_from_env_or_path("CLANG", "clang");

    std::string llc_cmd = shell_quote(llc) + " -filetype=obj " + shell_quote(ll_file) + " -o " + shell_quote(object_file);
    if (!run_shell_command(llc_cmd))
    {
        std::cerr << "llc failed: " << llc_cmd << "\n";
        return false;
    }

    std::string link_cmd = shell_quote(clang);
    for (const auto &flag : split_flags(std::getenv("LINKFLAGS")))
        link_cmd += " " + shell_quote(flag);

    LlvmLinkFlags llvm_flags;
    if (link_llvm)
    {
        llvm_flags = llvm_link_flags();
        if (llvm_flags.ldflags.empty() && llvm_flags.libs.empty())
        {
            std::cerr << "LLVM C API was referenced, but llvm-config was not found. Set LLVM_CONFIG or LLVM_BINDIR.\n";
            return false;
        }
        for (const auto &flag : llvm_flags.ldflags)
            link_cmd += " " + shell_quote(flag);
    }

    link_cmd += " " + shell_quote(object_file) + " -o " + shell_quote(binary_file);

    if (link_llvm)
    {
        for (const auto &flag : llvm_flags.libs)
            link_cmd += " " + shell_quote(flag);
    }

    link_cmd += " -lm";

    if (!run_shell_command(link_cmd))
    {
        std::cerr << "clang link failed: " << link_cmd << "\n";
        return false;
    }

    if (!keep_obj)
    {
        std::error_code ec;
        fs::remove(object_file, ec);
    }

    return true;
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

    OutputMode output_mode = OutputMode::BuildNative;
    bool debug = false;
    bool use_project_mode = false;
    bool keep_obj = false;
    bool link_llvm = false;
    bool output_dir_explicit = false;
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
            output_dir_explicit = true;
            i++;
        }
        else if (arg == "help")
        {
            print_help(argv[0]);
            return 0;
        }
        else if (arg == "ll" || arg == "build-ir" || arg == "ir")
        {
            output_mode = OutputMode::EmitIR;
        }
        else if (arg == "debug")
        {
            debug = true;
            output_mode = OutputMode::Debug;
        }
        else if (arg == "build")
        {
            output_mode = OutputMode::BuildNative;
        }
        else if (arg == "--keep-obj")
        {
            keep_obj = true;
        }
        else if (arg == "--link-llvm")
        {
            link_llvm = true;
        }
        else
        {
            inputs.push_back(arg);
        }
    }

    if (inputs.empty() && output_mode == OutputMode::BuildNative)
        use_project_mode = true;
    if (inputs.empty() && output_mode == OutputMode::EmitIR)
        use_project_mode = true;

    if (!fs::exists(output_dir))
    {
        fs::create_directories(output_dir);
    }

    std::unique_ptr<ast::Program> program;
    std::vector<fs::path> src_files;
    std::string output_base = "merged";

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
        if (!config->name.empty())
            output_base = config->name;

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
        
        if (!output_dir_explicit)
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
        if (src_files.size() == 1)
            output_base = src_files[0].stem().string();
    }

    if (!program)
        return 1;

    codegen::CodeGen cg("yc");
    if (!cg.generate(*program))
    {
        std::cerr << "codegen failed\n";
        return 1;
    }

    if (output_mode == OutputMode::Debug)
    {
        std::cout << "--- LLVM IR ---\n";
        cg.dump_llvm_ir();
    }

    fs::path out_file = output_dir / (output_base + ".ll");

    if (!cg.write_ir_to_file(out_file.string()))
    {
        std::cerr << "failed to write IR: " << out_file << "\n";
        return 1;
    }
    std::cout << "Wrote IR to " << out_file << "\n";

    if (output_mode == OutputMode::BuildNative)
    {
        fs::path object_file = output_dir / (output_base + ".o");
        fs::path binary_file = output_dir / output_base;
        bool should_link_llvm = link_llvm || module_references_llvm_c_api(cg.get_module());
        if (!build_native_executable(out_file, binary_file, object_file, keep_obj, should_link_llvm))
            return 1;
        std::cout << "Wrote binary to " << binary_file << "\n";
    }

    return 0;
}
