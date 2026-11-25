import LibcMath.Framework.Spec
import LibcMath.Testing.Oracle.FloatLib
import LibcMath.Kernels.Cospif.Generated.Sse2
import LibcMath.Kernels.Cospif.Generated.Sse42
import LibcMath.Kernels.Cospif.Generated.Avx2Fma

/-!
# Extracted `cospif` evaluation and microarch plans

Collects 3 extracted LLVM libc `cospif` plans and states plan-qualified obligations.
Every statement names its evaluation and microarch plan explicitly.
-/

namespace LibcMath.Kernels.Cospif

open FloatLib.Floats.Formats.BinaryInterchange
open LibcMath.Libc
open LibcMath.Kernels.Cospif.Generated

/-- Lists all 3 extracted `cospif` plans. -/
def allPlans : List (UnaryKernel .binary32) :=
  [ Sse2.kernel
  , Sse42.kernel
  , Avx2Fma.kernel ]

/-- Correct rounding of `cospif` (`sse2`) in all four C modes. -/
def CospifSse2CorrectlyRounded : Prop :=
  UnaryFnCorrectlyRounded FloatLibSpec.cospi cModes Sse2.kernel.eval

/-- **Open.** Prove `cospif` (`sse2`) is correctly rounded in all four C modes. -/
theorem cospifSse2_correctlyRounded : CospifSse2CorrectlyRounded := by
  sorry

/-- Correct rounding of `cospif` (`sse42`) in all four C modes. -/
def CospifSse42CorrectlyRounded : Prop :=
  UnaryFnCorrectlyRounded FloatLibSpec.cospi cModes Sse42.kernel.eval

/-- **Open.** Prove `cospif` (`sse42`) is correctly rounded in all four C modes. -/
theorem cospifSse42_correctlyRounded : CospifSse42CorrectlyRounded := by
  sorry

/-- Correct rounding of `cospif` (`avx2_fma`) in all four C modes. -/
def CospifAvx2FmaCorrectlyRounded : Prop :=
  UnaryFnCorrectlyRounded FloatLibSpec.cospi cModes Avx2Fma.kernel.eval

/-- **Open.** Prove `cospif` (`avx2_fma`) is correctly rounded in all four C modes. -/
theorem cospifAvx2Fma_correctlyRounded : CospifAvx2FmaCorrectlyRounded := by
  sorry

/--
info: 'LibcMath.Kernels.Cospif.cospifSse2_correctlyRounded' depends on axioms: [propext,
 sorryAx,
 Classical.choice,
 Quot.sound]
-/
#guard_msgs in
#print axioms cospifSse2_correctlyRounded

/--
info: 'LibcMath.Kernels.Cospif.cospifSse42_correctlyRounded' depends on axioms: [propext,
 sorryAx,
 Classical.choice,
 Quot.sound]
-/
#guard_msgs in
#print axioms cospifSse42_correctlyRounded

/--
info: 'LibcMath.Kernels.Cospif.cospifAvx2Fma_correctlyRounded' depends on axioms: [propext,
 sorryAx,
 Classical.choice,
 Quot.sound]
-/
#guard_msgs in
#print axioms cospifAvx2Fma_correctlyRounded

end LibcMath.Kernels.Cospif
