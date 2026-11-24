import LibcMath.Exhaustive.Reduction
import LibcMath.Extracted.ExpfPaths.Exec
import LibcMath.Functions.AddRounding
import LibcMath.Functions.AddSpecial
import LibcMath.Functions.ExpRanges

/-!
# Extracted `expf` kernels on their short paths

Proves `HoldsOnBits (CorrectAt (Spec.exp .binary32) impl mode) lo hi` across every closed-form
short-path range of:

* `Expf.DoubleEval.expf` (and identically `Expf.DoubleEvalFma.expf`):
  - `0x00000000`–`0x32800000` (`+0` and `0 < x ≤ 2⁻²⁶`, returning `1 + x`)
  - `0x42B17218`–`0x7F7FFFFF` (overflow via `Core.setOverflow`)
  - `0x7F800000` (`+∞`) and `0x7F800001`–`0x7FFFFFFF` (positive NaNs)
  - `0x80000000`–`0xB2800000` (`-0` and `-2⁻²⁶ ≤ x < 0`, returning `1 + x`)
  - `0xC2CFF1B5`–`0xFF7FFFFF` (underflow via `Core.setUnderflow`)
  - `0xFF800000` (`-∞`) and `0xFF800001`–`0xFFFFFFFF` (negative NaNs)
  Together these cover **3 749 616 693** of the `2³²` bit patterns (87.30 %), leaving
  `545 350 603` patterns per rounding direction (`[0x32800001, 0x42B17218)` and
  `[0xB2800001, 0xC2CFF1B5)`).

* `Expf.StaticRounding.kernel` (and via `integerEval_eq_staticRounding_nearest`,
  `Expf.IntegerEval.kernel` in `.nearest`):
  - `0x00000000`–`0x32FFFFFF` and `0x80000000`–`0xB2FFFFFF` (`|x| < 2⁻²⁵`, wider than
    `DoubleEval`), plus `0x42B17218`–`0x7FFFFFFF` and `0xC2CFF1B5`–`0xFFFFFFFF`.
  Together these cover **3 766 393 907** of the `2³²` bit patterns (87.69 %), leaving
  `528 573 389` patterns per rounding direction (`[0x33000000, 0x42B17218)` and
  `[0xB3000000, 0xC2CFF1B5)`).
-/

namespace LibcMath.Extracted.ExpfPaths

open FloatLib.Floats.Formats.BinaryInterchange Model
open LibcMath.Core.DSL

variable {mode : IEEERoundingMode}

/-- Lift a proof over 32-bit vectors to `HoldsOnBits` on `[lo, hi)`. -/
theorem holdsOnBits_of_forall_bitVec {P : Model .binary32 → Prop} {lo hi : ℕ}
    (h : ∀ b : BitVec 32, lo ≤ b.toNat → b.toNat < hi → P f32(b))
    (hrange : hi ≤ 2 ^ 32 := by norm_num) : HoldsOnBits P lo hi := by
  intro n hlo hhi
  have hmod : (BitVec.ofNat 32 n).toNat = n := by
    rw [BitVec.toNat_ofNat]
    omega
  exact h (BitVec.ofNat 32 n) (by omega) (by omega)

private theorem toNatBits_ofBits (b : BitVec 32) : f32(b).toNatBits = b.toNat := rfl

/-! ## `Expf.DoubleEval.expf` short-path ranges -/

theorem holdsOnBits_small_pos (hmode : mode ∈ cModes) :
    HoldsOnBits (CorrectAt (Spec.exp .binary32) Expf.DoubleEval.expf mode) 0x00000000 0x32800001 :=
  holdsOnBits_of_forall_bitVec fun b _ hhi => by
    refine .inl ?_
    rw [doubleEval_of_small b (by omega)]
    by_cases hzero : b.toNat = 0
    · rw [one_add_of_zero_bits (x := f32(b)) hmode (.inl hzero),
        ExpRanges.eval_of_zero_bits (x := f32(b)) (.inl hzero)]
    · have hbits : 0x00000001 ≤ f32(b).toNatBits ∧ f32(b).toNatBits ≤ 0x32800000 := by
        rw [toNatBits_ofBits]; omega
      rw [one_add_of_tiny_pos_bits hmode hbits,
        ExpRanges.eval_of_tiny_pos_bits hmode ⟨hbits.1, by omega⟩]

