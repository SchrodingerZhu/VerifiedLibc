import LibcMath.Kernels.Ufromfpxf.Statement

/-!
# `ufromfpxf` (`sse42`)

**Not complete.** Each theorem below that ends in `sorry` is open; `OPEN.md` lists it.
-/

namespace LibcMath.Kernels.Ufromfpxf.Proof.Sse42

open FloatLib.Floats.Formats.BinaryInterchange
open Model (IEEERoundingMode)
open LibcMath.Libc
open LibcMath.Kernels.Ufromfpxf.Generated

/-- **Open.** Prove `ufromfpxf` (`sse42`) executes without C++ undefined behavior. -/
theorem ufromfpxfSse42_defined : UfromfpxfSse42Defined := by
  sorry

/--
info: 'LibcMath.Kernels.Ufromfpxf.Proof.Sse42.ufromfpxfSse42_defined' depends on axioms: [propext,
 sorryAx,
 Classical.choice,
 Quot.sound]
-/
#guard_msgs in
#print axioms ufromfpxfSse42_defined

end LibcMath.Kernels.Ufromfpxf.Proof.Sse42
