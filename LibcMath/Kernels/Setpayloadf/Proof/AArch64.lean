import LibcMath.Kernels.Setpayloadf.Statement

/-!
# `setpayloadf` (`aarch64`)

**Not complete.** Each theorem below that ends in `sorry` is open; `OPEN.md` lists it.
-/

namespace LibcMath.Kernels.Setpayloadf.Proof.AArch64

open FloatLib.Floats.Formats.BinaryInterchange
open Model (IEEERoundingMode)
open LibcMath.Libc
open LibcMath.Kernels.Setpayloadf.Generated

/-- **Open.** Prove `setpayloadf` (`aarch64`) executes without C++ undefined behavior. -/
theorem setpayloadfAArch64_defined : SetpayloadfAArch64Defined := by
  sorry

/--
info: 'LibcMath.Kernels.Setpayloadf.Proof.AArch64.setpayloadfAArch64_defined' depends on axioms: [propext,
 sorryAx,
 Classical.choice,
 Quot.sound]
-/
#guard_msgs in
#print axioms setpayloadfAArch64_defined

end LibcMath.Kernels.Setpayloadf.Proof.AArch64
