import LibcMath.Kernels.Fromfpxf.Statement

/-!
# `fromfpxf` (`avx2_fma`)

**Not complete.** Each theorem below that ends in `sorry` is open; `OPEN.md` lists it.
-/

namespace LibcMath.Kernels.Fromfpxf.Proof.Avx2Fma

open FloatLib.Floats.Formats.BinaryInterchange
open Model (IEEERoundingMode)
open LibcMath.Libc
open LibcMath.Kernels.Fromfpxf.Generated

/-- **Open.** Prove `fromfpxf` (`avx2_fma`) executes without C++ undefined behavior. -/
theorem fromfpxfAvx2Fma_defined : FromfpxfAvx2FmaDefined := by
  sorry

/--
info: 'LibcMath.Kernels.Fromfpxf.Proof.Avx2Fma.fromfpxfAvx2Fma_defined' depends on axioms: [propext,
 sorryAx,
 Classical.choice,
 Quot.sound]
-/
#guard_msgs in
#print axioms fromfpxfAvx2Fma_defined

end LibcMath.Kernels.Fromfpxf.Proof.Avx2Fma
