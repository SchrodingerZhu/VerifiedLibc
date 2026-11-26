import LibcMath.Kernels.FminimumMagf.Statement

/-!
# `fminimum_magf` (`sse42`)

**Not complete.** Each theorem below that ends in `sorry` is open; `OPEN.md` lists it.
-/

namespace LibcMath.Kernels.FminimumMagf.Proof.Sse42

open FloatLib.Floats.Formats.BinaryInterchange
open LibcMath.Libc
open LibcMath.Kernels.FminimumMagf.Generated

/-- **Open.** Prove `fminimum_magf` (`sse42`) is correctly rounded in all four C modes. -/
theorem fminimum_magfSse42_correctlyRounded : FminimumMagfSse42CorrectlyRounded := by
  sorry

/--
info: 'LibcMath.Kernels.FminimumMagf.Proof.Sse42.fminimum_magfSse42_correctlyRounded' depends on axioms: [propext,
 sorryAx,
 Classical.choice,
 Quot.sound]
-/
#guard_msgs in
#print axioms fminimum_magfSse42_correctlyRounded

end LibcMath.Kernels.FminimumMagf.Proof.Sse42
