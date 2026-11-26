import LibcMath.Kernels.Fmaximumf.Statement

/-!
# `fmaximumf` (`sse42`)

**Not complete.** Each theorem below that ends in `sorry` is open; `OPEN.md` lists it.
-/

namespace LibcMath.Kernels.Fmaximumf.Proof.Sse42

open FloatLib.Floats.Formats.BinaryInterchange
open LibcMath.Libc
open LibcMath.Kernels.Fmaximumf.Generated

/-- **Open.** Prove `fmaximumf` (`sse42`) is correctly rounded in all four C modes. -/
theorem fmaximumfSse42_correctlyRounded : FmaximumfSse42CorrectlyRounded := by
  sorry

/--
info: 'LibcMath.Kernels.Fmaximumf.Proof.Sse42.fmaximumfSse42_correctlyRounded' depends on axioms: [propext,
 sorryAx,
 Classical.choice,
 Quot.sound]
-/
#guard_msgs in
#print axioms fmaximumfSse42_correctlyRounded

end LibcMath.Kernels.Fmaximumf.Proof.Sse42
