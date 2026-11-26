import LibcMath.Kernels.Canonicalizef.Generated.GenericSse2
import LibcMath.Kernels.Canonicalizef.Generated.Sse42
import LibcMath.Kernels.Canonicalizef.Generated.Avx2Fma
import LibcMath.Kernels.Canonicalizef.Generated.AArch64

/-!
# Extracted `canonicalizef` plans

The plans that `ast2lean` writes under `Generated/`. Every name says the evaluation plan or the
target.

* `GenericSse2`: `generic_sse2`.
* `Sse42`: `sse42`.
* `Avx2Fma`: `avx2_fma`.
* `AArch64`: `aarch64`.
-/

namespace LibcMath.Kernels.Canonicalizef

open FloatLib.Floats.Formats.BinaryInterchange
open LibcMath.Libc
open LibcMath.Kernels.Canonicalizef.Generated

end LibcMath.Kernels.Canonicalizef
