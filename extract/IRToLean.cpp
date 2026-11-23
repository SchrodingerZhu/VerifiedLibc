//===-- Export a function from LLVM IR to Lean ----------------------------===//
//
// Writes one function of an IR module as a value of `LibcMath.IR.Func`. The
// function must lie in the supported fragment: loop structure is not checked
// here, but every instruction, type and constant must have a counterpart on
// the Lean side, and anything else is an error.
//
//===----------------------------------------------------------------------===//

#include "CoreOps.h"

#include "llvm/ADT/DenseMap.h"
#include "llvm/ADT/StringExtras.h"
#include "llvm/IR/Constants.h"
#include "llvm/IR/DataLayout.h"
#include "llvm/IR/Instructions.h"
#include "llvm/IR/IntrinsicInst.h"
#include "llvm/IR/LLVMContext.h"
#include "llvm/IR/Module.h"
#include "llvm/IRReader/IRReader.h"
#include "llvm/Support/CommandLine.h"
#include "llvm/Support/SourceMgr.h"
#include "llvm/Support/raw_ostream.h"

using namespace llvm;

static cl::opt<std::string> InputFile(cl::Positional, cl::desc("<IR file>"),
                                      cl::Required);
static cl::opt<std::string>
    FunctionName("function", cl::Required,
                 cl::desc("Function to export, by its name relative to the "
                          "libc namespace, e.g. math::double_eval::expf"));
static cl::opt<std::string> LeanName("name", cl::Required,
                                     cl::desc("Name of the Lean definition"));

static cl::opt<std::string>
    Origin("origin", cl::desc("Description of the source, for the header"));

namespace {

[[noreturn]] void unsupported(const Twine &What, const Value &V) {
  errs() << "ir2lean: unsupported " << What << ": " << V << "\n";
  exit(1);
}

class Exporter {
public:
  Exporter(const Function &F, raw_ostream &OS)
      : F(F), DL(F.getParent()->getDataLayout()), OS(OS) {}

  void run();

private:
  unsigned width(const Type *Ty, const Value &Context) const;
  StringRef format(const Type *Ty, const Value &Context) const;
  std::string operand(const Value *V);
  unsigned table(const GlobalVariable &GV, const Value &Context);
  std::string instruction(const Instruction &I);
  std::string terminator(const Instruction &I);

  /// A GEP is exported together with the load that reads through it.
  static bool isTableAddress(const Instruction &I) {
    return isa<GetElementPtrInst>(I) &&
           all_of(I.users(), [](const User *U) { return isa<LoadInst>(U); });
  }

