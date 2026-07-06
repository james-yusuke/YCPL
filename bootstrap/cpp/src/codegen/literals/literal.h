#pragma once
#include "../codegen.h"
#include "../common.h"
#include <llvm/IR/Constants.h>
#include <llvm/IR/DerivedTypes.h>
#include <llvm/IR/Intrinsics.h>

namespace codegen
{

Value *CodeGen::codegen_literal(const ast::Literal *lit)
{
    if (!lit)
        return nullptr;
    switch (lit->t)
    {
    case lex::TokenType::INT:
    {
        long long v = 0;
        const auto &s = lit->raw;

        if (s.size() > 2 && s[0] == '0' && (s[1] == 'x' || s[1] == 'X'))
        {
            v = std::stoll(s.substr(2), nullptr, 16);
        }

        else if (s.size() > 2 && s[0] == '0' && (s[1] == 'b' || s[1] == 'B'))
        {
            v = std::stoll(s.substr(2), nullptr, 2);
        }

        else if (s.size() > 1 && s[0] == '0')
        {
            v = std::stoll(s, nullptr, 8);
        }

        else
        {
            v = std::stoll(s, nullptr, 10);
        }

        return ConstantInt::get(get_int_type(), v, true);
    }

    case lex::TokenType::FLOAT:
    {
        double d = std::stod(lit->raw);
        return ConstantFP::get(get_double_type(), d);
    }
    case lex::TokenType::BOOL:
    {
        return ConstantInt::get(Type::getInt1Ty(context), lit->raw == "true", false);
    }
    case lex::TokenType::STRING:
    {
        std::string raw = lit->raw;
        if (!raw.empty() && (raw.front() == '"' || raw.front() == '`'))
        {
            raw = raw.substr(1, raw.size() - 2);
        }
        std::string unescaped;
        for (size_t i = 0; i < raw.size(); ++i)
        {
            if (raw[i] == '\\' && i + 1 < raw.size())
            {
                char c = raw[++i];
                if (c == 'n')
                    unescaped.push_back('\n');
                else if (c == 'r')
                    unescaped.push_back('\r');
                else if (c == 't')
                    unescaped.push_back('\t');
                else if (c == '\\')
                    unescaped.push_back('\\');
                else if (c == '"')
                    unescaped.push_back('"');
                else
                    unescaped.push_back(c);
            }
            else
            {
                unescaped.push_back(raw[i]);
            }
        }
        return make_global_string(unescaped, ".str");
    }
    case lex::TokenType::CHAR:
    {
        std::string raw = lit->raw;
        char ch = '?';
        if (raw.size() >= 3 && raw.front() == '\'' && raw.back() == '\'')
        {
            if (raw[1] == '\\' && raw.size() >= 4)
            {
                char esc = raw[2];
                if (esc == 'n')
                    ch = '\n';
                else if (esc == 't')
                    ch = '\t';
                else
                    ch = esc;
            }
            else
            {
                ch = raw[1];
            }
        }
        return ConstantInt::get(Type::getInt8Ty(context), (int64_t)ch, true);
    }
    case lex::TokenType::NONE:
    {
        return ConstantPointerNull::get(cast<PointerType>(get_i8ptr_type()));
    }
    default:
        return nullptr;
    }
}

Value *CodeGen::codegen_ident(const ast::Ident *id)
{
    if (!id)
        return nullptr;

    Value *v = lookup_local(id->name);
    if (!v)
    {
        error("unknown identifier: " + id->name);
        return nullptr;
    }

    if (AllocaInst *ai = dyn_cast<AllocaInst>(v))
    {
        Type *allocated = ai->getAllocatedType();
        return builder.CreateLoad(allocated, v, id->name + ".val");
    }

    if (GlobalVariable *gv = dyn_cast<GlobalVariable>(v))
    {
        Type *vt = gv->getValueType();
        return builder.CreateLoad(vt, v, id->name + ".val");
    }

    if (v->getType()->isPointerTy())
    {
        return v;
    }

    return v;
}

Value *CodeGen::codegen_byte_array(const ast::ByteArrayLiteral *bal)
{
    if (!bal)
        return nullptr;

    std::vector<Constant *> vals;
    vals.reserve(bal->elems.size());

    for (const auto &elemPtr : bal->elems)
    {
        if (!elemPtr)
        {
            error("null element in byte array literal");
            return nullptr;
        }

        const ast::Literal *lit = dynamic_cast<const ast::Literal *>(elemPtr.get());
        if (!lit)
        {
            error("byte array elements must be integer literals");
            return nullptr;
        }

        const std::string &s = lit->raw;
        long long v = 0;

        if (s.size() > 2 && s[0] == '0' && (s[1] == 'x' || s[1] == 'X'))
        {
            try
            {
                v = std::stoll(s.substr(2), nullptr, 16);
            }
            catch (...)
            {
                error("invalid hex in byte literal: " + s);
                return nullptr;
            }
        }
        else if (s.size() > 2 && s[0] == '0' && (s[1] == 'b' || s[1] == 'B'))
        {
            try
            {
                v = std::stoll(s.substr(2), nullptr, 2);
            }
            catch (...)
            {
                error("invalid binary in byte literal: " + s);
                return nullptr;
            }
        }
        else if (s.size() > 1 && s[0] == '0' && std::isdigit(static_cast<unsigned char>(s[1])))
        {

            try
            {
                v = std::stoll(s.substr(1), nullptr, 8);
            }
            catch (...)
            {
                error("invalid octal in byte literal: " + s);
                return nullptr;
            }
        }
        else
        {
            try
            {
                v = std::stoll(s, nullptr, 10);
            }
            catch (...)
            {
                error("invalid decimal in byte literal: " + s);
                return nullptr;
            }
        }

        if (v < 0 || v > 255)
        {
            error("byte literal out of range (0..255): " + s);
            return nullptr;
        }

        vals.push_back(ConstantInt::get(Type::getInt8Ty(context), static_cast<uint64_t>(v), false));
    }

    ArrayType *arrTy = ArrayType::get(Type::getInt8Ty(context), vals.size());
    Constant *constArr = ConstantArray::get(arrTy, vals);

    std::string name = ".bytearr" + std::to_string(g_byte_array_counter++);
    GlobalVariable *gv = new GlobalVariable(
        *module,
        arrTy,
        true,
        GlobalValue::PrivateLinkage,
        constArr,
        name);
    gv->setUnnamedAddr(GlobalValue::UnnamedAddr::Global);
    gv->setAlignment(MaybeAlign(1));

    Constant *zero32 = ConstantInt::get(Type::getInt32Ty(context), 0);
    std::vector<Constant *> idxs = {zero32, zero32};
    Constant *gep = ConstantExpr::getInBoundsGetElementPtr(arrTy, gv, ArrayRef<Constant *>(idxs));

    return gep;
}

}
