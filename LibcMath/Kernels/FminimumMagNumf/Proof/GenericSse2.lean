import LibcMath.Kernels.FminimumMagNumf.Statement

/-!
# `fminimum_mag_numf` (`generic_sse2`)

**Not complete.** Each theorem below that ends in `sorry` is open; `OPEN.md` lists it.
-/

namespace LibcMath.Kernels.FminimumMagNumf.Proof.GenericSse2

open FloatLib.Floats.Formats.BinaryInterchange
open LibcMath.Libc
open LibcMath.Kernels.FminimumMagNumf.Generated

/-- **Open.** Prove `fminimum_mag_numf` (`generic_sse2`) is correctly rounded in all four C modes.
-/
theorem fminimum_mag_numfGenericSse2_correctlyRounded :
    FminimumMagNumfGenericSse2CorrectlyRounded := by
  sorry

/--
info: 'LibcMath.Kernels.FminimumMagNumf.Proof.GenericSse2.fminimum_mag_numfGenericSse2_correctlyRounded' depends on axioms: [propext,
 sorryAx,
 Classical.choice,
 Quot.sound]
-/
#guard_msgs in
#print axioms fminimum_mag_numfGenericSse2_correctlyRounded

end LibcMath.Kernels.FminimumMagNumf.Proof.GenericSse2
