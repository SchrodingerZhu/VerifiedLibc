import LibcMath.Framework.Spec
import LibcMath.Testing.Oracle.FloatLib
import LibcMath.Kernels.Sincosf.Generated.Sse2
import LibcMath.Kernels.Sincosf.Generated.Sse42
import LibcMath.Kernels.Sincosf.Generated.Avx2Fma

/-!
# Extracted `sincosf` microarch plans

Collects three extracted LLVM libc `sincosf` microarch plans (SSE2, SSE4.2, AVX2+FMA).
Every statement names its microarch plan explicitly.
-/

namespace LibcMath.Kernels.Sincosf

open FloatLib.Floats.Formats.BinaryInterchange
open LibcMath.Kernels.Sincosf.Generated

/-- Correct rounding of `sincosf` (`sse2`) in all four C modes. -/
def SincosfSse2CorrectlyRounded : Prop :=
  FnCorrectlyRounded (SamePairValue (fmt := .binary32)) FloatLibSpec.sincos cModes
    (fun mode x => Sse2.sincosf mode x default default)

/-- **Open.** Prove `sincosf` (`sse2`) is correctly rounded in all four C modes. -/
theorem sincosfSse2_correctlyRounded : SincosfSse2CorrectlyRounded := by
  sorry

/-- Correct rounding of `sincosf` (`sse42`) in all four C modes. -/
def SincosfSse42CorrectlyRounded : Prop :=
  FnCorrectlyRounded (SamePairValue (fmt := .binary32)) FloatLibSpec.sincos cModes
    (fun mode x => Sse42.sincosf mode x default default)

/-- **Open.** Prove `sincosf` (`sse42`) is correctly rounded in all four C modes. -/
theorem sincosfSse42_correctlyRounded : SincosfSse42CorrectlyRounded := by
  sorry

/-- Correct rounding of `sincosf` (`avx2_fma`) in all four C modes. -/
def SincosfAvx2FmaCorrectlyRounded : Prop :=
  FnCorrectlyRounded (SamePairValue (fmt := .binary32)) FloatLibSpec.sincos cModes
    (fun mode x => Avx2Fma.sincosf mode x default default)

/-- **Open.** Prove `sincosf` (`avx2_fma`) is correctly rounded in all four C modes. -/
theorem sincosfAvx2Fma_correctlyRounded : SincosfAvx2FmaCorrectlyRounded := by
  sorry

/--
info: 'LibcMath.Kernels.Sincosf.sincosfSse2_correctlyRounded' depends on axioms: [propext,
 sorryAx,
 Classical.choice,
 Quot.sound]
-/
#guard_msgs in
#print axioms sincosfSse2_correctlyRounded

/--
info: 'LibcMath.Kernels.Sincosf.sincosfSse42_correctlyRounded' depends on axioms: [propext,
 sorryAx,
 Classical.choice,
 Quot.sound]
-/
#guard_msgs in
#print axioms sincosfSse42_correctlyRounded

/--
info: 'LibcMath.Kernels.Sincosf.sincosfAvx2Fma_correctlyRounded' depends on axioms: [propext,
 sorryAx,
 Classical.choice,
 Quot.sound]
-/
#guard_msgs in
#print axioms sincosfAvx2Fma_correctlyRounded

end LibcMath.Kernels.Sincosf
