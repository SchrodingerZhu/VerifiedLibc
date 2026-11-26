import LibcMath.Kernels.Copysignf.Statement

/-!
# `copysignf` (`aarch64`)

**Not complete.** Each theorem below that ends in `sorry` is open; `OPEN.md` lists it.
-/

namespace LibcMath.Kernels.Copysignf.Proof.AArch64

open FloatLib.Floats.Formats.BinaryInterchange
open LibcMath.Libc
open LibcMath.Kernels.Copysignf.Generated

/-- **Open.** Prove `copysignf` (`aarch64`) is correctly rounded in all four C modes. -/
theorem copysignfAArch64_correctlyRounded : CopysignfAArch64CorrectlyRounded := by
  sorry

/--
info: 'LibcMath.Kernels.Copysignf.Proof.AArch64.copysignfAArch64_correctlyRounded' depends on axioms: [propext,
 sorryAx,
 Classical.choice,
 Quot.sound]
-/
#guard_msgs in
#print axioms copysignfAArch64_correctlyRounded

end LibcMath.Kernels.Copysignf.Proof.AArch64
