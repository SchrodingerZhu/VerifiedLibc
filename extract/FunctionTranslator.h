//===-- Translation of an IR function to the supported fragment -----------===//
//
// Walks one LLVM function and describes it to a `DslEmitter`. Every
// instruction, type and constant must have a counterpart in `LibcMath.IR`;
// anything else stops the tool with an error naming the offending value.
//
//===----------------------------------------------------------------------===//

#ifndef VERIFIED_LIBC_EXTRACT_FUNCTION_TRANSLATOR_H
#define VERIFIED_LIBC_EXTRACT_FUNCTION_TRANSLATOR_H

#include "llvm/ADT/StringRef.h"

namespace llvm {
class Function;
}

namespace extract {

class DslEmitter;

void translateFunction(const llvm::Function &F, llvm::StringRef Name,
                       DslEmitter &Emitter);

} // namespace extract

#endif
