import LibcMath.Kernels.Remquof.Statement

/-!
# `remquof` (`sse42`)

**Not complete.** Each theorem below that ends in `sorry` is open; `OPEN.md` lists it.
-/

namespace LibcMath.Kernels.Remquof.Proof.Sse42

open FloatLib.Floats.Formats.BinaryInterchange
open Model (IEEERoundingMode)
open LibcMath.Libc
open LibcMath.Kernels.Remquof.Generated

/-- **Open.** Prove `remquof` (`sse42`) executes without C++ undefined behavior. -/
theorem remquofSse42_defined : RemquofSse42Defined := by
  sorry

/--
info: 'LibcMath.Kernels.Remquof.Proof.Sse42.remquofSse42_defined' depends on axioms: [propext,
 sorryAx,
 Classical.choice,
 Quot.sound]
-/
#guard_msgs in
#print axioms remquofSse42_defined

end LibcMath.Kernels.Remquof.Proof.Sse42
