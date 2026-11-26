import LibcMath.Kernels.Sincosf.Plans
import LibcMath.Framework.Spec
import LibcMath.Testing.Oracle.FloatLib

/-!
# Correctness statements for extracted `sincosf` plans

Each statement names its plan. There is no default plan.
-/

namespace LibcMath.Kernels.Sincosf

open FloatLib.Floats.Formats.BinaryInterchange
open LibcMath.Kernels.Sincosf.Generated

/-- Correct rounding of `sincosf` (`sse2`) in all four C modes. -/
def SincosfSse2CorrectlyRounded : Prop :=
  FnCorrectlyRounded (SamePairValue (fmt := .binary32)) FloatLibSpec.sincos cModes
    (fun mode x => Sse2.sincosf mode x default default)

/-- Correct rounding of `sincosf` (`sse42`) in all four C modes. -/
def SincosfSse42CorrectlyRounded : Prop :=
  FnCorrectlyRounded (SamePairValue (fmt := .binary32)) FloatLibSpec.sincos cModes
    (fun mode x => Sse42.sincosf mode x default default)

/-- Correct rounding of `sincosf` (`avx2_fma`) in all four C modes. -/
def SincosfAvx2FmaCorrectlyRounded : Prop :=
  FnCorrectlyRounded (SamePairValue (fmt := .binary32)) FloatLibSpec.sincos cModes
    (fun mode x => Avx2Fma.sincosf mode x default default)

/-- Correct rounding of `sincosf` (`aarch64`) in all four C modes. -/
def SincosfAArch64CorrectlyRounded : Prop :=
  FnCorrectlyRounded (SamePairValue (fmt := .binary32)) FloatLibSpec.sincos cModes
    (fun mode x => AArch64.sincosf mode x default default)

end LibcMath.Kernels.Sincosf
