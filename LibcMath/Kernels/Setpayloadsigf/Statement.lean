import LibcMath.Kernels.Setpayloadsigf.Plans
import LibcMath.Framework.Spec

/-!
# Correctness statements for extracted `setpayloadsigf` plans

Each statement names its plan. There is no default plan.
-/

namespace LibcMath.Kernels.Setpayloadsigf

open FloatLib.Floats.Formats.BinaryInterchange
open Model (IEEERoundingMode)
open LibcMath.Libc
open LibcMath.Kernels.Setpayloadsigf.Generated

/-- Definedness (no C++ undefined behavior) of `setpayloadsigf` (`generic_sse2`). -/
def SetpayloadsigfGenericSse2Defined : Prop :=
  ∀ m ∈ cModes, ∀ x : Model .binary32, (GenericSse2.setpayloadsigf m x).isSome

/-- Definedness (no C++ undefined behavior) of `setpayloadsigf` (`sse42`). -/
def SetpayloadsigfSse42Defined : Prop :=
  ∀ m ∈ cModes, ∀ x : Model .binary32, (Sse42.setpayloadsigf m x).isSome

/-- Definedness (no C++ undefined behavior) of `setpayloadsigf` (`avx2_fma`). -/
def SetpayloadsigfAvx2FmaDefined : Prop :=
  ∀ m ∈ cModes, ∀ x : Model .binary32, (Avx2Fma.setpayloadsigf m x).isSome

/-- Definedness (no C++ undefined behavior) of `setpayloadsigf` (`aarch64`). -/
def SetpayloadsigfAArch64Defined : Prop :=
  ∀ m ∈ cModes, ∀ x : Model .binary32, (AArch64.setpayloadsigf m x).isSome

end LibcMath.Kernels.Setpayloadsigf
