import LibcMath.Kernels.Cospif.Statement

/-!
# `cospif` (`sse2`)

**Not complete.** Each theorem below that ends in `sorry` is open; `OPEN.md` lists it.
-/

namespace LibcMath.Kernels.Cospif.Proof.Sse2

open FloatLib.Floats.Formats.BinaryInterchange
open LibcMath.Libc
open LibcMath.Kernels.Cospif.Generated

/-- **Open.** Prove `cospif` (`sse2`) is correctly rounded in all four C modes. -/
theorem cospifSse2_correctlyRounded : CospifSse2CorrectlyRounded := by
  sorry

/--
info: 'LibcMath.Kernels.Cospif.Proof.Sse2.cospifSse2_correctlyRounded' depends on axioms: [propext,
 sorryAx,
 Classical.choice,
 Quot.sound]
-/
#guard_msgs in
#print axioms cospifSse2_correctlyRounded

end LibcMath.Kernels.Cospif.Proof.Sse2
