import LibcMath.Kernels.Canonicalizef.Statement

/-!
# `canonicalizef` (`avx2_fma`)

**Not complete.** Each theorem below that ends in `sorry` is open; `OPEN.md` lists it.
-/

namespace LibcMath.Kernels.Canonicalizef.Proof.Avx2Fma

open FloatLib.Floats.Formats.BinaryInterchange
open Model (IEEERoundingMode)
open LibcMath.Libc
open LibcMath.Kernels.Canonicalizef.Generated

/-- **Open.** Prove `canonicalizef` (`avx2_fma`) executes without C++ undefined behavior. -/
theorem canonicalizefAvx2Fma_defined : CanonicalizefAvx2FmaDefined := by
  sorry

/--
info: 'LibcMath.Kernels.Canonicalizef.Proof.Avx2Fma.canonicalizefAvx2Fma_defined' depends on axioms: [propext,
 sorryAx,
 Classical.choice,
 Quot.sound]
-/
#guard_msgs in
#print axioms canonicalizefAvx2Fma_defined

end LibcMath.Kernels.Canonicalizef.Proof.Avx2Fma
