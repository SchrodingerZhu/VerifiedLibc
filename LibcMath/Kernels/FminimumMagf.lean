import LibcMath.Framework.Spec
import LibcMath.Testing.Oracle.FloatLib
import LibcMath.Kernels.FminimumMagf.Generated.GenericSse2

/-!
# Extracted `fminimum_magf` microarch plans

Collects 1 extracted LLVM libc `fminimum_magf` plans and states plan-qualified obligations.
Every statement names its microarch plan explicitly.
-/

namespace LibcMath.Kernels.FminimumMagf

open FloatLib.Floats.Formats.BinaryInterchange
open LibcMath.Libc
open LibcMath.Kernels.FminimumMagf.Generated

/-- Lists all 1 extracted `fminimum_magf` plans. -/
def allPlans : List (BinaryKernel .binary32) :=
  [ GenericSse2.kernel ]

/-- Correct rounding of `fminimum_magf` (`generic_sse2`) in all four C modes. -/
def FminimumMagfGenericSse2CorrectlyRounded : Prop :=
  BinaryFnCorrectlyRounded FloatLibSpec.fminimumMag cModes GenericSse2.kernel.eval

/-- **Open.** Prove `fminimum_magf` (`generic_sse2`) is correctly rounded in all four C modes. -/
theorem fminimum_magfGenericSse2_correctlyRounded : FminimumMagfGenericSse2CorrectlyRounded := by
  sorry

/--
info: 'LibcMath.Kernels.FminimumMagf.fminimum_magfGenericSse2_correctlyRounded' depends on axioms: [propext,
 sorryAx,
 Classical.choice,
 Quot.sound]
-/
#guard_msgs in
#print axioms fminimum_magfGenericSse2_correctlyRounded

end LibcMath.Kernels.FminimumMagf
