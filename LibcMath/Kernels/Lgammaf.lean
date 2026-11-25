import LibcMath.Framework.Spec
import LibcMath.Framework.SpecialSpecs
import LibcMath.Kernels.Lgammaf.Generated.Sse2
import LibcMath.Kernels.Lgammaf.Generated.Avx2Fma

/-!
# Extracted `lgammaf` microarch plans

Collects 2 extracted LLVM libc `lgammaf` plans and states plan-qualified obligations.
Every statement names its microarch plan explicitly.
-/

namespace LibcMath.Kernels.Lgammaf

open FloatLib.Floats.Formats.BinaryInterchange
open LibcMath.Libc
open LibcMath.Kernels.Lgammaf.Generated

/-- Lists all 2 extracted `lgammaf` plans. -/
def allPlans : List (UnaryKernel .binary32) :=
  [ Sse2.kernel
  , Avx2Fma.kernel ]

/-- Correct rounding of `lgammaf` (`sse2`) in all four C modes. -/
def LgammafSse2CorrectlyRounded : Prop :=
  CorrectlyRounded (Spec.lgamma .binary32) cModes Sse2.kernel.eval

/-- **Open.** Prove `lgammaf` (`sse2`) is correctly rounded in all four C modes. -/
theorem lgammafSse2_correctlyRounded : LgammafSse2CorrectlyRounded := by
  sorry

/-- Correct rounding of `lgammaf` (`avx2_fma`) in all four C modes. -/
def LgammafAvx2FmaCorrectlyRounded : Prop :=
  CorrectlyRounded (Spec.lgamma .binary32) cModes Avx2Fma.kernel.eval

/-- **Open.** Prove `lgammaf` (`avx2_fma`) is correctly rounded in all four C modes. -/
theorem lgammafAvx2Fma_correctlyRounded : LgammafAvx2FmaCorrectlyRounded := by
  sorry

/--
info: 'LibcMath.Kernels.Lgammaf.lgammafSse2_correctlyRounded' depends on axioms: [propext,
 sorryAx,
 Classical.choice,
 Quot.sound]
-/
#guard_msgs in
#print axioms lgammafSse2_correctlyRounded

/--
info: 'LibcMath.Kernels.Lgammaf.lgammafAvx2Fma_correctlyRounded' depends on axioms: [propext,
 sorryAx,
 Classical.choice,
 Quot.sound]
-/
#guard_msgs in
#print axioms lgammafAvx2Fma_correctlyRounded

end LibcMath.Kernels.Lgammaf
