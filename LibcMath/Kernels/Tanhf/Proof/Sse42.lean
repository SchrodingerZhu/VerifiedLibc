import LibcMath.Kernels.Tanhf.Statement

/-!
# `tanhf` (`sse42`)

**Not complete.** Each theorem below that ends in `sorry` is open; `OPEN.md` lists it.
-/

namespace LibcMath.Kernels.Tanhf.Proof.Sse42

open FloatLib.Floats.Formats.BinaryInterchange
open LibcMath.Libc
open LibcMath.Kernels.Tanhf.Generated

/-- **Open.** Prove `tanhf` (`sse42`) is correctly rounded in all four C modes. -/
theorem tanhfSse42_correctlyRounded : TanhfSse42CorrectlyRounded := by
  sorry

/--
info: 'LibcMath.Kernels.Tanhf.Proof.Sse42.tanhfSse42_correctlyRounded' depends on axioms: [propext,
 sorryAx,
 Classical.choice,
 Quot.sound]
-/
#guard_msgs in
#print axioms tanhfSse42_correctlyRounded

end LibcMath.Kernels.Tanhf.Proof.Sse42
