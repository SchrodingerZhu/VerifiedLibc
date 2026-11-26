import LibcMath.Kernels.Exp2m1f.Plans
import LibcMath.Framework.Spec
import LibcMath.Libc.DSL
import LibcMath.Testing.Oracle.FloatLib

/-!
# Correctness statements for extracted `exp2m1f` plans

Each statement names its plan. There is no default plan.
-/

namespace LibcMath.Kernels.Exp2m1f

open FloatLib.Floats.Formats.BinaryInterchange
open LibcMath.Libc
open LibcMath.Libc.DSL
open LibcMath.Kernels.Exp2m1f.Generated

/-- Correct rounding of `exp2m1f` (`sse2`) on all inputs except negative NaNs. -/
def Exp2m1fSse2CorrectlyRoundedNonNegNaN : Prop :=
  ∀ mode ∈ cModes, ∀ x : Model .binary32, !(x.isNaN && x.signBit) →
    ∃ y, Sse2.kernel.eval mode x = some y ∧ SameValue y (FloatLibSpec.exp2m1 mode x)

/-- Correct rounding of `exp2m1f` (`sse42`) on all inputs except negative NaNs. -/
def Exp2m1fSse42CorrectlyRoundedNonNegNaN : Prop :=
  ∀ mode ∈ cModes, ∀ x : Model .binary32, !(x.isNaN && x.signBit) →
    ∃ y, Sse42.kernel.eval mode x = some y ∧ SameValue y (FloatLibSpec.exp2m1 mode x)

/-- Correct rounding of `exp2m1f` (`avx2_fma`) on all inputs except negative NaNs. -/
def Exp2m1fAvx2FmaCorrectlyRoundedNonNegNaN : Prop :=
  ∀ mode ∈ cModes, ∀ x : Model .binary32, !(x.isNaN && x.signBit) →
    ∃ y, Avx2Fma.kernel.eval mode x = some y ∧ SameValue y (FloatLibSpec.exp2m1 mode x)

/-- Correct rounding of `exp2m1f` (`aarch64`) on all inputs except negative NaNs. -/
def Exp2m1fAArch64CorrectlyRoundedNonNegNaN : Prop :=
  ∀ mode ∈ cModes, ∀ x : Model .binary32, !(x.isNaN && x.signBit) →
    ∃ y, AArch64.kernel.eval mode x = some y ∧ SameValue y (FloatLibSpec.exp2m1 mode x)

end LibcMath.Kernels.Exp2m1f
