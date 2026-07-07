#include "resolver.h"
#include "json.h"
#include "../lexer/lexer.h"
#include "../parser/parser.h"
#include <fstream>
#include <sstream>
#include <iostream>
#include <algorithm>

namespace module
{
    static std::string default_alias_for_import(const std::string &path)
    {
        size_t slash = path.find_last_of("/.");
        if (slash == std::string::npos || slash + 1 >= path.size())
            return path;
        return path.substr(slash + 1);
    }

    static std::string sanitize_module_name(const std::string &name)
    {
        std::string out;
        out.reserve(name.size());
        for (char c : name)
        {
            if ((c >= 'a' && c <= 'z') || (c >= 'A' && c <= 'Z') || (c >= '0' && c <= '9') || c == '_')
                out.push_back(c);
            else
                out += "__";
        }
        return out;
    }

    static std::string mangle_symbol(const std::string &module_name, const std::string &name)
    {
        if (name == "main")
            return "main";
        return sanitize_module_name(module_name) + "__" + name;
    }

    static bool is_std_import(const std::string &path)
    {
        return path == "std/fmt" || path == "std/array" || path == "std/mem" || path == "std/str" || path == "std/math";
    }

    static std::vector<std::string> std_symbols_for(const std::string &path)
    {
        if (path == "std/fmt")
            return {"print", "println", "printf"};
        if (path == "std/array")
            return {"new", "len", "cap", "append", "get", "set", "free"};
        if (path == "std/mem")
            return {"alloc", "calloc", "realloc", "free", "copy", "set", "sizeof"};
        if (path == "std/str")
            return {"len", "eq", "cmp", "copy"};
        if (path == "std/math")
            return {"abs", "pow", "sin", "cos", "sqrt"};
        return {};
    }

    static std::string std_intrinsic_name(const std::string &path, const std::string &symbol)
    {
        return "__YCPL_" + sanitize_module_name(path) + "_" + symbol;
    }

    static std::string module_intrinsic_name(const std::string &module_name, const std::string &symbol)
    {
        return "__YCPL_" + sanitize_module_name(module_name) + "_" + symbol;
    }

    static bool is_std_module_name(const std::string &module_name)
    {
        return module_name == "std" || module_name == "std2" ||
               module_name.rfind("std.", 0) == 0 || module_name.rfind("std/", 0) == 0 ||
               module_name.rfind("std2.", 0) == 0 || module_name.rfind("std2/", 0) == 0;
    }

    static std::vector<std::string> member_path(const ast::Expr *expr)
    {
        if (auto id = dynamic_cast<const ast::Ident *>(expr))
            return {id->name};
        if (auto member = dynamic_cast<const ast::MemberExpr *>(expr))
        {
            auto parts = member_path(member->object.get());
            parts.push_back(member->member);
            return parts;
        }
        return {};
    }

    static void rewrite_expr(std::unique_ptr<ast::Expr> &expr,
                             ModuleInfo &info,
                             const std::unordered_map<std::string, std::string> &local_functions,
                             const std::unordered_map<std::string, ModuleInfo> &modules,
                             std::vector<std::string> &errors);

    static bool imported_symbol_exists(const std::string &name,
                                       const ModuleInfo &info,
                                       const std::unordered_map<std::string, ModuleInfo> &modules)
    {
        for (const auto &target_pair : info.import_targets)
        {
            if (target_pair.second.empty())
                continue;
            auto mod_it = modules.find(target_pair.second);
            if (mod_it == modules.end())
                continue;
            if (mod_it->second.exported_symbols.find(name) != mod_it->second.exported_symbols.end())
                return true;
        }
        return false;
    }

