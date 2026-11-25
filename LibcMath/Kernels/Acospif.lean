import LibcMath.Framework.Spec
import LibcMath.Testing.Oracle.FloatLib
import LibcMath.Kernels.Acospif.Generated.Sse2
import LibcMath.Kernels.Acospif.Generated.Avx2Fma

/-!
# Extracted `acospif` evaluation and microarch plans

Collects 2 extracted LLVM libc `acospif` plans and states plan-qualified obligations.
Every statement names its evaluation and microarch plan explicitly.
-/

namespace LibcMath.Kernels.Acospif

open FloatLib.Floats.Formats.BinaryInterchange
open LibcMath.Libc
open LibcMath.Kernels.Acospif.Generated

/-- Lists all 2 extracted `acospif` plans. -/
def allPlans : List (UnaryKernel .binary32) :=
  [ Sse2.kernel
  , Avx2Fma.kernel ]

/-- Correct rounding of `acospif` (`sse2`) in all four C modes. -/
def AcospifSse2CorrectlyRounded : Prop :=
  UnaryFnCorrectlyRounded FloatLibSpec.acospi cModes Sse2.kernel.eval

/-- **Open.** Prove `acospif` (`sse2`) is correctly rounded in all four C modes. -/
theorem acospifSse2_correctlyRounded : AcospifSse2CorrectlyRounded := by
  sorry

/-- Correct rounding of `acospif` (`avx2_fma`) in all four C modes. -/
def AcospifAvx2FmaCorrectlyRounded : Prop :=
  UnaryFnCorrectlyRounded FloatLibSpec.acospi cModes Avx2Fma.kernel.eval

/-- **Open.** Prove `acospif` (`avx2_fma`) is correctly rounded in all four C modes. -/
theorem acospifAvx2Fma_correctlyRounded : AcospifAvx2FmaCorrectlyRounded := by
  sorry

/--
info: 'LibcMath.Kernels.Acospif.acospifSse2_correctlyRounded' depends on axioms: [propext,
 sorryAx,
 Classical.choice,
 Quot.sound]
-/
#guard_msgs in
#print axioms acospifSse2_correctlyRounded

/--
info: 'LibcMath.Kernels.Acospif.acospifAvx2Fma_correctlyRounded' depends on axioms: [propext,
 sorryAx,
 Classical.choice,
 Quot.sound]
-/
#guard_msgs in
#print axioms acospifAvx2Fma_correctlyRounded

end LibcMath.Kernels.Acospif
