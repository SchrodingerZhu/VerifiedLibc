import LibcMath.Kernels.Lroundf.Plans
import LibcMath.Framework.Spec

/-!
# Correctness statements for extracted `lroundf` plans

Each statement names its plan. There is no default plan.
-/

namespace LibcMath.Kernels.Lroundf

open FloatLib.Floats.Formats.BinaryInterchange
open Model (IEEERoundingMode)
open LibcMath.Libc
open LibcMath.Kernels.Lroundf.Generated

/-- Definedness (no C++ undefined behavior) of `lroundf` (`generic_sse2`). -/
def LroundfGenericSse2Defined : Prop :=
  ∀ x : Model .binary32, (GenericSse2.lroundf x).isSome

/-- Definedness (no C++ undefined behavior) of `lroundf` (`sse42`). -/
def LroundfSse42Defined : Prop :=
  ∀ x : Model .binary32, (Sse42.lroundf x).isSome

/-- Definedness (no C++ undefined behavior) of `lroundf` (`avx2_fma`). -/
def LroundfAvx2FmaDefined : Prop :=
  ∀ x : Model .binary32, (Avx2Fma.lroundf x).isSome

/-- Definedness (no C++ undefined behavior) of `lroundf` (`aarch64`). -/
def LroundfAArch64Defined : Prop :=
  ∀ x : Model .binary32, (AArch64.lroundf x).isSome

end LibcMath.Kernels.Lroundf