    static const SymbolInfo *find_unique_imported_function(const std::string &name,
                                                           const ModuleInfo &info,
                                                           const std::unordered_map<std::string, ModuleInfo> &modules)
    {
        const SymbolInfo *matched = nullptr;
        for (const auto &target_pair : info.import_targets)
        {
            if (target_pair.second.empty())
                continue;
            auto mod_it = modules.find(target_pair.second);
            if (mod_it == modules.end())
                continue;
            auto sym_it = mod_it->second.exported_symbols.find(name);
            if (sym_it == mod_it->second.exported_symbols.end() || !sym_it->second.is_function)
                continue;
            if (matched)
                return nullptr;
            matched = &sym_it->second;
        }
        return matched;
    }

    static void rewrite_stmt(std::unique_ptr<ast::Stmt> &stmt,
                             ModuleInfo &info,
                             const std::unordered_map<std::string, std::string> &local_functions,
                             const std::unordered_map<std::string, ModuleInfo> &modules,
                             std::vector<std::string> &errors)
    {
        if (!stmt)
            return;

        if (auto es = dynamic_cast<ast::ExprStmt *>(stmt.get()))
        {
            rewrite_expr(es->expr, info, local_functions, modules, errors);
        }
        else if (auto rs = dynamic_cast<ast::ReturnStmt *>(stmt.get()))
        {
            rewrite_expr(rs->expr, info, local_functions, modules, errors);
        }
        else if (auto ds = dynamic_cast<ast::DeferStmt *>(stmt.get()))
        {
            rewrite_stmt(ds->stmt, info, local_functions, modules, errors);
        }
        else if (auto ss = dynamic_cast<ast::ScopeStmt *>(stmt.get()))
        {
            if (ss->body)
                for (auto &s : ss->body->stmts)
                    rewrite_stmt(s, info, local_functions, modules, errors);
        }
        else if (auto vd = dynamic_cast<ast::VarDecl *>(stmt.get()))
        {
            rewrite_expr(vd->init, info, local_functions, modules, errors);
        }
        else if (auto as = dynamic_cast<ast::AssignStmt *>(stmt.get()))
        {
            rewrite_expr(as->target, info, local_functions, modules, errors);
            rewrite_expr(as->value, info, local_functions, modules, errors);
        }
        else if (auto blk = dynamic_cast<ast::BlockStmt *>(stmt.get()))
        {
            for (auto &s : blk->stmts)
                rewrite_stmt(s, info, local_functions, modules, errors);
        }
        else if (auto ifs = dynamic_cast<ast::IfStmt *>(stmt.get()))
        {
            rewrite_expr(ifs->cond, info, local_functions, modules, errors);
            if (ifs->then_blk)
                for (auto &s : ifs->then_blk->stmts)
                    rewrite_stmt(s, info, local_functions, modules, errors);
            if (ifs->else_blk)
                for (auto &s : ifs->else_blk->stmts)
                    rewrite_stmt(s, info, local_functions, modules, errors);
        }
        else if (auto sw = dynamic_cast<ast::SwitchStmt *>(stmt.get()))
        {
            rewrite_expr(sw->value, info, local_functions, modules, errors);
            for (auto &caseNode : sw->cases)
            {
                rewrite_expr(caseNode.value, info, local_functions, modules, errors);
                if (caseNode.body)
                    for (auto &s : caseNode.body->stmts)
                        rewrite_stmt(s, info, local_functions, modules, errors);
            }
            if (sw->default_body)
                for (auto &s : sw->default_body->stmts)
                    rewrite_stmt(s, info, local_functions, modules, errors);
        }
        else if (auto fs = dynamic_cast<ast::ForInStmt *>(stmt.get()))
        {
            rewrite_expr(fs->iterable, info, local_functions, modules, errors);
            if (fs->body)
                for (auto &s : fs->body->stmts)
                    rewrite_stmt(s, info, local_functions, modules, errors);
        }
        else if (auto fs = dynamic_cast<ast::ForStmt *>(stmt.get()))
        {
            if (fs->body)
                for (auto &s : fs->body->stmts)
                    rewrite_stmt(s, info, local_functions, modules, errors);
        }
        else if (auto fs = dynamic_cast<ast::ForCStyleStmt *>(stmt.get()))
        {
            rewrite_stmt(fs->init, info, local_functions, modules, errors);
            rewrite_expr(fs->cond, info, local_functions, modules, errors);
            rewrite_expr(fs->post, info, local_functions, modules, errors);
            if (fs->body)
                for (auto &s : fs->body->stmts)
                    rewrite_stmt(s, info, local_functions, modules, errors);
        }
    }

