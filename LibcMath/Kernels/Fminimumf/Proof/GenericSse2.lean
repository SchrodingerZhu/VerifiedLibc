import LibcMath.Kernels.Fminimumf.Statement

/-!
# `fminimumf` (`generic_sse2`)

**Not complete.** Each theorem below that ends in `sorry` is open; `OPEN.md` lists it.
-/

namespace LibcMath.Kernels.Fminimumf.Proof.GenericSse2

open FloatLib.Floats.Formats.BinaryInterchange
open LibcMath.Libc
open LibcMath.Kernels.Fminimumf.Generated

/-- **Open.** Prove `fminimumf` (`generic_sse2`) is correctly rounded in all four C modes. -/
theorem fminimumfGenericSse2_correctlyRounded : FminimumfGenericSse2CorrectlyRounded := by
  sorry

/--
info: 'LibcMath.Kernels.Fminimumf.Proof.GenericSse2.fminimumfGenericSse2_correctlyRounded' depends on axioms: [propext,
 sorryAx,
 Classical.choice,
 Quot.sound]
-/
#guard_msgs in
#print axioms fminimumfGenericSse2_correctlyRounded

end LibcMath.Kernels.Fminimumf.Proof.GenericSse2
