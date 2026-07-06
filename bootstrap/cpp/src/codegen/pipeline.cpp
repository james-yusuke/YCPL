#include "codegen.h"

#include <llvm/IR/Verifier.h>

namespace codegen
{
    bool CodeGen::generate(const ast::Program &prog)
    {
        failed = false;

        prepare_struct_types(prog);

        std::vector<const ast::FuncDecl *> funcPtrs;
        for (const auto &d : prog.decls)
        {
            if (auto fd = dynamic_cast<const ast::FuncDecl *>(d.get()))
                funcPtrs.push_back(fd);
        }
        if (!funcPtrs.empty())
            predeclare_functions(funcPtrs);

        for (const auto &d : prog.decls)
        {
            if (auto fd = dynamic_cast<const ast::FuncDecl *>(d.get()))
                codegen_function_decl(fd);
        }

        for (const auto &d : prog.decls)
        {
            if (dynamic_cast<const ast::StmtDecl *>(d.get()))
                error("top-level statements are not supported in codegen (please define fn main)");
        }

        if (verifyModule(*module, &llvm::errs()))
        {
            error("module verification failed");
            return false;
        }

        return !failed;
    }
}
