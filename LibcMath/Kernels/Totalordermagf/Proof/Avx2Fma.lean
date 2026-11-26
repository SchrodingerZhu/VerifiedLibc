import LibcMath.Kernels.Totalordermagf.Statement

/-!
# `totalordermagf` (`avx2_fma`)

**Not complete.** Each theorem below that ends in `sorry` is open; `OPEN.md` lists it.
-/

namespace LibcMath.Kernels.Totalordermagf.Proof.Avx2Fma

open FloatLib.Floats.Formats.BinaryInterchange
open Model (IEEERoundingMode)
open LibcMath.Libc
open LibcMath.Kernels.Totalordermagf.Generated

/-- **Open.** Prove `totalordermagf` (`avx2_fma`) matches `FloatLibSpec.totalordermag`. -/
theorem totalordermagfAvx2Fma_correct : TotalordermagfAvx2FmaCorrect := by
  sorry

/--
info: 'LibcMath.Kernels.Totalordermagf.Proof.Avx2Fma.totalordermagfAvx2Fma_correct' depends on axioms: [propext,
 sorryAx,
 Classical.choice,
 Quot.sound]
-/
#guard_msgs in
#print axioms totalordermagfAvx2Fma_correct

end LibcMath.Kernels.Totalordermagf.Proof.Avx2Fma
