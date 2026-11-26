import LibcMath.Kernels.Exp2m1f.Plans
import LibcMath.Kernels.Exp2m1f.Statement
import LibcMath.Kernels.Exp2m1f.Proof.Sse2
import LibcMath.Kernels.Exp2m1f.Proof.Sse42
import LibcMath.Kernels.Exp2m1f.Proof.Avx2Fma
import LibcMath.Kernels.Exp2m1f.Proof.AArch64
import LibcMath.Kernels.Exp2m1f.Examples

/-!
# `exp2m1f`: where everything is

Every statement and theorem names its plan; there is no default plan.

Upstream `src/__support/math/exp2m1f.h` at `e1a5f92db023` has undefined behaviour on negative
NaNs: `static_cast<int>` of a NaN. `Proof.<Plan>.exp2m1f<Plan>_ub_at_negNaN` proves it for
each plan, and the statements exclude negative NaNs.

* `sse2` (open):
  `Proof.Sse2.exp2m1fSse2_ub_at_negNaN`,
  `Proof.Sse2.exp2m1fSse2_correctlyRounded_nonNegNaN`.
* `sse42` (open):
  `Proof.Sse42.exp2m1fSse42_ub_at_negNaN`,
  `Proof.Sse42.exp2m1fSse42_correctlyRounded_nonNegNaN`.
* `avx2_fma` (open):
  `Proof.Avx2Fma.exp2m1fAvx2Fma_ub_at_negNaN`,
  `Proof.Avx2Fma.exp2m1fAvx2Fma_correctlyRounded_nonNegNaN`.
* `aarch64` (open):
  `Proof.AArch64.exp2m1fAArch64_ub_at_negNaN`,
  `Proof.AArch64.exp2m1fAArch64_correctlyRounded_nonNegNaN`.

* `Generated/`: the plans as `ast2lean` writes them. `Plans.lean` lists them.
* `Statement.lean`: what is to be proved about each plan.
* `Proof/<Plan>.lean`: the theorem for one plan.
* `Examples.lean`: worked evaluations.
-/
