import LibcMath.Framework.Spec
import LibcMath.Kernels.Scalbnf.Generated.GenericSse2

/-!
# Extracted `scalbnf` generic SSE2 plan

Collects the extracted LLVM libc `scalbnf` (`generic_sse2`) plan and states its obligation.
Every statement names its microarch plan explicitly.
-/

namespace LibcMath.Kernels.Scalbnf

open FloatLib.Floats.Formats.BinaryInterchange
open Model (IEEERoundingMode)
open LibcMath.Libc
open LibcMath.Kernels.Scalbnf.Generated

/-- Definedness (no C++ undefined behavior) of `scalbnf` (`generic_sse2`). -/
def ScalbnfGenericSse2Defined : Prop :=
  ∀ m ∈ cModes, ∀ (x : Model .binary32) (n : BitVec 32), (GenericSse2.scalbnf m x n).isSome

/-- **Open.** Prove `scalbnf` (`generic_sse2`) executes without C++ undefined behavior. -/
theorem scalbnfGenericSse2_defined : ScalbnfGenericSse2Defined := by
  sorry

/--
info: 'LibcMath.Kernels.Scalbnf.scalbnfGenericSse2_defined' depends on axioms: [propext,
 sorryAx,
 Classical.choice,
 Quot.sound]
-/
#guard_msgs in
#print axioms scalbnfGenericSse2_defined

end LibcMath.Kernels.Scalbnf
