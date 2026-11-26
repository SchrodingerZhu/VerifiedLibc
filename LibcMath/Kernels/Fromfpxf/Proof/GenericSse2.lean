import LibcMath.Kernels.Fromfpxf.Statement

/-!
# `fromfpxf` (`generic_sse2`)

**Not complete.** Each theorem below that ends in `sorry` is open; `OPEN.md` lists it.
-/

namespace LibcMath.Kernels.Fromfpxf.Proof.GenericSse2

open FloatLib.Floats.Formats.BinaryInterchange
open Model (IEEERoundingMode)
open LibcMath.Libc
open LibcMath.Kernels.Fromfpxf.Generated

/-- **Open.** Prove `fromfpxf` (`generic_sse2`) executes without C++ undefined behavior. -/
theorem fromfpxfGenericSse2_defined : FromfpxfGenericSse2Defined := by
  sorry

/--
info: 'LibcMath.Kernels.Fromfpxf.Proof.GenericSse2.fromfpxfGenericSse2_defined' depends on axioms: [propext,
 sorryAx,
 Classical.choice,
 Quot.sound]
-/
#guard_msgs in
#print axioms fromfpxfGenericSse2_defined

end LibcMath.Kernels.Fromfpxf.Proof.GenericSse2
