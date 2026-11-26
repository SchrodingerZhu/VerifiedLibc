import LibcMath.Kernels.Iscanonicalf.Statement

/-!
# `iscanonicalf` (`avx2_fma`)

**Not complete.** Each theorem below that ends in `sorry` is open; `OPEN.md` lists it.
-/

namespace LibcMath.Kernels.Iscanonicalf.Proof.Avx2Fma

open FloatLib.Floats.Formats.BinaryInterchange
open Model (IEEERoundingMode)
open LibcMath.Libc
open LibcMath.Kernels.Iscanonicalf.Generated

/-- **Open.** Prove `iscanonicalf` (`avx2_fma`) matches IEEE canonical encoding predicate. -/
theorem iscanonicalfAvx2Fma_correct : IscanonicalfAvx2FmaCorrect := by
  sorry

/--
info: 'LibcMath.Kernels.Iscanonicalf.Proof.Avx2Fma.iscanonicalfAvx2Fma_correct' depends on axioms: [sorryAx]
-/
#guard_msgs in
#print axioms iscanonicalfAvx2Fma_correct

end LibcMath.Kernels.Iscanonicalf.Proof.Avx2Fma
