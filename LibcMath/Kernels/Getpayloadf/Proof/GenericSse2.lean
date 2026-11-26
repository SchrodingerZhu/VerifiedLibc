import LibcMath.Kernels.Getpayloadf.Statement

/-!
# `getpayloadf` (`generic_sse2`)

**Not complete.** Each theorem below that ends in `sorry` is open; `OPEN.md` lists it.
-/

namespace LibcMath.Kernels.Getpayloadf.Proof.GenericSse2

open FloatLib.Floats.Formats.BinaryInterchange
open Model (IEEERoundingMode)
open LibcMath.Libc
open LibcMath.Kernels.Getpayloadf.Generated

/-- **Open.** Prove `getpayloadf` (`generic_sse2`) matches `FloatLibSpec.getpayload` in C modes.
-/
theorem getpayloadfGenericSse2_correctlyRounded : GetpayloadfGenericSse2CorrectlyRounded := by
  sorry

/--
info: 'LibcMath.Kernels.Getpayloadf.Proof.GenericSse2.getpayloadfGenericSse2_correctlyRounded' depends on axioms: [propext,
 sorryAx,
 Classical.choice,
 Quot.sound]
-/
#guard_msgs in
#print axioms getpayloadfGenericSse2_correctlyRounded

end LibcMath.Kernels.Getpayloadf.Proof.GenericSse2
