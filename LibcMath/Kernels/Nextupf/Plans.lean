import LibcMath.Kernels.Nextupf.Generated.GenericSse2
import LibcMath.Kernels.Nextupf.Generated.Sse42
import LibcMath.Kernels.Nextupf.Generated.Avx2Fma
import LibcMath.Kernels.Nextupf.Generated.AArch64

/-!
# Extracted `nextupf` plans

The plans that `ast2lean` writes under `Generated/`. Every name says the evaluation plan or the
target.

* `GenericSse2`: `generic_sse2`.
* `Sse42`: `sse42`.
* `Avx2Fma`: `avx2_fma`.
* `AArch64`: `aarch64`.
-/

namespace LibcMath.Kernels.Nextupf

open FloatLib.Floats.Formats.BinaryInterchange
open LibcMath.Libc
open LibcMath.Kernels.Nextupf.Generated

end LibcMath.Kernels.Nextupf
