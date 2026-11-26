import LibcMath.Kernels.Rsqrtf.Statement

/-!
# `rsqrtf` (`sse42`)

**Not complete.** Each theorem below that ends in `sorry` is open; `OPEN.md` lists it.
-/

namespace LibcMath.Kernels.Rsqrtf.Proof.Sse42

open FloatLib.Floats.Formats.BinaryInterchange
open LibcMath.Libc
open LibcMath.Kernels.Rsqrtf.Generated

/-- **Open.** Prove `rsqrtf` (`sse42`) is correctly rounded in all four C modes. -/
theorem rsqrtfSse42_correctlyRounded : RsqrtfSse42CorrectlyRounded := by
  sorry

/--
info: 'LibcMath.Kernels.Rsqrtf.Proof.Sse42.rsqrtfSse42_correctlyRounded' depends on axioms: [propext,
 sorryAx,
 Classical.choice,
 Quot.sound]
-/
#guard_msgs in
#print axioms rsqrtfSse42_correctlyRounded

end LibcMath.Kernels.Rsqrtf.Proof.Sse42
