import LibcMath.Kernels.Llroundf.Plans
import LibcMath.Framework.Spec

/-!
# Correctness statements for extracted `llroundf` plans

Each statement names its plan. There is no default plan.
-/

namespace LibcMath.Kernels.Llroundf

open FloatLib.Floats.Formats.BinaryInterchange
open Model (IEEERoundingMode)
open LibcMath.Libc
open LibcMath.Kernels.Llroundf.Generated

/-- Definedness (no C++ undefined behavior) of `llroundf` (`generic_sse2`). -/
def LlroundfGenericSse2Defined : Prop :=
  ∀ x : Model .binary32, (GenericSse2.llroundf x).isSome

/-- Definedness (no C++ undefined behavior) of `llroundf` (`sse42`). -/
def LlroundfSse42Defined : Prop :=
  ∀ x : Model .binary32, (Sse42.llroundf x).isSome

/-- Definedness (no C++ undefined behavior) of `llroundf` (`avx2_fma`). -/
def LlroundfAvx2FmaDefined : Prop :=
  ∀ x : Model .binary32, (Avx2Fma.llroundf x).isSome

/-- Definedness (no C++ undefined behavior) of `llroundf` (`aarch64`). -/
def LlroundfAArch64Defined : Prop :=
  ∀ x : Model .binary32, (AArch64.llroundf x).isSome

end LibcMath.Kernels.Llroundf
