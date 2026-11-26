import LibcMath.Kernels.Acospif.Statement

/-!
# `acospif` (`sse42`)

**Not complete.** Each theorem below that ends in `sorry` is open; `OPEN.md` lists it.
-/

namespace LibcMath.Kernels.Acospif.Proof.Sse42

open FloatLib.Floats.Formats.BinaryInterchange
open LibcMath.Libc
open LibcMath.Kernels.Acospif.Generated

/-- **Open.** Prove `acospif` (`sse42`) is correctly rounded in all four C modes. -/
theorem acospifSse42_correctlyRounded : AcospifSse42CorrectlyRounded := by
  sorry

/--
info: 'LibcMath.Kernels.Acospif.Proof.Sse42.acospifSse42_correctlyRounded' depends on axioms: [propext,
 sorryAx,
 Classical.choice,
 Quot.sound]
-/
#guard_msgs in
#print axioms acospifSse42_correctlyRounded

end LibcMath.Kernels.Acospif.Proof.Sse42
