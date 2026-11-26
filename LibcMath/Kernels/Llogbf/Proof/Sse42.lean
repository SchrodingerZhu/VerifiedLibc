import LibcMath.Kernels.Llogbf.Statement

/-!
# `llogbf` (`sse42`)

**Not complete.** Each theorem below that ends in `sorry` is open; `OPEN.md` lists it.
-/

namespace LibcMath.Kernels.Llogbf.Proof.Sse42

open FloatLib.Floats.Formats.BinaryInterchange
open Model (IEEERoundingMode)
open LibcMath.Libc
open LibcMath.Kernels.Llogbf.Generated

/-- **Open.** Prove `llogbf` (`sse42`) executes without C++ undefined behavior. -/
theorem llogbfSse42_defined : LlogbfSse42Defined := by
  sorry

/--
info: 'LibcMath.Kernels.Llogbf.Proof.Sse42.llogbfSse42_defined' depends on axioms: [propext,
 sorryAx,
 Classical.choice,
 Quot.sound]
-/
#guard_msgs in
#print axioms llogbfSse42_defined

end LibcMath.Kernels.Llogbf.Proof.Sse42
