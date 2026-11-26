import LibcMath.Kernels.Nextafterf.Plans

/-!
# Worked examples for extracted `nextafterf` plans

Each plan is evaluated at one input. Plans of the same implementation for other targets agree
with the SSE2 plan near `1`.
-/

namespace LibcMath.Kernels.Nextafterf.Examples

open FloatLib.Floats.Formats.BinaryInterchange
open LibcMath.Libc
open LibcMath.Libc.DSL
open LibcMath.Kernels.Nextafterf.Generated

#guard (GenericSse2.nextafterf f32(0x3FC00000#32) f32(0x3FC00000#32)).isSome

#guard (Sse42.nextafterf f32(0x3FC00000#32) f32(0x3FC00000#32)).isSome

#guard (Avx2Fma.nextafterf f32(0x3FC00000#32) f32(0x3FC00000#32)).isSome

#guard (AArch64.nextafterf f32(0x3FC00000#32) f32(0x3FC00000#32)).isSome

end LibcMath.Kernels.Nextafterf.Examples
