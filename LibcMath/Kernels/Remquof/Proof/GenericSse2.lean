import LibcMath.Kernels.Remquof.Statement

/-!
# `remquof` (`generic_sse2`)

**Not complete.** Each theorem below that ends in `sorry` is open; `OPEN.md` lists it.
-/

namespace LibcMath.Kernels.Remquof.Proof.GenericSse2

open FloatLib.Floats.Formats.BinaryInterchange
open Model (IEEERoundingMode)
open LibcMath.Libc
open LibcMath.Kernels.Remquof.Generated

/-- **Open.** Prove `remquof` (`generic_sse2`) executes without C++ undefined behavior. -/
theorem remquofGenericSse2_defined : RemquofGenericSse2Defined := by
  sorry

/--
info: 'LibcMath.Kernels.Remquof.Proof.GenericSse2.remquofGenericSse2_defined' depends on axioms: [propext,
 sorryAx,
 Classical.choice,
 Quot.sound]
-/
#guard_msgs in
#print axioms remquofGenericSse2_defined

end LibcMath.Kernels.Remquof.Proof.GenericSse2