theorem holdsOnBits_small_neg (hmode : mode ∈ cModes) :
    HoldsOnBits (CorrectAt (Spec.exp .binary32) Expf.DoubleEval.expf mode) 0x80000000 0xB2800001 :=
  holdsOnBits_of_forall_bitVec fun b hlo hhi => by
    refine .inl ?_
    rw [doubleEval_of_small b (by omega)]
    by_cases hzero : b.toNat = 0x80000000
    · rw [one_add_of_zero_bits (x := f32(b)) hmode (.inr hzero),
        ExpRanges.eval_of_zero_bits (x := f32(b)) (.inr hzero)]
    · have hbits : 0x80000001 ≤ f32(b).toNatBits ∧ f32(b).toNatBits ≤ 0xB2800000 := by
        rw [toNatBits_ofBits]; omega
      rw [one_add_of_tiny_neg_bits hmode hbits,
        ExpRanges.eval_of_tiny_neg_bits hmode ⟨hbits.1, by omega⟩]

theorem holdsOnBits_overflow (hmode : mode ∈ cModes) :
    HoldsOnBits (CorrectAt (Spec.exp .binary32) Expf.DoubleEval.expf mode) 0x42B17218 0x7F800000 :=
  holdsOnBits_of_forall_bitVec fun b hlo hhi => by
    refine .inl ?_
    rw [doubleEval_of_overflow b hmode hlo (by omega),
      ExpRanges.eval_of_overflow_bits (x := f32(b)) hmode
        ⟨by rw [toNatBits_ofBits]; omega, by rw [toNatBits_ofBits]; omega⟩]

