import LibcMath.Kernels.Logbf.Plans
import LibcMath.Framework.Spec

/-!
# Correctness statements for extracted `logbf` plans

Each statement names its plan. There is no default plan.
-/

namespace LibcMath.Kernels.Logbf

open FloatLib.Floats.Formats.BinaryInterchange
open Model (IEEERoundingMode)
open LibcMath.Libc
open LibcMath.Kernels.Logbf.Generated

/-- Definedness (no C++ undefined behavior) of `logbf` (`generic_sse2`). -/
def LogbfGenericSse2Defined : Prop :=
  ∀ x : Model .binary32, (GenericSse2.logbf x).isSome

/-- Definedness (no C++ undefined behavior) of `logbf` (`sse42`). -/
def LogbfSse42Defined : Prop :=
  ∀ x : Model .binary32, (Sse42.logbf x).isSome

/-- Definedness (no C++ undefined behavior) of `logbf` (`avx2_fma`). -/
def LogbfAvx2FmaDefined : Prop :=
  ∀ x : Model .binary32, (Avx2Fma.logbf x).isSome

/-- Definedness (no C++ undefined behavior) of `logbf` (`aarch64`). -/
def LogbfAArch64Defined : Prop :=
  ∀ x : Model .binary32, (AArch64.logbf x).isSome

end LibcMath.Kernels.Logbf
