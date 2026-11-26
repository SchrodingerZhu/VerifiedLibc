import LibcMath.Kernels.Nextafterf.Statement

/-!
# `nextafterf` (`generic_sse2`)

**Not complete.** Each theorem below that ends in `sorry` is open; `OPEN.md` lists it.
-/

namespace LibcMath.Kernels.Nextafterf.Proof.GenericSse2

open FloatLib.Floats.Formats.BinaryInterchange
open Model (IEEERoundingMode)
open LibcMath.Libc
open LibcMath.Kernels.Nextafterf.Generated

/-- **Open.** Prove `nextafterf` (`generic_sse2`) executes without C++ undefined behavior. -/
theorem nextafterfGenericSse2_defined : NextafterfGenericSse2Defined := by
  sorry

/--
info: 'LibcMath.Kernels.Nextafterf.Proof.GenericSse2.nextafterfGenericSse2_defined' depends on axioms: [propext,
 sorryAx,
 Classical.choice,
 Quot.sound]
-/
#guard_msgs in
#print axioms nextafterfGenericSse2_defined

end LibcMath.Kernels.Nextafterf.Proof.GenericSse2
