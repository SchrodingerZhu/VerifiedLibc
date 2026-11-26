import LibcMath.Kernels.Hypotf.Statement

/-!
# `hypotf` (`aarch64`)

**Not complete.** Each theorem below that ends in `sorry` is open; `OPEN.md` lists it.
-/

namespace LibcMath.Kernels.Hypotf.Proof.AArch64

open FloatLib.Floats.Formats.BinaryInterchange
open LibcMath.Libc
open LibcMath.Kernels.Hypotf.Generated

/-- **Open.** Prove `hypotf` (`aarch64`) is correctly rounded in all four C modes. -/
theorem hypotfAArch64_correctlyRounded : HypotfAArch64CorrectlyRounded := by
  sorry

/--
info: 'LibcMath.Kernels.Hypotf.Proof.AArch64.hypotfAArch64_correctlyRounded' depends on axioms: [propext,
 sorryAx,
 Classical.choice,
 Quot.sound]
-/
#guard_msgs in
#print axioms hypotfAArch64_correctlyRounded

end LibcMath.Kernels.Hypotf.Proof.AArch64
