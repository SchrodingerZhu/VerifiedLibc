import LibcMath.Kernels.Rsqrtf.Statement

/-!
# `rsqrtf` (`sse2`)

**Not complete.** Each theorem below that ends in `sorry` is open; `OPEN.md` lists it.
-/

namespace LibcMath.Kernels.Rsqrtf.Proof.Sse2

open FloatLib.Floats.Formats.BinaryInterchange
open LibcMath.Libc
open LibcMath.Kernels.Rsqrtf.Generated

/-- **Open.** Prove `rsqrtf` (`sse2`) is correctly rounded in all four C modes. -/
theorem rsqrtfSse2_correctlyRounded : RsqrtfSse2CorrectlyRounded := by
  sorry

/--
info: 'LibcMath.Kernels.Rsqrtf.Proof.Sse2.rsqrtfSse2_correctlyRounded' depends on axioms: [propext,
 sorryAx,
 Classical.choice,
 Quot.sound]
-/
#guard_msgs in
#print axioms rsqrtfSse2_correctlyRounded

end LibcMath.Kernels.Rsqrtf.Proof.Sse2
