import LibcMath.Kernels.Llogbf.Statement

/-!
# `llogbf` (`generic_sse2`)

**Not complete.** Each theorem below that ends in `sorry` is open; `OPEN.md` lists it.
-/

namespace LibcMath.Kernels.Llogbf.Proof.GenericSse2

open FloatLib.Floats.Formats.BinaryInterchange
open Model (IEEERoundingMode)
open LibcMath.Libc
open LibcMath.Kernels.Llogbf.Generated

/-- **Open.** Prove `llogbf` (`generic_sse2`) executes without C++ undefined behavior. -/
theorem llogbfGenericSse2_defined : LlogbfGenericSse2Defined := by
  sorry

/--
info: 'LibcMath.Kernels.Llogbf.Proof.GenericSse2.llogbfGenericSse2_defined' depends on axioms: [propext,
 sorryAx,
 Classical.choice,
 Quot.sound]
-/
#guard_msgs in
#print axioms llogbfGenericSse2_defined

end LibcMath.Kernels.Llogbf.Proof.GenericSse2
