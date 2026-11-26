import LibcMath.Kernels.Acospif.Statement

/-!
# `acospif` (`sse2`)

**Not complete.** Each theorem below that ends in `sorry` is open; `OPEN.md` lists it.
-/

namespace LibcMath.Kernels.Acospif.Proof.Sse2

open FloatLib.Floats.Formats.BinaryInterchange
open LibcMath.Libc
open LibcMath.Kernels.Acospif.Generated

/-- **Open.** Prove `acospif` (`sse2`) is correctly rounded in all four C modes. -/
theorem acospifSse2_correctlyRounded : AcospifSse2CorrectlyRounded := by
  sorry

/--
info: 'LibcMath.Kernels.Acospif.Proof.Sse2.acospifSse2_correctlyRounded' depends on axioms: [propext,
 sorryAx,
 Classical.choice,
 Quot.sound]
-/
#guard_msgs in
#print axioms acospifSse2_correctlyRounded

end LibcMath.Kernels.Acospif.Proof.Sse2
