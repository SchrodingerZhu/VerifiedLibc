import LibcMath.Kernels.Scalblnf.Statement

/-!
# `scalblnf` (`generic_sse2`)

**Not complete.** Each theorem below that ends in `sorry` is open; `OPEN.md` lists it.
-/

namespace LibcMath.Kernels.Scalblnf.Proof.GenericSse2

open FloatLib.Floats.Formats.BinaryInterchange
open Model (IEEERoundingMode)
open LibcMath.Libc
open LibcMath.Kernels.Scalblnf.Generated

/-- **Open.** Prove `scalblnf` (`generic_sse2`) executes without C++ undefined behavior. -/
theorem scalblnfGenericSse2_defined : ScalblnfGenericSse2Defined := by
  sorry

/--
info: 'LibcMath.Kernels.Scalblnf.Proof.GenericSse2.scalblnfGenericSse2_defined' depends on axioms: [propext,
 sorryAx,
 Classical.choice,
 Quot.sound]
-/
#guard_msgs in
#print axioms scalblnfGenericSse2_defined

end LibcMath.Kernels.Scalblnf.Proof.GenericSse2
