import LibcMath.Kernels.Lrintf.Plans
import LibcMath.Framework.Spec

/-!
# Correctness statements for extracted `lrintf` plans

Each statement names its plan. There is no default plan.
-/

namespace LibcMath.Kernels.Lrintf

open FloatLib.Floats.Formats.BinaryInterchange
open Model (IEEERoundingMode)
open LibcMath.Libc
open LibcMath.Kernels.Lrintf.Generated

/-- Definedness (no C++ undefined behavior) of `lrintf` (`generic_sse2`). -/
def LrintfGenericSse2Defined : Prop :=
  ∀ m ∈ cModes, ∀ x : Model .binary32, (GenericSse2.lrintf m x).isSome

/-- Definedness (no C++ undefined behavior) of `lrintf` (`sse42`). -/
def LrintfSse42Defined : Prop :=
  ∀ m ∈ cModes, ∀ x : Model .binary32, (Sse42.lrintf m x).isSome

/-- Definedness (no C++ undefined behavior) of `lrintf` (`avx2_fma`). -/
def LrintfAvx2FmaDefined : Prop :=
  ∀ m ∈ cModes, ∀ x : Model .binary32, (Avx2Fma.lrintf m x).isSome

/-- Definedness (no C++ undefined behavior) of `lrintf` (`aarch64`). -/
def LrintfAArch64Defined : Prop :=
  ∀ m ∈ cModes, ∀ x : Model .binary32, (AArch64.lrintf m x).isSome

end LibcMath.Kernels.Lrintf
