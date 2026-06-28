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

void CodeGen::register_builtin_ffi()
{
    auto iTy = get_int_type();
    auto i64Ty = get_i64_type();
    auto dblTy = get_double_type();
    auto voidTy = get_void_type();
    auto i8ptr = get_i8ptr_type();

    auto addFunc = [this](const std::string &name,
                          llvm::Type *ret,
                          const std::vector<llvm::Type *> &args,
                          bool vararg = false) -> llvm::Function *
    {
        llvm::FunctionType *ft = llvm::FunctionType::get(ret, args, vararg);
        llvm::Function *f = llvm::Function::Create(ft, llvm::Function::ExternalLinkage, name, module.get());
        function_protos[name] = f;
        return f;
    };

    addFunc("malloc", i8ptr, {i64Ty});
    addFunc("calloc", i8ptr, {i64Ty, i64Ty});
    addFunc("realloc", i8ptr, {i8ptr, i64Ty});
    addFunc("free", voidTy, {i8ptr});

    addFunc("puts", iTy, {i8ptr});
    addFunc("putchar", iTy, {iTy});

    addFunc("open", iTy, {i8ptr, iTy, iTy});
    addFunc("close", iTy, {iTy});
    addFunc("read", iTy, {iTy, i8ptr, iTy});
    addFunc("write", iTy, {iTy, i8ptr, iTy});
    addFunc("lseek", iTy, {iTy, iTy, iTy});
    addFunc("fsync", iTy, {iTy});
    addFunc("ftruncate", iTy, {iTy, iTy});

    addFunc("socket", iTy, {iTy, iTy, iTy});
    addFunc("bind", iTy, {iTy, i8ptr, iTy});
    addFunc("listen", iTy, {iTy, iTy});
    addFunc("accept", iTy, {iTy, i8ptr, i8ptr});
    addFunc("connect", iTy, {iTy, i8ptr, iTy});
    addFunc("send", iTy, {iTy, i8ptr, iTy, iTy});
    addFunc("recv", iTy, {iTy, i8ptr, iTy, iTy});
    addFunc("sendto", iTy, {iTy, i8ptr, iTy, iTy, i8ptr, iTy});
    addFunc("recvfrom", iTy, {iTy, i8ptr, iTy, iTy, i8ptr, i8ptr});
    addFunc("shutdown", iTy, {iTy, iTy});
    addFunc("setsockopt", iTy, {iTy, iTy, iTy, i8ptr, iTy});
    addFunc("getsockopt", iTy, {iTy, iTy, iTy, i8ptr, i8ptr});

    addFunc("inet_pton", iTy, {iTy, i8ptr, i8ptr});
    addFunc("inet_ntop", i8ptr, {iTy, i8ptr, i8ptr, iTy});
    addFunc("htons", iTy, {iTy});
    addFunc("ntohs", iTy, {iTy});
    addFunc("htonl", iTy, {iTy});
    addFunc("ntohl", iTy, {iTy});
    addFunc("getaddrinfo", iTy, {i8ptr, i8ptr, i8ptr, i8ptr});
    addFunc("freeaddrinfo", voidTy, {i8ptr});

    addFunc("fork", iTy, {});
    addFunc("execve", iTy, {i8ptr, i8ptr, i8ptr});
    addFunc("waitpid", iTy, {iTy, i8ptr, iTy});
    addFunc("exit", voidTy, {iTy});
    addFunc("getpid", iTy, {});
    addFunc("kill", iTy, {iTy, iTy});
    addFunc("getenv", i8ptr, {i8ptr});
    addFunc("setenv", iTy, {i8ptr, i8ptr, iTy});
    addFunc("unsetenv", iTy, {i8ptr});

    addFunc("time", iTy, {i8ptr});
    addFunc("gettimeofday", iTy, {i8ptr, i8ptr});
    addFunc("nanosleep", iTy, {i8ptr, i8ptr});

    addFunc("mmap", i8ptr, {i8ptr, iTy, iTy, iTy, iTy, iTy});
    addFunc("munmap", iTy, {i8ptr, iTy});
    addFunc("mprotect", iTy, {i8ptr, iTy, iTy});

    addFunc("pthread_create", iTy, {i8ptr, i8ptr, i8ptr, i8ptr});
    addFunc("pthread_join", iTy, {i8ptr, i8ptr});
    addFunc("pthread_mutex_init", iTy, {i8ptr, i8ptr});
    addFunc("pthread_mutex_lock", iTy, {i8ptr});
    addFunc("pthread_mutex_unlock", iTy, {i8ptr});
    addFunc("pthread_cond_wait", iTy, {i8ptr, i8ptr});
    addFunc("pthread_cond_signal", iTy, {i8ptr});

    addFunc("sin", dblTy, {dblTy});
    addFunc("cos", dblTy, {dblTy});
    addFunc("tan", dblTy, {dblTy});

    addFunc("pow", dblTy, {dblTy, dblTy});
    addFunc("sqrt", dblTy, {dblTy});
    addFunc("exp", dblTy, {dblTy});
    addFunc("log", dblTy, {dblTy});
    addFunc("fabs", dblTy, {dblTy});

    addFunc("system", iTy, {i8ptr});
    addFunc("uname", iTy, {i8ptr});

    {

        llvm::FunctionType *ft = llvm::FunctionType::get(iTy, {iTy}, true);
        llvm::Function *f = llvm::Function::Create(ft, llvm::Function::ExternalLinkage, "syscall", module.get());
        function_protos["syscall"] = f;
    }

    addFunc("strlen", i64Ty, {i8ptr});
    addFunc("strcpy", i8ptr, {i8ptr, i8ptr});
    addFunc("strcmp", iTy, {i8ptr, i8ptr});
    addFunc("memcpy", i8ptr, {i8ptr, i8ptr, i64Ty});
    addFunc("memcmp", iTy, {i8ptr, i8ptr, i64Ty});
    addFunc("memmove", i8ptr, {i8ptr, i8ptr, i64Ty});
    addFunc("memset", i8ptr, {i8ptr, iTy, i64Ty});

    addFunc("strstr", i8ptr, {i8ptr, i8ptr});
    addFunc("strcat", i8ptr, {i8ptr, i8ptr});
    addFunc("strncpy", i8ptr, {i8ptr, i8ptr, iTy});
    addFunc("fchmod", iTy, {iTy, iTy});
}
