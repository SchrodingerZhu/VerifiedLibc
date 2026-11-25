import LibcMath.Framework.Spec
import LibcMath.Testing.Oracle.FloatLib
import LibcMath.Kernels.Asinpif.Generated.Sse2
import LibcMath.Kernels.Asinpif.Generated.Avx2Fma

/-!
# Extracted `asinpif` evaluation and microarch plans

Collects 2 extracted LLVM libc `asinpif` plans and states plan-qualified obligations.
Every statement names its evaluation and microarch plan explicitly.
-/

namespace LibcMath.Kernels.Asinpif

open FloatLib.Floats.Formats.BinaryInterchange
open LibcMath.Libc
open LibcMath.Kernels.Asinpif.Generated

/-- Lists all 2 extracted `asinpif` plans. -/
def allPlans : List (UnaryKernel .binary32) :=
  [ Sse2.kernel
  , Avx2Fma.kernel ]

/-- Correct rounding of `asinpif` (`sse2`) in all four C modes. -/
def AsinpifSse2CorrectlyRounded : Prop :=
  UnaryFnCorrectlyRounded FloatLibSpec.asinpi cModes Sse2.kernel.eval

/-- **Open.** Prove `asinpif` (`sse2`) is correctly rounded in all four C modes. -/
theorem asinpifSse2_correctlyRounded : AsinpifSse2CorrectlyRounded := by
  sorry

/-- Correct rounding of `asinpif` (`avx2_fma`) in all four C modes. -/
def AsinpifAvx2FmaCorrectlyRounded : Prop :=
  UnaryFnCorrectlyRounded FloatLibSpec.asinpi cModes Avx2Fma.kernel.eval

/-- **Open.** Prove `asinpif` (`avx2_fma`) is correctly rounded in all four C modes. -/
theorem asinpifAvx2Fma_correctlyRounded : AsinpifAvx2FmaCorrectlyRounded := by
  sorry

/--
info: 'LibcMath.Kernels.Asinpif.asinpifSse2_correctlyRounded' depends on axioms: [propext,
 sorryAx,
 Classical.choice,
 Quot.sound]
-/
#guard_msgs in
#print axioms asinpifSse2_correctlyRounded

/--
info: 'LibcMath.Kernels.Asinpif.asinpifAvx2Fma_correctlyRounded' depends on axioms: [propext,
 sorryAx,
 Classical.choice,
 Quot.sound]
-/
#guard_msgs in
#print axioms asinpifAvx2Fma_correctlyRounded

end LibcMath.Kernels.Asinpif
