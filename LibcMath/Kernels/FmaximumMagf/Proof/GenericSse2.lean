import LibcMath.Kernels.FmaximumMagf.Statement

/-!
# `fmaximum_magf` (`generic_sse2`)

**Not complete.** Each theorem below that ends in `sorry` is open; `OPEN.md` lists it.
-/

namespace LibcMath.Kernels.FmaximumMagf.Proof.GenericSse2

open FloatLib.Floats.Formats.BinaryInterchange
open LibcMath.Libc
open LibcMath.Kernels.FmaximumMagf.Generated

/-- **Open.** Prove `fmaximum_magf` (`generic_sse2`) is correctly rounded in all four C modes. -/
theorem fmaximum_magfGenericSse2_correctlyRounded : FmaximumMagfGenericSse2CorrectlyRounded := by
  sorry

/--
info: 'LibcMath.Kernels.FmaximumMagf.Proof.GenericSse2.fmaximum_magfGenericSse2_correctlyRounded' depends on axioms: [propext,
 sorryAx,
 Classical.choice,
 Quot.sound]
-/
#guard_msgs in
#print axioms fmaximum_magfGenericSse2_correctlyRounded

end LibcMath.Kernels.FmaximumMagf.Proof.GenericSse2
