import LibcMath.Kernels.Hypotf.Statement

/-!
# `hypotf` (`avx2_fma`)

**Not complete.** Each theorem below that ends in `sorry` is open; `OPEN.md` lists it.
-/

namespace LibcMath.Kernels.Hypotf.Proof.Avx2Fma

open FloatLib.Floats.Formats.BinaryInterchange
open LibcMath.Libc
open LibcMath.Kernels.Hypotf.Generated

/-- **Open.** Prove `hypotf` (`avx2_fma`) is correctly rounded in all four C modes. -/
theorem hypotfAvx2Fma_correctlyRounded : HypotfAvx2FmaCorrectlyRounded := by
  sorry

/--
info: 'LibcMath.Kernels.Hypotf.Proof.Avx2Fma.hypotfAvx2Fma_correctlyRounded' depends on axioms: [propext,
 sorryAx,
 Classical.choice,
 Quot.sound]
-/
#guard_msgs in
#print axioms hypotfAvx2Fma_correctlyRounded

end LibcMath.Kernels.Hypotf.Proof.Avx2Fma
