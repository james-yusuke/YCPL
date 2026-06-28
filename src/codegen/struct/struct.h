#pragma once
#include "../codegen.h"
#include "../common.h"
#include <llvm/IR/Constants.h>
#include <llvm/IR/DerivedTypes.h>
#include <llvm/IR/Intrinsics.h>
#include <memory>
#include <string>
#include <vector>
#include <algorithm>

using namespace llvm;
using namespace codegen;

Type *CodeGen::resolve_type_from_ast(const ast::Type *at)
{
    if (!at)
        return nullptr;

    if (auto named = dynamic_cast<const ast::NamedType *>(at))
    {

        return resolve_type_by_name(named->name);
    }

    if (auto ptr = dynamic_cast<const ast::PointerType *>(at))
    {
        Type *inner = resolve_type_from_ast(ptr->base.get());
        if (!inner)
            inner = get_int_type();
        return llvm::PointerType::getUnqual(inner);
    }

    if (auto arr = dynamic_cast<const ast::ArrayType *>(at))
    {
        llvm::Type *elem = resolve_type_from_ast(arr->elem.get());
        if (!elem)
            elem = get_int_type();

        return llvm::PointerType::getUnqual(elem);
    }

    if (auto f = dynamic_cast<const ast::FuncType *>(at))
    {

        std::vector<llvm::Type *> params;
        for (const auto &p : f->params)
        {
            llvm::Type *pt = resolve_type_from_ast(p.get());
            if (!pt)
                pt = get_int_type();
            params.push_back(pt);
        }
        llvm::Type *ret = nullptr;
        if (f->ret)
            ret = resolve_type_from_ast(f->ret.get());
        if (!ret)
            ret = get_int_type();
        llvm::FunctionType *fty = llvm::FunctionType::get(ret, params, /*isVarArg=*/false);
        return llvm::PointerType::getUnqual(fty);
    }

    return nullptr;
}

static std::string namedTypeName(const ast::Type *at)
{
    if (!at)
        return std::string();

    if (auto named = dynamic_cast<const ast::NamedType *>(at))
    {
        return named->name;
    }
    if (auto ptr = dynamic_cast<const ast::PointerType *>(at))
    {
        return namedTypeName(ptr->base.get());
    }
    if (auto arr = dynamic_cast<const ast::ArrayType *>(at))
    {
        return namedTypeName(arr->elem.get());
    }
    if (auto ft = dynamic_cast<const ast::FuncType *>(at))
    {
        if (ft->ret)
            return namedTypeName(ft->ret.get());
    }
    return std::string();
}

void CodeGen::prepare_struct_types(const ast::Program &prog)
{
    struct_types.clear();
    struct_decls.clear();

    for (const auto &dptr : prog.decls)
    {
        if (auto sd = dynamic_cast<const ast::StructDecl *>(dptr.get()))
        {
            if (!sd->name.empty())
            {
                struct_decls[sd->name] = sd;

                if (struct_types.find(sd->name) == struct_types.end())
                {
                    llvm::StructType *st = llvm::StructType::create(context, sd->name);
                    struct_types[sd->name] = st;
                }
            }
        }
    }

    for (const auto &kv : struct_decls)
    {
        const std::string name = kv.first;
        const ast::StructDecl *sd = kv.second;
        llvm::StructType *st = struct_types[name];
        if (!st)
        {
            st = llvm::StructType::create(context, name);
            struct_types[name] = st;
        }

        if (!st->isOpaque())
            continue;

        std::vector<llvm::Type *> elems;
        for (const auto &fptr : sd->fields)
        {

            if (fptr->inline_struct)
            {

                const ast::StructDecl *inner = fptr->inline_struct.get();

                llvm::StructType *innerSt = llvm::StructType::create(context);

                std::vector<llvm::Type *> innerElems;
                for (const auto &ifptr : inner->fields)
                {

                    llvm::Type *t = nullptr;
                    if (ifptr->type)
                    {
                        t = resolve_type_from_ast(ifptr->type.get());
                    }
                    if (!t)
                        t = get_int_type();
                    innerElems.push_back(t);
                }
                innerSt->setBody(innerElems, /*isPacked=*/false);
                elems.push_back(innerSt);
            }
            else
            {
                llvm::Type *ft = nullptr;
                if (fptr->type)
                    ft = resolve_type_from_ast(fptr->type.get());
                if (!ft)
                    ft = get_int_type();
                elems.push_back(ft);
            }
        }

        st->setBody(elems, /*isPacked=*/false);
    }
}

