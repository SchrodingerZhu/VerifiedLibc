import LibcMath.Kernels.Ufromfpxf.Generated.GenericSse2
import LibcMath.Kernels.Ufromfpxf.Generated.Sse42
import LibcMath.Kernels.Ufromfpxf.Generated.Avx2Fma
import LibcMath.Kernels.Ufromfpxf.Generated.AArch64

/-!
# Extracted `ufromfpxf` plans

The plans that `ast2lean` writes under `Generated/`. Every name says the evaluation plan or the
target.

* `GenericSse2`: `generic_sse2`.
* `Sse42`: `sse42`.
* `Avx2Fma`: `avx2_fma`.
* `AArch64`: `aarch64`.
-/

namespace LibcMath.Kernels.Ufromfpxf

open FloatLib.Floats.Formats.BinaryInterchange
open LibcMath.Libc
open LibcMath.Kernels.Ufromfpxf.Generated

end LibcMath.Kernels.Ufromfpxf
