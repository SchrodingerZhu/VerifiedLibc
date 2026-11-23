#include "DslEmitter.h"

#include "llvm/ADT/STLExtras.h"
#include "llvm/ADT/StringExtras.h"

using namespace llvm;

namespace extract {

static raw_ostream &operator<<(raw_ostream &OS, const Operand &Op) {
  Op.print(OS);
  return OS;
}

static raw_ostream &operator<<(raw_ostream &OS, const TypedOperand &Op) {
  return OS << Op.Type << " " << Op.Value;
}

static void printBits(raw_ostream &OS, const APInt &Bits) {
  OS << "0x" << toString(Bits, 16, /*Signed=*/false);
}

void Operand::print(raw_ostream &OS) const {
  if (IsRegister)
    OS << "%" << Number;
  else
    printBits(OS, Bits);
}

raw_ostream &DslEmitter::define(unsigned Result) {
  return OS << "    %" << Result << " = ";
}

raw_ostream &DslEmitter::define(unsigned Result, StringRef Opcode,
                                ArrayRef<StringRef> Flags) {
  define(Result) << Opcode << " ";
  for (StringRef Flag : Flags)
    OS << Flag << " ";
  return OS;
}

void DslEmitter::beginFunction(StringRef Name, ArrayRef<TypedOperand> Params) {
  OS << "llvm_func " << Name << "(";
  interleaveComma(Params, OS);
  OS << ") {\n";
}

void DslEmitter::endFunction() { OS << "}\n"; }

void DslEmitter::table(StringRef Name, StringRef ElementType,
                       ArrayRef<APInt> Elements) {
  OS << "  @" << Name << " : " << ElementType << " := [";
  for (size_t N = 0; N != Elements.size(); ++N) {
    OS << (N ? "," : "") << (N % 4 ? " " : "\n    ");
    printBits(OS, Elements[N]);
  }
  OS << "]\n";
}

void DslEmitter::beginBlock(unsigned Index) {
  OS << "  ^bb" << Index << ":\n";
}

void DslEmitter::operation(unsigned Result, StringRef Opcode,
                           ArrayRef<StringRef> Flags, ArrayRef<Operand> Args,
                           StringRef Type) {
  define(Result, Opcode, Flags);
  interleaveComma(Args, OS);
  OS << " : " << Type << "\n";
}

void DslEmitter::comparison(unsigned Result, StringRef Opcode,
                            ArrayRef<StringRef> Flags, StringRef Predicate,
                            const Operand &LHS, const Operand &RHS,
                            StringRef Type) {
  define(Result, Opcode, Flags)
      << Predicate << " " << LHS << ", " << RHS << " : " << Type << "\n";
}

void DslEmitter::cast(unsigned Result, StringRef Opcode,
                      ArrayRef<StringRef> Flags, const Operand &Arg,
                      StringRef From, StringRef To) {
  define(Result, Opcode, Flags)
      << Arg << " : " << From << " -> " << To << "\n";
}

void DslEmitter::phi(unsigned Result,
                     ArrayRef<std::pair<unsigned, Operand>> Incoming,
                     StringRef Type) {
  define(Result) << "phi ";
  interleaveComma(Incoming, OS, [&](const auto &Edge) {
    OS << "[^bb" << Edge.first << ": " << Edge.second << "]";
  });
  OS << " : " << Type << "\n";
}

void DslEmitter::load(unsigned Result, StringRef Table,
                      const TypedOperand &Index, StringRef Type) {
  define(Result) << "load @" << Table << "[" << Index << "] : " << Type << "\n";
}

void DslEmitter::call(unsigned Result, StringRef CoreOp,
                      ArrayRef<TypedOperand> Args) {
  define(Result) << "call " << CoreOp << "(";
  interleaveComma(Args, OS);
  OS << ")\n";
}

void DslEmitter::ret(const TypedOperand &Value) {
  OS << "    ret " << Value << "\n";
}

void DslEmitter::br(unsigned Target) { OS << "    br ^bb" << Target << "\n"; }

void DslEmitter::condBr(const Operand &Condition, unsigned IfTrue,
                        unsigned IfFalse) {
  OS << "    br " << Condition << ", ^bb" << IfTrue << ", ^bb" << IfFalse
     << "\n";
}

} // namespace extract
