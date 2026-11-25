import LibcMath.Framework.Spec
import LibcMath.Testing.Oracle.FloatLib
import LibcMath.Kernels.Expm1f.Generated.Sse2
import LibcMath.Kernels.Expm1f.Generated.Sse42
import LibcMath.Kernels.Expm1f.Generated.Avx2Fma

/-!
# Extracted `expm1f` microarch plans

Collects three extracted LLVM libc `expm1f` microarch plans (SSE2, SSE4.2, AVX2+FMA).
Every statement names its microarch plan explicitly.
-/

namespace LibcMath.Kernels.Expm1f

open FloatLib.Floats.Formats.BinaryInterchange
open LibcMath.Libc
open LibcMath.Kernels.Expm1f.Generated

/-- Lists all three extracted `expm1f` microarch plans. -/
def allPlans : List (UnaryKernel .binary32) :=
  [ Sse2.kernel, Sse42.kernel, Avx2Fma.kernel ]

/-- Correct rounding of `expm1f` (`sse2`) across all four C rounding modes. -/
def Expm1fSse2CorrectlyRounded : Prop :=
  UnaryFnCorrectlyRounded FloatLibSpec.expm1 cModes Sse2.kernel.eval

/-- Correct rounding of `expm1f` (`sse42`) across all four C rounding modes. -/
def Expm1fSse42CorrectlyRounded : Prop :=
  UnaryFnCorrectlyRounded FloatLibSpec.expm1 cModes Sse42.kernel.eval

/-- Correct rounding of `expm1f` (`avx2_fma`) across all four C rounding modes. -/
def Expm1fAvx2FmaCorrectlyRounded : Prop :=
  UnaryFnCorrectlyRounded FloatLibSpec.expm1 cModes Avx2Fma.kernel.eval

/-- **Open.** Prove `expm1f` (`sse2`) is correctly rounded across all four C rounding modes. -/
theorem expm1fSse2_correctlyRounded : Expm1fSse2CorrectlyRounded := by
  sorry

/-- **Open.** Prove `expm1f` (`sse42`) is correctly rounded across all four C rounding modes. -/
theorem expm1fSse42_correctlyRounded : Expm1fSse42CorrectlyRounded := by
  sorry

/-- **Open.** Prove `expm1f` (`avx2_fma`) is correctly rounded across all four C rounding modes. -/
theorem expm1fAvx2Fma_correctlyRounded : Expm1fAvx2FmaCorrectlyRounded := by
  sorry

/--
info: 'LibcMath.Kernels.Expm1f.expm1fSse2_correctlyRounded' depends on axioms: [propext,
 sorryAx,
 Classical.choice,
 Quot.sound]
-/
#guard_msgs in
#print axioms expm1fSse2_correctlyRounded

/--
info: 'LibcMath.Kernels.Expm1f.expm1fSse42_correctlyRounded' depends on axioms: [propext,
 sorryAx,
 Classical.choice,
 Quot.sound]
-/
#guard_msgs in
#print axioms expm1fSse42_correctlyRounded

/--
info: 'LibcMath.Kernels.Expm1f.expm1fAvx2Fma_correctlyRounded' depends on axioms: [propext,
 sorryAx,
 Classical.choice,
 Quot.sound]
-/
#guard_msgs in
#print axioms expm1fAvx2Fma_correctlyRounded

end LibcMath.Kernels.Expm1f
