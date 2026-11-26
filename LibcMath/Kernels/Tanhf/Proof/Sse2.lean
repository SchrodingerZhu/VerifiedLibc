import LibcMath.Kernels.Tanhf.Statement

/-!
# `tanhf` (`sse2`)

**Not complete.** Each theorem below that ends in `sorry` is open; `OPEN.md` lists it.
-/

namespace LibcMath.Kernels.Tanhf.Proof.Sse2

open FloatLib.Floats.Formats.BinaryInterchange
open LibcMath.Libc
open LibcMath.Kernels.Tanhf.Generated

/-- **Open.** Prove `tanhf` (`sse2`) is correctly rounded in all four C modes. -/
theorem tanhfSse2_correctlyRounded : TanhfSse2CorrectlyRounded := by
  sorry

/--
info: 'LibcMath.Kernels.Tanhf.Proof.Sse2.tanhfSse2_correctlyRounded' depends on axioms: [propext,
 sorryAx,
 Classical.choice,
 Quot.sound]
-/
#guard_msgs in
#print axioms tanhfSse2_correctlyRounded

end LibcMath.Kernels.Tanhf.Proof.Sse2
