import LibcMath.Framework.Spec
import LibcMath.Testing.Oracle.FloatLib
import LibcMath.Kernels.Nearbyintf.Generated.GenericSse2
import LibcMath.Kernels.Nearbyintf.Generated.BuiltinSse42

/-!
# Extracted `nearbyintf` microarch plans

Collects 2 extracted LLVM libc `nearbyintf` plans and states plan-qualified obligations.
Every statement names its microarch plan explicitly.
-/

namespace LibcMath.Kernels.Nearbyintf

open FloatLib.Floats.Formats.BinaryInterchange
open LibcMath.Libc
open LibcMath.Kernels.Nearbyintf.Generated

/-- Lists all 2 extracted `nearbyintf` plans. -/
def allPlans : List (UnaryKernel .binary32) :=
  [ GenericSse2.kernel
  , BuiltinSse42.kernel ]

/-- Correct rounding of `nearbyintf` (`generic_sse2`) in all four C modes. -/
def NearbyintfGenericSse2CorrectlyRounded : Prop :=
  UnaryFnCorrectlyRounded FloatLibSpec.rint cModes GenericSse2.kernel.eval

/-- **Open.** Prove `nearbyintf` (`generic_sse2`) is correctly rounded in all four C modes. -/
theorem nearbyintfGenericSse2_correctlyRounded : NearbyintfGenericSse2CorrectlyRounded := by
  sorry

/-- Correct rounding of `nearbyintf` (`builtin_sse42`) in all four C modes. -/
def NearbyintfBuiltinSse42CorrectlyRounded : Prop :=
  UnaryFnCorrectlyRounded FloatLibSpec.rint cModes BuiltinSse42.kernel.eval

/-- **Open.** Prove `nearbyintf` (`builtin_sse42`) is correctly rounded in all four C modes. -/
theorem nearbyintfBuiltinSse42_correctlyRounded : NearbyintfBuiltinSse42CorrectlyRounded := by
  sorry

/--
info: 'LibcMath.Kernels.Nearbyintf.nearbyintfGenericSse2_correctlyRounded' depends on axioms: [propext,
 sorryAx,
 Classical.choice,
 Quot.sound]
-/
#guard_msgs in
#print axioms nearbyintfGenericSse2_correctlyRounded

/--
info: 'LibcMath.Kernels.Nearbyintf.nearbyintfBuiltinSse42_correctlyRounded' depends on axioms: [propext,
 sorryAx,
 Classical.choice,
 Quot.sound]
-/
#guard_msgs in
#print axioms nearbyintfBuiltinSse42_correctlyRounded

end LibcMath.Kernels.Nearbyintf
