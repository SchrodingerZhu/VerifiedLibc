import LibcMath.Kernels.Floorf.Statement

/-!
# `floorf` (`generic_sse2`)

**Not complete.** Each theorem below that ends in `sorry` is open; `OPEN.md` lists it.
-/

namespace LibcMath.Kernels.Floorf.Proof.GenericSse2

open FloatLib.Floats.Formats.BinaryInterchange
open LibcMath.Libc
open LibcMath.Kernels.Floorf.Generated

/-- **Open.** Prove `floorf` (`generic_sse2`) is correctly rounded in all four C modes. -/
theorem floorfGenericSse2_correctlyRounded : FloorfGenericSse2CorrectlyRounded := by
  sorry

/--
info: 'LibcMath.Kernels.Floorf.Proof.GenericSse2.floorfGenericSse2_correctlyRounded' depends on axioms: [propext,
 sorryAx,
 Classical.choice,
 Quot.sound]
-/
#guard_msgs in
#print axioms floorfGenericSse2_correctlyRounded

end LibcMath.Kernels.Floorf.Proof.GenericSse2
