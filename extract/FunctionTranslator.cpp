#include "FunctionTranslator.h"

#include "CoreOps.h"
#include "DslEmitter.h"

#include "llvm/ADT/DenseMap.h"
#include "llvm/ADT/StringExtras.h"
#include "llvm/IR/Constants.h"
#include "llvm/IR/DataLayout.h"
#include "llvm/IR/Instructions.h"
#include "llvm/IR/IntrinsicInst.h"
#include "llvm/IR/Module.h"
#include "llvm/Support/raw_ostream.h"

using namespace llvm;

namespace extract {

namespace {

[[noreturn]] void unsupported(const Twine &What, const Value &V) {
  errs() << "ir2lean: unsupported " << What << ": " << V << "\n";
  exit(1);
}

class Translator {
public:
  Translator(const Function &F, DslEmitter &Emitter)
      : F(F), DL(F.getParent()->getDataLayout()), Emitter(Emitter) {}

  void run(StringRef Name);

private:
  void numberValues();
  void collectTables();
  void translate(const Instruction &I);
  void translateBinary(const BinaryOperator &I);
  void translateCast(const CastInst &I);
  void translateLoad(const LoadInst &I);
  void translateCall(const CallInst &I);
  void translateTerminator(const Instruction &I);

  std::string type(const Type *Ty, const Value &Context) const;
  Operand operand(const Value *V) const;
  TypedOperand typedOperand(const Value *V) const {
    return {type(V->getType(), *V), operand(V)};
  }
  unsigned reg(const Value &V) const { return Registers.lookup(&V); }

  /// The constant table a load reads and the index it reads at. The address
  /// must be that of a whole element of the type being read.
  std::pair<const GlobalVariable *, const Value *>
  tableAccess(const LoadInst &Load) const;

  /// A GEP is translated together with the loads that read through it.
  static bool isTableAddress(const Instruction &I) {
    return isa<GetElementPtrInst>(I) &&
           all_of(I.users(), [](const User *U) { return isa<LoadInst>(U); });
  }

