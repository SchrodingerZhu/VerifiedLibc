import LibcMath.Kernels.Truncf.Statement

/-!
# `truncf` (`generic_sse2`)

**Not complete.** Each theorem below that ends in `sorry` is open; `OPEN.md` lists it.
-/

namespace LibcMath.Kernels.Truncf.Proof.GenericSse2

open FloatLib.Floats.Formats.BinaryInterchange
open LibcMath.Libc
open LibcMath.Kernels.Truncf.Generated

/-- **Open.** Prove `truncf` (`generic_sse2`) is correctly rounded in all four C modes. -/
theorem truncfGenericSse2_correctlyRounded : TruncfGenericSse2CorrectlyRounded := by
  sorry

/--
info: 'LibcMath.Kernels.Truncf.Proof.GenericSse2.truncfGenericSse2_correctlyRounded' depends on axioms: [propext,
 sorryAx,
 Classical.choice,
 Quot.sound]
-/
#guard_msgs in
#print axioms truncfGenericSse2_correctlyRounded

end LibcMath.Kernels.Truncf.Proof.GenericSse2
