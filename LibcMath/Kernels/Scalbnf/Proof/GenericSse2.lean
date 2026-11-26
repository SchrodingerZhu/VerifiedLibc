import LibcMath.Kernels.Scalbnf.Statement

/-!
# `scalbnf` (`generic_sse2`)

**Not complete.** Each theorem below that ends in `sorry` is open; `OPEN.md` lists it.
-/

namespace LibcMath.Kernels.Scalbnf.Proof.GenericSse2

open FloatLib.Floats.Formats.BinaryInterchange
open Model (IEEERoundingMode)
open LibcMath.Libc
open LibcMath.Kernels.Scalbnf.Generated

/-- **Open.** Prove `scalbnf` (`generic_sse2`) executes without C++ undefined behavior. -/
theorem scalbnfGenericSse2_defined : ScalbnfGenericSse2Defined := by
  sorry

/--
info: 'LibcMath.Kernels.Scalbnf.Proof.GenericSse2.scalbnfGenericSse2_defined' depends on axioms: [propext,
 sorryAx,
 Classical.choice,
 Quot.sound]
-/
#guard_msgs in
#print axioms scalbnfGenericSse2_defined

end LibcMath.Kernels.Scalbnf.Proof.GenericSse2
