import LibcMath.Kernels.Getpayloadf.Statement

/-!
# `getpayloadf` (`sse42`)

**Not complete.** Each theorem below that ends in `sorry` is open; `OPEN.md` lists it.
-/

namespace LibcMath.Kernels.Getpayloadf.Proof.Sse42

open FloatLib.Floats.Formats.BinaryInterchange
open Model (IEEERoundingMode)
open LibcMath.Libc
open LibcMath.Kernels.Getpayloadf.Generated

/-- **Open.** Prove `getpayloadf` (`sse42`) matches `FloatLibSpec.getpayload` in C modes.
-/
theorem getpayloadfSse42_correctlyRounded : GetpayloadfSse42CorrectlyRounded := by
  sorry

/--
info: 'LibcMath.Kernels.Getpayloadf.Proof.Sse42.getpayloadfSse42_correctlyRounded' depends on axioms: [propext,
 sorryAx,
 Classical.choice,
 Quot.sound]
-/
#guard_msgs in
#print axioms getpayloadfSse42_correctlyRounded

end LibcMath.Kernels.Getpayloadf.Proof.Sse42
