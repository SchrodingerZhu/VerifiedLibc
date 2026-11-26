import LibcMath.Kernels.Remquof.Plans

/-!
# Worked examples for extracted `remquof` plans

Each plan is evaluated at one input. Plans of the same implementation for other targets agree
with the SSE2 plan near `1`.
-/

namespace LibcMath.Kernels.Remquof.Examples

open FloatLib.Floats.Formats.BinaryInterchange
open LibcMath.Libc
open LibcMath.Libc.DSL
open LibcMath.Kernels.Remquof.Generated

#guard (GenericSse2.remquof .nearest f32(0x3FC00000#32) f32(0x3FC00000#32)).isSome

#guard (Sse42.remquof .nearest f32(0x3FC00000#32) f32(0x3FC00000#32)).isSome

#guard (Avx2Fma.remquof .nearest f32(0x3FC00000#32) f32(0x3FC00000#32)).isSome

#guard (AArch64.remquof .nearest f32(0x3FC00000#32) f32(0x3FC00000#32)).isSome

end LibcMath.Kernels.Remquof.Examples
