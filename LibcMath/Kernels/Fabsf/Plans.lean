import LibcMath.Kernels.Fabsf.Generated.GenericSse2
import LibcMath.Kernels.Fabsf.Generated.Sse42
import LibcMath.Kernels.Fabsf.Generated.Avx2Fma
import LibcMath.Kernels.Fabsf.Generated.AArch64

/-!
# Extracted `fabsf` plans

The plans that `ast2lean` writes under `Generated/`. Every name says the evaluation plan or the
target.

* `GenericSse2`: `generic_sse2`.
* `Sse42`: `sse42`.
* `Avx2Fma`: `avx2_fma`.
* `AArch64`: `aarch64`.
-/

namespace LibcMath.Kernels.Fabsf

open FloatLib.Floats.Formats.BinaryInterchange
open LibcMath.Libc
open LibcMath.Kernels.Fabsf.Generated

/-- All 4 extracted `fabsf` plans. -/
def allPlans : List (UnaryKernel .binary32) :=
  [ GenericSse2.kernel
  , Sse42.kernel
  , Avx2Fma.kernel
  , AArch64.kernel ]

end LibcMath.Kernels.Fabsf
