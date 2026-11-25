import LibcMath.Framework.Spec
import LibcMath.Testing.Oracle.FloatLib
import LibcMath.Kernels.Asinhf.Generated.Sse2
import LibcMath.Kernels.Asinhf.Generated.Avx2Fma

/-!
# Extracted `asinhf` microarch plans

Collects 2 extracted LLVM libc `asinhf` plans and states plan-qualified obligations.
Every statement names its microarch plan explicitly.
-/

namespace LibcMath.Kernels.Asinhf

open FloatLib.Floats.Formats.BinaryInterchange
open LibcMath.Libc
open LibcMath.Kernels.Asinhf.Generated

/-- Lists all 2 extracted `asinhf` plans. -/
def allPlans : List (UnaryKernel .binary32) :=
  [ Sse2.kernel
  , Avx2Fma.kernel ]

/-- Correct rounding of `asinhf` (`sse2`) in all four C modes. -/
def AsinhfSse2CorrectlyRounded : Prop :=
  UnaryFnCorrectlyRounded FloatLibSpec.asinh cModes Sse2.kernel.eval

/-- **Open.** Prove `asinhf` (`sse2`) is correctly rounded in all four C modes. -/
theorem asinhfSse2_correctlyRounded : AsinhfSse2CorrectlyRounded := by
  sorry

/-- Correct rounding of `asinhf` (`avx2_fma`) in all four C modes. -/
def AsinhfAvx2FmaCorrectlyRounded : Prop :=
  UnaryFnCorrectlyRounded FloatLibSpec.asinh cModes Avx2Fma.kernel.eval

/-- **Open.** Prove `asinhf` (`avx2_fma`) is correctly rounded in all four C modes. -/
theorem asinhfAvx2Fma_correctlyRounded : AsinhfAvx2FmaCorrectlyRounded := by
  sorry

/--
info: 'LibcMath.Kernels.Asinhf.asinhfSse2_correctlyRounded' depends on axioms: [propext,
 sorryAx,
 Classical.choice,
 Quot.sound]
-/
#guard_msgs in
#print axioms asinhfSse2_correctlyRounded

/--
info: 'LibcMath.Kernels.Asinhf.asinhfAvx2Fma_correctlyRounded' depends on axioms: [propext,
 sorryAx,
 Classical.choice,
 Quot.sound]
-/
#guard_msgs in
#print axioms asinhfAvx2Fma_correctlyRounded

end LibcMath.Kernels.Asinhf
