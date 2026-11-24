import LibcMath.Core

/-!
# Worked examples and regression tests for `LibcMath.Core`

Exercises the Core LLVM libc operations, config-sensitive FMA / directed-rounding semantics,
`Frac64`, `NumberPair`, `PolyElem` (Horner & Estrin), DSL notation, and agent diagnostics in both
Lean's kernel (`decide +kernel`) and compiled evaluation (`#eval` + `#guard_msgs`).
-/

namespace LibcMath.CoreExamples

open FloatLib.Floats.Formats.BinaryInterchange
open Model (IEEERoundingMode)
open LibcMath.Core
open LibcMath.Core.DSL

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
    (Core.bitCast (Core.bitCast f32(0x3F800000#32) : BitVec 32) : Model .binary32) =
      f32(0x3F800000#32) := by
  decide +kernel

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
info: 'LibcMath.Core.setOverflow_binary32_pos_eq' depends on axioms: [propext, Classical.choice, Quot.sound]
-/
#guard_msgs in
#print axioms LibcMath.Core.setOverflow_binary32_pos_eq

/--
info: 'LibcMath.Core.setUnderflow_binary32_pos_eq' depends on axioms: [propext, Classical.choice, Quot.sound]
-/
#guard_msgs in
#print axioms LibcMath.Core.setUnderflow_binary32_pos_eq

end LibcMath.CoreExamples
