import LibcMath.Kernels.Scalbnf.Plans
import LibcMath.Framework.Spec

/-!
# Correctness statements for extracted `scalbnf` plans

Each statement names its plan. There is no default plan.
-/

namespace LibcMath.Kernels.Scalbnf

open FloatLib.Floats.Formats.BinaryInterchange
open Model (IEEERoundingMode)
open LibcMath.Libc
open LibcMath.Kernels.Scalbnf.Generated

/-- Definedness (no C++ undefined behavior) of `scalbnf` (`generic_sse2`). -/
def ScalbnfGenericSse2Defined : Prop :=
  ∀ m ∈ cModes, ∀ (x : Model .binary32) (n : BitVec 32), (GenericSse2.scalbnf m x n).isSome

/-- Definedness (no C++ undefined behavior) of `scalbnf` (`sse42`). -/
def ScalbnfSse42Defined : Prop :=
  ∀ m ∈ cModes, ∀ (x : Model .binary32) (n : BitVec 32), (Sse42.scalbnf m x n).isSome

/-- Definedness (no C++ undefined behavior) of `scalbnf` (`avx2_fma`). -/
def ScalbnfAvx2FmaDefined : Prop :=
  ∀ m ∈ cModes, ∀ (x : Model .binary32) (n : BitVec 32), (Avx2Fma.scalbnf m x n).isSome

/-- Definedness (no C++ undefined behavior) of `scalbnf` (`aarch64`). -/
def ScalbnfAArch64Defined : Prop :=
  ∀ m ∈ cModes, ∀ (x : Model .binary32) (n : BitVec 32), (AArch64.scalbnf m x n).isSome

end LibcMath.Kernels.Scalbnf
