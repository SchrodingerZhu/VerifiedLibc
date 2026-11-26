import LibcMath.Kernels.Exp2f.Plans

/-!
# Worked examples for extracted `exp2f` plans

Each plan is evaluated at one input. Plans of the same implementation for other targets agree
with the SSE2 plan near `1`.
-/

namespace LibcMath.Kernels.Exp2f.Examples

open FloatLib.Floats.Formats.BinaryInterchange
open LibcMath.Libc
open LibcMath.Libc.DSL
open LibcMath.Kernels.Exp2f.Generated

#guard (Diag.firstDiffBits DoubleEvalAArch64.kernel.eval DoubleEvalAvx2Fma.kernel.eval
    .nearest 0x3F800000 32).isNone

#guard (DoubleEvalSse2.kernel.eval .nearest f32(0x3FC00000#32)).isSome

#guard (DoubleEvalSse42.kernel.eval .nearest f32(0x3FC00000#32)).isSome

#guard (DoubleEvalAvx2Fma.kernel.eval .nearest f32(0x3FC00000#32)).isSome

#guard (DoubleEvalAArch64.kernel.eval .nearest f32(0x3FC00000#32)).isSome

#guard (FloatEval.kernel.eval .nearest f32(0x3FC00000#32)).isSome

#guard (IntegerEval.kernel.eval .nearest f32(0x3FC00000#32)).isSome

#guard (StaticRounding.kernel.eval .nearest f32(0x3FC00000#32)).isSome

#guard (Diag.firstDiffBits DoubleEvalSse2.kernel.eval DoubleEvalSse42.kernel.eval
    .nearest 0x3F800000 32).isNone

#guard (Diag.firstDiffBits DoubleEvalSse2.kernel.eval DoubleEvalAvx2Fma.kernel.eval
    .nearest 0x3F800000 32).isNone

#guard (Diag.firstDiffBits DoubleEvalSse2.kernel.eval DoubleEvalAArch64.kernel.eval
    .nearest 0x3F800000 32).isNone

end LibcMath.Kernels.Exp2f.Examples
