import LibcMath.Check.Oracle
import LibcMath.Correctness

/-!
# Testing an implementation against an oracle on a block of inputs

`checkRange O impl mode first count` (`LibcMath/Check/Oracle.lean`) asks the oracle `O` about the
result of `impl` on each of `count` consecutive bit patterns. It is a test: the compiled program
`checkrange` runs it, and `Core.Diag` reports the first input that fails.

The lemmas here say what a passing test means. They do not make testing the way a function is
proved correct: the proof of a function is by analysis, and a test tells whether the statement
being proved is true before the effort is spent.

* `checkRange.firstFailure O.check impl mode first count` is the first failing bit pattern, and
  `checkRange.firstFailure_eq_none_iff` says it is `none` exactly when the test passes.
* `holdsOnBits_of_checkRange`: a test that passes against a sound oracle gives `CorrectAt` on its
  block.
* `checkRangeResult` compares with a given result instead of an oracle.
-/

namespace LibcMath

open FloatLib.Floats.Formats.BinaryInterchange
open Model (IEEERoundingMode)

variable {fmt : FloatFormat} {S : Spec fmt}
  {impl : IEEERoundingMode → Model fmt → Option (Model fmt)}
  {mode : IEEERoundingMode} {x : Model fmt} {first count lo hi : ℕ}

/-! ### Blocks checked against an oracle -/

/-- Single-input predicate used by `checkRange`, taking the oracle's test as a plain function so
diagnostics and native runners can compile at concrete `S`. -/
def checkRange.test (check : IEEERoundingMode → Model fmt → Model fmt → Bool)
    (impl : IEEERoundingMode → Model fmt → Option (Model fmt))
    (mode : IEEERoundingMode) (input : Model fmt) : Bool :=
  (impl mode input).any (check mode input)

theorem checkRange_eq_checkBits (O : Oracle S)
    (impl : IEEERoundingMode → Model fmt → Option (Model fmt)) (mode : IEEERoundingMode)
    (first count : ℕ) :
    checkRange O impl mode first count =
      checkBits (checkRange.test O.check impl mode) first count :=
  rfl

/-- First bit pattern of `[first, first + count)` rejected by `check`. Compilable for `#eval`. -/
def checkRange.firstFailure (check : IEEERoundingMode → Model fmt → Model fmt → Bool)
    (impl : IEEERoundingMode → Model fmt → Option (Model fmt)) (mode : IEEERoundingMode)
    (first count : ℕ) : Option ℕ :=
  firstFailingBits (checkRange.test check impl mode) first count

theorem checkRange.firstFailure_eq_none_iff {O : Oracle S} :
    checkRange.firstFailure O.check impl mode first count = none ↔
      checkRange O impl mode first count = true :=
  firstFailingBits_eq_none_iff

@[grind =]
theorem checkRange_eq_true_iff {O : Oracle S} :
    checkRange O impl mode first count = true ↔
      ∀ i < count, ∃ y, impl mode (.ofNatBits (first + i)) = some y ∧
        O.check mode (.ofNatBits (first + i)) y = true := by
  simp [checkRange, checkBits_eq_true_iff, Option.any_eq_true]

/-- A block is checked by checking an initial part and the rest. -/
theorem checkRange_add (O : Oracle S) (impl : IEEERoundingMode → Model fmt → Option (Model fmt))
    (mode : IEEERoundingMode) (first m n : ℕ) :
    checkRange O impl mode first (m + n) =
      (checkRange O impl mode first m && checkRange O impl mode (first + m) n) :=
  checkBits_add (checkRange.test O.check impl mode) first m n

/-- A checked block establishes `CorrectAt` on every input in the block. -/
theorem CorrectAt.of_checkRange {O : Oracle S}
    (h : checkRange O impl mode first count = true) {i : ℕ} (hi : i < count) :
    CorrectAt S impl mode (.ofNatBits (first + i)) :=
  let ⟨y, hy, hcheck⟩ := checkRange_eq_true_iff.1 h i hi
  ⟨y, hy, O.sound _ _ _ hcheck⟩

theorem holdsOnBits_of_checkRange {O : Oracle S} (h : checkRange O impl mode first count = true) :
    HoldsOnBits (CorrectAt S impl mode) first (first + count) :=
  HoldsOnBits.iff_forall_lt.2 fun _ => CorrectAt.of_checkRange h

/-! ### Blocks checked against given results -/

/-- Check that `impl mode x` has a result with the same value as `expected x` on
`[first, first + count)`. -/
def checkRangeResult (impl : IEEERoundingMode → Model fmt → Option (Model fmt))
    (mode : IEEERoundingMode) (expected : Model fmt → Model fmt) (first count : ℕ) : Bool :=
  checkBits (first := first) (count := count) fun input =>
    (impl mode input).any fun result => decide (SameValue result (expected input))

@[grind =]
theorem checkRangeResult_eq_true_iff {expected : Model fmt → Model fmt} :
    checkRangeResult impl mode expected first count = true ↔
      ∀ i < count, ∃ y, impl mode (.ofNatBits (first + i)) = some y ∧
        SameValue y (expected (.ofNatBits (first + i))) := by
  simp [checkRangeResult, checkBits_eq_true_iff, Option.any_eq_true]

/-- If `expected` describes the prescribed results on a block and `impl` produces them, then
`impl` is correct on that block. -/
theorem holdsOnBits_of_checkRangeResult {expected : Model fmt → Model fmt}
    (hexpected : HoldsOnBits (fun x => SameValue (expected x) (S.eval mode x))
      first (first + count))
    (h : checkRangeResult impl mode expected first count = true) :
    HoldsOnBits (CorrectAt S impl mode) first (first + count) :=
  HoldsOnBits.iff_forall_lt.2 fun i hi =>
    let ⟨y, hy, hsame⟩ := checkRangeResult_eq_true_iff.1 h i hi
    ⟨y, hy, hsame.trans (HoldsOnBits.iff_forall_lt.1 hexpected i hi)⟩

end LibcMath
