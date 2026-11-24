import LibcMath.Expf.Examples
import LibcMath.Expf.MainPath.PointwiseExceptions
import LibcMath.Expf.MainPath.Polynomial
import LibcMath.Expf.MainPath.ProductError
import LibcMath.Expf.MainPath.Tmd.Main
import LibcMath.Expf.Plans
import LibcMath.Expf.ShortPaths.Ranges
import LibcMath.Expf.Statement

/-!
# `expf` is correctly rounded

Entry point for the verification of LLVM libc `expf` (`LibcMath/Expf/`).

`expf_correctlyRounded` proves `ExpfCorrectlyRounded` for the default plan `double_eval` across all
`2³²` binary32 inputs and all four C rounding directions (`cModes`), with no `sorry` and only the
three standard Lean axioms (`[propext, Classical.choice, Quot.sound]`):

* `Expf/ShortPaths/Ranges.lean` proves the short paths (`3 749 616 693` bit patterns, `87.30 %`).
* `correctAt_main_pos` closes `[0x32800001, 0x42B17218)` (`271 675 927` bit patterns, `6.33 %`)
  by combining `MainPath.ProductError.holdsOnBits_tiny_pos_main` (`[0x32800001, 0x33800000)`) with
  `MainPath.Tmd.Main.holdsOnBits_tmd_pos` (`[0x33800000, 0x42B17218)`).
* `correctAt_main_neg` closes `[0xB2800001, 0xC2CFF1B5)` (`273 674 676` bit patterns, `6.37 %`)
  by combining `MainPath.ProductError.holdsOnBits_tiny_neg_main` (`[0xB2800001, 0xB3000000)`),
  `MainPath.PointwiseExceptions.correctAt_0xB3000000` (`0xB3000000`),
  `MainPath.Tmd.Main.holdsOnBits_tmd_neg` (`[0xB3000001, 0xC2CE8ED0)`), and
  `MainPath.ProductError.holdsOnBits_near_underflow_main` (`[0xC2CE8ED0, 0xC2CFF1B5)`).

## Analytical decomposition of the main path (`Expf/MainPath/`)

1. **UB-freedom & exact range reduction (`RangeReduction.lean`)**: builds on
   `LibcMath/Analysis/RangeReduction.lean` to show `k = nearestInt (128 * x)` is an exact integer,
   `r = submul(x, kf, 1/128) = x - k / 128` has zero rounding error with `|r| ≤ 1 / 256` outside
   the two isolated directed-rounding boundary inputs `0x3B7FFFFF` and `0xBB7FFFFF`, `fptosi?`,
   `sadd?`, and both table indices stay in bounds, and `r` widens to binary64 exactly.
2. **Value error (`Polynomial.lean`, `HornerError.lean`, `TableBounds.lean`, `ProductError.lean`)**:
   builds on `LibcMath/Analysis/Horner.lean` to prove the binary64 result
   `v = (EXP_M1[hi] * EXP_M2[mid]) * horner(xd)` is finite, positive, below
   `posMaxFinite .binary32`, and satisfies `|v - exp x| ≤ (2 / 10¹⁵) * exp x` across all four C
   rounding modes.
3. **Rounding transfer & TMD (`Analysis/RoundingTransfer.lean`, `Analysis/ChebTmd.lean`,
   `PointwiseExceptions.lean`, `Tmd/`)**: `25 256 675` tiny and near-underflow inputs are closed
   analytically; the remaining `520 093 927` inputs are certified by `278 619` always-odd
   Chebyshev-L1 SLZ certificates checked in Lean's kernel (`decide +kernel`) together with `103`
   pointwise inputs (including `0xC236BD8C`, `0x3B7FFFFF`, `0xBB7FFFFF`, `0xB3000000`, and all
   hard-to-round points).

This file also keeps the conditional reductions of the other extracted evaluation plans
(`DoubleEvalFma`, `StaticRounding`, `IntegerEval`) from their proved short paths (`87.30 %` and
`87.69 %` of bit patterns) to their main polynomial ranges, together with
`expfIntegerEvalCorrectlyRounded_of_staticRounding`.
-/

namespace LibcMath.Expf

open FloatLib.Floats.Formats.BinaryInterchange
open Model (IEEERoundingMode)

variable {mode : IEEERoundingMode}

