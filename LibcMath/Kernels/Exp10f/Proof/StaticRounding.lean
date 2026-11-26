import LibcMath.Kernels.Exp10f.Statement

/-!
# `exp10f` (`static_rounding`)

**Not complete.** Each theorem below that ends in `sorry` is open; `OPEN.md` lists it.
-/

namespace LibcMath.Kernels.Exp10f.Proof.StaticRounding

open FloatLib.Floats.Formats.BinaryInterchange
open LibcMath.Libc
open LibcMath.Kernels.Exp10f.Generated

/-- **Open.** Prove `exp10f` (`static_rounding`) is correctly rounded across all four C modes. -/
theorem exp10fStaticRounding_correctlyRounded : Exp10fStaticRoundingCorrectlyRounded := by
  sorry

/--
info: 'LibcMath.Kernels.Exp10f.Proof.StaticRounding.exp10fStaticRounding_correctlyRounded' depends on axioms: [propext,
 sorryAx,
 Classical.choice,
 Quot.sound]
-/
#guard_msgs in
#print axioms exp10fStaticRounding_correctlyRounded

end LibcMath.Kernels.Exp10f.Proof.StaticRounding