llvm::Type *CodeGen::resolve_type_by_name(const std::string &typeName)
{
    if (typeName.empty())
        return nullptr;

    if (typeName == "string")
        return llvm::PointerType::getUnqual(Type::getInt8Ty(context));

    if (typeName == "bool")
        return Type::getInt1Ty(context);

    if (typeName == "char")
        return Type::getInt8Ty(context);

    if (typeName == "byte")
        return Type::getInt8Ty(context);

    if (typeName == "size_t")
        return get_i64_type();

    if (typeName[0] == '*')
    {
        std::string inner = typeName.substr(1);
        llvm::Type *t = resolve_type_by_name(inner);
        if (!t)
            t = get_int_type();
        return llvm::PointerType::getUnqual(t);
    }

    if (typeName.rfind("[]", 0) == 0)
    {
        std::string inner = typeName.substr(2);
        llvm::Type *et = resolve_type_by_name(inner);
        if (!et)
            et = get_int_type();
        return llvm::PointerType::getUnqual(et);
    }

    if (typeName == "i32")
        return get_int_type();
    if (typeName == "i64")
        return get_i64_type();
    if (typeName == "double" || typeName == "float")
        return get_double_type();
    if (typeName == "void")
        return get_void_type();
    if (typeName == "string")
        return llvm::PointerType::getUnqual(Type::getInt8Ty(context));

    auto it = struct_types.find(typeName);
    if (it != struct_types.end())
        return it->second;

    llvm::StructType *st = llvm::StructType::create(context, typeName);
    struct_types[typeName] = st;
    return st;
}

llvm::StructType *CodeGen::get_or_create_named_struct(const std::string &name)
{
    if (name.empty())
        return nullptr;
    auto it = struct_types.find(name);
    if (it != struct_types.end())
        return it->second;
    llvm::StructType *st = llvm::StructType::create(context, name);
    struct_types[name] = st;
    return st;
}

int CodeGen::get_field_index(const ast::StructDecl *sd, const std::string &fieldName)
{
    if (!sd)
        return -1;

    for (size_t i = 0; i < sd->fields.size(); ++i)
    {
        const auto &f = sd->fields[i];

        if (f->name == fieldName)
            return static_cast<int>(i);
    }
    return -1;
}

