cmake_minimum_required(VERSION 3.20)
project(ycc LANGUAGES CXX C)

set(CMAKE_CXX_STANDARD 20)
set(CMAKE_CXX_STANDARD_REQUIRED ON)

set(YCPL_LLVM_MIN_VERSION 22 CACHE STRING "Minimum LLVM major version")

if(NOT LLVM_DIR AND DEFINED ENV{LLVM_DIR})
    set(LLVM_DIR "$ENV{LLVM_DIR}" CACHE PATH "Path to LLVMConfig.cmake directory")
endif()

if(NOT LLVM_DIR)
    if(DEFINED ENV{LLVM_CONFIG})
        set(YCPL_LLVM_CONFIG "$ENV{LLVM_CONFIG}")
    else()
        set(YCPL_LLVM_CONFIG_CANDIDATES
            "$ENV{LLVM_BINDIR}/llvm-config"
            "/opt/homebrew/opt/llvm@${YCPL_LLVM_MIN_VERSION}/bin/llvm-config"
            "/opt/homebrew/opt/llvm/bin/llvm-config"
            "/usr/local/opt/llvm@${YCPL_LLVM_MIN_VERSION}/bin/llvm-config"
            "/usr/local/opt/llvm/bin/llvm-config"
            "/usr/lib/llvm-${YCPL_LLVM_MIN_VERSION}/bin/llvm-config"
        )
        foreach(candidate IN LISTS YCPL_LLVM_CONFIG_CANDIDATES)
            if(candidate AND EXISTS "${candidate}")
                set(YCPL_LLVM_CONFIG "${candidate}")
                break()
            endif()
        endforeach()
        if(NOT YCPL_LLVM_CONFIG)
            find_program(YCPL_LLVM_CONFIG
                NAMES
                    llvm-config-${YCPL_LLVM_MIN_VERSION}
                    llvm-config${YCPL_LLVM_MIN_VERSION}
                    llvm-config
            )
        endif()
    endif()

    if(YCPL_LLVM_CONFIG)
        execute_process(
            COMMAND "${YCPL_LLVM_CONFIG}" --cmakedir
            OUTPUT_VARIABLE YCPL_LLVM_CMAKE_DIR
            OUTPUT_STRIP_TRAILING_WHITESPACE
            ERROR_QUIET
        )
        if(EXISTS "${YCPL_LLVM_CMAKE_DIR}/LLVMConfig.cmake")
            set(LLVM_DIR "${YCPL_LLVM_CMAKE_DIR}" CACHE PATH "Path to LLVMConfig.cmake directory" FORCE)
        endif()
    endif()
endif()

find_package(LLVM CONFIG QUIET)
if(NOT LLVM_FOUND)
    message(FATAL_ERROR
        "Could not find LLVM ${YCPL_LLVM_MIN_VERSION}+.\n"
        "Set one of:\n"
        "  LLVM_CONFIG=/absolute/path/to/llvm-config\n"
        "  LLVM_DIR=/absolute/path/to/lib/cmake/llvm\n"
        "  LLVM_BINDIR=/absolute/path/to/llvm/bin\n"
        "Common paths checked include:\n"
        "  /opt/homebrew/opt/llvm@${YCPL_LLVM_MIN_VERSION}\n"
        "  /opt/homebrew/opt/llvm\n"
        "  /usr/local/opt/llvm@${YCPL_LLVM_MIN_VERSION}\n"
        "  /usr/lib/llvm-${YCPL_LLVM_MIN_VERSION}\n"
    )
endif()
if(LLVM_PACKAGE_VERSION VERSION_LESS "${YCPL_LLVM_MIN_VERSION}.0")
    message(FATAL_ERROR "YCPL requires LLVM ${YCPL_LLVM_MIN_VERSION} or newer; found ${LLVM_PACKAGE_VERSION}")
endif()

include_directories(${CMAKE_CURRENT_SOURCE_DIR})
include_directories(${CMAKE_CURRENT_SOURCE_DIR}/bootstrap/cpp)

message(STATUS "Found LLVM ${LLVM_PACKAGE_VERSION}: ${LLVM_DIR}")
message(STATUS "LLVM include dirs: ${LLVM_INCLUDE_DIRS}")
message(STATUS "LLVM library dirs: ${LLVM_LIBRARY_DIRS}")

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
    bootstrap/cpp/src/lexer/lexer.cpp
    bootstrap/cpp/src/parser/parser.cpp
    bootstrap/cpp/src/codegen/codegen.cpp
    bootstrap/cpp/src/codegen/core.cpp
    bootstrap/cpp/src/codegen/dispatch.cpp
    bootstrap/cpp/src/codegen/pipeline.cpp
    bootstrap/cpp/src/codegen/scope.cpp
    bootstrap/cpp/src/ast/ast.cpp
    bootstrap/cpp/src/module/json.cpp
    bootstrap/cpp/src/module/resolver.cpp
)

target_include_directories(ycclib SYSTEM PUBLIC ${LLVM_INCLUDE_DIRS})
separate_arguments(YCPL_LLVM_DEFINITIONS NATIVE_COMMAND "${LLVM_DEFINITIONS}")
target_compile_options(ycclib PUBLIC ${YCPL_LLVM_DEFINITIONS})
target_link_libraries(ycclib PUBLIC ${LLVM_LIBS})

if(LLVM_LIBRARY_DIRS)
    set(CMAKE_BUILD_RPATH ${LLVM_LIBRARY_DIRS})
    set(CMAKE_INSTALL_RPATH ${LLVM_LIBRARY_DIRS})
endif()

add_executable(ycc
    bootstrap/cpp/src/cli/driver.cpp
    bootstrap/cpp/src/cli/ycc.cpp
)

target_link_libraries(ycc PRIVATE ycclib)
if(LLVM_LIBRARY_DIRS)
    set_target_properties(ycc PROPERTIES BUILD_RPATH "${LLVM_LIBRARY_DIRS}")
endif()

add_executable(ycc_legacy
    bootstrap/cpp/src/main.cpp
)

target_link_libraries(ycc_legacy PRIVATE ycclib)
if(LLVM_LIBRARY_DIRS)
    set_target_properties(ycc_legacy PROPERTIES BUILD_RPATH "${LLVM_LIBRARY_DIRS}")
endif()
