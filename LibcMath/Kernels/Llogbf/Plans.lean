import LibcMath.Kernels.Llogbf.Generated.GenericSse2
import LibcMath.Kernels.Llogbf.Generated.Sse42
import LibcMath.Kernels.Llogbf.Generated.Avx2Fma
import LibcMath.Kernels.Llogbf.Generated.AArch64

/-!
# Extracted `llogbf` plans

The plans that `ast2lean` writes under `Generated/`. Every name says the evaluation plan or the
target.

* `GenericSse2`: `generic_sse2`.
* `Sse42`: `sse42`.
* `Avx2Fma`: `avx2_fma`.
* `AArch64`: `aarch64`.
-/

namespace LibcMath.Kernels.Llogbf

open FloatLib.Floats.Formats.BinaryInterchange
open LibcMath.Libc
open LibcMath.Kernels.Llogbf.Generated

end LibcMath.Kernels.Llogbf