llvm::Value *CodeGen::codegen_struct_literal(const ast::StructLiteral *sl)
{
    if (!sl)
        return nullptr;
    if (!sl->type)
    {
        error("anonymous struct literals not supported");
        return nullptr;
    }

    auto named = dynamic_cast<const ast::NamedType *>(sl->type.get());
    if (!named)
    {
        error("struct literal type must be a named type");
        return nullptr;
    }

    const std::string &typeName = named->name;

    auto it = struct_decls.find(typeName);
    if (it == struct_decls.end())
    {
        error("unknown struct type: " + typeName);
        return nullptr;
    }

    const ast::StructDecl *sd = it->second;

    llvm::StructType *st = get_or_create_named_struct(typeName);
    if (!st)
    {
        error("failed to get struct type for: " + typeName);
        return nullptr;
    }

    if (!st->isSized())
    {
        error("struct type '" + typeName + "' is not yet defined (opaque) -- ensure prepare_struct_types ran or the struct name matches");
        return nullptr;
    }

    Function *curF = builder.GetInsertBlock()->getParent();
    IRBuilder<> tmp(&curF->getEntryBlock(), curF->getEntryBlock().begin());
    llvm::AllocaInst *all = tmp.CreateAlloca(st, /*ArraySize=*/nullptr, (typeName + ".tmp").c_str());

    std::vector<const ast::StructFieldInit *> positional(sd->fields.size(), nullptr);
    for (const auto &init : sl->inits)
    {
        if (init.name.has_value())
        {
            int idx = get_field_index(sd, *init.name);
            if (idx < 0)
            {
                error("unknown field '" + *init.name + "' in struct literal for " + typeName);
                return nullptr;
            }
            positional[idx] = &init;
        }
        else
        {
            bool placed = false;
            for (size_t i = 0; i < positional.size(); ++i)
            {
                if (!positional[i])
                {
                    positional[i] = &init;
                    placed = true;
                    break;
                }
            }
            if (!placed)
            {
                error("too many positional initializers for struct " + typeName);
                return nullptr;
            }
        }
    }

    for (size_t i = 0; i < positional.size(); ++i)
    {
        const ast::StructFieldInit *initPtr = positional[i];
        if (!initPtr)
            continue;

        Value *idx0 = ConstantInt::get(Type::getInt32Ty(context), 0);
        Value *idx1 = ConstantInt::get(Type::getInt32Ty(context), static_cast<uint32_t>(i));
        SmallVector<Value *, 2> idxs = {idx0, idx1};

        Value *fieldAddr = builder.CreateInBoundsGEP(st, all, ArrayRef<Value *>(idxs.data(), idxs.size()), typeName + ".field" + std::to_string(i) + ".addr");

        Value *v = codegen_expr(initPtr->value.get());
        if (!v)
        {
            error("failed generating initializer for struct field");
            return nullptr;
        }

        llvm::Type *fieldTy = st->getElementType((unsigned)i);

        if (fieldTy->isStructTy() && v->getType()->isPointerTy())
        {

            Type *srcElem = cast<PointerType>(v->getType());

            if (srcElem != fieldTy)
            {
                v = builder.CreateBitCast(v, PointerType::getUnqual(fieldTy), (typeName + ".field" + std::to_string(i) + ".cast_ptr").c_str());
            }

            Value *loadedStruct = builder.CreateLoad(fieldTy, v, (typeName + ".field" + std::to_string(i) + ".load").c_str());
            builder.CreateStore(loadedStruct, fieldAddr);
            continue;
        }

        if (v->getType() != fieldTy)
        {
            if (v->getType()->isIntegerTy() && fieldTy->isIntegerTy())
            {
                v = builder.CreateIntCast(v, fieldTy, true, "cast_int_field");
                builder.CreateStore(v, fieldAddr);
            }
            else if (v->getType()->isFloatingPointTy() && fieldTy->isFloatingPointTy())
            {
                if (v->getType() != fieldTy)
                    v = builder.CreateFPExt(v, fieldTy, "cast_fp_field");
                builder.CreateStore(v, fieldAddr);
            }
            else if (fieldTy->isPointerTy() && v->getType()->isPointerTy())
            {
                if (v->getType() != fieldTy)
                    v = builder.CreateBitCast(v, fieldTy, "bitcast_ptr_field");
                builder.CreateStore(v, fieldAddr);
            }
            else if (v->getType() == fieldTy)
            {
                builder.CreateStore(v, fieldAddr);
            }
            else
            {
                if (v->getType()->isPointerTy() && fieldTy->isPointerTy())
                {
                    v = builder.CreateBitCast(v, fieldTy, "bitcast_ptr_field_fallback");
                    builder.CreateStore(v, fieldAddr);
                }
                else
                {
                    error("type mismatch storing into struct field (index " + std::to_string(i) + ")");
                    return nullptr;
                }
            }
        }
        else
        {
            builder.CreateStore(v, fieldAddr);
        }
    }

    return all;
}

static const ast::StructDecl *findStructDecl(
    const std::unordered_map<std::string, const ast::StructDecl *> &struct_decls_map,
    llvm::StructType *st)
{
    if (!st || !st->hasName())
        return nullptr;

    std::string nm = st->getName().str();

    auto it = struct_decls_map.find(nm);
    if (it != struct_decls_map.end())
        return it->second;

    for (const auto &kv : struct_decls_map)
    {
        const std::string &declName = kv.first;
        if (nm == declName)
            return kv.second;
        if (nm.find(declName) != std::string::npos)
            return kv.second;

        if (declName.find(nm) != std::string::npos)
            return kv.second;
    }

    auto split_tokens = [](const std::string &s)
    {
        std::vector<std::string> tok;
        std::string cur;
        for (char c : s)
        {
            if (c == ':' || c == '.' || c == '/')
            {
                if (!cur.empty())
                {
                    tok.push_back(cur);
                    cur.clear();
                }
            }
            else
                cur.push_back(c);
        }
        if (!cur.empty())
            tok.push_back(cur);
        return tok;
    };

    auto nm_toks = split_tokens(nm);
    for (const auto &kv : struct_decls_map)
    {
        auto decl_toks = split_tokens(kv.first);
        for (const auto &nt : nm_toks)
        {
            for (const auto &dt : decl_toks)
            {
                if (nt == dt)
                    return kv.second;
            }
        }
    }

    return nullptr;
}

