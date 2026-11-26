import LibcMath.Kernels.Getpayloadf.Statement

/-!
# `getpayloadf` (`aarch64`)

**Not complete.** Each theorem below that ends in `sorry` is open; `OPEN.md` lists it.
-/

namespace LibcMath.Kernels.Getpayloadf.Proof.AArch64

open FloatLib.Floats.Formats.BinaryInterchange
open Model (IEEERoundingMode)
open LibcMath.Libc
open LibcMath.Kernels.Getpayloadf.Generated

/-- **Open.** Prove `getpayloadf` (`aarch64`) matches `FloatLibSpec.getpayload` in C modes.
-/
theorem getpayloadfAArch64_correctlyRounded : GetpayloadfAArch64CorrectlyRounded := by
  sorry

/--
info: 'LibcMath.Kernels.Getpayloadf.Proof.AArch64.getpayloadfAArch64_correctlyRounded' depends on axioms: [propext,
 sorryAx,
 Classical.choice,
 Quot.sound]
-/
#guard_msgs in
#print axioms getpayloadfAArch64_correctlyRounded

end LibcMath.Kernels.Getpayloadf.Proof.AArch64
