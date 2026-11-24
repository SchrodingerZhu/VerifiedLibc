import LibcMath.Extracted.Expf.Paths.Ranges
import LibcMath.Extracted.Expf.PointwiseExceptions
import LibcMath.Extracted.Expf.Polynomial
import LibcMath.Extracted.Expf.ProductError
import LibcMath.Extracted.Expf.Statements
import LibcMath.Extracted.Expf.Tmd.Main

/-!
# `expf` is correctly rounded

`expf_correctlyRounded` proves `ExpfCorrectlyRounded` for the default plan `double_eval` across all
`2³²` binary32 inputs and all four C rounding directions (`cModes`), with no `sorry` and only the
three standard Lean axioms (`[propext, Classical.choice, Quot.sound]`):

* `Paths/Ranges.lean` proves the short paths (`3 749 616 693` bit patterns, `87.30 %`).
* `correctAt_main_pos` closes `[0x32800001, 0x42B17218)` (`271 675 927` bit patterns, `6.33 %`)
  by combining `ProductError.holdsOnBits_tiny_pos_main` (`[0x32800001, 0x33800000)`) with
  `Tmd.Main.holdsOnBits_tmd_pos` (`[0x33800000, 0x42B17218)`).
* `correctAt_main_neg` closes `[0xB2800001, 0xC2CFF1B5)` (`273 674 676` bit patterns, `6.37 %`)
  by combining `ProductError.holdsOnBits_tiny_neg_main` (`[0xB2800001, 0xB3000000)`),
  `PointwiseExceptions.correctAt_0xB3000000` (`0xB3000000`),
  `Tmd.Main.holdsOnBits_tmd_neg` (`[0xB3000001, 0xC2CE8ED0)`), and
  `ProductError.holdsOnBits_near_underflow_main` (`[0xC2CE8ED0, 0xC2CFF1B5)`).

## Analytical decomposition of the main path

1. **UB-freedom & exact range reduction (`RangeReduction.lean`)**: `k = nearestInt (128 * x)` is an
   exact integer, `r = submul(x, kf, 1/128) = x - k / 128` has zero rounding error with
   `|r| ≤ 1 / 256` outside the two isolated directed-rounding boundary inputs `0x3B7FFFFF` and
   `0xBB7FFFFF`, `fptosi?`, `sadd?`, and both table indices stay in bounds, and `r` widens to
   binary64 exactly.
2. **Value error (`Polynomial.lean`, `HornerError.lean`, `TableBounds.lean`, `ProductError.lean`)**:
   the binary64 result `v = (EXP_M1[hi] * EXP_M2[mid]) * horner(xd)` is finite, positive, below
   `posMaxFinite .binary32`, and satisfies `|v - exp x| ≤ (2 / 10¹⁵) * exp x` across all four C
   rounding modes.
3. **Rounding transfer & TMD (`RoundingTransfer.lean`, `PointwiseExceptions.lean`, `Tmd/`)**:
   `25 256 675` tiny and near-underflow inputs are closed analytically; the remaining `520 093 927`
   inputs are certified by `278 619` always-odd Chebyshev-L1 SLZ certificates checked in Lean's
   kernel (`decide +kernel`) together with `103` pointwise inputs (including `0xC236BD8C`,
   `0x3B7FFFFF`, `0xBB7FFFFF`, `0xB3000000`, and all hard-to-round points).

The file also retains the conditional reductions of the other extracted evaluation plans
(`DoubleEvalFma`, `StaticRounding`, `IntegerEval`) from their proved short paths (`87.30 %` and
`87.69 %` of bit patterns) to their main polynomial ranges, together with
`expfIntegerEvalCorrectlyRounded_of_staticRounding`.
-/

namespace LibcMath.Extracted

namespace Expf

open FloatLib.Floats.Formats.BinaryInterchange
open Model (IEEERoundingMode)

variable {mode : IEEERoundingMode}

/-- `Expf.DoubleEval.expf` is correctly rounded on `[0x32800001, 0x42B17218)` (`2⁻²⁶ < x < 88.72…`)
in every C rounding mode. -/
theorem correctAt_main_pos (hmode : mode ∈ cModes) :
    HoldsOnBits (CorrectAt (Spec.exp .binary32) Expf.DoubleEval.expf mode)
      0x32800001 0x42B17218 :=
  (ProductError.holdsOnBits_tiny_pos_main hmode).append (Tmd.Main.holdsOnBits_tmd_pos hmode)