Value *CodeGen::codegen_member_addr(const ast::MemberExpr *me)
{
    if (!me)
    {
        error("null member expr");
        return nullptr;
    }

    std::vector<const ast::MemberExpr *> chain;
    const ast::Expr *cur = me;
    while (auto m = dynamic_cast<const ast::MemberExpr *>(cur))
    {
        chain.push_back(m);
        cur = m->object.get();
    }

    Value *basePtr = nullptr;
    StructType *curStructTy = nullptr;
    const ast::StructDecl *curDecl = nullptr;

    if (auto id = dynamic_cast<const ast::Ident *>(cur))
    {
        Value *objVal = lookup_local(id->name);
        if (!objVal)
        {
            error("unknown identifier in member access: " + id->name);
            return nullptr;
        }

        auto [st, ptr] = resolve_struct_and_ptr(objVal, id->name);
        if (!st || !ptr)
        {

            if (!st && !ptr)
            {
                error("member access on non-struct object for: " + id->name);
                return nullptr;
            }
        }

        curStructTy = st;
        basePtr = ptr ? ptr : objVal;

        if (curStructTy)
            curDecl = findStructDecl(struct_decls, curStructTy);
    }
    else
    {
        Value *objVal = codegen_expr(cur);
        if (!objVal)
            return nullptr;

        auto [st, ptr] = resolve_struct_and_ptr(objVal, std::string());
        if (st)
            curStructTy = st;
        basePtr = objVal;

        if (!curStructTy && basePtr->getType()->isPointerTy())
        {
            Type *elt = basePtr->getType();
            if (elt && elt->isStructTy())
            {
                curStructTy = dyn_cast<StructType>(elt);
                if (curStructTy)
                    curDecl = findStructDecl(struct_decls, curStructTy);
            }
        }

        if (curStructTy && !curDecl)
            curDecl = findStructDecl(struct_decls, curStructTy);
    }

    if (!basePtr)
    {
        error("unable to determine base pointer for member access");
        return nullptr;
    }
    if (!curStructTy)
    {

        if (basePtr->getType()->isPointerTy())
        {
            Type *elt = basePtr->getType();
            if (elt && elt->isStructTy())
                curStructTy = dyn_cast<StructType>(elt);
        }
        if (!curStructTy)
        {
            error("unable to determine struct type for member access");
            return nullptr;
        }
        if (!curDecl)
            curDecl = findStructDecl(struct_decls, curStructTy);
    }

    {
        PointerType *desiredPtrTy = PointerType::getUnqual(curStructTy);

        if (basePtr->getType()->isIntegerTy())
        {
            basePtr = builder.CreateIntToPtr(basePtr, desiredPtrTy, "base_int_to_ptr");
        }
        else if (basePtr->getType()->isPointerTy())
        {
            Type *pointee = basePtr->getType();
            if (pointee != curStructTy)
            {
                basePtr = builder.CreateBitCast(basePtr, desiredPtrTy, "base_ptr_bitcast");
            }
        }
        else if (basePtr->getType()->isStructTy())
        {
            Value *tmp = builder.CreateAlloca(basePtr->getType(), nullptr, "member_tmp");
            builder.CreateStore(basePtr, tmp);
            basePtr = tmp;
            if (basePtr->getType() != desiredPtrTy)
                basePtr = builder.CreateBitCast(basePtr, desiredPtrTy, "member_tmp_cast");
        }
        else
        {
            error("unsupported basePtr kind for member access");
            return nullptr;
        }
    }

    for (int ci = static_cast<int>(chain.size()) - 1; ci >= 0; --ci)
    {
        const ast::MemberExpr *m = chain[ci];
        const std::string &fieldName = m->member;

        if (curStructTy && (!curDecl || (curDecl && curDecl->name != curStructTy->getName().str())))
        {
            const ast::StructDecl *found = findStructDecl(struct_decls, curStructTy);
            if (found)
                curDecl = found;
        }

        if (!curDecl)
        {
            error("no AST struct decl available while resolving member: " + fieldName);
            return nullptr;
        }

        int idx = get_field_index(curDecl, fieldName);

        if (idx < 0)
        {
            bool foundAlt = false;
            for (const auto &kv : struct_decls)
            {
                int altIdx = get_field_index(kv.second, fieldName);
                if (altIdx >= 0)
                {

                    idx = altIdx;
                    curDecl = kv.second;
                    foundAlt = true;
                    break;
                }
            }
            if (!foundAlt)
            {
                error("no such field '" + fieldName + "' in struct " + curDecl->name);
                return nullptr;
            }
        }

        Value *zero = ConstantInt::get(Type::getInt32Ty(context), 0);
        Value *iidx = ConstantInt::get(Type::getInt32Ty(context), (uint32_t)idx);
        SmallVector<Value *, 2> idxs = {zero, iidx};

        Value *gep = builder.CreateInBoundsGEP(curStructTy, basePtr, ArrayRef<Value *>(idxs.data(), idxs.size()), fieldName + ".addr");

        const auto &field = curDecl->fields[(size_t)idx];
        llvm::Type *fieldTy = nullptr;
        if (field->type)
            fieldTy = resolve_type_from_ast(field->type.get());
        if (!fieldTy)
            fieldTy = get_int_type();

        basePtr = gep;

        if (fieldTy && fieldTy->isStructTy())
        {
            curStructTy = dyn_cast<StructType>(fieldTy);
            curDecl = curStructTy ? findStructDecl(struct_decls, curStructTy) : nullptr;
        }
        else if (fieldTy && fieldTy->isPointerTy())
        {
            Type *pointee = fieldTy;
            if (pointee && pointee->isStructTy())
            {
                curStructTy = dyn_cast<StructType>(pointee);
                curDecl = curStructTy ? findStructDecl(struct_decls, curStructTy) : nullptr;
            }
            else
            {
                curStructTy = nullptr;
                curDecl = nullptr;
            }
        }
        else
        {
            curStructTy = nullptr;
            curDecl = nullptr;
        }
    }

    return basePtr;
}

