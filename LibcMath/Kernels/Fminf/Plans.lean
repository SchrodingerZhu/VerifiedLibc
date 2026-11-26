import LibcMath.Kernels.Fminf.Generated.GenericSse2
import LibcMath.Kernels.Fminf.Generated.Sse42
import LibcMath.Kernels.Fminf.Generated.Avx2Fma
import LibcMath.Kernels.Fminf.Generated.AArch64

/-!
# Extracted `fminf` plans

The plans that `ast2lean` writes under `Generated/`. Every name says the evaluation plan or the
target.

* `GenericSse2`: `generic_sse2`.
* `Sse42`: `sse42`.
* `Avx2Fma`: `avx2_fma`.
* `AArch64`: `aarch64`.
-/

namespace LibcMath.Kernels.Fminf

open FloatLib.Floats.Formats.BinaryInterchange
open LibcMath.Libc
open LibcMath.Kernels.Fminf.Generated

/-- All 4 extracted `fminf` plans. -/
def allPlans : List (BinaryKernel .binary32) :=
  [ GenericSse2.kernel
  , Sse42.kernel
  , Avx2Fma.kernel
  , AArch64.kernel ]

end LibcMath.Kernels.Fminf
