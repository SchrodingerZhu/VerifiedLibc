cmake_minimum_required(VERSION 3.20)
project(VerifiedLibcExtract CXX)

find_package(LLVM REQUIRED CONFIG)
list(APPEND CMAKE_MODULE_PATH "${LLVM_CMAKE_DIR}")
include(AddLLVM)

set(CMAKE_CXX_STANDARD 17)
set(CMAKE_CXX_STANDARD_REQUIRED ON)
include_directories(SYSTEM ${LLVM_INCLUDE_DIRS})
add_definitions(${LLVM_DEFINITIONS})
if(NOT LLVM_ENABLE_RTTI)
  add_compile_options(-fno-rtti)
endif()

add_library(MarkCoreOps MODULE MarkCoreOps.cpp CoreOps.cpp)
set_target_properties(MarkCoreOps PROPERTIES PREFIX "")

add_executable(ir2lean IRToLean.cpp FunctionTranslator.cpp DslEmitter.cpp CoreOps.cpp)
llvm_map_components_to_libnames(IR2LEAN_LIBS core irreader support demangle passes transformutils)
target_link_libraries(ir2lean PRIVATE ${IR2LEAN_LIBS})
