import LibcMath.Kernels.Fromfpxf.Generated.GenericSse2
import LibcMath.Kernels.Fromfpxf.Generated.Sse42
import LibcMath.Kernels.Fromfpxf.Generated.Avx2Fma
import LibcMath.Kernels.Fromfpxf.Generated.AArch64

/-!
# Extracted `fromfpxf` plans

The plans that `ast2lean` writes under `Generated/`. Every name says the evaluation plan or the
target.

* `GenericSse2`: `generic_sse2`.
* `Sse42`: `sse42`.
* `Avx2Fma`: `avx2_fma`.
* `AArch64`: `aarch64`.
-/

namespace LibcMath.Kernels.Fromfpxf

open FloatLib.Floats.Formats.BinaryInterchange
open LibcMath.Libc
open LibcMath.Kernels.Fromfpxf.Generated

end LibcMath.Kernels.Fromfpxf
