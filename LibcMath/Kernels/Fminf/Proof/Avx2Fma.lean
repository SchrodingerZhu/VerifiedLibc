import LibcMath.Kernels.Fminf.Statement

/-!
# `fminf` (`avx2_fma`)

**Not complete.** Each theorem below that ends in `sorry` is open; `OPEN.md` lists it.
-/

namespace LibcMath.Kernels.Fminf.Proof.Avx2Fma

open FloatLib.Floats.Formats.BinaryInterchange
open LibcMath.Libc
open LibcMath.Kernels.Fminf.Generated

/-- **Open.** Prove `fminf` (`avx2_fma`) is correctly rounded in all four C modes. -/
theorem fminfAvx2Fma_correctlyRounded : FminfAvx2FmaCorrectlyRounded := by
  sorry

/--
info: 'LibcMath.Kernels.Fminf.Proof.Avx2Fma.fminfAvx2Fma_correctlyRounded' depends on axioms: [propext,
 sorryAx,
 Classical.choice,
 Quot.sound]
-/
#guard_msgs in
#print axioms fminfAvx2Fma_correctlyRounded

end LibcMath.Kernels.Fminf.Proof.Avx2Fma
