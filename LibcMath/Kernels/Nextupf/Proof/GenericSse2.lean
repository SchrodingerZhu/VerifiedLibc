import LibcMath.Kernels.Nextupf.Statement

/-!
# `nextupf` (`generic_sse2`)

**Not complete.** Each theorem below that ends in `sorry` is open; `OPEN.md` lists it.
-/

namespace LibcMath.Kernels.Nextupf.Proof.GenericSse2

open FloatLib.Floats.Formats.BinaryInterchange
open Model (IEEERoundingMode)
open LibcMath.Libc
open LibcMath.Kernels.Nextupf.Generated

/-- **Open.** Prove `nextupf` (`generic_sse2`) matches `FloatLibSpec.nextup` in all four C modes. -/
theorem nextupfGenericSse2_correctlyRounded : NextupfGenericSse2CorrectlyRounded := by
  sorry

/--
info: 'LibcMath.Kernels.Nextupf.Proof.GenericSse2.nextupfGenericSse2_correctlyRounded' depends on axioms: [propext,
 sorryAx,
 Classical.choice,
 Quot.sound]
-/
#guard_msgs in
#print axioms nextupfGenericSse2_correctlyRounded

end LibcMath.Kernels.Nextupf.Proof.GenericSse2
