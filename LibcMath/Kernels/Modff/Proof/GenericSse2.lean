import LibcMath.Kernels.Modff.Statement

/-!
# `modff` (`generic_sse2`)

**Not complete.** Each theorem below that ends in `sorry` is open; `OPEN.md` lists it.
-/

namespace LibcMath.Kernels.Modff.Proof.GenericSse2

open FloatLib.Floats.Formats.BinaryInterchange
open Model (IEEERoundingMode)
open LibcMath.Libc
open LibcMath.Kernels.Modff.Generated

/-- **Open.** Prove `modff` (`generic_sse2`) executes without C++ undefined behavior. -/
theorem modffGenericSse2_defined : ModffGenericSse2Defined := by
  sorry

/--
info: 'LibcMath.Kernels.Modff.Proof.GenericSse2.modffGenericSse2_defined' depends on axioms: [propext,
 sorryAx,
 Classical.choice,
 Quot.sound]
-/
#guard_msgs in
#print axioms modffGenericSse2_defined

end LibcMath.Kernels.Modff.Proof.GenericSse2
