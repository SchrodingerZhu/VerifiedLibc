import LibcMath.Kernels.Scalblnf.Statement

/-!
# `scalblnf` (`aarch64`)

**Not complete.** Each theorem below that ends in `sorry` is open; `OPEN.md` lists it.
-/

namespace LibcMath.Kernels.Scalblnf.Proof.AArch64

open FloatLib.Floats.Formats.BinaryInterchange
open Model (IEEERoundingMode)
open LibcMath.Libc
open LibcMath.Kernels.Scalblnf.Generated

/-- **Open.** Prove `scalblnf` (`aarch64`) executes without C++ undefined behavior. -/
theorem scalblnfAArch64_defined : ScalblnfAArch64Defined := by
  sorry

/--
info: 'LibcMath.Kernels.Scalblnf.Proof.AArch64.scalblnfAArch64_defined' depends on axioms: [propext,
 sorryAx,
 Classical.choice,
 Quot.sound]
-/
#guard_msgs in
#print axioms scalblnfAArch64_defined

end LibcMath.Kernels.Scalblnf.Proof.AArch64
