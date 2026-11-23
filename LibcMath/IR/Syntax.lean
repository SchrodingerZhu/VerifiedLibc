import FloatLib.Floats.Formats.BinaryInterchange.Format.Catalog
import Mathlib.Data.Nat.Notation

/-!
# Extracted code

The fragment of LLVM IR that the bodies of libc math functions compile to once their core
operations are kept as calls: loop-free control flow over integer and floating-point
instructions, reads of constant tables, and calls of core operations.

Values of this type are produced by the `ir2lean` tool from the optimized IR of a function.
-/

namespace LibcMath.IR

open FloatLib.Floats.Formats.BinaryInterchange (FloatFormat)

/-- An SSA register. Parameters come first, then instructions in program order. -/
abbrev Reg := ℕ

/-- An operand: a register, or a constant given by its width and bit pattern. Floating-point
constants appear as their encodings. -/
inductive Operand where
  | reg (r : Reg)
  | const (width bits : ℕ)
  deriving DecidableEq

/-- The flags of integer instructions under which LLVM produces poison. An instruction whose flag
is set has a result only when the condition of the flag holds; `Semantics.lean` states the
conditions. A flag is consulted only by the instructions that carry it in LLVM.

`getelementptr` flags (`inbounds`, `nuw`, `nusw`) have no counterpart here: a table access is one
`load` instruction, which has a result only when its index is within the table, and that implies
the conditions of all three. -/
structure Flags where
  /-- No unsigned overflow: `add`, `sub`, `mul`, `shl`, `trunc`. -/
  nuw : Bool := false
  /-- No signed overflow: `add`, `sub`, `mul`, `shl`, `trunc`. -/
  nsw : Bool := false
  /-- No set bit is shifted out: `lshr`, `ashr`. -/
  exact : Bool := false
  /-- The operands have no set bit in common: `or`. -/
  disjoint : Bool := false
  /-- The operands have the same sign: `icmp`. -/
  samesign : Bool := false
  /-- The operand is non-negative: `zext`, `uitofp`. -/
  nneg : Bool := false
  deriving DecidableEq

/-- The fast-math flags that restrict the values of a floating-point instruction. An instruction
whose flag is set has a result only when none of its floating-point arguments, and not its
floating-point result, is a value the flag excludes. The other fast-math flags of LLVM (`nsz`,
`arcp`, `contract`, `afn`, `reassoc`) license different results and are not represented. -/
structure FastMathFlags where
  /-- No NaNs. -/
  nnan : Bool := false
  /-- No infinities. -/
  ninf : Bool := false
  deriving DecidableEq

inductive IntBinOp where
  | add | sub | mul | and | or | xor | shl | lshr | ashr
  deriving DecidableEq

inductive ICmp where
  | eq | ne | ult | ule | ugt | uge | slt | sle | sgt | sge
  deriving DecidableEq

inductive FBinOp where
  | fadd | fsub | fmul | fdiv
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
  | intBin (op : IntBinOp) (a b : Operand) (flags : Flags := {})
  | icmp (pred : ICmp) (a b : Operand) (flags : Flags := {})
  | zext (width : ℕ) (a : Operand) (flags : Flags := {})
  | sext (width : ℕ) (a : Operand)
  | trunc (width : ℕ) (a : Operand) (flags : Flags := {})
  | select (cond a b : Operand)
  | fBin (fmt : FloatFormat) (op : FBinOp) (a b : Operand) (fmf : FastMathFlags := {})
  | fneg (fmt : FloatFormat) (a : Operand) (fmf : FastMathFlags := {})
  | fabs (fmt : FloatFormat) (a : Operand) (fmf : FastMathFlags := {})
  /-- `llvm.fmuladd`: `a * b + c`, fused or not at the discretion of the target. -/
  | fmuladd (fmt : FloatFormat) (a b c : Operand) (fmf : FastMathFlags := {})
  | fcmp (fmt : FloatFormat) (pred : FCmp) (a b : Operand) (fmf : FastMathFlags := {})
  /-- `fpext` and `fptrunc`. -/
  | fpConvert (src dst : FloatFormat) (a : Operand) (fmf : FastMathFlags := {})
  | fptosi (src : FloatFormat) (width : ℕ) (a : Operand)
  | fptoui (src : FloatFormat) (width : ℕ) (a : Operand)
  | sitofp (dst : FloatFormat) (a : Operand)
  | uitofp (dst : FloatFormat) (a : Operand) (flags : Flags := {})
  /-- `llvm.sqrt`. -/
  | sqrt (fmt : FloatFormat) (a : Operand) (fmf : FastMathFlags := {})
  /-- `llvm.copysign`: `a` with the sign of `b`. -/
  | copysign (fmt : FloatFormat) (a b : Operand) (fmf : FastMathFlags := {})
  /-- `llvm.is.fpclass`: whether `a` belongs to one of the classes that the bits of `mask`
  select. -/
  | isFpClass (fmt : FloatFormat) (a : Operand) (mask : ℕ)
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
