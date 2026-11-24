import LibcMath.Expf.Plans

/-!
# Verification & diagnostic examples for multi-plan extracted `expf`

Kernel-checked (`decide +kernel`) evaluation and cross-plan agreement checks across all six
extracted `expf` evaluation plans, plus `#guard_msgs` diagnostic checks via `LibcMath.Libc.Diag`.
-/

namespace LibcMath.Expf.Examples

open FloatLib.Floats.Formats.BinaryInterchange
open Model (IEEERoundingMode)
open LibcMath.Libc
open LibcMath.Libc.DSL
open LibcMath.Expf.Generated

/-! ### Spot checks across evaluation plans in Lean's kernel -/

/-- All five correctly-rounded plans agree on key normal, subnormal, exceptional (`0xC236BD8C`),
overflow, underflow, and special inputs in round-to-nearest-even mode. -/
def rnSpotInputs : List (Model .binary32) :=
  [ f32(0x00000000#32) -- +0.0
  , f32(0x80000000#32) -- -0.0
  , f32(0x3F800000#32) -- +1.0
  , f32(0xBF800000#32) -- -1.0
  , f32(0x32800000#32) -- +2^-26 (small positive)
  , f32(0xB2800000#32) -- -2^-26 (small negative)
  , f32(0xC236BD8C#32) -- hard-to-round exceptional point in double_eval
  , f32(0xC2B40000#32) -- -90.0 (produces subnormal)
  , f32(0x42B17218#32) -- overflow threshold
  , f32(0xC2CFF1B5#32) -- underflow threshold
  , f32(0x7F800000#32) -- +inf
  , f32(0xFF800000#32) -- -inf
  , f32(0x7FC00000#32) -- +qNaN
  ]

theorem crNearestPlans_agree_on_spotInputs :
    crNearestPlans.all (fun k =>
      rnSpotInputs.all (fun x =>
        Diag.sameResultBool (k .nearest x) (DoubleEval.kernel .nearest x))) = true := by
  decide +kernel

/-- All three four-mode correctly-rounded plans (`DoubleEval`, `DoubleEvalFma`, `StaticRounding`)
agree bit-for-bit (up to NaN) across all four IEEE rounding modes on representative inputs. -/
def allModes : List IEEERoundingMode := [.nearest, .down, .up, .towardZero]

theorem crAllModePlans_agree_all_modes :
    allModes.all (fun m =>
      crAllModePlans.all (fun k =>
        rnSpotInputs.all (fun x =>
          Diag.sameResultBool (k m x) (DoubleEval.kernel m x)))) = true := by
  decide +kernel

/-- Verify exact IEEE outputs at `1.0` (`0x402DF854` for CR plans, `0x402DF855` = +1 ULP for fast
`FloatEval`) and at the hard-to-round exceptional point `0xC236BD8C` (`0x1E88452D`). -/
theorem expf_one_exact :
    DoubleEval.expf .nearest f32(0x3F800000#32) = some f32(0x402DF854#32) ∧
    DoubleEvalFma.expf .nearest f32(0x3F800000#32) = some f32(0x402DF854#32) ∧
    IntegerEval.expf f32(0x3F800000#32) = some f32(0x402DF854#32) ∧
    StaticRounding.kernel .nearest f32(0x3F800000#32) = some f32(0x402DF854#32) ∧
    FloatEvalCrRn.expf .nearest f32(0x3F800000#32) = some f32(0x402DF854#32) ∧
    FloatEval.expf .nearest f32(0x3F800000#32) = some f32(0x402DF855#32) := by
  decide +kernel

theorem expf_exceptional_point_exact :
    DoubleEval.expf .nearest f32(0xC236BD8C#32) = some f32(0x1E88452D#32) ∧
    IntegerEval.expf f32(0xC236BD8C#32) = some f32(0x1E88452D#32) ∧
    FloatEvalCrRn.expf .nearest f32(0xC236BD8C#32) = some f32(0x1E88452D#32) := by
  decide +kernel

/-- All five correctly-rounded plans agree on a 64-input slice around `1.0` in `.nearest`. -/
theorem crNearestPlans_agree_near_one :
    crNearestPlans.all (fun k =>
      (Diag.firstDiffBits k.eval DoubleEval.kernel.eval .nearest 0x3F800000 64).isNone) = true := by
  decide +kernel

/-! ### Config & provenance diagnostics -/

/--
info: "Kernel: expf\n  C++ function : math::double_eval::expf\n  Source       : src/math/generic/expf.cpp (e1a5f92db023)\n  Clang        : 23.1.5\n  Config       : variant=double_eval target=x86_64-pc-linux-gnu LIBC_MATH=[none (LIBC_MATH=0)] cpu=[INT128]\n  Tables       : [EXP_M1, EXP_M2]"
-/
#guard_msgs in
#eval Diag.inspectKernel DoubleEval.kernel

/--
info: "Kernel: expf\n  C++ function : math::double_eval::expf\n  Source       : src/math/generic/expf.cpp (e1a5f92db023)\n  Clang        : 23.1.5\n  Config       : variant=double_eval_fma target=x86_64-pc-linux-gnu LIBC_MATH=[none (LIBC_MATH=0)] cpu=[FMA_FLOAT,FMA_DOUBLE,NEAREST_INT,INT128]\n  Tables       : [EXP_M1, EXP_M2]"
-/
#guard_msgs in
#eval Diag.inspectKernel DoubleEvalFma.kernel

/--
info: "Kernel: expf\n  C++ function : math::integer_eval::expf\n  Source       : src/math/generic/expf.cpp (e1a5f92db023)\n  Clang        : 23.1.5\n  Config       : variant=integer_eval target=x86_64-pc-linux-gnu LIBC_MATH=[NO_ERRNO|NO_EXCEPT|ASSUME_ROUND_NEAREST_ONLY] cpu=[INT128]\n  Tables       : [LOG2_E, EXP2F_COEFFS]"
-/
#guard_msgs in
#eval Diag.inspectKernel IntegerEval.kernel

/--
info: "Kernel: expf\n  C++ function : math::float_eval_cr_rn::expf\n  Source       : src/math/generic/expf.cpp (e1a5f92db023)\n  Clang        : 23.1.5\n  Config       : variant=float_eval_cr_rn target=x86_64-pc-linux-gnu LIBC_MATH=[SMALL_TABLES|NO_ERRNO|NO_EXCEPT|INTERMEDIATE_COMP_IN_FLOAT|ASSUME_ROUND_NEAREST_ONLY] cpu=[FMA_FLOAT,FMA_DOUBLE,NEAREST_INT,INT128]\n  Tables       : [COEFFS]"
-/
#guard_msgs in
#eval Diag.inspectKernel FloatEvalCrRn.kernel

/--
info: "[compare expf/double_eval vs expf/integer_eval] mode=nearest range=[0x3F800000, +32): all 32 inputs agree"
-/
#guard_msgs in
#eval Diag.compareKernels DoubleEval.kernel IntegerEval.kernel .nearest 0x3F800000 32

/--
info: "[compare expf/double_eval vs expf/float_eval] mode=nearest FIRST DIFF at 0x3F800000 (+normal, s=+, exp=127, frac=0 val=1):\n  expf/double_eval: 0x402DF854 (+normal, s=+, exp=128, frac=3012692 val=2850325/1048576)\n  expf/float_eval: 0x402DF855 (+normal, s=+, exp=128, frac=3012693 val=11401301/4194304) ulp_diff=-1"
-/
#guard_msgs in
#eval Diag.compareKernels DoubleEval.kernel FloatEval.kernel .nearest 0x3F800000 32

/--
info: "[plan-matrix] mode=nearest input=0x3F800000 (+normal, s=+, exp=127, frac=0 val=1)\n  expf/double_eval: 0x402DF854 (+normal, s=+, exp=128, frac=3012692 val=2850325/1048576) [exact]\n  expf/double_eval_fma: 0x402DF854 (+normal, s=+, exp=128, frac=3012692 val=2850325/1048576) [exact]\n  expf/integer_eval: 0x402DF854 (+normal, s=+, exp=128, frac=3012692 val=2850325/1048576) [exact]\n  expf/static_rounding: 0x402DF854 (+normal, s=+, exp=128, frac=3012692 val=2850325/1048576) [exact]\n  expf/float_eval: 0x402DF855 (+normal, s=+, exp=128, frac=3012693 val=11401301/4194304) [ulp=1]\n  expf/float_eval_cr_rn: 0x402DF854 (+normal, s=+, exp=128, frac=3012692 val=2850325/1048576) [exact]"
-/
#guard_msgs in
#eval Diag.diagnosePlanMatrix allPlans .nearest f32(0x3F800000#32)

/-! ### Axiom check -/

/--
info: 'LibcMath.Expf.Examples.crNearestPlans_agree_on_spotInputs' depends on axioms: [propext, Classical.choice, Quot.sound]
-/
#guard_msgs in
#print axioms crNearestPlans_agree_on_spotInputs

/--
info: 'LibcMath.Expf.Examples.crAllModePlans_agree_all_modes' depends on axioms: [propext, Classical.choice, Quot.sound]
-/
#guard_msgs in
#print axioms crAllModePlans_agree_all_modes

end LibcMath.Expf.Examples
