import LibcMath.Exhaustive.Run.Block
import LibcMath.Exhaustive.Run.Target

/-!
# `checkrange`: compiled evaluation of `checkRange`

    checkrange <mode> <first> <count> [<block>]

evaluates `checkRange Run.oracle Run.run mode b block` (through `checkBlock`) for the consecutive
blocks `b = first, first + block, …` that cover `count` bit patterns (one block when `block` is
omitted), and prints one tab-separated line per block:

    <mode> <first> <count> <ok|fail> <milliseconds>

`mode` is `nearest`, `towardZero`, `up` or `down`. The exit status is 0 when every block is `ok`.

A line `ok` is the compiled program's answer and proves nothing by itself. It tells which
certificates are worth generating (see `scripts/exhaustive.py`) and what they will cost.
-/

open LibcMath LibcMath.Exhaustive
open FloatLib.Floats.Formats.BinaryInterchange.Model (IEEERoundingMode)

def parseMode : String → Option IEEERoundingMode
  | "nearest" => some .nearest
  | "towardZero" => some .towardZero
  | "up" => some .up
  | "down" => some .down
  | _ => none

def usage : String := "usage: checkrange <nearest|towardZero|up|down> <first> <count> [<block>]"

def main (args : List String) : IO UInt32 := do
  let parsed : Option (String × IEEERoundingMode × Nat × Nat × Nat) := do
    let name :: first :: count :: rest := args | none
    let mode ← parseMode name
    let first ← first.toNat?
    let count ← count.toNat?
    let block ← match rest with
      | [] => some count
      | [block] => block.toNat?.filter (0 < ·)
      | _ => none
    pure (name, mode, first, count, block)
  let some (name, mode, first, count, block) := parsed
    | IO.eprintln usage
      return 2
  let stdout ← IO.getStdout
  let mut allOk := true
  let mut start := first
  while start < first + count do
    let size := min block (first + count - start)
    let t0 ← IO.monoMsNow
    let ok := checkBlock Run.oracle.check Run.run mode start size
    let t1 ← IO.monoMsNow
    allOk := allOk && ok
    stdout.putStrLn s!"{name}\t{start}\t{size}\t{if ok then "ok" else "fail"}\t{t1 - t0}"
    stdout.flush
    start := start + size
  return if allOk then 0 else 1
