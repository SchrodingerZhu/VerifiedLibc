import LibcMath.Kernels.Nextupf.Statement

/-!
# `nextupf` (`avx2_fma`)

**Not complete.** Each theorem below that ends in `sorry` is open; `OPEN.md` lists it.
-/

namespace LibcMath.Kernels.Nextupf.Proof.Avx2Fma

open FloatLib.Floats.Formats.BinaryInterchange
open Model (IEEERoundingMode)
open LibcMath.Libc
open LibcMath.Kernels.Nextupf.Generated

/-- **Open.** Prove `nextupf` (`avx2_fma`) matches `FloatLibSpec.nextup` in all four C modes. -/
theorem nextupfAvx2Fma_correctlyRounded : NextupfAvx2FmaCorrectlyRounded := by
  sorry

/--
info: 'LibcMath.Kernels.Nextupf.Proof.Avx2Fma.nextupfAvx2Fma_correctlyRounded' depends on axioms: [propext,
 sorryAx,
 Classical.choice,
 Quot.sound]
-/
#guard_msgs in
#print axioms nextupfAvx2Fma_correctlyRounded

end LibcMath.Kernels.Nextupf.Proof.Avx2Fma
