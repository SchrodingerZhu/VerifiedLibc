import LibcMath.Kernels.Nextdownf.Generated.GenericSse2
import LibcMath.Kernels.Nextdownf.Generated.Sse42
import LibcMath.Kernels.Nextdownf.Generated.Avx2Fma
import LibcMath.Kernels.Nextdownf.Generated.AArch64

/-!
# Extracted `nextdownf` plans

The plans that `ast2lean` writes under `Generated/`. Every name says the evaluation plan or the
target.

* `GenericSse2`: `generic_sse2`.
* `Sse42`: `sse42`.
* `Avx2Fma`: `avx2_fma`.
* `AArch64`: `aarch64`.
-/

namespace LibcMath.Kernels.Nextdownf

open FloatLib.Floats.Formats.BinaryInterchange
open LibcMath.Libc
open LibcMath.Kernels.Nextdownf.Generated

end LibcMath.Kernels.Nextdownf
