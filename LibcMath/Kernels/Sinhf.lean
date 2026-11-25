import LibcMath.Framework.Spec
import LibcMath.Testing.Oracle.FloatLib
import LibcMath.Kernels.Sinhf.Generated.Sse2
import LibcMath.Kernels.Sinhf.Generated.Sse42
import LibcMath.Kernels.Sinhf.Generated.Avx2Fma

/-!
# Extracted `sinhf` microarch plans

Collects 3 extracted LLVM libc `sinhf` plans and states plan-qualified obligations.
Every statement names its microarch plan explicitly.
-/

namespace LibcMath.Kernels.Sinhf

open FloatLib.Floats.Formats.BinaryInterchange
open LibcMath.Libc
open LibcMath.Kernels.Sinhf.Generated

/-- Lists all 3 extracted `sinhf` plans. -/
def allPlans : List (UnaryKernel .binary32) :=
  [ Sse2.kernel
  , Sse42.kernel
  , Avx2Fma.kernel ]

/-- Correct rounding of `sinhf` (`sse2`) in all four C modes. -/
def SinhfSse2CorrectlyRounded : Prop :=
  UnaryFnCorrectlyRounded FloatLibSpec.sinh cModes Sse2.kernel.eval

/-- **Open.** Prove `sinhf` (`sse2`) is correctly rounded in all four C modes. -/
theorem sinhfSse2_correctlyRounded : SinhfSse2CorrectlyRounded := by
  sorry

/-- Correct rounding of `sinhf` (`sse42`) in all four C modes. -/
def SinhfSse42CorrectlyRounded : Prop :=
  UnaryFnCorrectlyRounded FloatLibSpec.sinh cModes Sse42.kernel.eval

/-- **Open.** Prove `sinhf` (`sse42`) is correctly rounded in all four C modes. -/
theorem sinhfSse42_correctlyRounded : SinhfSse42CorrectlyRounded := by
  sorry

/-- Correct rounding of `sinhf` (`avx2_fma`) in all four C modes. -/
def SinhfAvx2FmaCorrectlyRounded : Prop :=
  UnaryFnCorrectlyRounded FloatLibSpec.sinh cModes Avx2Fma.kernel.eval

/-- **Open.** Prove `sinhf` (`avx2_fma`) is correctly rounded in all four C modes. -/
theorem sinhfAvx2Fma_correctlyRounded : SinhfAvx2FmaCorrectlyRounded := by
  sorry

/--
info: 'LibcMath.Kernels.Sinhf.sinhfSse2_correctlyRounded' depends on axioms: [propext, sorryAx, Classical.choice, Quot.sound]
-/
#guard_msgs in
#print axioms sinhfSse2_correctlyRounded

/--
info: 'LibcMath.Kernels.Sinhf.sinhfSse42_correctlyRounded' depends on axioms: [propext, sorryAx, Classical.choice, Quot.sound]
-/
#guard_msgs in
#print axioms sinhfSse42_correctlyRounded

/--
info: 'LibcMath.Kernels.Sinhf.sinhfAvx2Fma_correctlyRounded' depends on axioms: [propext,
 sorryAx,
 Classical.choice,
 Quot.sound]
-/
#guard_msgs in
#print axioms sinhfAvx2Fma_correctlyRounded

end LibcMath.Kernels.Sinhf
