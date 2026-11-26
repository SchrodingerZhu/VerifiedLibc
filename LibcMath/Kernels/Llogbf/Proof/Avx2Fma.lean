import LibcMath.Kernels.Llogbf.Statement

/-!
# `llogbf` (`avx2_fma`)

**Not complete.** Each theorem below that ends in `sorry` is open; `OPEN.md` lists it.
-/

namespace LibcMath.Kernels.Llogbf.Proof.Avx2Fma

open FloatLib.Floats.Formats.BinaryInterchange
open Model (IEEERoundingMode)
open LibcMath.Libc
open LibcMath.Kernels.Llogbf.Generated

/-- **Open.** Prove `llogbf` (`avx2_fma`) executes without C++ undefined behavior. -/
theorem llogbfAvx2Fma_defined : LlogbfAvx2FmaDefined := by
  sorry

/--
info: 'LibcMath.Kernels.Llogbf.Proof.Avx2Fma.llogbfAvx2Fma_defined' depends on axioms: [propext,
 sorryAx,
 Classical.choice,
 Quot.sound]
-/
#guard_msgs in
#print axioms llogbfAvx2Fma_defined

end LibcMath.Kernels.Llogbf.Proof.Avx2Fma
