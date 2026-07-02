#pragma once
#include "../codegen.h"
#include "../common.h"
#include <llvm/IR/Constants.h>
#include <llvm/IR/DerivedTypes.h>
#include <llvm/IR/Intrinsics.h>
#include <llvm/ADT/SmallVector.h>
#include <llvm/ADT/Twine.h>

using namespace llvm;
using namespace codegen;

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

    if (name == "malloc")
        return declareFunc(i8ptr, {i64Ty});
    if (name == "calloc")
        return declareFunc(i8ptr, {i64Ty, i64Ty});
    if (name == "realloc")
        return declareFunc(i8ptr, {i8ptr, i64Ty});
    if (name == "free")
        return declareFunc(voidTy, {i8ptr});

    if (name == "puts")
        return declareFunc(iTy, {i8ptr});
    if (name == "putchar")
        return declareFunc(iTy, {iTy});

    if (name == "open")
        return declareFunc(iTy, {i8ptr, iTy, iTy});
    if (name == "close")
        return declareFunc(iTy, {iTy});
    if (name == "read")
        return declareFunc(iTy, {iTy, i8ptr, iTy});
    if (name == "write")
        return declareFunc(iTy, {iTy, i8ptr, iTy});
    if (name == "lseek")
        return declareFunc(iTy, {iTy, iTy, iTy});
    if (name == "fsync")
        return declareFunc(iTy, {iTy});
    if (name == "ftruncate")
        return declareFunc(iTy, {iTy, iTy});

    if (name == "socket")
        return declareFunc(iTy, {iTy, iTy, iTy});
    if (name == "bind")
        return declareFunc(iTy, {iTy, i8ptr, iTy});
    if (name == "listen")
        return declareFunc(iTy, {iTy, iTy});
    if (name == "accept")
        return declareFunc(iTy, {iTy, i8ptr, i8ptr});
    if (name == "connect")
        return declareFunc(iTy, {iTy, i8ptr, iTy});
    if (name == "send")
        return declareFunc(iTy, {iTy, i8ptr, iTy, iTy});
    if (name == "recv")
        return declareFunc(iTy, {iTy, i8ptr, iTy, iTy});
    if (name == "sendto")
        return declareFunc(iTy, {iTy, i8ptr, iTy, iTy, i8ptr, iTy});
    if (name == "recvfrom")
        return declareFunc(iTy, {iTy, i8ptr, iTy, iTy, i8ptr, i8ptr});
    if (name == "shutdown")
        return declareFunc(iTy, {iTy, iTy});
    if (name == "setsockopt")
        return declareFunc(iTy, {iTy, iTy, iTy, i8ptr, iTy});
    if (name == "getsockopt")
        return declareFunc(iTy, {iTy, iTy, iTy, i8ptr, i8ptr});

    if (name == "inet_pton")
        return declareFunc(iTy, {iTy, i8ptr, i8ptr});
    if (name == "inet_ntop")
        return declareFunc(i8ptr, {iTy, i8ptr, i8ptr, iTy});
    if (name == "htons")
        return declareFunc(iTy, {iTy});
    if (name == "ntohs")
        return declareFunc(iTy, {iTy});
    if (name == "htonl")
        return declareFunc(iTy, {iTy});
    if (name == "ntohl")
        return declareFunc(iTy, {iTy});
    if (name == "getaddrinfo")
        return declareFunc(iTy, {i8ptr, i8ptr, i8ptr, i8ptr});
    if (name == "freeaddrinfo")
        return declareFunc(voidTy, {i8ptr});

    if (name == "fork")
        return declareFunc(iTy, {});
    if (name == "execve")
        return declareFunc(iTy, {i8ptr, i8ptr, i8ptr});
    if (name == "waitpid")
        return declareFunc(iTy, {iTy, i8ptr, iTy});
    if (name == "exit")
        return declareFunc(voidTy, {iTy});
    if (name == "getpid")
        return declareFunc(iTy, {});
    if (name == "kill")
        return declareFunc(iTy, {iTy, iTy});
    if (name == "getenv")
        return declareFunc(i8ptr, {i8ptr});
    if (name == "setenv")
        return declareFunc(iTy, {i8ptr, i8ptr, iTy});
    if (name == "unsetenv")
        return declareFunc(iTy, {i8ptr});

    if (name == "time")
        return declareFunc(iTy, {i8ptr});
    if (name == "gettimeofday")
        return declareFunc(iTy, {i8ptr, i8ptr});
    if (name == "nanosleep")
        return declareFunc(iTy, {i8ptr, i8ptr});

    if (name == "mmap")
        return declareFunc(i8ptr, {i8ptr, iTy, iTy, iTy, iTy, iTy});
    if (name == "munmap")
        return declareFunc(iTy, {i8ptr, iTy});
    if (name == "mprotect")
        return declareFunc(iTy, {i8ptr, iTy, iTy});

    if (name == "pthread_create")
        return declareFunc(iTy, {i8ptr, i8ptr, i8ptr, i8ptr});
    if (name == "pthread_join")
        return declareFunc(iTy, {i8ptr, i8ptr});
    if (name == "pthread_mutex_init")
        return declareFunc(iTy, {i8ptr, i8ptr});
    if (name == "pthread_mutex_lock")
        return declareFunc(iTy, {i8ptr});
    if (name == "pthread_mutex_unlock")
        return declareFunc(iTy, {i8ptr});
    if (name == "pthread_cond_wait")
        return declareFunc(iTy, {i8ptr, i8ptr});
    if (name == "pthread_cond_signal")
        return declareFunc(iTy, {i8ptr});

    if (name == "sin" || name == "cos" || name == "tan" || name == "sqrt" ||
        name == "exp" || name == "log" || name == "fabs")
        return declareFunc(dblTy, {dblTy});
    if (name == "pow")
        return declareFunc(dblTy, {dblTy, dblTy});

    if (name == "system")
        return declareFunc(iTy, {i8ptr});
    if (name == "uname")
        return declareFunc(iTy, {i8ptr});
    if (name == "syscall")
        return declareFunc(iTy, {iTy}, true);

    if (name == "strlen")
        return declareFunc(i64Ty, {i8ptr});
    if (name == "strcpy")
        return declareFunc(i8ptr, {i8ptr, i8ptr});
    if (name == "strcmp")
        return declareFunc(iTy, {i8ptr, i8ptr});
    if (name == "memcpy")
        return declareFunc(i8ptr, {i8ptr, i8ptr, i64Ty});
    if (name == "memcmp")
        return declareFunc(iTy, {i8ptr, i8ptr, i64Ty});
    if (name == "memmove")
        return declareFunc(i8ptr, {i8ptr, i8ptr, i64Ty});
    if (name == "memset")
        return declareFunc(i8ptr, {i8ptr, iTy, i64Ty});

    if (name == "strstr")
        return declareFunc(i8ptr, {i8ptr, i8ptr});
    if (name == "strcat")
        return declareFunc(i8ptr, {i8ptr, i8ptr});
    if (name == "strncpy")
        return declareFunc(i8ptr, {i8ptr, i8ptr, iTy});
    if (name == "fchmod")
        return declareFunc(iTy, {iTy, iTy});
    if (name == "fopen")
        return declareFunc(i8ptr, {i8ptr, i8ptr});
    if (name == "fputs")
        return declareFunc(iTy, {i8ptr, i8ptr});
    if (name == "fclose")
        return declareFunc(iTy, {i8ptr});
    if (name == "mkdir")
        return declareFunc(iTy, {i8ptr, iTy});

    return nullptr;
}
