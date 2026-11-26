import LibcMath.Kernels.Tanpif.Statement

/-!
# `tanpif` (`sse2`)

**Not complete.** Each theorem below that ends in `sorry` is open; `OPEN.md` lists it.
-/

namespace LibcMath.Kernels.Tanpif.Proof.Sse2

open FloatLib.Floats.Formats.BinaryInterchange
open LibcMath.Libc
open LibcMath.Kernels.Tanpif.Generated

/-- **Open.** Prove `tanpif` (`sse2`) is correctly rounded in all four C modes. -/
theorem tanpifSse2_correctlyRounded : TanpifSse2CorrectlyRounded := by
  sorry

/--
info: 'LibcMath.Kernels.Tanpif.Proof.Sse2.tanpifSse2_correctlyRounded' depends on axioms: [propext,
 sorryAx,
 Classical.choice,
 Quot.sound]
-/
#guard_msgs in
#print axioms tanpifSse2_correctlyRounded

end LibcMath.Kernels.Tanpif.Proof.Sse2
