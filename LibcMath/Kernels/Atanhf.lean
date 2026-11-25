import LibcMath.Framework.Spec
import LibcMath.Testing.Oracle.FloatLib
import LibcMath.Kernels.Atanhf.Generated.Sse2
import LibcMath.Kernels.Atanhf.Generated.Avx2Fma

/-!
# Extracted `atanhf` microarch plans

Collects 2 extracted LLVM libc `atanhf` plans and states plan-qualified obligations.
Every statement names its microarch plan explicitly.
-/

namespace LibcMath.Kernels.Atanhf

open FloatLib.Floats.Formats.BinaryInterchange
open LibcMath.Libc
open LibcMath.Kernels.Atanhf.Generated

/-- Lists all 2 extracted `atanhf` plans. -/
def allPlans : List (UnaryKernel .binary32) :=
  [ Sse2.kernel
  , Avx2Fma.kernel ]

/-- Correct rounding of `atanhf` (`sse2`) in all four C modes. -/
def AtanhfSse2CorrectlyRounded : Prop :=
  UnaryFnCorrectlyRounded FloatLibSpec.atanh cModes Sse2.kernel.eval

/-- **Open.** Prove `atanhf` (`sse2`) is correctly rounded in all four C modes. -/
theorem atanhfSse2_correctlyRounded : AtanhfSse2CorrectlyRounded := by
  sorry

/-- Correct rounding of `atanhf` (`avx2_fma`) in all four C modes. -/
def AtanhfAvx2FmaCorrectlyRounded : Prop :=
  UnaryFnCorrectlyRounded FloatLibSpec.atanh cModes Avx2Fma.kernel.eval

/-- **Open.** Prove `atanhf` (`avx2_fma`) is correctly rounded in all four C modes. -/
theorem atanhfAvx2Fma_correctlyRounded : AtanhfAvx2FmaCorrectlyRounded := by
  sorry

/--
info: 'LibcMath.Kernels.Atanhf.atanhfSse2_correctlyRounded' depends on axioms: [propext,
 sorryAx,
 Classical.choice,
 Quot.sound]
-/
#guard_msgs in
#print axioms atanhfSse2_correctlyRounded

/--
info: 'LibcMath.Kernels.Atanhf.atanhfAvx2Fma_correctlyRounded' depends on axioms: [propext,
 sorryAx,
 Classical.choice,
 Quot.sound]
-/
#guard_msgs in
#print axioms atanhfAvx2Fma_correctlyRounded

end LibcMath.Kernels.Atanhf
