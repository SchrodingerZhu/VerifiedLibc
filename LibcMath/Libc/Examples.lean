import LibcMath.Libc

/-!
# Worked examples and regression tests for `LibcMath.Libc`

Exercises the Core LLVM libc operations, config-sensitive FMA / directed-rounding semantics,
`Frac64`, `NumberPair`, `PolyElem` (Horner & Estrin), DSL notation, and agent diagnostics in both
Lean's kernel (`decide +kernel`) and compiled evaluation (`#eval` + `#guard_msgs`).
-/

namespace LibcMath.Libc.Examples

open FloatLib.Floats.Formats.BinaryInterchange
open Model (IEEERoundingMode)
open LibcMath.Libc
open LibcMath.Libc.DSL

/-! ### Config-sensitive `subMultiply`: FMA vs non-FMA directed rounding -/

/-- `sub_multiply(2^-149, 2^-149, 0.5)` in `FE_UPWARD` demonstrates the exact comment in
LLVM libc `multiply_add.h:189-190`:
* without FMA + directed rounding (`x + ((-y) * z)`): `RU(2^-149 + RU(-2^-150)) = 2^-149`
* without FMA + RN-only (`x - (y * z)`): `RU(2^-149 - RU(2^-150)) = 0` -/
example :
    submul[MathConfig.defaultX86_64, .up](f32(0x00000001#32), f32(0x00000001#32),
      f32(0x3F000000#32))
      = f32(0x00000001#32) := by
  decide +kernel

example :
    submul[{ MathConfig.defaultX86_64 with assumeRoundNearestOnly := true }, .up](
      f32(0x00000001#32), f32(0x00000001#32), f32(0x3F000000#32))
      = f32(0x00000000#32) := by
  decide +kernel

/-- With FMA, `sub_multiply(1 + 2^-23, 1 + 2^-23, 1)` computes the exact single-rounded residual. -/
example :
    submul[MathConfig.x86_64Fma, .nearest](f32(0x3F800001#32), f32(0x3F800001#32),
      f32(0x3F800000#32))
      = f32(0x00000000#32) := by
  decide +kernel

/-! ### `horner[...]` and `estrin[...]` DSL evaluation -/

/-- `horner` on `[1.0, 2.0, 3.0]` at `x = 2.0` gives `1 + 2*(2 + 2*3) = 17.0`. -/
example :
    horner[MathConfig.defaultX86_64, .nearest] f32(0x40000000#32)
      [f32(0x3F800000#32), f32(0x40000000#32), f32(0x40400000#32)]
      = f32(0x41880000#32) := by
  decide +kernel

/-- `estrin` split sizes match `polyeval.h:201-208`. -/
example :
    [2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12].map estrinSplitLog2
      = [0, 0, 1, 0, 1, 2, 2, 0, 1, 2, 2] := by
  decide +kernel

/-- `estrin` max power log2 matches `polyeval.h:224-227`. -/
example :
    [2, 3, 4, 5, 6, 7, 8, 12, 13, 24].map estrinMaxPowerLog2
      = [0, 0, 1, 1, 1, 2, 2, 2, 3, 3] := by
  decide +kernel

/-- `estrin` with offset 1 on `#[100, 1, 2, 3]` at `x = 2.0` evaluates `1 + 2*2 + 3*4 = 17.0`. -/
example :
    estrin[MathConfig.defaultX86_64, .nearest, 1] f32(0x40000000#32)
      #[f32(0x42C80000#32), f32(0x3F800000#32), f32(0x40000000#32), f32(0x40400000#32)]
      = f32(0x41880000#32) := by
  decide +kernel

/-! ### `Frac64` exact vs 32-bit split multiplication -/

example :
    (Frac64.mul { hasInt128 := true } (frac64(0x8000000000000000#64))
      (frac64(0x8000000000000000#64))).val
      = 0x4000000000000000#64 := by
  decide +kernel

example :
    (Frac64.mul { hasInt128 := false } (frac64(0x8000000000000000#64))
      (frac64(0x8000000000000000#64))).val
      = 0x4000000000000000#64 := by
  decide +kernel

/-! ### `grind` automation over `Core` predicates and config -/

example (cfg : MathConfig) (h : cfg.hasFmaFloat = false) (mode : IEEERoundingMode)
    (x y z : Model .binary32) :
    multiplyAdd cfg mode x y z = Model.add (Model.mul x y mode) z mode := by
  grind

example (x : Model .binary32) : FPBits.getVal (FPBits.ofVal x) = x := by
  grind

/-- Concrete width resolution via `FmtBitWidth` allows direct `BitVec 32` ops and `bitCast`. -/
example :
    ((FPBits.uintval (FPBits.ofVal f32(0xBF800000#32))) &&& 0x7FFFFFFF#32) = 0x3F800000#32 := by
  decide +kernel

example :
    (Libc.bitCast (Libc.bitCast f32(0x3F800000#32) : BitVec 32) : Model .binary32) =
      f32(0x3F800000#32) := by
  decide +kernel

/-! ### FloatLib-backed rounding, extrema, payload, total order, and bit utilities -/

/-- `floor`, `ceil`, `trunc`, `round`, `roundEven` on `1.5f` and `-1.5f`. -/
example : Libc.floor f32(0x3FC00000#32) = f32(0x3F800000#32) := by decide +kernel
example : Libc.ceil f32(0x3FC00000#32) = f32(0x40000000#32) := by decide +kernel
example : Libc.trunc f32(0xBFC00000#32) = f32(0xBF800000#32) := by decide +kernel
example : Libc.round f32(0x3FC00000#32) = f32(0x40000000#32) := by decide +kernel
example : Libc.roundEven f32(0x40200000#32) = f32(0x40000000#32) := by decide +kernel
example : Libc.roundToIntMode f32(0x3FC00000#32) Libc.fpIntDownward = f32(0x3F800000#32) := by
  decide +kernel
example : Libc.roundToInt MathConfig.defaultX86_64 .up f32(0x3FC00000#32) = f32(0x40000000#32) := by
  decide +kernel

/-- `isInteger` and `isOddInteger` on `2.0f`, `3.0f`, and `1.5f`. -/
example : Libc.isInteger f32(0x40000000#32) = true := by decide +kernel
example : Libc.isInteger f32(0x3FC00000#32) = false := by decide +kernel
example : Libc.isOddInteger f32(0x40400000#32) = true := by decide +kernel
example : Libc.isOddInteger f32(0x40000000#32) = false := by decide +kernel

/-- `ldexp`, `logb`, `intlogb`, `remainder`, `nextUp`, `nextDown`, and `nextAfter`. -/
example : Libc.ldexp MathConfig.defaultX86_64 .nearest f32(0x3FC00000#32) (2#32) =
    f32(0x40C00000#32) := by decide +kernel
example : Libc.logb f32(0x41000000#32) = f32(0x40400000#32) := by decide +kernel
example : Libc.intlogb MathConfig.x86_64Sse2 32 f32(0x41000000#32) = 3#32 := by decide +kernel
example : Libc.remainder f32(0x40A00000#32) f32(0x40000000#32) = f32(0x3F800000#32) := by
  decide +kernel
example : Libc.nextUp f32(0x3F800000#32) = f32(0x3F800001#32) := by decide +kernel
example : Libc.nextDown f32(0x3F800000#32) = f32(0x3F7FFFFF#32) := by decide +kernel
example : Libc.nextAfter f32(0x3F800000#32) f32(0x40000000#32) = f32(0x3F800001#32) := by
  decide +kernel

/-- Extrema, payload, total order, bitwise ops, and C++20 bit utilities. -/
example : Libc.fmax f32(0xBF800000#32) f32(0x3F800000#32) = f32(0x3F800000#32) := by decide +kernel
example : Libc.fminimumMag f32(0xBF800000#32) f32(0x40000000#32) = f32(0xBF800000#32) := by
  decide +kernel
example : Libc.getPayload f32(0x7FC00005#32) = f32(0x40A00000#32) := by decide +kernel
example : Libc.totalOrder f32(0x80000000#32) f32(0x00000000#32) = true := by decide +kernel
example : Libc.totalOrderMag f32(0xBF800000#32) f32(0x40000000#32) = true := by decide +kernel
example : Libc.fpAnd f32(0xBF800000#32) f32(0x7FFFFFFF#32) = f32(0x3F800000#32) := by decide +kernel
example : Libc.hasSingleBit (8#32) = true ∧ Libc.hasSingleBit (6#32) = false := by decide +kernel
example : Libc.countrZero (8#32) = 3#32 ∧ Libc.bitWidth (8#32) = 4#32 := by decide +kernel

/-! ### Agent-friendly diagnostics -/

/--
info: "0x3F800000 (+normal, s=+, exp=127, frac=0 val=1)"
-/
#guard_msgs in
#eval Diag.describeFloat f32(0x3F800000#32)

/--
info: "variant=default target=x86_64-unknown-linux-gnu LIBC_MATH=[none (LIBC_MATH=0)] cpu=[INT128]"
-/
#guard_msgs in
#eval MathConfig.defaultX86_64.summary

/--
info: some 1
-/
#guard_msgs in
#eval Diag.ulpDiff? f32(0x3F800001#32) f32(0x3F800000#32)

/-! ### Axiom check -/

/--
info: 'LibcMath.Libc.setOverflow_binary32_pos_eq' depends on axioms: [propext, Classical.choice, Quot.sound]
-/
#guard_msgs in
#print axioms LibcMath.Libc.setOverflow_binary32_pos_eq

/--
info: 'LibcMath.Libc.setUnderflow_binary32_pos_eq' depends on axioms: [propext, Classical.choice, Quot.sound]
-/
#guard_msgs in
#print axioms LibcMath.Libc.setUnderflow_binary32_pos_eq

/-- `NumberPair.subScalar`, `scalarSub`, and `PolyElem.msub` on `DoubleDouble`. -/
example :
    (NumberPair.subScalar .nearest
      ({ lo := f64(0x0000000000000000#64), hi := f64(0x4008000000000000#64) } : DoubleDouble)
      f64(0x3FF0000000000000#64)).hi = f64(0x4000000000000000#64) := by
  decide +kernel

example :
    (msub[MathConfig.x86_64Avx2Fma, .nearest](
      ({ lo := f64(0x0000000000000000#64), hi := f64(0x4000000000000000#64) } : DoubleDouble),
      ({ lo := f64(0x0000000000000000#64), hi := f64(0x4008000000000000#64) } : DoubleDouble),
      ({ lo := f64(0x0000000000000000#64), hi := f64(0x3FF0000000000000#64) } : DoubleDouble)
    )).hi = f64(0x4014000000000000#64) := by
  decide +kernel

/-- Faithful `DyadicFloat.quickMul` (limb-truncated `quickMulHi` + 1-bit shift) and `asFloat`. -/
example :
    let a : DyadicFloat 128 := DyadicFloat.ofFloat 128 f32(0x40400000#32)
    let b : DyadicFloat 128 := DyadicFloat.ofFloat 128 f32(0x40000000#32)
    DyadicFloat.asFloat MathConfig.x86_64Sse2 .binary32 .nearest
      (DyadicFloat.quickMul MathConfig.x86_64Sse2 a b) = f32(0x40C00000#32) := by
  decide +kernel

/-! ### Microarch error-bound axiom checks -/

/--
info: 'LibcMath.Libc.Microarch.frac64_mulHiSplit32_error_bound' depends on axioms: [propext, Classical.choice, Quot.sound]
-/
#guard_msgs in
#print axioms LibcMath.Libc.Microarch.frac64_mulHiSplit32_error_bound

/--
info: 'LibcMath.Libc.Microarch.bigInt_quickMulHi_128_error_bound' depends on axioms: [propext, Classical.choice, Quot.sound]
-/
#guard_msgs in
#print axioms LibcMath.Libc.Microarch.bigInt_quickMulHi_128_error_bound

/-! ### `NormalFloat`, NaN payload, and `BigInt.ofLimbs64` checks -/

#guard (FPBits.quietNaN .binary32 .pos (0x123#32)).toBits == 0x7FC00123#32
#guard FPBits.exponent (FPBits.ofVal f32(0x00000001#32)) == (-127#32)
#guard FPBits.explicitExponent (FPBits.ofVal f32(0x00000001#32)) == (-126#32)
#guard (FPBits.signalingNaN .binary32 .pos (0x123#32)).toBits == 0x7F800123#32
#guard (FPBits.signalingNaN .binary32).toBits == 0x7FA00000#32
#guard BigInt.ofLimbs64 128 #[0x2#64, 0x1#64] == ((1#128 <<< 64) ||| 2#128)
#guard (NormalFloat.ofVal f32(0x3FC00000#32)).exponent == 0#32
#guard (NormalFloat.ofVal f32(0x3FC00000#32)).mantissa == 0x00C00000#32
#guard (NormalFloat.ofVal f32(0x00000001#32)).exponent == (-149#32)
#guard NormalFloat.toVal (NormalFloat.ofVal f32(0x3FC00000#32)) == f32(0x3FC00000#32)
#guard NormalFloat.toVal (NormalFloat.ofVal f32(0x00000001#32)) == f32(0x00000001#32)
#guard NormalFloat.toVal (NormalFloat.mul2 (NormalFloat.ofVal f32(0x3F800000#32)) 200#32) ==
    FPBits.inf .binary32
#guard NormalFloat.cmp (NormalFloat.ofVal f32(0x40000000#32))
    (NormalFloat.ofVal f32(0x3F800000#32)) == 1#32

end LibcMath.Libc.Examples
