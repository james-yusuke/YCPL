#pragma once
#include "../ast/ast.h"
#include "arrays/layout.h"
#include "common.h"
#include <llvm/IR/IRBuilder.h>
#include <llvm/IR/LLVMContext.h>
#include <llvm/IR/Module.h>
#include <llvm/IR/Verifier.h>
#include <llvm/Support/TargetSelect.h>
#include <llvm/Support/raw_ostream.h>
#include <map>
#include <memory>
#include <string>
#include <unordered_map>
#include <utility>
#include <vector>

namespace codegen
{
    class CodeGen
    {
    public:
        CodeGen(const std::string &module_name = "module");
        ~CodeGen();

        bool generate(const ast::Program &prog);

        void dump_llvm_ir();

        bool write_ir_to_file(const std::string &path);

        llvm::Module *get_module() { return module.get(); }

    private:
        // Core LLVM state, owned for the lifetime of one compilation.
        llvm::LLVMContext context;
        std::unique_ptr<llvm::Module> module;
        llvm::IRBuilder<> builder;

        int g_byte_array_counter = 0;

        bool irdebug = false;

        // Lexical scopes and local type/const metadata.
        std::vector<std::map<std::string, llvm::Value *>> locals_stack;
        std::vector<std::map<std::string, std::string>> locals_stack_type;
        std::vector<std::map<std::string, bool>> locals_stack_const;
        std::unordered_map<std::string, llvm::Type *> localPointedType;
        std::unordered_map<std::string, llvm::Type *> globalPointedType;

        // Function and loop state shared by expression/statement lowering.
        std::map<std::string, llvm::Function *> function_protos;

        std::vector<llvm::BasicBlock *> break_targets;
        std::vector<llvm::BasicBlock *> continue_targets;

        // Struct registry prepared before function body generation.
        std::unordered_map<std::string, llvm::StructType *> struct_types;
        std::unordered_map<std::string, const ast::StructDecl *> struct_decls;

        llvm::StructType *lookup_struct_type(const std::string &name);

        std::pair<llvm::StructType *, llvm::Value *> resolve_struct_and_ptr(llvm::Value *v, const std::string &hintVarName);
        std::pair<llvm::StructType *, llvm::Value *> deduce_struct_type_and_ptr(llvm::Value *v, const std::string &hintVarName);

        void prepare_struct_types(const ast::Program &prog);
        llvm::Type *resolve_type_by_name(const std::string &typeName);
        llvm::Type *resolve_type_from_ast_local(const ast::Type *at);
        llvm::StructType *get_or_create_named_struct(const std::string &name);
        llvm::StructType *build_struct_type_from_decl(const ast::StructDecl *sd);

        llvm::Value *codegen_struct_literal(const ast::StructLiteral *sl);
        llvm::Value *codegen_member(const ast::MemberExpr *me);
        llvm::Value *codegen_member_addr(const ast::MemberExpr *me);
        int get_field_index(const ast::StructDecl *sd, const std::string &fieldName);

        llvm::StructType *get_struct_type_from_value(llvm::Value *v, const std::string &varname);

        llvm::Type *get_int_type();
        llvm::Type *get_i64_type();
        llvm::Type *get_double_type();
        llvm::Type *get_void_type();
        llvm::Type *get_i8ptr_type();

        llvm::Value *cast_to_integer_type(llvm::Value *v, llvm::Type *targetType);

        llvm::Value *coerce_to_i64(llvm::Value *value, const std::string &label);
        llvm::Value *coerce_to_i32(llvm::Value *value, const std::string &label);
        llvm::Value *coerce_to_double(llvm::Value *value, const std::string &label);
        llvm::Value *coerce_to_i8ptr(llvm::Value *value, const std::string &label);

