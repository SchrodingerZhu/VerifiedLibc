import LibcMath.Extracted.Expf.Paths.Ranges
import LibcMath.Extracted.Expf.Polynomial
import LibcMath.Extracted.Expf.Statements

/-!
# `expf` is correctly rounded, with what is open stated as `sorry`

`expf_correctlyRounded` is the theorem `ExpfCorrectlyRounded` for the plan `double_eval`. Its
proof is complete except for two lemmas, which are stated here and end in `sorry`:

* `correctAt_main_pos`, the bit patterns `[0x32800001, 0x42B17218)`: `2⁻²⁶ < x < 88.72…`;
* `correctAt_main_neg`, the bit patterns `[0xB2800001, 0xC2CFF1B5)`: `-103.97… < x < -2⁻²⁶`.

These are the inputs for which the function reads its tables and evaluates its polynomial:
271 675 927 and 273 674 676 bit patterns, 12.70 % of all. Everything else, 87.30 %, is proved in
`Paths/Ranges.lean`.

The file also retains the conditional reductions of the other extracted evaluation plans
(`DoubleEvalFma`, `StaticRounding`, `IntegerEval`) from their proved short paths (87.30 % and
87.69 % of bit patterns) to their main polynomial ranges, together with
`expfIntegerEvalCorrectlyRounded_of_staticRounding`.

`#print axioms expf_correctlyRounded` lists `sorryAx` for as long as either lemma is open; the
check at the end of this file records it. Do not replace a `sorry` here by a hypothesis of the
theorem: an open obligation is to stay visible.

## What a proof of the two lemmas has to show

For an input `x` of these ranges and a rounding direction `mode`, with
`k = nearestInt (128 * x)`, `r = x - k / 128`, `hi = ⌊k / 128⌋` and `mid = k mod 128`:

1. **No undefined operation.** `k` converts to a 32-bit integer, `k + 13312` does not overflow,
   and both table indices are in bounds, so that the function returns `some y`. This needs
   `|k| ≤ 128 * 104`, from the bounds on `x`.
2. **The reduction is exact.** `r` is computed without error and `|r| ≤ 1 / 256`.
3. **The error of the value.** `y` is the rounding to binary32 of a binary64 number `v` with
   `|v - exp x| ≤ ε * exp x`. The parts of `ε` are the error of the polynomial against `exp r`
   (proved: `Poly.abs_poly_sub_exp_le`, at most `10⁻¹⁵`), the rounding of the eight binary64
   operations of the polynomial and of the two multiplications, and the error of the two table
   entries.
4. **The rounding.** Rounding `v` to binary32 in direction `mode` gives the same result as
   rounding `exp x`, because no rounding boundary of binary32 lies within `ε * exp x` of `exp x`.

Steps 1 to 3 are numerical analysis of the expression that `Expf.DoubleEval.expf` is. Step 4 is a
statement about how close `exp x` comes to a rounding boundary for a binary32 `x`; it does not
follow from an error bound alone. The journal tree `prob-48KJ` tracks all four.

The input `0xC236BD8C` is in `[0xB2800001, 0xC2CFF1B5)`. The function returns a constant
expression for it without reading a table, so the four steps above do not describe it;
`correctAt_main_neg` covers it as stated, and a proof will treat it by evaluation.
-/

namespace LibcMath.Extracted

namespace Expf

open FloatLib.Floats.Formats.BinaryInterchange
open Model (IEEERoundingMode)

variable {mode : IEEERoundingMode}

/-- **Open.** `Expf.DoubleEval.expf` is correct for `2⁻²⁶ < x < 88.72…`, the positive inputs that
reach its tables and its polynomial. The module docstring says what a proof has to show. -/
theorem correctAt_main_pos (hmode : mode ∈ cModes) :
    HoldsOnBits (CorrectAt (Spec.exp .binary32) Expf.DoubleEval.expf mode)
      0x32800001 0x42B17218 := by
  sorry

/-- **Open.** `Expf.DoubleEval.expf` is correct for `-103.97… < x < -2⁻²⁶`, the negative inputs
that reach its tables and its polynomial, and the one input `0xC236BD8C` among them that has a
branch of its own. The module docstring says what a proof has to show. -/
theorem correctAt_main_neg (hmode : mode ∈ cModes) :
    HoldsOnBits (CorrectAt (Spec.exp .binary32) Expf.DoubleEval.expf mode)
      0xB2800001 0xC2CFF1B5 := by
  sorry

end Expf

open FloatLib.Floats.Formats.BinaryInterchange
open Model (IEEERoundingMode)

/-- `math::double_eval::expf` is correctly rounded in the four rounding directions of C.

**The proof is not complete.** It uses `Expf.correctAt_main_pos` and `Expf.correctAt_main_neg`,
which end in `sorry`. -/
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

`sorryAx` is listed for as long as the two lemmas above are open. When they are proved, this
check fails and has to be updated; that is intended. -/

/--
info: 'LibcMath.Extracted.expf_correctlyRounded' depends on axioms: [propext, sorryAx, Classical.choice, Quot.sound]
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
