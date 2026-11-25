import LibcMath.Framework.Spec
import LibcMath.Testing.Oracle.FloatLib
import LibcMath.Kernels.Tanhf.Generated.Sse2
import LibcMath.Kernels.Tanhf.Generated.Sse42
import LibcMath.Kernels.Tanhf.Generated.Avx2Fma

/-!
# Extracted `tanhf` microarch plans

Collects 3 extracted LLVM libc `tanhf` plans and states plan-qualified obligations.
Every statement names its microarch plan explicitly.
-/

namespace LibcMath.Kernels.Tanhf

open FloatLib.Floats.Formats.BinaryInterchange
open LibcMath.Libc
open LibcMath.Kernels.Tanhf.Generated

/-- Lists all 3 extracted `tanhf` plans. -/
def allPlans : List (UnaryKernel .binary32) :=
  [ Sse2.kernel
  , Sse42.kernel
  , Avx2Fma.kernel ]

/-- Correct rounding of `tanhf` (`sse2`) in all four C modes. -/
def TanhfSse2CorrectlyRounded : Prop :=
  UnaryFnCorrectlyRounded FloatLibSpec.tanh cModes Sse2.kernel.eval

/-- **Open.** Prove `tanhf` (`sse2`) is correctly rounded in all four C modes. -/
theorem tanhfSse2_correctlyRounded : TanhfSse2CorrectlyRounded := by
  sorry

/-- Correct rounding of `tanhf` (`sse42`) in all four C modes. -/
def TanhfSse42CorrectlyRounded : Prop :=
  UnaryFnCorrectlyRounded FloatLibSpec.tanh cModes Sse42.kernel.eval

/-- **Open.** Prove `tanhf` (`sse42`) is correctly rounded in all four C modes. -/
theorem tanhfSse42_correctlyRounded : TanhfSse42CorrectlyRounded := by
  sorry

/-- Correct rounding of `tanhf` (`avx2_fma`) in all four C modes. -/
def TanhfAvx2FmaCorrectlyRounded : Prop :=
  UnaryFnCorrectlyRounded FloatLibSpec.tanh cModes Avx2Fma.kernel.eval

/-- **Open.** Prove `tanhf` (`avx2_fma`) is correctly rounded in all four C modes. -/
theorem tanhfAvx2Fma_correctlyRounded : TanhfAvx2FmaCorrectlyRounded := by
  sorry

/--
info: 'LibcMath.Kernels.Tanhf.tanhfSse2_correctlyRounded' depends on axioms: [propext, sorryAx, Classical.choice, Quot.sound]
-/
#guard_msgs in
#print axioms tanhfSse2_correctlyRounded

/--
info: 'LibcMath.Kernels.Tanhf.tanhfSse42_correctlyRounded' depends on axioms: [propext, sorryAx, Classical.choice, Quot.sound]
-/
#guard_msgs in
#print axioms tanhfSse42_correctlyRounded

/--
info: 'LibcMath.Kernels.Tanhf.tanhfAvx2Fma_correctlyRounded' depends on axioms: [propext,
 sorryAx,
 Classical.choice,
 Quot.sound]
-/
#guard_msgs in
#print axioms tanhfAvx2Fma_correctlyRounded

end LibcMath.Kernels.Tanhf
