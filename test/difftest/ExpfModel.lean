import LibcMath.Expf.Plans

/-!
# The Lean models of `expf`, run from the command line

    difftest-expf-model [--plan=<name>] <mode> (<first> <step> <count>)...

evaluates the selected AST-extracted `expf` evaluation plan under `<mode>` (`nearest`, `up`,
`down`, or `zero`) at binary32 bit patterns `first + i * step` modulo `2 ^ 32` for `i < count`.
`first` is hexadecimal; `step` and `count` are decimal. Output lines are `<input_hex> <output_hex>`,
matching `test/difftest/expf_native.cpp`.
-/

open FloatLib.Floats.Formats.BinaryInterchange
open LibcMath.Libc
open LibcMath.Expf
open LibcMath.Expf.Generated

def parseMode : String → Option Model.IEEERoundingMode
  | "nearest" => some .nearest
  | "up" => some .up
  | "down" => some .down
  | "zero" => some .towardZero
  | _ => none

def lookupPlan : String → Option (UnaryKernel .binary32)
  | "double_eval" => some DoubleEval.kernel
  | "double_eval_fma" => some DoubleEvalFma.kernel
  | "integer_eval" => some IntegerEval.kernel
  | "static_rounding" => some StaticRounding.kernel
  | "float_eval" => some FloatEval.kernel
  | "float_eval_cr_rn" => some FloatEvalCrRn.kernel
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

def resultLine (kernel : UnaryKernel .binary32) (mode : Model.IEEERoundingMode)
    (x : BitVec 32) : String :=
  -- `undefined` is not a bit pattern, so the comparison with the compiled code reports it.
  match kernel.eval mode (.ofBits x) with
  | some y => s!"{hex32 x} {hex32 y.toBits}\n"
  | none => s!"{hex32 x} undefined\n"

def main (args : List String) : IO UInt32 := do
  let parsed : Option (UnaryKernel .binary32 × Model.IEEERoundingMode × List Range) := do
    let (kernel, rest) ← match args with
      | flag :: rest =>
          if flag.startsWith "--plan=" then
            match lookupPlan (flag.drop 7).toString with
            | some k => some (k, rest)
            | none => none
          else
            some (DoubleEval.kernel, args)
      | [] => none
    let mode :: rest := rest | none
    pure (kernel, ← parseMode mode, ← parseRanges rest)
  let some (kernel, mode, ranges) := parsed
    | IO.eprintln "usage: difftest-expf-model [--plan=double_eval|double_eval_fma|integer_eval|static_rounding|float_eval|float_eval_cr_rn] nearest|up|down|zero (<first> <step> <count>)..."
      return 2
  let stdout ← IO.getStdout
  for range in ranges do
    for i in [0:range.count] do
      stdout.putStr (resultLine kernel mode (BitVec.ofNat 32 (range.first + i * range.step)))
  return 0
