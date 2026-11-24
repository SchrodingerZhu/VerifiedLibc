import LibcMath.BitRange
import LibcMath.SpecLemmas

/-!
# Correct rounding, one input at a time

`CorrectAt S impl mode x` is correct rounding at one input and one rounding direction: `impl` has
a result there, and it is the one `S` prescribes. A proof for a function is assembled from
statements `HoldsOnBits (CorrectAt S impl mode) lo hi` about ranges of bit patterns, each proved
by whatever suits the range, and `correctlyRounded_of_holdsOnBits` turns the range that covers the
format into `CorrectlyRounded`.
-/

namespace LibcMath

open FloatLib.Floats.Formats.BinaryInterchange
open Model (IEEERoundingMode)

variable {fmt : FloatFormat} {S : Spec fmt}
  {impl : IEEERoundingMode → Model fmt → Option (Model fmt)}
  {mode : IEEERoundingMode} {x y : Model fmt}

/-- Under `mode`, the implementation `impl` has a result on `x`, and it is the one `S`
prescribes. -/
@[grind]
def CorrectAt (S : Spec fmt) (impl : IEEERoundingMode → Model fmt → Option (Model fmt))
    (mode : IEEERoundingMode) (x : Model fmt) : Prop :=
  ∃ y, impl mode x = some y ∧ SameValue y (S.eval mode x)

theorem correctlyRounded_iff_forall_correctAt {modes : Set IEEERoundingMode} :
    CorrectlyRounded S modes impl ↔ ∀ mode ∈ modes, ∀ x, CorrectAt S impl mode x :=
  Iff.rfl

/-- The usual way to prove `CorrectAt`: the result of `impl`, and that it is the prescribed
one. -/
theorem CorrectAt.of_eq_some (hy : impl mode x = some y) (h : SameValue y (S.eval mode x)) :
    CorrectAt S impl mode x :=
  ⟨y, hy, h⟩

/-- An implementation that is correct on every bit pattern of the format under every mode in
`modes` is correctly rounded. -/
theorem correctlyRounded_of_holdsOnBits {modes : Set IEEERoundingMode}
    (h : ∀ mode ∈ modes, HoldsOnBits (CorrectAt S impl mode) 0 (2 ^ fmt.bitWidth)) :
    CorrectlyRounded S modes impl :=
  fun mode hmode => (h mode hmode).forall

end LibcMath
