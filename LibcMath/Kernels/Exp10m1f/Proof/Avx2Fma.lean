import LibcMath.Kernels.Exp10m1f.Statement

/-!
# `exp10m1f` (`avx2_fma`)

**Not complete.** Each theorem below that ends in `sorry` is open; `OPEN.md` lists it.
-/

namespace LibcMath.Kernels.Exp10m1f.Proof.Avx2Fma

open FloatLib.Floats.Formats.BinaryInterchange
open LibcMath.Libc
open LibcMath.Kernels.Exp10m1f.Generated

/-- **Open.** Prove `exp10m1f` (`avx2_fma`) is correctly rounded across all four C modes. -/
theorem exp10m1fAvx2Fma_correctlyRounded : Exp10m1fAvx2FmaCorrectlyRounded := by
  sorry

/--
info: 'LibcMath.Kernels.Exp10m1f.Proof.Avx2Fma.exp10m1fAvx2Fma_correctlyRounded' depends on axioms: [propext,
 sorryAx,
 Classical.choice,
 Quot.sound]
-/
#guard_msgs in
#print axioms exp10m1fAvx2Fma_correctlyRounded

end LibcMath.Kernels.Exp10m1f.Proof.Avx2Fma
