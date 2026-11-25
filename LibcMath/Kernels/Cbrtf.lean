import LibcMath.Framework.Spec
import LibcMath.Testing.Oracle.FloatLib
import LibcMath.Kernels.Cbrtf.Generated.Sse2
import LibcMath.Kernels.Cbrtf.Generated.Avx2Fma

/-!
# Extracted `cbrtf` evaluation and microarch plans

Collects 2 extracted LLVM libc `cbrtf` plans and states plan-qualified obligations.
Every statement names its evaluation and microarch plan explicitly.
-/

namespace LibcMath.Kernels.Cbrtf

open FloatLib.Floats.Formats.BinaryInterchange
open LibcMath.Libc
open LibcMath.Kernels.Cbrtf.Generated

/-- Lists all 2 extracted `cbrtf` plans. -/
def allPlans : List (UnaryKernel .binary32) :=
  [ Sse2.kernel
  , Avx2Fma.kernel ]

/-- Correct rounding of `cbrtf` (`sse2`) in all four C modes. -/
def CbrtfSse2CorrectlyRounded : Prop :=
  UnaryFnCorrectlyRounded FloatLibSpec.cbrt cModes Sse2.kernel.eval

/-- **Open.** Prove `cbrtf` (`sse2`) is correctly rounded in all four C modes. -/
theorem cbrtfSse2_correctlyRounded : CbrtfSse2CorrectlyRounded := by
  sorry

/-- Correct rounding of `cbrtf` (`avx2_fma`) in all four C modes. -/
def CbrtfAvx2FmaCorrectlyRounded : Prop :=
  UnaryFnCorrectlyRounded FloatLibSpec.cbrt cModes Avx2Fma.kernel.eval

/-- **Open.** Prove `cbrtf` (`avx2_fma`) is correctly rounded in all four C modes. -/
theorem cbrtfAvx2Fma_correctlyRounded : CbrtfAvx2FmaCorrectlyRounded := by
  sorry

/--
info: 'LibcMath.Kernels.Cbrtf.cbrtfSse2_correctlyRounded' depends on axioms: [propext, sorryAx, Classical.choice, Quot.sound]
-/
#guard_msgs in
#print axioms cbrtfSse2_correctlyRounded

/--
info: 'LibcMath.Kernels.Cbrtf.cbrtfAvx2Fma_correctlyRounded' depends on axioms: [propext,
 sorryAx,
 Classical.choice,
 Quot.sound]
-/
#guard_msgs in
#print axioms cbrtfAvx2Fma_correctlyRounded

end LibcMath.Kernels.Cbrtf
