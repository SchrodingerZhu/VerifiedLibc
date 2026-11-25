import LibcMath.Framework.Spec
import LibcMath.Framework.SpecialSpecs
import LibcMath.Kernels.Erff.Generated.Sse2
import LibcMath.Kernels.Erff.Generated.Avx2Fma

/-!
# Extracted `erff` microarch plans

Collects 2 extracted LLVM libc `erff` plans and states plan-qualified obligations.
Every statement names its microarch plan explicitly.
-/

namespace LibcMath.Kernels.Erff

open FloatLib.Floats.Formats.BinaryInterchange
open LibcMath.Libc
open LibcMath.Kernels.Erff.Generated

/-- Lists all 2 extracted `erff` plans. -/
def allPlans : List (UnaryKernel .binary32) :=
  [ Sse2.kernel
  , Avx2Fma.kernel ]

/-- Correct rounding of `erff` (`sse2`) in all four C modes. -/
def ErffSse2CorrectlyRounded : Prop :=
  CorrectlyRounded (Spec.erf .binary32) cModes Sse2.kernel.eval

/-- **Open.** Prove `erff` (`sse2`) is correctly rounded in all four C modes. -/
theorem erffSse2_correctlyRounded : ErffSse2CorrectlyRounded := by
  sorry

/-- Correct rounding of `erff` (`avx2_fma`) in all four C modes. -/
def ErffAvx2FmaCorrectlyRounded : Prop :=
  CorrectlyRounded (Spec.erf .binary32) cModes Avx2Fma.kernel.eval

/-- **Open.** Prove `erff` (`avx2_fma`) is correctly rounded in all four C modes. -/
theorem erffAvx2Fma_correctlyRounded : ErffAvx2FmaCorrectlyRounded := by
  sorry

/--
info: 'LibcMath.Kernels.Erff.erffSse2_correctlyRounded' depends on axioms: [propext, sorryAx, Classical.choice, Quot.sound]
-/
#guard_msgs in
#print axioms erffSse2_correctlyRounded

/--
info: 'LibcMath.Kernels.Erff.erffAvx2Fma_correctlyRounded' depends on axioms: [propext, sorryAx, Classical.choice, Quot.sound]
-/
#guard_msgs in
#print axioms erffAvx2Fma_correctlyRounded

end LibcMath.Kernels.Erff
