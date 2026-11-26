import LibcMath.Kernels.Exp2m1f.Generated.Sse2
import LibcMath.Kernels.Exp2m1f.Generated.Sse42
import LibcMath.Kernels.Exp2m1f.Generated.Avx2Fma
import LibcMath.Kernels.Exp2m1f.Generated.AArch64

/-!
# Extracted `exp2m1f` plans

The plans that `ast2lean` writes under `Generated/`. Every name says the evaluation plan or the
target.

* `Sse2`: `sse2`.
* `Sse42`: `sse42`.
* `Avx2Fma`: `avx2_fma`.
* `AArch64`: `aarch64`.
-/

namespace LibcMath.Kernels.Exp2m1f

open FloatLib.Floats.Formats.BinaryInterchange
open LibcMath.Libc
open LibcMath.Kernels.Exp2m1f.Generated

/-- All 4 extracted `exp2m1f` plans. -/
def allPlans : List (UnaryKernel .binary32) :=
  [ Sse2.kernel
  , Sse42.kernel
  , Avx2Fma.kernel
  , AArch64.kernel ]

end LibcMath.Kernels.Exp2m1f
