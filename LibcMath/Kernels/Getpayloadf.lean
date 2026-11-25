import LibcMath.Framework.Spec
import LibcMath.Testing.Oracle.FloatLib
import LibcMath.Kernels.Getpayloadf.Generated.GenericSse2

/-!
# Extracted `getpayloadf` generic SSE2 plan

Collects the extracted LLVM libc `getpayloadf` (`generic_sse2`) plan and states its obligation.
Every statement names its microarch plan explicitly.
-/

namespace LibcMath.Kernels.Getpayloadf

open FloatLib.Floats.Formats.BinaryInterchange
open Model (IEEERoundingMode)
open LibcMath.Libc
open LibcMath.Kernels.Getpayloadf.Generated

/-- Correct rounding of `getpayloadf` (`generic_sse2`) in all four C modes. -/
def GetpayloadfGenericSse2CorrectlyRounded : Prop :=
  UnaryFnCorrectlyRounded FloatLibSpec.getpayload cModes GenericSse2.kernel.eval

/-- **Open.** Prove `getpayloadf` (`generic_sse2`) matches `FloatLibSpec.getpayload` in C modes.
-/
theorem getpayloadfGenericSse2_correctlyRounded : GetpayloadfGenericSse2CorrectlyRounded := by
  sorry

/--
info: 'LibcMath.Kernels.Getpayloadf.getpayloadfGenericSse2_correctlyRounded' depends on axioms: [propext,
 sorryAx,
 Classical.choice,
 Quot.sound]
-/
#guard_msgs in
#print axioms getpayloadfGenericSse2_correctlyRounded

end LibcMath.Kernels.Getpayloadf
