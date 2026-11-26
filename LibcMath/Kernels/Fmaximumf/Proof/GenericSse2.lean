import LibcMath.Kernels.Fmaximumf.Statement

/-!
# `fmaximumf` (`generic_sse2`)

**Not complete.** Each theorem below that ends in `sorry` is open; `OPEN.md` lists it.
-/

namespace LibcMath.Kernels.Fmaximumf.Proof.GenericSse2

open FloatLib.Floats.Formats.BinaryInterchange
open LibcMath.Libc
open LibcMath.Kernels.Fmaximumf.Generated

/-- **Open.** Prove `fmaximumf` (`generic_sse2`) is correctly rounded in all four C modes. -/
theorem fmaximumfGenericSse2_correctlyRounded : FmaximumfGenericSse2CorrectlyRounded := by
  sorry

/--
info: 'LibcMath.Kernels.Fmaximumf.Proof.GenericSse2.fmaximumfGenericSse2_correctlyRounded' depends on axioms: [propext,
 sorryAx,
 Classical.choice,
 Quot.sound]
-/
#guard_msgs in
#print axioms fmaximumfGenericSse2_correctlyRounded

end LibcMath.Kernels.Fmaximumf.Proof.GenericSse2
