import LibcMath.Framework.Spec
import LibcMath.Testing.Oracle.FloatLib
import LibcMath.Kernels.Coshf.Generated.Sse2
import LibcMath.Kernels.Coshf.Generated.Sse42
import LibcMath.Kernels.Coshf.Generated.Avx2Fma

/-!
# Extracted `coshf` microarch plans

Collects 3 extracted LLVM libc `coshf` plans and states plan-qualified obligations.
Every statement names its microarch plan explicitly.
-/

namespace LibcMath.Kernels.Coshf

open FloatLib.Floats.Formats.BinaryInterchange
open LibcMath.Libc
open LibcMath.Kernels.Coshf.Generated

/-- Lists all 3 extracted `coshf` plans. -/
def allPlans : List (UnaryKernel .binary32) :=
  [ Sse2.kernel
  , Sse42.kernel
  , Avx2Fma.kernel ]

/-- Correct rounding of `coshf` (`sse2`) in all four C modes. -/
def CoshfSse2CorrectlyRounded : Prop :=
  UnaryFnCorrectlyRounded FloatLibSpec.cosh cModes Sse2.kernel.eval

/-- **Open.** Prove `coshf` (`sse2`) is correctly rounded in all four C modes. -/
theorem coshfSse2_correctlyRounded : CoshfSse2CorrectlyRounded := by
  sorry

/-- Correct rounding of `coshf` (`sse42`) in all four C modes. -/
def CoshfSse42CorrectlyRounded : Prop :=
  UnaryFnCorrectlyRounded FloatLibSpec.cosh cModes Sse42.kernel.eval

/-- **Open.** Prove `coshf` (`sse42`) is correctly rounded in all four C modes. -/
theorem coshfSse42_correctlyRounded : CoshfSse42CorrectlyRounded := by
  sorry

/-- Correct rounding of `coshf` (`avx2_fma`) in all four C modes. -/
def CoshfAvx2FmaCorrectlyRounded : Prop :=
  UnaryFnCorrectlyRounded FloatLibSpec.cosh cModes Avx2Fma.kernel.eval

/-- **Open.** Prove `coshf` (`avx2_fma`) is correctly rounded in all four C modes. -/
theorem coshfAvx2Fma_correctlyRounded : CoshfAvx2FmaCorrectlyRounded := by
  sorry

/--
info: 'LibcMath.Kernels.Coshf.coshfSse2_correctlyRounded' depends on axioms: [propext, sorryAx, Classical.choice, Quot.sound]
-/
#guard_msgs in
#print axioms coshfSse2_correctlyRounded

/--
info: 'LibcMath.Kernels.Coshf.coshfSse42_correctlyRounded' depends on axioms: [propext, sorryAx, Classical.choice, Quot.sound]
-/
#guard_msgs in
#print axioms coshfSse42_correctlyRounded

/--
info: 'LibcMath.Kernels.Coshf.coshfAvx2Fma_correctlyRounded' depends on axioms: [propext,
 sorryAx,
 Classical.choice,
 Quot.sound]
-/
#guard_msgs in
#print axioms coshfAvx2Fma_correctlyRounded

end LibcMath.Kernels.Coshf