/-- `Generated.DoubleEval.expf` is correctly rounded on `[0x32800001, 0x42B17218)`
(`2⁻²⁶ < x < 88.72…`) in every C rounding mode. -/
theorem correctAt_main_pos (hmode : mode ∈ cModes) :
    HoldsOnBits (CorrectAt (Spec.exp .binary32) Generated.DoubleEval.expf mode)
      0x32800001 0x42B17218 :=
  (MainPath.ProductError.holdsOnBits_tiny_pos_main hmode).append
    (MainPath.Tmd.Main.holdsOnBits_tmd_pos hmode)

/-- `Generated.DoubleEval.expf` is correctly rounded on `[0xB2800001, 0xC2CFF1B5)`
(`-103.97… < x < -2⁻²⁶`, including the special input `0xC236BD8C`) in every C rounding mode. -/
theorem correctAt_main_neg (hmode : mode ∈ cModes) :
    HoldsOnBits (CorrectAt (Spec.exp .binary32) Generated.DoubleEval.expf mode)
      0xB2800001 0xC2CFF1B5 :=
  (((MainPath.ProductError.holdsOnBits_tiny_neg_main hmode).append
    (HoldsOnBits.singleton (MainPath.PointwiseExceptions.correctAt_0xB3000000 hmode))).append
    (MainPath.Tmd.Main.holdsOnBits_tmd_neg hmode)).append
    (MainPath.ProductError.holdsOnBits_near_underflow_main hmode)

/-- `math::double_eval::expf` is correctly rounded in all four rounding directions of C and never
reaches an undefined operation. -/
theorem expf_correctlyRounded : ExpfCorrectlyRounded := by
  refine correctlyRounded_of_holdsOnBits fun mode hmode => ?_
  obtain ⟨low, middle, high⟩ := ShortPaths.holdsOnBits_short_paths hmode
  exact (((low.append (correctAt_main_pos hmode)).append middle).append
    (correctAt_main_neg hmode)).append high

/-! ### Other evaluation plans (short paths proved, main ranges conditional) -/

/-- Under `mode`, `Generated.DoubleEvalFma.expf` is correct on both main polynomial ranges. -/
def ExpfFmaMainRangesChecked (mode : IEEERoundingMode) : Prop :=
  HoldsOnBits (CorrectAt (Spec.exp .binary32) Generated.DoubleEvalFma.expf mode)
    0x32800001 0x42B17218 ∧
  HoldsOnBits (CorrectAt (Spec.exp .binary32) Generated.DoubleEvalFma.expf mode)
    0xB2800001 0xC2CFF1B5

/-- `Generated.DoubleEvalFma.expf` is correctly rounded in all four C rounding directions, provided
it is on its two polynomial ranges. -/
theorem expfDoubleEvalFmaCorrectlyRounded_of_mainRanges
    (h : ∀ mode ∈ cModes, ExpfFmaMainRangesChecked mode) :
    ExpfDoubleEvalFmaCorrectlyRounded := by
  refine correctlyRounded_of_holdsOnBits fun mode hmode => ?_
  obtain ⟨low, middle, high⟩ := ShortPaths.holdsOnBits_short_paths_fma hmode
  obtain ⟨positive, negative⟩ := h mode hmode
  exact (((low.append positive).append middle).append negative).append high

/-- Under `mode`, the pure-integer kernel `Generated.StaticRounding.kernel` is correct on both main
polynomial ranges (`528 573 389` inputs). -/
def ExpfStaticRoundingMainRangesChecked (mode : IEEERoundingMode) : Prop :=
  HoldsOnBits (CorrectAt (Spec.exp .binary32) Generated.StaticRounding.kernel mode)
    0x33000000 0x42B17218 ∧
  HoldsOnBits (CorrectAt (Spec.exp .binary32) Generated.StaticRounding.kernel mode)
    0xB3000000 0xC2CFF1B5

/-- `Generated.StaticRounding.kernel` is correctly rounded in all four C rounding directions,
provided it is on its two polynomial ranges. -/
theorem expfStaticRoundingCorrectlyRounded_of_mainRanges
    (h : ∀ mode ∈ cModes, ExpfStaticRoundingMainRangesChecked mode) :
    ExpfStaticRoundingCorrectlyRounded := by
  refine correctlyRounded_of_holdsOnBits fun mode hmode => ?_
  obtain ⟨low, middle, high⟩ := ShortPaths.holdsOnBits_short_paths_staticRounding hmode
  obtain ⟨positive, negative⟩ := h mode hmode
  exact (((low.append positive).append middle).append negative).append high

