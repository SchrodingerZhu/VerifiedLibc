import LibcMath.Kernels.Truncf.Statement

/-!
# `truncf` (`avx2_fma`)

**Not complete.** Each theorem below that ends in `sorry` is open; `OPEN.md` lists it.
-/

namespace LibcMath.Kernels.Truncf.Proof.Avx2Fma

open FloatLib.Floats.Formats.BinaryInterchange
open LibcMath.Libc
open LibcMath.Kernels.Truncf.Generated

/-- **Open.** Prove `truncf` (`avx2_fma`) is correctly rounded in all four C modes. -/
theorem truncfAvx2Fma_correctlyRounded : TruncfAvx2FmaCorrectlyRounded := by
  sorry

/--
info: 'LibcMath.Kernels.Truncf.Proof.Avx2Fma.truncfAvx2Fma_correctlyRounded' depends on axioms: [propext,
 sorryAx,
 Classical.choice,
 Quot.sound]
-/
#guard_msgs in
#print axioms truncfAvx2Fma_correctlyRounded

end LibcMath.Kernels.Truncf.Proof.Avx2Fma
