import LibcMath.Kernels.Remainderf.Generated.GenericSse2
import LibcMath.Kernels.Remainderf.Generated.Sse42
import LibcMath.Kernels.Remainderf.Generated.Avx2Fma
import LibcMath.Kernels.Remainderf.Generated.AArch64

/-!
# Extracted `remainderf` plans

The plans that `ast2lean` writes under `Generated/`. Every name says the evaluation plan or the
target.

* `GenericSse2`: `generic_sse2`.
* `Sse42`: `sse42`.
* `Avx2Fma`: `avx2_fma`.
* `AArch64`: `aarch64`.
-/

namespace LibcMath.Kernels.Remainderf

open FloatLib.Floats.Formats.BinaryInterchange
open LibcMath.Libc
open LibcMath.Kernels.Remainderf.Generated

end LibcMath.Kernels.Remainderf
