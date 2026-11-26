import LibcMath.Kernels.Getpayloadf.Statement

/-!
# `getpayloadf` (`avx2_fma`)

**Not complete.** Each theorem below that ends in `sorry` is open; `OPEN.md` lists it.
-/

namespace LibcMath.Kernels.Getpayloadf.Proof.Avx2Fma

open FloatLib.Floats.Formats.BinaryInterchange
open Model (IEEERoundingMode)
open LibcMath.Libc
open LibcMath.Kernels.Getpayloadf.Generated

/-- **Open.** Prove `getpayloadf` (`avx2_fma`) matches `FloatLibSpec.getpayload` in C modes.
-/
theorem getpayloadfAvx2Fma_correctlyRounded : GetpayloadfAvx2FmaCorrectlyRounded := by
  sorry

/--
info: 'LibcMath.Kernels.Getpayloadf.Proof.Avx2Fma.getpayloadfAvx2Fma_correctlyRounded' depends on axioms: [propext,
 sorryAx,
 Classical.choice,
 Quot.sound]
-/
#guard_msgs in
#print axioms getpayloadfAvx2Fma_correctlyRounded

end LibcMath.Kernels.Getpayloadf.Proof.Avx2Fma
