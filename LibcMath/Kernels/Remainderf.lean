import LibcMath.Framework.Spec
import LibcMath.Testing.Oracle.FloatLib
import LibcMath.Kernels.Remainderf.Generated.GenericSse2

/-!
# Extracted `remainderf` generic SSE2 plan

Collects the extracted LLVM libc `remainderf` (`generic_sse2`) plan and states its obligation.
Every statement names its microarch plan explicitly.
-/

namespace LibcMath.Kernels.Remainderf

open FloatLib.Floats.Formats.BinaryInterchange
open Model (IEEERoundingMode)
open LibcMath.Libc
open LibcMath.Kernels.Remainderf.Generated

/-- Correct rounding of `remainderf` (`generic_sse2`) in all four C modes. -/
def RemainderfGenericSse2CorrectlyRounded : Prop :=
  BinaryFnCorrectlyRounded FloatLibSpec.remainder cModes GenericSse2.kernel.eval

/-- **Open.** Prove `remainderf` (`generic_sse2`) matches IEEE remainder in all C modes. -/
theorem remainderfGenericSse2_correctlyRounded : RemainderfGenericSse2CorrectlyRounded := by
  sorry

/--
info: 'LibcMath.Kernels.Remainderf.remainderfGenericSse2_correctlyRounded' depends on axioms: [propext,
 sorryAx,
 Classical.choice,
 Quot.sound]
-/
#guard_msgs in
#print axioms remainderfGenericSse2_correctlyRounded

end LibcMath.Kernels.Remainderf
