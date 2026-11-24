import LibcMath.Exhaustive.Interface

/-!
# A compilable form of `checkRange`

`checkRange` takes the specification `S` in the type of its oracle. Specifications contain real
functions and have no compiled code, so the Lean compiler rejects a call of `checkRange` at a
concrete `S` (including `native_decide` and executables). `checkBlock` is the same `checkBits`
computation with the oracle's test passed as a plain Boolean function; `checkRange_eq_checkBlock`
is definitional (`rfl`).
-/

namespace LibcMath.Exhaustive

open FloatLib.Floats.Formats.BinaryInterchange
open Model (IEEERoundingMode)

variable {fmt : FloatFormat}

/-- `impl` produces a result accepted by `check` on each of the `count` bit patterns starting at
`first`. Delegates directly to `checkBits`. -/
def checkBlock (check : IEEERoundingMode → (input result : Model fmt) → Bool)
    (impl : IEEERoundingMode → Model fmt → Model fmt)
    (mode : IEEERoundingMode) (first count : Nat) : Bool :=
  checkBits (fun input => check mode input (impl mode input)) first count

theorem checkRange_eq_checkBlock {S : Spec fmt} (O : Oracle S)
    (impl : IEEERoundingMode → Model fmt → Model fmt)
    (mode : IEEERoundingMode) (first count : Nat) :
    checkRange O impl mode first count = checkBlock O.check impl mode first count :=
  rfl

theorem checkRange_of_checkBlock {S : Spec fmt} {O : Oracle S}
    {impl : IEEERoundingMode → Model fmt → Model fmt}
    {mode : IEEERoundingMode} {first count : Nat}
    (h : checkBlock O.check impl mode first count = true) :
    checkRange O impl mode first count = true :=
  h

end LibcMath.Exhaustive
