import LibcMath.Kernels.Modff.Generated.GenericSse2
import LibcMath.Kernels.Modff.Generated.Sse42
import LibcMath.Kernels.Modff.Generated.Avx2Fma
import LibcMath.Kernels.Modff.Generated.AArch64

/-!
# Extracted `modff` plans

The plans that `ast2lean` writes under `Generated/`. Every name says the evaluation plan or the
target.

* `GenericSse2`: `generic_sse2`.
* `Sse42`: `sse42`.
* `Avx2Fma`: `avx2_fma`.
* `AArch64`: `aarch64`.
-/

namespace LibcMath.Kernels.Modff

open FloatLib.Floats.Formats.BinaryInterchange
open LibcMath.Libc
open LibcMath.Kernels.Modff.Generated

end LibcMath.Kernels.Modff
