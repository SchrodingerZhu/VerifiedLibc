import LibcMath.Kernels.Scalblnf.Plans
import LibcMath.Framework.Spec

/-!
# Correctness statements for extracted `scalblnf` plans

Each statement names its plan. There is no default plan.
-/

namespace LibcMath.Kernels.Scalblnf

open FloatLib.Floats.Formats.BinaryInterchange
open Model (IEEERoundingMode)
open LibcMath.Libc
open LibcMath.Kernels.Scalblnf.Generated

/-- Definedness (no C++ undefined behavior) of `scalblnf` (`generic_sse2`). -/
def ScalblnfGenericSse2Defined : Prop :=
  ∀ m ∈ cModes, ∀ (x : Model .binary32) (n : BitVec 64), (GenericSse2.scalblnf m x n).isSome

/-- Definedness (no C++ undefined behavior) of `scalblnf` (`sse42`). -/
def ScalblnfSse42Defined : Prop :=
  ∀ m ∈ cModes, ∀ (x : Model .binary32) (n : BitVec 64), (Sse42.scalblnf m x n).isSome

/-- Definedness (no C++ undefined behavior) of `scalblnf` (`avx2_fma`). -/
def ScalblnfAvx2FmaDefined : Prop :=
  ∀ m ∈ cModes, ∀ (x : Model .binary32) (n : BitVec 64), (Avx2Fma.scalblnf m x n).isSome

/-- Definedness (no C++ undefined behavior) of `scalblnf` (`aarch64`). -/
def ScalblnfAArch64Defined : Prop :=
  ∀ m ∈ cModes, ∀ (x : Model .binary32) (n : BitVec 64), (AArch64.scalblnf m x n).isSome

end LibcMath.Kernels.Scalblnf
