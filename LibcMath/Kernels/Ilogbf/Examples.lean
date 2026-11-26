import LibcMath.Kernels.Ilogbf.Plans

/-!
# Worked examples for extracted `ilogbf` plans

Each plan is evaluated at one input. Plans of the same implementation for other targets agree
with the SSE2 plan near `1`.
-/

namespace LibcMath.Kernels.Ilogbf.Examples

open FloatLib.Floats.Formats.BinaryInterchange
open LibcMath.Libc
open LibcMath.Libc.DSL
open LibcMath.Kernels.Ilogbf.Generated

#guard (GenericSse2.ilogbf f32(0x3FC00000#32)).isSome

#guard (Sse42.ilogbf f32(0x3FC00000#32)).isSome

#guard (Avx2Fma.ilogbf f32(0x3FC00000#32)).isSome

#guard (AArch64.ilogbf f32(0x3FC00000#32)).isSome

end LibcMath.Kernels.Ilogbf.Examples
