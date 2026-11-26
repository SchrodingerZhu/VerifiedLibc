import LibcMath.Kernels.Remquof.Generated.GenericSse2
import LibcMath.Kernels.Remquof.Generated.Sse42
import LibcMath.Kernels.Remquof.Generated.Avx2Fma
import LibcMath.Kernels.Remquof.Generated.AArch64

/-!
# Extracted `remquof` plans

The plans that `ast2lean` writes under `Generated/`. Every name says the evaluation plan or the
target.

* `GenericSse2`: `generic_sse2`.
* `Sse42`: `sse42`.
* `Avx2Fma`: `avx2_fma`.
* `AArch64`: `aarch64`.
-/

namespace LibcMath.Kernels.Remquof

open FloatLib.Floats.Formats.BinaryInterchange
open LibcMath.Libc
open LibcMath.Kernels.Remquof.Generated

end LibcMath.Kernels.Remquof
