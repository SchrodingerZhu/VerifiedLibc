import LibcMath.Kernels.Fromfpxf.Statement

/-!
# `fromfpxf` (`sse42`)

**Not complete.** Each theorem below that ends in `sorry` is open; `OPEN.md` lists it.
-/

namespace LibcMath.Kernels.Fromfpxf.Proof.Sse42

open FloatLib.Floats.Formats.BinaryInterchange
open Model (IEEERoundingMode)
open LibcMath.Libc
open LibcMath.Kernels.Fromfpxf.Generated

/-- **Open.** Prove `fromfpxf` (`sse42`) executes without C++ undefined behavior. -/
theorem fromfpxfSse42_defined : FromfpxfSse42Defined := by
  sorry

/--
info: 'LibcMath.Kernels.Fromfpxf.Proof.Sse42.fromfpxfSse42_defined' depends on axioms: [propext,
 sorryAx,
 Classical.choice,
 Quot.sound]
-/
#guard_msgs in
#print axioms fromfpxfSse42_defined

end LibcMath.Kernels.Fromfpxf.Proof.Sse42
