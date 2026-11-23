import LibcMath.Exhaustive.Interface
import LibcMath.Exhaustive.Range
import LibcMath.IR.Semantics
import LibcMath.SpecLemmas

/-!
# From checks of finitely many blocks to correct rounding

This file turns checks of blocks of consecutive bit patterns into the statement that an extracted
function is correctly rounded.

## The pieces

* `RunsCorrectlyAt S run mode x`: the executable implementation `run` produces on the input `x` a
  result with the value `S` prescribes. A successful `checkRange` gives this for every input of
  its block (`RunsCorrectlyAt.of_checkRange`).
* `IR.Func.IsComputedBy f run`: the hypothesis that `run` is a sound interpreter for the extracted
  function `f`.
* `IR.Func.CorrectAt f S mode x`: `f` is correctly rounded on the single input `x`. It is the
  statement of `IR.Func.CorrectlyRounded` for one rounding direction and one input, and it follows
  from `RunsCorrectlyAt` when `run` is sound (`IR.Func.IsComputedBy.correctAt`).
* `IR.Func.correctlyRounded_of_holdsOnBits`: `f` is correctly rounded if, for each rounding
  direction, `CorrectAt` holds on the range `[0, 2 ^ fmt.bitWidth)` in the sense of
  `HoldsOnBits`.

## How a proof for a whole format is assembled

For one rounding direction `mode`, the goal is
`HoldsOnBits (f.CorrectAt S mode) 0 (2 ^ fmt.bitWidth)`. It is obtained from statements
`HoldsOnBits (f.CorrectAt S mode) lo hi` for smaller ranges with `HoldsOnBits.append`, or
`HoldsOnBits.of_isChain` for a list of boundaries. Adjacent ranges share a boundary syntactically,
so no side condition about coverage has to be evaluated. A statement for one range can come from

* a block check: `IR.Func.IsComputedBy.holdsOnBits_of_checkRange` for one block, and
  `IR.Func.IsComputedBy.holdsOnBits_of_checkBlocks` for consecutive blocks given by a list of
  boundaries;
* a description of the prescribed results proved by other means, together with a run of the
  implementation alone: `IR.Func.IsComputedBy.holdsOnBits_of_checkRangeResult`;
* any proof of `f.CorrectAt S mode` for the inputs of the range, for instance one that reasons
  about `f.Returns` directly.

## How a block check is established

The hypotheses of the theorems here have the form `checkRange O run mode first count = true`
(likewise for `checkBlocks` and `checkRangeResult`). This file does not fix how such an equation
is proved. It is a closed Boolean computation, so the possibilities are evaluation in the kernel
(`decide +kernel`), which needs `run` and `O.check` to reduce well there and adds nothing to the
trusted base; `native_decide`, which trusts the compiler and should stay in files that are
clearly separated from the rest; or a checker outside Lean whose verdicts enter as explicit
hypotheses. `checkRange_add` splits a block, so the block size can be chosen to suit the method.
-/

namespace LibcMath

open FloatLib.Floats.Formats.BinaryInterchange
open Model (IEEERoundingMode)

variable {fmt : FloatFormat} {S : Spec fmt}
  {run : IEEERoundingMode → Model fmt → Option (Model fmt)}
  {mode : IEEERoundingMode} {x y : Model fmt} {first count lo hi : ℕ}

/-- The implementation `run` produces on the input `x` a result with the value `S` prescribes. -/
def RunsCorrectlyAt (S : Spec fmt) (run : IEEERoundingMode → Model fmt → Option (Model fmt))
    (mode : IEEERoundingMode) (x : Model fmt) : Prop :=
  ∃ y, run mode x = some y ∧ SameValue y (S.eval mode x)

/-! ### Blocks checked against an oracle -/

theorem checkRange_eq_true_iff {O : Oracle S} :
    checkRange O run mode first count = true ↔
      ∀ i < count, ∃ y, run mode (.ofNatBits (first + i)) = some y ∧
        O.check mode (.ofNatBits (first + i)) y = true := by
  simp only [checkRange, List.all_eq_true, List.mem_range]
  refine forall₂_congr fun i _ => ?_
  cases run mode (.ofNatBits (first + i)) <;> simp

/-- A block is checked by checking an initial part and the rest. -/
theorem checkRange_add (O : Oracle S) (run : IEEERoundingMode → Model fmt → Option (Model fmt))
    (mode : IEEERoundingMode) (first m n : ℕ) :
    checkRange O run mode first (m + n) =
      (checkRange O run mode first m && checkRange O run mode (first + m) n) := by
  simp [checkRange, List.range_add, List.all_map, Function.comp_def, Nat.add_assoc]

