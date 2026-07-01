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

static bool is_YCPL_std_intrinsic(const std::string &name)
{
    return name.rfind("__YCPL_std__", 0) == 0;
}

Value *CodeGen::codegen_std_intrinsic_call(const std::string &name, const ast::CallExpr *ce)
{
    auto to_i64 = [&](Value *v, const std::string &label) -> Value *
    {
        if (!v)
            return nullptr;
        Type *i64Ty = get_i64_type();
        if (v->getType()->isIntegerTy(64))
            return v;
        if (v->getType()->isIntegerTy())
            return v->getType()->isIntegerTy(1) ? builder.CreateZExtOrTrunc(v, i64Ty, label) : builder.CreateSExtOrTrunc(v, i64Ty, label);
        if (v->getType()->isPointerTy())
            return builder.CreatePtrToInt(v, i64Ty, label);
        if (v->getType()->isFloatingPointTy())
            return builder.CreateFPToSI(v, i64Ty, label);
        return v;
    };

    auto to_i32 = [&](Value *v, const std::string &label) -> Value *
    {
        if (!v)
            return nullptr;
        Type *i32Ty = get_int_type();
        if (v->getType()->isIntegerTy(32))
            return v;
        if (v->getType()->isIntegerTy())
            return builder.CreateSExtOrTrunc(v, i32Ty, label);
        if (v->getType()->isFloatingPointTy())
            return builder.CreateFPToSI(v, i32Ty, label);
        return v;
    };

    auto to_double = [&](Value *v, const std::string &label) -> Value *
    {
        if (!v)
            return nullptr;
        Type *dblTy = get_double_type();
        if (v->getType()->isDoubleTy())
            return v;
        if (v->getType()->isFloatTy())
            return builder.CreateFPExt(v, dblTy, label);
        if (v->getType()->isIntegerTy())
            return builder.CreateSIToFP(v, dblTy, label);
        return v;
    };

    auto to_i8ptr = [&](Value *v, const std::string &label) -> Value *
    {
        if (!v)
            return nullptr;
        Type *i8ptrTy = get_i8ptr_type();
        if (v->getType() == i8ptrTy)
            return v;
        if (v->getType()->isPointerTy())
            return builder.CreatePointerCast(v, i8ptrTy, label);
        if (v->getType()->isIntegerTy())
            return builder.CreateIntToPtr(to_i64(v, label + ".int"), cast<PointerType>(i8ptrTy), label);
        return v;
    };

    auto get_c_function = [&](const std::string &fn_name) -> Function *
    {
        return get_or_declare_c_function(fn_name);
    };

    auto array_ptr_from_value = [&](Value *arr, const std::string &label) -> Value *
    {
        if (!arr)
            return nullptr;
        Module *M = module.get();
        const DataLayout &dl = M->getDataLayout();
        Type *arrayPtrTy = detail::getPtrTy(context);

        if (arr->getType()->isPointerTy())
            return builder.CreatePointerCast(arr, arrayPtrTy, label);

        if (arr->getType()->isStructTy())
        {
            Value *tmp = builder.CreateAlloca(arr->getType(), nullptr, label + ".tmp");
            builder.CreateStore(arr, tmp);
            return builder.CreatePointerCast(tmp, arrayPtrTy, label);
        }

        if (arr->getType()->isIntegerTy())
        {
            unsigned ptrBits = dl.getPointerSizeInBits();
            Type *ptrIntTy = IntegerType::get(context, ptrBits);
            if (arr->getType() != ptrIntTy)
                arr = builder.CreateSExtOrTrunc(arr, ptrIntTy, label + ".ptrint");
            return builder.CreateIntToPtr(arr, cast<PointerType>(arrayPtrTy), label);
        }

        error("array: unsupported array value");
        return nullptr;
    };

    auto array_ptr_from_expr = [&](const ast::Expr *expr, const std::string &label) -> Value *
    {
        Value *arr = codegen_expr(expr);
        return array_ptr_from_value(arr, label);
    };

    auto array_field = [&](Value *arrPtr, unsigned fieldNo, const std::string &label) -> Value *
    {
        StructType *arrayStruct = detail::getOrCreateArrayStruct(context);
        return detail::createStructFieldGEP(builder, arrayStruct, arrPtr, fieldNo, label);
    };

    auto checked_array_elem_i8 = [&](const ast::Expr *arrExpr, const ast::Expr *idxExpr, Value **elemSizeOut) -> Value *
    {
        if (!arrExpr || !idxExpr)
            return nullptr;

        Module *M = module.get();
        StructType *arrayStruct = detail::getOrCreateArrayStruct(context);
        Type *i64Ty = get_i64_type();
        Type *i8Ty = Type::getInt8Ty(context);
        Type *i8ptrTy = get_i8ptr_type();

        Value *arrPtr = array_ptr_from_expr(arrExpr, "array.ptr");
        if (!arrPtr)
            return nullptr;

        Value *idxVal = codegen_expr(idxExpr);
        idxVal = to_i64(idxVal, "idx.i64");
        if (!idxVal)
            return nullptr;

        Value *lenPtr = detail::createStructFieldGEP(builder, arrayStruct, arrPtr, 1, "array.len.ptr");
        Value *lenVal = builder.CreateLoad(i64Ty, lenPtr, "array.len");
        Value *inRange = builder.CreateICmpULT(idxVal, lenVal, "array.idx.in_range");

        Function *F = builder.GetInsertBlock()->getParent();
        BasicBlock *okBB = BasicBlock::Create(context, "array_idx_ok", F);
        BasicBlock *oobBB = BasicBlock::Create(context, "array_idx_oob", F);
        builder.CreateCondBr(inRange, okBB, oobBB);

        builder.SetInsertPoint(oobBB);
        FunctionType *abortTy = FunctionType::get(Type::getVoidTy(context), {}, false);
        FunctionCallee abortFn = M->getOrInsertFunction("abort", abortTy);
        builder.CreateCall(abortFn, {});
        builder.CreateUnreachable();

        builder.SetInsertPoint(okBB);
        Value *dataPtrPtr = detail::createStructFieldGEP(builder, arrayStruct, arrPtr, 0, "array.data.ptr.ptr");
        Value *dataPtr = builder.CreateLoad(i8ptrTy, dataPtrPtr, "array.data.ptr");
        Value *elemSizePtr = detail::createStructFieldGEP(builder, arrayStruct, arrPtr, 3, "array.elem_size.ptr");
        Value *elemSize = builder.CreateLoad(i64Ty, elemSizePtr, "array.elem_size");
        if (elemSizeOut)
            *elemSizeOut = elemSize;

        Value *offset = builder.CreateMul(idxVal, elemSize, "array.elem.offset");
        return builder.CreateInBoundsGEP(i8Ty, dataPtr, {offset}, "array.elem.i8");
    };

    if (name == "__YCPL_std__fmt_println")
        return codegen_println_call(ce);

    if (name == "__YCPL_std__fmt_printf")
        return codegen_printf_call(ce);

    if (name == "__YCPL_std__fmt_print")
    {
        if (ce->args.empty())
            return nullptr;

        SmallVector<Value *, 8> printfArgs;
        std::string fmtStr;
        for (size_t i = 0; i < ce->args.size(); ++i)
        {
            Value *arg = codegen_expr(ce->args[i].get());
            if (!arg)
                return nullptr;

            if (arg->getType()->isPointerTy())
            {
                fmtStr += "%s";
                arg = to_i8ptr(arg, "fmt.print.ptr");
            }
            else if (arg->getType()->isFloatingPointTy())
            {
                fmtStr += "%f";
                arg = to_double(arg, "fmt.print.double");
            }
            else if (arg->getType()->isIntegerTy())
            {
                fmtStr += "%lld";
                arg = to_i64(arg, "fmt.print.i64");
            }
            else
            {
                fmtStr += "%p";
                arg = to_i8ptr(arg, "fmt.print.anyptr");
            }

            if (i + 1 < ce->args.size())
                fmtStr += " ";
            printfArgs.push_back(arg);
        }

        SmallVector<Value *, 8> callArgs;
        callArgs.push_back(make_global_string(fmtStr, ".fmt.print"));
        for (Value *arg : printfArgs)
            callArgs.push_back(arg);
        return builder.CreateCall(get_printf(), callArgs, "call_fmt_print");
    }

    if (name == "__YCPL_std__array_len")
        return codegen_len_call(ce);

    if (name == "__YCPL_std__array_append")
        return codegen_append_call(ce);

    if (name == "__YCPL_std__array_new")
    {
        if (ce->args.size() != 2)
        {
            error("array.new expects 2 arguments: array.new([]T, cap)");
            return nullptr;
        }

        const auto *typeExpr = dynamic_cast<const ast::TypeExpr *>(ce->args[0].get());
        if (!typeExpr)
        {
            error("array.new first argument must be an array type, e.g. []i32");
            return nullptr;
        }

        const ast::Type *elemAst = typeExpr->type.get();
        if (auto arrAst = dynamic_cast<const ast::ArrayType *>(elemAst))
            elemAst = arrAst->elem.get();
        else
        {
            error("array.new first argument must be an array type, e.g. []i32");
            return nullptr;
        }

        Type *elemTy = resolve_type_from_ast(elemAst);
        if (!elemTy)
        {
            error("array.new cannot resolve element type");
            return nullptr;
        }

        Module *M = module.get();
        const DataLayout &dl = M->getDataLayout();
        StructType *arrayStruct = detail::getOrCreateArrayStruct(context);
        Type *arrayPtrTy = detail::getPtrTy(context);
        Type *i64Ty = get_i64_type();
        Type *i8ptrTy = get_i8ptr_type();

        Value *cap = to_i64(codegen_expr(ce->args[1].get()), "array.cap.i64");
        if (!cap)
            return nullptr;

        Value *zero = ConstantInt::get(i64Ty, 0);
        Value *one = ConstantInt::get(i64Ty, 1);
        Value *allocCap = builder.CreateSelect(builder.CreateICmpEQ(cap, zero, "array.cap.is_zero"), one, cap, "array.alloc_cap");

        uint64_t elemSize = dl.getTypeAllocSize(elemTy);
        Value *elemSizeVal = ConstantInt::get(i64Ty, elemSize);
        Value *dataBytes = builder.CreateMul(allocCap, elemSizeVal, "array.data_bytes");

        FunctionCallee mallocFn = detail::getMalloc(M);
        Value *structSize = ConstantInt::get(i64Ty, dl.getTypeAllocSize(arrayStruct));
        Value *rawStruct = builder.CreateCall(mallocFn, {structSize}, "array.struct.raw");
        Value *arrPtr = builder.CreatePointerCast(rawStruct, arrayPtrTy, "array.struct");
        Value *rawData = builder.CreateCall(mallocFn, {dataBytes}, "array.data.raw");
        Value *dataPtr = builder.CreatePointerCast(rawData, i8ptrTy, "array.data");
        builder.CreateMemSet(dataPtr, ConstantInt::get(Type::getInt8Ty(context), 0), dataBytes, MaybeAlign(1));

        builder.CreateStore(dataPtr, array_field(arrPtr, 0, "array.new.data.ptr"));
        builder.CreateStore(zero, array_field(arrPtr, 1, "array.new.len.ptr"));
        builder.CreateStore(cap, array_field(arrPtr, 2, "array.new.cap.ptr"));
        builder.CreateStore(elemSizeVal, array_field(arrPtr, 3, "array.new.elem_size.ptr"));
        return arrPtr;
    }

    if (name == "__YCPL_std__array_cap")
    {
        if (ce->args.size() != 1)
        {
            error("array.cap expects 1 argument");
            return nullptr;
        }
        Value *arrPtr = array_ptr_from_expr(ce->args[0].get(), "array.cap.ptr");
        if (!arrPtr)
            return nullptr;
        Value *capPtr = array_field(arrPtr, 2, "array.cap.ptr.field");
        Value *cap64 = builder.CreateLoad(get_i64_type(), capPtr, "array.cap64");
        return builder.CreateTrunc(cap64, get_int_type(), "array.cap32");
    }

    if (name == "__YCPL_std__array_get")
    {
        if (ce->args.size() != 2)
        {
            error("array.get expects 2 arguments");
            return nullptr;
        }
        Value *elemSize = nullptr;
        Value *elemPtrI8 = checked_array_elem_i8(ce->args[0].get(), ce->args[1].get(), &elemSize);
        if (!elemPtrI8)
            return nullptr;

        if (auto id = dynamic_cast<const ast::Ident *>(ce->args[0].get()))
        {
            if (std::string *typeHint = lookup_local_type(id->name))
            {
                ParsedType parsed = parse_type_chain(*typeHint);
                if (parsed.array_depth > 0)
                {
                    std::string elemTypeName = parsed.base;
                    for (int i = 1; i < parsed.array_depth; ++i)
                        elemTypeName += "[]";
                    for (int i = 0; i < parsed.pointer_depth; ++i)
                        elemTypeName += "*";

                    Type *elemTy = parsed.array_depth > 1
                                       ? detail::getPtrTy(context)
                                       : getLLVMType(elemTypeName);
                    if (elemTy)
                    {
                        Value *typedPtr = builder.CreatePointerCast(elemPtrI8, detail::getPtrTy(context), "array.get.typed.ptr");
                        return builder.CreateLoad(elemTy, typedPtr, "array.get.typed");
                    }
                }
            }
        }

        Type *i64Ty = get_i64_type();
        Function *F = builder.GetInsertBlock()->getParent();
        BasicBlock *case8BB = BasicBlock::Create(context, "array_get_case8", F);
        BasicBlock *check4BB = BasicBlock::Create(context, "array_get_check4", F);
        BasicBlock *case4BB = BasicBlock::Create(context, "array_get_case4", F);
        BasicBlock *check2BB = BasicBlock::Create(context, "array_get_check2", F);
        BasicBlock *case2BB = BasicBlock::Create(context, "array_get_case2", F);
        BasicBlock *case1BB = BasicBlock::Create(context, "array_get_case1", F);
        BasicBlock *afterBB = BasicBlock::Create(context, "array_get_after", F);

        builder.CreateCondBr(builder.CreateICmpEQ(elemSize, ConstantInt::get(i64Ty, 8)), case8BB, check4BB);

        builder.SetInsertPoint(case8BB);
        Value *v8 = builder.CreateLoad(i64Ty, builder.CreatePointerCast(elemPtrI8, detail::getPtrTy(context)), "array.get.i64");
        builder.CreateBr(afterBB);

        builder.SetInsertPoint(check4BB);
        builder.CreateCondBr(builder.CreateICmpEQ(elemSize, ConstantInt::get(i64Ty, 4)), case4BB, check2BB);

        builder.SetInsertPoint(case4BB);
        Value *v4raw = builder.CreateLoad(get_int_type(), builder.CreatePointerCast(elemPtrI8, detail::getPtrTy(context)), "array.get.i32");
        Value *v4 = builder.CreateSExt(v4raw, i64Ty, "array.get.i32.to_i64");
        builder.CreateBr(afterBB);

        builder.SetInsertPoint(check2BB);
        builder.CreateCondBr(builder.CreateICmpEQ(elemSize, ConstantInt::get(i64Ty, 2)), case2BB, case1BB);

        builder.SetInsertPoint(case2BB);
        Type *i16Ty = Type::getInt16Ty(context);
        Value *v2raw = builder.CreateLoad(i16Ty, builder.CreatePointerCast(elemPtrI8, detail::getPtrTy(context)), "array.get.i16");
        Value *v2 = builder.CreateSExt(v2raw, i64Ty, "array.get.i16.to_i64");
        builder.CreateBr(afterBB);

        builder.SetInsertPoint(case1BB);
        Type *i8Ty = Type::getInt8Ty(context);
        Value *v1raw = builder.CreateLoad(i8Ty, builder.CreatePointerCast(elemPtrI8, detail::getPtrTy(context)), "array.get.i8");
        Value *v1 = builder.CreateSExt(v1raw, i64Ty, "array.get.i8.to_i64");
        builder.CreateBr(afterBB);

        builder.SetInsertPoint(afterBB);
        PHINode *phi = builder.CreatePHI(i64Ty, 4, "array.get.result");
        phi->addIncoming(v8, case8BB);
        phi->addIncoming(v4, case4BB);
        phi->addIncoming(v2, case2BB);
        phi->addIncoming(v1, case1BB);
        return phi;
    }

    if (name == "__YCPL_std__array_set")
    {
        if (ce->args.size() != 3)
        {
            error("array.set expects 3 arguments");
            return nullptr;
        }
        Value *elemSize = nullptr;
        Value *elemPtrI8 = checked_array_elem_i8(ce->args[0].get(), ce->args[1].get(), &elemSize);
        Value *value = codegen_expr(ce->args[2].get());
        if (!elemPtrI8 || !value)
            return nullptr;

        Type *i8ptrTy = get_i8ptr_type();
        Value *srcPtr = nullptr;
        if (value->getType()->isPointerTy())
        {
            Value *tmp = builder.CreateAlloca(value->getType(), nullptr, "array.set.ptr.tmp");
            builder.CreateStore(value, tmp);
            srcPtr = builder.CreatePointerCast(tmp, i8ptrTy, "array.set.src.ptr.value");
        }
        else
        {
            Value *tmp = builder.CreateAlloca(value->getType(), nullptr, "array.set.tmp");
            builder.CreateStore(value, tmp);
            srcPtr = builder.CreatePointerCast(tmp, i8ptrTy, "array.set.src.i8");
        }
        builder.CreateMemCpy(elemPtrI8, MaybeAlign(1), srcPtr, MaybeAlign(1), elemSize);
        return nullptr;
    }

    if (name == "__YCPL_std__array_free")
    {
        if (ce->args.size() != 1)
        {
            error("array.free expects 1 argument");
            return nullptr;
        }
        Value *arrPtr = array_ptr_from_expr(ce->args[0].get(), "array.free.ptr");
        if (!arrPtr)
            return nullptr;
        Value *dataPtrPtr = array_field(arrPtr, 0, "array.free.data.ptr.ptr");
        Value *dataPtr = builder.CreateLoad(get_i8ptr_type(), dataPtrPtr, "array.free.data.ptr");
        Function *freeFn = get_c_function("free");
        if (!freeFn)
        {
            error("free is not available");
            return nullptr;
        }
        builder.CreateCall(freeFn, {dataPtr});
        builder.CreateCall(freeFn, {builder.CreatePointerCast(arrPtr, get_i8ptr_type(), "array.free.struct.i8")});
        return nullptr;
    }

    if (name == "__YCPL_std__mem_alloc" || name == "__YCPL_std__mem_calloc" || name == "__YCPL_std__mem_realloc" ||
        name == "__YCPL_std__mem_free" || name == "__YCPL_std__mem_copy" || name == "__YCPL_std__mem_set")
    {
        std::string c_name;
        if (name == "__YCPL_std__mem_alloc")
            c_name = "malloc";
        else if (name == "__YCPL_std__mem_calloc")
            c_name = "calloc";
        else if (name == "__YCPL_std__mem_realloc")
            c_name = "realloc";
        else if (name == "__YCPL_std__mem_free")
            c_name = "free";
        else if (name == "__YCPL_std__mem_copy")
            c_name = "memcpy";
        else
            c_name = "memset";

        Function *fn = get_c_function(c_name);
        if (!fn)
        {
            error(c_name + " is not available");
            return nullptr;
        }

        std::vector<Value *> args;
        for (size_t i = 0; i < ce->args.size(); ++i)
        {
            Value *arg = codegen_expr(ce->args[i].get());
            if (!arg)
                return nullptr;

            if (c_name == "malloc")
            {
                args.push_back(to_i64(arg, "mem.alloc.size"));
            }
            else if (c_name == "calloc")
            {
                args.push_back(to_i64(arg, i == 0 ? "mem.calloc.count" : "mem.calloc.size"));
            }
            else if (c_name == "realloc")
            {
                args.push_back(i == 0 ? to_i8ptr(arg, "mem.realloc.ptr") : to_i64(arg, "mem.realloc.size"));
            }
            else if (c_name == "free")
            {
                args.push_back(to_i8ptr(arg, "mem.free.ptr"));
            }
            else if (c_name == "memcpy")
            {
                args.push_back(i < 2 ? to_i8ptr(arg, "mem.copy.ptr") : to_i64(arg, "mem.copy.size"));
            }
            else
            {
                if (i == 0)
                    args.push_back(to_i8ptr(arg, "mem.set.ptr"));
                else if (i == 1)
                    args.push_back(to_i32(arg, "mem.set.value"));
                else
                    args.push_back(to_i64(arg, "mem.set.size"));
            }
        }

        if (fn->getReturnType()->isVoidTy())
            return builder.CreateCall(fn, args);
        return builder.CreateCall(fn, args, "call_" + c_name);
    }

    if (name == "__YCPL_std__mem_sizeof")
    {
        if (ce->args.size() != 1)
        {
            error("mem.sizeof expects one type argument");
            return nullptr;
        }
        auto typeExpr = dynamic_cast<const ast::TypeExpr *>(ce->args[0].get());
        if (!typeExpr)
        {
            error("mem.sizeof expects a type argument");
            return nullptr;
        }

        Type *llvmTy = nullptr;
        if (dynamic_cast<const ast::ArrayType *>(typeExpr->type.get()))
            llvmTy = detail::getOrCreateArrayStruct(context);
        else
            llvmTy = resolve_type_from_ast(typeExpr->type.get());
        if (!llvmTy)
        {
            error("mem.sizeof cannot resolve type");
            return nullptr;
        }
        const DataLayout &dl = module->getDataLayout();
        return ConstantInt::get(get_i64_type(), dl.getTypeAllocSize(llvmTy));
    }

    if (name == "__YCPL_std__str_len" || name == "__YCPL_std__str_cmp" || name == "__YCPL_std__str_copy" || name == "__YCPL_std__str_eq")
    {
        std::string c_name = name == "__YCPL_std__str_len" ? "strlen" : (name == "__YCPL_std__str_copy" ? "strcpy" : "strcmp");
        Function *fn = get_c_function(c_name);
        if (!fn)
        {
            error(c_name + " is not available");
            return nullptr;
        }

        if (name == "__YCPL_std__str_len")
        {
            if (ce->args.size() != 1)
            {
                error("str.len expects 1 argument");
                return nullptr;
            }
            Value *s = to_i8ptr(codegen_expr(ce->args[0].get()), "str.len.ptr");
            return builder.CreateCall(fn, {s}, "call_strlen");
        }

        if (ce->args.size() != 2)
        {
            error("str function expects 2 arguments");
            return nullptr;
        }
        Value *a = to_i8ptr(codegen_expr(ce->args[0].get()), "str.arg.a");
        Value *b = to_i8ptr(codegen_expr(ce->args[1].get()), "str.arg.b");
        Value *result = builder.CreateCall(fn, {a, b}, "call_" + c_name);
        if (name == "__YCPL_std__str_eq")
            return builder.CreateICmpEQ(result, ConstantInt::get(result->getType(), 0), "str.eq");
        return result;
    }

    if (name == "__YCPL_std__math_abs")
    {
        if (ce->args.size() != 1)
        {
            error("math.abs expects 1 argument");
            return nullptr;
        }
        Value *arg = codegen_expr(ce->args[0].get());
        if (!arg)
            return nullptr;
        if (arg->getType()->isIntegerTy())
        {
            Value *zero = ConstantInt::get(arg->getType(), 0);
            return builder.CreateSelect(builder.CreateICmpSLT(arg, zero), builder.CreateNeg(arg), arg, "math.abs");
        }
        Function *fabsFn = get_c_function("fabs");
        if (!fabsFn)
        {
            error("fabs is not available");
            return nullptr;
        }
        return builder.CreateCall(fabsFn, {to_double(arg, "math.abs.double")}, "call_fabs");
    }

    if (name == "__YCPL_std__math_pow" || name == "__YCPL_std__math_sin" || name == "__YCPL_std__math_cos" || name == "__YCPL_std__math_sqrt")
    {
        std::string c_name;
        if (name == "__YCPL_std__math_pow")
            c_name = "pow";
        else if (name == "__YCPL_std__math_sin")
            c_name = "sin";
        else if (name == "__YCPL_std__math_cos")
            c_name = "cos";
        else
            c_name = "sqrt";

        Function *fn = get_c_function(c_name);
        if (!fn)
        {
            error(c_name + " is not available");
            return nullptr;
        }

        if (c_name == "pow")
        {
            if (ce->args.size() != 2)
            {
                error("math.pow expects 2 arguments");
                return nullptr;
            }
            return builder.CreateCall(fn, {to_double(codegen_expr(ce->args[0].get()), "math.pow.a"), to_double(codegen_expr(ce->args[1].get()), "math.pow.b")}, "call_pow");
        }

        if (ce->args.size() != 1)
        {
            error("math function expects 1 argument");
            return nullptr;
        }
        return builder.CreateCall(fn, {to_double(codegen_expr(ce->args[0].get()), "math.arg")}, "call_" + c_name);
    }

    error("unknown std intrinsic: " + name);
    return nullptr;
}

