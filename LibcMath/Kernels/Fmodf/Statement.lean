import LibcMath.Kernels.Fmodf.Plans
import LibcMath.Framework.Spec

/-!
# Correctness statements for extracted `fmodf` plans

Each statement names its plan. There is no default plan.
-/

namespace LibcMath.Kernels.Fmodf

open FloatLib.Floats.Formats.BinaryInterchange
open Model (IEEERoundingMode)
open LibcMath.Libc
open LibcMath.Kernels.Fmodf.Generated

/-- Definedness (no C++ undefined behavior) of `fmodf` (`generic_sse2`). -/
def FmodfGenericSse2Defined : Prop :=
  ∀ x y : Model .binary32, (GenericSse2.fmodf x y).isSome

/-- Definedness (no C++ undefined behavior) of `fmodf` (`sse42`). -/
def FmodfSse42Defined : Prop :=
  ∀ x y : Model .binary32, (Sse42.fmodf x y).isSome

/-- Definedness (no C++ undefined behavior) of `fmodf` (`avx2_fma`). -/
def FmodfAvx2FmaDefined : Prop :=
  ∀ x y : Model .binary32, (Avx2Fma.fmodf x y).isSome

/-- Definedness (no C++ undefined behavior) of `fmodf` (`aarch64`). -/
def FmodfAArch64Defined : Prop :=
  ∀ x y : Model .binary32, (AArch64.fmodf x y).isSome

end LibcMath.Kernels.Fmodf
