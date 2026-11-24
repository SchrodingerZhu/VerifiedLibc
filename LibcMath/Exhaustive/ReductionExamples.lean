import LibcMath.Exhaustive.Expf

/-!
# The reduction on small blocks

Worked examples of `LibcMath.Exhaustive.Reduction`, kept in the build so that they stay true:

* a block check established by evaluation, and the diagnostic for a block that fails;
* certificates for adjacent ranges joined by `grind`;
* the passage from block checks directly to `CorrectAt` on a total kernel.

The oracle here knows only that `exp` of a NaN is a NaN. It stands in for a real oracle, so that
the examples depend on nothing outside this directory.
-/

namespace LibcMath.ReductionExamples

open FloatLib.Floats.Formats.BinaryInterchange
open Model (IEEERoundingMode)

/-- Accepts a NaN result on a NaN input, and nothing else. -/
def nanOracle : Oracle (Spec.exp .binary32) where
  check _ input result := input.isNaN && result.isNaN
  sound mode input result h := by
    obtain ⟨hinput, hresult⟩ : input.isNaN = true ∧ result.isNaN = true := by simpa using h
    have hnan : (Model.canonicalNaN .binary32).isNaN = true := by decide
    exact .inr ⟨hresult, by simp [Spec.eval, hinput, hnan]⟩

/-- An implementation that returns its argument: right on NaNs, wrong elsewhere. -/
def idImpl : IEEERoundingMode → Model .binary32 → Model .binary32 :=
  fun _ x => x

/-! ### A block that passes

The bit patterns from `0x7FC00000` are quiet NaNs. -/

example : checkRange nanOracle idImpl .nearest 0x7FC00000 8 = true := by
  decide +kernel

/-- info: none -/
#guard_msgs in
#eval checkRange.firstFailure nanOracle.check idImpl .nearest 0x7FC00000 8

/-! ### A block that fails, and where

`0x7F7FFFFE` and `0x7F7FFFFF` are finite, `0x7F800000` is `+∞`, and NaNs start at `0x7F800001`. -/

example : checkRange nanOracle idImpl .nearest 0x7F7FFFFE 8 = false := by
  decide +kernel

/-- info: some 2139095038 -/
#guard_msgs in
#eval checkRange.firstFailure nanOracle.check idImpl .nearest 0x7F7FFFFE 8

/-- info: some 2139095040 -/
#guard_msgs in
#eval checkRange.firstFailure nanOracle.check idImpl .nearest 0x7F800000 8

/-! ### Joining ranges -/

example {P : Model .binary32 → Prop} (h₁ : HoldsOnBits P 0 10) (h₂ : HoldsOnBits P 10 20)
    (h₃ : HoldsOnBits P 20 32) : HoldsOnBits P 0 32 := by
  grind

/-- Ranges may overlap or arrive out of order. -/
example {P : Model .binary32 → Prop} (h₁ : HoldsOnBits P 16 32) (h₂ : HoldsOnBits P 0 20) :
    HoldsOnBits P 4 30 := by
  grind

/-! ### From block checks directly to correctness of a kernel -/

variable {S : Spec .binary32} {impl : IEEERoundingMode → Model .binary32 → Model .binary32}

example (O : Oracle S)
    (h₁ : checkRange O impl .up 0x3F800000 0x100 = true)
    (h₂ : checkRange O impl .up 0x3F800100 0x100 = true) :
    HoldsOnBits (CorrectAt S impl .up) 0x3F800000 0x3F800200 := by
  have := holdsOnBits_of_checkRange h₁
  have := holdsOnBits_of_checkRange h₂
  grind

end LibcMath.ReductionExamples
