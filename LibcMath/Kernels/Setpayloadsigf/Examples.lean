import LibcMath.Kernels.Setpayloadsigf.Plans

/-!
# Worked examples for extracted `setpayloadsigf` plans

Each plan is evaluated at one input. Plans of the same implementation for other targets agree
with the SSE2 plan near `1`.
-/

namespace LibcMath.Kernels.Setpayloadsigf.Examples

open FloatLib.Floats.Formats.BinaryInterchange
open LibcMath.Libc
open LibcMath.Libc.DSL
open LibcMath.Kernels.Setpayloadsigf.Generated

#guard (GenericSse2.setpayloadsigf .nearest f32(0x3FC00000#32)).isSome

#guard (Sse42.setpayloadsigf .nearest f32(0x3FC00000#32)).isSome

#guard (Avx2Fma.setpayloadsigf .nearest f32(0x3FC00000#32)).isSome

#guard (AArch64.setpayloadsigf .nearest f32(0x3FC00000#32)).isSome

end LibcMath.Kernels.Setpayloadsigf.Examples
