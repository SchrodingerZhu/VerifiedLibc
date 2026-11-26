import LibcMath.Kernels.Exp2f.Statement

/-!
# `exp2f` (`static_rounding`)

**Not complete.** Each theorem below that ends in `sorry` is open; `OPEN.md` lists it.
-/

namespace LibcMath.Kernels.Exp2f.Proof.StaticRounding

open FloatLib.Floats.Formats.BinaryInterchange
open LibcMath.Libc
open LibcMath.Kernels.Exp2f.Generated

/-- **Open.** Prove `exp2f` (`static_rounding`) is correctly rounded across all four C modes. -/
theorem exp2fStaticRounding_correctlyRounded : Exp2fStaticRoundingCorrectlyRounded := by
  sorry

/--
info: 'LibcMath.Kernels.Exp2f.Proof.StaticRounding.exp2fStaticRounding_correctlyRounded' depends on axioms: [propext,
 sorryAx,
 Classical.choice,
 Quot.sound]
-/
#guard_msgs in
#print axioms exp2fStaticRounding_correctlyRounded

end LibcMath.Kernels.Exp2f.Proof.StaticRounding
