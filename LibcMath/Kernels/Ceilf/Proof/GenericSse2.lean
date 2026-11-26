import LibcMath.Kernels.Ceilf.Statement

/-!
# `ceilf` (`generic_sse2`)

**Not complete.** Each theorem below that ends in `sorry` is open; `OPEN.md` lists it.
-/

namespace LibcMath.Kernels.Ceilf.Proof.GenericSse2

open FloatLib.Floats.Formats.BinaryInterchange
open LibcMath.Libc
open LibcMath.Kernels.Ceilf.Generated

/-- **Open.** Prove `ceilf` (`generic_sse2`) is correctly rounded in all four C modes. -/
theorem ceilfGenericSse2_correctlyRounded : CeilfGenericSse2CorrectlyRounded := by
  sorry

/--
info: 'LibcMath.Kernels.Ceilf.Proof.GenericSse2.ceilfGenericSse2_correctlyRounded' depends on axioms: [propext,
 sorryAx,
 Classical.choice,
 Quot.sound]
-/
#guard_msgs in
#print axioms ceilfGenericSse2_correctlyRounded

end LibcMath.Kernels.Ceilf.Proof.GenericSse2
