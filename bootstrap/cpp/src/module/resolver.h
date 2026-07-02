#pragma once

#include "../ast/ast.h"
#include <string>
#include <vector>
#include <unordered_map>
#include <unordered_set>
#include <filesystem>
#include <optional>
#include <memory>

namespace module
{

    struct ProjectConfig
    {
        std::string name;
        std::string version;
        std::string entry;
        std::vector<std::string> src_dirs;
        std::string output_dir;
        std::vector<std::string> dependencies;

        static std::optional<ProjectConfig> load(const std::filesystem::path &path);
    };

    struct SymbolInfo
    {
        std::string name;
        std::string module_path;
        std::string link_name;
        bool is_public;
        bool is_function;
        bool is_struct;
        const ast::Decl *decl;
    };

    struct ModuleInfo
    {
        std::string module_name;
        std::filesystem::path file_path;
        std::unique_ptr<ast::Program> program;
        std::unordered_map<std::string, SymbolInfo> exported_symbols;
        std::vector<std::string> imports;
        std::unordered_map<std::string, std::string> import_aliases;
        std::unordered_map<std::string, std::string> import_targets;
        bool is_virtual_std = false;
    };

    class ModuleResolver
    {
    public:
        ModuleResolver();

        void set_project_root(const std::filesystem::path &root);
        void add_source_dir(const std::filesystem::path &dir);

        bool resolve_all(const std::vector<std::filesystem::path> &sources);

        std::unique_ptr<ast::Program> link_program();

        const SymbolInfo *resolve_symbol(const std::string &name, const std::string &from_module);

        const std::unordered_map<std::string, ModuleInfo> &get_modules() const { return modules_; }

        bool has_errors() const { return !errors_.empty(); }
        const std::vector<std::string> &get_errors() const { return errors_; }

    private:
        std::filesystem::path project_root_;
        std::vector<std::filesystem::path> source_dirs_;
        std::unordered_map<std::string, ModuleInfo> modules_;
        std::unordered_map<std::string, std::string> file_to_module_;
        std::vector<std::string> errors_;

        bool parse_file(const std::filesystem::path &file);
        void extract_exports(ModuleInfo &info);
        bool resolve_imports();
        bool rewrite_modules();
        std::filesystem::path resolve_import_path(const std::string &import_path, const std::filesystem::path &from_file);
        void emit_error(const std::string &msg);
    };

}
