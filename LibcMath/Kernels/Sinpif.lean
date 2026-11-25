import LibcMath.Framework.Spec
import LibcMath.Testing.Oracle.FloatLib
import LibcMath.Kernels.Sinpif.Generated.Sse2
import LibcMath.Kernels.Sinpif.Generated.Sse42
import LibcMath.Kernels.Sinpif.Generated.Avx2Fma

/-!
# Extracted `sinpif` evaluation and microarch plans

Collects 3 extracted LLVM libc `sinpif` plans and states plan-qualified obligations.
Every statement names its evaluation and microarch plan explicitly.
-/

namespace LibcMath.Kernels.Sinpif

open FloatLib.Floats.Formats.BinaryInterchange
open LibcMath.Libc
open LibcMath.Kernels.Sinpif.Generated

/-- Lists all 3 extracted `sinpif` plans. -/
def allPlans : List (UnaryKernel .binary32) :=
  [ Sse2.kernel
  , Sse42.kernel
  , Avx2Fma.kernel ]

/-- Correct rounding of `sinpif` (`sse2`) in all four C modes. -/
def SinpifSse2CorrectlyRounded : Prop :=
  UnaryFnCorrectlyRounded FloatLibSpec.sinpi cModes Sse2.kernel.eval

/-- **Open.** Prove `sinpif` (`sse2`) is correctly rounded in all four C modes. -/
theorem sinpifSse2_correctlyRounded : SinpifSse2CorrectlyRounded := by
  sorry

/-- Correct rounding of `sinpif` (`sse42`) in all four C modes. -/
def SinpifSse42CorrectlyRounded : Prop :=
  UnaryFnCorrectlyRounded FloatLibSpec.sinpi cModes Sse42.kernel.eval

/-- **Open.** Prove `sinpif` (`sse42`) is correctly rounded in all four C modes. -/
theorem sinpifSse42_correctlyRounded : SinpifSse42CorrectlyRounded := by
  sorry

/-- Correct rounding of `sinpif` (`avx2_fma`) in all four C modes. -/
def SinpifAvx2FmaCorrectlyRounded : Prop :=
  UnaryFnCorrectlyRounded FloatLibSpec.sinpi cModes Avx2Fma.kernel.eval

/-- **Open.** Prove `sinpif` (`avx2_fma`) is correctly rounded in all four C modes. -/
theorem sinpifAvx2Fma_correctlyRounded : SinpifAvx2FmaCorrectlyRounded := by
  sorry

/--
info: 'LibcMath.Kernels.Sinpif.sinpifSse2_correctlyRounded' depends on axioms: [propext,
 sorryAx,
 Classical.choice,
 Quot.sound]
-/
#guard_msgs in
#print axioms sinpifSse2_correctlyRounded

/--
info: 'LibcMath.Kernels.Sinpif.sinpifSse42_correctlyRounded' depends on axioms: [propext,
 sorryAx,
 Classical.choice,
 Quot.sound]
-/
#guard_msgs in
#print axioms sinpifSse42_correctlyRounded

/--
info: 'LibcMath.Kernels.Sinpif.sinpifAvx2Fma_correctlyRounded' depends on axioms: [propext,
 sorryAx,
 Classical.choice,
 Quot.sound]
-/
#guard_msgs in
#print axioms sinpifAvx2Fma_correctlyRounded

end LibcMath.Kernels.Sinpif
