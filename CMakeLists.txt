cmake_minimum_required(VERSION 3.20)
project(ecc LANGUAGES CXX C)

set(CMAKE_CXX_STANDARD 20)
set(CMAKE_CXX_STANDARD_REQUIRED ON)

find_package(LLVM REQUIRED CONFIG PATHS /opt/homebrew/opt/llvm@18/lib/cmake/llvm NO_DEFAULT_PATH)

include_directories(${LLVM_INCLUDE_DIRS})
add_definitions(${LLVM_DEFINITIONS})

llvm_map_components_to_libnames(LLVM_LIBS
    core
    irreader
    executionengine
    native
    nativecodegen
    orcjit
    support
)

add_library(ecclib
    src/lexer/lexer.cpp
    src/parser/parser.cpp
    src/codegen/codegen.cpp
    src/ast/ast.cpp
    src/module/json.cpp
    src/module/resolver.cpp
)

target_link_libraries(ecclib ${LLVM_LIBS})

add_executable(ecc
    cli/ecc/ecc.cpp
)

target_link_libraries(ecc ecclib ${LLVM_LIBS})

add_executable(ecc_legacy
    src/main.cpp
)

target_link_libraries(ecc_legacy ecclib ${LLVM_LIBS})
