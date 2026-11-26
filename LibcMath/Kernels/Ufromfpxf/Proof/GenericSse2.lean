import LibcMath.Kernels.Ufromfpxf.Statement

/-!
# `ufromfpxf` (`generic_sse2`)

**Not complete.** Each theorem below that ends in `sorry` is open; `OPEN.md` lists it.
-/

namespace LibcMath.Kernels.Ufromfpxf.Proof.GenericSse2

open FloatLib.Floats.Formats.BinaryInterchange
open Model (IEEERoundingMode)
open LibcMath.Libc
open LibcMath.Kernels.Ufromfpxf.Generated

/-- **Open.** Prove `ufromfpxf` (`generic_sse2`) executes without C++ undefined behavior. -/
theorem ufromfpxfGenericSse2_defined : UfromfpxfGenericSse2Defined := by
  sorry

/--
info: 'LibcMath.Kernels.Ufromfpxf.Proof.GenericSse2.ufromfpxfGenericSse2_defined' depends on axioms: [propext,
 sorryAx,
 Classical.choice,
 Quot.sound]
-/
#guard_msgs in
#print axioms ufromfpxfGenericSse2_defined

end LibcMath.Kernels.Ufromfpxf.Proof.GenericSse2
