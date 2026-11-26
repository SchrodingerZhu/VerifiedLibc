import LibcMath.Kernels.Nearbyintf.Generated.GenericSse2
import LibcMath.Kernels.Nearbyintf.Generated.BuiltinSse42
import LibcMath.Kernels.Nearbyintf.Generated.Avx2Fma
import LibcMath.Kernels.Nearbyintf.Generated.AArch64

/-!
# Extracted `nearbyintf` plans

The plans that `ast2lean` writes under `Generated/`. Every name says the evaluation plan or the
target.

* `GenericSse2`: `generic_sse2`.
* `BuiltinSse42`: `builtin_sse42`.
* `Avx2Fma`: `avx2_fma`.
* `AArch64`: `aarch64`.
-/

namespace LibcMath.Kernels.Nearbyintf

open FloatLib.Floats.Formats.BinaryInterchange
open LibcMath.Libc
open LibcMath.Kernels.Nearbyintf.Generated

/-- All 4 extracted `nearbyintf` plans. -/
def allPlans : List (UnaryKernel .binary32) :=
  [ GenericSse2.kernel
  , BuiltinSse42.kernel
  , Avx2Fma.kernel
  , AArch64.kernel ]

end LibcMath.Kernels.Nearbyintf
