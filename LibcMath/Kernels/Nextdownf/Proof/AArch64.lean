import LibcMath.Kernels.Nextdownf.Statement

/-!
# `nextdownf` (`aarch64`)

**Not complete.** Each theorem below that ends in `sorry` is open; `OPEN.md` lists it.
-/

namespace LibcMath.Kernels.Nextdownf.Proof.AArch64

open FloatLib.Floats.Formats.BinaryInterchange
open Model (IEEERoundingMode)
open LibcMath.Libc
open LibcMath.Kernels.Nextdownf.Generated

/-- **Open.** Prove `nextdownf` (`aarch64`) matches `FloatLibSpec.nextdown` in all C modes.
-/
theorem nextdownfAArch64_correctlyRounded : NextdownfAArch64CorrectlyRounded := by
  sorry

/--
info: 'LibcMath.Kernels.Nextdownf.Proof.AArch64.nextdownfAArch64_correctlyRounded' depends on axioms: [propext,
 sorryAx,
 Classical.choice,
 Quot.sound]
-/
#guard_msgs in
#print axioms nextdownfAArch64_correctlyRounded

end LibcMath.Kernels.Nextdownf.Proof.AArch64
