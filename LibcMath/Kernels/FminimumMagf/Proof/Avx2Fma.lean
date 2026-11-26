import LibcMath.Kernels.FminimumMagf.Statement

/-!
# `fminimum_magf` (`avx2_fma`)

**Not complete.** Each theorem below that ends in `sorry` is open; `OPEN.md` lists it.
-/

namespace LibcMath.Kernels.FminimumMagf.Proof.Avx2Fma

open FloatLib.Floats.Formats.BinaryInterchange
open LibcMath.Libc
open LibcMath.Kernels.FminimumMagf.Generated

/-- **Open.** Prove `fminimum_magf` (`avx2_fma`) is correctly rounded in all four C modes. -/
theorem fminimum_magfAvx2Fma_correctlyRounded : FminimumMagfAvx2FmaCorrectlyRounded := by
  sorry

/--
info: 'LibcMath.Kernels.FminimumMagf.Proof.Avx2Fma.fminimum_magfAvx2Fma_correctlyRounded' depends on axioms: [propext,
 sorryAx,
 Classical.choice,
 Quot.sound]
-/
#guard_msgs in
#print axioms fminimum_magfAvx2Fma_correctlyRounded

end LibcMath.Kernels.FminimumMagf.Proof.Avx2Fma
