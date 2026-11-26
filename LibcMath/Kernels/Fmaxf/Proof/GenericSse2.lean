import LibcMath.Kernels.Fmaxf.Statement

/-!
# `fmaxf` (`generic_sse2`)

**Not complete.** Each theorem below that ends in `sorry` is open; `OPEN.md` lists it.
-/

namespace LibcMath.Kernels.Fmaxf.Proof.GenericSse2

open FloatLib.Floats.Formats.BinaryInterchange
open LibcMath.Libc
open LibcMath.Kernels.Fmaxf.Generated

/-- **Open.** Prove `fmaxf` (`generic_sse2`) is correctly rounded in all four C modes. -/
theorem fmaxfGenericSse2_correctlyRounded : FmaxfGenericSse2CorrectlyRounded := by
  sorry

/--
info: 'LibcMath.Kernels.Fmaxf.Proof.GenericSse2.fmaxfGenericSse2_correctlyRounded' depends on axioms: [propext,
 sorryAx,
 Classical.choice,
 Quot.sound]
-/
#guard_msgs in
#print axioms fmaxfGenericSse2_correctlyRounded

end LibcMath.Kernels.Fmaxf.Proof.GenericSse2
