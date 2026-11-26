import LibcMath.Kernels.Roundevenf.Plans

/-!
# Worked examples for extracted `roundevenf` plans

Each plan is evaluated at one input. Plans of the same implementation for other targets agree
with the SSE2 plan near `1`.
-/

namespace LibcMath.Kernels.Roundevenf.Examples

open FloatLib.Floats.Formats.BinaryInterchange
open LibcMath.Libc
open LibcMath.Libc.DSL
open LibcMath.Kernels.Roundevenf.Generated

#guard (GenericSse2.kernel.eval .nearest f32(0x3FC00000#32)).isSome

#guard (BuiltinSse42.kernel.eval .nearest f32(0x3FC00000#32)).isSome

#guard (Avx2Fma.kernel.eval .nearest f32(0x3FC00000#32)).isSome

#guard (AArch64.kernel.eval .nearest f32(0x3FC00000#32)).isSome

#guard (Diag.firstDiffBits GenericSse2.kernel.eval BuiltinSse42.kernel.eval
    .nearest 0x3F800000 32).isNone

#guard (Diag.firstDiffBits GenericSse2.kernel.eval Avx2Fma.kernel.eval
    .nearest 0x3F800000 32).isNone

#guard (Diag.firstDiffBits GenericSse2.kernel.eval AArch64.kernel.eval
    .nearest 0x3F800000 32).isNone

end LibcMath.Kernels.Roundevenf.Examples
