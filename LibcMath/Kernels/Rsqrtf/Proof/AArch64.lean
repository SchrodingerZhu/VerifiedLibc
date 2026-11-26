import LibcMath.Kernels.Rsqrtf.Statement

/-!
# `rsqrtf` (`aarch64`)

**Not complete.** Each theorem below that ends in `sorry` is open; `OPEN.md` lists it.
-/

namespace LibcMath.Kernels.Rsqrtf.Proof.AArch64

open FloatLib.Floats.Formats.BinaryInterchange
open LibcMath.Libc
open LibcMath.Kernels.Rsqrtf.Generated

/-- **Open.** Prove `rsqrtf` (`aarch64`) is correctly rounded in all four C modes. -/
theorem rsqrtfAArch64_correctlyRounded : RsqrtfAArch64CorrectlyRounded := by
  sorry

/--
info: 'LibcMath.Kernels.Rsqrtf.Proof.AArch64.rsqrtfAArch64_correctlyRounded' depends on axioms: [propext,
 sorryAx,
 Classical.choice,
 Quot.sound]
-/
#guard_msgs in
#print axioms rsqrtfAArch64_correctlyRounded

end LibcMath.Kernels.Rsqrtf.Proof.AArch64
