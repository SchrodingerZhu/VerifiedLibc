import LibcMath.Kernels.Sincosf.Statement

/-!
# `sincosf` (`aarch64`)

**Not complete.** Each theorem below that ends in `sorry` is open; `OPEN.md` lists it.
-/

namespace LibcMath.Kernels.Sincosf.Proof.AArch64

open FloatLib.Floats.Formats.BinaryInterchange
open LibcMath.Kernels.Sincosf.Generated

/-- **Open.** Prove `sincosf` (`aarch64`) is correctly rounded in all four C modes. -/
theorem sincosfAArch64_correctlyRounded : SincosfAArch64CorrectlyRounded := by
  sorry

/--
info: 'LibcMath.Kernels.Sincosf.Proof.AArch64.sincosfAArch64_correctlyRounded' depends on axioms: [propext,
 sorryAx,
 Classical.choice,
 Quot.sound]
-/
#guard_msgs in
#print axioms sincosfAArch64_correctlyRounded

end LibcMath.Kernels.Sincosf.Proof.AArch64
