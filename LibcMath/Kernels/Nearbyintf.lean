import LibcMath.Kernels.Nearbyintf.Plans
import LibcMath.Kernels.Nearbyintf.Statement
import LibcMath.Kernels.Nearbyintf.Proof.GenericSse2
import LibcMath.Kernels.Nearbyintf.Proof.BuiltinSse42
import LibcMath.Kernels.Nearbyintf.Proof.Avx2Fma
import LibcMath.Kernels.Nearbyintf.Proof.AArch64
import LibcMath.Kernels.Nearbyintf.Examples

/-!
# `nearbyintf`: where everything is

Every statement and theorem names its plan; there is no default plan.

* `generic_sse2` (open): `Proof.GenericSse2.nearbyintfGenericSse2_correctlyRounded`.
* `builtin_sse42` (open): `Proof.BuiltinSse42.nearbyintfBuiltinSse42_correctlyRounded`.
* `avx2_fma` (open): `Proof.Avx2Fma.nearbyintfAvx2Fma_correctlyRounded`.
* `aarch64` (open): `Proof.AArch64.nearbyintfAArch64_correctlyRounded`.

* `Generated/`: the plans as `ast2lean` writes them. `Plans.lean` lists them.
* `Statement.lean`: what is to be proved about each plan.
* `Proof/<Plan>.lean`: the theorem for one plan.
* `Examples.lean`: worked evaluations.
-/
