import LibcMath.Kernels.Lgammaf.Statement

/-!
# `lgammaf` (`aarch64`)

**Not complete.** Each theorem below that ends in `sorry` is open; `OPEN.md` lists it.
-/

namespace LibcMath.Kernels.Lgammaf.Proof.AArch64

open FloatLib.Floats.Formats.BinaryInterchange
open LibcMath.Libc
open LibcMath.Kernels.Lgammaf.Generated

/-- **Open.** Prove `lgammaf` (`aarch64`) is correctly rounded in all four C modes. -/
theorem lgammafAArch64_correctlyRounded : LgammafAArch64CorrectlyRounded := by
  sorry

/--
info: 'LibcMath.Kernels.Lgammaf.Proof.AArch64.lgammafAArch64_correctlyRounded' depends on axioms: [propext,
 sorryAx,
 Classical.choice,
 Quot.sound]
-/
#guard_msgs in
#print axioms lgammafAArch64_correctlyRounded

end LibcMath.Kernels.Lgammaf.Proof.AArch64
