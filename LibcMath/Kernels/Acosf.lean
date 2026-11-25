import LibcMath.Framework.Spec
import LibcMath.Testing.Oracle.FloatLib
import LibcMath.Kernels.Acosf.Generated.Sse2
import LibcMath.Kernels.Acosf.Generated.Avx2Fma

/-!
# Extracted `acosf` evaluation and microarch plans

Collects 2 extracted LLVM libc `acosf` plans and states plan-qualified obligations.
Every statement names its evaluation and microarch plan explicitly.
-/

namespace LibcMath.Kernels.Acosf

open FloatLib.Floats.Formats.BinaryInterchange
open LibcMath.Libc
open LibcMath.Kernels.Acosf.Generated

/-- Lists all 2 extracted `acosf` plans. -/
def allPlans : List (UnaryKernel .binary32) :=
  [ Sse2.kernel
  , Avx2Fma.kernel ]

/-- Correct rounding of `acosf` (`sse2`) in all four C modes. -/
def AcosfSse2CorrectlyRounded : Prop :=
  UnaryFnCorrectlyRounded FloatLibSpec.acos cModes Sse2.kernel.eval

/-- **Open.** Prove `acosf` (`sse2`) is correctly rounded in all four C modes. -/
theorem acosfSse2_correctlyRounded : AcosfSse2CorrectlyRounded := by
  sorry

/-- Correct rounding of `acosf` (`avx2_fma`) in all four C modes. -/
def AcosfAvx2FmaCorrectlyRounded : Prop :=
  UnaryFnCorrectlyRounded FloatLibSpec.acos cModes Avx2Fma.kernel.eval

/-- **Open.** Prove `acosf` (`avx2_fma`) is correctly rounded in all four C modes. -/
theorem acosfAvx2Fma_correctlyRounded : AcosfAvx2FmaCorrectlyRounded := by
  sorry

/--
info: 'LibcMath.Kernels.Acosf.acosfSse2_correctlyRounded' depends on axioms: [propext, sorryAx, Classical.choice, Quot.sound]
-/
#guard_msgs in
#print axioms acosfSse2_correctlyRounded

/--
info: 'LibcMath.Kernels.Acosf.acosfAvx2Fma_correctlyRounded' depends on axioms: [propext,
 sorryAx,
 Classical.choice,
 Quot.sound]
-/
#guard_msgs in
#print axioms acosfAvx2Fma_correctlyRounded

end LibcMath.Kernels.Acosf
