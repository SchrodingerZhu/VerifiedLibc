import LibcMath.Kernels.FmaximumNumf.Statement

/-!
# `fmaximum_numf` (`generic_sse2`)

**Not complete.** Each theorem below that ends in `sorry` is open; `OPEN.md` lists it.
-/

namespace LibcMath.Kernels.FmaximumNumf.Proof.GenericSse2

open FloatLib.Floats.Formats.BinaryInterchange
open LibcMath.Libc
open LibcMath.Kernels.FmaximumNumf.Generated

/-- **Open.** Prove `fmaximum_numf` (`generic_sse2`) is correctly rounded in all four C modes. -/
theorem fmaximum_numfGenericSse2_correctlyRounded : FmaximumNumfGenericSse2CorrectlyRounded := by
  sorry

/--
info: 'LibcMath.Kernels.FmaximumNumf.Proof.GenericSse2.fmaximum_numfGenericSse2_correctlyRounded' depends on axioms: [propext,
 sorryAx,
 Classical.choice,
 Quot.sound]
-/
#guard_msgs in
#print axioms fmaximum_numfGenericSse2_correctlyRounded

end LibcMath.Kernels.FmaximumNumf.Proof.GenericSse2
