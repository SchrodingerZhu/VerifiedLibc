import LibcMath.Kernels.Fmaf.Generated.GenericSse2
import LibcMath.Kernels.Fmaf.Generated.Sse42
import LibcMath.Kernels.Fmaf.Generated.Avx2Fma
import LibcMath.Kernels.Fmaf.Generated.AArch64

/-!
# Extracted `fmaf` plans

The plans that `ast2lean` writes under `Generated/`. Every name says the evaluation plan or the
target.

* `GenericSse2`: `generic_sse2`.
* `Sse42`: `sse42`.
* `Avx2Fma`: `avx2_fma`.
* `AArch64`: `aarch64`.
-/

namespace LibcMath.Kernels.Fmaf

open FloatLib.Floats.Formats.BinaryInterchange
open LibcMath.Libc
open LibcMath.Kernels.Fmaf.Generated

/-- All 4 extracted `fmaf` plans. -/
def allPlans : List (TernaryKernel .binary32) :=
  [ GenericSse2.kernel
  , Sse42.kernel
  , Avx2Fma.kernel
  , AArch64.kernel ]

end LibcMath.Kernels.Fmaf
