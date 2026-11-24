import LibcMath.Core.Config
import FloatLib.Floats.Formats.BinaryInterchange.Model.ExactValue

/-!
# Agent-friendly diagnostics for extracted math kernels

Provides executable inspection helpers meant for `#eval` during proof development and debugging,
as well as CLI runners:

* `hexBits` / `classifyFloat` / `describeFloat`: human- and agent-readable breakdown of any
  `Model fmt` bit pattern (hex word, IEEE class, sign, biased exponent, fraction, exact rational).
* `ulpDiff?`: signed ULP distance between two finite values of the same format.
* `diagnoseInput` / `diagnoseBlock`: locate and explain the first failing bit pattern in a block
  check, showing input breakdown, kernel output, and `KernelMeta` configuration.
* `firstDiffBits` / `compareKernels`: compare two extracted evaluation plans (e.g. `double_eval`
  vs `integer_eval` or FMA vs non-FMA) across a bit range and explain the first disagreement.
-/

namespace LibcMath.Core.Diag

open FloatLib.Floats.Formats.BinaryInterchange
open Model (IEEERoundingMode)

/-- Zero-padded uppercase hexadecimal string for a fixed-width bit vector. -/
def hexBits {w : Nat} (b : BitVec w) : String :=
  let width := (w + 3) / 4
  let digits := (Nat.toDigits 16 b.toNat).map Char.toUpper
  "0x" ++ String.ofList (List.replicate (width - digits.length) '0' ++ digits)

/-- Short name of an IEEE rounding mode. -/
def modeName : IEEERoundingMode → String
  | .nearest => "nearest"
  | .towardZero => "towardZero"
  | .up => "up"
  | .down => "down"
  | .nearestAway => "nearestAway"
  | .away => "away"

/-- IEEE classification label for a `Model fmt` value. -/
def classifyFloat {fmt : FloatFormat} (x : Model fmt) : String :=
  if x.isNaN then
    if x.isSignaling then "sNaN" else "qNaN"
  else if x.isInfinite then
    if x.signBit then "-Inf" else "+Inf"
  else if x.isZero then
    if x.signBit then "-0" else "+0"
  else if x.isSubnormal then
    if x.signBit then "-subnormal" else "+subnormal"
  else
    if x.signBit then "-normal" else "+normal"

/-- Detailed one-line breakdown of a `Model fmt` bit pattern. -/
def describeFloat {fmt : FloatFormat} (x : Model fmt) : String :=
  let cls := classifyFloat x
  let signStr := if x.signBit then "-" else "+"
  let ratStr := match Model.toRat? x with
    | some q => s!" val={q}"
    | none => ""
  s!"{hexBits x.toBits} ({cls}, s={signStr}, exp={x.expField}, frac={x.fracField}{ratStr})"

/-- Ordered integer rank of a finite IEEE value, where adjacent representable floats differ by 1
and `-0` and `+0` map to `0`. -/
def finiteRank? {fmt : FloatFormat} (x : Model fmt) : Option Int :=
  if !x.isFinite then none
  else
    let mag : Nat := x.toNatBits &&& ((1 <<< (fmt.bitWidth - 1)) - 1)
    if x.signBit then some (-Int.ofNat mag) else some (Int.ofNat mag)

/-- Signed ULP distance `rank(a) - rank(b)` when both operands are finite. -/
def ulpDiff? {fmt : FloatFormat} (a b : Model fmt) : Option Int := do
  let ra ← finiteRank? a
  let rb ← finiteRank? b
  pure (ra - rb)

/-- Whether two results agree up to NaN equivalence (`SameValue`, executable `Bool` form). -/
@[inline] def sameValueBool {fmt : FloatFormat} (a b : Model fmt) : Bool :=
  a == b || (a.isNaN && b.isNaN)

/-- Diagnose a single input against an oracle's executable `check` predicate. -/
def diagnoseInput {fmt : FloatFormat}
    (check : IEEERoundingMode → Model fmt → Model fmt → Bool)
    (impl : IEEERoundingMode → Model fmt → Model fmt)
    (mode : IEEERoundingMode) (x : Model fmt)
    (label : String := "kernel") : String :=
  let y := impl mode x
  let ok := check mode x y
  s!"[{label}] mode={modeName mode} status={if ok then "ok" else "FAIL"}\n" ++
  s!"  input : {describeFloat x}\n" ++
  s!"  output: {describeFloat y}"

