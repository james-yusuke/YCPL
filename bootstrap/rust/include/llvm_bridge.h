#pragma once
#include "rust/cxx.h"
#include <cstdint>
#include <memory>
namespace ycpl::rust_seed
{
class Session
{
    struct Impl;
    std::unique_ptr<Impl> p;

  public:
    explicit Session(rust::Str name);
    ~Session();
    std::uint64_t type_create(std::uint8_t, std::uint64_t, rust::Slice<const std::uint64_t>,
                              rust::Str);
    void type_body(std::uint64_t, rust::Slice<const std::uint64_t>);
    std::uint64_t type_size(std::uint64_t) const;
    std::uint64_t constant(std::uint8_t, std::uint64_t, std::uint64_t, double, rust::Str);
    std::uint64_t function(rust::Str, std::uint64_t);
    std::uint64_t parameter(std::uint64_t, std::uint32_t);
    std::uint64_t block(std::uint64_t, rust::Str);
    void position(std::uint64_t);
    bool terminated() const;
    std::uint64_t instruction(rust::Str, std::uint64_t, rust::Slice<const std::uint64_t>, rust::Str,
                              std::uint64_t);
    void verify() const;
    rust::String ir() const;
};
std::unique_ptr<Session> new_session(rust::Str name);
} // namespace ycpl::rust_seed