  const Function &F;
  const DataLayout &DL;
  DslEmitter &Emitter;
  DenseMap<const Value *, unsigned> Registers;
  DenseMap<const BasicBlock *, unsigned> Blocks;
};

std::string Translator::type(const Type *Ty, const Value &Context) const {
  if (Ty->isIntegerTy())
    return "i" + utostr(Ty->getIntegerBitWidth());
  if (Ty->isFloatTy())
    return "float";
  if (Ty->isDoubleTy())
    return "double";
  unsupported("type", Context);
}

Operand Translator::operand(const Value *V) const {
  if (auto It = Registers.find(V); It != Registers.end())
    return Operand::reg(It->second);
  if (const auto *CI = dyn_cast<ConstantInt>(V))
    return Operand::constant(CI->getValue());
  if (const auto *CF = dyn_cast<ConstantFP>(V))
    return Operand::constant(CF->getValueAPF().bitcastToAPInt());
  unsupported("operand", *V);
}

std::pair<const GlobalVariable *, const Value *>
Translator::tableAccess(const LoadInst &Load) const {
  const auto *GEP = dyn_cast<GetElementPtrInst>(Load.getPointerOperand());
  if (Load.isVolatile() || !GEP || GEP->getNumIndices() != 1)
    unsupported("memory access", Load);
  const auto *GV = dyn_cast<GlobalVariable>(GEP->getPointerOperand());
  if (!GV || !GV->isConstant() || !GV->hasDefinitiveInitializer())
    unsupported("memory access", Load);
  const auto *Data = dyn_cast<ConstantDataArray>(GV->getInitializer());
  if (!Data || Data->getElementType() != Load.getType() ||
      DL.getTypeAllocSize(GEP->getSourceElementType()) !=
          DL.getTypeAllocSize(Data->getElementType()))
    unsupported("memory access", Load);
  return {GV, GEP->getOperand(1)};
}

void Translator::numberValues() {
  unsigned Next = 0;
  for (const Argument &Arg : F.args())
    Registers[&Arg] = Next++;
  for (const BasicBlock &BB : F) {
    Blocks[&BB] = Blocks.size();
    for (const Instruction &I : BB)
      if (!I.isTerminator() && !isTableAddress(I))
        Registers[&I] = Next++;
  }
}

void Translator::collectTables() {
  SmallVector<const GlobalVariable *> Seen;
  for (const BasicBlock &BB : F)
    for (const Instruction &I : BB) {
      const auto *Load = dyn_cast<LoadInst>(&I);
      if (!Load)
        continue;
      const GlobalVariable *GV = tableAccess(*Load).first;
      if (is_contained(Seen, GV))
        continue;
      Seen.push_back(GV);
      const auto *Data = cast<ConstantDataArray>(GV->getInitializer());
      SmallVector<APInt> Elements;
      for (unsigned N = 0; N != Data->getNumElements(); ++N) {
        const Constant *Element = Data->getElementAsConstant(N);
        Elements.push_back(
            isa<ConstantFP>(Element)
                ? cast<ConstantFP>(Element)->getValueAPF().bitcastToAPInt()
                : cast<ConstantInt>(Element)->getValue());
      }
      Emitter.table(GV->getName(), type(Data->getElementType(), *GV), Elements);
    }
}

void Translator::translateBinary(const BinaryOperator &I) {
  StringRef Opcode;
  switch (I.getOpcode()) {
  case Instruction::Add:
  case Instruction::Sub:
  case Instruction::Mul:
  case Instruction::And:
  case Instruction::Or:
  case Instruction::Xor:
  case Instruction::Shl:
  case Instruction::LShr:
  case Instruction::AShr:
  case Instruction::FAdd:
  case Instruction::FSub:
  case Instruction::FMul:
    Opcode = I.getOpcodeName();
    break;
  default:
    unsupported("instruction", I);
  }
  Emitter.operation(reg(I), Opcode, {operand(I.getOperand(0)), operand(I.getOperand(1))},
                    type(I.getType(), I));
}

void Translator::translateCast(const CastInst &I) {
  switch (I.getOpcode()) {
  case Instruction::ZExt:
  case Instruction::SExt:
  case Instruction::Trunc:
  case Instruction::BitCast:
  case Instruction::FPExt:
  case Instruction::FPTrunc:
  case Instruction::FPToSI:
    break;
  default:
    unsupported("cast", I);
  }
  Emitter.cast(reg(I), I.getOpcodeName(), operand(I.getOperand(0)),
               type(I.getSrcTy(), I), type(I.getDestTy(), I));
}

void Translator::translateLoad(const LoadInst &I) {
  auto [GV, Index] = tableAccess(I);
  Emitter.load(reg(I), GV->getName(), typedOperand(Index), type(I.getType(), I));
}

void Translator::translateCall(const CallInst &I) {
  if (const auto *II = dyn_cast<IntrinsicInst>(&I)) {
    StringRef Opcode;
    switch (II->getIntrinsicID()) {
    case Intrinsic::fabs:
      Opcode = "fabs";
      break;
    case Intrinsic::fmuladd:
      Opcode = "fmuladd";
      break;
    default:
      unsupported("intrinsic", I);
    }
    SmallVector<Operand> Args;
    for (const Use &Arg : II->args())
      Args.push_back(operand(Arg));
    Emitter.operation(reg(I), Opcode, Args, type(I.getType(), I));
    return;
  }

  const Function *Callee = I.getCalledFunction();
  auto Core = Callee ? lookupCoreOp(*Callee) : std::nullopt;
  if (!Core)
    unsupported("call", I);
  SmallVector<TypedOperand> Args;
  for (const Use &Arg : I.args())
    Args.push_back(typedOperand(Arg));
  Emitter.call(reg(I), Core->LeanName, Args);
}

void Translator::translate(const Instruction &I) {
  if (const auto *Phi = dyn_cast<PHINode>(&I)) {
    SmallVector<std::pair<unsigned, Operand>> Incoming;
    for (unsigned N = 0; N != Phi->getNumIncomingValues(); ++N)
      Incoming.emplace_back(Blocks.lookup(Phi->getIncomingBlock(N)),
                            operand(Phi->getIncomingValue(N)));
    Emitter.phi(reg(I), Incoming, type(I.getType(), I));
  } else if (const auto *Binary = dyn_cast<BinaryOperator>(&I)) {
    translateBinary(*Binary);
  } else if (const auto *Cmp = dyn_cast<CmpInst>(&I)) {
    Emitter.comparison(reg(I), I.getOpcodeName(),
                       CmpInst::getPredicateName(Cmp->getPredicate()),
                       operand(I.getOperand(0)), operand(I.getOperand(1)),
                       type(I.getOperand(0)->getType(), I));
  } else if (const auto *Cast = dyn_cast<CastInst>(&I)) {
    translateCast(*Cast);
  } else if (isa<SelectInst>(I)) {
    Emitter.operation(reg(I), "select",
                      {operand(I.getOperand(0)), operand(I.getOperand(1)),
                       operand(I.getOperand(2))},
                      type(I.getType(), I));
  } else if (I.getOpcode() == Instruction::FNeg) {
    Emitter.operation(reg(I), "fneg", {operand(I.getOperand(0))},
                      type(I.getType(), I));
  } else if (const auto *Load = dyn_cast<LoadInst>(&I)) {
    translateLoad(*Load);
  } else if (const auto *Call = dyn_cast<CallInst>(&I)) {
    translateCall(*Call);
  } else {
    unsupported("instruction", I);
  }
}

void Translator::translateTerminator(const Instruction &I) {
  if (const auto *Ret = dyn_cast<ReturnInst>(&I); Ret && Ret->getReturnValue())
    Emitter.ret(typedOperand(Ret->getReturnValue()));
  else if (const auto *Br = dyn_cast<UncondBrInst>(&I))
    Emitter.br(Blocks.lookup(Br->getSuccessor()));
  else if (const auto *Br = dyn_cast<CondBrInst>(&I))
    Emitter.condBr(operand(Br->getCondition()),
                   Blocks.lookup(Br->getSuccessor(0)),
                   Blocks.lookup(Br->getSuccessor(1)));
  else
    unsupported("terminator", I);
}

void Translator::run(StringRef Name) {
  numberValues();

  SmallVector<TypedOperand> Params;
  for (const Argument &Arg : F.args())
    Params.push_back(typedOperand(&Arg));
  Emitter.beginFunction(Name, Params);
  collectTables();
  for (const BasicBlock &BB : F) {
    Emitter.beginBlock(Blocks.lookup(&BB));
    for (const Instruction &I : BB) {
      if (I.isTerminator())
        translateTerminator(I);
      else if (!isTableAddress(I))
        translate(I);
    }
  }
  Emitter.endFunction();
}

} // namespace

void translateFunction(const Function &F, StringRef Name, DslEmitter &Emitter) {
  Translator(F, Emitter).run(Name);
}

} // namespace extract
