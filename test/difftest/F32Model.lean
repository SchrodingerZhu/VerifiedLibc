import LibcMath.Kernels.Expf.Plans
import LibcMath.Kernels.Exp2f.Generated.DoubleEvalSse2
import LibcMath.Kernels.Exp2f.Generated.DoubleEvalSse42
import LibcMath.Kernels.Exp2f.Generated.DoubleEvalAvx2Fma
import LibcMath.Kernels.Exp2f.Generated.FloatEval
import LibcMath.Kernels.Exp2f.Generated.IntegerEval
import LibcMath.Kernels.Exp10f.Generated.DoubleEvalSse2
import LibcMath.Kernels.Exp10f.Generated.DoubleEvalSse42
import LibcMath.Kernels.Exp10f.Generated.DoubleEvalAvx2Fma
import LibcMath.Kernels.Exp10f.Generated.FloatEval
import LibcMath.Kernels.Exp10f.Generated.IntegerEval
import LibcMath.Kernels.Expm1f.Generated.Sse2
import LibcMath.Kernels.Expm1f.Generated.Sse42
import LibcMath.Kernels.Expm1f.Generated.Avx2Fma
import LibcMath.Kernels.Exp2m1f.Generated.Sse2
import LibcMath.Kernels.Exp2m1f.Generated.Sse42
import LibcMath.Kernels.Exp2m1f.Generated.Avx2Fma
import LibcMath.Kernels.Exp10m1f.Generated.Sse2
import LibcMath.Kernels.Exp10m1f.Generated.Sse42
import LibcMath.Kernels.Exp10m1f.Generated.Avx2Fma
import LibcMath.Kernels.Logf.Generated.DoubleEvalSse2
import LibcMath.Kernels.Logf.Generated.DoubleEvalAvx2Fma
import LibcMath.Kernels.Log2f.Generated.DoubleEvalSse2
import LibcMath.Kernels.Log2f.Generated.DoubleEvalAvx2Fma
import LibcMath.Kernels.Log10f.Generated.DoubleEvalSse2
import LibcMath.Kernels.Log10f.Generated.DoubleEvalAvx2Fma
import LibcMath.Kernels.Log1pf.Generated.DoubleEvalSse2
import LibcMath.Kernels.Log1pf.Generated.DoubleEvalAvx2Fma
import LibcMath.Kernels.Cbrtf.Generated.Sse2
import LibcMath.Kernels.Cbrtf.Generated.Avx2Fma
import LibcMath.Kernels.Rsqrtf.Generated.Sse2
import LibcMath.Kernels.Rsqrtf.Generated.Avx2Fma
import LibcMath.Kernels.Hypotf.Generated.GenericSse2
import LibcMath.Kernels.Hypotf.Generated.Avx2Fma
import LibcMath.Kernels.Sqrtf.Generated.X86Sse2
import LibcMath.Kernels.Sqrtf.Generated.GenericSoftFloat
import LibcMath.Kernels.Powf.Generated.DoubleEvalSse2
import LibcMath.Kernels.Powf.Generated.DoubleEvalSse42
import LibcMath.Kernels.Powf.Generated.DoubleEvalAvx2Fma
import LibcMath.Kernels.Powf.Generated.FloatEval

/-!
# Generic Lean model runner for binary32 differential testing

    difftest-f32-model --fn=<name> --plan=<plan> <mode> (<first> <step> <count>)...
    difftest-f32-model --fn=<name> --plan=<plan> <mode> --stdin

Evaluates the selected AST-extracted binary32 kernel and prints hex bit patterns matching
`test/difftest/f32_native.cpp`.
-/

open FloatLib.Floats.Formats.BinaryInterchange
open Model (IEEERoundingMode)
open LibcMath.Libc

