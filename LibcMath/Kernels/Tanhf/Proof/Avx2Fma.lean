import LibcMath.Kernels.Tanhf.Statement

/-!
# `tanhf` (`avx2_fma`)

**Not complete.** Each theorem below that ends in `sorry` is open; `OPEN.md` lists it.
-/

namespace LibcMath.Kernels.Tanhf.Proof.Avx2Fma

open FloatLib.Floats.Formats.BinaryInterchange
open LibcMath.Libc
open LibcMath.Kernels.Tanhf.Generated

/-- **Open.** Prove `tanhf` (`avx2_fma`) is correctly rounded in all four C modes. -/
theorem tanhfAvx2Fma_correctlyRounded : TanhfAvx2FmaCorrectlyRounded := by
  sorry

/--
info: 'LibcMath.Kernels.Tanhf.Proof.Avx2Fma.tanhfAvx2Fma_correctlyRounded' depends on axioms: [propext,
 sorryAx,
 Classical.choice,
 Quot.sound]
-/
#guard_msgs in
#print axioms tanhfAvx2Fma_correctlyRounded

end LibcMath.Kernels.Tanhf.Proof.Avx2Fma
