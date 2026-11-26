import LibcMath.Kernels.Setpayloadf.Statement

/-!
# `setpayloadf` (`generic_sse2`)

**Not complete.** Each theorem below that ends in `sorry` is open; `OPEN.md` lists it.
-/

namespace LibcMath.Kernels.Setpayloadf.Proof.GenericSse2

open FloatLib.Floats.Formats.BinaryInterchange
open Model (IEEERoundingMode)
open LibcMath.Libc
open LibcMath.Kernels.Setpayloadf.Generated

/-- **Open.** Prove `setpayloadf` (`generic_sse2`) executes without C++ undefined behavior. -/
theorem setpayloadfGenericSse2_defined : SetpayloadfGenericSse2Defined := by
  sorry

/--
info: 'LibcMath.Kernels.Setpayloadf.Proof.GenericSse2.setpayloadfGenericSse2_defined' depends on axioms: [propext,
 sorryAx,
 Classical.choice,
 Quot.sound]
-/
#guard_msgs in
#print axioms setpayloadfGenericSse2_defined

end LibcMath.Kernels.Setpayloadf.Proof.GenericSse2
