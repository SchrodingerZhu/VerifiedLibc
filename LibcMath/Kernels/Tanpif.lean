import LibcMath.Framework.Spec
import LibcMath.Testing.Oracle.FloatLib
import LibcMath.Kernels.Tanpif.Generated.Sse2
import LibcMath.Kernels.Tanpif.Generated.Sse42
import LibcMath.Kernels.Tanpif.Generated.Avx2Fma

/-!
# Extracted `tanpif` evaluation and microarch plans

Collects 3 extracted LLVM libc `tanpif` plans and states plan-qualified obligations.
Every statement names its evaluation and microarch plan explicitly.
-/

namespace LibcMath.Kernels.Tanpif

open FloatLib.Floats.Formats.BinaryInterchange
open LibcMath.Libc
open LibcMath.Kernels.Tanpif.Generated

/-- Lists all 3 extracted `tanpif` plans. -/
def allPlans : List (UnaryKernel .binary32) :=
  [ Sse2.kernel
  , Sse42.kernel
  , Avx2Fma.kernel ]

/-- Correct rounding of `tanpif` (`sse2`) in all four C modes. -/
def TanpifSse2CorrectlyRounded : Prop :=
  UnaryFnCorrectlyRounded FloatLibSpec.tanpi cModes Sse2.kernel.eval

/-- **Open.** Prove `tanpif` (`sse2`) is correctly rounded in all four C modes. -/
theorem tanpifSse2_correctlyRounded : TanpifSse2CorrectlyRounded := by
  sorry

/-- Correct rounding of `tanpif` (`sse42`) in all four C modes. -/
def TanpifSse42CorrectlyRounded : Prop :=
  UnaryFnCorrectlyRounded FloatLibSpec.tanpi cModes Sse42.kernel.eval

/-- **Open.** Prove `tanpif` (`sse42`) is correctly rounded in all four C modes. -/
theorem tanpifSse42_correctlyRounded : TanpifSse42CorrectlyRounded := by
  sorry

/-- Correct rounding of `tanpif` (`avx2_fma`) in all four C modes. -/
def TanpifAvx2FmaCorrectlyRounded : Prop :=
  UnaryFnCorrectlyRounded FloatLibSpec.tanpi cModes Avx2Fma.kernel.eval

/-- **Open.** Prove `tanpif` (`avx2_fma`) is correctly rounded in all four C modes. -/
theorem tanpifAvx2Fma_correctlyRounded : TanpifAvx2FmaCorrectlyRounded := by
  sorry

/--
info: 'LibcMath.Kernels.Tanpif.tanpifSse2_correctlyRounded' depends on axioms: [propext,
 sorryAx,
 Classical.choice,
 Quot.sound]
-/
#guard_msgs in
#print axioms tanpifSse2_correctlyRounded

/--
info: 'LibcMath.Kernels.Tanpif.tanpifSse42_correctlyRounded' depends on axioms: [propext,
 sorryAx,
 Classical.choice,
 Quot.sound]
-/
#guard_msgs in
#print axioms tanpifSse42_correctlyRounded

/--
info: 'LibcMath.Kernels.Tanpif.tanpifAvx2Fma_correctlyRounded' depends on axioms: [propext,
 sorryAx,
 Classical.choice,
 Quot.sound]
-/
#guard_msgs in
#print axioms tanpifAvx2Fma_correctlyRounded

end LibcMath.Kernels.Tanpif
