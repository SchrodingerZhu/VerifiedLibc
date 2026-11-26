import LibcMath.Kernels.Erff.Statement

/-!
# `erff` (`avx2_fma`)

**Not complete.** Each theorem below that ends in `sorry` is open; `OPEN.md` lists it.
-/

namespace LibcMath.Kernels.Erff.Proof.Avx2Fma

open FloatLib.Floats.Formats.BinaryInterchange
open LibcMath.Libc
open LibcMath.Kernels.Erff.Generated

/-- **Open.** Prove `erff` (`avx2_fma`) is correctly rounded in all four C modes. -/
theorem erffAvx2Fma_correctlyRounded : ErffAvx2FmaCorrectlyRounded := by
  sorry

/--
info: 'LibcMath.Kernels.Erff.Proof.Avx2Fma.erffAvx2Fma_correctlyRounded' depends on axioms: [propext,
 sorryAx,
 Classical.choice,
 Quot.sound]
-/
#guard_msgs in
#print axioms erffAvx2Fma_correctlyRounded

end LibcMath.Kernels.Erff.Proof.Avx2Fma