/-- Calling-convention adapter for extracted binary32 kernels. -/
inductive F32Entry where
  | uF32 (f : IEEERoundingMode → Model .binary32 → Option (Model .binary32))
  | bF32 (f : IEEERoundingMode → Model .binary32 → Model .binary32 → Option (Model .binary32))
  | tF32 (f : IEEERoundingMode → Model .binary32 → Model .binary32 → Model .binary32 →
      Option (Model .binary32))
  | uF32I32 (f : IEEERoundingMode → Model .binary32 → Option (BitVec 32))
  | uF32I64 (f : IEEERoundingMode → Model .binary32 → Option (BitVec 64))
  | uF32OutI32 (f : IEEERoundingMode → Model .binary32 → Option (Model .binary32 × BitVec 32))
  | uF32OutF32 (f : IEEERoundingMode → Model .binary32 →
      Option (Model .binary32 × Model .binary32))
  | bF32OutI32 (f : IEEERoundingMode → Model .binary32 → Model .binary32 →
      Option (Model .binary32 × BitVec 32))
  | uF32InI32 (f : IEEERoundingMode → Model .binary32 → BitVec 32 → Option (Model .binary32))
  | uF32InI64 (f : IEEERoundingMode → Model .binary32 → BitVec 64 → Option (Model .binary32))
  | uF32FromFp (f : IEEERoundingMode → Model .binary32 → BitVec 32 → BitVec 32 →
      Option (Model .binary32))
  | bPtrI32 (f : IEEERoundingMode → Model .binary32 → Model .binary32 → Option (BitVec 32))
  | uOutF32I32 (f : IEEERoundingMode → Model .binary32 → Option (BitVec 32 × Model .binary32))

def parseMode : String → Option IEEERoundingMode
  | "nearest" => some .nearest
  | "up" => some .up
  | "down" => some .down
  | "zero" => some .towardZero
  | _ => none

def parseHex (s : String) : Option Nat :=
  let s := s.trimAscii.toString
  if s.isEmpty then none else
    s.foldl (init := some 0) fun acc c => do
      let n ← acc
      let d ← if c.isDigit then some (c.toNat - '0'.toNat)
        else if 'a' ≤ c ∧ c ≤ 'f' then some (c.toNat - 'a'.toNat + 10)
        else if 'A' ≤ c ∧ c ≤ 'F' then some (c.toNat - 'A'.toNat + 10)
        else none
      pure (16 * n + d)

def hex32 (x : BitVec 32) : String :=
  let digits := Nat.toDigits 16 x.toNat
  String.ofList (List.replicate (8 - digits.length) '0' ++ digits)

def hex64 (x : BitVec 64) : String :=
  let digits := Nat.toDigits 16 x.toNat
  String.ofList (List.replicate (16 - digits.length) '0' ++ digits)

