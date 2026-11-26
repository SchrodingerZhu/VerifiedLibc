import LibcMath.Kernels.Hypotf.Statement

/-!
# `hypotf` (`generic_sse2`)

**Not complete.** Each theorem below that ends in `sorry` is open; `OPEN.md` lists it.
-/

namespace LibcMath.Kernels.Hypotf.Proof.GenericSse2

open FloatLib.Floats.Formats.BinaryInterchange
open LibcMath.Libc
open LibcMath.Kernels.Hypotf.Generated

/-- **Open.** Prove `hypotf` (`generic_sse2`) is correctly rounded in all four C modes. -/
theorem hypotfGenericSse2_correctlyRounded : HypotfGenericSse2CorrectlyRounded := by
  sorry

/--
info: 'LibcMath.Kernels.Hypotf.Proof.GenericSse2.hypotfGenericSse2_correctlyRounded' depends on axioms: [propext,
 sorryAx,
 Classical.choice,
 Quot.sound]
-/
#guard_msgs in
#print axioms hypotfGenericSse2_correctlyRounded

end LibcMath.Kernels.Hypotf.Proof.GenericSse2
