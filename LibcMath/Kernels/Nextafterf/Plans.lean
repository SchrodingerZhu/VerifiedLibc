import LibcMath.Kernels.Nextafterf.Generated.GenericSse2
import LibcMath.Kernels.Nextafterf.Generated.Sse42
import LibcMath.Kernels.Nextafterf.Generated.Avx2Fma
import LibcMath.Kernels.Nextafterf.Generated.AArch64

/-!
# Extracted `nextafterf` plans

The plans that `ast2lean` writes under `Generated/`. Every name says the evaluation plan or the
target.

* `GenericSse2`: `generic_sse2`.
* `Sse42`: `sse42`.
* `Avx2Fma`: `avx2_fma`.
* `AArch64`: `aarch64`.
-/

namespace LibcMath.Kernels.Nextafterf

open FloatLib.Floats.Formats.BinaryInterchange
open LibcMath.Libc
open LibcMath.Kernels.Nextafterf.Generated

end LibcMath.Kernels.Nextafterf