/-- `Expf.DoubleEval.expf` is correctly rounded on `[0xB2800001, 0xC2CFF1B5)`
(`-103.97… < x < -2⁻²⁶`, including the special input `0xC236BD8C`) in every C rounding mode. -/
theorem correctAt_main_neg (hmode : mode ∈ cModes) :
    HoldsOnBits (CorrectAt (Spec.exp .binary32) Expf.DoubleEval.expf mode)
      0xB2800001 0xC2CFF1B5 :=
  (((ProductError.holdsOnBits_tiny_neg_main hmode).append
    (HoldsOnBits.singleton (PointwiseExceptions.correctAt_0xB3000000 hmode))).append
    (Tmd.Main.holdsOnBits_tmd_neg hmode)).append
    (ProductError.holdsOnBits_near_underflow_main hmode)

end Expf

open FloatLib.Floats.Formats.BinaryInterchange
open Model (IEEERoundingMode)

/-- `math::double_eval::expf` is correctly rounded in all four rounding directions of C and never
reaches an undefined operation. -/
theorem expf_correctlyRounded : ExpfCorrectlyRounded := by
  refine correctlyRounded_of_holdsOnBits fun mode hmode => ?_
  obtain ⟨low, middle, high⟩ := Expf.Paths.holdsOnBits_short_paths hmode
  exact (((low.append (Expf.correctAt_main_pos hmode)).append middle).append
    (Expf.correctAt_main_neg hmode)).append high

/-! ### Other evaluation plans (short paths proved, main ranges conditional) -/

/-- Under `mode`, `Expf.DoubleEvalFma.expf` is correct on both main polynomial ranges. -/
def ExpfFmaMainRangesChecked (mode : IEEERoundingMode) : Prop :=
  HoldsOnBits (CorrectAt (Spec.exp .binary32) Expf.DoubleEvalFma.expf mode)
    0x32800001 0x42B17218 ∧
  HoldsOnBits (CorrectAt (Spec.exp .binary32) Expf.DoubleEvalFma.expf mode)
    0xB2800001 0xC2CFF1B5

/-- `Expf.DoubleEvalFma.expf` is correctly rounded in all four C rounding directions, provided it is
on its two polynomial ranges. -/
theorem expfDoubleEvalFmaCorrectlyRounded_of_mainRanges
    (h : ∀ mode ∈ cModes, ExpfFmaMainRangesChecked mode) :
    ExpfDoubleEvalFmaCorrectlyRounded := by
  refine correctlyRounded_of_holdsOnBits fun mode hmode => ?_
  obtain ⟨low, middle, high⟩ := Expf.Paths.holdsOnBits_short_paths_fma hmode
  obtain ⟨positive, negative⟩ := h mode hmode
  exact (((low.append positive).append middle).append negative).append high

/-- Under `mode`, the pure-integer kernel `Expf.StaticRounding.kernel` is correct on both main
polynomial ranges (`528 573 389` inputs). -/
def ExpfStaticRoundingMainRangesChecked (mode : IEEERoundingMode) : Prop :=
  HoldsOnBits (CorrectAt (Spec.exp .binary32) Expf.StaticRounding.kernel mode)
    0x33000000 0x42B17218 ∧
  HoldsOnBits (CorrectAt (Spec.exp .binary32) Expf.StaticRounding.kernel mode)
    0xB3000000 0xC2CFF1B5

/-- `Expf.StaticRounding.kernel` is correctly rounded in all four C rounding directions, provided it
is on its two polynomial ranges. -/
theorem expfStaticRoundingCorrectlyRounded_of_mainRanges
    (h : ∀ mode ∈ cModes, ExpfStaticRoundingMainRangesChecked mode) :
    ExpfStaticRoundingCorrectlyRounded := by
  refine correctlyRounded_of_holdsOnBits fun mode hmode => ?_
  obtain ⟨low, middle, high⟩ := Expf.Paths.holdsOnBits_short_paths_staticRounding hmode
  obtain ⟨positive, negative⟩ := h mode hmode
  exact (((low.append positive).append middle).append negative).append high

