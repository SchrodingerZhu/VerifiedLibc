import LibcMath.Framework.Spec
import LibcMath.Testing.Oracle.FloatLib
import LibcMath.Kernels.Hypotf.Generated.GenericSse2
import LibcMath.Kernels.Hypotf.Generated.Avx2Fma

/-!
# Extracted `hypotf` evaluation and microarch plans

Collects 2 extracted LLVM libc `hypotf` plans and states plan-qualified obligations.
Every statement names its evaluation and microarch plan explicitly.
-/

namespace LibcMath.Kernels.Hypotf

open FloatLib.Floats.Formats.BinaryInterchange
open LibcMath.Libc
open LibcMath.Kernels.Hypotf.Generated

/-- Lists all 2 extracted `hypotf` plans. -/
def allPlans : List (BinaryKernel .binary32) :=
  [ GenericSse2.kernel
  , Avx2Fma.kernel ]

/-- Correct rounding of `hypotf` (`generic_sse2`) in all four C modes. -/
def HypotfGenericSse2CorrectlyRounded : Prop :=
  BinaryFnCorrectlyRounded FloatLibSpec.hypot cModes GenericSse2.kernel.eval

/-- **Open.** Prove `hypotf` (`generic_sse2`) is correctly rounded in all four C modes. -/
theorem hypotfGenericSse2_correctlyRounded : HypotfGenericSse2CorrectlyRounded := by
  sorry

/-- Correct rounding of `hypotf` (`avx2_fma`) in all four C modes. -/
def HypotfAvx2FmaCorrectlyRounded : Prop :=
  BinaryFnCorrectlyRounded FloatLibSpec.hypot cModes Avx2Fma.kernel.eval

/-- **Open.** Prove `hypotf` (`avx2_fma`) is correctly rounded in all four C modes. -/
theorem hypotfAvx2Fma_correctlyRounded : HypotfAvx2FmaCorrectlyRounded := by
  sorry

/--
info: 'LibcMath.Kernels.Hypotf.hypotfGenericSse2_correctlyRounded' depends on axioms: [propext,
 sorryAx,
 Classical.choice,
 Quot.sound]
-/
#guard_msgs in
#print axioms hypotfGenericSse2_correctlyRounded

/--
info: 'LibcMath.Kernels.Hypotf.hypotfAvx2Fma_correctlyRounded' depends on axioms: [propext,
 sorryAx,
 Classical.choice,
 Quot.sound]
-/
#guard_msgs in
#print axioms hypotfAvx2Fma_correctlyRounded

end LibcMath.Kernels.Hypotf
