import LibcMath.Kernels.Expm1f.Statement

/-!
# `expm1f` (`sse2`)

**Not complete.** Each theorem below that ends in `sorry` is open; `OPEN.md` lists it.
-/

namespace LibcMath.Kernels.Expm1f.Proof.Sse2

open FloatLib.Floats.Formats.BinaryInterchange
open LibcMath.Libc
open LibcMath.Kernels.Expm1f.Generated

/-- **Open.** Prove `expm1f` (`sse2`) is correctly rounded across all four C rounding modes. -/
theorem expm1fSse2_correctlyRounded : Expm1fSse2CorrectlyRounded := by
  sorry

/--
info: 'LibcMath.Kernels.Expm1f.Proof.Sse2.expm1fSse2_correctlyRounded' depends on axioms: [propext,
 sorryAx,
 Classical.choice,
 Quot.sound]
-/
#guard_msgs in
#print axioms expm1fSse2_correctlyRounded

end LibcMath.Kernels.Expm1f.Proof.Sse2
