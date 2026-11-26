import LibcMath.Kernels.Hypotf.Statement

/-!
# `hypotf` (`sse42`)

**Not complete.** Each theorem below that ends in `sorry` is open; `OPEN.md` lists it.
-/

namespace LibcMath.Kernels.Hypotf.Proof.Sse42

open FloatLib.Floats.Formats.BinaryInterchange
open LibcMath.Libc
open LibcMath.Kernels.Hypotf.Generated

/-- **Open.** Prove `hypotf` (`sse42`) is correctly rounded in all four C modes. -/
theorem hypotfSse42_correctlyRounded : HypotfSse42CorrectlyRounded := by
  sorry

/--
info: 'LibcMath.Kernels.Hypotf.Proof.Sse42.hypotfSse42_correctlyRounded' depends on axioms: [propext,
 sorryAx,
 Classical.choice,
 Quot.sound]
-/
#guard_msgs in
#print axioms hypotfSse42_correctlyRounded

end LibcMath.Kernels.Hypotf.Proof.Sse42
