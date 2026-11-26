import LibcMath.Kernels.Setpayloadf.Plans
import LibcMath.Framework.Spec

/-!
# Correctness statements for extracted `setpayloadf` plans

Each statement names its plan. There is no default plan.
-/

namespace LibcMath.Kernels.Setpayloadf

open FloatLib.Floats.Formats.BinaryInterchange
open Model (IEEERoundingMode)
open LibcMath.Libc
open LibcMath.Kernels.Setpayloadf.Generated

/-- Definedness (no C++ undefined behavior) of `setpayloadf` (`generic_sse2`). -/
def SetpayloadfGenericSse2Defined : Prop :=
  ∀ m ∈ cModes, ∀ x : Model .binary32, (GenericSse2.setpayloadf m x).isSome

/-- Definedness (no C++ undefined behavior) of `setpayloadf` (`sse42`). -/
def SetpayloadfSse42Defined : Prop :=
  ∀ m ∈ cModes, ∀ x : Model .binary32, (Sse42.setpayloadf m x).isSome

/-- Definedness (no C++ undefined behavior) of `setpayloadf` (`avx2_fma`). -/
def SetpayloadfAvx2FmaDefined : Prop :=
  ∀ m ∈ cModes, ∀ x : Model .binary32, (Avx2Fma.setpayloadf m x).isSome

/-- Definedness (no C++ undefined behavior) of `setpayloadf` (`aarch64`). -/
def SetpayloadfAArch64Defined : Prop :=
  ∀ m ∈ cModes, ∀ x : Model .binary32, (AArch64.setpayloadf m x).isSome

end LibcMath.Kernels.Setpayloadf