    static void rewrite_expr(std::unique_ptr<ast::Expr> &expr,
                             ModuleInfo &info,
                             const std::unordered_map<std::string, std::string> &local_functions,
                             const std::unordered_map<std::string, ModuleInfo> &modules,
                             std::vector<std::string> &errors)
    {
        if (!expr)
            return;

        if (auto call = dynamic_cast<ast::CallExpr *>(expr.get()))
        {
            for (auto &arg : call->args)
                rewrite_expr(arg, info, local_functions, modules, errors);

            if (auto id = dynamic_cast<ast::Ident *>(call->callee.get()))
            {
                auto local_it = local_functions.find(id->name);
                if (local_it != local_functions.end())
                {
                    id->name = local_it->second;
                }
                else if (imported_symbol_exists(id->name, info, modules))
                {
                    errors.push_back("Imported symbol '" + id->name + "' must be called through its import alias in module " + info.module_name);
                }
                return;
            }

            auto parts = member_path(call->callee.get());
            if (parts.size() >= 2)
            {
                const std::string &alias = parts.front();
                const std::string &symbol = parts.back();
                auto target_it = info.import_targets.find(alias);
                if (target_it != info.import_targets.end())
                {
                    const std::string &target_module = target_it->second;
                    if (is_std_import(target_module))
                    {
                        call->callee = std::make_unique<ast::Ident>(std_intrinsic_name(target_module, symbol));
                        return;
                    }

                    auto mod_it = modules.find(target_module);
                    if (mod_it == modules.end())
                    {
                        errors.push_back("Cannot resolve import alias '" + alias + "' in module " + info.module_name);
                        return;
                    }
                    auto sym_it = mod_it->second.exported_symbols.find(symbol);
                    if (sym_it == mod_it->second.exported_symbols.end() || !sym_it->second.is_function)
                    {
                        errors.push_back("Module '" + target_module + "' has no public function '" + symbol + "'");
                        return;
                    }
                    call->callee = std::make_unique<ast::Ident>(sym_it->second.link_name);
                    return;
                }
            }

            if (auto member = dynamic_cast<ast::MemberExpr *>(call->callee.get()))
            {
                const SymbolInfo *ufcs = find_unique_imported_function(member->member, info, modules);
                if (ufcs)
                {
                    std::unique_ptr<ast::Expr> receiver = std::move(member->object);
                    rewrite_expr(receiver, info, local_functions, modules, errors);
                    call->args.insert(call->args.begin(), std::move(receiver));
                    call->callee = std::make_unique<ast::Ident>(ufcs->link_name);
                    return;
                }
            }

            rewrite_expr(call->callee, info, local_functions, modules, errors);
            return;
        }

        if (auto unary = dynamic_cast<ast::UnaryExpr *>(expr.get()))
        {
            rewrite_expr(unary->rhs, info, local_functions, modules, errors);
        }
        else if (auto binary = dynamic_cast<ast::BinaryExpr *>(expr.get()))
        {
            rewrite_expr(binary->left, info, local_functions, modules, errors);
            rewrite_expr(binary->right, info, local_functions, modules, errors);
        }
        else if (auto array = dynamic_cast<ast::ArrayLiteral *>(expr.get()))
        {
            for (auto &elem : array->elements)
                rewrite_expr(elem, info, local_functions, modules, errors);
        }
        else if (auto bytes = dynamic_cast<ast::ByteArrayLiteral *>(expr.get()))
        {
            for (auto &elem : bytes->elems)
                rewrite_expr(elem, info, local_functions, modules, errors);
        }
        else if (auto member = dynamic_cast<ast::MemberExpr *>(expr.get()))
        {
            rewrite_expr(member->object, info, local_functions, modules, errors);
        }
        else if (auto index = dynamic_cast<ast::IndexExpr *>(expr.get()))
        {
            rewrite_expr(index->collection, info, local_functions, modules, errors);
            rewrite_expr(index->index, info, local_functions, modules, errors);
        }
        else if (auto postfix = dynamic_cast<ast::PostfixExpr *>(expr.get()))
        {
            rewrite_expr(postfix->lhs, info, local_functions, modules, errors);
        }
        else if (auto literal = dynamic_cast<ast::StructLiteral *>(expr.get()))
        {
            for (auto &init : literal->inits)
                rewrite_expr(init.value, info, local_functions, modules, errors);
        }
    }

