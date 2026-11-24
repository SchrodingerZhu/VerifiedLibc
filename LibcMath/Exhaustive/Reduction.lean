import LibcMath.Exhaustive.Interface
import LibcMath.SpecLemmas

/-!
# From checks of finitely many blocks to correct rounding

This file turns checks of blocks of consecutive bit patterns into `CorrectlyRounded` for any
total unary implementation `impl : IEEERoundingMode → Model fmt → Model fmt` (including any
extracted `Core.UnaryKernel`).

## The pieces

* `CorrectAt S impl mode x`: `impl mode x` has the same IEEE value as `S.eval mode x`. A
  successful `checkRange` gives this for every input of its block (`CorrectAt.of_checkRange`,
  `holdsOnBits_of_checkRange`).
* `correctlyRounded_of_holdsOnBits`: `impl` is correctly rounded if, for each rounding direction,
  `CorrectAt` holds on `[0, 2 ^ fmt.bitWidth)` in the sense of `HoldsOnBits`.
* `checkBlocks` / `holdsOnBits_of_checkBlocks`: check consecutive blocks along a list of
  boundaries.
* `checkRangeResult` / `holdsOnBits_of_checkRangeResult`: check against a proved closed form
  without calling an oracle.

## When a block check fails

`checkRange.firstFailure O.check impl mode first count` returns the first failing bit pattern
(compilable for `#eval` and CLI diagnostics; see `Core.Diag.diagnoseBlock` for rich formatting),
and `checkRange.firstFailure_eq_none_iff` proves it returns `none` iff `checkRange` returns `true`.
-/

namespace LibcMath

open FloatLib.Floats.Formats.BinaryInterchange
open Model (IEEERoundingMode)

variable {fmt : FloatFormat} {S : Spec fmt}
  {impl : IEEERoundingMode → Model fmt → Model fmt}
  {mode : IEEERoundingMode} {x : Model fmt} {first count lo hi : ℕ}

/-- Under `mode`, the implementation `impl` produces the result `S` prescribes on `x`. -/
@[grind]
def CorrectAt (S : Spec fmt) (impl : IEEERoundingMode → Model fmt → Model fmt)
    (mode : IEEERoundingMode) (x : Model fmt) : Prop :=
  SameValue (impl mode x) (S.eval mode x)

theorem correctlyRounded_iff_forall_correctAt {modes : Set IEEERoundingMode} :
    CorrectlyRounded S modes impl ↔ ∀ mode ∈ modes, ∀ x, CorrectAt S impl mode x :=
  Iff.rfl

/-! ### Blocks checked against an oracle -/

/-- Single-input predicate used by `checkRange`, taking the oracle's test as a plain function so
diagnostics and native runners can compile at concrete `S`. -/
def checkRange.test (check : IEEERoundingMode → Model fmt → Model fmt → Bool)
    (impl : IEEERoundingMode → Model fmt → Model fmt)
    (mode : IEEERoundingMode) (input : Model fmt) : Bool :=
  check mode input (impl mode input)

theorem checkRange_eq_checkBits (O : Oracle S)
    (impl : IEEERoundingMode → Model fmt → Model fmt) (mode : IEEERoundingMode)
    (first count : ℕ) :
    checkRange O impl mode first count = checkBits (checkRange.test O.check impl mode) first count :=
  rfl

/-- First bit pattern of `[first, first + count)` rejected by `check`. Compilable for `#eval`. -/
def checkRange.firstFailure (check : IEEERoundingMode → Model fmt → Model fmt → Bool)
    (impl : IEEERoundingMode → Model fmt → Model fmt) (mode : IEEERoundingMode)
    (first count : ℕ) : Option ℕ :=
  firstFailingBits (checkRange.test check impl mode) first count

theorem checkRange.firstFailure_eq_none_iff {O : Oracle S} :
    checkRange.firstFailure O.check impl mode first count = none ↔
      checkRange O impl mode first count = true :=
  firstFailingBits_eq_none_iff

@[grind =]
theorem checkRange_eq_true_iff {O : Oracle S} :
    checkRange O impl mode first count = true ↔
      ∀ i < count, O.check mode (.ofNatBits (first + i)) (impl mode (.ofNatBits (first + i))) = true :=
  checkBits_eq_true_iff

/-- A block is checked by checking an initial part and the rest. -/
theorem checkRange_add (O : Oracle S) (impl : IEEERoundingMode → Model fmt → Model fmt)
    (mode : IEEERoundingMode) (first m n : ℕ) :
    checkRange O impl mode first (m + n) =
      (checkRange O impl mode first m && checkRange O impl mode (first + m) n) :=
  checkBits_add (checkRange.test O.check impl mode) first m n

/-- A checked block establishes `CorrectAt` on every input in the block. -/
theorem CorrectAt.of_checkRange {O : Oracle S}
    (h : checkRange O impl mode first count = true) {i : ℕ} (hi : i < count) :
    CorrectAt S impl mode (.ofNatBits (first + i)) :=
  O.sound _ _ _ (checkRange_eq_true_iff.1 h i hi)

