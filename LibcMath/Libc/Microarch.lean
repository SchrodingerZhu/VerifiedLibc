import FloatLib.Floats.Formats.BinaryInterchange.Operations.Proof.RoundToIntegral.Real
import FloatLib.Floats.Formats.Flocq.Theory.Error.Addition
import FloatLib.Floats.Formats.Flocq.Theory.Error.Multiplication
import FloatLib.Floats.Formats.Flocq.Theory.Rounding.Odd
import LibcMath.Libc.Extended
import LibcMath.Libc.Poly

/-!
# Microarchitectural semantics and accuracy-pass theorems

Proves equivalence, divergence, and error-bound theorems for the target microarchitecture paths
modeled in `LibcMath.Libc`:

* `nearestInt` dispatch across x86-64 SSE2, x86-64 SSSE3, x86-64 SSE4.2 (`roundss`/`roundsd`),
  x86-64 AVX2+FMA, AArch64 (`frintn`), 32-bit ARMv8 (`roundeven`), RISC-V, and GPU (`rintf`).
* FMA versus unfused multiply-add dispatch and `assumeRoundNearestOnly` behavior.
* Exact 1-ULP error bounds for `Frac64.mulHiSplit32` (32-bit split without 128-bit integers)
  and `BigInt.quickMulHi` on 128-bit mantissas (`DyadicFloat<128>::quick_mul`).
* Bridges to FloatLib's integral-rounding, error-free transformation, and round-to-odd theories.
-/

namespace LibcMath.Libc.Microarch

open FloatLib.Floats.Formats.BinaryInterchange
open Model (IEEERoundingMode)
open LibcMath.Libc

/-! ## `nearestInt` microarchitectural equivalence and divergence -/

/-- Hardware ties-to-even targets compute `Model.roundToIntegral x .nearest` in every mode. -/
theorem nearestInt_of_hwTiesToEven {fmt : FloatFormat} {cfg : MathConfig}
    (h : cfg.nearestIntKind fmt = .hwTiesToEven) (mode : IEEERoundingMode) (x : Model fmt) :
    nearestInt cfg mode x = Model.roundToIntegral x (mode := .nearest) := by
  simp [nearestInt, h]

/-- GPU targets compute `Model.roundToIntegral x mode` in the dynamic rounding mode. -/
theorem nearestInt_gpu_eq_roundToIntegral {fmt : FloatFormat} (mode : IEEERoundingMode)
    (x : Model fmt) :
    nearestInt MathConfig.gpuNvptx mode x = Model.roundToIntegral x (mode := mode) := by
  simp [nearestInt, MathConfig.nearestIntKind, MathConfig.gpuNvptx]

/-- x86-64 SSE4.2 (`roundss`/`roundsd`) and AArch64 (`frintn`) agree on `nearestInt`. -/
theorem nearestInt_x86_64Sse42_eq_aarch64 {fmt : FloatFormat} (mode : IEEERoundingMode)
    (x : Model fmt) :
    nearestInt MathConfig.x86_64Sse42 mode x = nearestInt MathConfig.aarch64 mode x := by
  simp [nearestInt, MathConfig.nearestIntKind, MathConfig.x86_64Sse42, MathConfig.aarch64]

/-- x86-64 AVX2+FMA and AArch64 agree on `nearestInt`. -/
theorem nearestInt_x86_64Avx2Fma_eq_aarch64 {fmt : FloatFormat} (mode : IEEERoundingMode)
    (x : Model fmt) :
    nearestInt MathConfig.x86_64Avx2Fma mode x = nearestInt MathConfig.aarch64 mode x := by
  simp [nearestInt, MathConfig.nearestIntKind, MathConfig.x86_64Avx2Fma, MathConfig.aarch64]

/-- 32-bit ARMv8 hard-float (`roundeven`) agrees with AArch64 (`frintn`) on `binary32`. -/
theorem nearestInt_armV8_eq_aarch64_binary32 (mode : IEEERoundingMode) (x : Model .binary32) :
    nearestInt MathConfig.armV8HardFloat mode x = nearestInt MathConfig.aarch64 mode x := by
  simp [nearestInt, MathConfig.nearestIntKind, MathConfig.hasArmFpu,
    MathConfig.armV8HardFloat, MathConfig.aarch64]

