import LibcMath.Kernels.Modff.Plans
import LibcMath.Framework.Spec

/-!
# Correctness statements for extracted `modff` plans

Each statement names its plan. There is no default plan.
-/

namespace LibcMath.Kernels.Modff

open FloatLib.Floats.Formats.BinaryInterchange
open Model (IEEERoundingMode)
open LibcMath.Libc
open LibcMath.Kernels.Modff.Generated

/-- Definedness (no C++ undefined behavior) of `modff` (`generic_sse2`). -/
def ModffGenericSse2Defined : Prop :=
  ∀ m ∈ cModes, ∀ x : Model .binary32, (GenericSse2.modff m x).isSome

/-- Definedness (no C++ undefined behavior) of `modff` (`sse42`). -/
def ModffSse42Defined : Prop :=
  ∀ m ∈ cModes, ∀ x : Model .binary32, (Sse42.modff m x).isSome

/-- Definedness (no C++ undefined behavior) of `modff` (`avx2_fma`). -/
def ModffAvx2FmaDefined : Prop :=
  ∀ m ∈ cModes, ∀ x : Model .binary32, (Avx2Fma.modff m x).isSome

/-- Definedness (no C++ undefined behavior) of `modff` (`aarch64`). -/
def ModffAArch64Defined : Prop :=
  ∀ m ∈ cModes, ∀ x : Model .binary32, (AArch64.modff m x).isSome

end LibcMath.Kernels.Modff
