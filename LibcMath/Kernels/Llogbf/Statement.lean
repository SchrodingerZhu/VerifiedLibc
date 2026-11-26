import LibcMath.Kernels.Llogbf.Plans
import LibcMath.Framework.Spec

/-!
# Correctness statements for extracted `llogbf` plans

Each statement names its plan. There is no default plan.
-/

namespace LibcMath.Kernels.Llogbf

open FloatLib.Floats.Formats.BinaryInterchange
open Model (IEEERoundingMode)
open LibcMath.Libc
open LibcMath.Kernels.Llogbf.Generated

/-- Definedness (no C++ undefined behavior) of `llogbf` (`generic_sse2`). -/
def LlogbfGenericSse2Defined : Prop :=
  ∀ x : Model .binary32, (GenericSse2.llogbf x).isSome

/-- Definedness (no C++ undefined behavior) of `llogbf` (`sse42`). -/
def LlogbfSse42Defined : Prop :=
  ∀ x : Model .binary32, (Sse42.llogbf x).isSome

/-- Definedness (no C++ undefined behavior) of `llogbf` (`avx2_fma`). -/
def LlogbfAvx2FmaDefined : Prop :=
  ∀ x : Model .binary32, (Avx2Fma.llogbf x).isSome

/-- Definedness (no C++ undefined behavior) of `llogbf` (`aarch64`). -/
def LlogbfAArch64Defined : Prop :=
  ∀ x : Model .binary32, (AArch64.llogbf x).isSome

end LibcMath.Kernels.Llogbf