    std::optional<ProjectConfig> ProjectConfig::load(const std::filesystem::path &path)
    {
        auto json = load_json_file(path.string());
        if (!json)
        {
            return std::nullopt;
        }

        if (!json->is_object())
        {
            std::cerr << "YCPL.json must be an object\n";
            return std::nullopt;
        }

        ProjectConfig config;
        config.name = json->value("name", "unnamed");
        config.version = json->value("version", "0.0.0");
        config.entry = json->value("entry", "main.yc");
        config.output_dir = json->value("output", "build/");

        auto src_val = json->get("src");
        if (src_val)
        {
            if (src_val->is_array())
            {
                for (const auto &s : src_val->as_array())
                {
                    if (s.is_string())
                        config.src_dirs.push_back(s.as_string());
                }
            }
            else if (src_val->is_string())
            {
                config.src_dirs.push_back(src_val->as_string());
            }
        }
        else
        {
            config.src_dirs.push_back("src/");
        }

        auto deps_val = json->get("dependencies");
        if (deps_val && deps_val->is_array())
        {
            for (const auto &dep : deps_val->as_array())
            {
                if (dep.is_string())
                {
                    config.dependencies.push_back(dep.as_string());
                }
            }
        }

        return config;
    }

    ModuleResolver::ModuleResolver() = default;

    void ModuleResolver::set_project_root(const std::filesystem::path &root)
    {
        project_root_ = std::filesystem::canonical(root);
    }

    void ModuleResolver::add_source_dir(const std::filesystem::path &dir)
    {
        source_dirs_.push_back(dir);
    }

    bool ModuleResolver::resolve_all(const std::vector<std::filesystem::path> &sources)
    {
        for (const auto &file : sources)
        {
            if (!parse_file(file))
            {
                return false;
            }
        }

        for (auto &pair : modules_)
        {
            extract_exports(pair.second);
        }

        if (!resolve_imports())
        {
            return false;
        }

        if (!rewrite_modules())
        {
            return false;
        }

        return true;
    }