/-- `Generated.IntegerEval.kernel` is correctly rounded in `.nearest` mode, provided it is on its
two polynomial ranges (`528 573 389` inputs). -/
theorem expfIntegerEvalCorrectlyRounded_of_mainRanges
    (hpos : HoldsOnBits (CorrectAt (Spec.exp .binary32) Generated.IntegerEval.kernel .nearest)
      0x33000000 0x42B17218)
    (hneg : HoldsOnBits (CorrectAt (Spec.exp .binary32) Generated.IntegerEval.kernel .nearest)
      0xB3000000 0xC2CFF1B5) :
    ExpfIntegerEvalCorrectlyRounded := by
  refine correctlyRounded_of_holdsOnBits fun mode hmode => ?_
  rcases hmode with rfl
  obtain ⟨low, middle, high⟩ := ShortPaths.holdsOnBits_short_paths_integerEval
  exact (((low.append hpos).append middle).append hneg).append high

/-- `ExpfStaticRoundingCorrectlyRounded` immediately implies `ExpfIntegerEvalCorrectlyRounded`. -/
theorem expfIntegerEvalCorrectlyRounded_of_staticRounding
    (h : ExpfStaticRoundingCorrectlyRounded) :
    ExpfIntegerEvalCorrectlyRounded := by
  intro mode hmode x
  rcases hmode with rfl
  obtain ⟨y, hy, hsame⟩ := h .nearest (by simp [cModes]) x
  exact ⟨y, by rw [ShortPaths.integerEval_eq_staticRounding_nearest]; exact hy, hsame⟩

/-! ### Axioms

`expf_correctlyRounded` depends solely on the three standard Lean axioms (`propext`,
`Classical.choice`, `Quot.sound`) — no `sorryAx`, no `Lean.ofReduceBool`, no oracle axioms. -/

/--
info: 'LibcMath.Expf.expf_correctlyRounded' depends on axioms: [propext, Classical.choice, Quot.sound]
-/
#guard_msgs in
#print axioms expf_correctlyRounded

/-- Short-paths theorem for `double_eval`. -/
theorem expf_correct_on_short_paths {mode : IEEERoundingMode} (hmode : mode ∈ cModes) :
    HoldsOnBits (CorrectAt (Spec.exp .binary32) Generated.DoubleEval.expf mode)
      0x00000000 0x32800001 ∧
    HoldsOnBits (CorrectAt (Spec.exp .binary32) Generated.DoubleEval.expf mode)
      0x42B17218 0xB2800001 ∧
    HoldsOnBits (CorrectAt (Spec.exp .binary32) Generated.DoubleEval.expf mode)
      0xC2CFF1B5 0x100000000 :=
  ShortPaths.holdsOnBits_short_paths hmode

/--
info: 'LibcMath.Expf.expf_correct_on_short_paths' depends on axioms: [propext, Classical.choice, Quot.sound]
-/
#guard_msgs in
#print axioms expf_correct_on_short_paths

/--
info: 'LibcMath.Expf.expfDoubleEvalFmaCorrectlyRounded_of_mainRanges' depends on axioms: [propext,
 Classical.choice,
 Quot.sound]
-/
#guard_msgs in
#print axioms expfDoubleEvalFmaCorrectlyRounded_of_mainRanges

/--
info: 'LibcMath.Expf.expfStaticRoundingCorrectlyRounded_of_mainRanges' depends on axioms: [propext,
 Classical.choice,
 Quot.sound]
-/
#guard_msgs in
#print axioms expfStaticRoundingCorrectlyRounded_of_mainRanges

/--
info: 'LibcMath.Expf.expfIntegerEvalCorrectlyRounded_of_mainRanges' depends on axioms: [propext, Classical.choice, Quot.sound]
-/
#guard_msgs in
#print axioms expfIntegerEvalCorrectlyRounded_of_mainRanges

/--
info: 'LibcMath.Expf.expfIntegerEvalCorrectlyRounded_of_staticRounding' depends on axioms: [propext,
 Classical.choice,
 Quot.sound]
-/
#guard_msgs in
#print axioms expfIntegerEvalCorrectlyRounded_of_staticRounding

end LibcMath.Expf
