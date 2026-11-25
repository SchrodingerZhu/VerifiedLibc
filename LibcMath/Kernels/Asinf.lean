import LibcMath.Framework.Spec
import LibcMath.Testing.Oracle.FloatLib
import LibcMath.Kernels.Asinf.Generated.Sse2
import LibcMath.Kernels.Asinf.Generated.Avx2Fma

/-!
# Extracted `asinf` evaluation and microarch plans

Collects 2 extracted LLVM libc `asinf` plans and states plan-qualified obligations.
Every statement names its evaluation and microarch plan explicitly.
-/

namespace LibcMath.Kernels.Asinf

open FloatLib.Floats.Formats.BinaryInterchange
open LibcMath.Libc
open LibcMath.Kernels.Asinf.Generated

/-- Lists all 2 extracted `asinf` plans. -/
def allPlans : List (UnaryKernel .binary32) :=
  [ Sse2.kernel
  , Avx2Fma.kernel ]

/-- Correct rounding of `asinf` (`sse2`) in all four C modes. -/
def AsinfSse2CorrectlyRounded : Prop :=
  UnaryFnCorrectlyRounded FloatLibSpec.asin cModes Sse2.kernel.eval

/-- **Open.** Prove `asinf` (`sse2`) is correctly rounded in all four C modes. -/
theorem asinfSse2_correctlyRounded : AsinfSse2CorrectlyRounded := by
  sorry

/-- Correct rounding of `asinf` (`avx2_fma`) in all four C modes. -/
def AsinfAvx2FmaCorrectlyRounded : Prop :=
  UnaryFnCorrectlyRounded FloatLibSpec.asin cModes Avx2Fma.kernel.eval

/-- **Open.** Prove `asinf` (`avx2_fma`) is correctly rounded in all four C modes. -/
theorem asinfAvx2Fma_correctlyRounded : AsinfAvx2FmaCorrectlyRounded := by
  sorry

/--
info: 'LibcMath.Kernels.Asinf.asinfSse2_correctlyRounded' depends on axioms: [propext, sorryAx, Classical.choice, Quot.sound]
-/
#guard_msgs in
#print axioms asinfSse2_correctlyRounded

/--
info: 'LibcMath.Kernels.Asinf.asinfAvx2Fma_correctlyRounded' depends on axioms: [propext,
 sorryAx,
 Classical.choice,
 Quot.sound]
-/
#guard_msgs in
#print axioms asinfAvx2Fma_correctlyRounded

end LibcMath.Kernels.Asinf
