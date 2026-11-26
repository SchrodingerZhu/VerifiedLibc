import LibcMath.Kernels.FminimumMagf.Statement

/-!
# `fminimum_magf` (`generic_sse2`)

**Not complete.** Each theorem below that ends in `sorry` is open; `OPEN.md` lists it.
-/

namespace LibcMath.Kernels.FminimumMagf.Proof.GenericSse2

open FloatLib.Floats.Formats.BinaryInterchange
open LibcMath.Libc
open LibcMath.Kernels.FminimumMagf.Generated

/-- **Open.** Prove `fminimum_magf` (`generic_sse2`) is correctly rounded in all four C modes. -/
theorem fminimum_magfGenericSse2_correctlyRounded : FminimumMagfGenericSse2CorrectlyRounded := by
  sorry

/--
info: 'LibcMath.Kernels.FminimumMagf.Proof.GenericSse2.fminimum_magfGenericSse2_correctlyRounded' depends on axioms: [propext,
 sorryAx,
 Classical.choice,
 Quot.sound]
-/
#guard_msgs in
#print axioms fminimum_magfGenericSse2_correctlyRounded

end LibcMath.Kernels.FminimumMagf.Proof.GenericSse2
