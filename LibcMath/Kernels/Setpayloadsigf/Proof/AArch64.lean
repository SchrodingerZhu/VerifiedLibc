import LibcMath.Kernels.Setpayloadsigf.Statement

/-!
# `setpayloadsigf` (`aarch64`)

**Not complete.** Each theorem below that ends in `sorry` is open; `OPEN.md` lists it.
-/

namespace LibcMath.Kernels.Setpayloadsigf.Proof.AArch64

open FloatLib.Floats.Formats.BinaryInterchange
open Model (IEEERoundingMode)
open LibcMath.Libc
open LibcMath.Kernels.Setpayloadsigf.Generated

/-- **Open.** Prove `setpayloadsigf` (`aarch64`) executes without C++ undefined behavior. -/
theorem setpayloadsigfAArch64_defined : SetpayloadsigfAArch64Defined := by
  sorry

/--
info: 'LibcMath.Kernels.Setpayloadsigf.Proof.AArch64.setpayloadsigfAArch64_defined' depends on axioms: [propext,
 sorryAx,
 Classical.choice,
 Quot.sound]
-/
#guard_msgs in
#print axioms setpayloadsigfAArch64_defined

end LibcMath.Kernels.Setpayloadsigf.Proof.AArch64
