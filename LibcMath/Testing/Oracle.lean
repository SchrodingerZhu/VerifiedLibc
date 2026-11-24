import LibcMath.Framework.BitRange
import LibcMath.Framework.Spec

/-!
# Checking correct rounding input by input

A format such as binary32 has few enough bit patterns that correct rounding of a unary function
can be established by examining every input. This file fixes the pieces such a proof is assembled
from, so that they can be developed and run independently:

* an `Oracle` decides, for one input and one candidate result, whether the result is the correctly
  rounded one, and is proved sound once;
* a total executable implementation `impl : IEEERoundingMode → Model fmt → Model fmt` (such as an
  extracted `Libc.UnaryKernel`) computes the result on one input;
* `checkRange` runs both over a block of consecutive bit patterns using `checkBits`.

Establishing `checkRange … = true` for blocks that cover a format is then a finite computation,
which can be split among any number of workers.
-/

namespace LibcMath

open FloatLib.Floats.Formats.BinaryInterchange
open Model (IEEERoundingMode)

variable {fmt : FloatFormat}

/-- A sound test for the correctly rounded result of `S`. It may answer `false` on a correct
result, for instance when it gives up, but never `true` on a wrong one. -/
structure Oracle (S : Spec fmt) where
  check : IEEERoundingMode → (input result : Model fmt) → Bool
  sound : ∀ mode input result, check mode input result = true →
    SameValue result (S.eval mode input)

/-- The implementation `impl` has a result, and `O` accepts it, on each of the `count` bit
patterns starting at `first`. -/
def checkRange {S : Spec fmt} (O : Oracle S)
    (impl : IEEERoundingMode → Model fmt → Option (Model fmt))
    (mode : IEEERoundingMode) (first count : Nat) : Bool :=
  checkBits (fun input => (impl mode input).any (O.check mode input)) first count

end LibcMath
