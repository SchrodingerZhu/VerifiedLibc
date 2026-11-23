import LibcMath.Extracted.Expf
import LibcMath.IR.Interp

/-!
# The Lean model of `expf`, run from the command line

    difftest-expf-model <mode> (<first> <step> <count>)...

evaluates the extracted `expf` with the interpreter under the rounding direction `<mode>`
(`nearest`, `up`, `down` or `zero`) at the binary32 bit patterns `first + i * step` modulo `2 ^ 32`
for `i < count`, for each triple in turn. `first` is hexadecimal, `step` and `count` are decimal.
Each line of output is an input and its result as eight hexadecimal digits each, or `none` in
place of the result where the interpreter gives no answer. `test/difftest/expf_native.cpp` prints
the results of the compiled function in the same form.
-/

open FloatLib.Floats.Formats.BinaryInterchange
open LibcMath.Extracted (expf)

def parseMode : String → Option Model.IEEERoundingMode
  | "nearest" => some .nearest
  | "up" => some .up
  | "down" => some .down
  | "zero" => some .towardZero
  | _ => none

def parseHex (s : String) : Option Nat :=
  if s.isEmpty then none else
    s.foldl (init := some 0) fun acc c => do
      let n ← acc
      let d ← if c.isDigit then some (c.toNat - '0'.toNat)
        else if 'a' ≤ c ∧ c ≤ 'f' then some (c.toNat - 'a'.toNat + 10)
        else if 'A' ≤ c ∧ c ≤ 'F' then some (c.toNat - 'A'.toNat + 10)
        else none
      pure (16 * n + d)

structure Range where
  first : Nat
  step : Nat
  count : Nat

def parseRanges : List String → Option (List Range)
  | [] => some []
  | first :: step :: count :: rest => do
    let range : Range := ⟨← parseHex first, ← step.toNat?, ← count.toNat?⟩
    pure (range :: (← parseRanges rest))
  | _ => none

def hex32 (x : BitVec 32) : String :=
  let digits := Nat.toDigits 16 x.toNat
  String.ofList (List.replicate (8 - digits.length) '0' ++ digits)

def resultLine (mode : Model.IEEERoundingMode) (x : BitVec 32) : String :=
  let result := match expf.runUnary (fmt := .binary32) mode (.ofBits x) with
    | some y => hex32 y.toBits
    | none => "none"
  s!"{hex32 x} {result}\n"

def main (args : List String) : IO UInt32 := do
  let some (mode, ranges) := (do
      let mode :: rest := args | none
      pure (← parseMode mode, ← parseRanges rest) : Option _)
    | IO.eprintln "usage: difftest-expf-model nearest|up|down|zero (<first> <step> <count>)..."
      return 2
  let stdout ← IO.getStdout
  for range in ranges do
    for i in [0:range.count] do
      stdout.putStr (resultLine mode (BitVec.ofNat 32 (range.first + i * range.step)))
  return 0
