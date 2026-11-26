import LibcMath.Kernels.Setpayloadsigf.Statement

/-!
# `setpayloadsigf` (`generic_sse2`)

**Not complete.** Each theorem below that ends in `sorry` is open; `OPEN.md` lists it.
-/

namespace LibcMath.Kernels.Setpayloadsigf.Proof.GenericSse2

open FloatLib.Floats.Formats.BinaryInterchange
open Model (IEEERoundingMode)
open LibcMath.Libc
open LibcMath.Kernels.Setpayloadsigf.Generated

/-- **Open.** Prove `setpayloadsigf` (`generic_sse2`) executes without C++ undefined behavior. -/
theorem setpayloadsigfGenericSse2_defined : SetpayloadsigfGenericSse2Defined := by
  sorry

/--
info: 'LibcMath.Kernels.Setpayloadsigf.Proof.GenericSse2.setpayloadsigfGenericSse2_defined' depends on axioms: [propext,
 sorryAx,
 Classical.choice,
 Quot.sound]
-/
#guard_msgs in
#print axioms setpayloadsigfGenericSse2_defined

end LibcMath.Kernels.Setpayloadsigf.Proof.GenericSse2