def lookupKernel (fn plan : String) : Option F32Entry :=
  match fn, plan with
  | "expf", "double_eval" =>
      some (.uF32 LibcMath.Kernels.Expf.Generated.DoubleEval.kernel.eval)
  | "expf", "double_eval_sse42" =>
      some (.uF32 LibcMath.Kernels.Expf.Generated.DoubleEvalSse42.kernel.eval)
  | "expf", "double_eval_fma" =>
      some (.uF32 LibcMath.Kernels.Expf.Generated.DoubleEvalFma.kernel.eval)
  | "expf", "integer_eval" =>
      some (.uF32 LibcMath.Kernels.Expf.Generated.IntegerEval.kernel.eval)
  | "expf", "static_rounding" =>
      some (.uF32 LibcMath.Kernels.Expf.Generated.StaticRounding.kernel.eval)
  | "expf", "float_eval" =>
      some (.uF32 LibcMath.Kernels.Expf.Generated.FloatEval.kernel.eval)
  | "expf", "float_eval_cr_rn" =>
      some (.uF32 LibcMath.Kernels.Expf.Generated.FloatEvalCrRn.kernel.eval)
  | "exp2f", "double_eval_sse2" =>
      some (.uF32 LibcMath.Kernels.Exp2f.Generated.DoubleEvalSse2.kernel.eval)
  | "exp2f", "double_eval_sse42" =>
      some (.uF32 LibcMath.Kernels.Exp2f.Generated.DoubleEvalSse42.kernel.eval)
  | "exp2f", "double_eval_avx2_fma" =>
      some (.uF32 LibcMath.Kernels.Exp2f.Generated.DoubleEvalAvx2Fma.kernel.eval)
  | "exp2f", "float_eval" =>
      some (.uF32 LibcMath.Kernels.Exp2f.Generated.FloatEval.kernel.eval)
  | "exp2f", "integer_eval" =>
      some (.uF32 LibcMath.Kernels.Exp2f.Generated.IntegerEval.kernel.eval)
  | "exp10f", "double_eval_sse2" =>
      some (.uF32 LibcMath.Kernels.Exp10f.Generated.DoubleEvalSse2.kernel.eval)
  | "exp10f", "double_eval_sse42" =>
      some (.uF32 LibcMath.Kernels.Exp10f.Generated.DoubleEvalSse42.kernel.eval)
  | "exp10f", "double_eval_avx2_fma" =>
      some (.uF32 LibcMath.Kernels.Exp10f.Generated.DoubleEvalAvx2Fma.kernel.eval)
  | "exp10f", "float_eval" =>
      some (.uF32 LibcMath.Kernels.Exp10f.Generated.FloatEval.kernel.eval)
  | "exp10f", "integer_eval" =>
      some (.uF32 LibcMath.Kernels.Exp10f.Generated.IntegerEval.kernel.eval)
  | "expm1f", "sse2" =>
      some (.uF32 LibcMath.Kernels.Expm1f.Generated.Sse2.kernel.eval)
  | "expm1f", "sse42" =>
      some (.uF32 LibcMath.Kernels.Expm1f.Generated.Sse42.kernel.eval)
  | "expm1f", "avx2_fma" =>
      some (.uF32 LibcMath.Kernels.Expm1f.Generated.Avx2Fma.kernel.eval)
  | "exp2m1f", "sse2" =>
      some (.uF32 LibcMath.Kernels.Exp2m1f.Generated.Sse2.kernel.eval)
  | "exp2m1f", "sse42" =>
      some (.uF32 LibcMath.Kernels.Exp2m1f.Generated.Sse42.kernel.eval)
  | "exp2m1f", "avx2_fma" =>
      some (.uF32 LibcMath.Kernels.Exp2m1f.Generated.Avx2Fma.kernel.eval)
  | "exp10m1f", "sse2" =>
      some (.uF32 LibcMath.Kernels.Exp10m1f.Generated.Sse2.kernel.eval)
  | "exp10m1f", "sse42" =>
      some (.uF32 LibcMath.Kernels.Exp10m1f.Generated.Sse42.kernel.eval)
  | "exp10m1f", "avx2_fma" =>
      some (.uF32 LibcMath.Kernels.Exp10m1f.Generated.Avx2Fma.kernel.eval)
  | "logf", "double_eval_sse2" =>
      some (.uF32 LibcMath.Kernels.Logf.Generated.DoubleEvalSse2.kernel.eval)
  | "logf", "double_eval_avx2_fma" =>
      some (.uF32 LibcMath.Kernels.Logf.Generated.DoubleEvalAvx2Fma.kernel.eval)
  | "log2f", "double_eval_sse2" =>
      some (.uF32 LibcMath.Kernels.Log2f.Generated.DoubleEvalSse2.kernel.eval)
  | "log2f", "double_eval_avx2_fma" =>
      some (.uF32 LibcMath.Kernels.Log2f.Generated.DoubleEvalAvx2Fma.kernel.eval)
  | "log10f", "double_eval_sse2" =>
      some (.uF32 LibcMath.Kernels.Log10f.Generated.DoubleEvalSse2.kernel.eval)
  | "log10f", "double_eval_avx2_fma" =>
      some (.uF32 LibcMath.Kernels.Log10f.Generated.DoubleEvalAvx2Fma.kernel.eval)
  | "log1pf", "double_eval_sse2" =>
      some (.uF32 LibcMath.Kernels.Log1pf.Generated.DoubleEvalSse2.kernel.eval)
  | "log1pf", "double_eval_avx2_fma" =>
      some (.uF32 LibcMath.Kernels.Log1pf.Generated.DoubleEvalAvx2Fma.kernel.eval)
  | "cbrtf", "sse2" =>
      some (.uF32 LibcMath.Kernels.Cbrtf.Generated.Sse2.kernel.eval)
  | "cbrtf", "avx2_fma" =>
      some (.uF32 LibcMath.Kernels.Cbrtf.Generated.Avx2Fma.kernel.eval)
  | "rsqrtf", "sse2" =>
      some (.uF32 LibcMath.Kernels.Rsqrtf.Generated.Sse2.kernel.eval)
  | "rsqrtf", "avx2_fma" =>
      some (.uF32 LibcMath.Kernels.Rsqrtf.Generated.Avx2Fma.kernel.eval)
  | "hypotf", "generic_sse2" =>
      some (.bF32 LibcMath.Kernels.Hypotf.Generated.GenericSse2.kernel.eval)
  | "hypotf", "avx2_fma" =>
      some (.bF32 LibcMath.Kernels.Hypotf.Generated.Avx2Fma.kernel.eval)
  | "sqrtf", "x86_sse2" =>
      some (.uF32 LibcMath.Kernels.Sqrtf.Generated.X86Sse2.kernel.eval)
  | "sqrtf", "generic_softfloat" =>
      some (.uF32 LibcMath.Kernels.Sqrtf.Generated.GenericSoftFloat.kernel.eval)
  | "powf", "double_eval_sse2" =>
      some (.bF32 LibcMath.Kernels.Powf.Generated.DoubleEvalSse2.kernel.eval)
  | "powf", "double_eval_sse42" =>
      some (.bF32 LibcMath.Kernels.Powf.Generated.DoubleEvalSse42.kernel.eval)
  | "powf", "double_eval_avx2_fma" =>
      some (.bF32 LibcMath.Kernels.Powf.Generated.DoubleEvalAvx2Fma.kernel.eval)
  | "powf", "float_eval" =>
      some (.bF32 LibcMath.Kernels.Powf.Generated.FloatEval.kernel.eval)
  | _, _ => none

