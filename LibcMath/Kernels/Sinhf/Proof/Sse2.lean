import LibcMath.Kernels.Sinhf.Statement

/-!
# `sinhf` (`sse2`)

**Not complete.** Each theorem below that ends in `sorry` is open; `OPEN.md` lists it.
-/

namespace LibcMath.Kernels.Sinhf.Proof.Sse2

open FloatLib.Floats.Formats.BinaryInterchange
open LibcMath.Libc
open LibcMath.Kernels.Sinhf.Generated

/-- **Open.** Prove `sinhf` (`sse2`) is correctly rounded in all four C modes. -/
theorem sinhfSse2_correctlyRounded : SinhfSse2CorrectlyRounded := by
  sorry

/--
info: 'LibcMath.Kernels.Sinhf.Proof.Sse2.sinhfSse2_correctlyRounded' depends on axioms: [propext,
 sorryAx,
 Classical.choice,
 Quot.sound]
-/
#guard_msgs in
#print axioms sinhfSse2_correctlyRounded

end LibcMath.Kernels.Sinhf.Proof.Sse2