        llvm::Value *array_header_ptr_from_value(llvm::Value *value, const std::string &label);
        llvm::Value *array_header_ptr_from_storage_or_value(llvm::Value *value, const std::string &label);
        llvm::Value *array_header_ptr_from_expr(const ast::Expr *expr, const std::string &label);
        llvm::Value *array_header_field_ptr(llvm::Value *arrayHeaderPtr, detail::RuntimeArrayField field, const std::string &label);
        llvm::Value *checked_array_element_data_ptr_from_values(llvm::Value *collectionValue, llvm::Value *indexValue, llvm::Value **elementSizeOut, const std::string &label);
        llvm::Value *checked_array_element_data_ptr(const ast::Expr *arrayExpr, const ast::Expr *indexExpr, llvm::Value **elementSizeOut);
        llvm::Value *coerce_index_to_i64(llvm::Value *indexValue, const std::string &label);
        llvm::Value *string_element_addr(llvm::Value *stringValue, llvm::Value *indexValue, const std::string &label);
        llvm::Value *string_element_value(llvm::Value *stringValue, llvm::Value *indexValue, const std::string &label);
        std::pair<bool, bool> infer_array_literal_element_shape(const ast::Expr *collectionExpr);

        llvm::Value *create_entry_alloca(llvm::Function *func, llvm::Type *type, const std::string &name);

        // Expression lowering.
        llvm::Value *codegen_expr(const ast::Expr *e);
        llvm::Value *codegen_literal(const ast::Literal *lit);
        llvm::Value *codegen_byte_array(const ast::ByteArrayLiteral *bal);
        llvm::Value *codegen_ident(const ast::Ident *id);
        llvm::Value *codegen_unary(const ast::UnaryExpr *ue);
        llvm::Value *codegen_binary(const ast::BinaryExpr *be);
        llvm::Value *codegen_call(const ast::CallExpr *ce);
        llvm::Value *codegen_std_intrinsic_call(const std::string &name, const ast::CallExpr *ce);
        llvm::Value *codegen_array_intrinsic_call(const std::string &name, const ast::CallExpr *ce);
        llvm::Value *codegen_array(const ast::ArrayLiteral *alit);
        llvm::Value *codegen_index(const ast::IndexExpr *ie);
        llvm::Value *codegen_postfix(const ast::PostfixExpr *pe);
        llvm::Value *codegen_index_addr(const ast::IndexExpr *ie);

        // Statement and control-flow lowering.
        llvm::Value *codegen_ifstmt(const ast::IfStmt *ifs);
        llvm::Value *codegen_for_loop(const ast::ForStmt *forStmt);
        llvm::Value *codegen_for_in_loop(const ast::ForInStmt *forInStmt);
        llvm::Value *codegen_append_call(const ast::CallExpr *ce);
        llvm::Value *codegen_println_call(const ast::CallExpr *ce);
        llvm::Value *codegen_printf_call(const ast::CallExpr *ce);
        llvm::Value *codegen_sprintf_call(const ast::CallExpr *ce);
        llvm::Value *codegen_len_call(const ast::CallExpr *ce);
        llvm::Value *codegen_cast_call(const ast::CallExpr *ce);
        llvm::Value *codegen_new_call(const ast::CallExpr *ce);
        llvm::Value *codegen_assign(const ast::AssignStmt *as);
        llvm::Value *codegen_vardecl(const ast::VarDecl *vd);
        llvm::Value *codegen_c_style_for_loop(const ast::ForCStyleStmt *forStmt);

        // Type and function lowering.
        llvm::Type *get_llvm_type_from_str(const std::string &typeStr, llvm::LLVMContext &ctx);

        llvm::Value *codegen_stmt(const ast::Stmt *s);
        llvm::Value *codegen_block(const ast::BlockStmt *blk);

        llvm::Function *codegen_function_decl(const ast::FuncDecl *fdecl);

        std::string resolve_type_name(ast::Type *tp);

        llvm::Type *resolve_type_from_ast(const ast::Type *at);

        // Runtime helpers and local symbol table helpers.
        llvm::FunctionCallee get_printf();
        llvm::Value *make_global_string(const std::string &str, const std::string &name = "");
        void push_scope();
        void pop_scope();
        void bind_local(const std::string &name, const std::string type, llvm::Value *v);
        void bind_local_const(const std::string &name, const std::string type, llvm::Value *v, bool is_const);
        llvm::Value *lookup_local(const std::string &name);
        llvm::Type *resolve_llvm_type_name(const std::string &typeName);
        std::string *lookup_local_type(const std::string &name);
        std::string infer_expr_type_name(const ast::Expr *expr);
        bool is_local_const(const std::string &name);

        void predeclare_functions(const std::vector<const ast::FuncDecl *> &funcs);
        llvm::Function *get_or_declare_c_function(const std::string &name);

        // Error state.
        void error(const std::string &msg);
        bool failed = false;
    };
}
