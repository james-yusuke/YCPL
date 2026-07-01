cmake_minimum_required(VERSION 3.20)
project(ycc LANGUAGES CXX C)

set(CMAKE_CXX_STANDARD 20)
set(CMAKE_CXX_STANDARD_REQUIRED ON)

set(YCPL_LLVM_MIN_VERSION 22 CACHE STRING "Minimum LLVM major version")
find_package(LLVM REQUIRED CONFIG)
if(LLVM_PACKAGE_VERSION VERSION_LESS "${YCPL_LLVM_MIN_VERSION}.0")
    message(FATAL_ERROR "YCPL requires LLVM ${YCPL_LLVM_MIN_VERSION} or newer; found ${LLVM_PACKAGE_VERSION}")
endif()

include_directories(${LLVM_INCLUDE_DIRS})
add_definitions(${LLVM_DEFINITIONS})
include_directories(${CMAKE_CURRENT_SOURCE_DIR})

message(STATUS "Found LLVM ${LLVM_PACKAGE_VERSION}: ${LLVM_DIR}")

llvm_map_components_to_libnames(LLVM_LIBS
    core
    irreader
    executionengine
    native
    nativecodegen
    orcjit
    support
)

add_library(ycclib
    src/lexer/lexer.cpp
    src/parser/parser.cpp
    src/codegen/codegen.cpp
    src/ast/ast.cpp
    src/module/json.cpp
    src/module/resolver.cpp
)

target_link_libraries(ycclib ${LLVM_LIBS})

add_executable(ycc
    tools/cli/ycc/ycc.cpp
)

target_link_libraries(ycc ycclib ${LLVM_LIBS})

add_executable(ycc_legacy
    src/main.cpp
)

target_link_libraries(ycc_legacy ycclib ${LLVM_LIBS})
