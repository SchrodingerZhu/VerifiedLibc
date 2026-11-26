import LibcMath.Kernels.Totalorderf.Statement

/-!
# `totalorderf` (`avx2_fma`)

**Not complete.** Each theorem below that ends in `sorry` is open; `OPEN.md` lists it.
-/

namespace LibcMath.Kernels.Totalorderf.Proof.Avx2Fma

open FloatLib.Floats.Formats.BinaryInterchange
open Model (IEEERoundingMode)
open LibcMath.Libc
open LibcMath.Kernels.Totalorderf.Generated

/-- **Open.** Prove `totalorderf` (`avx2_fma`) matches `FloatLibSpec.totalorder`. -/
theorem totalorderfAvx2Fma_correct : TotalorderfAvx2FmaCorrect := by
  sorry

/--
info: 'LibcMath.Kernels.Totalorderf.Proof.Avx2Fma.totalorderfAvx2Fma_correct' depends on axioms: [propext,
 sorryAx,
 Classical.choice,
 Quot.sound]
-/
#guard_msgs in
#print axioms totalorderfAvx2Fma_correct

end LibcMath.Kernels.Totalorderf.Proof.Avx2Fma
