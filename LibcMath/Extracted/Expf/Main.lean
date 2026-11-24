import LibcMath.Extracted.Expf.Exhaustive
import LibcMath.Extracted.Expf.Paths.Ranges

/-!
# Correct rounding of extracted `expf` kernels, up to their main computation

Every extracted `expf` plan evaluates a polynomial on two bounded finite intervals and handles
every remaining bit pattern on a short path whose correctness is proved for whole ranges in
`LibcMath/Extracted/Expf/Paths/Ranges.lean`.

Because `ast2lean` extracts high-level functional Lean models directly over `LibcMath.Core`, this
file reduces `CorrectlyRounded` directly to those two main intervals with **zero** interpreter
indirection and **zero** structured-form bridge hypotheses:

* `Expf.DoubleEval.expf` & `Expf.DoubleEvalFma.expf`:
  `[0x32800001, 0x42B17218)` and `[0xB2800001, 0xC2CFF1B5)` — `545 350 603` inputs per C mode
  (87.30 % already discharged analytically).
* `Expf.StaticRounding.kernel` (4 C modes) & `Expf.IntegerEval.kernel` (`.nearest`):
  `[0x33000000, 0x42B17218)` and `[0xB3000000, 0xC2CFF1B5)` — `528 573 389` inputs per mode
  (87.69 % already discharged analytically).
-/

namespace LibcMath.Extracted

open FloatLib.Floats.Formats.BinaryInterchange
open Model (IEEERoundingMode)

/-- Under `mode`, `Expf.DoubleEval.expf` returns the correctly rounded exponential on both main
polynomial ranges (`545 350 603` inputs). -/
def ExpfMainRangesChecked (mode : IEEERoundingMode) : Prop :=
  HoldsOnBits (CorrectAt (Spec.exp .binary32) Expf.DoubleEval.expf mode) 0x32800001 0x42B17218 ∧
  HoldsOnBits (CorrectAt (Spec.exp .binary32) Expf.DoubleEval.expf mode) 0xB2800001 0xC2CFF1B5

/-- `Expf.DoubleEval.expf` is correctly rounded in all four C rounding directions, provided it is on
its two polynomial ranges. -/
theorem expfCorrectlyRounded_of_mainRanges (h : ∀ mode ∈ cModes, ExpfMainRangesChecked mode) :
    ExpfCorrectlyRounded := by
  refine correctlyRounded_of_holdsOnBits fun mode hmode => ?_
  obtain ⟨low, middle, high⟩ := Expf.Paths.holdsOnBits_short_paths hmode
  obtain ⟨positive, negative⟩ := h mode hmode
  exact (((low.append positive).append middle).append negative).append high

/-- Under `mode`, `Expf.DoubleEvalFma.expf` is correct on both main polynomial ranges. -/
def ExpfFmaMainRangesChecked (mode : IEEERoundingMode) : Prop :=
  HoldsOnBits (CorrectAt (Spec.exp .binary32) Expf.DoubleEvalFma.expf mode) 0x32800001 0x42B17218 ∧
  HoldsOnBits (CorrectAt (Spec.exp .binary32) Expf.DoubleEvalFma.expf mode) 0xB2800001 0xC2CFF1B5

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
  HoldsOnBits (CorrectAt (Spec.exp .binary32) Expf.StaticRounding.kernel mode) 0xB3000000 0xC2CFF1B5

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
  rw [Expf.Paths.integerEval_eq_staticRounding_nearest]
  exact h .nearest (by simp [cModes]) x

/-! ### Axiom guards -/

/--
info: 'LibcMath.Extracted.expfCorrectlyRounded_of_mainRanges' depends on axioms: [propext, Classical.choice, Quot.sound]
-/
#guard_msgs in
#print axioms expfCorrectlyRounded_of_mainRanges

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

end LibcMath.Extracted
