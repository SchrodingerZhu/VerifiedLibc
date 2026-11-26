import LibcMath.Kernels.Setpayloadf.Plans

/-!
# Worked examples for extracted `setpayloadf` plans

Each plan is evaluated at one input. Plans of the same implementation for other targets agree
with the SSE2 plan near `1`.
-/

namespace LibcMath.Kernels.Setpayloadf.Examples

open FloatLib.Floats.Formats.BinaryInterchange
open LibcMath.Libc
open LibcMath.Libc.DSL
open LibcMath.Kernels.Setpayloadf.Generated

#guard (GenericSse2.setpayloadf .nearest f32(0x3FC00000#32)).isSome

#guard (Sse42.setpayloadf .nearest f32(0x3FC00000#32)).isSome

#guard (Avx2Fma.setpayloadf .nearest f32(0x3FC00000#32)).isSome

#guard (AArch64.setpayloadf .nearest f32(0x3FC00000#32)).isSome

end LibcMath.Kernels.Setpayloadf.Examples
