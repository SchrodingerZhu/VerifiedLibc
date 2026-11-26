import LibcMath.Kernels.Scalbnf.Statement

/-!
# `scalbnf` (`sse42`)

**Not complete.** Each theorem below that ends in `sorry` is open; `OPEN.md` lists it.
-/

namespace LibcMath.Kernels.Scalbnf.Proof.Sse42

open FloatLib.Floats.Formats.BinaryInterchange
open Model (IEEERoundingMode)
open LibcMath.Libc
open LibcMath.Kernels.Scalbnf.Generated

/-- **Open.** Prove `scalbnf` (`sse42`) executes without C++ undefined behavior. -/
theorem scalbnfSse42_defined : ScalbnfSse42Defined := by
  sorry

/--
info: 'LibcMath.Kernels.Scalbnf.Proof.Sse42.scalbnfSse42_defined' depends on axioms: [propext,
 sorryAx,
 Classical.choice,
 Quot.sound]
-/
#guard_msgs in
#print axioms scalbnfSse42_defined

end LibcMath.Kernels.Scalbnf.Proof.Sse42