    bool ModuleResolver::parse_file(const std::filesystem::path &file)
    {
        std::filesystem::path normalized_file = std::filesystem::weakly_canonical(file);
        std::ifstream in(normalized_file);
        if (!in.is_open())
        {
            emit_error("Failed to open file: " + normalized_file.string());
            return false;
        }

        std::stringstream buf;
        buf << in.rdbuf();
        std::string source = buf.str();
        size_t parse_error_base = errors_.size();

        auto lex_err = [this, &normalized_file](int line, int col, const std::string &msg)
        {
            emit_error("[lexer] " + normalized_file.string() + ":" + std::to_string(line) + ":" + std::to_string(col) + " " + msg);
        };

        auto parse_err = [this, &normalized_file](int line, int col, const std::string &msg)
        {
            emit_error("[parser] " + normalized_file.string() + ":" + std::to_string(line) + ":" + std::to_string(col) + " " + msg);
        };

        lex::Lexer lx(source, lex_err);
        path::Parser parser(lx, parse_err);
        auto program = parser.parse_program();

        if (!program || errors_.size() > parse_error_base)
        {
            emit_error("Failed to parse: " + normalized_file.string());
            return false;
        }

        ModuleInfo info;
        info.file_path = normalized_file;
        info.program = std::move(program);

        std::string module_name = file.stem().string();
        for (auto &decl : info.program->decls)
        {
            if (auto mod_decl = dynamic_cast<ast::ModuleDecl *>(decl.get()))
            {
                module_name = mod_decl->name;
                break;
            }
        }

        info.module_name = module_name;
        file_to_module_[normalized_file.string()] = module_name;

        bool ok = true;
        for (auto &decl : info.program->decls)
        {
            if (auto import_decl = dynamic_cast<ast::ImportDecl *>(decl.get()))
            {
                info.imports.push_back(import_decl->path);
                std::string alias = import_decl->alias.value_or(default_alias_for_import(import_decl->path));
                if (info.import_aliases.find(alias) != info.import_aliases.end())
                {
                    emit_error("Duplicate import alias '" + alias + "' in " + normalized_file.string());
                    ok = false;
                }
                info.import_aliases[alias] = import_decl->path;
            }
            else if (auto fn = dynamic_cast<ast::FuncDecl *>(decl.get()))
            {
                fn->module_name = module_name;
                if (fn->is_extern && fn->is_intrinsic)
                {
                    emit_error("Function cannot be both extern and intrinsic: " + fn->name);
                    ok = false;
                }
                if ((fn->is_extern || fn->is_intrinsic) && fn->body)
                {
                    emit_error((fn->is_extern ? "extern" : "intrinsic") + std::string(" function cannot have a body: ") + fn->name);
                    ok = false;
                }
                if (fn->is_intrinsic && !is_std_module_name(module_name))
                {
                    emit_error("intrinsic functions are only allowed in std modules: " + fn->name);
                    ok = false;
                }

                if (fn->is_intrinsic)
                    fn->link_name = module_intrinsic_name(module_name, fn->name);
                else if (fn->is_extern)
                    fn->link_name = fn->extern_name.value_or(fn->name);
                else
                    fn->link_name = mangle_symbol(module_name, fn->name);
            }
        }

        modules_[module_name] = std::move(info);
        return ok;
    }

    void ModuleResolver::extract_exports(ModuleInfo &info)
    {
        for (auto &decl : info.program->decls)
        {
            if (auto fn = dynamic_cast<ast::FuncDecl *>(decl.get()))
            {
                if (fn->is_pub)
                {
                    SymbolInfo sym;
                    sym.name = fn->name;
                    sym.module_path = info.module_name;
                    sym.link_name = fn->link_name.empty() ? mangle_symbol(info.module_name, fn->name) : fn->link_name;
                    sym.is_public = true;
                    sym.is_function = true;
                    sym.is_struct = false;
                    sym.decl = fn;
                    info.exported_symbols[fn->name] = sym;
                }
            }
            else if (auto st = dynamic_cast<ast::StructDecl *>(decl.get()))
            {
                if (st->is_pub)
                {
                    SymbolInfo sym;
                    sym.name = st->name;
                    sym.module_path = info.module_name;
                    sym.link_name = mangle_symbol(info.module_name, st->name);
                    sym.is_public = true;
                    sym.is_function = false;
                    sym.is_struct = true;
                    sym.decl = st;
                    info.exported_symbols[st->name] = sym;
                }
            }
        }
    }

