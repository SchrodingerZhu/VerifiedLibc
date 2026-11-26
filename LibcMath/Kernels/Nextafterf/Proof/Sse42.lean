import LibcMath.Kernels.Nextafterf.Statement

/-!
# `nextafterf` (`sse42`)

**Not complete.** Each theorem below that ends in `sorry` is open; `OPEN.md` lists it.
-/

namespace LibcMath.Kernels.Nextafterf.Proof.Sse42

open FloatLib.Floats.Formats.BinaryInterchange
open Model (IEEERoundingMode)
open LibcMath.Libc
open LibcMath.Kernels.Nextafterf.Generated

/-- **Open.** Prove `nextafterf` (`sse42`) executes without C++ undefined behavior. -/
theorem nextafterfSse42_defined : NextafterfSse42Defined := by
  sorry

/--
info: 'LibcMath.Kernels.Nextafterf.Proof.Sse42.nextafterfSse42_defined' depends on axioms: [propext,
 sorryAx,
 Classical.choice,
 Quot.sound]
-/
#guard_msgs in
#print axioms nextafterfSse42_defined

end LibcMath.Kernels.Nextafterf.Proof.Sse42
