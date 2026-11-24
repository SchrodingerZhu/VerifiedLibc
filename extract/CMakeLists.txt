cmake_minimum_required(VERSION 3.28)
project(LibcMathAstExtract LANGUAGES C CXX)

set(CMAKE_CXX_STANDARD 23)
set(CMAKE_CXX_STANDARD_REQUIRED ON)
set(CMAKE_CXX_EXTENSIONS OFF)
set(CMAKE_CXX_SCAN_FOR_MODULES ON)

find_package(LLVM REQUIRED CONFIG)
find_package(Clang REQUIRED CONFIG)

message(STATUS "Found LLVM ${LLVM_PACKAGE_VERSION} (${LLVM_CMAKE_DIR})")
message(STATUS "Found Clang (${Clang_CMAKE_DIR})")

execute_process(
  COMMAND "${CMAKE_CXX_COMPILER}" -print-resource-dir
  OUTPUT_VARIABLE DETECTED_CLANG_RESOURCE_DIR
  OUTPUT_STRIP_TRAILING_WHITESPACE
  ERROR_QUIET
)
if(NOT DETECTED_CLANG_RESOURCE_DIR)
  set(DETECTED_CLANG_RESOURCE_DIR "${LLVM_LIBRARY_DIR}/clang/${LLVM_VERSION_MAJOR}")
endif()

add_library(libc_extract_core STATIC)
target_sources(libc_extract_core
  PUBLIC
    FILE_SET CXX_MODULES FILES
      src/core_ops.cppm
      src/ir.cppm
      src/clang_parse.cppm
      src/lift.cppm
      src/emit_lean.cppm
      src/extract.cppm
      src/cli.cppm
)

target_include_directories(libc_extract_core SYSTEM PRIVATE
  ${LLVM_INCLUDE_DIRS}
  ${CLANG_INCLUDE_DIRS}
)
target_compile_definitions(libc_extract_core PRIVATE
  ${LLVM_DEFINITIONS}
  AST2LEAN_DEFAULT_RESOURCE_DIR="${DETECTED_CLANG_RESOURCE_DIR}"
  AST2LEAN_CLANG_VERSION="${LLVM_PACKAGE_VERSION}"
)

if(NOT LLVM_ENABLE_RTTI)
  target_compile_options(libc_extract_core PRIVATE -fno-rtti)
endif()

target_compile_options(libc_extract_core PRIVATE -Wall -Wextra -Wno-unused-parameter)

if(TARGET clang-cpp)
  target_link_libraries(libc_extract_core PRIVATE clang-cpp)
else()
  target_link_libraries(libc_extract_core PRIVATE
    clangTooling
    clangFrontend
    clangSerialization
    clangDriver
    clangParse
    clangSema
    clangAnalysis
    clangAST
    clangBasic
    clangLex
  )
endif()

if(TARGET LLVM)
  target_link_libraries(libc_extract_core PRIVATE LLVM)
else()
  llvm_map_components_to_libnames(LLVM_LIBS core support option targetparser)
  target_link_libraries(libc_extract_core PRIVATE ${LLVM_LIBS})
endif()

add_executable(ast2lean src/main.cpp)
target_link_libraries(ast2lean PRIVATE libc_extract_core)
target_compile_options(ast2lean PRIVATE -Wall -Wextra)
