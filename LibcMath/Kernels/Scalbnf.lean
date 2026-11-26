import LibcMath.Kernels.Scalbnf.Plans
import LibcMath.Kernels.Scalbnf.Statement
import LibcMath.Kernels.Scalbnf.Proof.GenericSse2
import LibcMath.Kernels.Scalbnf.Proof.Sse42
import LibcMath.Kernels.Scalbnf.Proof.Avx2Fma
import LibcMath.Kernels.Scalbnf.Proof.AArch64
import LibcMath.Kernels.Scalbnf.Examples

/-!
# `scalbnf`: where everything is

Every statement and theorem names its plan; there is no default plan.

* `generic_sse2` (open): `Proof.GenericSse2.scalbnfGenericSse2_defined`.
* `sse42` (open): `Proof.Sse42.scalbnfSse42_defined`.
* `avx2_fma` (open): `Proof.Avx2Fma.scalbnfAvx2Fma_defined`.
* `aarch64` (open): `Proof.AArch64.scalbnfAArch64_defined`.

* `Generated/`: the plans as `ast2lean` writes them. `Plans.lean` lists them.
* `Statement.lean`: what is to be proved about each plan.
* `Proof/<Plan>.lean`: the theorem for one plan.
* `Examples.lean`: worked evaluations.
-/
