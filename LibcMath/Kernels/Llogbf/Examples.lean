import LibcMath.Kernels.Llogbf.Plans

/-!
# Worked examples for extracted `llogbf` plans

Each plan is evaluated at one input. Plans of the same implementation for other targets agree
with the SSE2 plan near `1`.
-/

namespace LibcMath.Kernels.Llogbf.Examples

open FloatLib.Floats.Formats.BinaryInterchange
open LibcMath.Libc
open LibcMath.Libc.DSL
open LibcMath.Kernels.Llogbf.Generated

#guard (GenericSse2.llogbf f32(0x3FC00000#32)).isSome

#guard (Sse42.llogbf f32(0x3FC00000#32)).isSome

#guard (Avx2Fma.llogbf f32(0x3FC00000#32)).isSome

#guard (AArch64.llogbf f32(0x3FC00000#32)).isSome

end LibcMath.Kernels.Llogbf.Examples
