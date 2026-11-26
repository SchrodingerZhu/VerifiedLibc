import LibcMath.Kernels.Scalbnf.Statement

/-!
# `scalbnf` (`aarch64`)

**Not complete.** Each theorem below that ends in `sorry` is open; `OPEN.md` lists it.
-/

namespace LibcMath.Kernels.Scalbnf.Proof.AArch64

open FloatLib.Floats.Formats.BinaryInterchange
open Model (IEEERoundingMode)
open LibcMath.Libc
open LibcMath.Kernels.Scalbnf.Generated

/-- **Open.** Prove `scalbnf` (`aarch64`) executes without C++ undefined behavior. -/
theorem scalbnfAArch64_defined : ScalbnfAArch64Defined := by
  sorry

/--
info: 'LibcMath.Kernels.Scalbnf.Proof.AArch64.scalbnfAArch64_defined' depends on axioms: [propext,
 sorryAx,
 Classical.choice,
 Quot.sound]
-/
#guard_msgs in
#print axioms scalbnfAArch64_defined

end LibcMath.Kernels.Scalbnf.Proof.AArch64
