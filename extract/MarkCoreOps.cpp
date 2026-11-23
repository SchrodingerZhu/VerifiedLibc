//===-- Keep core operations out of line ----------------------------------===//
//
// A pass plugin for clang. Before any optimization runs, it marks every core
// operation `noinline`, so that the optimized IR of a math function still
// calls them. It changes no code.
//
//===----------------------------------------------------------------------===//

#include "CoreOps.h"

#include "llvm/IR/Module.h"
#include "llvm/IR/PassManager.h"
#include "llvm/Passes/PassBuilder.h"
#include "llvm/Plugins/PassPlugin.h"

using namespace llvm;

namespace {

struct MarkCoreOps : PassInfoMixin<MarkCoreOps> {
  PreservedAnalyses run(Module &M, ModuleAnalysisManager &) {
    for (Function &F : M) {
      if (F.isDeclaration() || !extract::lookupCoreOp(F))
        continue;
      F.removeFnAttr(Attribute::AlwaysInline);
      F.addFnAttr(Attribute::NoInline);
    }
    return PreservedAnalyses::all();
  }
};

} // namespace

extern "C" LLVM_ATTRIBUTE_WEAK PassPluginLibraryInfo llvmGetPassPluginInfo() {
  return {LLVM_PLUGIN_API_VERSION, "MarkCoreOps", LLVM_VERSION_STRING,
          [](PassBuilder &PB) {
            PB.registerPipelineStartEPCallback(
                [](ModulePassManager &MPM, OptimizationLevel) {
                  MPM.addPass(MarkCoreOps());
                });
          }};
}
