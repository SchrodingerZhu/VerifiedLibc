import LibcMath.Kernels.Issignalingf.Statement

/-!
# `issignalingf` (`avx2_fma`)

**Not complete.** Each theorem below that ends in `sorry` is open; `OPEN.md` lists it.
-/

namespace LibcMath.Kernels.Issignalingf.Proof.Avx2Fma

open FloatLib.Floats.Formats.BinaryInterchange
open Model (IEEERoundingMode)
open LibcMath.Libc
open LibcMath.Kernels.Issignalingf.Generated

/-- **Open.** Prove `issignalingf` (`avx2_fma`) matches IEEE sNaN test. -/
theorem issignalingfAvx2Fma_correct : IssignalingfAvx2FmaCorrect := by
  sorry

/--
info: 'LibcMath.Kernels.Issignalingf.Proof.Avx2Fma.issignalingfAvx2Fma_correct' depends on axioms: [propext,
 sorryAx,
 Classical.choice,
 Quot.sound]
-/
#guard_msgs in
#print axioms issignalingfAvx2Fma_correct

end LibcMath.Kernels.Issignalingf.Proof.Avx2Fma
