import LibcMath.IR.DSL
import LibcMath.IR.Semantics

/-!
# Executions that go wrong

Two small functions with undefined behavior. The second has it on some executions only, and
shows why `Func.CorrectlyRounded` asks that no execution goes wrong in addition to constraining
the executions that return.
-/

namespace LibcMath.IR.Examples

open FloatLib.Floats.Formats.BinaryInterchange
open Model (IEEERoundingMode)

/- An addition whose `nuw` flag is violated. -/
llvm_func addOverflows() {
  ^bb0:
    %0 = add nuw 0xFFFFFFFF, 0x1 : i32
    ret i32 %0
}

example (mode : IEEERoundingMode) : addOverflows.GoesWrong mode [] := by
  refine .body (b := addOverflows.blocks[0]) rfl (.nil _) (.here ?_)
  rintro v ⟨w, x, y, ha, hb, hdefined, -⟩
  cases ha
  cases hb
  revert hdefined
  decide

/- The identity, except that it increments the unspecified result of `raiseExcept` under `nuw`:
the addition is undefined when that result is `0xFFFFFFFF`. -/
llvm_func incrementsStatus(float %0) {
  ^bb0:
    %1 = call raiseExcept()
    %2 = add nuw %1, 0x1 : i32
    ret float %0
}

/-- When `raiseExcept` returns `0`, the function returns its argument. -/
example (mode : IEEERoundingMode) (x : Model .binary32) :
    incrementsStatus.Returns mode [.ofModel x] (.ofModel x) := by
  refine .ret (b := incrementsStatus.blocks[0]) rfl (.nil _)
    (.cons (v := .ofNat 32 0) rfl (.cons ⟨32, 0, 1, rfl, rfl, rfl, rfl⟩ (.nil _))) rfl rfl

/-- Every execution that returns, returns the argument. -/
example (mode : IEEERoundingMode) (x : Model .binary32) (r : Val)
    (h : incrementsStatus.Returns mode [.ofModel x] r) : r = .ofModel x := by
  have hblock {b : Block} (hb : incrementsStatus.blocks[0]? = some b) :
      b = incrementsStatus.blocks[0] := (Option.some.inj hb).symm
  cases h with
  | ret hb h₁ h₂ hterm hr =>
    cases hblock hb
    cases h₁
    cases hterm
    obtain _ | ⟨-, _ | ⟨-, ⟨⟩⟩⟩ := h₂
    exact (Option.some.inj hr).symm
  | br hb _ _ hterm | condBr hb _ _ hterm =>
    cases hblock hb
    cases hterm

/-- When `raiseExcept` returns `0xFFFFFFFF`, the addition has no result. -/
example (mode : IEEERoundingMode) (x : Model .binary32) :
    incrementsStatus.GoesWrong mode [.ofModel x] := by
  refine .body (b := incrementsStatus.blocks[0]) rfl (.nil _)
    (.later (v := .ofNat 32 0xFFFFFFFF) rfl (.here ?_))
  rintro v ⟨w, a, b, ha, hb, hdefined, -⟩
  cases ha
  cases hb
  revert hdefined
  decide

end LibcMath.IR.Examples
