import LibcMath.Kernels.Frexpf.Generated.GenericSse2
import LibcMath.Kernels.Frexpf.Generated.Sse42
import LibcMath.Kernels.Frexpf.Generated.Avx2Fma
import LibcMath.Kernels.Frexpf.Generated.AArch64

/-!
# Extracted `frexpf` plans

The plans that `ast2lean` writes under `Generated/`. Every name says the evaluation plan or the
target.

* `GenericSse2`: `generic_sse2`.
* `Sse42`: `sse42`.
* `Avx2Fma`: `avx2_fma`.
* `AArch64`: `aarch64`.
-/

namespace LibcMath.Kernels.Frexpf

open FloatLib.Floats.Formats.BinaryInterchange
open LibcMath.Libc
open LibcMath.Kernels.Frexpf.Generated

end LibcMath.Kernels.Frexpf
