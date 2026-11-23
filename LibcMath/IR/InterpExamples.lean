import LibcMath.Exhaustive.ExpfInterp
import LibcMath.IR.InterpDiag

/-!
# The interpreter on `expf` and on small functions

Kept in the build so that the results stay true:

* results of the extracted `expf` at a few inputs, under two rounding directions;
* a function on which the interpreter gives up, and the report of `Func.explain`;
* the axioms of the soundness theorem.
-/

namespace LibcMath.IR.Examples

open FloatLib.Floats.Formats.BinaryInterchange
open Model (IEEERoundingMode)
open Extracted (expf)

/-- The bit pattern the interpreter computes for `expf` at the bit pattern `bits`. -/
def expfBits (mode : IEEERoundingMode) (bits : ℕ) : Option ℕ :=
  (expf.runUnary (fmt := .binary32) mode (.ofNatBits bits)).map (·.toNatBits)

/-! ### `expf`

`exp 1` is `0x402DF854` to nearest and `0x402DF855` upward; `exp 0` is `1`; `exp (-∞)` is `+0`;
a quiet NaN gives a NaN. -/

#guard expfBits .nearest 0x3F800000 = some 0x402DF854
#guard expfBits .up 0x3F800000 = some 0x402DF855
#guard expfBits .nearest 0x00000000 = some 0x3F800000
#guard expfBits .nearest 0xFF800000 = some 0x00000000
#guard (expf.runUnary (fmt := .binary32) .nearest (.ofNatBits 0x7FC00000)).any (·.isNaN)

/-! ### A function on which the interpreter gives up

`x - x` is a NaN at an infinity, and `Func.Returns` allows any NaN there. The interpreter records
"some NaN" for `%1` and has no answer for the addition that consumes it. -/

llvm_func nanConsumed(float %0) {
  ^bb0:
    %1 = fsub %0, %0 : float
    %2 = fadd %1, %1 : float
    ret float %2
}

/-- At `1` the difference is `+0`, and the function returns `+0`. -/
example : nanConsumed.runUnary (fmt := .binary32) .nearest (.ofNatBits 0x3F800000) =
    some (.ofNatBits 0) := by
  decide +kernel

#guard (nanConsumed.runUnary (fmt := .binary32) .nearest (.ofNatBits 0x7F800000)).isNone

/--
info: The interpreter gave up at block 0: %2 (floating-point arithmetic) has no answer. Registers not known exactly: %1 is some NaN of width 32 (FloatLib computes 0x7fc00000).
-/
#guard_msgs in
#eval IO.println (nanConsumed.explain .nearest [.ofModel (.ofNatBits 0x7F800000 : Model .binary32)])

/--
info: The interpreter answers the 32-bit pattern 0x0.
-/
#guard_msgs in
#eval IO.println (nanConsumed.explain .nearest [.ofModel (.ofNatBits 0x3F800000 : Model .binary32)])

/-! ### Axioms -/

/--
info: 'LibcMath.Extracted.expf_isComputedBy' depends on axioms: [propext, Classical.choice, Quot.sound]
-/
#guard_msgs in
#print axioms Extracted.expf_isComputedBy

end LibcMath.IR.Examples