theorem holdsOnBits_posInf (hmode : mode ∈ cModes) :
    HoldsOnBits (CorrectAt (Spec.exp .binary32) Expf.DoubleEval.expf mode) 0x7F800000 0x7F800001 :=
  holdsOnBits_of_forall_bitVec fun b hlo hhi => by
    obtain rfl : b = 0x7F800000#32 := BitVec.eq_of_toNat_eq (show b.toNat = 0x7F800000 by omega)
    refine .inl ?_
    rw [doubleEval_of_posInf_or_pos_nan _ (by decide) (by decide),
      ExpRanges.eval_of_posInf_bits (x := f32(0x7F800000#32)) rfl]
    rcases hmode with rfl | rfl | rfl | rfl <;> decide +kernel

theorem holdsOnBits_pos_nan :
    HoldsOnBits (CorrectAt (Spec.exp .binary32) Expf.DoubleEval.expf mode) 0x7F800001 0x80000000 :=
  holdsOnBits_of_forall_bitVec fun b hlo hhi => by
    have hnan : f32(b).isNaN = true :=
      Binary32.isNaN_iff.mpr (.inl (by rw [toNatBits_ofBits]; omega))
    refine .inr ⟨?_, ?_⟩
    · rw [doubleEval_of_posInf_or_pos_nan b (by omega) (by omega)]
      exact isNaN_add_of_isNaN_left mode hnan
    · rw [ExpRanges.eval_of_isNaN hnan]
      decide +kernel

theorem holdsOnBits_underflow (hmode : mode ∈ cModes) :
    HoldsOnBits (CorrectAt (Spec.exp .binary32) Expf.DoubleEval.expf mode) 0xC2CFF1B5 0xFF800000 :=
  holdsOnBits_of_forall_bitVec fun b hlo hhi => by
    refine .inl ?_
    rw [doubleEval_of_underflow b hmode hlo (by omega),
      ExpRanges.eval_of_underflow_bits (x := f32(b)) hmode
        ⟨by rw [toNatBits_ofBits]; omega, by rw [toNatBits_ofBits]; omega⟩]

theorem holdsOnBits_negInf :
    HoldsOnBits (CorrectAt (Spec.exp .binary32) Expf.DoubleEval.expf mode) 0xFF800000 0xFF800001 :=
  holdsOnBits_of_forall_bitVec fun b hlo hhi => by
    obtain rfl : b = 0xFF800000#32 := BitVec.eq_of_toNat_eq (show b.toNat = 0xFF800000 by omega)
    refine .inl ?_
    change Expf.DoubleEval.expf mode (Model.negInf .binary32) =
      (Spec.exp .binary32).eval mode (Model.negInf .binary32)
    rw [doubleEval_of_negInf, ExpRanges.eval_of_negInf_bits (x := Model.negInf .binary32) rfl]

theorem holdsOnBits_neg_nan :
    HoldsOnBits (CorrectAt (Spec.exp .binary32) Expf.DoubleEval.expf mode) 0xFF800001 0x100000000 :=
  holdsOnBits_of_forall_bitVec fun b hlo hhi => by
    have hnan : f32(b).isNaN = true :=
      Binary32.isNaN_iff.mpr (.inr (by rw [toNatBits_ofBits]; omega))
    refine .inr ⟨?_, ?_⟩
    · rw [doubleEval_of_neg_nan b hlo]; exact hnan
    · rw [ExpRanges.eval_of_isNaN hnan]; decide +kernel

/-- All short-path ranges of `Expf.DoubleEval.expf` joined into three intervals covering
3 749 616 693 of 2³² bit patterns (87.30 %) in every C rounding mode. -/
theorem holdsOnBits_short_paths (hmode : mode ∈ cModes) :
    HoldsOnBits (CorrectAt (Spec.exp .binary32) Expf.DoubleEval.expf mode) 0x00000000 0x32800001 ∧
    HoldsOnBits (CorrectAt (Spec.exp .binary32) Expf.DoubleEval.expf mode) 0x42B17218 0xB2800001 ∧
    HoldsOnBits (CorrectAt (Spec.exp .binary32) Expf.DoubleEval.expf mode) 0xC2CFF1B5 0x100000000 :=
  ⟨holdsOnBits_small_pos hmode,
    (((holdsOnBits_overflow hmode).append (holdsOnBits_posInf hmode)).append
      holdsOnBits_pos_nan).append (holdsOnBits_small_neg hmode),
    ((holdsOnBits_underflow hmode).append holdsOnBits_negInf).append holdsOnBits_neg_nan⟩

/-! ## `Expf.DoubleEvalFma.expf` short-path ranges -/

theorem holdsOnBits_short_paths_fma (hmode : mode ∈ cModes) :
    HoldsOnBits (CorrectAt (Spec.exp .binary32) Expf.DoubleEvalFma.expf mode) 0x00000000 0x32800001 ∧
    HoldsOnBits (CorrectAt (Spec.exp .binary32) Expf.DoubleEvalFma.expf mode) 0x42B17218 0xB2800001 ∧
    HoldsOnBits (CorrectAt (Spec.exp .binary32) Expf.DoubleEvalFma.expf mode) 0xC2CFF1B5 0x100000000 := by
  have hsmall_pos :
      HoldsOnBits (CorrectAt (Spec.exp .binary32) Expf.DoubleEvalFma.expf mode) 0x00000000 0x32800001 :=
    holdsOnBits_of_forall_bitVec fun b _ hhi => by
      refine .inl ?_
      rw [doubleEvalFma_of_small b (by omega)]
      by_cases hzero : b.toNat = 0
      · rw [one_add_of_zero_bits (x := f32(b)) hmode (.inl hzero),
          ExpRanges.eval_of_zero_bits (x := f32(b)) (.inl hzero)]
      · have hbits : 0x00000001 ≤ f32(b).toNatBits ∧ f32(b).toNatBits ≤ 0x32800000 := by
          rw [toNatBits_ofBits]; omega
        rw [one_add_of_tiny_pos_bits hmode hbits,
          ExpRanges.eval_of_tiny_pos_bits hmode ⟨hbits.1, by omega⟩]
  have hsmall_neg :
      HoldsOnBits (CorrectAt (Spec.exp .binary32) Expf.DoubleEvalFma.expf mode) 0x80000000 0xB2800001 :=
    holdsOnBits_of_forall_bitVec fun b hlo hhi => by
      refine .inl ?_
      rw [doubleEvalFma_of_small b (by omega)]
      by_cases hzero : b.toNat = 0x80000000
      · rw [one_add_of_zero_bits (x := f32(b)) hmode (.inr hzero),
          ExpRanges.eval_of_zero_bits (x := f32(b)) (.inr hzero)]
      · have hbits : 0x80000001 ≤ f32(b).toNatBits ∧ f32(b).toNatBits ≤ 0xB2800000 := by
          rw [toNatBits_ofBits]; omega
        rw [one_add_of_tiny_neg_bits hmode hbits,
          ExpRanges.eval_of_tiny_neg_bits hmode ⟨hbits.1, by omega⟩]
  have hoverflow :
      HoldsOnBits (CorrectAt (Spec.exp .binary32) Expf.DoubleEvalFma.expf mode) 0x42B17218 0x7F800000 :=
    holdsOnBits_of_forall_bitVec fun b hlo hhi => .inl (by
      rw [doubleEvalFma_of_overflow b hmode hlo (by omega),
        ExpRanges.eval_of_overflow_bits (x := f32(b)) hmode
          ⟨by rw [toNatBits_ofBits]; omega, by rw [toNatBits_ofBits]; omega⟩])
  have hposInf :
      HoldsOnBits (CorrectAt (Spec.exp .binary32) Expf.DoubleEvalFma.expf mode) 0x7F800000 0x7F800001 :=
    holdsOnBits_of_forall_bitVec fun b hlo hhi => by
      obtain rfl : b = 0x7F800000#32 := BitVec.eq_of_toNat_eq (show b.toNat = 0x7F800000 by omega)
      refine .inl ?_
      rw [doubleEvalFma_of_posInf_or_pos_nan _ (by decide) (by decide),
        ExpRanges.eval_of_posInf_bits (x := f32(0x7F800000#32)) rfl]
      rcases hmode with rfl | rfl | rfl | rfl <;> decide +kernel
  have hposNan :
      HoldsOnBits (CorrectAt (Spec.exp .binary32) Expf.DoubleEvalFma.expf mode) 0x7F800001 0x80000000 :=
    holdsOnBits_of_forall_bitVec fun b hlo hhi => by
      have hnan : f32(b).isNaN = true :=
        Binary32.isNaN_iff.mpr (.inl (by rw [toNatBits_ofBits]; omega))
      refine .inr ⟨?_, ?_⟩
      · rw [doubleEvalFma_of_posInf_or_pos_nan b (by omega) (by omega)]
        exact isNaN_add_of_isNaN_left mode hnan
      · rw [ExpRanges.eval_of_isNaN hnan]; decide +kernel
  have hunderflow :
      HoldsOnBits (CorrectAt (Spec.exp .binary32) Expf.DoubleEvalFma.expf mode) 0xC2CFF1B5 0xFF800000 :=
    holdsOnBits_of_forall_bitVec fun b hlo hhi => .inl (by
      rw [doubleEvalFma_of_underflow b hmode hlo (by omega),
        ExpRanges.eval_of_underflow_bits (x := f32(b)) hmode
          ⟨by rw [toNatBits_ofBits]; omega, by rw [toNatBits_ofBits]; omega⟩])
  have hnegInf :
      HoldsOnBits (CorrectAt (Spec.exp .binary32) Expf.DoubleEvalFma.expf mode) 0xFF800000 0xFF800001 :=
    holdsOnBits_of_forall_bitVec fun b hlo hhi => by
      obtain rfl : b = 0xFF800000#32 := BitVec.eq_of_toNat_eq (show b.toNat = 0xFF800000 by omega)
      refine .inl ?_
      change Expf.DoubleEvalFma.expf mode (Model.negInf .binary32) =
        (Spec.exp .binary32).eval mode (Model.negInf .binary32)
      rw [doubleEvalFma_of_negInf, ExpRanges.eval_of_negInf_bits (x := Model.negInf .binary32) rfl]
  have hnegNan :
      HoldsOnBits (CorrectAt (Spec.exp .binary32) Expf.DoubleEvalFma.expf mode) 0xFF800001 0x100000000 :=
    holdsOnBits_of_forall_bitVec fun b hlo hhi => by
      have hnan : f32(b).isNaN = true :=
        Binary32.isNaN_iff.mpr (.inr (by rw [toNatBits_ofBits]; omega))
      refine .inr ⟨?_, ?_⟩
      · rw [doubleEvalFma_of_neg_nan b hlo]; exact hnan
      · rw [ExpRanges.eval_of_isNaN hnan]; decide +kernel
  exact ⟨hsmall_pos, (((hoverflow.append hposInf).append hposNan).append hsmall_neg),
    ((hunderflow.append hnegInf).append hnegNan)⟩

/-! ## `Expf.StaticRounding.kernel` & `Expf.IntegerEval.kernel` short-path ranges -/

private theorem isNaN_or_quiet (b : BitVec 32)
    (hb : (0x7F800001 ≤ b.toNat ∧ b.toNat ≤ 0x7FFFFFFF) ∨ 0xFF800001 ≤ b.toNat) :
    f32(b ||| 0x400000#32).isNaN = true := by
  have hlo : b.toNat ≤ (b ||| 0x400000#32).toNat := by
    rw [BitVec.toNat_or]
    exact Nat.left_le_or
  apply Binary32.isNaN_iff.mpr
  rw [toNatBits_ofBits]
  rcases hb with ⟨h1, h2⟩ | h1
  · left
    have hlt : (b ||| 0x400000#32).toNat < 2 ^ 31 := by
      rw [BitVec.toNat_or]
      exact Nat.or_lt_two_pow (by omega) (by norm_num)
    exact ⟨by omega, by omega⟩
  · right; omega

/-- All short-path ranges of the integer-only 4-mode kernel `Expf.StaticRounding.kernel`, covering
3 766 393 907 of 2³² bit patterns (87.69 %) in every C rounding mode. -/
theorem holdsOnBits_short_paths_staticRounding (hmode : mode ∈ cModes) :
    HoldsOnBits (CorrectAt (Spec.exp .binary32) Expf.StaticRounding.kernel mode) 0x00000000 0x33000000 ∧
    HoldsOnBits (CorrectAt (Spec.exp .binary32) Expf.StaticRounding.kernel mode) 0x42B17218 0xB3000000 ∧
    HoldsOnBits (CorrectAt (Spec.exp .binary32) Expf.StaticRounding.kernel mode) 0xC2CFF1B5 0x100000000 := by
  have hsmall_pos :
      HoldsOnBits (CorrectAt (Spec.exp .binary32) Expf.StaticRounding.kernel mode) 0x00000000 0x33000000 :=
    holdsOnBits_of_forall_bitVec fun b _ hhi => .inl (by
      by_cases hzero : b.toNat = 0
      · rw [staticRounding_of_zero b (.inl hzero),
          ExpRanges.eval_of_zero_bits (x := f32(b)) (.inl hzero)]
      · rw [staticRounding_of_tiny_pos b hmode (by omega) (by omega),
          ExpRanges.eval_of_tiny_pos_bits (x := f32(b)) hmode
            ⟨by rw [toNatBits_ofBits]; omega, by rw [toNatBits_ofBits]; omega⟩])
  have hsmall_neg :
      HoldsOnBits (CorrectAt (Spec.exp .binary32) Expf.StaticRounding.kernel mode) 0x80000000 0xB3000000 :=
    holdsOnBits_of_forall_bitVec fun b hlo hhi => .inl (by
      by_cases hzero : b.toNat = 0x80000000
      · rw [staticRounding_of_zero b (.inr hzero),
          ExpRanges.eval_of_zero_bits (x := f32(b)) (.inr hzero)]
      · rw [staticRounding_of_tiny_neg b hmode (by omega) (by omega),
          ExpRanges.eval_of_tiny_neg_bits (x := f32(b)) hmode
            ⟨by rw [toNatBits_ofBits]; omega, by rw [toNatBits_ofBits]; omega⟩])
  have hoverflow :
      HoldsOnBits (CorrectAt (Spec.exp .binary32) Expf.StaticRounding.kernel mode) 0x42B17218 0x7F800000 :=
    holdsOnBits_of_forall_bitVec fun b hlo hhi => .inl (by
      rw [staticRounding_of_overflow b hmode hlo (by omega),
        ExpRanges.eval_of_overflow_bits (x := f32(b)) hmode
          ⟨by rw [toNatBits_ofBits]; omega, by rw [toNatBits_ofBits]; omega⟩])
  have hposInf :
      HoldsOnBits (CorrectAt (Spec.exp .binary32) Expf.StaticRounding.kernel mode) 0x7F800000 0x7F800001 :=
    holdsOnBits_of_forall_bitVec fun b hlo hhi => by
      obtain rfl : b = 0x7F800000#32 := BitVec.eq_of_toNat_eq (show b.toNat = 0x7F800000 by omega)
      refine .inl ?_
      change Expf.StaticRounding.kernel mode (Model.posInf .binary32) =
        (Spec.exp .binary32).eval mode (Model.posInf .binary32)
      rw [staticRounding_of_posInf, ExpRanges.eval_of_posInf_bits (x := Model.posInf .binary32) rfl]
  have hposNan :
      HoldsOnBits (CorrectAt (Spec.exp .binary32) Expf.StaticRounding.kernel mode) 0x7F800001 0x80000000 :=
    holdsOnBits_of_forall_bitVec fun b hlo hhi => by
      have hnan : f32(b).isNaN = true :=
        Binary32.isNaN_iff.mpr (.inl (by rw [toNatBits_ofBits]; omega))
      refine .inr ⟨?_, ?_⟩
      · rw [staticRounding_of_nan b (.inl ⟨by omega, by omega⟩)]
        exact isNaN_or_quiet b (.inl ⟨by omega, by omega⟩)
      · rw [ExpRanges.eval_of_isNaN hnan]; decide +kernel
  have hunderflow :
      HoldsOnBits (CorrectAt (Spec.exp .binary32) Expf.StaticRounding.kernel mode) 0xC2CFF1B5 0xFF800000 :=
    holdsOnBits_of_forall_bitVec fun b hlo hhi => .inl (by
      rw [staticRounding_of_underflow b hmode hlo (by omega),
        ExpRanges.eval_of_underflow_bits (x := f32(b)) hmode
          ⟨by rw [toNatBits_ofBits]; omega, by rw [toNatBits_ofBits]; omega⟩])
  have hnegInf :
      HoldsOnBits (CorrectAt (Spec.exp .binary32) Expf.StaticRounding.kernel mode) 0xFF800000 0xFF800001 :=
    holdsOnBits_of_forall_bitVec fun b hlo hhi => by
      obtain rfl : b = 0xFF800000#32 := BitVec.eq_of_toNat_eq (show b.toNat = 0xFF800000 by omega)
      refine .inl ?_
      change Expf.StaticRounding.kernel mode (Model.negInf .binary32) =
        (Spec.exp .binary32).eval mode (Model.negInf .binary32)
      rw [staticRounding_of_negInf, ExpRanges.eval_of_negInf_bits (x := Model.negInf .binary32) rfl]
  have hnegNan :
      HoldsOnBits (CorrectAt (Spec.exp .binary32) Expf.StaticRounding.kernel mode) 0xFF800001 0x100000000 :=
    holdsOnBits_of_forall_bitVec fun b hlo hhi => by
      have hnan : f32(b).isNaN = true :=
        Binary32.isNaN_iff.mpr (.inr (by rw [toNatBits_ofBits]; omega))
      refine .inr ⟨?_, ?_⟩
      · rw [staticRounding_of_nan b (.inr (by omega))]
        exact isNaN_or_quiet b (.inr (by omega))
      · rw [ExpRanges.eval_of_isNaN hnan]; decide +kernel
  exact ⟨hsmall_pos, (((hoverflow.append hposInf).append hposNan).append hsmall_neg),
    ((hunderflow.append hnegInf).append hnegNan)⟩

/-- Short-path ranges of `Expf.IntegerEval.kernel` in `.nearest` mode, inherited directly from
`Expf.StaticRounding.kernel` via `integerEval_eq_staticRounding_nearest`. -/
theorem holdsOnBits_short_paths_integerEval :
    HoldsOnBits (CorrectAt (Spec.exp .binary32) Expf.IntegerEval.kernel .nearest) 0x00000000 0x33000000 ∧
    HoldsOnBits (CorrectAt (Spec.exp .binary32) Expf.IntegerEval.kernel .nearest) 0x42B17218 0xB3000000 ∧
    HoldsOnBits (CorrectAt (Spec.exp .binary32) Expf.IntegerEval.kernel .nearest) 0xC2CFF1B5 0x100000000 := by
  obtain ⟨h1, h2, h3⟩ := holdsOnBits_short_paths_staticRounding (mode := .nearest) (by simp [cModes])
  have tr : ∀ {lo hi},
      HoldsOnBits (CorrectAt (Spec.exp .binary32) Expf.StaticRounding.kernel .nearest) lo hi →
      HoldsOnBits (CorrectAt (Spec.exp .binary32) Expf.IntegerEval.kernel .nearest) lo hi :=
    fun h => h.imp fun x hx => by
      change SameValue (Expf.IntegerEval.kernel .nearest x) ((Spec.exp .binary32).eval .nearest x)
      rw [integerEval_eq_staticRounding_nearest]
      exact hx
  exact ⟨tr h1, tr h2, tr h3⟩

end LibcMath.Extracted.ExpfPaths
