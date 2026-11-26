import LibcMath.Kernels.Ufromfpf.Plans
import LibcMath.Framework.Spec

/-!
# Correctness statements for extracted `ufromfpf` plans

Each statement names its plan. There is no default plan.
-/

namespace LibcMath.Kernels.Ufromfpf

open FloatLib.Floats.Formats.BinaryInterchange
open Model (IEEERoundingMode)
open LibcMath.Libc
open LibcMath.Kernels.Ufromfpf.Generated

/-- Definedness (no C++ undefined behavior) of `ufromfpf` (`generic_sse2`). -/
def UfromfpfGenericSse2Defined : Prop :=
  ∀ m ∈ cModes, ∀ (x : Model .binary32) (r w : BitVec 32), (GenericSse2.ufromfpf m x r w).isSome

/-- Definedness (no C++ undefined behavior) of `ufromfpf` (`sse42`). -/
def UfromfpfSse42Defined : Prop :=
  ∀ m ∈ cModes, ∀ (x : Model .binary32) (r w : BitVec 32), (Sse42.ufromfpf m x r w).isSome

/-- Definedness (no C++ undefined behavior) of `ufromfpf` (`avx2_fma`). -/
def UfromfpfAvx2FmaDefined : Prop :=
  ∀ m ∈ cModes, ∀ (x : Model .binary32) (r w : BitVec 32), (Avx2Fma.ufromfpf m x r w).isSome

/-- Definedness (no C++ undefined behavior) of `ufromfpf` (`aarch64`). -/
def UfromfpfAArch64Defined : Prop :=
  ∀ m ∈ cModes, ∀ (x : Model .binary32) (r w : BitVec 32), (AArch64.ufromfpf m x r w).isSome

end LibcMath.Kernels.Ufromfpf
