import LibcMath.Framework.Spec
import LibcMath.Testing.Oracle.FloatLib
import LibcMath.Kernels.FmaximumMagf.Generated.GenericSse2

/-!
# Extracted `fmaximum_magf` microarch plans

Collects 1 extracted LLVM libc `fmaximum_magf` plans and states plan-qualified obligations.
Every statement names its microarch plan explicitly.
-/

namespace LibcMath.Kernels.FmaximumMagf

open FloatLib.Floats.Formats.BinaryInterchange
open LibcMath.Libc
open LibcMath.Kernels.FmaximumMagf.Generated

/-- Lists all 1 extracted `fmaximum_magf` plans. -/
def allPlans : List (BinaryKernel .binary32) :=
  [ GenericSse2.kernel ]

/-- Correct rounding of `fmaximum_magf` (`generic_sse2`) in all four C modes. -/
def FmaximumMagfGenericSse2CorrectlyRounded : Prop :=
  BinaryFnCorrectlyRounded FloatLibSpec.fmaximumMag cModes GenericSse2.kernel.eval

/-- **Open.** Prove `fmaximum_magf` (`generic_sse2`) is correctly rounded in all four C modes. -/
theorem fmaximum_magfGenericSse2_correctlyRounded : FmaximumMagfGenericSse2CorrectlyRounded := by
  sorry

/--
info: 'LibcMath.Kernels.FmaximumMagf.fmaximum_magfGenericSse2_correctlyRounded' depends on axioms: [propext,
 sorryAx,
 Classical.choice,
 Quot.sound]
-/
#guard_msgs in
#print axioms fmaximum_magfGenericSse2_correctlyRounded

end LibcMath.Kernels.FmaximumMagf
