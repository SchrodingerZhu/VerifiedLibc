import LibcMath.Kernels.Fmaf.Statement

/-!
# `fmaf` (`generic_sse2`)

**Not complete.** Each theorem below that ends in `sorry` is open; `OPEN.md` lists it.
-/

namespace LibcMath.Kernels.Fmaf.Proof.GenericSse2

open FloatLib.Floats.Formats.BinaryInterchange
open LibcMath.Libc
open LibcMath.Kernels.Fmaf.Generated

/-- **Open.** Prove `fmaf` (`generic_sse2`) is correctly rounded in all four C modes. -/
theorem fmafGenericSse2_correctlyRounded : FmafGenericSse2CorrectlyRounded := by
  sorry

/--
info: 'LibcMath.Kernels.Fmaf.Proof.GenericSse2.fmafGenericSse2_correctlyRounded' depends on axioms: [propext,
 sorryAx,
 Classical.choice,
 Quot.sound]
-/
#guard_msgs in
#print axioms fmafGenericSse2_correctlyRounded

end LibcMath.Kernels.Fmaf.Proof.GenericSse2
