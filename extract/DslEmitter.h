//===-- Writer for the `llvm_func` notation -------------------------------===//
//
// Prints a function in the notation that `LibcMath/IR/DSL.lean` reads. This
// class knows the concrete syntax and nothing about LLVM IR beyond its
// constants; deciding what to print is the translator's job.
//
//===----------------------------------------------------------------------===//

#ifndef VERIFIED_LIBC_EXTRACT_DSL_EMITTER_H
#define VERIFIED_LIBC_EXTRACT_DSL_EMITTER_H

#include "llvm/ADT/APInt.h"
#include "llvm/ADT/ArrayRef.h"
#include "llvm/ADT/StringRef.h"
#include "llvm/Support/raw_ostream.h"
#include <string>

namespace extract {

/// A register, or a constant given by its bit pattern.
class Operand {
public:
  static Operand reg(unsigned Number) { return Operand(Number); }
  static Operand constant(llvm::APInt Bits) { return Operand(std::move(Bits)); }

  void print(llvm::raw_ostream &OS) const;

private:
  explicit Operand(unsigned Number) : IsRegister(true), Number(Number) {}
  explicit Operand(llvm::APInt Bits) : IsRegister(false), Bits(std::move(Bits)) {}

  bool IsRegister;
  unsigned Number = 0;
  llvm::APInt Bits;
};

/// An operand together with the name of its type.
struct TypedOperand {
  std::string Type;
  Operand Value;
};

class DslEmitter {
public:
  explicit DslEmitter(llvm::raw_ostream &OS) : OS(OS) {}

  void beginFunction(llvm::StringRef Name, llvm::ArrayRef<TypedOperand> Params);
  void endFunction();

  void table(llvm::StringRef Name, llvm::StringRef ElementType,
             llvm::ArrayRef<llvm::APInt> Elements);

  void beginBlock(unsigned Index);

  /// `%r = opcode flags a, b, … : type`
  void operation(unsigned Result, llvm::StringRef Opcode,
                 llvm::ArrayRef<llvm::StringRef> Flags,
                 llvm::ArrayRef<Operand> Args, llvm::StringRef Type);
  /// `%r = opcode flags predicate a, b : type`
  void comparison(unsigned Result, llvm::StringRef Opcode,
                  llvm::ArrayRef<llvm::StringRef> Flags,
                  llvm::StringRef Predicate, const Operand &LHS,
                  const Operand &RHS, llvm::StringRef Type);
  /// `%r = opcode flags a : from -> to`
  void cast(unsigned Result, llvm::StringRef Opcode,
            llvm::ArrayRef<llvm::StringRef> Flags, const Operand &Arg,
            llvm::StringRef From, llvm::StringRef To);
  /// `%r = phi [^bbN: a], … : type`
  void phi(unsigned Result,
           llvm::ArrayRef<std::pair<unsigned, Operand>> Incoming,
           llvm::StringRef Type);
  /// `%r = load @table[index] : type`
  void load(unsigned Result, llvm::StringRef Table, const TypedOperand &Index,
            llvm::StringRef Type);
  /// `%r = call op(args)`
  void call(unsigned Result, llvm::StringRef CoreOp,
            llvm::ArrayRef<TypedOperand> Args);

  void ret(const TypedOperand &Value);
  void br(unsigned Target);
  void condBr(const Operand &Condition, unsigned IfTrue, unsigned IfFalse);
  void unreachable();

private:
  llvm::raw_ostream &define(unsigned Result);
  /// `%r = opcode flags `
  llvm::raw_ostream &define(unsigned Result, llvm::StringRef Opcode,
                            llvm::ArrayRef<llvm::StringRef> Flags);

  llvm::raw_ostream &OS;
};

} // namespace extract

#endif
