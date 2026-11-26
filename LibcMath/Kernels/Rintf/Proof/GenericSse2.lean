import LibcMath.Kernels.Rintf.Statement

/-!
# `rintf` (`generic_sse2`)

**Not complete.** Each theorem below that ends in `sorry` is open; `OPEN.md` lists it.
-/

namespace LibcMath.Kernels.Rintf.Proof.GenericSse2

open FloatLib.Floats.Formats.BinaryInterchange
open LibcMath.Libc
open LibcMath.Kernels.Rintf.Generated

/-- **Open.** Prove `rintf` (`generic_sse2`) is correctly rounded in all four C modes. -/
theorem rintfGenericSse2_correctlyRounded : RintfGenericSse2CorrectlyRounded := by
  sorry

/--
info: 'LibcMath.Kernels.Rintf.Proof.GenericSse2.rintfGenericSse2_correctlyRounded' depends on axioms: [propext,
 sorryAx,
 Classical.choice,
 Quot.sound]
-/
#guard_msgs in
#print axioms rintfGenericSse2_correctlyRounded

end LibcMath.Kernels.Rintf.Proof.GenericSse2
