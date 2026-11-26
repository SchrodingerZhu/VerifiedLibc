import LibcMath.Kernels.Fromfpxf.Plans
import LibcMath.Framework.Spec

/-!
# Correctness statements for extracted `fromfpxf` plans

Each statement names its plan. There is no default plan.
-/

namespace LibcMath.Kernels.Fromfpxf

open FloatLib.Floats.Formats.BinaryInterchange
open Model (IEEERoundingMode)
open LibcMath.Libc
open LibcMath.Kernels.Fromfpxf.Generated

/-- Definedness (no C++ undefined behavior) of `fromfpxf` (`generic_sse2`). -/
def FromfpxfGenericSse2Defined : Prop :=
  ∀ (x : Model .binary32) (r w : BitVec 32), (GenericSse2.fromfpxf x r w).isSome

/-- Definedness (no C++ undefined behavior) of `fromfpxf` (`sse42`). -/
def FromfpxfSse42Defined : Prop :=
  ∀ (x : Model .binary32) (r w : BitVec 32), (Sse42.fromfpxf x r w).isSome

/-- Definedness (no C++ undefined behavior) of `fromfpxf` (`avx2_fma`). -/
def FromfpxfAvx2FmaDefined : Prop :=
  ∀ (x : Model .binary32) (r w : BitVec 32), (Avx2Fma.fromfpxf x r w).isSome

/-- Definedness (no C++ undefined behavior) of `fromfpxf` (`aarch64`). -/
def FromfpxfAArch64Defined : Prop :=
  ∀ (x : Model .binary32) (r w : BitVec 32), (AArch64.fromfpxf x r w).isSome

end LibcMath.Kernels.Fromfpxf
