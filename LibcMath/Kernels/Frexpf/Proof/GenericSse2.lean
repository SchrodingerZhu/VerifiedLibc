import LibcMath.Kernels.Frexpf.Statement

/-!
# `frexpf` (`generic_sse2`)

**Not complete.** Each theorem below that ends in `sorry` is open; `OPEN.md` lists it.
-/

namespace LibcMath.Kernels.Frexpf.Proof.GenericSse2

open FloatLib.Floats.Formats.BinaryInterchange
open Model (IEEERoundingMode)
open LibcMath.Libc
open LibcMath.Kernels.Frexpf.Generated

/-- **Open.** Prove `frexpf` (`generic_sse2`) executes without C++ undefined behavior. -/
theorem frexpfGenericSse2_defined : FrexpfGenericSse2Defined := by
  sorry

/--
info: 'LibcMath.Kernels.Frexpf.Proof.GenericSse2.frexpfGenericSse2_defined' depends on axioms: [propext,
 sorryAx,
 Classical.choice,
 Quot.sound]
-/
#guard_msgs in
#print axioms frexpfGenericSse2_defined

end LibcMath.Kernels.Frexpf.Proof.GenericSse2
