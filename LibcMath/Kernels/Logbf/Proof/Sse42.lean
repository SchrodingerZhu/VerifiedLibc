import LibcMath.Kernels.Logbf.Statement

/-!
# `logbf` (`sse42`)

**Not complete.** Each theorem below that ends in `sorry` is open; `OPEN.md` lists it.
-/

namespace LibcMath.Kernels.Logbf.Proof.Sse42

open FloatLib.Floats.Formats.BinaryInterchange
open Model (IEEERoundingMode)
open LibcMath.Libc
open LibcMath.Kernels.Logbf.Generated

/-- **Open.** Prove `logbf` (`sse42`) executes without C++ undefined behavior. -/
theorem logbfSse42_defined : LogbfSse42Defined := by
  sorry

/--
info: 'LibcMath.Kernels.Logbf.Proof.Sse42.logbfSse42_defined' depends on axioms: [propext,
 sorryAx,
 Classical.choice,
 Quot.sound]
-/
#guard_msgs in
#print axioms logbfSse42_defined

end LibcMath.Kernels.Logbf.Proof.Sse42