/-- A checked block: on each of its inputs, `run` produces the prescribed result. -/
theorem RunsCorrectlyAt.of_checkRange {O : Oracle S}
    (h : checkRange O run mode first count = true) {i : ℕ} (hi : i < count) :
    RunsCorrectlyAt S run mode (.ofNatBits (first + i)) :=
  let ⟨y, hy, hcheck⟩ := checkRange_eq_true_iff.1 h i hi
  ⟨y, hy, O.sound _ _ _ hcheck⟩

theorem holdsOnBits_of_checkRange {O : Oracle S} (h : checkRange O run mode first count = true) :
    HoldsOnBits (RunsCorrectlyAt S run mode) first (first + count) :=
  HoldsOnBits.iff_forall_lt.2 fun _ => RunsCorrectlyAt.of_checkRange h

/-- `checkRange` on each block between two consecutive entries of a list of boundaries. -/
def checkBlocks (O : Oracle S) (run : IEEERoundingMode → Model fmt → Option (Model fmt))
    (mode : IEEERoundingMode) : List ℕ → Bool
  | a :: b :: bounds => checkRange O run mode a (b - a) && checkBlocks O run mode (b :: bounds)
  | _ => true

theorem isChain_of_checkBlocks {O : Oracle S} :
    ∀ {bounds : List ℕ}, checkBlocks O run mode bounds = true →
      bounds.IsChain (HoldsOnBits (RunsCorrectlyAt S run mode))
  | [], _ => .nil
  | [_], _ => .singleton _
  | a :: b :: bounds, h => by
    rw [checkBlocks, Bool.and_eq_true] at h
    refine List.isChain_cons_cons.2 ⟨?_, isChain_of_checkBlocks h.2⟩
    rcases le_total a b with hab | hab
    · simpa [Nat.add_sub_cancel' hab] using holdsOnBits_of_checkRange h.1
    · exact .of_le hab

/-- Checked consecutive blocks: `run` produces the prescribed result on every input between the
first and the last boundary. -/
theorem holdsOnBits_of_checkBlocks {O : Oracle S} {bounds : List ℕ}
    (h : checkBlocks O run mode bounds = true) (hlo : lo ∈ bounds.head?)
    (hhi : hi ∈ bounds.getLast?) : HoldsOnBits (RunsCorrectlyAt S run mode) lo hi :=
  .of_isChain (isChain_of_checkBlocks h) hlo hhi

/-! ### Blocks checked against given results -/

/-- The implementation `run` produces a result with the same value as `expected input` on each of
the `count` bit patterns starting at `first`. No oracle is involved: this is the check to use when
the prescribed results on a range are known by proof. -/
def checkRangeResult (run : IEEERoundingMode → Model fmt → Option (Model fmt))
    (mode : IEEERoundingMode) (expected : Model fmt → Model fmt) (first count : ℕ) : Bool :=
  (List.range count).all fun i =>
    let input : Model fmt := .ofNatBits (first + i)
    match run mode input with
    | some result => decide (SameValue result (expected input))
    | none => false

theorem checkRangeResult_eq_true_iff {expected : Model fmt → Model fmt} :
    checkRangeResult run mode expected first count = true ↔
      ∀ i < count, ∃ y, run mode (.ofNatBits (first + i)) = some y ∧
        SameValue y (expected (.ofNatBits (first + i))) := by
  simp only [checkRangeResult, List.all_eq_true, List.mem_range]
  refine forall₂_congr fun i _ => ?_
  cases run mode (.ofNatBits (first + i)) <;> simp

/-- If `expected` describes the prescribed results on a block and `run` produces them, then `run`
produces the prescribed result on each input of the block. -/
theorem holdsOnBits_of_checkRangeResult {expected : Model fmt → Model fmt}
    (hexpected : HoldsOnBits (fun x => SameValue (expected x) (S.eval mode x))
      first (first + count))
    (h : checkRangeResult run mode expected first count = true) :
    HoldsOnBits (RunsCorrectlyAt S run mode) first (first + count) :=
  HoldsOnBits.iff_forall_lt.2 fun i hi =>
    let ⟨y, hy, hsame⟩ := checkRangeResult_eq_true_iff.1 h i hi
    ⟨y, hy, hsame.trans (HoldsOnBits.iff_forall_lt.1 hexpected i hi)⟩

namespace IR.Func

variable {f : Func} {modes : Set IEEERoundingMode}

/-- `run` is a sound interpreter for the unary function `f`: whenever it produces a result, `f`
can return on that input, and everything `f` can return encodes that result. -/
def IsComputedBy (f : Func) (run : IEEERoundingMode → Model fmt → Option (Model fmt)) : Prop :=
  ∀ mode x y, run mode x = some y →
    (∃ r, f.Returns mode [.ofModel x] r) ∧ ∀ r, f.Returns mode [.ofModel x] r → r.Encodes y

/-- Under the rounding direction `mode`, the unary function `f` has a result on the input `x`, and
every result it can have is the one `S` prescribes. -/
def CorrectAt (f : Func) (S : Spec fmt) (mode : IEEERoundingMode) (x : Model fmt) : Prop :=
  (∃ r, f.Returns mode [.ofModel x] r) ∧
    ∀ r, f.Returns mode [.ofModel x] r → r.Encodes (S.eval mode x)

theorem correctlyRounded_iff_forall_correctAt :
    f.CorrectlyRounded S modes ↔ ∀ mode ∈ modes, ∀ x, f.CorrectAt S mode x :=
  Iff.rfl

namespace IsComputedBy

/-- A result of a sound interpreter that has the prescribed value makes `f` correct on that
input. -/
theorem correctAt_of_sameValue (hrun : f.IsComputedBy run) (hy : run mode x = some y)
    (h : SameValue y (S.eval mode x)) : f.CorrectAt S mode x :=
  let ⟨hex, hall⟩ := hrun mode x y hy
  ⟨hex, fun r hr => (hall r hr).of_sameValue h⟩

theorem correctAt (hrun : f.IsComputedBy run) (h : RunsCorrectlyAt S run mode x) :
    f.CorrectAt S mode x :=
  let ⟨_, hy, hsame⟩ := h
  hrun.correctAt_of_sameValue hy hsame

/-- Conversely, where `f` is correct, any result of a sound interpreter has the prescribed
value. -/
theorem sameValue_of_correctAt (hrun : f.IsComputedBy run) (h : f.CorrectAt S mode x)
    (hy : run mode x = some y) : SameValue y (S.eval mode x) :=
  let ⟨⟨r, hr⟩, hall⟩ := hrun mode x y hy
  (hall r hr).sameValue (h.2 r hr)

theorem holdsOnBits_correctAt (hrun : f.IsComputedBy run)
    (h : HoldsOnBits (RunsCorrectlyAt S run mode) lo hi) :
    HoldsOnBits (f.CorrectAt S mode) lo hi :=
  h.imp fun _ => hrun.correctAt

/-- A block checked against an oracle. -/
theorem holdsOnBits_of_checkRange (hrun : f.IsComputedBy run) {O : Oracle S}
    (h : checkRange O run mode first count = true) :
    HoldsOnBits (f.CorrectAt S mode) first (first + count) :=
  hrun.holdsOnBits_correctAt (LibcMath.holdsOnBits_of_checkRange h)

/-- Consecutive blocks checked against an oracle. -/
theorem holdsOnBits_of_checkBlocks (hrun : f.IsComputedBy run) {O : Oracle S} {bounds : List ℕ}
    (h : checkBlocks O run mode bounds = true) (hlo : lo ∈ bounds.head?)
    (hhi : hi ∈ bounds.getLast?) : HoldsOnBits (f.CorrectAt S mode) lo hi :=
  hrun.holdsOnBits_correctAt (LibcMath.holdsOnBits_of_checkBlocks h hlo hhi)

/-- A block on which the prescribed results are described by `expected`, checked without an
oracle. -/
theorem holdsOnBits_of_checkRangeResult (hrun : f.IsComputedBy run)
    {expected : Model fmt → Model fmt}
    (hexpected : HoldsOnBits (fun x => SameValue (expected x) (S.eval mode x))
      first (first + count))
    (h : checkRangeResult run mode expected first count = true) :
    HoldsOnBits (f.CorrectAt S mode) first (first + count) :=
  hrun.holdsOnBits_correctAt (LibcMath.holdsOnBits_of_checkRangeResult hexpected h)

end IsComputedBy

/-- A function that is correct on every bit pattern of the format, under each rounding direction
in `modes`, is correctly rounded. -/
theorem correctlyRounded_of_holdsOnBits
    (h : ∀ mode ∈ modes, HoldsOnBits (f.CorrectAt S mode) 0 (2 ^ fmt.bitWidth)) :
    f.CorrectlyRounded S modes :=
  fun mode hmode => (h mode hmode).forall

/-- Correct rounding by computation alone: for each rounding direction, a list of boundaries from
`0` to `2 ^ fmt.bitWidth` all of whose blocks pass `checkRange`. -/
theorem IsComputedBy.correctlyRounded_of_checkBlocks (hrun : f.IsComputedBy run) (O : Oracle S)
    (bounds : IEEERoundingMode → List ℕ)
    (h : ∀ mode ∈ modes, checkBlocks O run mode (bounds mode) = true ∧
      0 ∈ (bounds mode).head? ∧ 2 ^ fmt.bitWidth ∈ (bounds mode).getLast?) :
    f.CorrectlyRounded S modes :=
  correctlyRounded_of_holdsOnBits fun mode hmode =>
    let ⟨hcheck, hlo, hhi⟩ := h mode hmode
    hrun.holdsOnBits_of_checkBlocks hcheck hlo hhi

end IR.Func

end LibcMath
