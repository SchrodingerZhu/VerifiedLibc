import LibcMath.Kernels.FminimumNumf.Generated.GenericSse2
import LibcMath.Kernels.FminimumNumf.Generated.Sse42
import LibcMath.Kernels.FminimumNumf.Generated.Avx2Fma
import LibcMath.Kernels.FminimumNumf.Generated.AArch64

/-!
# Extracted `fminimum_numf` plans

The plans that `ast2lean` writes under `Generated/`. Every name says the evaluation plan or the
target.

* `GenericSse2`: `generic_sse2`.
* `Sse42`: `sse42`.
* `Avx2Fma`: `avx2_fma`.
* `AArch64`: `aarch64`.
-/

namespace LibcMath.Kernels.FminimumNumf

open FloatLib.Floats.Formats.BinaryInterchange
open LibcMath.Libc
open LibcMath.Kernels.FminimumNumf.Generated

/-- All 4 extracted `fminimum_numf` plans. -/
def allPlans : List (BinaryKernel .binary32) :=
  [ GenericSse2.kernel
  , Sse42.kernel
  , Avx2Fma.kernel
  , AArch64.kernel ]

end LibcMath.Kernels.FminimumNumf
