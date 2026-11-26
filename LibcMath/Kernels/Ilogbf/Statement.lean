import LibcMath.Kernels.Ilogbf.Plans
import LibcMath.Framework.Spec

/-!
# Correctness statements for extracted `ilogbf` plans

Each statement names its plan. There is no default plan.
-/

namespace LibcMath.Kernels.Ilogbf

open FloatLib.Floats.Formats.BinaryInterchange
open Model (IEEERoundingMode)
open LibcMath.Libc
open LibcMath.Kernels.Ilogbf.Generated

/-- Definedness (no C++ undefined behavior) of `ilogbf` (`generic_sse2`). -/
def IlogbfGenericSse2Defined : Prop :=
  ∀ x : Model .binary32, (GenericSse2.ilogbf x).isSome

/-- Definedness (no C++ undefined behavior) of `ilogbf` (`sse42`). -/
def IlogbfSse42Defined : Prop :=
  ∀ x : Model .binary32, (Sse42.ilogbf x).isSome

/-- Definedness (no C++ undefined behavior) of `ilogbf` (`avx2_fma`). -/
def IlogbfAvx2FmaDefined : Prop :=
  ∀ x : Model .binary32, (Avx2Fma.ilogbf x).isSome

/-- Definedness (no C++ undefined behavior) of `ilogbf` (`aarch64`). -/
def IlogbfAArch64Defined : Prop :=
  ∀ x : Model .binary32, (AArch64.ilogbf x).isSome

end LibcMath.Kernels.Ilogbf
