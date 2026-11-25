import LibcMath.Framework.Spec
import LibcMath.Testing.Oracle.FloatLib
import LibcMath.Kernels.Rsqrtf.Generated.Sse2
import LibcMath.Kernels.Rsqrtf.Generated.Avx2Fma

/-!
# Extracted `rsqrtf` evaluation and microarch plans

Collects 2 extracted LLVM libc `rsqrtf` plans and states plan-qualified obligations.
Every statement names its evaluation and microarch plan explicitly.
-/

namespace LibcMath.Kernels.Rsqrtf

open FloatLib.Floats.Formats.BinaryInterchange
open LibcMath.Libc
open LibcMath.Kernels.Rsqrtf.Generated

/-- Lists all 2 extracted `rsqrtf` plans. -/
def allPlans : List (UnaryKernel .binary32) :=
  [ Sse2.kernel
  , Avx2Fma.kernel ]

/-- Correct rounding of `rsqrtf` (`sse2`) in all four C modes. -/
def RsqrtfSse2CorrectlyRounded : Prop :=
  UnaryFnCorrectlyRounded FloatLibSpec.rsqrt cModes Sse2.kernel.eval

/-- **Open.** Prove `rsqrtf` (`sse2`) is correctly rounded in all four C modes. -/
theorem rsqrtfSse2_correctlyRounded : RsqrtfSse2CorrectlyRounded := by
  sorry

/-- Correct rounding of `rsqrtf` (`avx2_fma`) in all four C modes. -/
def RsqrtfAvx2FmaCorrectlyRounded : Prop :=
  UnaryFnCorrectlyRounded FloatLibSpec.rsqrt cModes Avx2Fma.kernel.eval

/-- **Open.** Prove `rsqrtf` (`avx2_fma`) is correctly rounded in all four C modes. -/
theorem rsqrtfAvx2Fma_correctlyRounded : RsqrtfAvx2FmaCorrectlyRounded := by
  sorry

/--
info: 'LibcMath.Kernels.Rsqrtf.rsqrtfSse2_correctlyRounded' depends on axioms: [propext,
 sorryAx,
 Classical.choice,
 Quot.sound]
-/
#guard_msgs in
#print axioms rsqrtfSse2_correctlyRounded

/--
info: 'LibcMath.Kernels.Rsqrtf.rsqrtfAvx2Fma_correctlyRounded' depends on axioms: [propext,
 sorryAx,
 Classical.choice,
 Quot.sound]
-/
#guard_msgs in
#print axioms rsqrtfAvx2Fma_correctlyRounded

end LibcMath.Kernels.Rsqrtf
