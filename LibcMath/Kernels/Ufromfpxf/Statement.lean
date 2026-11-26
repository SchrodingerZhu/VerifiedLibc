import LibcMath.Kernels.Ufromfpxf.Plans
import LibcMath.Framework.Spec

/-!
# Correctness statements for extracted `ufromfpxf` plans

Each statement names its plan. There is no default plan.
-/

namespace LibcMath.Kernels.Ufromfpxf

open FloatLib.Floats.Formats.BinaryInterchange
open Model (IEEERoundingMode)
open LibcMath.Libc
open LibcMath.Kernels.Ufromfpxf.Generated

/-- Definedness (no C++ undefined behavior) of `ufromfpxf` (`generic_sse2`). -/
def UfromfpxfGenericSse2Defined : Prop :=
  ∀ m ∈ cModes, ∀ (x : Model .binary32) (r w : BitVec 32), (GenericSse2.ufromfpxf m x r w).isSome

/-- Definedness (no C++ undefined behavior) of `ufromfpxf` (`sse42`). -/
def UfromfpxfSse42Defined : Prop :=
  ∀ m ∈ cModes, ∀ (x : Model .binary32) (r w : BitVec 32), (Sse42.ufromfpxf m x r w).isSome

/-- Definedness (no C++ undefined behavior) of `ufromfpxf` (`avx2_fma`). -/
def UfromfpxfAvx2FmaDefined : Prop :=
  ∀ m ∈ cModes, ∀ (x : Model .binary32) (r w : BitVec 32), (Avx2Fma.ufromfpxf m x r w).isSome

/-- Definedness (no C++ undefined behavior) of `ufromfpxf` (`aarch64`). -/
def UfromfpxfAArch64Defined : Prop :=
  ∀ m ∈ cModes, ∀ (x : Model .binary32) (r w : BitVec 32), (AArch64.ufromfpxf m x r w).isSome

end LibcMath.Kernels.Ufromfpxf