/-- 32-bit ARMv8 hard-float (`roundeven`) agrees with AArch64 (`frintn`) on `binary64`. -/
theorem nearestInt_armV8_eq_aarch64_binary64 (mode : IEEERoundingMode) (x : Model .binary64) :
    nearestInt MathConfig.armV8HardFloat mode x = nearestInt MathConfig.aarch64 mode x := by
  simp [nearestInt, MathConfig.nearestIntKind, MathConfig.hasArmFpu,
    MathConfig.armV8HardFloat, MathConfig.aarch64]

/-- x86-64 SSE2 and SSSE3 share identical software `nearestInt` semantics. -/
theorem nearestInt_x86_64Sse2_eq_x86_64Ssse3 {fmt : FloatFormat} (mode : IEEERoundingMode)
    (x : Model fmt) :
    nearestInt MathConfig.x86_64Sse2 mode x = nearestInt MathConfig.x86_64Ssse3 mode x := by
  simp [nearestInt, MathConfig.nearestIntKind, MathConfig.x86_64Sse2, MathConfig.x86_64Ssse3]

/-- RISC-V `rv64gc` and x86-64 SSE2 share identical software `nearestInt` semantics. -/
theorem nearestInt_riscv64G_eq_x86_64Sse2 {fmt : FloatFormat} (mode : IEEERoundingMode)
    (x : Model fmt) :
    nearestInt MathConfig.riscv64G mode x = nearestInt MathConfig.x86_64Sse2 mode x := by
  simp [nearestInt, MathConfig.nearestIntKind, MathConfig.riscv64G, MathConfig.x86_64Sse2]

/-- GPU `nearestInt` agrees with AArch64 in round-to-nearest-even mode. -/
theorem nearestInt_gpu_nearest_eq_aarch64 {fmt : FloatFormat} (x : Model fmt) :
    nearestInt MathConfig.gpuNvptx .nearest x = nearestInt MathConfig.aarch64 .nearest x := by
  simp [nearestInt, MathConfig.nearestIntKind, MathConfig.gpuNvptx, MathConfig.aarch64]

