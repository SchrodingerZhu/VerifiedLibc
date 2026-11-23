import LibcMath.Exhaustive.Expf

/-!
# The reduction on small blocks

Worked examples of `LibcMath.Exhaustive.Reduction`, kept in the build so that they stay true:

* a block check established by evaluation, and the diagnostic for a block that fails;
* certificates for adjacent ranges joined by `grind`;
* the passage from block checks to `CorrectAt`.

The oracle here knows only that `exp` of a NaN is a NaN. It stands in for a real oracle, so that
the examples depend on nothing outside this directory.
-/

namespace LibcMath.ReductionExamples

open FloatLib.Floats.Formats.BinaryInterchange
open Model (IEEERoundingMode)
open IR.Func

/-- Accepts a NaN result on a NaN input, and nothing else. -/
def nanOracle : Oracle (Spec.exp .binary32) where
  check _ input result := input.isNaN && result.isNaN
  sound mode input result h := by
    obtain ⟨hinput, hresult⟩ : input.isNaN = true ∧ result.isNaN = true := by simpa using h
    have hnan : (Model.canonicalNaN .binary32).isNaN = true := by decide
    exact .inr ⟨hresult, by simp [Spec.eval, hinput, hnan]⟩

/-- An implementation that returns its argument: right on NaNs, wrong elsewhere. -/
def idRun : IEEERoundingMode → Model .binary32 → Option (Model .binary32) :=
  fun _ x => some x

/-! ### A block that passes

The bit patterns from `0x7FC00000` are quiet NaNs. -/

example : checkRange nanOracle idRun .nearest 0x7FC00000 8 = true := by
  decide +kernel

/-- info: none -/
#guard_msgs in
#eval checkRange.firstFailure nanOracle.check idRun .nearest 0x7FC00000 8

/-! ### A block that fails, and where

`0x7F7FFFFE` and `0x7F7FFFFF` are finite, `0x7F800000` is `+∞`, and NaNs start at `0x7F800001`.
The block fails at its first input; the block starting at `0x7F800000` fails only there. -/

example : checkRange nanOracle idRun .nearest 0x7F7FFFFE 8 = false := by
  decide +kernel

/-- info: some 2139095038 -/
#guard_msgs in
#eval checkRange.firstFailure nanOracle.check idRun .nearest 0x7F7FFFFE 8

/-- info: some 2139095040 -/
#guard_msgs in
#eval checkRange.firstFailure nanOracle.check idRun .nearest 0x7F800000 8

/-! ### Joining ranges -/

example {P : Model .binary32 → Prop} (h₁ : HoldsOnBits P 0 10) (h₂ : HoldsOnBits P 10 20)
    (h₃ : HoldsOnBits P 20 32) : HoldsOnBits P 0 32 := by
  grind

/-- Ranges may overlap or arrive out of order. -/
example {P : Model .binary32 → Prop} (h₁ : HoldsOnBits P 16 32) (h₂ : HoldsOnBits P 0 20) :
    HoldsOnBits P 4 30 := by
  grind

/-! ### From block checks to correctness of an extracted function

With a sound interpreter, the two checked halves of a block give correctness on the whole block.
`grind` joins the ranges, including the arithmetic of their ends. -/

variable {f : IR.Func} {S : Spec .binary32}
  {run : IEEERoundingMode → Model .binary32 → Option (Model .binary32)}

example (hrun : f.IsComputedBy run) (O : Oracle S)
    (h₁ : checkRange O run .up 0x3F800000 0x100 = true)
    (h₂ : checkRange O run .up 0x3F800100 0x100 = true) :
    HoldsOnBits (f.CorrectAt S .up) 0x3F800000 0x3F800200 := by
  have := hrun.holdsOnBits_of_checkRange h₁
  have := hrun.holdsOnBits_of_checkRange h₂
  grind

end LibcMath.ReductionExamples
