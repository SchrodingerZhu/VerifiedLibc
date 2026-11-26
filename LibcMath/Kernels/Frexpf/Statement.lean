import LibcMath.Kernels.Frexpf.Plans
import LibcMath.Framework.Spec

/-!
# Correctness statements for extracted `frexpf` plans

Each statement names its plan. There is no default plan.
-/

namespace LibcMath.Kernels.Frexpf

open FloatLib.Floats.Formats.BinaryInterchange
open Model (IEEERoundingMode)
open LibcMath.Libc
open LibcMath.Kernels.Frexpf.Generated

/-- Definedness (no C++ undefined behavior) of `frexpf` (`generic_sse2`). -/
def FrexpfGenericSse2Defined : Prop :=
  ∀ x : Model .binary32, (GenericSse2.frexpf x).isSome

/-- Definedness (no C++ undefined behavior) of `frexpf` (`sse42`). -/
def FrexpfSse42Defined : Prop :=
  ∀ x : Model .binary32, (Sse42.frexpf x).isSome

/-- Definedness (no C++ undefined behavior) of `frexpf` (`avx2_fma`). -/
def FrexpfAvx2FmaDefined : Prop :=
  ∀ x : Model .binary32, (Avx2Fma.frexpf x).isSome

/-- Definedness (no C++ undefined behavior) of `frexpf` (`aarch64`). -/
def FrexpfAArch64Defined : Prop :=
  ∀ x : Model .binary32, (AArch64.frexpf x).isSome

end LibcMath.Kernels.Frexpf
