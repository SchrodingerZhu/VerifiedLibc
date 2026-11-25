import LibcMath.Framework.Spec
import LibcMath.Testing.Oracle.FloatLib
import LibcMath.Kernels.Fmaf.Generated.GenericSse2
import LibcMath.Kernels.Fmaf.Generated.Avx2Fma

/-!
# Extracted `fmaf` microarch plans

Collects 2 extracted LLVM libc `fmaf` plans and states plan-qualified obligations.
Every statement names its microarch plan explicitly.
-/

namespace LibcMath.Kernels.Fmaf

open FloatLib.Floats.Formats.BinaryInterchange
open LibcMath.Libc
open LibcMath.Kernels.Fmaf.Generated

/-- Lists all 2 extracted `fmaf` plans. -/
def allPlans : List (TernaryKernel .binary32) :=
  [ GenericSse2.kernel
  , Avx2Fma.kernel ]

/-- Correct rounding of `fmaf` (`generic_sse2`) in all four C modes. -/
def FmafGenericSse2CorrectlyRounded : Prop :=
  TernaryFnCorrectlyRounded FloatLibSpec.fma cModes GenericSse2.kernel.eval

/-- **Open.** Prove `fmaf` (`generic_sse2`) is correctly rounded in all four C modes. -/
theorem fmafGenericSse2_correctlyRounded : FmafGenericSse2CorrectlyRounded := by
  sorry

/-- Correct rounding of `fmaf` (`avx2_fma`) in all four C modes. -/
def FmafAvx2FmaCorrectlyRounded : Prop :=
  TernaryFnCorrectlyRounded FloatLibSpec.fma cModes Avx2Fma.kernel.eval

/-- **Open.** Prove `fmaf` (`avx2_fma`) is correctly rounded in all four C modes. -/
theorem fmafAvx2Fma_correctlyRounded : FmafAvx2FmaCorrectlyRounded := by
  sorry

/--
info: 'LibcMath.Kernels.Fmaf.fmafGenericSse2_correctlyRounded' depends on axioms: [propext,
 sorryAx,
 Classical.choice,
 Quot.sound]
-/
#guard_msgs in
#print axioms fmafGenericSse2_correctlyRounded

/--
info: 'LibcMath.Kernels.Fmaf.fmafAvx2Fma_correctlyRounded' depends on axioms: [propext, sorryAx, Classical.choice, Quot.sound]
-/
#guard_msgs in
#print axioms fmafAvx2Fma_correctlyRounded

end LibcMath.Kernels.Fmaf
