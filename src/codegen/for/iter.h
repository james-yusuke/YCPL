#pragma once
#include "../codegen.h"
#include "../common.h"
#include "../array/parse.h"
#include <llvm/IR/Constants.h>
#include <llvm/IR/DerivedTypes.h>
#include <llvm/IR/Intrinsics.h>

using namespace llvm;
using namespace codegen;

Value *CodeGen::codegen_forinstmt(const ast::ForInStmt *fs)
{
    Function *F = builder.GetInsertBlock()->getParent();
    Value *iterV = codegen_expr(fs->iterable.get());
    if (!iterV)
        return nullptr;

    if (auto id = dynamic_cast<const ast::Ident *>(fs->iterable.get()))
    {
        std::string *typeHint = lookup_local_type(id->name);
        if (typeHint)
        {
            ParsedType parsed = parse_type_chain(*typeHint);
            if (parsed.array_depth > 0)
            {
                StructType *arrayStruct = detail::getOrCreateArrayStruct(context);
                Type *arrayPtrTy = arrayStruct->getPointerTo();
                Type *i64Ty = get_i64_type();
                Type *i8Ty = Type::getInt8Ty(context);
                Type *i8ptrTy = get_i8ptr_type();

                Value *arrPtr = iterV;
                if (arrPtr->getType() != arrayPtrTy)
                    arrPtr = builder.CreatePointerCast(arrPtr, arrayPtrTy, "forin.array.ptr");

                Value *lenPtr = builder.CreateStructGEP(arrayStruct, arrPtr, 1, "forin.array.len.ptr");
                Value *lenVal = builder.CreateLoad(i64Ty, lenPtr, "forin.array.len");
                Value *dataPtrPtr = builder.CreateStructGEP(arrayStruct, arrPtr, 0, "forin.array.data.ptr.ptr");
                Value *dataPtr = builder.CreateLoad(i8ptrTy, dataPtrPtr, "forin.array.data");
                Value *elemSizePtr = builder.CreateStructGEP(arrayStruct, arrPtr, 3, "forin.array.elem_size.ptr");
                Value *elemSize = builder.CreateLoad(i64Ty, elemSizePtr, "forin.array.elem_size");

                Value *idxAlloca = create_entry_alloca(F, i64Ty, ".forin.array.idx");
                builder.CreateStore(ConstantInt::get(i64Ty, 0), idxAlloca);

                std::string elemTypeName = parsed.base;
                for (int i = 1; i < parsed.array_depth; ++i)
                    elemTypeName += "[]";
                for (int i = 0; i < parsed.pointer_depth; ++i)
                    elemTypeName += "*";

                Type *elemTy = nullptr;
                if (parsed.array_depth > 1)
                    elemTy = arrayPtrTy;
                else
                    elemTy = getLLVMType(elemTypeName);
                if (!elemTy)
                    elemTy = get_int_type();

                Value *varAlloca = create_entry_alloca(F, elemTy, fs->var);

                BasicBlock *condBB = BasicBlock::Create(context, "forin.array.cond", F);
                BasicBlock *bodyBB = BasicBlock::Create(context, "forin.array.body", F);
                BasicBlock *incrBB = BasicBlock::Create(context, "forin.array.incr", F);
                BasicBlock *afterBB = BasicBlock::Create(context, "forin.array.end", F);

                if (!builder.GetInsertBlock()->getTerminator())
                    builder.CreateBr(condBB);

                builder.SetInsertPoint(condBB);
                Value *idxLoad = builder.CreateLoad(i64Ty, idxAlloca, ".forin.array.idx.load");
                Value *cmp = builder.CreateICmpULT(idxLoad, lenVal, "forin.array.cmp");
                builder.CreateCondBr(cmp, bodyBB, afterBB);

                break_targets.push_back(afterBB);
                continue_targets.push_back(incrBB);

                builder.SetInsertPoint(bodyBB);
                push_scope();
                bind_local(fs->var, elemTypeName, varAlloca);

                Value *idxInBody = builder.CreateLoad(i64Ty, idxAlloca, ".forin.array.idx.load2");
                Value *offset = builder.CreateMul(idxInBody, elemSize, "forin.array.offset");
                Value *slotI8 = builder.CreateInBoundsGEP(i8Ty, dataPtr, {offset}, "forin.array.slot.i8");
                Value *slot = builder.CreatePointerCast(slotI8, PointerType::getUnqual(elemTy), "forin.array.slot");
                Value *elemVal = builder.CreateLoad(elemTy, slot, "forin.array.elem");
                builder.CreateStore(elemVal, varAlloca);

                if (fs->body)
                    codegen_block(fs->body.get());

                pop_scope();

                if (!builder.GetInsertBlock()->getTerminator())
                    builder.CreateBr(incrBB);

                builder.SetInsertPoint(incrBB);
                Value *idxOld = builder.CreateLoad(i64Ty, idxAlloca, ".forin.array.idx.load3");
                Value *idxNew = builder.CreateAdd(idxOld, ConstantInt::get(i64Ty, 1), ".forin.array.idx.inc");
                builder.CreateStore(idxNew, idxAlloca);
                if (!builder.GetInsertBlock()->getTerminator())
                    builder.CreateBr(condBB);

                break_targets.pop_back();
                continue_targets.pop_back();

                builder.SetInsertPoint(afterBB);
                return nullptr;
            }
        }
    }

    if (iterV->getType()->isPointerTy())
    {
        Type *i8Ty = Type::getInt8Ty(context);
        Type *i8ptr = PointerType::get(i8Ty, 0);
        Value *strPtr = iterV;
        if (iterV->getType() != i8ptr)
            strPtr = builder.CreateBitCast(iterV, i8ptr, "strptr_cast");

        Value *idxAlloca = create_entry_alloca(F, get_int_type(), ".forin.idx");
        builder.CreateStore(ConstantInt::get(get_int_type(), 0), idxAlloca);

        BasicBlock *condBB = BasicBlock::Create(context, "forin.cond", F);
        BasicBlock *bodyBB = BasicBlock::Create(context, "forin.body", F);
        BasicBlock *incrBB = BasicBlock::Create(context, "forin.incr", F);
        BasicBlock *afterBB = BasicBlock::Create(context, "forin.end", F);

        if (!builder.GetInsertBlock()->getTerminator())
            builder.CreateBr(condBB);

        builder.SetInsertPoint(condBB);
        Value *idxLoad = builder.CreateLoad(get_int_type(), idxAlloca, ".forin.idx.load");

        Value *ptr = builder.CreateGEP(i8Ty, strPtr, idxLoad, "forin.gep");
        Value *ch = builder.CreateLoad(i8Ty, ptr, "forin.ch");
        Value *zero8 = ConstantInt::get(Type::getInt8Ty(context), 0);
        Value *cond = builder.CreateICmpNE(ch, zero8, "forin.cond");
        builder.CreateCondBr(cond, bodyBB, afterBB);

        Value *varAlloca = create_entry_alloca(F, get_int_type(), fs->var);

        break_targets.push_back(afterBB);
        continue_targets.push_back(incrBB);

        builder.SetInsertPoint(bodyBB);
        push_scope();

        bind_local(fs->var, "i32", varAlloca);

        Value *idxInBody = builder.CreateLoad(get_int_type(), idxAlloca, ".forin.idx.load2");
        Value *ptrInBody = builder.CreateGEP(i8Ty, strPtr, idxInBody, "forin.gep2");
        Value *ch2 = builder.CreateLoad(i8Ty, ptrInBody, "forin.ch2");

        Value *chExt = builder.CreateSExt(ch2, get_int_type(), "forin.ch.ext");
        builder.CreateStore(chExt, varAlloca);

        if (fs->body)
            codegen_block(fs->body.get());

        pop_scope();

        if (!builder.GetInsertBlock()->getTerminator())
            builder.CreateBr(incrBB);

        builder.SetInsertPoint(incrBB);
        Value *idxOld = builder.CreateLoad(get_int_type(), idxAlloca, ".forin.idx.load3");
        Value *one = ConstantInt::get(get_int_type(), 1);
        Value *idxNew = builder.CreateAdd(idxOld, one, ".forin.idx.inc");
        builder.CreateStore(idxNew, idxAlloca);
        if (!builder.GetInsertBlock()->getTerminator())
            builder.CreateBr(condBB);

        break_targets.pop_back();
        continue_targets.pop_back();

        builder.SetInsertPoint(afterBB);

        return nullptr;
    }

    if (iterV->getType()->isIntegerTy() || iterV->getType()->isFloatingPointTy())
    {

        Value *endVal = iterV;
        if (iterV->getType()->isFloatingPointTy())
        {
            endVal = builder.CreateFPToSI(iterV, get_int_type(), "end_fp_to_i");
        }
        else if (iterV->getType()->isIntegerTy() && !iterV->getType()->isIntegerTy(get_int_type()->getIntegerBitWidth()))
        {
            endVal = builder.CreateSExtOrTrunc(iterV, get_int_type(), "end_sext_trunc");
        }

        Value *idxAlloca = create_entry_alloca(F, get_int_type(), ".forin.idx");
        builder.CreateStore(ConstantInt::get(get_int_type(), 0), idxAlloca);

        BasicBlock *condBB = BasicBlock::Create(context, "forin.cond", F);
        BasicBlock *bodyBB = BasicBlock::Create(context, "forin.body", F);
        BasicBlock *incrBB = BasicBlock::Create(context, "forin.incr", F);
        BasicBlock *afterBB = BasicBlock::Create(context, "forin.end", F);

        if (!builder.GetInsertBlock()->getTerminator())
            builder.CreateBr(condBB);

        builder.SetInsertPoint(condBB);
        Value *idxLoad = builder.CreateLoad(get_int_type(), idxAlloca, ".forin.idx.load");
        Value *cmp = builder.CreateICmpSLT(idxLoad, endVal, "forin.cmp");
        builder.CreateCondBr(cmp, bodyBB, afterBB);

        Value *varAlloca = create_entry_alloca(F, get_int_type(), fs->var);

        break_targets.push_back(afterBB);
        continue_targets.push_back(incrBB);

        builder.SetInsertPoint(bodyBB);
        push_scope();

        bind_local(fs->var, "i32", varAlloca);

        Value *idxInBody = builder.CreateLoad(get_int_type(), idxAlloca, ".forin.idx.load2");
        builder.CreateStore(idxInBody, varAlloca);

        if (fs->body)
            codegen_block(fs->body.get());

        pop_scope();

        if (!builder.GetInsertBlock()->getTerminator())
            builder.CreateBr(incrBB);

        builder.SetInsertPoint(incrBB);
        Value *idxOld = builder.CreateLoad(get_int_type(), idxAlloca, ".forin.idx.load3");
        Value *one = ConstantInt::get(get_int_type(), 1);
        Value *idxNew = builder.CreateAdd(idxOld, one, ".forin.idx.inc");
        builder.CreateStore(idxNew, idxAlloca);
        if (!builder.GetInsertBlock()->getTerminator())
            builder.CreateBr(condBB);

        break_targets.pop_back();
        continue_targets.pop_back();

        builder.SetInsertPoint(afterBB);
        return nullptr;
    }

    error("for-in only supports string (i8*), integer, or floating iterable for now");
    return nullptr;
}
