import LibcMath.Kernels.FmaximumMagf.Statement

/-!
# `fmaximum_magf` (`avx2_fma`)

**Not complete.** Each theorem below that ends in `sorry` is open; `OPEN.md` lists it.
-/

namespace LibcMath.Kernels.FmaximumMagf.Proof.Avx2Fma

open FloatLib.Floats.Formats.BinaryInterchange
open LibcMath.Libc
open LibcMath.Kernels.FmaximumMagf.Generated

/-- **Open.** Prove `fmaximum_magf` (`avx2_fma`) is correctly rounded in all four C modes. -/
theorem fmaximum_magfAvx2Fma_correctlyRounded : FmaximumMagfAvx2FmaCorrectlyRounded := by
  sorry

/--
info: 'LibcMath.Kernels.FmaximumMagf.Proof.Avx2Fma.fmaximum_magfAvx2Fma_correctlyRounded' depends on axioms: [propext,
 sorryAx,
 Classical.choice,
 Quot.sound]
-/
#guard_msgs in
#print axioms fmaximum_magfAvx2Fma_correctlyRounded

end LibcMath.Kernels.FmaximumMagf.Proof.Avx2Fma