def evalUnaryLine (entry : F32Entry) (mode : IEEERoundingMode) (bx : BitVec 32) : String :=
  let x : Model .binary32 := .ofBits bx
  match entry with
  | .uF32 f =>
      match f mode x with
      | some y => s!"{hex32 bx} {hex32 y.toBits}\n"
      | none => s!"{hex32 bx} undefined\n"
  | .uF32I32 f =>
      match f mode x with
      | some r => s!"{hex32 bx} {hex32 r}\n"
      | none => s!"{hex32 bx} undefined\n"
  | .uF32I64 f =>
      match f mode x with
      | some r => s!"{hex32 bx} {hex64 r}\n"
      | none => s!"{hex32 bx} undefined\n"
  | .uF32OutI32 f =>
      match f mode x with
      | some (y, o) => s!"{hex32 bx} {hex32 y.toBits} {hex32 o}\n"
      | none => s!"{hex32 bx} undefined undefined\n"
  | .uF32OutF32 f =>
      match f mode x with
      | some (a, b) => s!"{hex32 bx} {hex32 a.toBits} {hex32 b.toBits}\n"
      | none => s!"{hex32 bx} undefined undefined\n"
  | .uOutF32I32 f =>
      match f mode x with
      | some (r, y) => s!"{hex32 bx} {hex32 r} {hex32 y.toBits}\n"
      | none => s!"{hex32 bx} undefined undefined\n"
  | _ => s!"{hex32 bx} wrong_arity\n"

