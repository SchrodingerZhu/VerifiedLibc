import LibcMath.Exhaustive.Interface

/-!
# A compilable form of `checkRange`

`checkRange` takes the specification `S` as an argument of its oracle's type. Specifications
contain real functions and have no compiled code, so the Lean compiler rejects a call of
`checkRange` at a concrete `S`, and with it `native_decide` and any executable. `checkBlock` is
the same computation with the oracle's test passed as a plain function; `checkRange_eq_checkBlock`
transfers results back.
-/

namespace LibcMath.Exhaustive

open FloatLib.Floats.Formats.BinaryInterchange
open Model (IEEERoundingMode)

variable {fmt : FloatFormat}

/-- `run` produces a result accepted by `check` on each of the `count` bit patterns starting at
`first`. -/
def checkBlock (check : IEEERoundingMode → (input result : Model fmt) → Bool)
    (run : IEEERoundingMode → Model fmt → Option (Model fmt))
    (mode : IEEERoundingMode) (first count : Nat) : Bool :=
  (List.range count).all fun i =>
    let input : Model fmt := .ofNatBits (first + i)
    match run mode input with
    | some result => check mode input result
    | none => false

theorem checkRange_eq_checkBlock {S : Spec fmt} (O : Oracle S)
    (run : IEEERoundingMode → Model fmt → Option (Model fmt))
    (mode : IEEERoundingMode) (first count : Nat) :
    checkRange O run mode first count = checkBlock O.check run mode first count :=
  rfl

theorem checkRange_of_checkBlock {S : Spec fmt} {O : Oracle S}
    {run : IEEERoundingMode → Model fmt → Option (Model fmt)}
    {mode : IEEERoundingMode} {first count : Nat}
    (h : checkBlock O.check run mode first count = true) :
    checkRange O run mode first count = true :=
  h

end LibcMath.Exhaustive