/-- `Expf.IntegerEval.kernel` is correctly rounded in `.nearest` mode, provided it is on its two
polynomial ranges (`528 573 389` inputs). -/
theorem expfIntegerEvalCorrectlyRounded_of_mainRanges
    (hpos : HoldsOnBits (CorrectAt (Spec.exp .binary32) Expf.IntegerEval.kernel .nearest)
      0x33000000 0x42B17218)
    (hneg : HoldsOnBits (CorrectAt (Spec.exp .binary32) Expf.IntegerEval.kernel .nearest)
      0xB3000000 0xC2CFF1B5) :
    ExpfIntegerEvalCorrectlyRounded := by
  refine correctlyRounded_of_holdsOnBits fun mode hmode => ?_
  rcases hmode with rfl
  obtain ⟨low, middle, high⟩ := Expf.Paths.holdsOnBits_short_paths_integerEval
  exact (((low.append hpos).append middle).append hneg).append high

/-- `ExpfStaticRoundingCorrectlyRounded` immediately implies `ExpfIntegerEvalCorrectlyRounded`. -/
theorem expfIntegerEvalCorrectlyRounded_of_staticRounding
    (h : ExpfStaticRoundingCorrectlyRounded) :
    ExpfIntegerEvalCorrectlyRounded := by
  intro mode hmode x
  rcases hmode with rfl
  obtain ⟨y, hy, hsame⟩ := h .nearest (by simp [cModes]) x
  exact ⟨y, by rw [Expf.Paths.integerEval_eq_staticRounding_nearest]; exact hy, hsame⟩

/-! ### Axioms

`expf_correctlyRounded` depends solely on the three standard Lean axioms (`propext`,
`Classical.choice`, `Quot.sound`) — no `sorryAx`, no `Lean.ofReduceBool`, no oracle axioms. -/

/--
info: 'LibcMath.Extracted.expf_correctlyRounded' depends on axioms: [propext, Classical.choice, Quot.sound]
-/
#guard_msgs in
#print axioms expf_correctlyRounded

/-- What is proved without `sorry`: the short paths of `double_eval`. -/
theorem expf_correct_on_short_paths {mode : IEEERoundingMode} (hmode : mode ∈ cModes) :
    HoldsOnBits (CorrectAt (Spec.exp .binary32) Expf.DoubleEval.expf mode) 0x00000000 0x32800001 ∧
    HoldsOnBits (CorrectAt (Spec.exp .binary32) Expf.DoubleEval.expf mode) 0x42B17218 0xB2800001 ∧
    HoldsOnBits (CorrectAt (Spec.exp .binary32) Expf.DoubleEval.expf mode)
      0xC2CFF1B5 0x100000000 :=
  Expf.Paths.holdsOnBits_short_paths hmode

/--
info: 'LibcMath.Extracted.expf_correct_on_short_paths' depends on axioms: [propext, Classical.choice, Quot.sound]
-/
#guard_msgs in
#print axioms expf_correct_on_short_paths

/--
info: 'LibcMath.Extracted.expfDoubleEvalFmaCorrectlyRounded_of_mainRanges' depends on axioms: [propext,
 Classical.choice,
 Quot.sound]
-/
#guard_msgs in
#print axioms expfDoubleEvalFmaCorrectlyRounded_of_mainRanges

/--
info: 'LibcMath.Extracted.expfStaticRoundingCorrectlyRounded_of_mainRanges' depends on axioms: [propext,
 Classical.choice,
 Quot.sound]
-/
#guard_msgs in
#print axioms expfStaticRoundingCorrectlyRounded_of_mainRanges

/--
info: 'LibcMath.Extracted.expfIntegerEvalCorrectlyRounded_of_mainRanges' depends on axioms: [propext,
 Classical.choice,
 Quot.sound]
-/
#guard_msgs in
#print axioms expfIntegerEvalCorrectlyRounded_of_mainRanges

/--
info: 'LibcMath.Extracted.expfIntegerEvalCorrectlyRounded_of_staticRounding' depends on axioms: [propext,
 Classical.choice,
 Quot.sound]
-/
#guard_msgs in
#print axioms expfIntegerEvalCorrectlyRounded_of_staticRounding

end LibcMath.Extracted