def evalStdinLine (entry : F32Entry) (mode : IEEERoundingMode) (line : String) : String :=
  let toks := (line.trimAscii.toString.splitOn " ").filter (· ≠ "")
  match entry, toks with
  | .bF32 f, [sx, sy] =>
      match parseHex sx, parseHex sy with
      | some nx, some ny =>
          let bx := BitVec.ofNat 32 nx
          let by' := BitVec.ofNat 32 ny
          match f mode (.ofBits bx) (.ofBits by') with
          | some r => s!"{hex32 bx} {hex32 by'} {hex32 r.toBits}\n"
          | none => s!"{hex32 bx} {hex32 by'} undefined\n"
      | _, _ => ""
  | .tF32 f, [sx, sy, sz] =>
      match parseHex sx, parseHex sy, parseHex sz with
      | some nx, some ny, some nz =>
          let bx := BitVec.ofNat 32 nx
          let by' := BitVec.ofNat 32 ny
          let bz := BitVec.ofNat 32 nz
          match f mode (.ofBits bx) (.ofBits by') (.ofBits bz) with
          | some r => s!"{hex32 bx} {hex32 by'} {hex32 bz} {hex32 r.toBits}\n"
          | none => s!"{hex32 bx} {hex32 by'} {hex32 bz} undefined\n"
      | _, _, _ => ""
  | .bF32OutI32 f, [sx, sy] =>
      match parseHex sx, parseHex sy with
      | some nx, some ny =>
          let bx := BitVec.ofNat 32 nx
          let by' := BitVec.ofNat 32 ny
          match f mode (.ofBits bx) (.ofBits by') with
          | some (r, q) => s!"{hex32 bx} {hex32 by'} {hex32 r.toBits} {hex32 q}\n"
          | none => s!"{hex32 bx} {hex32 by'} undefined undefined\n"
      | _, _ => ""
  | .uF32InI32 f, [sx, sk] =>
      match parseHex sx, parseHex sk with
      | some nx, some nk =>
          let bx := BitVec.ofNat 32 nx
          let bk := BitVec.ofNat 32 nk
          match f mode (.ofBits bx) bk with
          | some r => s!"{hex32 bx} {hex32 bk} {hex32 r.toBits}\n"
          | none => s!"{hex32 bx} {hex32 bk} undefined\n"
      | _, _ => ""
  | .uF32InI64 f, [sx, sk] =>
      match parseHex sx, parseHex sk with
      | some nx, some nk =>
          let bx := BitVec.ofNat 32 nx
          let bk := BitVec.ofNat 64 nk
          match f mode (.ofBits bx) bk with
          | some r => s!"{hex32 bx} {hex64 bk} {hex32 r.toBits}\n"
          | none => s!"{hex32 bx} {hex64 bk} undefined\n"
      | _, _ => ""
  | .uF32FromFp f, [sx, sr, sw] =>
      match parseHex sx, parseHex sr, parseHex sw with
      | some nx, some nr, some nw =>
          let bx := BitVec.ofNat 32 nx
          let br := BitVec.ofNat 32 nr
          let bw := BitVec.ofNat 32 nw
          match f mode (.ofBits bx) br bw with
          | some r => s!"{hex32 bx} {hex32 br} {hex32 bw} {hex32 r.toBits}\n"
          | none => s!"{hex32 bx} {hex32 br} {hex32 bw} undefined\n"
      | _, _, _ => ""
  | .bPtrI32 f, [sx, sy] =>
      match parseHex sx, parseHex sy with
      | some nx, some ny =>
          let bx := BitVec.ofNat 32 nx
          let by' := BitVec.ofNat 32 ny
          match f mode (.ofBits bx) (.ofBits by') with
          | some r => s!"{hex32 bx} {hex32 by'} {hex32 r}\n"
          | none => s!"{hex32 bx} {hex32 by'} undefined\n"
      | _, _ => ""
  | _, [sx] =>
      match parseHex sx with
      | some nx => evalUnaryLine entry mode (BitVec.ofNat 32 nx)
      | none => ""
  | _, _ => ""

structure Range where
  first : Nat
  step : Nat
  count : Nat

def parseRanges : List String → Option (List Range)
  | [] => some []
  | first :: step :: count :: rest => do
    let r : Range := ⟨← parseHex first, ← step.toNat?, ← count.toNat?⟩
    pure (r :: (← parseRanges rest))
  | _ => none

def main (args : List String) : IO UInt32 := do
  let fnFlag :: planFlag :: modeStr :: rest := args
    | IO.eprintln "usage: difftest-f32-model --fn=<name> --plan=<plan> <mode> (--stdin | <ranges>)"
      return 2
  if !fnFlag.startsWith "--fn=" || !planFlag.startsWith "--plan=" then
    IO.eprintln "error: expected --fn=<name> --plan=<plan>"
    return 2
  let fn := (fnFlag.drop 5).toString
  let plan := (planFlag.drop 7).toString
  let some entry := lookupKernel fn plan
    | IO.eprintln s!"error: unknown kernel {fn}/{plan}"
      return 2
  let some mode := parseMode modeStr
    | IO.eprintln s!"error: unknown mode {modeStr}"
      return 2
  let stdout ← IO.getStdout
  if rest == ["--stdin"] then
    let stdin ← IO.getStdin
    repeat do
      let line ← stdin.getLine
      if line.isEmpty then break
      let out := evalStdinLine entry mode line
      if !out.isEmpty then stdout.putStr out
    return 0
  let some ranges := parseRanges rest
    | IO.eprintln "error: invalid range arguments"
      return 2
  for r in ranges do
    for i in [0:r.count] do
      stdout.putStr (evalUnaryLine entry mode (BitVec.ofNat 32 (r.first + i * r.step)))
  return 0