/-- Concrete witness: x86-64 SSE2 `genericNearestInt` diverges from SSE4.2 `roundss` on `0.5f`
in upward rounding mode (`1.0f` versus `0.0f`). -/
theorem nearestInt_sse2_ne_sse42_up_half :
    nearestInt MathConfig.x86_64Sse2 .up (Model.ofBits 0x3F000000#32 : Model .binary32) =
      (Model.ofBits 0x3F800000#32 : Model .binary32) ∧
    nearestInt MathConfig.x86_64Sse42 .up (Model.ofBits 0x3F000000#32 : Model .binary32) =
      (Model.ofBits 0x00000000#32 : Model .binary32) := by
  decide +kernel

/-- Concrete witness: GPU `__builtin_rintf` diverges from AArch64 `frintn` on `0.25f` in upward
rounding mode (`1.0f` versus `0.0f`). -/
theorem nearestInt_gpu_ne_aarch64_up_quarter :
    nearestInt MathConfig.gpuNvptx .up (Model.ofBits 0x3E800000#32 : Model .binary32) =
      (Model.ofBits 0x3F800000#32 : Model .binary32) ∧
    nearestInt MathConfig.aarch64 .up (Model.ofBits 0x3E800000#32 : Model .binary32) =
      (Model.ofBits 0x00000000#32 : Model .binary32) := by
  decide +kernel

/-- Real-valued contract for hardware ties-to-even `nearestInt` via FloatLib
`Model.toReal_roundToIntegral`. -/
theorem toReal_nearestInt_hw {fmt : FloatFormat} {cfg : MathConfig}
    (hkind : cfg.nearestIntKind fmt = .hwTiesToEven)
    (hfmt : fmt.isIEEE = true)
    (hrange : (fmt.fracWidth : Int) ≤ fmt.maxNormalExponent)
    (mode : IEEERoundingMode) (x : Model fmt)
    (exact : FloatLib.Numerics.Dyadic) (hd : Model.toDyadic? x = some exact) :
    Model.toReal (nearestInt cfg mode x) =
      ((Model.roundDyadicToInt .nearest exact : Int) : ℝ) := by
  rw [nearestInt_of_hwTiesToEven hkind]
  exact Model.toReal_roundToIntegral hfmt hrange x .nearest exact hd

/-! ## FMA versus unfused multiply-add microarch equivalence -/

/-- x86-64 AVX2+FMA, AArch64, RISC-V `rv64gc`, and GPU share identical FMA semantics on `binary32`
and `binary64`. -/
theorem multiplyAdd_avx2Fma_eq_aarch64 {fmt : FloatFormat}
    (hfmt : fmt = .binary32 ∨ fmt = .binary64)
    (mode : IEEERoundingMode) (x y z : Model fmt) :
    multiplyAdd MathConfig.x86_64Avx2Fma mode x y z =
      multiplyAdd MathConfig.aarch64 mode x y z := by
  rcases hfmt with rfl | rfl <;>
    simp [multiplyAdd, MathConfig.x86_64Avx2Fma, MathConfig.aarch64]

theorem multiplyAdd_avx2Fma_eq_riscv64G {fmt : FloatFormat}
    (hfmt : fmt = .binary32 ∨ fmt = .binary64)
    (mode : IEEERoundingMode) (x y z : Model fmt) :
    multiplyAdd MathConfig.x86_64Avx2Fma mode x y z =
      multiplyAdd MathConfig.riscv64G mode x y z := by
  rcases hfmt with rfl | rfl <;>
    simp [multiplyAdd, MathConfig.x86_64Avx2Fma, MathConfig.riscv64G]

/-- x86-64 SSE2, SSSE3, and SSE4.2 share identical unfused `multiplyAdd` and `subMultiply`. -/
theorem multiplyAdd_sse2_eq_sse42 {fmt : FloatFormat}
    (mode : IEEERoundingMode) (x y z : Model fmt) :
    multiplyAdd MathConfig.x86_64Sse2 mode x y z =
      multiplyAdd MathConfig.x86_64Sse42 mode x y z := by
  simp [multiplyAdd, MathConfig.hasFma, MathConfig.x86_64Sse2, MathConfig.x86_64Sse42]

theorem subMultiply_sse2_eq_sse42 {fmt : FloatFormat}
    (mode : IEEERoundingMode) (x y z : Model fmt) :
    subMultiply MathConfig.x86_64Sse2 mode x y z =
      subMultiply MathConfig.x86_64Sse42 mode x y z := by
  simp [subMultiply, MathConfig.hasFma, MathConfig.x86_64Sse2, MathConfig.x86_64Sse42]

/-! ## Multi-limb `Frac64.mulHiSplit32` and `BigInt.quickMulHi` exact error bounds -/

private theorem nat_mul_lt_pow_add {x y p q : Nat} (hx : x < 2 ^ p) (hy : y < 2 ^ q) :
    x * y < 2 ^ (p + q) := by
  calc x * y < 2 ^ p * 2 ^ q := Nat.mul_lt_mul'' hx hy
    _ = 2 ^ (p + q) := (Nat.pow_add 2 p q).symm

private theorem nat_div_add_lt_bounds {s r d : Nat} (hd : 0 < d) (hr : r < d) :
    s / d ≤ (s + r) / d ∧ (s + r) / d ≤ s / d + 1 := by
  constructor
  · exact Nat.div_le_div_right (Nat.le_add_right s r)
  · have hlt : (s + r) / d < s / d + 2 := by
      apply Nat.div_lt_of_lt_mul
      have hm := Nat.div_add_mod s d
      have hml := Nat.mod_lt s hd
      have hmul : d * (s / d + 2) = d * (s / d) + d + d := by ring
      omega
    omega

private theorem nat_div_split {x y d : Nat} (hd : 0 < d) :
    x / d + (y + x % d) / d = (x + y) / d := by
  have heq : x + y = d * (x / d) + (y + x % d) := by
    have hx := Nat.div_add_mod x d
    omega
  rw [heq, Nat.mul_add_div hd]

private theorem nat_mul_split32_bounds (a b : Nat) (ha : a < 2 ^ 64) (hb : b < 2 ^ 64) :
    let aLo := a % 2 ^ 32
    let aHi := a / 2 ^ 32
    let bLo := b % 2 ^ 32
    let bHi := b / 2 ^ 32
    let t1 := aHi * bLo
    let t2 := aLo * bHi + t1 % 2 ^ 32
    let approx := aHi * bHi + t1 / 2 ^ 32 + t2 / 2 ^ 32
    let exact := (a * b) / 2 ^ 64
    t1 < 2 ^ 64 ∧ t2 < 2 ^ 64 ∧ approx < 2 ^ 64 ∧
      approx ≤ exact ∧ exact ≤ approx + 1 := by
  dsimp only
  set aLo := a % 2 ^ 32
  set aHi := a / 2 ^ 32
  set bLo := b % 2 ^ 32
  set bHi := b / 2 ^ 32
  have haLo : aLo < 2 ^ 32 := Nat.mod_lt _ (by decide)
  have hbLo : bLo < 2 ^ 32 := Nat.mod_lt _ (by decide)
  have haHi : aHi < 2 ^ 32 := Nat.div_lt_of_lt_mul ha
  have hbHi : bHi < 2 ^ 32 := Nat.div_lt_of_lt_mul hb
  have haEq : a = aHi * 2 ^ 32 + aLo := (Nat.div_add_mod' a (2 ^ 32)).symm
  have hbEq : b = bHi * 2 ^ 32 + bLo := (Nat.div_add_mod' b (2 ^ 32)).symm
  have ht1 : aHi * bLo < 2 ^ 64 := nat_mul_lt_pow_add haHi hbLo
  have ht1m : aHi * bLo % 2 ^ 32 < 2 ^ 32 := Nat.mod_lt _ (by decide)
  have ht2 : aLo * bHi + aHi * bLo % 2 ^ 32 < 2 ^ 64 := by
    have h1 : aLo * bHi ≤ (2 ^ 32 - 1) * (2 ^ 32 - 1) :=
      Nat.mul_le_mul (Nat.le_sub_one_of_lt haLo) (Nat.le_sub_one_of_lt hbHi)
    have h2 : aHi * bLo % 2 ^ 32 ≤ 2 ^ 32 - 1 := Nat.le_sub_one_of_lt ht1m
    have hbound : (2 ^ 32 - 1) * (2 ^ 32 - 1) + (2 ^ 32 - 1) < 2 ^ 64 := by decide
    exact Nat.lt_of_le_of_lt (Nat.add_le_add h1 h2) hbound
  have hprod : a * b =
      (aHi * bHi) * 2 ^ 64 + (aHi * bLo + aLo * bHi) * 2 ^ 32 + aLo * bLo := by
    rw [haEq, hbEq]; ring
  have hlo : aLo * bLo < 2 ^ 64 := nat_mul_lt_pow_add haLo hbLo
  have hmid : (aHi * bLo) / 2 ^ 32 + (aLo * bHi + (aHi * bLo) % 2 ^ 32) / 2 ^ 32 =
      (aHi * bLo + aLo * bHi) / 2 ^ 32 :=
    nat_div_split (by decide)
  have happrox_lt : aHi * bHi + aHi * bLo / 2 ^ 32 +
      (aLo * bHi + aHi * bLo % 2 ^ 32) / 2 ^ 32 < 2 ^ 64 := by
    have h1 : aHi * bHi ≤ (2 ^ 32 - 1) * (2 ^ 32 - 1) :=
      Nat.mul_le_mul (Nat.le_sub_one_of_lt haHi) (Nat.le_sub_one_of_lt hbHi)
    have h2 : aHi * bLo / 2 ^ 32 ≤ 2 ^ 32 - 1 :=
      Nat.le_sub_one_of_lt (Nat.div_lt_of_lt_mul ht1)
    have h3 : (aLo * bHi + aHi * bLo % 2 ^ 32) / 2 ^ 32 ≤ 2 ^ 32 - 1 :=
      Nat.le_sub_one_of_lt (Nat.div_lt_of_lt_mul ht2)
    have hbound : (2 ^ 32 - 1) * (2 ^ 32 - 1) + (2 ^ 32 - 1) + (2 ^ 32 - 1) < 2 ^ 64 := by
      decide
    exact Nat.lt_of_le_of_lt (Nat.add_le_add (Nat.add_le_add h1 h2) h3) hbound
  have hexact_eq : (a * b) / 2 ^ 64 =
      aHi * bHi + ((aHi * bLo + aLo * bHi) * 2 ^ 32 + aLo * bLo) / 2 ^ 64 := by
    rw [hprod]
    have hcomm : aHi * bHi * 2 ^ 64 + (aHi * bLo + aLo * bHi) * 2 ^ 32 + aLo * bLo =
        ((aHi * bLo + aLo * bHi) * 2 ^ 32 + aLo * bLo) + aHi * bHi * 2 ^ 64 := by ring
    rw [hcomm, Nat.add_mul_div_right _ _ (by decide), Nat.add_comm]
  have hdiv_step := nat_div_add_lt_bounds (s := (aHi * bLo + aLo * bHi) * 2 ^ 32)
    (r := aLo * bLo) (d := 2 ^ 64) (by decide) hlo
  have hq : ((aHi * bLo + aLo * bHi) * 2 ^ 32) / 2 ^ 64 =
      (aHi * bLo + aLo * bHi) / 2 ^ 32 := by
    have hpow : (2 ^ 64 : Nat) = 2 ^ 32 * 2 ^ 32 := by decide
    rw [hpow, Nat.mul_div_mul_right _ _ (by decide)]
  rw [hq] at hdiv_step
  refine ⟨ht1, ht2, happrox_lt, ?_, ?_⟩
  · rw [hexact_eq, Nat.add_assoc, hmid]
    exact Nat.add_le_add_left hdiv_step.1 _
  · rw [hexact_eq, Nat.add_assoc (aHi * bHi), hmid, Nat.add_assoc]
    exact Nat.add_le_add_left hdiv_step.2 _

/-- Exact 1-ULP error bound for `Frac64.mulHiSplit32` (`!LIBC_TYPES_HAS_INT128`,
`src/__support/big_int.h:263-275, 674-678`): for every `a` and `b`,
`0 ≤ mulHi128(a, b) - mulHiSplit32(a, b) ≤ 1`. -/
theorem frac64_mulHiSplit32_error_bound (a b : Frac64) :
    (Frac64.mulHiSplit32 a b).val.toNat ≤ (Frac64.mulHi128 a b).val.toNat ∧
    (Frac64.mulHi128 a b).val.toNat ≤ (Frac64.mulHiSplit32 a b).val.toNat + 1 := by
  have ha : a.val.toNat < 2 ^ 64 := a.val.isLt
  have hb : b.val.toNat < 2 ^ 64 := b.val.isLt
  obtain ⟨ht1, ht2, happrox_lt, hle, hge⟩ := nat_mul_split32_bounds a.val.toNat b.val.toNat ha hb
  have hmask : ∀ x : BitVec 64, (x &&& 0x00000000FFFFFFFF#64).toNat = x.toNat % 2 ^ 32 := by
    intro x
    have h := BitVec.toNat_and x 0x00000000FFFFFFFF#64
    rw [h]
    exact Nat.and_two_pow_sub_one_eq_mod x.toNat 32
  have hExact : (Frac64.mulHi128 a b).val.toNat = (a.val.toNat * b.val.toNat) / 2 ^ 64 := by
    simp only [Frac64.mulHi128, BitVec.truncate, BitVec.zeroExtend, BitVec.toNat_setWidth,
      BitVec.toNat_ushiftRight, BitVec.toNat_mul]
    have h1 : a.val.toNat % 2 ^ 128 = a.val.toNat :=
      Nat.mod_eq_of_lt (Nat.lt_trans ha (by decide))
    have h2 : b.val.toNat % 2 ^ 128 = b.val.toNat :=
      Nat.mod_eq_of_lt (Nat.lt_trans hb (by decide))
    have hprod : a.val.toNat * b.val.toNat < 2 ^ 128 := nat_mul_lt_pow_add ha hb
    rw [h1, h2, Nat.mod_eq_of_lt hprod, Nat.shiftRight_eq_div_pow]
    exact Nat.mod_eq_of_lt (Nat.div_lt_of_lt_mul (by rw [← Nat.pow_add]; exact hprod))
  have hSplit : (Frac64.mulHiSplit32 a b).val.toNat =
      (a.val.toNat / 2 ^ 32) * (b.val.toNat / 2 ^ 32) +
        ((a.val.toNat / 2 ^ 32) * (b.val.toNat % 2 ^ 32)) / 2 ^ 32 +
        ((a.val.toNat % 2 ^ 32) * (b.val.toNat / 2 ^ 32) +
          ((a.val.toNat / 2 ^ 32) * (b.val.toNat % 2 ^ 32)) % 2 ^ 32) / 2 ^ 32 := by
    simp only [Frac64.mulHiSplit32]
    have haLo : (a.val &&& 0x00000000FFFFFFFF#64).toNat = a.val.toNat % 2 ^ 32 := hmask a.val
    have hbLo : (b.val &&& 0x00000000FFFFFFFF#64).toNat = b.val.toNat % 2 ^ 32 := hmask b.val
    have haHi : (a.val >>> 32).toNat = a.val.toNat / 2 ^ 32 := by
      simp [BitVec.toNat_ushiftRight, Nat.shiftRight_eq_div_pow]
    have hbHi : (b.val >>> 32).toNat = b.val.toNat / 2 ^ 32 := by
      simp [BitVec.toNat_ushiftRight, Nat.shiftRight_eq_div_pow]
    have haHiLt : a.val.toNat / 2 ^ 32 < 2 ^ 32 := Nat.div_lt_of_lt_mul ha
    have hbHiLt : b.val.toNat / 2 ^ 32 < 2 ^ 32 := Nat.div_lt_of_lt_mul hb
    have ht1_eq : ((a.val >>> 32) * (b.val &&& 0x00000000FFFFFFFF#64)).toNat =
        (a.val.toNat / 2 ^ 32) * (b.val.toNat % 2 ^ 32) := by
      rw [BitVec.toNat_mul, haHi, hbLo, Nat.mod_eq_of_lt ht1]
    have ht1Lo : (((a.val >>> 32) * (b.val &&& 0x00000000FFFFFFFF#64)) &&&
        0x00000000FFFFFFFF#64).toNat =
        ((a.val.toNat / 2 ^ 32) * (b.val.toNat % 2 ^ 32)) % 2 ^ 32 := by
      rw [hmask, ht1_eq]
    have haLo_bHi : ((a.val &&& 0x00000000FFFFFFFF#64) * (b.val >>> 32)).toNat =
        (a.val.toNat % 2 ^ 32) * (b.val.toNat / 2 ^ 32) := by
      rw [BitVec.toNat_mul, haLo, hbHi]
      exact Nat.mod_eq_of_lt (nat_mul_lt_pow_add (p := 32) (q := 32)
        (Nat.mod_lt _ (by decide)) hbHiLt)
    have ht2_eq : ((a.val &&& 0x00000000FFFFFFFF#64) * (b.val >>> 32) +
        ((a.val >>> 32) * (b.val &&& 0x00000000FFFFFFFF#64) &&& 0x00000000FFFFFFFF#64)).toNat =
        (a.val.toNat % 2 ^ 32) * (b.val.toNat / 2 ^ 32) +
          ((a.val.toNat / 2 ^ 32) * (b.val.toNat % 2 ^ 32)) % 2 ^ 32 := by
      rw [BitVec.toNat_add, haLo_bHi, ht1Lo, Nat.mod_eq_of_lt ht2]
    have haHi_bHi : ((a.val >>> 32) * (b.val >>> 32)).toNat =
        (a.val.toNat / 2 ^ 32) * (b.val.toNat / 2 ^ 32) := by
      rw [BitVec.toNat_mul, haHi, hbHi]
      exact Nat.mod_eq_of_lt (nat_mul_lt_pow_add (p := 32) (q := 32) haHiLt hbHiLt)
    have ht1Hi : (((a.val >>> 32) * (b.val &&& 0x00000000FFFFFFFF#64)) >>> 32).toNat =
        ((a.val.toNat / 2 ^ 32) * (b.val.toNat % 2 ^ 32)) / 2 ^ 32 := by
      rw [BitVec.toNat_ushiftRight, ht1_eq, Nat.shiftRight_eq_div_pow]
    have ht2Hi : (((a.val &&& 0x00000000FFFFFFFF#64) * (b.val >>> 32) +
        ((a.val >>> 32) * (b.val &&& 0x00000000FFFFFFFF#64) &&&
          0x00000000FFFFFFFF#64)) >>> 32).toNat =
        ((a.val.toNat % 2 ^ 32) * (b.val.toNat / 2 ^ 32) +
          ((a.val.toNat / 2 ^ 32) * (b.val.toNat % 2 ^ 32)) % 2 ^ 32) / 2 ^ 32 := by
      rw [BitVec.toNat_ushiftRight, ht2_eq, Nat.shiftRight_eq_div_pow]
    rw [BitVec.toNat_add, BitVec.toNat_add, haHi_bHi, ht1Hi, ht2Hi]
    have hsum1 : (a.val.toNat / 2 ^ 32) * (b.val.toNat / 2 ^ 32) +
        ((a.val.toNat / 2 ^ 32) * (b.val.toNat % 2 ^ 32)) / 2 ^ 32 < 2 ^ 64 :=
      Nat.lt_of_le_of_lt (Nat.le_add_right _ _) happrox_lt
    rw [Nat.mod_eq_of_lt hsum1, Nat.mod_eq_of_lt happrox_lt]
  rw [hExact, hSplit]
  exact ⟨hle, hge⟩

/-- Exact 1-ULP error bound for 128-bit `BigInt.quickMulHi` (`DyadicFloat<128>::quick_mul`,
`src/__support/big_int.h:692`): omitting the `a₀ * b₀` partial product loses at most 1 ULP. -/
theorem bigInt_quickMulHi_128_error_bound (cfg : MathConfig) (a b : BitVec 128) :
    let fullHi := ((a.zeroExtend 256 * b.zeroExtend 256) >>> 128).truncate 128
    let qHi := BigInt.quickMulHi cfg a b
    qHi.toNat ≤ fullHi.toNat ∧ fullHi.toNat ≤ qHi.toNat + 1 := by
  dsimp only
  have ha : a.toNat < 2 ^ 128 := a.isLt
  have hb : b.toNat < 2 ^ 128 := b.isLt
  have hprod_lt : a.toNat * b.toNat < 2 ^ 256 := nat_mul_lt_pow_add ha hb
  have hFull : (((a.zeroExtend 256 * b.zeroExtend 256) >>> 128).truncate 128).toNat =
      (a.toNat * b.toNat) / 2 ^ 128 := by
    simp only [BitVec.truncate, BitVec.zeroExtend, BitVec.toNat_setWidth,
      BitVec.toNat_ushiftRight, BitVec.toNat_mul]
    have hpow : (2 ^ 128 : Nat) < 2 ^ 256 := Nat.pow_lt_pow_right (by decide) (by decide)
    have h1 : a.toNat % 2 ^ 256 = a.toNat := Nat.mod_eq_of_lt (Nat.lt_trans ha hpow)
    have h2 : b.toNat % 2 ^ 256 = b.toNat := Nat.mod_eq_of_lt (Nat.lt_trans hb hpow)
    rw [h1, h2, Nat.mod_eq_of_lt hprod_lt, Nat.shiftRight_eq_div_pow]
    exact Nat.mod_eq_of_lt (Nat.div_lt_of_lt_mul (by rw [← Nat.pow_add]; exact hprod_lt))
  have hlimb0 : ∀ x : BitVec 128, BigInt.limb64 x 0 = x.toNat % 2 ^ 64 := by
    intro x
    simp only [BigInt.limb64, Nat.mul_zero, Nat.shiftRight_zero, Nat.shiftLeft_eq, Nat.one_mul]
    exact Nat.and_two_pow_sub_one_eq_mod x.toNat 64
  have hlimb1 : ∀ x : BitVec 128, BigInt.limb64 x 1 = x.toNat / 2 ^ 64 := by
    intro x
    simp only [BigInt.limb64, Nat.mul_one, Nat.shiftRight_eq_div_pow, Nat.shiftLeft_eq, Nat.one_mul]
    have hx : x.toNat / 2 ^ 64 < 2 ^ 64 :=
      Nat.div_lt_of_lt_mul (by rw [← Nat.pow_add]; exact x.isLt)
    rw [Nat.and_two_pow_sub_one_eq_mod, Nat.mod_eq_of_lt hx]
  have ha0 : a.toNat % 2 ^ 64 < 2 ^ 64 := Nat.mod_lt _ (Nat.two_pow_pos 64)
  have hb0 : b.toNat % 2 ^ 64 < 2 ^ 64 := Nat.mod_lt _ (Nat.two_pow_pos 64)
  have haEq : a.toNat = a.toNat / 2 ^ 64 * 2 ^ 64 + a.toNat % 2 ^ 64 :=
    (Nat.div_add_mod' a.toNat (2 ^ 64)).symm
  have hbEq : b.toNat = b.toNat / 2 ^ 64 * 2 ^ 64 + b.toNat % 2 ^ 64 :=
    (Nat.div_add_mod' b.toNat (2 ^ 64)).symm
  set S :=
    (a.toNat % 2 ^ 64) * (b.toNat / 2 ^ 64) * 2 ^ 64 +
    (a.toNat / 2 ^ 64) * (b.toNat % 2 ^ 64) * 2 ^ 64 +
    (a.toNat / 2 ^ 64) * (b.toNat / 2 ^ 64) * 2 ^ 128
  have hprod : a.toNat * b.toNat = S + (a.toNat % 2 ^ 64) * (b.toNat % 2 ^ 64) := by
    dsimp only [S]
    conv_lhs => rw [haEq, hbEq]
    ring
  have hrem : (a.toNat % 2 ^ 64) * (b.toNat % 2 ^ 64) < 2 ^ 128 := nat_mul_lt_pow_add ha0 hb0
  have hS_lt : S < 2 ^ 256 :=
    Nat.lt_of_le_of_lt (by rw [hprod]; exact Nat.le_add_right _ _) hprod_lt
  have hQ : (BigInt.quickMulHi cfg a b).toNat = S / 2 ^ 128 := by
    have hfold_gen : ∀ (f : Nat → Nat → Nat) (init : Nat),
        List.foldl f init [0, 1] = f (f init 0) 1 := fun _ _ => rfl
    have hfold : (BigInt.quickMulHi cfg a b).toNat = S / 2 ^ 128 % 2 ^ 128 := by
      simp only [BigInt.quickMulHi, show (128 : Nat) ≠ 64 by decide, ↓reduceDIte,
        show (128 > 64 && 128 % 64 == 0) = true by decide, ↓reduceIte]
      simp only [Nat.shiftLeft_eq, Nat.shiftRight_eq_div_pow, BitVec.toNat_ofNat]
      have h1 : (128 : Nat) / 64 = 2 := by decide
      have h2 : (2 : Nat) - 1 = 1 := by decide
      have h3 : List.range 2 = [0, 1] := by decide
      rw [h1, h2, h3, hfold_gen, hfold_gen, hfold_gen]
      simp only [show ¬(0 + 0 ≥ 1) by decide, show (0 + 1 ≥ 1) by decide,
        show (1 + 1 ≥ 1) by decide, ↓reduceIte,
        Nat.zero_add, Nat.add_zero, Nat.mul_one, show 64 * (1 + 1) = 128 by decide,
        hlimb0, hlimb1, S]
    have hdiv_lt : S / 2 ^ 128 < 2 ^ 128 :=
      Nat.div_lt_of_lt_mul (by rw [← Nat.pow_add]; exact hS_lt)
    rw [hfold, Nat.mod_eq_of_lt hdiv_lt]
  rw [hFull, hQ, hprod]
  exact nat_div_add_lt_bounds (Nat.two_pow_pos 128) hrem

/-! ## `NumberPair` and `DyadicFloat` reduction lemmas -/

/-- `NumberPair.exactAdd` with `fast2sum = true` unfolds to Dekker's 3-operation FastTwoSum. -/
theorem exactAdd_fast2sum {fmt : FloatFormat} (mode : IEEERoundingMode) (a b : Model fmt) :
    NumberPair.exactAdd mode a b true =
      let hi := fadd mode a b
      let t := fsub mode hi a
      { lo := fsub mode b t, hi } := rfl

/-- `NumberPair.exactAdd` with `fast2sum = false` unfolds to Knuth's 6-operation TwoSum. -/
theorem exactAdd_twosum {fmt : FloatFormat} (mode : IEEERoundingMode) (a b : Model fmt) :
    NumberPair.exactAdd mode a b false =
      let hi := fadd mode a b
      let t1 := fsub mode hi a
      let t2 := fsub mode hi t1
      let t3 := fsub mode b t1
      let t4 := fsub mode a t2
      { lo := fadd mode t3 t4, hi } := rfl

/-- Concrete witness: FastTwoSum (`fast2sum = true`) fails when `|a| < |b|`, whereas Knuth's
TwoSum (`fast2sum = false`) recovers the exact low part (`2^-25 + 1.0f`). -/
theorem exactAdd_fast2sum_ne_twosum_witness :
    let a : Model .binary32 := Model.ofBits 0x33000000#32
    let b : Model .binary32 := Model.ofBits 0x3F800000#32
    (NumberPair.exactAdd .nearest a b true).lo = (Model.ofBits 0x00000000#32 : Model .binary32) ∧
    (NumberPair.exactAdd .nearest a b false).lo = a := by
  decide +kernel

/-- `DyadicFloat.genericAs` agrees with FloatLib `Model.Internal.Directed.roundDyadic` on nonzero
mantissas when dynamic rounding is active. -/
theorem dyadicFloat_genericAs_eq_roundDyadic {bits : Nat} {cfg : MathConfig}
    (hrn : cfg.assumeRoundNearestOnly = false) (fmt : FloatFormat) (mode : IEEERoundingMode)
    (x : DyadicFloat bits) (hm : x.mantissa ≠ 0) :
    DyadicFloat.genericAs cfg fmt mode x =
      Model.Internal.Directed.roundDyadic fmt mode
        { negative := x.sign.isNeg, significand := x.mantissa.toNat, exponent := x.exponent } := by
  have hne : (x.mantissa == 0#bits) = false := beq_false_of_ne hm
  simp [DyadicFloat.genericAs, hrn, hne]

end LibcMath.Libc.Microarch