    std::filesystem::path ModuleResolver::resolve_import_path(const std::string &import_path, const std::filesystem::path &from_file)
    {
        if (!import_path.empty() && import_path[0] == '.')
        {
            std::filesystem::path base = from_file.parent_path();
            std::filesystem::path resolved = base / (import_path + ".yc");
            if (std::filesystem::exists(resolved))
            {
                return resolved;
            }
            resolved = base / import_path / "index.yc";
            if (std::filesystem::exists(resolved))
            {
                return resolved;
            }
        }

        auto resolve_under = [&](const std::filesystem::path &root) -> std::filesystem::path
        {
            std::filesystem::path resolved = root / (import_path + ".yc");
            if (std::filesystem::exists(resolved))
            {
                return resolved;
            }
            resolved = root / import_path / "index.yc";
            if (std::filesystem::exists(resolved))
            {
                return resolved;
            }
            return {};
        };

        for (const auto &src_dir : source_dirs_)
        {
            std::filesystem::path full_dir = project_root_ / src_dir;
            std::filesystem::path resolved = resolve_under(full_dir);
            if (!resolved.empty())
            {
                return resolved;
            }
        }

        std::filesystem::path search = project_root_;
        for (int i = 0; i < 12; ++i)
        {
            std::filesystem::path resolved = resolve_under(search / "stl");
            if (!resolved.empty())
            {
                return resolved;
            }

            std::filesystem::path parent = search.parent_path();
            if (parent == search)
                break;
            search = parent;
        }

        return {};
    }

    bool ModuleResolver::resolve_imports()
    {
        bool success = true;
        bool changed = true;

        while (changed)
        {
            changed = false;
            std::vector<std::string> module_names;
            module_names.reserve(modules_.size());
            for (const auto &pair : modules_)
            {
                if (!pair.second.is_virtual_std)
                    module_names.push_back(pair.first);
            }

            for (const auto &module_name : module_names)
            {
                auto module_it = modules_.find(module_name);
                if (module_it == modules_.end())
                    continue;

                std::filesystem::path from_file = module_it->second.file_path;
                std::vector<std::pair<std::string, std::string>> aliases(module_it->second.import_aliases.begin(), module_it->second.import_aliases.end());

                for (const auto &alias_pair : aliases)
                {
                    const std::string &alias = alias_pair.first;
                    const std::string &import_path = alias_pair.second;

                    auto current_it = modules_.find(module_name);
                    if (current_it == modules_.end())
                        continue;
                    if (current_it->second.import_targets.find(alias) != current_it->second.import_targets.end())
                        continue;

                    std::filesystem::path resolved = resolve_import_path(import_path, from_file);
                    if (resolved.empty())
                    {
                        if (is_std_import(import_path))
                        {
                            if (modules_.find(import_path) == modules_.end())
                            {
                                ModuleInfo std_info;
                                std_info.module_name = import_path;
                                std_info.is_virtual_std = true;
                                for (const auto &symbol : std_symbols_for(import_path))
                                {
                                    SymbolInfo sym;
                                    sym.name = symbol;
                                    sym.module_path = import_path;
                                    sym.link_name = std_intrinsic_name(import_path, symbol);
                                    sym.is_public = true;
                                    sym.is_function = true;
                                    sym.is_struct = false;
                                    sym.decl = nullptr;
                                    std_info.exported_symbols[symbol] = sym;
                                }
                                modules_[import_path] = std::move(std_info);
                            }
                            modules_[module_name].import_targets[alias] = import_path;
                            continue;
                        }

                        emit_error("Cannot resolve import: " + import_path + " (from " + from_file.string() + ")");
                        success = false;
                        modules_[module_name].import_targets[alias] = "";
                        continue;
                    }

                    resolved = std::filesystem::weakly_canonical(resolved);
                    auto it = file_to_module_.find(resolved.string());
                    if (it == file_to_module_.end())
                    {
                        if (!parse_file(resolved))
                        {
                            success = false;
                            modules_[module_name].import_targets[alias] = "";
                            continue;
                        }

                        auto parsed_it = file_to_module_.find(resolved.string());
                        if (parsed_it != file_to_module_.end())
                        {
                            extract_exports(modules_[parsed_it->second]);
                            modules_[module_name].import_targets[alias] = parsed_it->second;
                            changed = true;
                        }
                    }
                    else
                    {
                        modules_[module_name].import_targets[alias] = it->second;
                    }
                }
            }
        }

        return success;
    }