  const Function &F;
  const DataLayout &DL;
  raw_ostream &OS;
  DenseMap<const Value *, unsigned> Registers;
  DenseMap<const BasicBlock *, unsigned> Blocks;
  std::vector<const GlobalVariable *> Tables;
};

unsigned Exporter::width(const Type *Ty, const Value &Context) const {
  if (Ty->isIntegerTy())
    return Ty->getIntegerBitWidth();
  if (Ty->isFloatTy())
    return 32;
  if (Ty->isDoubleTy())
    return 64;
  if (Ty->isVoidTy())
    return 0;
  unsupported("type", Context);
}

StringRef Exporter::format(const Type *Ty, const Value &Context) const {
  if (Ty->isFloatTy())
    return ".binary32";
  if (Ty->isDoubleTy())
    return ".binary64";
  unsupported("floating-point type", Context);
}

std::string Exporter::operand(const Value *V) {
  if (auto It = Registers.find(V); It != Registers.end())
    return "(.reg " + utostr(It->second) + ")";
  APInt Bits;
  if (const auto *CI = dyn_cast<ConstantInt>(V))
    Bits = CI->getValue();
  else if (const auto *CF = dyn_cast<ConstantFP>(V))
    Bits = CF->getValueAPF().bitcastToAPInt();
  else
    unsupported("operand", *V);
  return "(.const " + utostr(Bits.getBitWidth()) + " 0x" +
         toString(Bits, 16, /*Signed=*/false) + ")";
}

unsigned Exporter::table(const GlobalVariable &GV, const Value &Context) {
  if (!GV.isConstant() || !GV.hasDefinitiveInitializer() ||
      !isa<ConstantDataArray>(GV.getInitializer()))
    unsupported("memory access", Context);
  auto It = find(Tables, &GV);
  if (It == Tables.end())
    It = Tables.insert(Tables.end(), &GV);
  return It - Tables.begin();
}

std::string Exporter::instruction(const Instruction &I) {
  auto Op = [&](unsigned N) { return operand(I.getOperand(N)); };
  auto Join = [](std::initializer_list<std::string> Parts) {
    return join(Parts, " ");
  };

  if (const auto *BO = dyn_cast<BinaryOperator>(&I)) {
    StringRef Name;
    switch (BO->getOpcode()) {
    case Instruction::Add:  Name = ".intBin .add"; break;
    case Instruction::Sub:  Name = ".intBin .sub"; break;
    case Instruction::Mul:  Name = ".intBin .mul"; break;
    case Instruction::And:  Name = ".intBin .and"; break;
    case Instruction::Or:   Name = ".intBin .or"; break;
    case Instruction::Xor:  Name = ".intBin .xor"; break;
    case Instruction::Shl:  Name = ".intBin .shl"; break;
    case Instruction::LShr: Name = ".intBin .lshr"; break;
    case Instruction::AShr: Name = ".intBin .ashr"; break;
    case Instruction::FAdd: Name = ".fadd"; break;
    case Instruction::FSub: Name = ".fsub"; break;
    case Instruction::FMul: Name = ".fmul"; break;
    default: unsupported("instruction", I);
    }
    if (I.getType()->isFloatingPointTy())
      return Join({".fBin", format(I.getType(), I).str(), Name.str(), Op(0), Op(1)});
    return Join({Name.str(), Op(0), Op(1)});
  }

  if (const auto *Cmp = dyn_cast<ICmpInst>(&I))
    return Join({".icmp",
                 "." + ICmpInst::getPredicateName(Cmp->getPredicate()).str(),
                 Op(0), Op(1)});
  if (const auto *Cmp = dyn_cast<FCmpInst>(&I))
    return Join({".fcmp", format(Cmp->getOperand(0)->getType(), I).str(),
                 "." + FCmpInst::getPredicateName(Cmp->getPredicate()).str(),
                 Op(0), Op(1)});

  if (const auto *Cast = dyn_cast<CastInst>(&I)) {
    std::string Width = utostr(width(I.getType(), I));
    switch (Cast->getOpcode()) {
    case Instruction::ZExt:  return Join({".zext", Width, Op(0)});
    case Instruction::SExt:  return Join({".sext", Width, Op(0)});
    case Instruction::Trunc: return Join({".trunc", Width, Op(0)});
    case Instruction::BitCast:
      width(Cast->getSrcTy(), I);
      return Join({".bitcast", Op(0)});
    case Instruction::FPExt:
    case Instruction::FPTrunc:
      return Join({".fpConvert", format(Cast->getSrcTy(), I).str(),
                   format(I.getType(), I).str(), Op(0)});
    case Instruction::FPToSI:
      return Join({".fptosi", format(Cast->getSrcTy(), I).str(), Width, Op(0)});
    default: unsupported("cast", I);
    }
  }

  if (isa<SelectInst>(I))
    return Join({".select", Op(0), Op(1), Op(2)});
  if (isa<FreezeInst>(I))
    unsupported("instruction", I);

  if (I.getOpcode() == Instruction::FNeg)
    return Join({".fneg", format(I.getType(), I).str(), Op(0)});

  if (const auto *Load = dyn_cast<LoadInst>(&I)) {
    const auto *GEP = dyn_cast<GetElementPtrInst>(Load->getPointerOperand());
    if (Load->isVolatile() || !GEP || GEP->getNumIndices() != 1)
      unsupported("memory access", I);
    const auto *GV = dyn_cast<GlobalVariable>(GEP->getPointerOperand());
    if (!GV)
      unsupported("memory access", I);
    unsigned Index = table(*GV, I);
    // The address must be that of a whole element of the type being read.
    Type *Elem = cast<ConstantDataArray>(GV->getInitializer())->getElementType();
    if (Elem != Load->getType() ||
        DL.getTypeAllocSize(GEP->getSourceElementType()) !=
            DL.getTypeAllocSize(Elem))
      unsupported("memory access", I);
    return Join({".load", utostr(Index), operand(GEP->getOperand(1))});
  }

  if (const auto *Call = dyn_cast<CallInst>(&I)) {
    if (const auto *II = dyn_cast<IntrinsicInst>(Call)) {
      switch (II->getIntrinsicID()) {
      case Intrinsic::fabs:
        return Join({".fabs", format(I.getType(), I).str(), Op(0)});
      case Intrinsic::fmuladd:
        return Join({".fmuladd", format(I.getType(), I).str(), Op(0), Op(1), Op(2)});
      default: unsupported("intrinsic", I);
      }
    }
    const Function *Callee = Call->getCalledFunction();
    auto Core = Callee ? extract::lookupCoreOp(*Callee) : std::nullopt;
    if (!Core)
      unsupported("call", I);
    std::string Args;
    for (const Use &Arg : Call->args())
      Args += (Args.empty() ? "" : ", ") + operand(Arg);
    return ".call ." + Core->LeanName.str() + " [" + Args + "]";
  }

  unsupported("instruction", I);
}

std::string Exporter::terminator(const Instruction &I) {
  if (const auto *Ret = dyn_cast<ReturnInst>(&I)) {
    if (!Ret->getReturnValue())
      unsupported("terminator", I);
    return ".ret " + operand(Ret->getReturnValue());
  }
  if (const auto *Br = dyn_cast<UncondBrInst>(&I))
    return ".br " + utostr(Blocks.lookup(Br->getSuccessor()));
  if (const auto *Br = dyn_cast<CondBrInst>(&I))
    return ".condBr " + operand(Br->getCondition()) + " " +
           utostr(Blocks.lookup(Br->getSuccessor(0))) + " " +
           utostr(Blocks.lookup(Br->getSuccessor(1)));
  unsupported("terminator", I);
}

void Exporter::run() {
  unsigned Next = 0;
  for (const Argument &Arg : F.args())
    Registers[&Arg] = Next++;
  for (const BasicBlock &BB : F) {
    Blocks[&BB] = Blocks.size();
    for (const Instruction &I : BB)
      if (!I.isTerminator() && !isTableAddress(I))
        Registers[&I] = Next++;
  }

  std::string Body;
  raw_string_ostream BS(Body);
  for (const BasicBlock &BB : F) {
    BS << "    -- block " << Blocks.lookup(&BB) << "\n    { phis := [";
    bool First = true;
    for (const PHINode &Phi : BB.phis()) {
      width(Phi.getType(), Phi);
      BS << (First ? "\n" : ",\n") << "        (" << Registers.lookup(&Phi) << ", [";
      for (unsigned N = 0; N != Phi.getNumIncomingValues(); ++N)
        BS << (N ? ", " : "") << "(" << Blocks.lookup(Phi.getIncomingBlock(N))
           << ", " << operand(Phi.getIncomingValue(N)) << ")";
      BS << "])";
      First = false;
    }
    BS << "]\n      body := [";
    First = true;
    for (const Instruction &I : BB) {
      if (isa<PHINode>(I) || I.isTerminator() || isTableAddress(I))
        continue;
      width(I.getType(), I);
      BS << (First ? "\n" : ",\n") << "        (" << Registers.lookup(&I)
         << ", " << instruction(I) << ")";
      First = false;
    }
    BS << "]\n      term := " << terminator(*BB.getTerminator()) << " }"
       << (&BB == &F.back() ? "" : ",") << "\n";
  }

  OS << "import LibcMath.IR.Syntax\n\n"
     << "/-! Generated by `ir2lean` from `" << F.getName()
     << "`" << (Origin.empty() ? "" : "\n(" + Origin + ")")
     << ". Do not edit. -/\n\n"
     << "namespace LibcMath.Extracted\n\nopen LibcMath.IR\n\n"
     << "set_option maxRecDepth 100000 in\n"
     << "def " << LeanName << " : Func where\n  params := [";
  for (const Argument &Arg : F.args())
    OS << (Arg.getArgNo() ? ", " : "") << width(Arg.getType(), Arg);
  OS << "]\n  tables := #[";
  for (const GlobalVariable *GV : Tables) {
    const auto *Data = cast<ConstantDataArray>(GV->getInitializer());
    OS << (GV == Tables.front() ? "\n" : ",\n") << "    -- " << GV->getName()
       << "\n    { width := " << width(Data->getElementType(), *GV)
       << ", elems := #[";
    for (unsigned N = 0; N != Data->getNumElements(); ++N) {
      const Constant *Elem = Data->getElementAsConstant(N);
      APInt Bits = isa<ConstantFP>(Elem)
                       ? cast<ConstantFP>(Elem)->getValueAPF().bitcastToAPInt()
                       : cast<ConstantInt>(Elem)->getValue();
      OS << (N ? "," : "") << (N % 4 ? " " : "\n      ") << "0x"
         << toString(Bits, 16, /*Signed=*/false);
    }
    OS << "] }";
  }
  OS << "]\n  blocks := #[\n" << Body << "  ]\n\nend LibcMath.Extracted\n";
}

} // namespace

int main(int argc, char **argv) {
  cl::ParseCommandLineOptions(argc, argv, "Export an IR function to Lean\n");

  LLVMContext Context;
  SMDiagnostic Err;
  std::unique_ptr<Module> M = parseIRFile(InputFile, Err, Context);
  if (!M) {
    Err.print(argv[0], errs());
    return 1;
  }

  for (const Function &F : *M) {
    if (F.isDeclaration() || extract::relativeName(F) != FunctionName)
      continue;
    Exporter(F, outs()).run();
    return 0;
  }
  errs() << "ir2lean: no function named " << FunctionName << "\n";
  return 1;
}
