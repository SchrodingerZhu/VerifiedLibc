import LibcMath.Exhaustive.Modes
import LibcMath.Extracted.Statements

/-!
# The reduction for `expf`

`CorrectlyRounded (Spec.exp .binary32) cModes impl` from statements about the `2 ^ 32` bit patterns
of binary32, specialized to `ExpfCorrectlyRounded` (`Expf.DoubleEval.expf`) as well as generic
over any total implementation `impl` (such as `DoubleEvalFma` or `StaticRounding`).
-/

namespace LibcMath.Extracted

open FloatLib.Floats.Formats.BinaryInterchange
open Model (IEEERoundingMode)

variable {impl : IEEERoundingMode → Model .binary32 → Model .binary32}

theorem forall_mem_cModes {p : IEEERoundingMode → Prop} (nearest : p .nearest)
    (towardZero : p .towardZero) (up : p .up) (down : p .down) : ∀ mode ∈ cModes, p mode := by
  rintro mode (rfl | rfl | rfl | rfl) <;> assumption

/-- Any total `binary32` implementation is correctly rounded for `exp` in all four C modes if it
is correct on `[0, 2 ^ 32)` under each mode. -/
theorem expfImplCorrectlyRounded_of_holdsOnBits
    (nearest : HoldsOnBits (CorrectAt (Spec.exp .binary32) impl .nearest) 0 (2 ^ 32))
    (towardZero : HoldsOnBits (CorrectAt (Spec.exp .binary32) impl .towardZero) 0 (2 ^ 32))
    (up : HoldsOnBits (CorrectAt (Spec.exp .binary32) impl .up) 0 (2 ^ 32))
    (down : HoldsOnBits (CorrectAt (Spec.exp .binary32) impl .down) 0 (2 ^ 32)) :
    CorrectlyRounded (Spec.exp .binary32) cModes impl :=
  correctlyRounded_of_holdsOnBits (forall_mem_cModes nearest towardZero up down)

/-- `Expf.DoubleEval.expf` is correctly rounded if it is correct on all bit patterns under each of
the four rounding directions. -/
theorem expfCorrectlyRounded_of_holdsOnBits
    (nearest : HoldsOnBits (CorrectAt (Spec.exp .binary32) Expf.DoubleEval.expf .nearest) 0 (2 ^ 32))
    (towardZero : HoldsOnBits (CorrectAt (Spec.exp .binary32) Expf.DoubleEval.expf .towardZero) 0 (2 ^ 32))
    (up : HoldsOnBits (CorrectAt (Spec.exp .binary32) Expf.DoubleEval.expf .up) 0 (2 ^ 32))
    (down : HoldsOnBits (CorrectAt (Spec.exp .binary32) Expf.DoubleEval.expf .down) 0 (2 ^ 32)) :
    ExpfCorrectlyRounded :=
  expfImplCorrectlyRounded_of_holdsOnBits nearest towardZero up down

/-- `Expf.DoubleEval.expf` is correctly rounded by computation alone: a sound oracle and, for each
of the four rounding directions, a list of boundaries from `0` to `2 ^ 32` whose blocks all pass
`checkRange`. -/
theorem expfCorrectlyRounded_of_checkBlocks
    (O : Oracle (Spec.exp .binary32)) {nearest towardZero up down : List ℕ}
    (hnearest : checkBlocks O Expf.DoubleEval.expf .nearest nearest = true)
    (hnearest₀ : 0 ∈ nearest.head?) (hnearest₁ : 2 ^ 32 ∈ nearest.getLast?)
    (htowardZero : checkBlocks O Expf.DoubleEval.expf .towardZero towardZero = true)
    (htowardZero₀ : 0 ∈ towardZero.head?) (htowardZero₁ : 2 ^ 32 ∈ towardZero.getLast?)
    (hup : checkBlocks O Expf.DoubleEval.expf .up up = true)
    (hup₀ : 0 ∈ up.head?) (hup₁ : 2 ^ 32 ∈ up.getLast?)
    (hdown : checkBlocks O Expf.DoubleEval.expf .down down = true)
    (hdown₀ : 0 ∈ down.head?) (hdown₁ : 2 ^ 32 ∈ down.getLast?) :
    ExpfCorrectlyRounded :=
  expfCorrectlyRounded_of_holdsOnBits
    (holdsOnBits_of_checkBlocks hnearest hnearest₀ hnearest₁)
    (holdsOnBits_of_checkBlocks htowardZero htowardZero₀ htowardZero₁)
    (holdsOnBits_of_checkBlocks hup hup₀ hup₁)
    (holdsOnBits_of_checkBlocks hdown hdown₀ hdown₁)

/-- A block of any `expf` implementation established for rounding down holds for rounding toward
zero if the implementation produces the same results under both directions. -/
theorem expf_holdsOnBits_towardZero_of_down {first count : ℕ}
    (down : HoldsOnBits (CorrectAt (Spec.exp .binary32) impl .down) first (first + count))
    (h : checkModesAgree impl .towardZero .down first count = true) :
    HoldsOnBits (CorrectAt (Spec.exp .binary32) impl .towardZero) first (first + count) :=
  holdsOnBits_of_checkModesAgree (fun x => .of_eq (Spec.exp_eval_towardZero _ x).symm) down h

/-! ### Axioms

The reduction uses no axiom beyond the three of Mathlib (`propext`, `Classical.choice`,
`Quot.sound`). -/

/--
info: 'LibcMath.Extracted.expfCorrectlyRounded_of_checkBlocks' depends on axioms: [propext, Classical.choice, Quot.sound]
-/
#guard_msgs in
#print axioms expfCorrectlyRounded_of_checkBlocks

/--
info: 'LibcMath.Extracted.expf_holdsOnBits_towardZero_of_down' depends on axioms: [propext, Classical.choice, Quot.sound]
-/
#guard_msgs in
#print axioms expf_holdsOnBits_towardZero_of_down

end LibcMath.Extracted
