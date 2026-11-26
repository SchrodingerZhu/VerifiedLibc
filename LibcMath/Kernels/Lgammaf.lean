import LibcMath.Kernels.Lgammaf.Plans
import LibcMath.Kernels.Lgammaf.Statement
import LibcMath.Kernels.Lgammaf.Proof.Sse2
import LibcMath.Kernels.Lgammaf.Proof.Sse42
import LibcMath.Kernels.Lgammaf.Proof.Avx2Fma
import LibcMath.Kernels.Lgammaf.Proof.AArch64
import LibcMath.Kernels.Lgammaf.Examples

/-!
# `lgammaf`: where everything is

Every statement and theorem names its plan; there is no default plan.

* `sse2` (open): `Proof.Sse2.lgammafSse2_correctlyRounded`.
* `sse42` (open): `Proof.Sse42.lgammafSse42_correctlyRounded`.
* `avx2_fma` (open): `Proof.Avx2Fma.lgammafAvx2Fma_correctlyRounded`.
* `aarch64` (open): `Proof.AArch64.lgammafAArch64_correctlyRounded`.

* `Generated/`: the plans as `ast2lean` writes them. `Plans.lean` lists them.
* `Statement.lean`: what is to be proved about each plan.
* `Proof/<Plan>.lean`: the theorem for one plan.
* `Examples.lean`: worked evaluations.
-/
