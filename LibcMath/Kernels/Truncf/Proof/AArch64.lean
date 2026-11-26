import LibcMath.Kernels.Truncf.Statement

/-!
# `truncf` (`aarch64`)

**Not complete.** Each theorem below that ends in `sorry` is open; `OPEN.md` lists it.
-/

namespace LibcMath.Kernels.Truncf.Proof.AArch64

open FloatLib.Floats.Formats.BinaryInterchange
open LibcMath.Libc
open LibcMath.Kernels.Truncf.Generated

/-- **Open.** Prove `truncf` (`aarch64`) is correctly rounded in all four C modes. -/
theorem truncfAArch64_correctlyRounded : TruncfAArch64CorrectlyRounded := by
  sorry

/--
info: 'LibcMath.Kernels.Truncf.Proof.AArch64.truncfAArch64_correctlyRounded' depends on axioms: [propext,
 sorryAx,
 Classical.choice,
 Quot.sound]
-/
#guard_msgs in
#print axioms truncfAArch64_correctlyRounded

end LibcMath.Kernels.Truncf.Proof.AArch64
