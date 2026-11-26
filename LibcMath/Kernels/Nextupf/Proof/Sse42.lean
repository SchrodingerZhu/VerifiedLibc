import LibcMath.Kernels.Nextupf.Statement

/-!
# `nextupf` (`sse42`)

**Not complete.** Each theorem below that ends in `sorry` is open; `OPEN.md` lists it.
-/

namespace LibcMath.Kernels.Nextupf.Proof.Sse42

open FloatLib.Floats.Formats.BinaryInterchange
open Model (IEEERoundingMode)
open LibcMath.Libc
open LibcMath.Kernels.Nextupf.Generated

/-- **Open.** Prove `nextupf` (`sse42`) matches `FloatLibSpec.nextup` in all four C modes. -/
theorem nextupfSse42_correctlyRounded : NextupfSse42CorrectlyRounded := by
  sorry

/--
info: 'LibcMath.Kernels.Nextupf.Proof.Sse42.nextupfSse42_correctlyRounded' depends on axioms: [propext,
 sorryAx,
 Classical.choice,
 Quot.sound]
-/
#guard_msgs in
#print axioms nextupfSse42_correctlyRounded

end LibcMath.Kernels.Nextupf.Proof.Sse42
