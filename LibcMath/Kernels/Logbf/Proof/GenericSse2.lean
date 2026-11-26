import LibcMath.Kernels.Logbf.Statement

/-!
# `logbf` (`generic_sse2`)

**Not complete.** Each theorem below that ends in `sorry` is open; `OPEN.md` lists it.
-/

namespace LibcMath.Kernels.Logbf.Proof.GenericSse2

open FloatLib.Floats.Formats.BinaryInterchange
open Model (IEEERoundingMode)
open LibcMath.Libc
open LibcMath.Kernels.Logbf.Generated

/-- **Open.** Prove `logbf` (`generic_sse2`) executes without C++ undefined behavior. -/
theorem logbfGenericSse2_defined : LogbfGenericSse2Defined := by
  sorry

/--
info: 'LibcMath.Kernels.Logbf.Proof.GenericSse2.logbfGenericSse2_defined' depends on axioms: [propext,
 sorryAx,
 Classical.choice,
 Quot.sound]
-/
#guard_msgs in
#print axioms logbfGenericSse2_defined

end LibcMath.Kernels.Logbf.Proof.GenericSse2
