import LibcMath.Kernels.FmaximumMagf.Statement

/-!
# `fmaximum_magf` (`sse42`)

**Not complete.** Each theorem below that ends in `sorry` is open; `OPEN.md` lists it.
-/

namespace LibcMath.Kernels.FmaximumMagf.Proof.Sse42

open FloatLib.Floats.Formats.BinaryInterchange
open LibcMath.Libc
open LibcMath.Kernels.FmaximumMagf.Generated

/-- **Open.** Prove `fmaximum_magf` (`sse42`) is correctly rounded in all four C modes. -/
theorem fmaximum_magfSse42_correctlyRounded : FmaximumMagfSse42CorrectlyRounded := by
  sorry

/--
info: 'LibcMath.Kernels.FmaximumMagf.Proof.Sse42.fmaximum_magfSse42_correctlyRounded' depends on axioms: [propext,
 sorryAx,
 Classical.choice,
 Quot.sound]
-/
#guard_msgs in
#print axioms fmaximum_magfSse42_correctlyRounded

end LibcMath.Kernels.FmaximumMagf.Proof.Sse42
