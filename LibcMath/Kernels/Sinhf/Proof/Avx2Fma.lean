import LibcMath.Kernels.Sinhf.Statement

/-!
# `sinhf` (`avx2_fma`)

**Not complete.** Each theorem below that ends in `sorry` is open; `OPEN.md` lists it.
-/

namespace LibcMath.Kernels.Sinhf.Proof.Avx2Fma

open FloatLib.Floats.Formats.BinaryInterchange
open LibcMath.Libc
open LibcMath.Kernels.Sinhf.Generated

/-- **Open.** Prove `sinhf` (`avx2_fma`) is correctly rounded in all four C modes. -/
theorem sinhfAvx2Fma_correctlyRounded : SinhfAvx2FmaCorrectlyRounded := by
  sorry

/--
info: 'LibcMath.Kernels.Sinhf.Proof.Avx2Fma.sinhfAvx2Fma_correctlyRounded' depends on axioms: [propext,
 sorryAx,
 Classical.choice,
 Quot.sound]
-/
#guard_msgs in
#print axioms sinhfAvx2Fma_correctlyRounded

end LibcMath.Kernels.Sinhf.Proof.Avx2Fma
