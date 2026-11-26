import LibcMath.Kernels.FmaximumNumf.Statement

/-!
# `fmaximum_numf` (`sse42`)

**Not complete.** Each theorem below that ends in `sorry` is open; `OPEN.md` lists it.
-/

namespace LibcMath.Kernels.FmaximumNumf.Proof.Sse42

open FloatLib.Floats.Formats.BinaryInterchange
open LibcMath.Libc
open LibcMath.Kernels.FmaximumNumf.Generated

/-- **Open.** Prove `fmaximum_numf` (`sse42`) is correctly rounded in all four C modes. -/
theorem fmaximum_numfSse42_correctlyRounded : FmaximumNumfSse42CorrectlyRounded := by
  sorry

/--
info: 'LibcMath.Kernels.FmaximumNumf.Proof.Sse42.fmaximum_numfSse42_correctlyRounded' depends on axioms: [propext,
 sorryAx,
 Classical.choice,
 Quot.sound]
-/
#guard_msgs in
#print axioms fmaximum_numfSse42_correctlyRounded

end LibcMath.Kernels.FmaximumNumf.Proof.Sse42
