import LibcMath.Kernels.Cospif.Generated.Sse2
import LibcMath.Kernels.Cospif.Generated.Sse42
import LibcMath.Kernels.Cospif.Generated.Avx2Fma
import LibcMath.Kernels.Cospif.Generated.AArch64

/-!
# Extracted `cospif` plans

The plans that `ast2lean` writes under `Generated/`. Every name says the evaluation plan or the
target.

* `Sse2`: `sse2`.
* `Sse42`: `sse42`.
* `Avx2Fma`: `avx2_fma`.
* `AArch64`: `aarch64`.
-/

namespace LibcMath.Kernels.Cospif

open FloatLib.Floats.Formats.BinaryInterchange
open LibcMath.Libc
open LibcMath.Kernels.Cospif.Generated

/-- All 4 extracted `cospif` plans. -/
def allPlans : List (UnaryKernel .binary32) :=
  [ Sse2.kernel
  , Sse42.kernel
  , Avx2Fma.kernel
  , AArch64.kernel ]

end LibcMath.Kernels.Cospif