theorem holdsOnBits_of_checkRange {O : Oracle S} (h : checkRange O impl mode first count = true) :
    HoldsOnBits (CorrectAt S impl mode) first (first + count) :=
  HoldsOnBits.iff_forall_lt.2 fun _ => CorrectAt.of_checkRange h

/-- `checkRange` on each block between two consecutive entries of a list of boundaries. -/
def checkBlocks (O : Oracle S) (impl : IEEERoundingMode → Model fmt → Model fmt)
    (mode : IEEERoundingMode) : List ℕ → Bool
  | a :: b :: bounds => checkRange O impl mode a (b - a) && checkBlocks O impl mode (b :: bounds)
  | _ => true

theorem isChain_of_checkBlocks {O : Oracle S} :
    ∀ {bounds : List ℕ}, checkBlocks O impl mode bounds = true →
      bounds.IsChain (HoldsOnBits (CorrectAt S impl mode))
  | [], _ => .nil
  | [_], _ => .singleton _
  | a :: b :: bounds, h => by
    rw [checkBlocks, Bool.and_eq_true] at h
    refine List.isChain_cons_cons.2 ⟨?_, isChain_of_checkBlocks h.2⟩
    rcases le_total a b with hab | hab
    · simpa [Nat.add_sub_cancel' hab] using holdsOnBits_of_checkRange h.1
    · exact .of_le hab

/-- Checked consecutive blocks establish `CorrectAt` from the first boundary to the last. -/
theorem holdsOnBits_of_checkBlocks {O : Oracle S} {bounds : List ℕ}
    (h : checkBlocks O impl mode bounds = true) (hlo : lo ∈ bounds.head?)
    (hhi : hi ∈ bounds.getLast?) : HoldsOnBits (CorrectAt S impl mode) lo hi :=
  .of_isChain (isChain_of_checkBlocks h) hlo hhi

/-! ### Blocks checked against given results -/

/-- Check that `impl mode x` has the same value as `expected x` on `[first, first + count)`. -/
def checkRangeResult (impl : IEEERoundingMode → Model fmt → Model fmt)
    (mode : IEEERoundingMode) (expected : Model fmt → Model fmt) (first count : ℕ) : Bool :=
  checkBits (first := first) (count := count) fun input =>
    decide (SameValue (impl mode input) (expected input))

@[grind =]
theorem checkRangeResult_eq_true_iff {expected : Model fmt → Model fmt} :
    checkRangeResult impl mode expected first count = true ↔
      ∀ i < count, SameValue (impl mode (.ofNatBits (first + i)))
        (expected (.ofNatBits (first + i))) := by
  simp [checkRangeResult, checkBits_eq_true_iff]

/-- If `expected` describes the prescribed results on a block and `impl` produces them, then
`impl` is correct on that block. -/
theorem holdsOnBits_of_checkRangeResult {expected : Model fmt → Model fmt}
    (hexpected : HoldsOnBits (fun x => SameValue (expected x) (S.eval mode x))
      first (first + count))
    (h : checkRangeResult impl mode expected first count = true) :
    HoldsOnBits (CorrectAt S impl mode) first (first + count) :=
  HoldsOnBits.iff_forall_lt.2 fun i hi =>
    (checkRangeResult_eq_true_iff.1 h i hi).trans (HoldsOnBits.iff_forall_lt.1 hexpected i hi)

/-! ### Whole-format assembly -/

/-- An implementation that is correct on every bit pattern of the format under every mode in
`modes` is correctly rounded. -/
theorem correctlyRounded_of_holdsOnBits {modes : Set IEEERoundingMode}
    (h : ∀ mode ∈ modes, HoldsOnBits (CorrectAt S impl mode) 0 (2 ^ fmt.bitWidth)) :
    CorrectlyRounded S modes impl :=
  fun mode hmode => (h mode hmode).forall

/-- Correct rounding by computation alone: for each mode in `modes`, a list of boundaries from
`0` to `2 ^ fmt.bitWidth` whose consecutive blocks all pass `checkRange`. -/
theorem correctlyRounded_of_checkBlocks {modes : Set IEEERoundingMode} (O : Oracle S)
    (bounds : IEEERoundingMode → List ℕ)
    (h : ∀ mode ∈ modes, checkBlocks O impl mode (bounds mode) = true ∧
      0 ∈ (bounds mode).head? ∧ 2 ^ fmt.bitWidth ∈ (bounds mode).getLast?) :
    CorrectlyRounded S modes impl :=
  correctlyRounded_of_holdsOnBits fun mode hmode =>
    let ⟨hcheck, hlo, hhi⟩ := h mode hmode
    holdsOnBits_of_checkBlocks hcheck hlo hhi

end LibcMath