/-- Find the first bit pattern in `[first, first + count)` rejected by `check`, returning a
detailed multi-line diagnostic report (or an `ok` summary if every input passes). -/
def diagnoseBlock {fmt : FloatFormat}
    (check : IEEERoundingMode → Model fmt → Model fmt → Bool)
    (impl : IEEERoundingMode → Model fmt → Model fmt)
    (mode : IEEERoundingMode) (first count : Nat)
    (label : String := "kernel") : String :=
  match (List.range count).find? fun i =>
      let x : Model fmt := .ofNatBits (first + i)
      !check mode x (impl mode x) with
  | none =>
      s!"[{label}] mode={modeName mode} range=[{hexBits (BitVec.ofNat fmt.bitWidth first)}, +{count}): ok"
  | some i =>
      let n := first + i
      let x : Model fmt := .ofNatBits n
      s!"[{label}] first failure at offset {i} ({hexBits (BitVec.ofNat fmt.bitWidth n)}):\n" ++
      diagnoseInput check impl mode x label

/-- First bit pattern in `[first, first + count)` where two implementations disagree (up to NaN). -/
def firstDiffBits {fmt : FloatFormat}
    (impl₁ impl₂ : IEEERoundingMode → Model fmt → Model fmt)
    (mode : IEEERoundingMode) (first count : Nat) : Option Nat :=
  ((List.range count).find? fun i =>
    let x : Model fmt := .ofNatBits (first + i)
    !sameValueBool (impl₁ mode x) (impl₂ mode x)).map (first + ·)

/-- Short human-readable tag identifying a kernel and its evaluation variant (e.g. `expf/double_eval`). -/
def kernelTag {fmt : FloatFormat} (k : UnaryKernel fmt) : String :=
  s!"{k.info.name}/{k.info.config.implVariant}"

/-- Compare two extracted `UnaryKernel` evaluation plans over `[first, first + count)` and report
either agreement or a detailed breakdown of the first disagreeing input (including ULP distance). -/
def compareKernels {fmt : FloatFormat} (k₁ k₂ : UnaryKernel fmt)
    (mode : IEEERoundingMode) (first count : Nat) : String :=
  let t₁ := kernelTag k₁
  let t₂ := kernelTag k₂
  match firstDiffBits k₁.eval k₂.eval mode first count with
  | none =>
      s!"[compare {t₁} vs {t₂}] mode={modeName mode} " ++
      s!"range=[{hexBits (BitVec.ofNat fmt.bitWidth first)}, +{count}): all {count} inputs agree"
  | some n =>
      let x : Model fmt := .ofNatBits n
      let y₁ := k₁.eval mode x
      let y₂ := k₂.eval mode x
      let ulpStr := match ulpDiff? y₁ y₂ with
        | some d => s!" ulp_diff={d}"
        | none => ""
      s!"[compare {t₁} vs {t₂}] mode={modeName mode} FIRST DIFF at {describeFloat x}:\n" ++
      s!"  {t₁}: {describeFloat y₁}\n" ++
      s!"  {t₂}: {describeFloat y₂}{ulpStr}"

/-- Evaluate a list of extracted evaluation plans on one input `x` and print their outputs and ULP
offsets relative to the first (reference) plan. -/
def diagnosePlanMatrix {fmt : FloatFormat} (plans : List (UnaryKernel fmt))
    (mode : IEEERoundingMode) (x : Model fmt) : String :=
  let header := s!"[plan-matrix] mode={modeName mode} input={describeFloat x}"
  match plans with
  | [] => header ++ "\n  (no plans)"
  | ref :: _ =>
      let yRef := ref.eval mode x
      let rows := plans.map fun k =>
        let y := k.eval mode x
        let delta :=
          if sameValueBool y yRef then "exact"
          else match ulpDiff? y yRef with
            | some d => s!"ulp={d}"
            | none => "diff"
        s!"  {kernelTag k}: {describeFloat y} [{delta}]"
      String.intercalate "\n" (header :: rows)

/-- Run `diagnoseBlock` on a `UnaryKernel`, automatically tagging output with `kernelTag k`. -/
def diagnoseKernelRange {fmt : FloatFormat}
    (check : IEEERoundingMode → Model fmt → Model fmt → Bool)
    (k : UnaryKernel fmt) (mode : IEEERoundingMode) (first count : Nat) : String :=
  diagnoseBlock check k.eval mode first count (kernelTag k)

/-- Print full provenance and active `LIBC_MATH` / CPU configuration of a kernel. -/
def inspectKernel {fmt : FloatFormat} (k : UnaryKernel fmt) : String :=
  s!"Kernel: {k.info.name}\n" ++
  s!"  C++ function : {k.info.cppFunction}\n" ++
  s!"  Source       : {k.info.sourceFile} ({k.info.sourceCommit})\n" ++
  s!"  Clang        : {k.info.clangVersion}\n" ++
  s!"  Config       : {k.info.config.summary}\n" ++
  s!"  Tables       : {k.info.tables}"

end LibcMath.Core.Diag
