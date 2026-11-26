import LibcMath.Kernels.Nextdownf.Statement

/-!
# `nextdownf` (`sse42`)

**Not complete.** Each theorem below that ends in `sorry` is open; `OPEN.md` lists it.
-/

namespace LibcMath.Kernels.Nextdownf.Proof.Sse42

open FloatLib.Floats.Formats.BinaryInterchange
open Model (IEEERoundingMode)
open LibcMath.Libc
open LibcMath.Kernels.Nextdownf.Generated

/-- **Open.** Prove `nextdownf` (`sse42`) matches `FloatLibSpec.nextdown` in all C modes.
-/
theorem nextdownfSse42_correctlyRounded : NextdownfSse42CorrectlyRounded := by
  sorry

/--
info: 'LibcMath.Kernels.Nextdownf.Proof.Sse42.nextdownfSse42_correctlyRounded' depends on axioms: [propext,
 sorryAx,
 Classical.choice,
 Quot.sound]
-/
#guard_msgs in
#print axioms nextdownfSse42_correctlyRounded

end LibcMath.Kernels.Nextdownf.Proof.Sse42
