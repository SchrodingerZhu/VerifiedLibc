import LibcMath.Kernels.Remainderf.Statement

/-!
# `remainderf` (`generic_sse2`)

**Not complete.** Each theorem below that ends in `sorry` is open; `OPEN.md` lists it.
-/

namespace LibcMath.Kernels.Remainderf.Proof.GenericSse2

open FloatLib.Floats.Formats.BinaryInterchange
open Model (IEEERoundingMode)
open LibcMath.Libc
open LibcMath.Kernels.Remainderf.Generated

/-- **Open.** Prove `remainderf` (`generic_sse2`) matches IEEE remainder in all C modes. -/
theorem remainderfGenericSse2_correctlyRounded : RemainderfGenericSse2CorrectlyRounded := by
  sorry

/--
info: 'LibcMath.Kernels.Remainderf.Proof.GenericSse2.remainderfGenericSse2_correctlyRounded' depends on axioms: [propext,
 sorryAx,
 Classical.choice,
 Quot.sound]
-/
#guard_msgs in
#print axioms remainderfGenericSse2_correctlyRounded

end LibcMath.Kernels.Remainderf.Proof.GenericSse2
