import LibcMath.Kernels.Fabsf.Statement

/-!
# `fabsf` (`generic_sse2`)

**Not complete.** Each theorem below that ends in `sorry` is open; `OPEN.md` lists it.
-/

namespace LibcMath.Kernels.Fabsf.Proof.GenericSse2

open FloatLib.Floats.Formats.BinaryInterchange
open LibcMath.Libc
open LibcMath.Kernels.Fabsf.Generated

/-- **Open.** Prove `fabsf` (`generic_sse2`) is correctly rounded in all four C modes. -/
theorem fabsfGenericSse2_correctlyRounded : FabsfGenericSse2CorrectlyRounded := by
  sorry

/--
info: 'LibcMath.Kernels.Fabsf.Proof.GenericSse2.fabsfGenericSse2_correctlyRounded' depends on axioms: [propext,
 sorryAx,
 Classical.choice,
 Quot.sound]
-/
#guard_msgs in
#print axioms fabsfGenericSse2_correctlyRounded

end LibcMath.Kernels.Fabsf.Proof.GenericSse2
