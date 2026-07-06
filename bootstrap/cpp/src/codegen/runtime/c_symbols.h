#pragma once
#include "../codegen.h"
#include "../common.h"
#include <llvm/IR/Constants.h>
#include <llvm/IR/DerivedTypes.h>
#include <llvm/IR/Intrinsics.h>
#include <initializer_list>
#include <vector>

namespace codegen
{

namespace
{
struct CFunctionSpec
{
    CFunctionSpec(const char *symbolName,
                  llvm::Type *returnType,
                  std::initializer_list<llvm::Type *> argumentTypes,
                  bool isVariadic = false)
        : symbol(symbolName), ret(returnType), args(argumentTypes), variadic(isVariadic)
    {
    }

    const char *symbol;
    llvm::Type *ret;
    std::vector<llvm::Type *> args;
    bool variadic;
};
}

Function *CodeGen::get_or_declare_c_function(const std::string &name)
{
    if (auto *existing = module->getFunction(name))
    {
        function_protos[name] = existing;
        return existing;
    }

    auto proto = function_protos.find(name);
    if (proto != function_protos.end())
        return proto->second;

    auto iTy = get_int_type();
    auto i64Ty = get_i64_type();
    auto dblTy = get_double_type();
    auto voidTy = get_void_type();
    auto i8ptr = get_i8ptr_type();

    auto declareFunc = [&](llvm::Type *ret,
                           const std::vector<llvm::Type *> &args,
                           bool vararg = false) -> llvm::Function *
    {
        llvm::FunctionType *ft = llvm::FunctionType::get(ret, args, vararg);
        llvm::FunctionCallee callee = module->getOrInsertFunction(name, ft);
        if (auto *fn = llvm::dyn_cast<llvm::Function>(callee.getCallee()))
        {
            function_protos[name] = fn;
            return fn;
        }
        return nullptr;
    };

    const std::vector<CFunctionSpec> knownFunctions = {
        // Memory management.
        {"malloc", i8ptr, {i64Ty}},
        {"calloc", i8ptr, {i64Ty, i64Ty}},
        {"realloc", i8ptr, {i8ptr, i64Ty}},
        {"free", voidTy, {i8ptr}},

        // Basic terminal and file I/O.
        {"puts", iTy, {i8ptr}},
        {"putchar", iTy, {iTy}},
        {"open", iTy, {i8ptr, iTy, iTy}},
        {"close", iTy, {iTy}},
        {"read", iTy, {iTy, i8ptr, iTy}},
        {"write", iTy, {iTy, i8ptr, iTy}},
        {"lseek", iTy, {iTy, iTy, iTy}},
        {"fsync", iTy, {iTy}},
        {"ftruncate", iTy, {iTy, iTy}},
        {"fchmod", iTy, {iTy, iTy}},
        {"fopen", i8ptr, {i8ptr, i8ptr}},
        {"fputs", iTy, {i8ptr, i8ptr}},
        {"fclose", iTy, {i8ptr}},
        {"mkdir", iTy, {i8ptr, iTy}},

        // Sockets and network helpers.
        {"socket", iTy, {iTy, iTy, iTy}},
        {"bind", iTy, {iTy, i8ptr, iTy}},
        {"listen", iTy, {iTy, iTy}},
        {"accept", iTy, {iTy, i8ptr, i8ptr}},
        {"connect", iTy, {iTy, i8ptr, iTy}},
        {"send", iTy, {iTy, i8ptr, iTy, iTy}},
        {"recv", iTy, {iTy, i8ptr, iTy, iTy}},
        {"sendto", iTy, {iTy, i8ptr, iTy, iTy, i8ptr, iTy}},
        {"recvfrom", iTy, {iTy, i8ptr, iTy, iTy, i8ptr, i8ptr}},
        {"shutdown", iTy, {iTy, iTy}},
        {"setsockopt", iTy, {iTy, iTy, iTy, i8ptr, iTy}},
        {"getsockopt", iTy, {iTy, iTy, iTy, i8ptr, i8ptr}},
        {"inet_pton", iTy, {iTy, i8ptr, i8ptr}},
        {"inet_ntop", i8ptr, {iTy, i8ptr, i8ptr, iTy}},
        {"htons", iTy, {iTy}},
        {"ntohs", iTy, {iTy}},
        {"htonl", iTy, {iTy}},
        {"ntohl", iTy, {iTy}},
        {"getaddrinfo", iTy, {i8ptr, i8ptr, i8ptr, i8ptr}},
        {"freeaddrinfo", voidTy, {i8ptr}},

        // Process, environment, time, memory map, and threading APIs.
        {"fork", iTy, {}},
        {"execve", iTy, {i8ptr, i8ptr, i8ptr}},
        {"waitpid", iTy, {iTy, i8ptr, iTy}},
        {"exit", voidTy, {iTy}},
        {"getpid", iTy, {}},
        {"kill", iTy, {iTy, iTy}},
        {"getenv", i8ptr, {i8ptr}},
        {"setenv", iTy, {i8ptr, i8ptr, iTy}},
        {"unsetenv", iTy, {i8ptr}},
        {"time", iTy, {i8ptr}},
        {"gettimeofday", iTy, {i8ptr, i8ptr}},
        {"nanosleep", iTy, {i8ptr, i8ptr}},
        {"mmap", i8ptr, {i8ptr, iTy, iTy, iTy, iTy, iTy}},
        {"munmap", iTy, {i8ptr, iTy}},
        {"mprotect", iTy, {i8ptr, iTy, iTy}},
        {"pthread_create", iTy, {i8ptr, i8ptr, i8ptr, i8ptr}},
        {"pthread_join", iTy, {i8ptr, i8ptr}},
        {"pthread_mutex_init", iTy, {i8ptr, i8ptr}},
        {"pthread_mutex_lock", iTy, {i8ptr}},
        {"pthread_mutex_unlock", iTy, {i8ptr}},
        {"pthread_cond_wait", iTy, {i8ptr, i8ptr}},
        {"pthread_cond_signal", iTy, {i8ptr}},

        // Math, command execution, and raw syscall support.
        {"sin", dblTy, {dblTy}},
        {"cos", dblTy, {dblTy}},
        {"tan", dblTy, {dblTy}},
        {"sqrt", dblTy, {dblTy}},
        {"exp", dblTy, {dblTy}},
        {"log", dblTy, {dblTy}},
        {"fabs", dblTy, {dblTy}},
        {"pow", dblTy, {dblTy, dblTy}},
        {"system", iTy, {i8ptr}},
        {"uname", iTy, {i8ptr}},
        {"syscall", iTy, {iTy}, true},

        // C string and memory primitives.
        {"strlen", i64Ty, {i8ptr}},
        {"strcpy", i8ptr, {i8ptr, i8ptr}},
        {"strcmp", iTy, {i8ptr, i8ptr}},
        {"memcpy", i8ptr, {i8ptr, i8ptr, i64Ty}},
        {"memcmp", iTy, {i8ptr, i8ptr, i64Ty}},
        {"memmove", i8ptr, {i8ptr, i8ptr, i64Ty}},
        {"memset", i8ptr, {i8ptr, iTy, i64Ty}},
        {"strstr", i8ptr, {i8ptr, i8ptr}},
        {"strcat", i8ptr, {i8ptr, i8ptr}},
        {"strncpy", i8ptr, {i8ptr, i8ptr, iTy}},
    };

    for (const CFunctionSpec &known : knownFunctions)
    {
        if (name == known.symbol)
            return declareFunc(known.ret, known.args, known.variadic);
    }

    return nullptr;
}

}
