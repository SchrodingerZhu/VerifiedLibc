import LibcMath.Kernels.Remquof.Plans
import LibcMath.Framework.Spec

/-!
# Correctness statements for extracted `remquof` plans

Each statement names its plan. There is no default plan.
-/

namespace LibcMath.Kernels.Remquof

open FloatLib.Floats.Formats.BinaryInterchange
open Model (IEEERoundingMode)
open LibcMath.Libc
open LibcMath.Kernels.Remquof.Generated

/-- Definedness (no C++ undefined behavior) of `remquof` (`generic_sse2`). -/
def RemquofGenericSse2Defined : Prop :=
  ∀ m ∈ cModes, ∀ x y : Model .binary32, (GenericSse2.remquof m x y).isSome

/-- Definedness (no C++ undefined behavior) of `remquof` (`sse42`). -/
def RemquofSse42Defined : Prop :=
  ∀ m ∈ cModes, ∀ x y : Model .binary32, (Sse42.remquof m x y).isSome

/-- Definedness (no C++ undefined behavior) of `remquof` (`avx2_fma`). -/
def RemquofAvx2FmaDefined : Prop :=
  ∀ m ∈ cModes, ∀ x y : Model .binary32, (Avx2Fma.remquof m x y).isSome

/-- Definedness (no C++ undefined behavior) of `remquof` (`aarch64`). -/
def RemquofAArch64Defined : Prop :=
  ∀ m ∈ cModes, ∀ x y : Model .binary32, (AArch64.remquof m x y).isSome

end LibcMath.Kernels.Remquof
