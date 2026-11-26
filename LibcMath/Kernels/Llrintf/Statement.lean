import LibcMath.Kernels.Llrintf.Plans
import LibcMath.Framework.Spec

/-!
# Correctness statements for extracted `llrintf` plans

Each statement names its plan. There is no default plan.
-/

namespace LibcMath.Kernels.Llrintf

open FloatLib.Floats.Formats.BinaryInterchange
open Model (IEEERoundingMode)
open LibcMath.Libc
open LibcMath.Kernels.Llrintf.Generated

/-- Definedness (no C++ undefined behavior) of `llrintf` (`generic_sse2`). -/
def LlrintfGenericSse2Defined : Prop :=
  ∀ m ∈ cModes, ∀ x : Model .binary32, (GenericSse2.llrintf m x).isSome

/-- Definedness (no C++ undefined behavior) of `llrintf` (`sse42`). -/
def LlrintfSse42Defined : Prop :=
  ∀ m ∈ cModes, ∀ x : Model .binary32, (Sse42.llrintf m x).isSome

/-- Definedness (no C++ undefined behavior) of `llrintf` (`avx2_fma`). -/
def LlrintfAvx2FmaDefined : Prop :=
  ∀ m ∈ cModes, ∀ x : Model .binary32, (Avx2Fma.llrintf m x).isSome

/-- Definedness (no C++ undefined behavior) of `llrintf` (`aarch64`). -/
def LlrintfAArch64Defined : Prop :=
  ∀ m ∈ cModes, ∀ x : Model .binary32, (AArch64.llrintf m x).isSome

end LibcMath.Kernels.Llrintf
