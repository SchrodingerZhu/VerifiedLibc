import LibcMath.Kernels.Ufromfpf.Generated.GenericSse2
import LibcMath.Kernels.Ufromfpf.Generated.Sse42
import LibcMath.Kernels.Ufromfpf.Generated.Avx2Fma
import LibcMath.Kernels.Ufromfpf.Generated.AArch64

/-!
# Extracted `ufromfpf` plans

The plans that `ast2lean` writes under `Generated/`. Every name says the evaluation plan or the
target.

* `GenericSse2`: `generic_sse2`.
* `Sse42`: `sse42`.
* `Avx2Fma`: `avx2_fma`.
* `AArch64`: `aarch64`.
-/

namespace LibcMath.Kernels.Ufromfpf

open FloatLib.Floats.Formats.BinaryInterchange
open LibcMath.Libc
open LibcMath.Kernels.Ufromfpf.Generated

end LibcMath.Kernels.Ufromfpf
