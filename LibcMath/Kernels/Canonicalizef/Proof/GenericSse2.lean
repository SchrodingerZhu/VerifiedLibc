import LibcMath.Kernels.Canonicalizef.Statement

/-!
# `canonicalizef` (`generic_sse2`)

**Not complete.** Each theorem below that ends in `sorry` is open; `OPEN.md` lists it.
-/

namespace LibcMath.Kernels.Canonicalizef.Proof.GenericSse2

open FloatLib.Floats.Formats.BinaryInterchange
open Model (IEEERoundingMode)
open LibcMath.Libc
open LibcMath.Kernels.Canonicalizef.Generated

/-- **Open.** Prove `canonicalizef` (`generic_sse2`) executes without C++ undefined behavior. -/
theorem canonicalizefGenericSse2_defined : CanonicalizefGenericSse2Defined := by
  sorry

/--
info: 'LibcMath.Kernels.Canonicalizef.Proof.GenericSse2.canonicalizefGenericSse2_defined' depends on axioms: [propext,
 sorryAx,
 Classical.choice,
 Quot.sound]
-/
#guard_msgs in
#print axioms canonicalizefGenericSse2_defined

end LibcMath.Kernels.Canonicalizef.Proof.GenericSse2
