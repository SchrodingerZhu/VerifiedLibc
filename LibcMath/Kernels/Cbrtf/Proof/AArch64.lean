import LibcMath.Kernels.Cbrtf.Statement

/-!
# `cbrtf` (`aarch64`)

**Not complete.** Each theorem below that ends in `sorry` is open; `OPEN.md` lists it.
-/

namespace LibcMath.Kernels.Cbrtf.Proof.AArch64

open FloatLib.Floats.Formats.BinaryInterchange
open LibcMath.Libc
open LibcMath.Kernels.Cbrtf.Generated

/-- **Open.** Prove `cbrtf` (`aarch64`) is correctly rounded in all four C modes. -/
theorem cbrtfAArch64_correctlyRounded : CbrtfAArch64CorrectlyRounded := by
  sorry

/--
info: 'LibcMath.Kernels.Cbrtf.Proof.AArch64.cbrtfAArch64_correctlyRounded' depends on axioms: [propext,
 sorryAx,
 Classical.choice,
 Quot.sound]
-/
#guard_msgs in
#print axioms cbrtfAArch64_correctlyRounded

end LibcMath.Kernels.Cbrtf.Proof.AArch64
