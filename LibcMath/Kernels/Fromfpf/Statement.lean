import LibcMath.Kernels.Fromfpf.Plans
import LibcMath.Framework.Spec

/-!
# Correctness statements for extracted `fromfpf` plans

Each statement names its plan. There is no default plan.
-/

namespace LibcMath.Kernels.Fromfpf

open FloatLib.Floats.Formats.BinaryInterchange
open Model (IEEERoundingMode)
open LibcMath.Libc
open LibcMath.Kernels.Fromfpf.Generated

/-- Definedness (no C++ undefined behavior) of `fromfpf` (`generic_sse2`). -/
def FromfpfGenericSse2Defined : Prop :=
  ∀ (x : Model .binary32) (r w : BitVec 32), (GenericSse2.fromfpf x r w).isSome

/-- Definedness (no C++ undefined behavior) of `fromfpf` (`sse42`). -/
def FromfpfSse42Defined : Prop :=
  ∀ (x : Model .binary32) (r w : BitVec 32), (Sse42.fromfpf x r w).isSome

/-- Definedness (no C++ undefined behavior) of `fromfpf` (`avx2_fma`). -/
def FromfpfAvx2FmaDefined : Prop :=
  ∀ (x : Model .binary32) (r w : BitVec 32), (Avx2Fma.fromfpf x r w).isSome

/-- Definedness (no C++ undefined behavior) of `fromfpf` (`aarch64`). -/
def FromfpfAArch64Defined : Prop :=
  ∀ (x : Model .binary32) (r w : BitVec 32), (AArch64.fromfpf x r w).isSome

end LibcMath.Kernels.Fromfpf
