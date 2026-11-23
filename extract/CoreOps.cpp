#include "CoreOps.h"

#include "llvm/Demangle/Demangle.h"
#include "llvm/IR/Function.h"

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
  std::string Demangled = demangle(F.getName());
  std::string Result;
  unsigned Depth = 0;
  for (char C : Demangled) {
    if (C == '(' && Depth == 0)
      break;
    if (C == '<')
      ++Depth;
    else if (C == '>')
      --Depth;
    else if (Depth == 0)
      Result.push_back(C);
  }
  StringRef Name = Result;
  // The return type precedes the name of a template specialization.
  size_t Space = Name.rfind(' ');
  if (Space != StringRef::npos)
    Name = Name.substr(Space + 1);
  if (Name.starts_with("__llvm_libc"))
    Name = Name.substr(Name.find("::") + 2);
  return Name.str();
}

std::optional<CoreOp> lookupCoreOp(const Function &F) {
  std::string Name = relativeName(F);
  for (const CoreOp &Op : CoreOps)
    if (Op.QualifiedName == Name)
      return Op;
  return std::nullopt;
}

} // namespace extract
