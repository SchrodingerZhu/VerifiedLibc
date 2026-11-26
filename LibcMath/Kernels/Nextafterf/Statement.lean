import LibcMath.Kernels.Nextafterf.Plans
import LibcMath.Framework.Spec

/-!
# Correctness statements for extracted `nextafterf` plans

Each statement names its plan. There is no default plan.
-/

namespace LibcMath.Kernels.Nextafterf

open FloatLib.Floats.Formats.BinaryInterchange
open Model (IEEERoundingMode)
open LibcMath.Libc
open LibcMath.Kernels.Nextafterf.Generated

/-- Definedness (no C++ undefined behavior) of `nextafterf` (`generic_sse2`). -/
def NextafterfGenericSse2Defined : Prop :=
  ∀ x y : Model .binary32, (GenericSse2.nextafterf x y).isSome

/-- Definedness (no C++ undefined behavior) of `nextafterf` (`sse42`). -/
def NextafterfSse42Defined : Prop :=
  ∀ x y : Model .binary32, (Sse42.nextafterf x y).isSome

/-- Definedness (no C++ undefined behavior) of `nextafterf` (`avx2_fma`). -/
def NextafterfAvx2FmaDefined : Prop :=
  ∀ x y : Model .binary32, (Avx2Fma.nextafterf x y).isSome

/-- Definedness (no C++ undefined behavior) of `nextafterf` (`aarch64`). -/
def NextafterfAArch64Defined : Prop :=
  ∀ x y : Model .binary32, (AArch64.nextafterf x y).isSome

end LibcMath.Kernels.Nextafterf