llvm::Value *CodeGen::codegen_member(const ast::MemberExpr *me)
{
    if (!me)
        return nullptr;

    llvm::Value *addr = codegen_member_addr(me);
    if (!addr)
        return nullptr;

    std::vector<const ast::MemberExpr *> chain;
    const ast::Expr *cur = me;
    while (auto m = dynamic_cast<const ast::MemberExpr *>(cur))
    {
        chain.push_back(m);
        cur = m->object.get();
    }

    const ast::StructDecl *curDecl = nullptr;

    if (auto id = dynamic_cast<const ast::Ident *>(cur))
    {
        Value *objVal = lookup_local(id->name);
        if (!objVal)
        {
            error("unknown identifier in member access: " + id->name);
            return nullptr;
        }

        auto [st, ptr] = resolve_struct_and_ptr(objVal, id->name);
        if (st && st->hasName())
        {
            auto it = struct_decls.find(st->getName().str());
            if (it != struct_decls.end())
                curDecl = it->second;
        }
    }
    else
    {

        Value *objVal = codegen_expr(cur);
        if (!objVal)
            return nullptr;
        auto [st, ptr] = resolve_struct_and_ptr(objVal, std::string());
        if (st && st->hasName())
        {
            auto it = struct_decls.find(st->getName().str());
            if (it != struct_decls.end())
                curDecl = it->second;
        }
    }

    if (!curDecl)
    {

        error("cannot determine base struct declaration for member expression");
        return nullptr;
    }

    llvm::Type *finalFieldTy = nullptr;
    for (int i = static_cast<int>(chain.size()) - 1; i >= 0; --i)
    {
        const ast::MemberExpr *m = chain[i];
        const std::string &fname = m->member;

        int idx = get_field_index(curDecl, fname);
        if (idx < 0)
        {
            error("no such field '" + fname + "' in struct " + curDecl->name);
            return nullptr;
        }

        const auto &field = curDecl->fields[(size_t)idx];

        if (i == 0)
        {
            if (field->type)
                finalFieldTy = resolve_type_from_ast(field->type.get());
            if (!finalFieldTy)
                finalFieldTy = get_int_type();
            break;
        }

        std::string innerName = namedTypeName(field->type.get());
        if (!innerName.empty())
        {
            auto it = struct_decls.find(innerName);
            if (it != struct_decls.end())
            {
                curDecl = it->second;
                continue;
            }
            else
            {
                curDecl = nullptr;
                break;
            }
        }
        else
        {

            llvm::Type *ft = nullptr;
            if (field->type)
                ft = resolve_type_from_ast(field->type.get());
            if (ft)
            {
                if (ft->isStructTy())
                {
                    auto st = dyn_cast<StructType>(ft);
                    if (st && st->hasName())
                    {
                        auto it = struct_decls.find(st->getName().str());
                        if (it != struct_decls.end())
                        {
                            curDecl = it->second;
                            continue;
                        }
                    }
                }
                else if (ft->isPointerTy())
                {
                    Type *pointee = ft;
                    if (pointee && pointee->isStructTy())
                    {
                        auto st = dyn_cast<StructType>(pointee);
                        if (st && st->hasName())
                        {
                            auto it = struct_decls.find(st->getName().str());
                            if (it != struct_decls.end())
                            {
                                curDecl = it->second;
                                continue;
                            }
                        }
                    }
                }
            }

            curDecl = nullptr;
            break;
        }
    }

    if (!finalFieldTy)
    {
        error("unable to determine final field type for member expression");
        return nullptr;
    }

    return builder.CreateLoad(finalFieldTy, addr, me->member + ".val");
}
