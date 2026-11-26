import LibcMath.Kernels.Ufromfpxf.Statement

/-!
# `ufromfpxf` (`avx2_fma`)

**Not complete.** Each theorem below that ends in `sorry` is open; `OPEN.md` lists it.
-/

namespace LibcMath.Kernels.Ufromfpxf.Proof.Avx2Fma

open FloatLib.Floats.Formats.BinaryInterchange
open Model (IEEERoundingMode)
open LibcMath.Libc
open LibcMath.Kernels.Ufromfpxf.Generated

/-- **Open.** Prove `ufromfpxf` (`avx2_fma`) executes without C++ undefined behavior. -/
theorem ufromfpxfAvx2Fma_defined : UfromfpxfAvx2FmaDefined := by
  sorry

/--
info: 'LibcMath.Kernels.Ufromfpxf.Proof.Avx2Fma.ufromfpxfAvx2Fma_defined' depends on axioms: [propext,
 sorryAx,
 Classical.choice,
 Quot.sound]
-/
#guard_msgs in
#print axioms ufromfpxfAvx2Fma_defined

end LibcMath.Kernels.Ufromfpxf.Proof.Avx2Fma
