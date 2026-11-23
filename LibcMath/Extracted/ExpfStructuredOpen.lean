import LibcMath.Extracted.ExpfStructuredEntry

/-!
# What is left of the equality between `expf` and its structured form

One statement is not proved in the build yet: `execFrom_block15_eq_expfMain`, that from block 15
on the interpreter computes `expfMain`, for every argument and rounding direction (blocks 15 to
21). `ExpfStructuredExec.lean` has a proof of it whose tactic steps all elaborate; the kernel did
not finish checking it within twenty-five minutes.

With `exec_reaches_block15` and `runUnary_special` from `ExpfStructuredEntry.lean` it gives the
equality `runUnary_eq_expfStructured` on the two main ranges and the transfer
`holdsOnBits_of_checkBlockMain'`, which are derived here.
-/

namespace LibcMath.Extracted

open FloatLib.Floats.Formats.BinaryInterchange
open Model (IEEERoundingMode)
open IR

variable {mode : IEEERoundingMode}

/-- The binary32 value with bit pattern `b`. -/
local notation "f32(" b ")" => (Model.ofBits b : Model FloatFormat.binary32)

/-- From block 15 on, the interpreter computes `expfMain`. -/
theorem execFrom_block15_eq_expfMain (fuel pred : ℕ) (s : Store) (x : Model .binary32)
    (hx : s.get 0 = some (.exact (.ofModel x))) :
    (expf.execFrom mode (fuel + 6) pred 15 s).bind (AbsVal.result? .binary32) =
      expfMain mode x := by
  sorry

/-- On the two main ranges the interpreter and `expfStructured` agree. -/
theorem runUnary_eq_expfStructured (b : BitVec 32) (hb : InExpfMainRanges b.toNat) :
    expf.runUnary mode f32(b) = expfStructured mode f32(b) := by
  by_cases hs : b.toNat = 0xC236BD8C
  · obtain rfl : b = 0xC236BD8C#32 := BitVec.eq_of_toNat_eq hs
    rw [runUnary_special]
    exact (ite_eq_left rfl).symm
  · obtain ⟨fuel, pred, s, hexec, h0⟩ := exec_reaches_block15 (mode := mode) b hb hs
    rw [Func.runUnary_eq_bind, hexec, execFrom_block15_eq_expfMain fuel pred s _ h0]
    exact (ite_eq_right hs).symm

/-- A block inside one of the two main ranges that `checkBlockMain` accepts: the interpreter
returns the correctly rounded exponential on each of its inputs. -/
theorem holdsOnBits_of_checkBlockMain' {O : Oracle (Spec.exp .binary32)} {first count : ℕ}
    (hrange : (0x32800001 ≤ first ∧ first + count ≤ 0x42B20000) ∨
      (0xB2800001 ≤ first ∧ first + count ≤ 0xC2CFF1B5))
    (h : checkBlockMain O.check mode first count = true) :
    HoldsOnBits (RunsCorrectlyAt (Spec.exp .binary32) expf.runUnary mode) first
      (first + count) :=
  holdsOnBits_of_checkBlockMain (fun b hb => runUnary_eq_expfStructured b hb) hrange h

end LibcMath.Extracted
