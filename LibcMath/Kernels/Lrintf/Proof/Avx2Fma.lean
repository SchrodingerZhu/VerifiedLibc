import LibcMath.Kernels.Lrintf.Statement

/-!
# `lrintf` (`avx2_fma`)

**Not complete.** Each theorem below that ends in `sorry` is open; `OPEN.md` lists it.
-/

namespace LibcMath.Kernels.Lrintf.Proof.Avx2Fma

open FloatLib.Floats.Formats.BinaryInterchange
open Model (IEEERoundingMode)
open LibcMath.Libc
open LibcMath.Kernels.Lrintf.Generated

/-- **Open.** Prove `lrintf` (`avx2_fma`) executes without C++ undefined behavior. -/
theorem lrintfAvx2Fma_defined : LrintfAvx2FmaDefined := by
  sorry

/--
info: 'LibcMath.Kernels.Lrintf.Proof.Avx2Fma.lrintfAvx2Fma_defined' depends on axioms: [propext,
 sorryAx,
 Classical.choice,
 Quot.sound]
-/
#guard_msgs in
#print axioms lrintfAvx2Fma_defined

end LibcMath.Kernels.Lrintf.Proof.Avx2Fma
