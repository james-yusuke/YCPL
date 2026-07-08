#pragma once
#include "../codegen.h"
#include "../common.h"
#include "../types/type_shape.h"
#include <llvm/IR/Constants.h>
#include <llvm/IR/DerivedTypes.h>
#include <llvm/IR/Intrinsics.h>
#include <memory>
#include <string>
#include <vector>

namespace codegen
{

llvm::Type *CodeGen::resolve_type_from_ast_local(const ast::Type *astType)
{
    if (!astType)
        return nullptr;

    if (auto namedType = dynamic_cast<const ast::NamedType *>(astType))
    {
        return resolve_type_by_name(namedType->name);
    }

    if (auto pointerType = dynamic_cast<const ast::PointerType *>(astType))
    {
        llvm::Type *innerType = resolve_type_from_ast_local(pointerType->base.get());
        if (!innerType)
            innerType = get_int_type();
        return codegen::detail::getPtrTy(context);
    }

    if (auto arrayType = dynamic_cast<const ast::ArrayType *>(astType))
    {
        llvm::Type *elementType = resolve_type_from_ast_local(arrayType->elem.get());
        if (!elementType)
            elementType = get_int_type();

        return codegen::detail::getPtrTy(context);
    }

    if (auto mapType = dynamic_cast<const ast::MapType *>(astType))
    {
        (void)mapType;
        return codegen::detail::getPtrTy(context);
    }

    if (auto funcTypeAst = dynamic_cast<const ast::FuncType *>(astType))
    {
        std::vector<llvm::Type *> paramTypes;
        for (const auto &param : funcTypeAst->params)
        {
            llvm::Type *paramType = resolve_type_from_ast_local(param.get());
            if (!paramType)
                paramType = get_int_type();
            paramTypes.push_back(paramType);
        }

        llvm::Type *returnType = nullptr;
        if (funcTypeAst->ret)
            returnType = resolve_type_from_ast_local(funcTypeAst->ret.get());
        if (!returnType)
            returnType = get_int_type();

        return codegen::detail::getPtrTy(context);
    }

    return nullptr;
}

void CodeGen::predeclare_functions(const std::vector<const ast::FuncDecl *> &funcDecls)
{
    for (const ast::FuncDecl *funcDecl : funcDecls)
    {
        if (!funcDecl)
            continue;

        if (funcDecl->is_intrinsic)
            continue;

        std::string llvmName = funcDecl->link_name.empty() ? funcDecl->name : funcDecl->link_name;
        bool is_main = (llvmName == "main");

        if (function_protos.find(llvmName) != function_protos.end())
            continue;

        bool isVarArg = false;
        if (!funcDecl->params.empty() && funcDecl->params.back().variadic)
            isVarArg = true;
        for (size_t i = 0; i + 1 < funcDecl->params.size(); ++i)
        {
            if (funcDecl->params[i].variadic)
            {
                error("variadic parameter must be the last parameter in function: " + llvmName);
                break;
            }
        }

        std::vector<Type *> argTypes;

        for (size_t i = 0; i < funcDecl->params.size(); ++i)
        {
            const auto &param = funcDecl->params[i];
            if (param.variadic)
            {
                continue;
            }

            llvm::Type *paramType = nullptr;
            if (param.type)
                paramType = resolve_type_from_ast_local(param.type.get());
            if (!paramType)
                paramType = get_int_type();
            argTypes.push_back(paramType);
        }

        Type *returnType = get_void_type();
        if (funcDecl->ret_type)
        {
            llvm::Type *rt = resolve_type_from_ast_local(funcDecl->ret_type.get());
            if (rt)
                returnType = rt;
            else
                returnType = get_int_type();
        }
        else if (is_main)
        {
            returnType = get_int_type();
        }

        FunctionType *functionType = FunctionType::get(returnType, argTypes, isVarArg);

        Function *existing = module->getFunction(llvmName);
        if (existing)
        {
            function_protos[llvmName] = existing;
            continue;
        }

        auto linkage = (funcDecl->is_extern || funcDecl->is_pub || is_main) ? Function::ExternalLinkage : Function::InternalLinkage;
        Function *fn = Function::Create(functionType, linkage, llvmName, module.get());

        unsigned argIndex = 0;
        for (auto &arg : fn->args())
        {
            if (argIndex < argTypes.size() && argIndex < funcDecl->params.size())
            {
                size_t p = 0;
                unsigned seen = 0;
                for (p = 0; p < funcDecl->params.size(); ++p)
                {
                    if (!funcDecl->params[p].variadic)
                    {
                        if (seen == argIndex)
                            break;
                        ++seen;
                    }
                }
                if (p < funcDecl->params.size())
                {
                    arg.setName(funcDecl->params[p].name);
                }
            }
            ++argIndex;
        }

        function_protos[llvmName] = fn;
    }
}

Function *CodeGen::codegen_function_decl(const ast::FuncDecl *funcDecl)
{
    if (!funcDecl)
        return nullptr;
    deferred_scopes.clear();

    if (funcDecl->is_intrinsic)
    {
        if (funcDecl->body)
            error("intrinsic function cannot have a body: " + funcDecl->name);
        return nullptr;
    }

    std::string llvmName = funcDecl->link_name.empty() ? funcDecl->name : funcDecl->link_name;
    bool is_main = (llvmName == "main");
    bool main_implicit_i32 = is_main && !funcDecl->ret_type;

    LLVMContext &context = builder.getContext();
    bool isVarArg = false;
    if (!funcDecl->params.empty() && funcDecl->params.back().variadic)
        isVarArg = true;
    for (size_t i = 0; i + 1 < funcDecl->params.size(); ++i)
    {
        if (funcDecl->params[i].variadic)
        {
            error("variadic parameter must be the last parameter in function: " + llvmName);

            break;
        }
    }

    std::vector<Type *> argTypes;

    for (size_t i = 0; i < funcDecl->params.size(); ++i)
    {
        const auto &param = funcDecl->params[i];
        if (param.variadic)
            continue;
        llvm::Type *paramType = nullptr;
        if (param.type)
            paramType = resolve_type_from_ast_local(param.type.get());
        if (!paramType)
            paramType = get_int_type();
        argTypes.push_back(paramType);
    }

    Type *returnType = get_void_type();
    if (funcDecl->ret_type)
    {
        llvm::Type *rt = resolve_type_from_ast_local(funcDecl->ret_type.get());
        if (rt)
            returnType = rt;
        else
            returnType = get_int_type();
    }
    else if (is_main)
    {
        returnType = get_int_type();
    }

    FunctionType *functionType = FunctionType::get(returnType, argTypes, isVarArg);

    Function *functionValue = module->getFunction(llvmName);
    if (!functionValue)
    {
        auto linkage = (funcDecl->is_extern || funcDecl->is_pub || is_main) ? Function::ExternalLinkage : Function::InternalLinkage;
        functionValue = Function::Create(functionType, linkage, llvmName, module.get());
        function_protos[llvmName] = functionValue;
    }
    else
    {
        if (functionValue->getFunctionType() != functionType)
        {
            std::string existingStr, expectedStr;
            {
                llvm::raw_string_ostream os(existingStr);
                functionValue->getFunctionType()->print(os);
            }
            {
                llvm::raw_string_ostream os(expectedStr);
                functionType->print(os);
            }
            error("function declaration/definition type mismatch for: " + llvmName +
                  " decl=" + existingStr + " expected=" + expectedStr);
            return nullptr;
        }

        if (!functionValue->empty())
        {
            error("redefinition of function: " + llvmName);
            return nullptr;
        }
    }

    if (funcDecl->is_extern)
    {
        if (funcDecl->body)
            error("extern function cannot have a body: " + funcDecl->name);
        return functionValue;
    }

    BasicBlock *entryBlock = BasicBlock::Create(context, "entry", functionValue);
    builder.SetInsertPoint(entryBlock);
    emit_runtime_function_entry(is_main);

    unsigned argIndex = 0;
    IRBuilder<> entryBuilder(entryBlock, entryBlock->begin());

    for (auto &arg : functionValue->args())
    {
        size_t p = 0;
        unsigned seen = 0;
        for (p = 0; p < funcDecl->params.size(); ++p)
        {
            if (!funcDecl->params[p].variadic)
            {
                if (seen == argIndex)
                    break;
                ++seen;
            }
        }

        std::string argName = (p < funcDecl->params.size() ? funcDecl->params[p].name : std::string(arg.getName()));
        arg.setName(argName);

        ast::Type *paramAstType = (p < funcDecl->params.size()) ? funcDecl->params[p].type.get() : nullptr;

        std::string paramTypeName = resolve_type_name(paramAstType);
        auto pt = parse_type_shape(paramTypeName);

        Value *localAlloca = entryBuilder.CreateAlloca(arg.getType(), nullptr, argName);
        entryBuilder.CreateStore(&arg, localAlloca);
        std::string localTypeName = paramTypeName.empty() ? pt.base + "_params" : paramTypeName;
        bind_local(argName, localTypeName, localAlloca);
        ++argIndex;
    }

    if (!funcDecl->params.empty() && funcDecl->params.back().variadic)
    {
        const auto &vparam = funcDecl->params.back();
        llvm::Type *elemType = nullptr;
        if (vparam.type)
            elemType = resolve_type_from_ast_local(vparam.type.get());
        if (!elemType)
            elemType = get_int_type();

        llvm::Type *holderType = codegen::detail::getPtrTy(context);
        Value *varAlloca = entryBuilder.CreateAlloca(holderType, nullptr, vparam.name);

        entryBuilder.CreateStore(Constant::getNullValue(holderType), varAlloca);
        bind_local(vparam.name, "ptr", varAlloca);
    }

    push_scope();

    if (funcDecl->body)
        codegen_block(funcDecl->body.get());

    if (auto currentBB = builder.GetInsertBlock())
    {
        if (!currentBB->getTerminator())
        {
            emit_deferred_statements();
            emit_runtime_function_exit(is_main);
            if (returnType->isVoidTy())
                builder.CreateRetVoid();
            else if (main_implicit_i32)
                builder.CreateRet(ConstantInt::get(returnType, 0));
            else
            {
                error("non-void function is missing an explicit return");
                builder.CreateRet(Constant::getNullValue(returnType));
            }
        }
    }

    if (verifyFunction(*functionValue, &errs()))
    {
        error("function verification failed: " + llvmName);
        functionValue->eraseFromParent();
        pop_scope();
        deferred_scopes.clear();
        return nullptr;
    }

    pop_scope();
    deferred_scopes.clear();
    return functionValue;
}

}
