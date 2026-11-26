import LibcMath.Kernels.Copysignf.Statement

/-!
# `copysignf` (`generic_sse2`)

**Not complete.** Each theorem below that ends in `sorry` is open; `OPEN.md` lists it.
-/

namespace LibcMath.Kernels.Copysignf.Proof.GenericSse2

open FloatLib.Floats.Formats.BinaryInterchange
open LibcMath.Libc
open LibcMath.Kernels.Copysignf.Generated

/-- **Open.** Prove `copysignf` (`generic_sse2`) is correctly rounded in all four C modes. -/
theorem copysignfGenericSse2_correctlyRounded : CopysignfGenericSse2CorrectlyRounded := by
  sorry

/--
info: 'LibcMath.Kernels.Copysignf.Proof.GenericSse2.copysignfGenericSse2_correctlyRounded' depends on axioms: [propext,
 sorryAx,
 Classical.choice,
 Quot.sound]
-/
#guard_msgs in
#print axioms copysignfGenericSse2_correctlyRounded

end LibcMath.Kernels.Copysignf.Proof.GenericSse2
