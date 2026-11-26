import LibcMath.Kernels.Fdimf.Generated.GenericSse2
import LibcMath.Kernels.Fdimf.Generated.Sse42
import LibcMath.Kernels.Fdimf.Generated.Avx2Fma
import LibcMath.Kernels.Fdimf.Generated.AArch64

/-!
# Extracted `fdimf` plans

The plans that `ast2lean` writes under `Generated/`. Every name says the evaluation plan or the
target.

* `GenericSse2`: `generic_sse2`.
* `Sse42`: `sse42`.
* `Avx2Fma`: `avx2_fma`.
* `AArch64`: `aarch64`.
-/

namespace LibcMath.Kernels.Fdimf

open FloatLib.Floats.Formats.BinaryInterchange
open LibcMath.Libc
open LibcMath.Kernels.Fdimf.Generated

/-- All 4 extracted `fdimf` plans. -/
def allPlans : List (BinaryKernel .binary32) :=
  [ GenericSse2.kernel
  , Sse42.kernel
  , Avx2Fma.kernel
  , AArch64.kernel ]

end LibcMath.Kernels.Fdimf
