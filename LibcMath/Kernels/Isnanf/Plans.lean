import LibcMath.Kernels.Isnanf.Generated.GenericSse2
import LibcMath.Kernels.Isnanf.Generated.Sse42
import LibcMath.Kernels.Isnanf.Generated.Avx2Fma
import LibcMath.Kernels.Isnanf.Generated.AArch64

/-!
# Extracted `isnanf` plans

The plans that `ast2lean` writes under `Generated/`. Every name says the evaluation plan or the
target.

* `GenericSse2`: `generic_sse2`.
* `Sse42`: `sse42`.
* `Avx2Fma`: `avx2_fma`.
* `AArch64`: `aarch64`.
-/

namespace LibcMath.Kernels.Isnanf

open FloatLib.Floats.Formats.BinaryInterchange
open LibcMath.Libc
open LibcMath.Kernels.Isnanf.Generated

end LibcMath.Kernels.Isnanf
