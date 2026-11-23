import LibcMath.Exhaustive.Reduction
import LibcMath.Functions
import LibcMath.Exhaustive.Run.Block
import LibcMath.Extracted.ExpfStructured

/-!
# Checking `expf` block by block on its structured form

`checkBlockMain` is `Exhaustive.checkBlock` with `expfStructured` in place of the interpreter, so
that a block of inputs is checked without executing the instructions of the extracted function
one by one. `holdsOnBits_of_checkBlockMain` transfers a successful check to the interpreter for a
block inside one of the two ranges on which `expf` evaluates its polynomial. It takes the
equality of the two functions on those ranges as a hypothesis.
-/

namespace LibcMath.Extracted

open FloatLib.Floats.Formats.BinaryInterchange
open Model (IEEERoundingMode)

/-- The bit patterns of the arguments for which `expf` evaluates its polynomial, and of the
argument `0xC236BD8C` among them. -/
def InExpfMainRanges (n : ℕ) : Prop :=
  (0x32800001 ≤ n ∧ n < 0x42B20000) ∨ (0xB2800001 ≤ n ∧ n < 0xC2CFF1B5)

/-- `expfStructured` produces a result accepted by `check` on each of the `count` bit patterns
starting at `first`. -/
def checkBlockMain (check : IEEERoundingMode → (input result : Model .binary32) → Bool)
    (mode : IEEERoundingMode) (first count : ℕ) : Bool :=
  Exhaustive.checkBlock check expfStructured mode first count

/-- A block inside one of the two main ranges that `checkBlockMain` accepts: the interpreter
returns the correctly rounded exponential on each of its inputs, provided the interpreter agrees
with `expfStructured` on the two ranges. -/
theorem holdsOnBits_of_checkBlockMain {O : Oracle (Spec.exp .binary32)} {mode : IEEERoundingMode}
    {first count : ℕ}
    (heq : ∀ b : BitVec 32, InExpfMainRanges b.toNat →
      expf.runUnary mode (Model.ofBits b : Model .binary32) = expfStructured mode (.ofBits b))
    (hrange : (0x32800001 ≤ first ∧ first + count ≤ 0x42B20000) ∨
      (0xB2800001 ≤ first ∧ first + count ≤ 0xC2CFF1B5))
    (h : checkBlockMain O.check mode first count = true) :
    HoldsOnBits (RunsCorrectlyAt (Spec.exp .binary32) expf.runUnary mode) first
      (first + count) := by
  refine HoldsOnBits.iff_forall_lt.2 fun i hi => ?_
  obtain ⟨y, hy, hcheck⟩ := checkRange_eq_true_iff.1 (Exhaustive.checkRange_of_checkBlock h) i hi
  have hmod : (BitVec.ofNat 32 (first + i)).toNat = first + i := by
    rw [BitVec.toNat_ofNat]
    rcases hrange with h | h <;> omega
  have hrun := heq (BitVec.ofNat 32 (first + i)) (by
    rw [hmod]
    unfold InExpfMainRanges
    rcases hrange with h | h <;> omega)
  exact ⟨y, hrun.trans hy, O.sound _ _ _ hcheck⟩

end LibcMath.Extracted
