import LibcMath.Kernels.Scalblnf.Generated.GenericSse2
import LibcMath.Kernels.Scalblnf.Generated.Sse42
import LibcMath.Kernels.Scalblnf.Generated.Avx2Fma
import LibcMath.Kernels.Scalblnf.Generated.AArch64

/-!
# Extracted `scalblnf` plans

The plans that `ast2lean` writes under `Generated/`. Every name says the evaluation plan or the
target.

* `GenericSse2`: `generic_sse2`.
* `Sse42`: `sse42`.
* `Avx2Fma`: `avx2_fma`.
* `AArch64`: `aarch64`.
-/

namespace LibcMath.Kernels.Scalblnf

open FloatLib.Floats.Formats.BinaryInterchange
open LibcMath.Libc
open LibcMath.Kernels.Scalblnf.Generated

end LibcMath.Kernels.Scalblnf
