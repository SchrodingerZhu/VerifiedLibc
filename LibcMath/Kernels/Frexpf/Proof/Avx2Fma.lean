import LibcMath.Kernels.Frexpf.Statement

/-!
# `frexpf` (`avx2_fma`)

**Not complete.** Each theorem below that ends in `sorry` is open; `OPEN.md` lists it.
-/

namespace LibcMath.Kernels.Frexpf.Proof.Avx2Fma

open FloatLib.Floats.Formats.BinaryInterchange
open Model (IEEERoundingMode)
open LibcMath.Libc
open LibcMath.Kernels.Frexpf.Generated

/-- **Open.** Prove `frexpf` (`avx2_fma`) executes without C++ undefined behavior. -/
theorem frexpfAvx2Fma_defined : FrexpfAvx2FmaDefined := by
  sorry

/--
info: 'LibcMath.Kernels.Frexpf.Proof.Avx2Fma.frexpfAvx2Fma_defined' depends on axioms: [propext,
 sorryAx,
 Classical.choice,
 Quot.sound]
-/
#guard_msgs in
#print axioms frexpfAvx2Fma_defined

end LibcMath.Kernels.Frexpf.Proof.Avx2Fma
