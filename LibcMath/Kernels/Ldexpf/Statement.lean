import LibcMath.Kernels.Ldexpf.Plans
import LibcMath.Framework.Spec

/-!
# Correctness statements for extracted `ldexpf` plans

Each statement names its plan. There is no default plan.
-/

namespace LibcMath.Kernels.Ldexpf

open FloatLib.Floats.Formats.BinaryInterchange
open Model (IEEERoundingMode)
open LibcMath.Libc
open LibcMath.Kernels.Ldexpf.Generated

/-- Definedness (no C++ undefined behavior) of `ldexpf` (`generic_sse2`). -/
def LdexpfGenericSse2Defined : Prop :=
  ∀ m ∈ cModes, ∀ (x : Model .binary32) (e : BitVec 32), (GenericSse2.ldexpf m x e).isSome

/-- Definedness (no C++ undefined behavior) of `ldexpf` (`sse42`). -/
def LdexpfSse42Defined : Prop :=
  ∀ m ∈ cModes, ∀ (x : Model .binary32) (e : BitVec 32), (Sse42.ldexpf m x e).isSome

/-- Definedness (no C++ undefined behavior) of `ldexpf` (`avx2_fma`). -/
def LdexpfAvx2FmaDefined : Prop :=
  ∀ m ∈ cModes, ∀ (x : Model .binary32) (e : BitVec 32), (Avx2Fma.ldexpf m x e).isSome

/-- Definedness (no C++ undefined behavior) of `ldexpf` (`aarch64`). -/
def LdexpfAArch64Defined : Prop :=
  ∀ m ∈ cModes, ∀ (x : Model .binary32) (e : BitVec 32), (AArch64.ldexpf m x e).isSome

end LibcMath.Kernels.Ldexpf
