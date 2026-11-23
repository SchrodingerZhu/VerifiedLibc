#include "CoreOps.h"

#include "llvm/Demangle/Demangle.h"
#include "llvm/IR/Function.h"
#include <cstdlib>

using namespace llvm;

namespace extract {

static const CoreOp CoreOps[] = {
    // Queries of the dynamic rounding mode. libc implements them by probing
    // with volatile floating-point arithmetic.
    {"fputil::generic::quick_get_round", "quickGetRound"},
    {"fputil::generic::fenv_is_round_up", "isRoundUp"},
    {"fputil::generic::fenv_is_round_down", "isRoundDown"},
    {"fputil::generic::fenv_is_round_to_nearest", "isRoundToNearest"},
    {"fputil::generic::fenv_is_round_to_zero", "isRoundToZero"},
    // Reporting through errno and the floating-point status flags. These do
    // not influence the value a math function returns.
    {"fputil::set_errno_if_required", "setErrno"},
    {"fputil::raise_except_if_required", "raiseExcept"},
    {"fputil::raise_overflow_except_if_required", "raiseExcept"},
    {"fputil::raise_underflow_except_if_required", "raiseExcept"},
};

std::string relativeName(const Function &F) {
  ItaniumPartialDemangler Demangler;
  std::string Mangled = F.getName().str();
  if (Demangler.partialDemangle(Mangled.c_str()) || !Demangler.isFunction())
    return Mangled;

  auto Take = [](char *Buffer) {
    std::string Result = Buffer ? Buffer : "";
    std::free(Buffer);
    return Result;
  };
  std::string Scope =
      Take(Demangler.getFunctionDeclContextName(nullptr, nullptr));
  std::string Base = Take(Demangler.getFunctionBaseName(nullptr, nullptr));
  std::string Name = Scope.empty() ? Base : Scope + "::" + Base;

  StringRef Relative = Name;
  if (Relative.consume_front("__llvm_libc"))
    Relative = Relative.substr(Relative.find("::") + 2);
  return Relative.str();
}

std::optional<CoreOp> lookupCoreOp(const Function &F) {
  std::string Name = relativeName(F);
  for (const CoreOp &Op : CoreOps)
    if (Op.QualifiedName == Name)
      return Op;
  return std::nullopt;
}

} // namespace extract
