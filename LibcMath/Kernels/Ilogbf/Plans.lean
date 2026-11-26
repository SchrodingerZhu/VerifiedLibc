import LibcMath.Kernels.Ilogbf.Generated.GenericSse2
import LibcMath.Kernels.Ilogbf.Generated.Sse42
import LibcMath.Kernels.Ilogbf.Generated.Avx2Fma
import LibcMath.Kernels.Ilogbf.Generated.AArch64

/-!
# Extracted `ilogbf` plans

The plans that `ast2lean` writes under `Generated/`. Every name says the evaluation plan or the
target.

* `GenericSse2`: `generic_sse2`.
* `Sse42`: `sse42`.
* `Avx2Fma`: `avx2_fma`.
* `AArch64`: `aarch64`.
-/

namespace LibcMath.Kernels.Ilogbf

open FloatLib.Floats.Formats.BinaryInterchange
open LibcMath.Libc
open LibcMath.Kernels.Ilogbf.Generated

end LibcMath.Kernels.Ilogbf
