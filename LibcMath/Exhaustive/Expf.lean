import LibcMath.Exhaustive.Modes
import LibcMath.Extracted.Statements

/-!
# The reduction for `expf`

`ExpfCorrectlyRounded` from statements about the `2 ^ 32` bit patterns of binary32, in the forms
in which the pieces of the proof are expected to arrive. Each theorem here takes those pieces as
explicit hypotheses.
-/

namespace LibcMath.Extracted

open FloatLib.Floats.Formats.BinaryInterchange
open Model (IEEERoundingMode)
open IR.Func

variable {run : IEEERoundingMode → Model .binary32 → Option (Model .binary32)}

theorem forall_mem_cModes {p : IEEERoundingMode → Prop} (nearest : p .nearest)
    (towardZero : p .towardZero) (up : p .up) (down : p .down) : ∀ mode ∈ cModes, p mode := by
  rintro mode (rfl | rfl | rfl | rfl) <;> assumption

/-- `expf` is correctly rounded if it is correct on all bit patterns under each of the four
rounding directions. -/
theorem expfCorrectlyRounded_of_holdsOnBits
    (nearest : HoldsOnBits (expf.CorrectAt (Spec.exp .binary32) .nearest) 0 (2 ^ 32))
    (towardZero : HoldsOnBits (expf.CorrectAt (Spec.exp .binary32) .towardZero) 0 (2 ^ 32))
    (up : HoldsOnBits (expf.CorrectAt (Spec.exp .binary32) .up) 0 (2 ^ 32))
    (down : HoldsOnBits (expf.CorrectAt (Spec.exp .binary32) .down) 0 (2 ^ 32)) :
    ExpfCorrectlyRounded :=
  correctlyRounded_of_holdsOnBits (forall_mem_cModes nearest towardZero up down)

/-- `expf` is correctly rounded if a sound interpreter produces, on all bit patterns under each
of the four rounding directions, the results `exp` prescribes. -/
theorem expfCorrectlyRounded_of_runsCorrectly (hrun : expf.IsComputedBy run)
    (nearest : HoldsOnBits (RunsCorrectlyAt (Spec.exp .binary32) run .nearest) 0 (2 ^ 32))
    (towardZero : HoldsOnBits (RunsCorrectlyAt (Spec.exp .binary32) run .towardZero) 0 (2 ^ 32))
    (up : HoldsOnBits (RunsCorrectlyAt (Spec.exp .binary32) run .up) 0 (2 ^ 32))
    (down : HoldsOnBits (RunsCorrectlyAt (Spec.exp .binary32) run .down) 0 (2 ^ 32)) :
    ExpfCorrectlyRounded :=
  expfCorrectlyRounded_of_holdsOnBits (hrun.holdsOnBits_correctAt nearest)
    (hrun.holdsOnBits_correctAt towardZero) (hrun.holdsOnBits_correctAt up)
    (hrun.holdsOnBits_correctAt down)

/-- `expf` is correctly rounded by computation alone: a sound interpreter, a sound oracle, and for
each of the four rounding directions a list of boundaries from `0` to `2 ^ 32` all of whose blocks
pass `checkRange`. -/
theorem expfCorrectlyRounded_of_checkBlocks (hrun : expf.IsComputedBy run)
    (O : Oracle (Spec.exp .binary32)) {nearest towardZero up down : List ℕ}
    (hnearest : checkBlocks O run .nearest nearest = true)
    (hnearest₀ : 0 ∈ nearest.head?) (hnearest₁ : 2 ^ 32 ∈ nearest.getLast?)
    (htowardZero : checkBlocks O run .towardZero towardZero = true)
    (htowardZero₀ : 0 ∈ towardZero.head?) (htowardZero₁ : 2 ^ 32 ∈ towardZero.getLast?)
    (hup : checkBlocks O run .up up = true)
    (hup₀ : 0 ∈ up.head?) (hup₁ : 2 ^ 32 ∈ up.getLast?)
    (hdown : checkBlocks O run .down down = true)
    (hdown₀ : 0 ∈ down.head?) (hdown₁ : 2 ^ 32 ∈ down.getLast?) :
    ExpfCorrectlyRounded :=
  expfCorrectlyRounded_of_holdsOnBits
    (hrun.holdsOnBits_of_checkBlocks hnearest hnearest₀ hnearest₁)
    (hrun.holdsOnBits_of_checkBlocks htowardZero htowardZero₀ htowardZero₁)
    (hrun.holdsOnBits_of_checkBlocks hup hup₀ hup₁)
    (hrun.holdsOnBits_of_checkBlocks hdown hdown₀ hdown₁)

/-- A block of `expf` established for rounding down holds for rounding toward zero if the
interpreter produces the same results under both directions. -/
theorem expf_holdsOnBits_towardZero_of_down (hrun : expf.IsComputedBy run) {first count : ℕ}
    (down : HoldsOnBits (expf.CorrectAt (Spec.exp .binary32) .down) first (first + count))
    (h : checkModesAgree run .towardZero .down first count = true) :
    HoldsOnBits (expf.CorrectAt (Spec.exp .binary32) .towardZero) first (first + count) :=
  hrun.holdsOnBits_of_checkModesAgree (fun x => .of_eq (Spec.exp_eval_towardZero _ x).symm) down h

/-! ### Axioms

The reduction uses no axiom beyond the three of Mathlib; in particular not `sorryAx`, and not
`Lean.ofReduceBool` or `Lean.trustCompiler`, which `native_decide` would bring in. The build fails
if that changes. -/

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
