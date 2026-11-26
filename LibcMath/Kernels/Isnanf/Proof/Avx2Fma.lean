import LibcMath.Kernels.Isnanf.Statement

/-!
# `isnanf` (`avx2_fma`)

**Not complete.** Each theorem below that ends in `sorry` is open; `OPEN.md` lists it.
-/

namespace LibcMath.Kernels.Isnanf.Proof.Avx2Fma

open FloatLib.Floats.Formats.BinaryInterchange
open Model (IEEERoundingMode)
open LibcMath.Libc
open LibcMath.Kernels.Isnanf.Generated

/-- **Open.** Prove `isnanf` (`avx2_fma`) matches IEEE NaN classification. -/
theorem isnanfAvx2Fma_correct : IsnanfAvx2FmaCorrect := by
  sorry

/--
info: 'LibcMath.Kernels.Isnanf.Proof.Avx2Fma.isnanfAvx2Fma_correct' depends on axioms: [propext,
 sorryAx,
 Classical.choice,
 Quot.sound]
-/
#guard_msgs in
#print axioms isnanfAvx2Fma_correct

end LibcMath.Kernels.Isnanf.Proof.Avx2Fma
