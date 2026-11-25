import LibcMath.Kernels.Expf.Plans
import LibcMath.Kernels.Exp2f.Generated.DoubleEvalSse2
import LibcMath.Kernels.Exp2f.Generated.DoubleEvalSse42
import LibcMath.Kernels.Exp2f.Generated.DoubleEvalAvx2Fma
import LibcMath.Kernels.Exp2f.Generated.FloatEval
import LibcMath.Kernels.Exp2f.Generated.IntegerEval
import LibcMath.Kernels.Exp2f.Generated.StaticRounding
import LibcMath.Kernels.Exp10f.Generated.DoubleEvalSse2
import LibcMath.Kernels.Exp10f.Generated.DoubleEvalSse42
import LibcMath.Kernels.Exp10f.Generated.DoubleEvalAvx2Fma
import LibcMath.Kernels.Exp10f.Generated.FloatEval
import LibcMath.Kernels.Exp10f.Generated.IntegerEval
import LibcMath.Kernels.Exp10f.Generated.StaticRounding
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
import LibcMath.Kernels.Sinf.Generated.DoubleEvalSse2
import LibcMath.Kernels.Sinf.Generated.DoubleEvalSse42
import LibcMath.Kernels.Sinf.Generated.DoubleEvalAvx2Fma
import LibcMath.Kernels.Sinf.Generated.FloatEval
import LibcMath.Kernels.Cosf.Generated.DoubleEvalSse2
import LibcMath.Kernels.Cosf.Generated.DoubleEvalSse42
import LibcMath.Kernels.Cosf.Generated.DoubleEvalAvx2Fma
import LibcMath.Kernels.Cosf.Generated.FloatEval
import LibcMath.Kernels.Tanf.Generated.DoubleEvalSse2
import LibcMath.Kernels.Tanf.Generated.DoubleEvalSse42
import LibcMath.Kernels.Tanf.Generated.DoubleEvalAvx2Fma
import LibcMath.Kernels.Tanf.Generated.FloatEval
import LibcMath.Kernels.Sincosf.Generated.Sse2
import LibcMath.Kernels.Sincosf.Generated.Sse42
import LibcMath.Kernels.Sincosf.Generated.Avx2Fma
import LibcMath.Kernels.Sinpif.Generated.Sse2
import LibcMath.Kernels.Sinpif.Generated.Sse42
import LibcMath.Kernels.Sinpif.Generated.Avx2Fma
import LibcMath.Kernels.Cospif.Generated.Sse2
import LibcMath.Kernels.Cospif.Generated.Sse42
import LibcMath.Kernels.Cospif.Generated.Avx2Fma
import LibcMath.Kernels.Tanpif.Generated.Sse2
import LibcMath.Kernels.Tanpif.Generated.Sse42
import LibcMath.Kernels.Tanpif.Generated.Avx2Fma
import LibcMath.Kernels.Asinf.Generated.Sse2
import LibcMath.Kernels.Asinf.Generated.Avx2Fma
import LibcMath.Kernels.Acosf.Generated.Sse2
import LibcMath.Kernels.Acosf.Generated.Avx2Fma
import LibcMath.Kernels.Atanf.Generated.DoubleEvalSse2
import LibcMath.Kernels.Atanf.Generated.DoubleEvalAvx2Fma
import LibcMath.Kernels.Atanf.Generated.FloatEval
import LibcMath.Kernels.Atan2f.Generated.DoubleEvalSse2
import LibcMath.Kernels.Atan2f.Generated.DoubleEvalAvx2Fma
import LibcMath.Kernels.Atan2f.Generated.FloatEval
import LibcMath.Kernels.Asinpif.Generated.Sse2
import LibcMath.Kernels.Asinpif.Generated.Avx2Fma
import LibcMath.Kernels.Acospif.Generated.Sse2
import LibcMath.Kernels.Acospif.Generated.Avx2Fma
import LibcMath.Kernels.Sinhf.Generated.Sse2
import LibcMath.Kernels.Sinhf.Generated.Sse42
import LibcMath.Kernels.Sinhf.Generated.Avx2Fma
import LibcMath.Kernels.Coshf.Generated.Sse2
import LibcMath.Kernels.Coshf.Generated.Sse42
import LibcMath.Kernels.Coshf.Generated.Avx2Fma
import LibcMath.Kernels.Tanhf.Generated.Sse2
import LibcMath.Kernels.Tanhf.Generated.Sse42
import LibcMath.Kernels.Tanhf.Generated.Avx2Fma
import LibcMath.Kernels.Asinhf.Generated.Sse2
import LibcMath.Kernels.Asinhf.Generated.Avx2Fma
import LibcMath.Kernels.Acoshf.Generated.Sse2
import LibcMath.Kernels.Acoshf.Generated.Avx2Fma
import LibcMath.Kernels.Atanhf.Generated.Sse2
import LibcMath.Kernels.Atanhf.Generated.Avx2Fma
import LibcMath.Kernels.Erff.Generated.Sse2
import LibcMath.Kernels.Erff.Generated.Avx2Fma
import LibcMath.Kernels.Lgammaf.Generated.Sse2
import LibcMath.Kernels.Lgammaf.Generated.Avx2Fma
import LibcMath.Kernels.Fmaf.Generated.GenericSse2
import LibcMath.Kernels.Fmaf.Generated.Avx2Fma
import LibcMath.Kernels.Fabsf.Generated.GenericSse2
import LibcMath.Kernels.Copysignf.Generated.GenericSse2
import LibcMath.Kernels.Fdimf.Generated.GenericSse2
import LibcMath.Kernels.Floorf.Generated.GenericSse2
import LibcMath.Kernels.Floorf.Generated.BuiltinSse42
import LibcMath.Kernels.Ceilf.Generated.GenericSse2
import LibcMath.Kernels.Ceilf.Generated.BuiltinSse42
import LibcMath.Kernels.Truncf.Generated.GenericSse2
import LibcMath.Kernels.Truncf.Generated.BuiltinSse42
import LibcMath.Kernels.Roundevenf.Generated.GenericSse2
import LibcMath.Kernels.Roundevenf.Generated.BuiltinSse42
import LibcMath.Kernels.Rintf.Generated.GenericSse2
import LibcMath.Kernels.Rintf.Generated.BuiltinSse42
import LibcMath.Kernels.Nearbyintf.Generated.GenericSse2
import LibcMath.Kernels.Nearbyintf.Generated.BuiltinSse42
import LibcMath.Kernels.Roundf.Generated.GenericSse2
import LibcMath.Kernels.Fmaxf.Generated.GenericSse2
import LibcMath.Kernels.Fminf.Generated.GenericSse2
import LibcMath.Kernels.Fmaximumf.Generated.GenericSse2
import LibcMath.Kernels.Fminimumf.Generated.GenericSse2
import LibcMath.Kernels.FmaximumNumf.Generated.GenericSse2
import LibcMath.Kernels.FminimumNumf.Generated.GenericSse2
import LibcMath.Kernels.FmaximumMagf.Generated.GenericSse2
import LibcMath.Kernels.FminimumMagf.Generated.GenericSse2
import LibcMath.Kernels.FmaximumMagNumf.Generated.GenericSse2
import LibcMath.Kernels.FminimumMagNumf.Generated.GenericSse2
import LibcMath.Kernels.Nextupf.Generated.GenericSse2
import LibcMath.Kernels.Nextdownf.Generated.GenericSse2
import LibcMath.Kernels.Nextafterf.Generated.GenericSse2
import LibcMath.Kernels.Ldexpf.Generated.GenericSse2
import LibcMath.Kernels.Scalbnf.Generated.GenericSse2
import LibcMath.Kernels.Scalblnf.Generated.GenericSse2
import LibcMath.Kernels.Logbf.Generated.GenericSse2
import LibcMath.Kernels.Ilogbf.Generated.GenericSse2
import LibcMath.Kernels.Llogbf.Generated.GenericSse2
import LibcMath.Kernels.Frexpf.Generated.GenericSse2
import LibcMath.Kernels.Modff.Generated.GenericSse2
import LibcMath.Kernels.Fmodf.Generated.GenericSse2
import LibcMath.Kernels.Remainderf.Generated.GenericSse2
import LibcMath.Kernels.Remquof.Generated.GenericSse2
import LibcMath.Kernels.Getpayloadf.Generated.GenericSse2
import LibcMath.Kernels.Setpayloadf.Generated.GenericSse2
import LibcMath.Kernels.Setpayloadsigf.Generated.GenericSse2
import LibcMath.Kernels.Totalorderf.Generated.GenericSse2
import LibcMath.Kernels.Totalordermagf.Generated.GenericSse2
import LibcMath.Kernels.Canonicalizef.Generated.GenericSse2
import LibcMath.Kernels.Iscanonicalf.Generated.GenericSse2
import LibcMath.Kernels.Isnanf.Generated.GenericSse2
import LibcMath.Kernels.Issignalingf.Generated.GenericSse2
import LibcMath.Kernels.Lrintf.Generated.GenericSse2
import LibcMath.Kernels.Llrintf.Generated.GenericSse2
import LibcMath.Kernels.Lroundf.Generated.GenericSse2
import LibcMath.Kernels.Llroundf.Generated.GenericSse2
import LibcMath.Kernels.Fromfpf.Generated.GenericSse2
import LibcMath.Kernels.Fromfpxf.Generated.GenericSse2
import LibcMath.Kernels.Ufromfpf.Generated.GenericSse2
import LibcMath.Kernels.Ufromfpxf.Generated.GenericSse2

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
  | "exp2f", "static_rounding" =>
      some (.uF32 LibcMath.Kernels.Exp2f.Generated.StaticRounding.kernel.eval)
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
  | "exp10f", "static_rounding" =>
      some (.uF32 LibcMath.Kernels.Exp10f.Generated.StaticRounding.kernel.eval)
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
  | "sinf", "double_eval_sse2" =>
      some (.uF32 LibcMath.Kernels.Sinf.Generated.DoubleEvalSse2.kernel.eval)
  | "sinf", "double_eval_sse42" =>
      some (.uF32 LibcMath.Kernels.Sinf.Generated.DoubleEvalSse42.kernel.eval)
  | "sinf", "double_eval_avx2_fma" =>
      some (.uF32 LibcMath.Kernels.Sinf.Generated.DoubleEvalAvx2Fma.kernel.eval)
  | "sinf", "float_eval" =>
      some (.uF32 LibcMath.Kernels.Sinf.Generated.FloatEval.kernel.eval)
  | "cosf", "double_eval_sse2" =>
      some (.uF32 LibcMath.Kernels.Cosf.Generated.DoubleEvalSse2.kernel.eval)
  | "cosf", "double_eval_sse42" =>
      some (.uF32 LibcMath.Kernels.Cosf.Generated.DoubleEvalSse42.kernel.eval)
  | "cosf", "double_eval_avx2_fma" =>
      some (.uF32 LibcMath.Kernels.Cosf.Generated.DoubleEvalAvx2Fma.kernel.eval)
  | "cosf", "float_eval" =>
      some (.uF32 LibcMath.Kernels.Cosf.Generated.FloatEval.kernel.eval)
  | "tanf", "double_eval_sse2" =>
      some (.uF32 LibcMath.Kernels.Tanf.Generated.DoubleEvalSse2.kernel.eval)
  | "tanf", "double_eval_sse42" =>
      some (.uF32 LibcMath.Kernels.Tanf.Generated.DoubleEvalSse42.kernel.eval)
  | "tanf", "double_eval_avx2_fma" =>
      some (.uF32 LibcMath.Kernels.Tanf.Generated.DoubleEvalAvx2Fma.kernel.eval)
  | "tanf", "float_eval" =>
      some (.uF32 LibcMath.Kernels.Tanf.Generated.FloatEval.kernel.eval)
  | "sincosf", "sse2" =>
      some (.uF32OutF32 fun m x => LibcMath.Kernels.Sincosf.Generated.Sse2.sincosf m x default default)
  | "sincosf", "sse42" =>
      some (.uF32OutF32 fun m x => LibcMath.Kernels.Sincosf.Generated.Sse42.sincosf m x default default)
  | "sincosf", "avx2_fma" =>
      some (.uF32OutF32 fun m x =>
        LibcMath.Kernels.Sincosf.Generated.Avx2Fma.sincosf m x default default)
  | "sinpif", "sse2" =>
      some (.uF32 LibcMath.Kernels.Sinpif.Generated.Sse2.kernel.eval)
  | "sinpif", "sse42" =>
      some (.uF32 LibcMath.Kernels.Sinpif.Generated.Sse42.kernel.eval)
  | "sinpif", "avx2_fma" =>
      some (.uF32 LibcMath.Kernels.Sinpif.Generated.Avx2Fma.kernel.eval)
  | "cospif", "sse2" =>
      some (.uF32 LibcMath.Kernels.Cospif.Generated.Sse2.kernel.eval)
  | "cospif", "sse42" =>
      some (.uF32 LibcMath.Kernels.Cospif.Generated.Sse42.kernel.eval)
  | "cospif", "avx2_fma" =>
      some (.uF32 LibcMath.Kernels.Cospif.Generated.Avx2Fma.kernel.eval)
  | "tanpif", "sse2" =>
      some (.uF32 LibcMath.Kernels.Tanpif.Generated.Sse2.kernel.eval)
  | "tanpif", "sse42" =>
      some (.uF32 LibcMath.Kernels.Tanpif.Generated.Sse42.kernel.eval)
  | "tanpif", "avx2_fma" =>
      some (.uF32 LibcMath.Kernels.Tanpif.Generated.Avx2Fma.kernel.eval)
  | "asinf", "sse2" =>
      some (.uF32 LibcMath.Kernels.Asinf.Generated.Sse2.kernel.eval)
  | "asinf", "avx2_fma" =>
      some (.uF32 LibcMath.Kernels.Asinf.Generated.Avx2Fma.kernel.eval)
  | "acosf", "sse2" =>
      some (.uF32 LibcMath.Kernels.Acosf.Generated.Sse2.kernel.eval)
  | "acosf", "avx2_fma" =>
      some (.uF32 LibcMath.Kernels.Acosf.Generated.Avx2Fma.kernel.eval)
  | "atanf", "double_eval_sse2" =>
      some (.uF32 LibcMath.Kernels.Atanf.Generated.DoubleEvalSse2.kernel.eval)
  | "atanf", "double_eval_avx2_fma" =>
      some (.uF32 LibcMath.Kernels.Atanf.Generated.DoubleEvalAvx2Fma.kernel.eval)
  | "atanf", "float_eval" =>
      some (.uF32 LibcMath.Kernels.Atanf.Generated.FloatEval.kernel.eval)
  | "atan2f", "double_eval_sse2" =>
      some (.bF32 LibcMath.Kernels.Atan2f.Generated.DoubleEvalSse2.kernel.eval)
  | "atan2f", "double_eval_avx2_fma" =>
      some (.bF32 LibcMath.Kernels.Atan2f.Generated.DoubleEvalAvx2Fma.kernel.eval)
  | "atan2f", "float_eval" =>
      some (.bF32 LibcMath.Kernels.Atan2f.Generated.FloatEval.kernel.eval)
  | "asinpif", "sse2" =>
      some (.uF32 LibcMath.Kernels.Asinpif.Generated.Sse2.kernel.eval)
  | "asinpif", "avx2_fma" =>
      some (.uF32 LibcMath.Kernels.Asinpif.Generated.Avx2Fma.kernel.eval)
  | "acospif", "sse2" =>
      some (.uF32 LibcMath.Kernels.Acospif.Generated.Sse2.kernel.eval)
  | "acospif", "avx2_fma" =>
      some (.uF32 LibcMath.Kernels.Acospif.Generated.Avx2Fma.kernel.eval)
  | "sinhf", "sse2" =>
      some (.uF32 LibcMath.Kernels.Sinhf.Generated.Sse2.kernel.eval)
  | "sinhf", "sse42" =>
      some (.uF32 LibcMath.Kernels.Sinhf.Generated.Sse42.kernel.eval)
  | "sinhf", "avx2_fma" =>
      some (.uF32 LibcMath.Kernels.Sinhf.Generated.Avx2Fma.kernel.eval)
  | "coshf", "sse2" =>
      some (.uF32 LibcMath.Kernels.Coshf.Generated.Sse2.kernel.eval)
  | "coshf", "sse42" =>
      some (.uF32 LibcMath.Kernels.Coshf.Generated.Sse42.kernel.eval)
  | "coshf", "avx2_fma" =>
      some (.uF32 LibcMath.Kernels.Coshf.Generated.Avx2Fma.kernel.eval)
  | "tanhf", "sse2" =>
      some (.uF32 LibcMath.Kernels.Tanhf.Generated.Sse2.kernel.eval)
  | "tanhf", "sse42" =>
      some (.uF32 LibcMath.Kernels.Tanhf.Generated.Sse42.kernel.eval)
  | "tanhf", "avx2_fma" =>
      some (.uF32 LibcMath.Kernels.Tanhf.Generated.Avx2Fma.kernel.eval)
  | "asinhf", "sse2" =>
      some (.uF32 LibcMath.Kernels.Asinhf.Generated.Sse2.kernel.eval)
  | "asinhf", "avx2_fma" =>
      some (.uF32 LibcMath.Kernels.Asinhf.Generated.Avx2Fma.kernel.eval)
  | "acoshf", "sse2" =>
      some (.uF32 LibcMath.Kernels.Acoshf.Generated.Sse2.kernel.eval)
  | "acoshf", "avx2_fma" =>
      some (.uF32 LibcMath.Kernels.Acoshf.Generated.Avx2Fma.kernel.eval)
  | "atanhf", "sse2" =>
      some (.uF32 LibcMath.Kernels.Atanhf.Generated.Sse2.kernel.eval)
  | "atanhf", "avx2_fma" =>
      some (.uF32 LibcMath.Kernels.Atanhf.Generated.Avx2Fma.kernel.eval)
  | "erff", "sse2" =>
      some (.uF32 LibcMath.Kernels.Erff.Generated.Sse2.kernel.eval)
  | "erff", "avx2_fma" =>
      some (.uF32 LibcMath.Kernels.Erff.Generated.Avx2Fma.kernel.eval)
  | "lgammaf", "sse2" =>
      some (.uF32 LibcMath.Kernels.Lgammaf.Generated.Sse2.kernel.eval)
  | "lgammaf", "avx2_fma" =>
      some (.uF32 LibcMath.Kernels.Lgammaf.Generated.Avx2Fma.kernel.eval)
  | "fmaf", "generic_sse2" =>
      some (.tF32 LibcMath.Kernels.Fmaf.Generated.GenericSse2.kernel.eval)
  | "fmaf", "avx2_fma" =>
      some (.tF32 LibcMath.Kernels.Fmaf.Generated.Avx2Fma.kernel.eval)
  | "fabsf", "generic_sse2" =>
      some (.uF32 LibcMath.Kernels.Fabsf.Generated.GenericSse2.kernel.eval)
  | "copysignf", "generic_sse2" =>
      some (.bF32 LibcMath.Kernels.Copysignf.Generated.GenericSse2.kernel.eval)
  | "fdimf", "generic_sse2" =>
      some (.bF32 LibcMath.Kernels.Fdimf.Generated.GenericSse2.kernel.eval)
  | "floorf", "generic_sse2" =>
      some (.uF32 LibcMath.Kernels.Floorf.Generated.GenericSse2.kernel.eval)
  | "floorf", "builtin_sse42" =>
      some (.uF32 LibcMath.Kernels.Floorf.Generated.BuiltinSse42.kernel.eval)
  | "ceilf", "generic_sse2" =>
      some (.uF32 LibcMath.Kernels.Ceilf.Generated.GenericSse2.kernel.eval)
  | "ceilf", "builtin_sse42" =>
      some (.uF32 LibcMath.Kernels.Ceilf.Generated.BuiltinSse42.kernel.eval)
  | "truncf", "generic_sse2" =>
      some (.uF32 LibcMath.Kernels.Truncf.Generated.GenericSse2.kernel.eval)
  | "truncf", "builtin_sse42" =>
      some (.uF32 LibcMath.Kernels.Truncf.Generated.BuiltinSse42.kernel.eval)
  | "roundevenf", "generic_sse2" =>
      some (.uF32 LibcMath.Kernels.Roundevenf.Generated.GenericSse2.kernel.eval)
  | "roundevenf", "builtin_sse42" =>
      some (.uF32 LibcMath.Kernels.Roundevenf.Generated.BuiltinSse42.kernel.eval)
  | "rintf", "generic_sse2" =>
      some (.uF32 LibcMath.Kernels.Rintf.Generated.GenericSse2.kernel.eval)
  | "rintf", "builtin_sse42" =>
      some (.uF32 LibcMath.Kernels.Rintf.Generated.BuiltinSse42.kernel.eval)
  | "nearbyintf", "generic_sse2" =>
      some (.uF32 LibcMath.Kernels.Nearbyintf.Generated.GenericSse2.kernel.eval)
  | "nearbyintf", "builtin_sse42" =>
      some (.uF32 LibcMath.Kernels.Nearbyintf.Generated.BuiltinSse42.kernel.eval)
  | "roundf", "generic_sse2" =>
      some (.uF32 LibcMath.Kernels.Roundf.Generated.GenericSse2.kernel.eval)
  | "fmaxf", "generic_sse2" =>
      some (.bF32 LibcMath.Kernels.Fmaxf.Generated.GenericSse2.kernel.eval)
  | "fminf", "generic_sse2" =>
      some (.bF32 LibcMath.Kernels.Fminf.Generated.GenericSse2.kernel.eval)
  | "fmaximumf", "generic_sse2" =>
      some (.bF32 LibcMath.Kernels.Fmaximumf.Generated.GenericSse2.kernel.eval)
  | "fminimumf", "generic_sse2" =>
      some (.bF32 LibcMath.Kernels.Fminimumf.Generated.GenericSse2.kernel.eval)
  | "fmaximum_numf", "generic_sse2" =>
      some (.bF32 LibcMath.Kernels.FmaximumNumf.Generated.GenericSse2.kernel.eval)
  | "fminimum_numf", "generic_sse2" =>
      some (.bF32 LibcMath.Kernels.FminimumNumf.Generated.GenericSse2.kernel.eval)
  | "fmaximum_magf", "generic_sse2" =>
      some (.bF32 LibcMath.Kernels.FmaximumMagf.Generated.GenericSse2.kernel.eval)
  | "fminimum_magf", "generic_sse2" =>
      some (.bF32 LibcMath.Kernels.FminimumMagf.Generated.GenericSse2.kernel.eval)
  | "fmaximum_mag_numf", "generic_sse2" =>
      some (.bF32 LibcMath.Kernels.FmaximumMagNumf.Generated.GenericSse2.kernel.eval)
  | "fminimum_mag_numf", "generic_sse2" =>
      some (.bF32 LibcMath.Kernels.FminimumMagNumf.Generated.GenericSse2.kernel.eval)
  | "nextupf", "generic_sse2" =>
      some (.uF32 LibcMath.Kernels.Nextupf.Generated.GenericSse2.kernel.eval)
  | "nextdownf", "generic_sse2" =>
      some (.uF32 LibcMath.Kernels.Nextdownf.Generated.GenericSse2.kernel.eval)
  | "nextafterf", "generic_sse2" =>
      some (.bF32 LibcMath.Kernels.Nextafterf.Generated.GenericSse2.kernel.eval)
  | "ldexpf", "generic_sse2" =>
      some (.uF32InI32 LibcMath.Kernels.Ldexpf.Generated.GenericSse2.ldexpf)
  | "scalbnf", "generic_sse2" =>
      some (.uF32InI32 LibcMath.Kernels.Scalbnf.Generated.GenericSse2.scalbnf)
  | "scalblnf", "generic_sse2" =>
      some (.uF32InI64 LibcMath.Kernels.Scalblnf.Generated.GenericSse2.scalblnf)
  | "logbf", "generic_sse2" =>
      some (.uF32 LibcMath.Kernels.Logbf.Generated.GenericSse2.kernel.eval)
  | "ilogbf", "generic_sse2" =>
      some (.uF32I32 fun _ x => LibcMath.Kernels.Ilogbf.Generated.GenericSse2.ilogbf x)
  | "llogbf", "generic_sse2" =>
      some (.uF32I64 fun _ x => LibcMath.Kernels.Llogbf.Generated.GenericSse2.llogbf x)
  | "frexpf", "generic_sse2" =>
      some (.uF32OutI32 fun _ x => LibcMath.Kernels.Frexpf.Generated.GenericSse2.frexpf x)
  | "modff", "generic_sse2" =>
      some (.uF32OutF32 LibcMath.Kernels.Modff.Generated.GenericSse2.modff)
  | "fmodf", "generic_sse2" =>
      some (.bF32 LibcMath.Kernels.Fmodf.Generated.GenericSse2.kernel.eval)
  | "remainderf", "generic_sse2" =>
      some (.bF32 LibcMath.Kernels.Remainderf.Generated.GenericSse2.kernel.eval)
  | "remquof", "generic_sse2" =>
      some (.bF32OutI32 LibcMath.Kernels.Remquof.Generated.GenericSse2.remquof)
  | "getpayloadf", "generic_sse2" =>
      some (.uF32 LibcMath.Kernels.Getpayloadf.Generated.GenericSse2.kernel.eval)
  | "setpayloadf", "generic_sse2" =>
      some (.uOutF32I32 LibcMath.Kernels.Setpayloadf.Generated.GenericSse2.setpayloadf)
  | "setpayloadsigf", "generic_sse2" =>
      some (.uOutF32I32 LibcMath.Kernels.Setpayloadsigf.Generated.GenericSse2.setpayloadsigf)
  | "totalorderf", "generic_sse2" =>
      some (.bPtrI32 fun _ x y => LibcMath.Kernels.Totalorderf.Generated.GenericSse2.totalorderf x y)
  | "totalordermagf", "generic_sse2" =>
      some (.bPtrI32 fun _ x y =>
        LibcMath.Kernels.Totalordermagf.Generated.GenericSse2.totalordermagf x y)
  | "canonicalizef", "generic_sse2" =>
      some (.uOutF32I32 fun _ x => LibcMath.Kernels.Canonicalizef.Generated.GenericSse2.canonicalizef x)
  | "iscanonicalf", "generic_sse2" =>
      some (.uF32I32 fun _ x => LibcMath.Kernels.Iscanonicalf.Generated.GenericSse2.iscanonicalf x)
  | "isnanf", "generic_sse2" =>
      some (.uF32I32 fun _ x => LibcMath.Kernels.Isnanf.Generated.GenericSse2.isnanf x)
  | "issignalingf", "generic_sse2" =>
      some (.uF32I32 fun _ x => LibcMath.Kernels.Issignalingf.Generated.GenericSse2.issignalingf x)
  | "lrintf", "generic_sse2" =>
      some (.uF32I64 LibcMath.Kernels.Lrintf.Generated.GenericSse2.lrintf)
  | "llrintf", "generic_sse2" =>
      some (.uF32I64 LibcMath.Kernels.Llrintf.Generated.GenericSse2.llrintf)
  | "lroundf", "generic_sse2" =>
      some (.uF32I64 fun _ x => LibcMath.Kernels.Lroundf.Generated.GenericSse2.lroundf x)
  | "llroundf", "generic_sse2" =>
      some (.uF32I64 fun _ x => LibcMath.Kernels.Llroundf.Generated.GenericSse2.llroundf x)
  | "fromfpf", "generic_sse2" =>
      some (.uF32FromFp fun _ x r w => LibcMath.Kernels.Fromfpf.Generated.GenericSse2.fromfpf x r w)
  | "fromfpxf", "generic_sse2" =>
      some (.uF32FromFp fun _ x r w => LibcMath.Kernels.Fromfpxf.Generated.GenericSse2.fromfpxf x r w)
  | "ufromfpf", "generic_sse2" =>
      some (.uF32FromFp LibcMath.Kernels.Ufromfpf.Generated.GenericSse2.ufromfpf)
  | "ufromfpxf", "generic_sse2" =>
      some (.uF32FromFp LibcMath.Kernels.Ufromfpxf.Generated.GenericSse2.ufromfpxf)
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
