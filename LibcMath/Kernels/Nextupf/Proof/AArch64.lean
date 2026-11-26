import LibcMath.Kernels.Nextupf.Statement

/-!
# `nextupf` (`aarch64`)

**Not complete.** Each theorem below that ends in `sorry` is open; `OPEN.md` lists it.
-/

namespace LibcMath.Kernels.Nextupf.Proof.AArch64

open FloatLib.Floats.Formats.BinaryInterchange
open Model (IEEERoundingMode)
open LibcMath.Libc
open LibcMath.Kernels.Nextupf.Generated

/-- **Open.** Prove `nextupf` (`aarch64`) matches `FloatLibSpec.nextup` in all four C modes. -/
theorem nextupfAArch64_correctlyRounded : NextupfAArch64CorrectlyRounded := by
  sorry

/--
info: 'LibcMath.Kernels.Nextupf.Proof.AArch64.nextupfAArch64_correctlyRounded' depends on axioms: [propext,
 sorryAx,
 Classical.choice,
 Quot.sound]
-/
#guard_msgs in
#print axioms nextupfAArch64_correctlyRounded

end LibcMath.Kernels.Nextupf.Proof.AArch64
