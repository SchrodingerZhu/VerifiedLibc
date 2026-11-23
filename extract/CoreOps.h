//===-- Core operations of LLVM libc math ---------------------------------===//
//
// Functions that extraction keeps as calls instead of letting the optimizer
// inline them. Each has a specification on the Lean side; the extracted code
// of a math function is then a program over ordinary IR instructions and
// these operations.
//
//===----------------------------------------------------------------------===//

#ifndef VERIFIED_LIBC_EXTRACT_CORE_OPS_H
#define VERIFIED_LIBC_EXTRACT_CORE_OPS_H

#include "llvm/ADT/StringRef.h"
#include <optional>
#include <string>

namespace llvm {
class Function;
}

namespace extract {

struct CoreOp {
  /// Name relative to the libc namespace, without template arguments.
  llvm::StringRef QualifiedName;
  /// Constructor of `LibcMath.IR.CoreOp` on the Lean side.
  llvm::StringRef LeanName;
};

/// The name of a function relative to the libc namespace, without its
/// parameter list and template arguments: `__llvm_libc::fputil::f<float>(int)`
/// becomes `fputil::f`. An enclosing class or function is printed in full, so
/// a member of a class template or a lambda has a name different from that of
/// any function at namespace scope. A name that is not mangled is returned
/// unchanged.
std::string relativeName(const llvm::Function &F);

/// The core operation a function implements, if any.
std::optional<CoreOp> lookupCoreOp(const llvm::Function &F);

} // namespace extract

#endif
