import LibcMath.Framework.Spec
import LibcMath.Testing.Oracle.FloatLib
import LibcMath.Kernels.Acoshf.Generated.Sse2
import LibcMath.Kernels.Acoshf.Generated.Avx2Fma

/-!
# Extracted `acoshf` microarch plans

Collects 2 extracted LLVM libc `acoshf` plans and states plan-qualified obligations.
Every statement names its microarch plan explicitly.
-/

namespace LibcMath.Kernels.Acoshf

open FloatLib.Floats.Formats.BinaryInterchange
open LibcMath.Libc
open LibcMath.Kernels.Acoshf.Generated

/-- Lists all 2 extracted `acoshf` plans. -/
def allPlans : List (UnaryKernel .binary32) :=
  [ Sse2.kernel
  , Avx2Fma.kernel ]

/-- Correct rounding of `acoshf` (`sse2`) in all four C modes. -/
def AcoshfSse2CorrectlyRounded : Prop :=
  UnaryFnCorrectlyRounded FloatLibSpec.acosh cModes Sse2.kernel.eval

/-- **Open.** Prove `acoshf` (`sse2`) is correctly rounded in all four C modes. -/
theorem acoshfSse2_correctlyRounded : AcoshfSse2CorrectlyRounded := by
  sorry

/-- Correct rounding of `acoshf` (`avx2_fma`) in all four C modes. -/
def AcoshfAvx2FmaCorrectlyRounded : Prop :=
  UnaryFnCorrectlyRounded FloatLibSpec.acosh cModes Avx2Fma.kernel.eval

/-- **Open.** Prove `acoshf` (`avx2_fma`) is correctly rounded in all four C modes. -/
theorem acoshfAvx2Fma_correctlyRounded : AcoshfAvx2FmaCorrectlyRounded := by
  sorry

/--
info: 'LibcMath.Kernels.Acoshf.acoshfSse2_correctlyRounded' depends on axioms: [propext,
 sorryAx,
 Classical.choice,
 Quot.sound]
-/
#guard_msgs in
#print axioms acoshfSse2_correctlyRounded

/--
info: 'LibcMath.Kernels.Acoshf.acoshfAvx2Fma_correctlyRounded' depends on axioms: [propext,
 sorryAx,
 Classical.choice,
 Quot.sound]
-/
#guard_msgs in
#print axioms acoshfAvx2Fma_correctlyRounded

end LibcMath.Kernels.Acoshf
