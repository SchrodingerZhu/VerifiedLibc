import LibcMath.Kernels.Asinpif.Statement

/-!
# `asinpif` (`avx2_fma`)

**Not complete.** Each theorem below that ends in `sorry` is open; `OPEN.md` lists it.
-/

namespace LibcMath.Kernels.Asinpif.Proof.Avx2Fma

open FloatLib.Floats.Formats.BinaryInterchange
open LibcMath.Libc
open LibcMath.Kernels.Asinpif.Generated

/-- **Open.** Prove `asinpif` (`avx2_fma`) is correctly rounded in all four C modes. -/
theorem asinpifAvx2Fma_correctlyRounded : AsinpifAvx2FmaCorrectlyRounded := by
  sorry

/--
info: 'LibcMath.Kernels.Asinpif.Proof.Avx2Fma.asinpifAvx2Fma_correctlyRounded' depends on axioms: [propext,
 sorryAx,
 Classical.choice,
 Quot.sound]
-/
#guard_msgs in
#print axioms asinpifAvx2Fma_correctlyRounded

end LibcMath.Kernels.Asinpif.Proof.Avx2Fma
