import LibcMath.Exhaustive.Run.Target
import FloatLib.Floats.Formats.BinaryInterchange.Transcendentals.CorrectlyRounded.Runtime

/-!
# Measurement: settling an input with one enclosure

`enclosure-experiment <mode> <first> <count> <degree> <precision>` measures a cheaper way to
accept a result than computing the correctly rounded one. `enclosureCheck` takes the result as
given, computes one rational enclosure of `exp input` with FloatLib's
`CorrectlyRounded.expReducedEnclosure`, and accepts when the enclosure lies strictly between the
two rounding boundaries around the result. For each of the `count` bit patterns from `first` the
program runs the implementation, then reports how many results the test accepts and the time per
input of the implementation, of the test, and of the oracle in `Run.Target` for comparison.

`enclosureCheck` is not proved sound and is not used by any certificate. It would become an oracle
through `CorrectlyRounded.contains_expReducedEnclosure` and a description of the reals that round
to a given value.
-/

open FloatLib.Floats.Formats.BinaryInterchange FloatLib.Numerics
open Model (IEEERoundingMode)
open Model.Transcendentals

/-- One enclosure of `exp input` at a fixed precision lies inside the set of reals that round to
`result` under `mode`. -/
def enclosureCheck (degree precision : Nat) (mode : IEEERoundingMode)
    (input result : Model .binary32) : Bool :=
  let b := result.toNatBits
  if 0 < b ∧ b + 1 < 0x7f800000 then
    match Model.toRat? input, Model.toRat? (.ofNatBits (b - 1) : Model .binary32),
        Model.toRat? result, Model.toRat? (.ofNatBits (b + 1) : Model .binary32) with
    | some q, some below, some r, some above =>
      let k := CorrectlyRounded.logTwoMultiple q
      let reduced := CorrectlyRounded.expReducedEnclosure q k (Certified.magnitudeBits k + 1)
        degree precision
      let scale : ℚ := (2 : ℚ) ^ k
      let lo := reduced.lo * scale
      let hi := reduced.hi * scale
      match mode with
      | .nearest => decide ((below + r) / 2 < lo ∧ hi < (r + above) / 2)
      | .down | .towardZero => decide (r < lo ∧ hi < above)
      | .up => decide (below < lo ∧ hi < r)
      | _ => false
    | _, _, _, _ => false
  else false

def main (args : List String) : IO Unit := do
  let mode : IEEERoundingMode := match args[0]! with
    | "up" => .up | "down" => .down | "towardZero" => .towardZero | _ => .nearest
  let first := args[1]!.toNat!
  let count := args[2]!.toNat!
  let degree := args[3]!.toNat!
  let precision := args[4]!.toNat!
  let start ← IO.monoNanosNow
  let results := (List.range count).filterMap fun i =>
    let input : Model .binary32 := .ofNatBits (first + i)
    (LibcMath.Exhaustive.Run.run mode input).map (input, ·)
  let t0 ← IO.monoNanosNow
  let settled := results.countP fun (x, y) => enclosureCheck degree precision mode x y
  let t1 ← IO.monoNanosNow
  let accepted := results.countP fun (x, y) => LibcMath.Exhaustive.Run.oracle.check mode x y
  let t2 ← IO.monoNanosNow
  let micros (nanos : Nat) : Nat := nanos / count / 1000
  IO.println s!"{args[0]!}\t{first}\t{count}\trun {results.length}\t{micros (t0 - start)} us\t\
    enclosure {settled}\t{micros (t1 - t0)} us\toracle {accepted}\t{micros (t2 - t1)} us"
