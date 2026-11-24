import LibcMath.Testing.Block
import LibcMath.Testing.Target
import LibcMath.Testing.Oracle.Mpfr

/-!
# `checkrange`: compiled evaluation of `checkRange`

    checkrange [--oracle=<name>] [--plan=<name>] <mode> <first> <count> [<block>]

evaluates `checkRange O impl mode b block` (through `checkBlock`) for the consecutive
blocks `b = first, first + block, …` covering `count` bit patterns, printing one tab-separated
line per block on stdout:

    <mode> <first> <count> <ok|fail> <milliseconds>

* `--oracle=<name>` selects the oracle `O`: `lean` [default] is `Testing.oracle`, which is proved
  sound in Lean; `mpfr` is `mpfrExpOracle`, which trusts MPFR and is much faster.
* `--plan=<name>` selects the extracted `expf` evaluation plan (`double_eval` [default],
  `double_eval_fma`, `integer_eval`, `static_rounding`, `float_eval`, `float_eval_cr_rn`).
* `mode` is `nearest`, `towardZero`, `up`, or `down`.
* On any failing block, prints a detailed diagnostic of the first failing bit pattern (hex bits,
  float classification, exact rational value, and kernel output) via `Libc.Diag.diagnoseBlock` to
  stderr so failures are immediately actionable without changing the stdout manifest format.
-/

open LibcMath LibcMath.Testing
open FloatLib.Floats.Formats.BinaryInterchange.Model (IEEERoundingMode)

def parseMode : String → Option IEEERoundingMode
  | "nearest" => some .nearest
  | "towardZero" => some .towardZero
  | "up" => some .up
  | "down" => some .down
  | _ => none

def usage : String :=
  "usage: checkrange [--oracle=lean|mpfr] [--plan=double_eval|double_eval_fma|integer_eval|" ++
    "static_rounding|float_eval|float_eval_cr_rn] <nearest|towardZero|up|down> <first> <count> " ++
    "[<block>]"

/-- The test of an oracle, by its name on the command line. -/
abbrev Check := IEEERoundingMode →
  (input result : FloatLib.Floats.Formats.BinaryInterchange.Model .binary32) → Bool

/-- Take a leading `--oracle=<name>` off the arguments. -/
def parseOracleFlag (args : List String) : Option (Check × List String) :=
  match args with
  | flag :: rest =>
      if flag.startsWith "--oracle=" then
        match (flag.drop 9).toString with
        | "lean" => some (Testing.oracle.check, rest)
        | "mpfr" => some (mpfrExpOracle.check, rest)
        | _ => none
      else
        some (Testing.oracle.check, args)
  | [] => none

def parsePlanFlag (args : List String) :
    Option (String × Libc.UnaryKernel .binary32 × List String) :=
  match args with
  | flag :: rest =>
      if flag.startsWith "--plan=" then
        let name := (flag.drop 7).toString
        match Testing.planByName? name with
        | some k => some (name, k, rest)
        | none => none
      else
        some ("double_eval", Expf.Generated.DoubleEval.kernel, args)
  | [] => none

def main (args : List String) : IO UInt32 := do
  let some (check, args) := parseOracleFlag args
    | IO.eprintln usage
      return 2
  let some (planName, kernel, restArgs) := parsePlanFlag args
    | IO.eprintln usage
      return 2
  let parsed : Option (String × IEEERoundingMode × Nat × Nat × Nat) := do
    let name :: first :: count :: rest := restArgs | none
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
    let ok := checkBlock check kernel.eval mode start size
    let t1 ← IO.monoMsNow
    if !ok then
      IO.eprintln
        (Libc.Diag.diagnoseBlock check kernel.eval mode start size s!"expf/{planName}")
    allOk := allOk && ok
    stdout.putStrLn s!"{name}\t{start}\t{size}\t{if ok then "ok" else "fail"}\t{t1 - t0}"
    stdout.flush
    start := start + size
  return if allOk then 0 else 1