    std::unique_ptr<ast::Program> ModuleResolver::link_program()
    {
        auto merged = std::make_unique<ast::Program>();

        std::vector<std::unique_ptr<ast::Decl>> named_decls;
        std::vector<std::unique_ptr<ast::Decl>> struct_decls;
        std::vector<std::unique_ptr<ast::Decl>> func_decls;

        for (auto &pair : modules_)
        {
            if (pair.second.is_virtual_std || !pair.second.program)
                continue;

            for (auto &decl : pair.second.program->decls)
            {
                if (dynamic_cast<ast::ImportDecl *>(decl.get()))
                {
                    continue;
                }

                if (dynamic_cast<ast::ModuleDecl *>(decl.get()))
                {
                    continue;
                }

                if (dynamic_cast<ast::StmtDecl *>(decl.get()))
                {
                    continue;
                }

                if (dynamic_cast<ast::EnumDecl *>(decl.get()) || dynamic_cast<ast::TypeAliasDecl *>(decl.get()))
                {
                    named_decls.push_back(std::move(decl));
                }
                else if (dynamic_cast<ast::StructDecl *>(decl.get()))
                {
                    struct_decls.push_back(std::move(decl));
                }
                else if (dynamic_cast<ast::FuncDecl *>(decl.get()))
                {
                    func_decls.push_back(std::move(decl));
                }
            }
        }

        for (auto &nd : named_decls)
            merged->decls.push_back(std::move(nd));
        for (auto &sd : struct_decls)
            merged->decls.push_back(std::move(sd));
        for (auto &fd : func_decls)
            merged->decls.push_back(std::move(fd));

        return merged;
    }

    bool ModuleResolver::rewrite_modules()
    {
        bool success = true;

        for (auto &pair : modules_)
        {
            ModuleInfo &info = pair.second;
            if (info.is_virtual_std || !info.program)
                continue;

            std::unordered_map<std::string, std::string> local_functions;
            for (auto &decl : info.program->decls)
            {
                if (auto fn = dynamic_cast<ast::FuncDecl *>(decl.get()))
                {
                    fn->module_name = info.module_name;
                    if (fn->link_name.empty())
                        fn->link_name = mangle_symbol(info.module_name, fn->name);
                    local_functions[fn->name] = fn->link_name;
                }
            }

            std::vector<std::string> rewrite_errors;
            for (auto &decl : info.program->decls)
            {
                if (auto fn = dynamic_cast<ast::FuncDecl *>(decl.get()))
                {
                    if (fn->body)
                    {
                        for (auto &stmt : fn->body->stmts)
                            rewrite_stmt(stmt, info, local_functions, modules_, rewrite_errors);
                    }
                }
                else if (auto sd = dynamic_cast<ast::StmtDecl *>(decl.get()))
                {
                    rewrite_stmt(sd->stmt, info, local_functions, modules_, rewrite_errors);
                }
            }

            for (const auto &err : rewrite_errors)
            {
                emit_error(err);
                success = false;
            }
        }

        return success;
    }

    const SymbolInfo *ModuleResolver::resolve_symbol(const std::string &name, const std::string &from_module)
    {
        auto it = modules_.find(from_module);
        if (it == modules_.end())
        {
            return nullptr;
        }

        for (const auto &target_pair : it->second.import_targets)
        {
            auto mod_it = modules_.find(target_pair.second);
            if (mod_it != modules_.end())
            {
                auto sym_it = mod_it->second.exported_symbols.find(name);
                if (sym_it != mod_it->second.exported_symbols.end())
                {
                    return &sym_it->second;
                }
            }
        }

        return nullptr;
    }

    void ModuleResolver::emit_error(const std::string &msg)
    {
        errors_.push_back(msg);
        std::cerr << "[module error] " << msg << "\n";
    }

}
