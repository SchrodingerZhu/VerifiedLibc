import LibcMath.Kernels.Sqrtf.Statement

/-!
# `sqrtf` (`generic_softfloat`)

**Not complete.** Each theorem below that ends in `sorry` is open; `OPEN.md` lists it.
-/

namespace LibcMath.Kernels.Sqrtf.Proof.GenericSoftFloat

open FloatLib.Floats.Formats.BinaryInterchange
open LibcMath.Libc
open LibcMath.Kernels.Sqrtf.Generated

/-- **Open.** Prove `sqrtf` (`generic_softfloat`) is correctly rounded in all four C modes. -/
theorem sqrtfGenericSoftFloat_correctlyRounded : SqrtfGenericSoftFloatCorrectlyRounded := by
  sorry

/--
info: 'LibcMath.Kernels.Sqrtf.Proof.GenericSoftFloat.sqrtfGenericSoftFloat_correctlyRounded' depends on axioms: [propext,
 sorryAx,
 Classical.choice,
 Quot.sound]
-/
#guard_msgs in
#print axioms sqrtfGenericSoftFloat_correctlyRounded

end LibcMath.Kernels.Sqrtf.Proof.GenericSoftFloat
