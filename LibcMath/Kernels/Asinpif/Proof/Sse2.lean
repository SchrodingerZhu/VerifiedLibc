import LibcMath.Kernels.Asinpif.Statement

/-!
# `asinpif` (`sse2`)

**Not complete.** Each theorem below that ends in `sorry` is open; `OPEN.md` lists it.
-/

namespace LibcMath.Kernels.Asinpif.Proof.Sse2

open FloatLib.Floats.Formats.BinaryInterchange
open LibcMath.Libc
open LibcMath.Kernels.Asinpif.Generated

/-- **Open.** Prove `asinpif` (`sse2`) is correctly rounded in all four C modes. -/
theorem asinpifSse2_correctlyRounded : AsinpifSse2CorrectlyRounded := by
  sorry

/--
info: 'LibcMath.Kernels.Asinpif.Proof.Sse2.asinpifSse2_correctlyRounded' depends on axioms: [propext,
 sorryAx,
 Classical.choice,
 Quot.sound]
-/
#guard_msgs in
#print axioms asinpifSse2_correctlyRounded

end LibcMath.Kernels.Asinpif.Proof.Sse2
