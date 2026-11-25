import LibcMath.Kernels.Expf.Proof.DoubleEval.MainPath.PointwiseExceptions
import LibcMath.Kernels.Expf.Proof.DoubleEval.MainPath.Polynomial
import LibcMath.Kernels.Expf.Proof.DoubleEval.MainPath.ProductError
import LibcMath.Kernels.Expf.Proof.DoubleEval.MainPath.Tmd.Main
import LibcMath.Kernels.Expf.Proof.DoubleEval.ShortPaths.Ranges
import LibcMath.Kernels.Expf.Statement

/-!
# `math::double_eval::expf` is correctly rounded

**Complete.** `expfDoubleEval_correctlyRounded` proves `ExpfDoubleEvalCorrectlyRounded`
(x86-64 without FMA, `LIBC_MATH=0`) on all `2³²` binary32 inputs and the four rounding directions
of C, with no `sorry` and the three standard axioms.

* `ShortPaths/Ranges.lean`: `holdsOnBits_short_paths_doubleEval`, 3 749 616 693 bit patterns
  (87.30 %).
* `correctAt_doubleEval_main_pos`: `[0x32800001, 0x42B17218)`, 271 675 927 bit patterns (6.33 %),
  from `MainPath.ProductError.holdsOnBits_tiny_pos_main` and
  `MainPath.Tmd.Main.holdsOnBits_tmd_pos`.
* `correctAt_doubleEval_main_neg`: `[0xB2800001, 0xC2CFF1B5)`, 273 674 676 bit patterns (6.37 %),
  from `MainPath.ProductError.holdsOnBits_tiny_neg_main`,
  `MainPath.PointwiseExceptions.correctAt_0xB3000000`, `MainPath.Tmd.Main.holdsOnBits_tmd_neg` and
  `MainPath.ProductError.holdsOnBits_near_underflow_main`.

## The main path (`MainPath/`)

1. **No undefined operation, exact reduction (`RangeReduction.lean`).** `k = nearestInt (128 * x)`
   is an integer, `r = x - k / 128` is computed without error with `|r| ≤ 1 / 256`, except at the
   two inputs `0x3B7FFFFF` and `0xBB7FFFFF` under directed rounding; `fptosi?`, `sadd?` and both
   table reads succeed.
2. **Error of the value (`Polynomial.lean`, `HornerError.lean`, `TableBounds.lean`,
   `ProductError.lean`).** The binary64 result `v` is finite, positive, below the largest binary32
   value, and `|v - exp x| ≤ (2 / 10¹⁵) * exp x`.
3. **Rounding (`PointwiseExceptions.lean`, `Tmd/`).** 25 256 675 inputs are closed by the error
   bound alone; 520 093 927 by 278 619 certificates that `exp x` is not near a rounding boundary,
   checked by `decide +kernel`; 103 inputs one by one.
-/

namespace LibcMath.Kernels.Expf.Proof.DoubleEval

open FloatLib.Floats.Formats.BinaryInterchange
open Model (IEEERoundingMode)

variable {mode : IEEERoundingMode}

/-- `Generated.DoubleEval.expf` is correctly rounded on `[0x32800001, 0x42B17218)`
(`2⁻²⁶ < x < 88.72…`) in every C rounding mode. -/
theorem correctAt_doubleEval_main_pos (hmode : mode ∈ cModes) :
    HoldsOnBits (CorrectAt (Spec.exp .binary32) Generated.DoubleEval.expf mode)
      0x32800001 0x42B17218 :=
  (MainPath.ProductError.holdsOnBits_tiny_pos_main hmode).append
    (MainPath.Tmd.Main.holdsOnBits_tmd_pos hmode)

/-- `Generated.DoubleEval.expf` is correctly rounded on `[0xB2800001, 0xC2CFF1B5)`
(`-103.97… < x < -2⁻²⁶`, including the special input `0xC236BD8C`) in every C rounding mode. -/
theorem correctAt_doubleEval_main_neg (hmode : mode ∈ cModes) :
    HoldsOnBits (CorrectAt (Spec.exp .binary32) Generated.DoubleEval.expf mode)
      0xB2800001 0xC2CFF1B5 :=
  (((MainPath.ProductError.holdsOnBits_tiny_neg_main hmode).append
    (HoldsOnBits.singleton (MainPath.PointwiseExceptions.correctAt_0xB3000000 hmode))).append
    (MainPath.Tmd.Main.holdsOnBits_tmd_neg hmode)).append
    (MainPath.ProductError.holdsOnBits_near_underflow_main hmode)

/-- `math::double_eval::expf` (non-FMA) is correctly rounded in all four rounding directions of C
and never reaches an undefined operation. -/
theorem expfDoubleEval_correctlyRounded : ExpfDoubleEvalCorrectlyRounded := by
  refine correctlyRounded_of_holdsOnBits fun mode hmode => ?_
  obtain ⟨low, middle, high⟩ := ShortPaths.holdsOnBits_short_paths_doubleEval hmode
  exact (((low.append (correctAt_doubleEval_main_pos hmode)).append middle).append
    (correctAt_doubleEval_main_neg hmode)).append high

/-- Short-paths theorem for `Generated.DoubleEval.expf`. -/
theorem expfDoubleEval_correct_on_short_paths {mode : IEEERoundingMode} (hmode : mode ∈ cModes) :
    HoldsOnBits (CorrectAt (Spec.exp .binary32) Generated.DoubleEval.expf mode)
      0x00000000 0x32800001 ∧
    HoldsOnBits (CorrectAt (Spec.exp .binary32) Generated.DoubleEval.expf mode)
      0x42B17218 0xB2800001 ∧
    HoldsOnBits (CorrectAt (Spec.exp .binary32) Generated.DoubleEval.expf mode)
      0xC2CFF1B5 0x100000000 :=
  ShortPaths.holdsOnBits_short_paths_doubleEval hmode

/--
info: 'LibcMath.Kernels.Expf.Proof.DoubleEval.expfDoubleEval_correctlyRounded' depends on axioms: [propext,
 Classical.choice,
 Quot.sound]
-/
#guard_msgs in
#print axioms expfDoubleEval_correctlyRounded

/--
info: 'LibcMath.Kernels.Expf.Proof.DoubleEval.expfDoubleEval_correct_on_short_paths' depends on axioms: [propext,
 Classical.choice,
 Quot.sound]
-/
#guard_msgs in
#print axioms expfDoubleEval_correct_on_short_paths

end LibcMath.Kernels.Expf.Proof.DoubleEval
