import LibcMath.Framework.Spec
import LibcMath.Testing.Oracle.FloatLib
import LibcMath.Kernels.Fdimf.Generated.GenericSse2

/-!
# Extracted `fdimf` microarch plans

Collects 1 extracted LLVM libc `fdimf` plans and states plan-qualified obligations.
Every statement names its microarch plan explicitly.
-/

namespace LibcMath.Kernels.Fdimf

open FloatLib.Floats.Formats.BinaryInterchange
open LibcMath.Libc
open LibcMath.Kernels.Fdimf.Generated

/-- Lists all 1 extracted `fdimf` plans. -/
def allPlans : List (BinaryKernel .binary32) :=
  [ GenericSse2.kernel ]

/-- Correct rounding of `fdimf` (`generic_sse2`) in all four C modes. -/
def FdimfGenericSse2CorrectlyRounded : Prop :=
  BinaryFnCorrectlyRounded FloatLibSpec.fdim cModes GenericSse2.kernel.eval

/-- **Open.** Prove `fdimf` (`generic_sse2`) is correctly rounded in all four C modes. -/
theorem fdimfGenericSse2_correctlyRounded : FdimfGenericSse2CorrectlyRounded := by
  sorry

/--
info: 'LibcMath.Kernels.Fdimf.fdimfGenericSse2_correctlyRounded' depends on axioms: [propext,
 sorryAx,
 Classical.choice,
 Quot.sound]
-/
#guard_msgs in
#print axioms fdimfGenericSse2_correctlyRounded

end LibcMath.Kernels.Fdimf
