import LibcMath.Framework.Spec
import LibcMath.Testing.Oracle.FloatLib
import LibcMath.Kernels.Exp10m1f.Generated.Sse2
import LibcMath.Kernels.Exp10m1f.Generated.Sse42
import LibcMath.Kernels.Exp10m1f.Generated.Avx2Fma

/-!
# Extracted `exp10m1f` microarch plans

Collects three extracted LLVM libc `exp10m1f` microarch plans (SSE2, SSE4.2, AVX2+FMA).
Every statement names its microarch plan explicitly.
-/

namespace LibcMath.Kernels.Exp10m1f

open FloatLib.Floats.Formats.BinaryInterchange
open LibcMath.Libc
open LibcMath.Kernels.Exp10m1f.Generated

/-- Lists all three extracted `exp10m1f` microarch plans. -/
def allPlans : List (UnaryKernel .binary32) :=
  [ Sse2.kernel, Sse42.kernel, Avx2Fma.kernel ]

/-- Correct rounding of `exp10m1f` (`sse2`) across all four C rounding modes. -/
def Exp10m1fSse2CorrectlyRounded : Prop :=
  UnaryFnCorrectlyRounded FloatLibSpec.exp10m1 cModes Sse2.kernel.eval

/-- Correct rounding of `exp10m1f` (`sse42`) across all four C rounding modes. -/
def Exp10m1fSse42CorrectlyRounded : Prop :=
  UnaryFnCorrectlyRounded FloatLibSpec.exp10m1 cModes Sse42.kernel.eval

/-- Correct rounding of `exp10m1f` (`avx2_fma`) across all four C rounding modes. -/
def Exp10m1fAvx2FmaCorrectlyRounded : Prop :=
  UnaryFnCorrectlyRounded FloatLibSpec.exp10m1 cModes Avx2Fma.kernel.eval

/-- **Open.** Prove `exp10m1f` (`sse2`) is correctly rounded across all four C rounding modes. -/
theorem exp10m1fSse2_correctlyRounded : Exp10m1fSse2CorrectlyRounded := by
  sorry

/-- **Open.** Prove `exp10m1f` (`sse42`) is correctly rounded across all four C rounding modes. -/
theorem exp10m1fSse42_correctlyRounded : Exp10m1fSse42CorrectlyRounded := by
  sorry

/-- **Open.** Prove `exp10m1f` (`avx2_fma`) is correctly rounded across all four C modes. -/
theorem exp10m1fAvx2Fma_correctlyRounded : Exp10m1fAvx2FmaCorrectlyRounded := by
  sorry

/--
info: 'LibcMath.Kernels.Exp10m1f.exp10m1fSse2_correctlyRounded' depends on axioms: [propext,
 sorryAx,
 Classical.choice,
 Quot.sound]
-/
#guard_msgs in
#print axioms exp10m1fSse2_correctlyRounded

/--
info: 'LibcMath.Kernels.Exp10m1f.exp10m1fSse42_correctlyRounded' depends on axioms: [propext,
 sorryAx,
 Classical.choice,
 Quot.sound]
-/
#guard_msgs in
#print axioms exp10m1fSse42_correctlyRounded

/--
info: 'LibcMath.Kernels.Exp10m1f.exp10m1fAvx2Fma_correctlyRounded' depends on axioms: [propext,
 sorryAx,
 Classical.choice,
 Quot.sound]
-/
#guard_msgs in
#print axioms exp10m1fAvx2Fma_correctlyRounded

end LibcMath.Kernels.Exp10m1f