Value *CodeGen::codegen_call(const ast::CallExpr *ce)
{
    if (auto ident = dynamic_cast<const ast::Ident *>(ce->callee.get()))
    {
        if (is_YCPL_std_intrinsic(ident->name))
        {
            return codegen_std_intrinsic_call(ident->name, ce);
        }

        if (ident->name == "println")
        {
            return codegen_println_call(ce);
        }
        else if (ident->name == "printf")
        {
            return codegen_printf_call(ce);
        }
        else if (ident->name == "sprintf")
        {
            return codegen_sprintf_call(ce);
        }
        else if (ident->name == "len")
        {
            return codegen_len_call(ce);
        }
        else if (ident->name == "append")
        {
            return codegen_append_call(ce);
        }
        else if (ident->name == "cast")
        {
            return codegen_cast_call(ce);
        }
        else if (ident->name == "new")
        {
            return codegen_new_call(ce);
        }
    }

    Value *calleeVal = codegen_expr(ce->callee.get());
    if (!calleeVal)
        return nullptr;

    Function *F = nullptr;
    if (auto gv = dyn_cast<GlobalValue>(calleeVal))
    {
        F = dyn_cast<Function>(gv);
    }

    if (!F)
    {
        if (auto id = dynamic_cast<const ast::Ident *>(ce->callee.get()))
        {
            auto it = function_protos.find(id->name);
            if (it != function_protos.end())
                F = it->second;
        }
    }

    if (!F)
    {
        error("call to unknown function");
        return nullptr;
    }

    std::vector<Value *> argsV;
    FunctionType *calleeType = F->getFunctionType();
    for (size_t i = 0; i < ce->args.size(); ++i)
    {
        Value *argv = codegen_expr(ce->args[i].get());
        if (!argv)
            return nullptr;

        if (i < calleeType->getNumParams())
        {
            Type *paramTy = calleeType->getParamType(static_cast<unsigned>(i));
            if (argv->getType() != paramTy)
            {
                if (argv->getType()->isIntegerTy() && paramTy->isIntegerTy())
                    argv = builder.CreateSExtOrTrunc(argv, paramTy, "call.arg.intcast");
                else if (argv->getType()->isIntegerTy() && paramTy->isFloatingPointTy())
                    argv = builder.CreateSIToFP(argv, paramTy, "call.arg.sitofp");
                else if (argv->getType()->isFloatingPointTy() && paramTy->isIntegerTy())
                    argv = builder.CreateFPToSI(argv, paramTy, "call.arg.fptosi");
                else if (argv->getType()->isPointerTy() && paramTy->isPointerTy())
                    argv = builder.CreatePointerCast(argv, paramTy, "call.arg.ptrcast");
                else if (argv->getType()->isPointerTy() && paramTy->isIntegerTy())
                    argv = builder.CreatePtrToInt(argv, paramTy, "call.arg.ptrtoint");
                else if (argv->getType()->isIntegerTy() && paramTy->isPointerTy())
                    argv = builder.CreateIntToPtr(argv, cast<PointerType>(paramTy), "call.arg.inttoptr");
            }
        }
        argsV.push_back(argv);
    }

    CallInst *callInst = builder.CreateCall(F, argsV);
    if (!F->getReturnType()->isVoidTy())
    {
        callInst->setName("calltmp");
        return callInst;
    }

    return nullptr;
}
