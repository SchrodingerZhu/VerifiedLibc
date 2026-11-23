import LibcMath.IR.Interp

/-!
# Why the interpreter gave up

`Func.exec` answers `none` without a reason. `Func.explain` runs the same steps and reports the
first one that has no answer: the block, the register and the kind of instruction, together with
the registers whose value the interpreter does not know exactly, which are the usual cause.

```
#eval IO.println (f.explain mode [.ofModel x])
```

This file proves nothing and nothing depends on it. It calls `Instr.exec`, `Operand.exec` and the
other pieces of the interpreter instead of repeating them, and `Func.explain` consults `Func.exec`
first, so it never reports a failure where the interpreter has an answer.
-/

namespace LibcMath.IR

open FloatLib.Floats.Formats.BinaryInterchange
open Model (IEEERoundingMode)

private def hex (n : ℕ) : String :=
  "0x" ++ String.ofList (Nat.toDigits 16 n)

def AbsVal.describe : AbsVal → String
  | exact v => s!"the {v.width}-bit pattern {hex v.bits.toNat}"
  | nan fmt x _ => s!"some NaN of width {fmt.bitWidth} (FloatLib computes {hex x.toNatBits})"
  | any width => s!"an unspecified value of width {width}"

/-- The kind of an instruction, for messages. -/
def Instr.kind : Instr → String
  | intBin .. => "integer arithmetic"
  | icmp .. => "icmp"
  | zext .. => "zext"
  | sext .. => "sext"
  | trunc .. => "trunc"
  | select .. => "select"
  | fBin .. => "floating-point arithmetic"
  | fneg .. => "fneg"
  | fabs .. => "fabs"
  | fmuladd .. => "fmuladd"
  | fcmp .. => "fcmp"
  | fpConvert .. => "fpext or fptrunc"
  | fptosi .. => "fptosi"
  | bitcast .. => "bitcast"
  | load .. => "load"
  | call .. => "call"

/-- The registers whose value is not known exactly. Only `phi`, `select`, `bitcast` and `ret`
accept such a register as an operand. -/
def Store.inexact (s : Store) : List String :=
  (List.range s.size).filterMap fun r =>
    match s.get r with
    | some (.exact _) | none => none
    | some a => some s!"%{r} is {a.describe}"

private def Store.report (s : Store) : String :=
  match s.inexact with
  | [] => "Every register assigned so far is known exactly, so look at the instruction itself: \
    operands of different widths, a register that is not assigned, a table index out of range, \
    or a conversion to an integer that fails."
  | l => "Registers not known exactly: " ++ "; ".intercalate l ++ "."

def explainPhis (cur pred : ℕ) (old : Store) :
    Store → List (Reg × List (ℕ × Operand)) → Except String Store
  | s, [] => .ok s
  | s, (r, incoming) :: rest =>
    match incoming.lookup pred with
    | none => .error s!"block {cur}: the phi node %{r} has no value for predecessor {pred}."
    | some a =>
      match a.exec old with
      | none => .error s!"block {cur}: the phi node %{r} reads a register that is not assigned."
      | some v => explainPhis cur pred old (s.set r v) rest

def explainBody (mode : IEEERoundingMode) (f : Func) (cur : ℕ) :
    Store → List (Reg × Instr) → Except String Store
  | s, [] => .ok s
  | s, (r, i) :: rest =>
    match i.exec mode f s with
    | none => .error s!"block {cur}: %{r} ({i.kind}) has no answer. {s.report}"
    | some a => explainBody mode f cur (s.set r a) rest

def Func.explainFrom (mode : IEEERoundingMode) (f : Func) :
    (fuel pred cur : ℕ) → Store → Except String AbsVal
  | 0, _, cur, _ => .error s!"block {cur}: every block was already entered once; the interpreter \
      does not follow loops."
  | fuel + 1, pred, cur, s => do
    let some b := f.blocks[cur]? | .error s!"there is no block {cur}."
    let s₁ ← explainPhis cur pred s s b.phis
    let s₂ ← explainBody mode f cur s₁ b.body
    match b.term with
    | .ret a =>
      match a.exec s₂ with
      | some v => .ok v
      | none => .error s!"block {cur}: the returned register is not assigned."
    | .br target => f.explainFrom mode fuel cur target s₂
    | .condBr cond ifTrue ifFalse =>
      match cond.execBool s₂ with
      | some c => f.explainFrom mode fuel cur (if c then ifTrue else ifFalse) s₂
      | none => .error s!"block {cur}: the branch condition is not a known boolean. {s₂.report}"

/-- What `f.exec mode args` answers, or the first step at which it has no answer. -/
def Func.explain (mode : IEEERoundingMode) (f : Func) (args : List Val) : String :=
  match f.exec mode args with
  | some a => s!"The interpreter answers {a.describe}."
  | none =>
    match f.explainFrom mode f.blocks.size 0 0 (.ofArgs args) with
    | .error e => s!"The interpreter gave up at {e}"
    | .ok _ => "The interpreter gave up, but `Func.explainFrom` found no step without an answer: \
        it no longer follows `Func.execFrom` and has to be updated."

/-- Why `f.runFloat fmt mode args` has no answer, when `f.exec` has one. -/
def Func.explainFloat (fmt : FloatFormat) (mode : IEEERoundingMode) (f : Func)
    (args : List Val) : String :=
  match f.exec mode args, f.runFloat fmt mode args with
  | some a, none => s!"The interpreter answers {a.describe}, which is not a bit pattern of a \
      format of width {fmt.bitWidth}."
  | _, _ => f.explain mode args

end LibcMath.IR
