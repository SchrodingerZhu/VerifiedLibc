import LibcMath.Spec

/-!
# Extracted code

The fragment of LLVM IR that the bodies of libc math functions compile to once their core
operations are kept as calls: loop-free control flow over integer and floating-point
instructions, reads of constant tables, and calls of core operations.

Values of this type are produced by the `ir2lean` tool from the optimized IR of a function.
-/

namespace LibcMath.IR

/-- An SSA register. Parameters come first, then instructions in program order. -/
abbrev Reg := ℕ

/-- An operand: a register, or a constant given by its width and bit pattern. Floating-point
constants appear as their encodings. -/
inductive Operand where
  | reg (r : Reg)
  | const (width bits : ℕ)
  deriving DecidableEq

inductive IntBinOp where
  | add | sub | mul | and | or | xor | shl | lshr | ashr
  deriving DecidableEq

inductive ICmp where
  | eq | ne | ult | ule | ugt | uge | slt | sle | sgt | sge
  deriving DecidableEq

inductive FBinOp where
  | fadd | fsub | fmul
  deriving DecidableEq

/-- Ordered comparisons are false, and unordered ones true, when an operand is NaN. -/
inductive FCmp where
  | oeq | ogt | oge | olt | ole | one | ord
  | ueq | ugt | uge | ult | ule | une | uno
  deriving DecidableEq

/-- Operations of libc that extraction keeps as calls. -/
inductive CoreOp where
  /-- `fputil::quick_get_round`: the rounding direction as an `FE_*` constant. -/
  | quickGetRound
  | isRoundUp
  | isRoundDown
  | isRoundToNearest
  | isRoundToZero
  /-- `fputil::set_errno_if_required`. -/
  | setErrno
  /-- `fputil::raise_except_if_required` and its variants. -/
  | raiseExcept
  deriving DecidableEq

inductive Instr where
  | intBin (op : IntBinOp) (a b : Operand)
  | icmp (pred : ICmp) (a b : Operand)
  | zext (width : ℕ) (a : Operand)
  | sext (width : ℕ) (a : Operand)
  | trunc (width : ℕ) (a : Operand)
  | select (cond a b : Operand)
  | fBin (F : Format) (op : FBinOp) (a b : Operand)
  | fneg (F : Format) (a : Operand)
  | fabs (F : Format) (a : Operand)
  /-- `llvm.fmuladd`: `a * b + c`, fused or not at the discretion of the target. -/
  | fmuladd (F : Format) (a b c : Operand)
  | fcmp (F : Format) (pred : FCmp) (a b : Operand)
  /-- `fpext` and `fptrunc`. -/
  | fpConvert (src dst : Format) (a : Operand)
  | fptosi (src : Format) (width : ℕ) (a : Operand)
  /-- A bit cast between an integer and a floating-point type; the bits are unchanged. -/
  | bitcast (a : Operand)
  /-- Read element `index` of constant table `table`. -/
  | load (table : ℕ) (index : Operand)
  | call (op : CoreOp) (args : List Operand)

inductive Terminator where
  | ret (a : Operand)
  | br (target : ℕ)
  | condBr (cond : Operand) (ifTrue ifFalse : ℕ)

structure Block where
  /-- Phi nodes: the register defined, and its value for each predecessor block. -/
  phis : List (Reg × List (ℕ × Operand))
  body : List (Reg × Instr)
  term : Terminator

/-- A constant array of elements of one width. -/
structure Table where
  width : ℕ
  elems : Array ℕ

structure Func where
  /-- Widths of the parameters, which occupy registers `0, 1, …`. -/
  params : List ℕ
  tables : Array Table
  /-- Basic blocks; execution starts at block `0`. -/
  blocks : Array Block

end LibcMath.IR
