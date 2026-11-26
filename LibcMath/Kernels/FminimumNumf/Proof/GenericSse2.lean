import LibcMath.Kernels.FminimumNumf.Statement

/-!
# `fminimum_numf` (`generic_sse2`)

**Not complete.** Each theorem below that ends in `sorry` is open; `OPEN.md` lists it.
-/

namespace LibcMath.Kernels.FminimumNumf.Proof.GenericSse2

open FloatLib.Floats.Formats.BinaryInterchange
open LibcMath.Libc
open LibcMath.Kernels.FminimumNumf.Generated

/-- **Open.** Prove `fminimum_numf` (`generic_sse2`) is correctly rounded in all four C modes. -/
theorem fminimum_numfGenericSse2_correctlyRounded : FminimumNumfGenericSse2CorrectlyRounded := by
  sorry

/--
info: 'LibcMath.Kernels.FminimumNumf.Proof.GenericSse2.fminimum_numfGenericSse2_correctlyRounded' depends on axioms: [propext,
 sorryAx,
 Classical.choice,
 Quot.sound]
-/
#guard_msgs in
#print axioms fminimum_numfGenericSse2_correctlyRounded

end LibcMath.Kernels.FminimumNumf.Proof.GenericSse2
