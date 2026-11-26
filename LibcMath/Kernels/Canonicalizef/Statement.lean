import LibcMath.Kernels.Canonicalizef.Plans
import LibcMath.Framework.Spec

/-!
# Correctness statements for extracted `canonicalizef` plans

Each statement names its plan. There is no default plan.
-/

namespace LibcMath.Kernels.Canonicalizef

open FloatLib.Floats.Formats.BinaryInterchange
open Model (IEEERoundingMode)
open LibcMath.Libc
open LibcMath.Kernels.Canonicalizef.Generated

/-- Definedness (no C++ undefined behavior) of `canonicalizef` (`generic_sse2`). -/
def CanonicalizefGenericSse2Defined : Prop :=
  ∀ x : Model .binary32, (GenericSse2.canonicalizef x).isSome

/-- Definedness (no C++ undefined behavior) of `canonicalizef` (`sse42`). -/
def CanonicalizefSse42Defined : Prop :=
  ∀ x : Model .binary32, (Sse42.canonicalizef x).isSome

/-- Definedness (no C++ undefined behavior) of `canonicalizef` (`avx2_fma`). -/
def CanonicalizefAvx2FmaDefined : Prop :=
  ∀ x : Model .binary32, (Avx2Fma.canonicalizef x).isSome

/-- Definedness (no C++ undefined behavior) of `canonicalizef` (`aarch64`). -/
def CanonicalizefAArch64Defined : Prop :=
  ∀ x : Model .binary32, (AArch64.canonicalizef x).isSome

end LibcMath.Kernels.Canonicalizef
