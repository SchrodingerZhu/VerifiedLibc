import LibcMath.Kernels.Sinhf.Statement

/-!
# `sinhf` (`sse42`)

**Not complete.** Each theorem below that ends in `sorry` is open; `OPEN.md` lists it.
-/

namespace LibcMath.Kernels.Sinhf.Proof.Sse42

open FloatLib.Floats.Formats.BinaryInterchange
open LibcMath.Libc
open LibcMath.Kernels.Sinhf.Generated

/-- **Open.** Prove `sinhf` (`sse42`) is correctly rounded in all four C modes. -/
theorem sinhfSse42_correctlyRounded : SinhfSse42CorrectlyRounded := by
  sorry

/--
info: 'LibcMath.Kernels.Sinhf.Proof.Sse42.sinhfSse42_correctlyRounded' depends on axioms: [propext,
 sorryAx,
 Classical.choice,
 Quot.sound]
-/
#guard_msgs in
#print axioms sinhfSse42_correctlyRounded

end LibcMath.Kernels.Sinhf.Proof.Sse42
