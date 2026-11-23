import LibcMath.Exhaustive.ExpfInterp
import LibcMath.Extracted.ExpfPaths.Ranges

/-!
# Correct rounding of `expf`, up to its main computation

The extracted `expf` evaluates a polynomial and two table entries on the arguments whose bit
patterns lie in `[0x32800001, 0x42B20000)` or `[0xB2800001, 0xC2CFF1B5)`; every other argument
takes a short path whose result is proved for whole ranges in `ExpfPaths`. This file reduces the
correct rounding of `expf` to those two ranges: if the interpreter returns the correctly rounded
exponential on every bit pattern in them, under each rounding direction of C, then `expf` is
correctly rounded.

What is left is a finite computation over `545 386 931` arguments per direction.
-/

namespace LibcMath.Extracted

open FloatLib.Floats.Formats.BinaryInterchange
open Model (IEEERoundingMode)

/-- Under `mode`, the interpreter returns the correctly rounded exponential on every argument for
which `expf` evaluates its polynomial. -/
def ExpfMainRangesChecked (mode : IEEERoundingMode) : Prop :=
  HoldsOnBits (RunsCorrectlyAt (Spec.exp .binary32) expf.runUnary mode) 0x32800001 0x42B20000 ∧
  HoldsOnBits (RunsCorrectlyAt (Spec.exp .binary32) expf.runUnary mode) 0xB2800001 0xC2CFF1B5

/-- `expf` is correctly rounded in the four rounding directions of C, provided it is on the
arguments for which it evaluates its polynomial. -/
theorem expfCorrectlyRounded_of_mainRanges (h : ∀ mode ∈ cModes, ExpfMainRangesChecked mode) :
    ExpfCorrectlyRounded := by
  have all : ∀ mode ∈ cModes,
      HoldsOnBits (RunsCorrectlyAt (Spec.exp .binary32) expf.runUnary mode) 0 (2 ^ 32) := by
    intro mode hmode
    obtain ⟨low, middle, high⟩ := ExpfPaths.holdsOnBits_short_paths hmode
    obtain ⟨positive, negative⟩ := h mode hmode
    exact (((low.append positive).append middle).append negative).append high
  exact expfCorrectlyRounded_of_runsCorrectly expf_isComputedBy
    (all _ (by simp [cModes])) (all _ (by simp [cModes])) (all _ (by simp [cModes]))
    (all _ (by simp [cModes]))

end LibcMath.Extracted
