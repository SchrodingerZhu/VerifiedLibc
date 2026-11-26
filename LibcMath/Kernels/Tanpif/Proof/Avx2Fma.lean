import LibcMath.Kernels.Tanpif.Statement

/-!
# `tanpif` (`avx2_fma`)

**Not complete.** Each theorem below that ends in `sorry` is open; `OPEN.md` lists it.
-/

namespace LibcMath.Kernels.Tanpif.Proof.Avx2Fma

open FloatLib.Floats.Formats.BinaryInterchange
open LibcMath.Libc
open LibcMath.Kernels.Tanpif.Generated

/-- **Open.** Prove `tanpif` (`avx2_fma`) is correctly rounded in all four C modes. -/
theorem tanpifAvx2Fma_correctlyRounded : TanpifAvx2FmaCorrectlyRounded := by
  sorry

/--
info: 'LibcMath.Kernels.Tanpif.Proof.Avx2Fma.tanpifAvx2Fma_correctlyRounded' depends on axioms: [propext,
 sorryAx,
 Classical.choice,
 Quot.sound]
-/
#guard_msgs in
#print axioms tanpifAvx2Fma_correctlyRounded

end LibcMath.Kernels.Tanpif.Proof.Avx2Fma
