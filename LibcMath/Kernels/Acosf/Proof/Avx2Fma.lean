import LibcMath.Kernels.Acosf.Statement

/-!
# `acosf` (`avx2_fma`)

**Not complete.** Each theorem below that ends in `sorry` is open; `OPEN.md` lists it.
-/

namespace LibcMath.Kernels.Acosf.Proof.Avx2Fma

open FloatLib.Floats.Formats.BinaryInterchange
open LibcMath.Libc
open LibcMath.Kernels.Acosf.Generated

/-- **Open.** Prove `acosf` (`avx2_fma`) is correctly rounded in all four C modes. -/
theorem acosfAvx2Fma_correctlyRounded : AcosfAvx2FmaCorrectlyRounded := by
  sorry

/--
info: 'LibcMath.Kernels.Acosf.Proof.Avx2Fma.acosfAvx2Fma_correctlyRounded' depends on axioms: [propext,
 sorryAx,
 Classical.choice,
 Quot.sound]
-/
#guard_msgs in
#print axioms acosfAvx2Fma_correctlyRounded

end LibcMath.Kernels.Acosf.Proof.Avx2Fma
