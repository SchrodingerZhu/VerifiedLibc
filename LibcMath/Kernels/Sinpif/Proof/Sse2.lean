import LibcMath.Kernels.Sinpif.Statement

/-!
# `sinpif` (`sse2`)

**Not complete.** Each theorem below that ends in `sorry` is open; `OPEN.md` lists it.
-/

namespace LibcMath.Kernels.Sinpif.Proof.Sse2

open FloatLib.Floats.Formats.BinaryInterchange
open LibcMath.Libc
open LibcMath.Kernels.Sinpif.Generated

/-- **Open.** Prove `sinpif` (`sse2`) is correctly rounded in all four C modes. -/
theorem sinpifSse2_correctlyRounded : SinpifSse2CorrectlyRounded := by
  sorry

/--
info: 'LibcMath.Kernels.Sinpif.Proof.Sse2.sinpifSse2_correctlyRounded' depends on axioms: [propext,
 sorryAx,
 Classical.choice,
 Quot.sound]
-/
#guard_msgs in
#print axioms sinpifSse2_correctlyRounded

end LibcMath.Kernels.Sinpif.Proof.Sse2
