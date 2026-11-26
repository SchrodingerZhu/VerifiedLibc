#!/usr/bin/env python3
"""Extract LLVM libc binary32 evaluation and microarch plans into Lean 4."""

from __future__ import annotations

import concurrent.futures
import os
import subprocess
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parent.parent
BIN = ROOT / "extract" / "build" / "ast2lean"
COMMIT = "e1a5f92db023"

# Each entry: (family, kernel_dir, cpp_file, lean_fn, plan_mod, variant, flags_kind, target_override)
PLANS: list[tuple[str, str, str, str, str, str, str, str | None]] = [
    # Exponential family
    ("exp", "Expf", "expf", "expf", "DoubleEvalSse42", "double_eval_sse42", "sse42", None),
    ("exp", "Expf", "expf", "expf", "DoubleEvalAArch64", "double_eval_aarch64", "aarch64", None),
    ("exp", "Exp2f", "exp2f", "exp2f", "DoubleEvalSse2", "double_eval_sse2", "sse2", None),
    ("exp", "Exp2f", "exp2f", "exp2f", "DoubleEvalSse42", "double_eval_sse42", "sse42", None),
    ("exp", "Exp2f", "exp2f", "exp2f", "DoubleEvalAvx2Fma", "double_eval_avx2_fma", "avx2_fma", None),
    ("exp", "Exp2f", "exp2f", "exp2f", "FloatEval", "float_eval", "float_eval", None),
    ("exp", "Exp2f", "exp2f", "exp2f", "IntegerEval", "integer_eval", "integer_eval", None),
    ("exp", "Exp2f", "exp2f", "exp2f", "StaticRounding", "static_rounding", "static_rounding",
     "math::static_rounding::exp2f"),
    ("exp", "Exp2f", "exp2f", "exp2f", "DoubleEvalAArch64", "double_eval_aarch64", "aarch64", None),
    ("exp", "Exp10f", "exp10f", "exp10f", "DoubleEvalSse2", "double_eval_sse2", "sse2", None),
    ("exp", "Exp10f", "exp10f", "exp10f", "DoubleEvalSse42", "double_eval_sse42", "sse42", None),
    ("exp", "Exp10f", "exp10f", "exp10f", "DoubleEvalAvx2Fma", "double_eval_avx2_fma", "avx2_fma", None),
    ("exp", "Exp10f", "exp10f", "exp10f", "FloatEval", "float_eval", "float_eval", None),
    ("exp", "Exp10f", "exp10f", "exp10f", "IntegerEval", "integer_eval", "integer_eval", None),
    ("exp", "Exp10f", "exp10f", "exp10f", "StaticRounding", "static_rounding", "static_rounding",
     "math::static_rounding::exp10f"),
    ("exp", "Exp10f", "exp10f", "exp10f", "DoubleEvalAArch64", "double_eval_aarch64", "aarch64", None),
    ("exp", "Expm1f", "expm1f", "expm1f", "Sse2", "sse2", "sse2", None),
    ("exp", "Expm1f", "expm1f", "expm1f", "Sse42", "sse42", "sse42", None),
    ("exp", "Expm1f", "expm1f", "expm1f", "Avx2Fma", "avx2_fma", "avx2_fma", None),
    ("exp", "Expm1f", "expm1f", "expm1f", "AArch64", "aarch64", "aarch64", None),
    ("exp", "Exp2m1f", "exp2m1f", "exp2m1f", "Sse2", "sse2", "sse2", None),
    ("exp", "Exp2m1f", "exp2m1f", "exp2m1f", "Sse42", "sse42", "sse42", None),
    ("exp", "Exp2m1f", "exp2m1f", "exp2m1f", "Avx2Fma", "avx2_fma", "avx2_fma", None),
    ("exp", "Exp2m1f", "exp2m1f", "exp2m1f", "AArch64", "aarch64", "aarch64", None),
    ("exp", "Exp10m1f", "exp10m1f", "exp10m1f", "Sse2", "sse2", "sse2", None),
    ("exp", "Exp10m1f", "exp10m1f", "exp10m1f", "Sse42", "sse42", "sse42", None),
    ("exp", "Exp10m1f", "exp10m1f", "exp10m1f", "Avx2Fma", "avx2_fma", "avx2_fma", None),
    ("exp", "Exp10m1f", "exp10m1f", "exp10m1f", "AArch64", "aarch64", "aarch64", None),
    # Logarithmic, root, and power family
    ("logpow", "Logf", "logf", "logf", "DoubleEvalSse2", "double_eval_sse2", "sse2", None),
    ("logpow", "Logf", "logf", "logf", "DoubleEvalAvx2Fma", "double_eval_avx2_fma", "avx2_fma", None),
    ("logpow", "Logf", "logf", "logf", "DoubleEvalSse42", "double_eval_sse42", "sse42", None),
    ("logpow", "Logf", "logf", "logf", "DoubleEvalAArch64", "double_eval_aarch64", "aarch64", None),
    ("logpow", "Log2f", "log2f", "log2f", "DoubleEvalSse2", "double_eval_sse2", "sse2", None),
    ("logpow", "Log2f", "log2f", "log2f", "DoubleEvalAvx2Fma", "double_eval_avx2_fma", "avx2_fma", None),
    ("logpow", "Log2f", "log2f", "log2f", "DoubleEvalSse42", "double_eval_sse42", "sse42", None),
    ("logpow", "Log2f", "log2f", "log2f", "DoubleEvalAArch64", "double_eval_aarch64", "aarch64", None),
    ("logpow", "Log10f", "log10f", "log10f", "DoubleEvalSse2", "double_eval_sse2", "sse2", None),
    ("logpow", "Log10f", "log10f", "log10f", "DoubleEvalAvx2Fma", "double_eval_avx2_fma", "avx2_fma", None),
    ("logpow", "Log10f", "log10f", "log10f", "DoubleEvalSse42", "double_eval_sse42", "sse42", None),
    ("logpow", "Log10f", "log10f", "log10f", "DoubleEvalAArch64", "double_eval_aarch64", "aarch64", None),
    ("logpow", "Log1pf", "log1pf", "log1pf", "DoubleEvalSse2", "double_eval_sse2", "sse2", None),
    ("logpow", "Log1pf", "log1pf", "log1pf", "DoubleEvalAvx2Fma", "double_eval_avx2_fma", "avx2_fma", None),
    ("logpow", "Log1pf", "log1pf", "log1pf", "DoubleEvalSse42", "double_eval_sse42", "sse42", None),
    ("logpow", "Log1pf", "log1pf", "log1pf", "DoubleEvalAArch64", "double_eval_aarch64", "aarch64", None),
    ("logpow", "Cbrtf", "cbrtf", "cbrtf", "Sse2", "sse2", "sse2", None),
    ("logpow", "Cbrtf", "cbrtf", "cbrtf", "Avx2Fma", "avx2_fma", "avx2_fma", None),
    ("logpow", "Cbrtf", "cbrtf", "cbrtf", "Sse42", "sse42", "sse42", None),
    ("logpow", "Cbrtf", "cbrtf", "cbrtf", "AArch64", "aarch64", "aarch64", None),
    ("logpow", "Rsqrtf", "rsqrtf", "rsqrtf", "Sse2", "sse2", "sse2", None),
    ("logpow", "Rsqrtf", "rsqrtf", "rsqrtf", "Avx2Fma", "avx2_fma", "avx2_fma", None),
    ("logpow", "Rsqrtf", "rsqrtf", "rsqrtf", "Sse42", "sse42", "sse42", None),
    ("logpow", "Rsqrtf", "rsqrtf", "rsqrtf", "AArch64", "aarch64", "aarch64", None),
    ("logpow", "Hypotf", "hypotf", "hypotf", "GenericSse2", "generic_sse2", "sse2", None),
    ("logpow", "Hypotf", "hypotf", "hypotf", "Avx2Fma", "avx2_fma", "avx2_fma", None),
    ("logpow", "Hypotf", "hypotf", "hypotf", "Sse42", "sse42", "sse42", None),
    ("logpow", "Hypotf", "hypotf", "hypotf", "AArch64", "aarch64", "aarch64", None),
    ("logpow", "Sqrtf", "sqrtf", "sqrtf", "X86Sse2", "x86_sse2", "sse2", None),
    ("logpow", "Sqrtf", "sqrtf", "sqrtf", "GenericSoftFloat", "generic_softfloat", "softfloat", "fputil::generic::sqrt"),
    ("logpow", "Sqrtf", "sqrtf", "sqrtf", "Sse42", "sse42", "sse42", None),
    ("logpow", "Sqrtf", "sqrtf", "sqrtf", "Avx2Fma", "avx2_fma", "avx2_fma", None),
    ("logpow", "Sqrtf", "sqrtf", "sqrtf", "AArch64", "aarch64", "aarch64", None),
    ("logpow", "Powf", "powf", "powf", "DoubleEvalSse2", "double_eval_sse2", "sse2", None),
    ("logpow", "Powf", "powf", "powf", "DoubleEvalSse42", "double_eval_sse42", "sse42", None),
    ("logpow", "Powf", "powf", "powf", "DoubleEvalAvx2Fma", "double_eval_avx2_fma", "avx2_fma", None),
    ("logpow", "Powf", "powf", "powf", "FloatEval", "float_eval", "float_eval", None),
    ("logpow", "Powf", "powf", "powf", "DoubleEvalAArch64", "double_eval_aarch64", "aarch64", None),
    # Trigonometric and inverse-trigonometric family
    ("trig", "Sinf", "sinf", "sinf", "DoubleEvalSse2", "double_eval_sse2", "sse2", None),
    ("trig", "Sinf", "sinf", "sinf", "DoubleEvalSse42", "double_eval_sse42", "sse42", None),
    ("trig", "Sinf", "sinf", "sinf", "DoubleEvalAvx2Fma", "double_eval_avx2_fma", "avx2_fma", None),
    ("trig", "Sinf", "sinf", "sinf", "FloatEval", "float_eval", "float_eval", None),
    ("trig", "Sinf", "sinf", "sinf", "DoubleEvalAArch64", "double_eval_aarch64", "aarch64", None),
    ("trig", "Cosf", "cosf", "cosf", "DoubleEvalSse2", "double_eval_sse2", "sse2", None),
    ("trig", "Cosf", "cosf", "cosf", "DoubleEvalSse42", "double_eval_sse42", "sse42", None),
    ("trig", "Cosf", "cosf", "cosf", "DoubleEvalAvx2Fma", "double_eval_avx2_fma", "avx2_fma", None),
    ("trig", "Cosf", "cosf", "cosf", "FloatEval", "float_eval", "float_eval", None),
    ("trig", "Cosf", "cosf", "cosf", "DoubleEvalAArch64", "double_eval_aarch64", "aarch64", None),
    ("trig", "Tanf", "tanf", "tanf", "DoubleEvalSse2", "double_eval_sse2", "sse2", None),
    ("trig", "Tanf", "tanf", "tanf", "DoubleEvalSse42", "double_eval_sse42", "sse42", None),
    ("trig", "Tanf", "tanf", "tanf", "DoubleEvalAvx2Fma", "double_eval_avx2_fma", "avx2_fma", None),
    ("trig", "Tanf", "tanf", "tanf", "FloatEval", "float_eval", "float_eval", None),
    ("trig", "Tanf", "tanf", "tanf", "DoubleEvalAArch64", "double_eval_aarch64", "aarch64", None),
    ("trig", "Sincosf", "sincosf", "sincosf", "Sse2", "sse2", "sse2", None),
    ("trig", "Sincosf", "sincosf", "sincosf", "Sse42", "sse42", "sse42", None),
    ("trig", "Sincosf", "sincosf", "sincosf", "Avx2Fma", "avx2_fma", "avx2_fma", None),
    ("trig", "Sincosf", "sincosf", "sincosf", "AArch64", "aarch64", "aarch64", None),
    ("trig", "Sinpif", "sinpif", "sinpif", "Sse2", "sse2", "sse2", None),
    ("trig", "Sinpif", "sinpif", "sinpif", "Sse42", "sse42", "sse42", None),
    ("trig", "Sinpif", "sinpif", "sinpif", "Avx2Fma", "avx2_fma", "avx2_fma", None),
    ("trig", "Sinpif", "sinpif", "sinpif", "AArch64", "aarch64", "aarch64", None),
    ("trig", "Cospif", "cospif", "cospif", "Sse2", "sse2", "sse2", None),
    ("trig", "Cospif", "cospif", "cospif", "Sse42", "sse42", "sse42", None),
    ("trig", "Cospif", "cospif", "cospif", "Avx2Fma", "avx2_fma", "avx2_fma", None),
    ("trig", "Cospif", "cospif", "cospif", "AArch64", "aarch64", "aarch64", None),
    ("trig", "Tanpif", "tanpif", "tanpif", "Sse2", "sse2", "sse2", None),
    ("trig", "Tanpif", "tanpif", "tanpif", "Sse42", "sse42", "sse42", None),
    ("trig", "Tanpif", "tanpif", "tanpif", "Avx2Fma", "avx2_fma", "avx2_fma", None),
    ("trig", "Tanpif", "tanpif", "tanpif", "AArch64", "aarch64", "aarch64", None),
    ("trig", "Asinf", "asinf", "asinf", "Sse2", "sse2", "sse2", None),
    ("trig", "Asinf", "asinf", "asinf", "Avx2Fma", "avx2_fma", "avx2_fma", None),
    ("trig", "Asinf", "asinf", "asinf", "Sse42", "sse42", "sse42", None),
    ("trig", "Asinf", "asinf", "asinf", "AArch64", "aarch64", "aarch64", None),
    ("trig", "Acosf", "acosf", "acosf", "Sse2", "sse2", "sse2", None),
    ("trig", "Acosf", "acosf", "acosf", "Avx2Fma", "avx2_fma", "avx2_fma", None),
    ("trig", "Acosf", "acosf", "acosf", "Sse42", "sse42", "sse42", None),
    ("trig", "Acosf", "acosf", "acosf", "AArch64", "aarch64", "aarch64", None),
    ("trig", "Atanf", "atanf", "atanf", "DoubleEvalSse2", "double_eval_sse2", "sse2", None),
    ("trig", "Atanf", "atanf", "atanf", "DoubleEvalAvx2Fma", "double_eval_avx2_fma", "avx2_fma", None),
    ("trig", "Atanf", "atanf", "atanf", "FloatEval", "float_eval", "float_eval", None),
    ("trig", "Atanf", "atanf", "atanf", "DoubleEvalSse42", "double_eval_sse42", "sse42", None),
    ("trig", "Atanf", "atanf", "atanf", "DoubleEvalAArch64", "double_eval_aarch64", "aarch64", None),
    ("trig", "Atan2f", "atan2f", "atan2f", "DoubleEvalSse2", "double_eval_sse2", "sse2", None),
    ("trig", "Atan2f", "atan2f", "atan2f", "DoubleEvalAvx2Fma", "double_eval_avx2_fma", "avx2_fma", None),
    ("trig", "Atan2f", "atan2f", "atan2f", "FloatEval", "float_eval", "float_eval", None),
    ("trig", "Atan2f", "atan2f", "atan2f", "DoubleEvalSse42", "double_eval_sse42", "sse42", None),
    ("trig", "Atan2f", "atan2f", "atan2f", "DoubleEvalAArch64", "double_eval_aarch64", "aarch64", None),
    ("trig", "Asinpif", "asinpif", "asinpif", "Sse2", "sse2", "sse2", None),
    ("trig", "Asinpif", "asinpif", "asinpif", "Avx2Fma", "avx2_fma", "avx2_fma", None),
    ("trig", "Asinpif", "asinpif", "asinpif", "Sse42", "sse42", "sse42", None),
    ("trig", "Asinpif", "asinpif", "asinpif", "AArch64", "aarch64", "aarch64", None),
    ("trig", "Acospif", "acospif", "acospif", "Sse2", "sse2", "sse2", None),
    ("trig", "Acospif", "acospif", "acospif", "Avx2Fma", "avx2_fma", "avx2_fma", None),
    ("trig", "Acospif", "acospif", "acospif", "Sse42", "sse42", "sse42", None),
    ("trig", "Acospif", "acospif", "acospif", "AArch64", "aarch64", "aarch64", None),
    # Hyperbolic, inverse-hyperbolic, and special family
    ("hypspec", "Sinhf", "sinhf", "sinhf", "Sse2", "sse2", "sse2", None),
    ("hypspec", "Sinhf", "sinhf", "sinhf", "Sse42", "sse42", "sse42", None),
    ("hypspec", "Sinhf", "sinhf", "sinhf", "Avx2Fma", "avx2_fma", "avx2_fma", None),
    ("hypspec", "Sinhf", "sinhf", "sinhf", "AArch64", "aarch64", "aarch64", None),
    ("hypspec", "Coshf", "coshf", "coshf", "Sse2", "sse2", "sse2", None),
    ("hypspec", "Coshf", "coshf", "coshf", "Sse42", "sse42", "sse42", None),
    ("hypspec", "Coshf", "coshf", "coshf", "Avx2Fma", "avx2_fma", "avx2_fma", None),
    ("hypspec", "Coshf", "coshf", "coshf", "AArch64", "aarch64", "aarch64", None),
    ("hypspec", "Tanhf", "tanhf", "tanhf", "Sse2", "sse2", "sse2", None),
    ("hypspec", "Tanhf", "tanhf", "tanhf", "Sse42", "sse42", "sse42", None),
    ("hypspec", "Tanhf", "tanhf", "tanhf", "Avx2Fma", "avx2_fma", "avx2_fma", None),
    ("hypspec", "Tanhf", "tanhf", "tanhf", "AArch64", "aarch64", "aarch64", None),
    ("hypspec", "Asinhf", "asinhf", "asinhf", "Sse2", "sse2", "sse2", None),
    ("hypspec", "Asinhf", "asinhf", "asinhf", "Avx2Fma", "avx2_fma", "avx2_fma", None),
    ("hypspec", "Asinhf", "asinhf", "asinhf", "Sse42", "sse42", "sse42", None),
    ("hypspec", "Asinhf", "asinhf", "asinhf", "AArch64", "aarch64", "aarch64", None),
    ("hypspec", "Acoshf", "acoshf", "acoshf", "Sse2", "sse2", "sse2", None),
    ("hypspec", "Acoshf", "acoshf", "acoshf", "Avx2Fma", "avx2_fma", "avx2_fma", None),
    ("hypspec", "Acoshf", "acoshf", "acoshf", "Sse42", "sse42", "sse42", None),
    ("hypspec", "Acoshf", "acoshf", "acoshf", "AArch64", "aarch64", "aarch64", None),
    ("hypspec", "Atanhf", "atanhf", "atanhf", "Sse2", "sse2", "sse2", None),
    ("hypspec", "Atanhf", "atanhf", "atanhf", "Avx2Fma", "avx2_fma", "avx2_fma", None),
    ("hypspec", "Atanhf", "atanhf", "atanhf", "Sse42", "sse42", "sse42", None),
    ("hypspec", "Atanhf", "atanhf", "atanhf", "AArch64", "aarch64", "aarch64", None),
    ("hypspec", "Erff", "erff", "erff", "Sse2", "sse2", "sse2", None),
    ("hypspec", "Erff", "erff", "erff", "Avx2Fma", "avx2_fma", "avx2_fma", None),
    ("hypspec", "Erff", "erff", "erff", "Sse42", "sse42", "sse42", None),
    ("hypspec", "Erff", "erff", "erff", "AArch64", "aarch64", "aarch64", None),
    ("hypspec", "Lgammaf", "lgammaf", "lgammaf", "Sse2", "sse2", "sse2", None),
    ("hypspec", "Lgammaf", "lgammaf", "lgammaf", "Avx2Fma", "avx2_fma", "avx2_fma", None),
    ("hypspec", "Lgammaf", "lgammaf", "lgammaf", "Sse42", "sse42", "sse42", None),
    ("hypspec", "Lgammaf", "lgammaf", "lgammaf", "AArch64", "aarch64", "aarch64", None),
    # Basic, rounding, and extrema family
    ("basic", "Fmaf", "fmaf", "fmaf", "GenericSse2", "generic_sse2", "sse2", "fputil::generic::fma"),
    ("basic", "Fmaf", "fmaf", "fmaf", "Avx2Fma", "avx2_fma", "avx2_fma", None),
    ("basic", "Fmaf", "fmaf", "fmaf", "Sse42", "sse42", "sse42", None),
    ("basic", "Fmaf", "fmaf", "fmaf", "AArch64", "aarch64", "aarch64", None),
    ("basic", "Fabsf", "fabsf", "fabsf", "GenericSse2", "generic_sse2", "sse2", None),
    ("basic", "Fabsf", "fabsf", "fabsf", "Sse42", "sse42", "sse42", None),
    ("basic", "Fabsf", "fabsf", "fabsf", "Avx2Fma", "avx2_fma", "avx2_fma", None),
    ("basic", "Fabsf", "fabsf", "fabsf", "AArch64", "aarch64", "aarch64", None),
    ("basic", "Copysignf", "copysignf", "copysignf", "GenericSse2", "generic_sse2", "sse2", None),
    ("basic", "Copysignf", "copysignf", "copysignf", "Sse42", "sse42", "sse42", None),
    ("basic", "Copysignf", "copysignf", "copysignf", "Avx2Fma", "avx2_fma", "avx2_fma", None),
    ("basic", "Copysignf", "copysignf", "copysignf", "AArch64", "aarch64", "aarch64", None),
    ("basic", "Fdimf", "fdimf", "fdimf", "GenericSse2", "generic_sse2", "sse2", None),
    ("basic", "Fdimf", "fdimf", "fdimf", "Sse42", "sse42", "sse42", None),
    ("basic", "Fdimf", "fdimf", "fdimf", "Avx2Fma", "avx2_fma", "avx2_fma", None),
    ("basic", "Fdimf", "fdimf", "fdimf", "AArch64", "aarch64", "aarch64", None),
    ("basic", "Floorf", "floorf", "floorf", "GenericSse2", "generic_sse2", "sse2", "fputil::floor"),
    ("basic", "Floorf", "floorf", "floorf", "BuiltinSse42", "builtin_sse42", "sse42", None),
    ("basic", "Floorf", "floorf", "floorf", "Avx2Fma", "avx2_fma", "avx2_fma", None),
    ("basic", "Floorf", "floorf", "floorf", "AArch64", "aarch64", "aarch64", None),
    ("basic", "Ceilf", "ceilf", "ceilf", "GenericSse2", "generic_sse2", "sse2", "fputil::ceil"),
    ("basic", "Ceilf", "ceilf", "ceilf", "BuiltinSse42", "builtin_sse42", "sse42", None),
    ("basic", "Ceilf", "ceilf", "ceilf", "Avx2Fma", "avx2_fma", "avx2_fma", None),
    ("basic", "Ceilf", "ceilf", "ceilf", "AArch64", "aarch64", "aarch64", None),
    ("basic", "Truncf", "truncf", "truncf", "GenericSse2", "generic_sse2", "sse2", "fputil::trunc"),
    ("basic", "Truncf", "truncf", "truncf", "BuiltinSse42", "builtin_sse42", "sse42", None),
    ("basic", "Truncf", "truncf", "truncf", "Avx2Fma", "avx2_fma", "avx2_fma", None),
    ("basic", "Truncf", "truncf", "truncf", "AArch64", "aarch64", "aarch64", None),
    ("basic", "Roundevenf", "roundevenf", "roundevenf", "GenericSse2", "generic_sse2", "sse2", None),
    ("basic", "Roundevenf", "roundevenf", "roundevenf", "BuiltinSse42", "builtin_sse42", "sse42", None),
    ("basic", "Roundevenf", "roundevenf", "roundevenf", "Avx2Fma", "avx2_fma", "avx2_fma", None),
    ("basic", "Roundevenf", "roundevenf", "roundevenf", "AArch64", "aarch64", "aarch64", None),
    ("basic", "Rintf", "rintf", "rintf", "GenericSse2", "generic_sse2", "sse2", "fputil::round_using_current_rounding_mode"),
    ("basic", "Rintf", "rintf", "rintf", "BuiltinSse42", "builtin_sse42", "sse42", None),
    ("basic", "Rintf", "rintf", "rintf", "Avx2Fma", "avx2_fma", "avx2_fma", None),
    ("basic", "Rintf", "rintf", "rintf", "AArch64", "aarch64", "aarch64", None),
    ("basic", "Nearbyintf", "nearbyintf", "nearbyintf", "GenericSse2", "generic_sse2", "sse2", "fputil::round_using_current_rounding_mode"),
    ("basic", "Nearbyintf", "nearbyintf", "nearbyintf", "BuiltinSse42", "builtin_sse42", "sse42", None),
    ("basic", "Nearbyintf", "nearbyintf", "nearbyintf", "Avx2Fma", "avx2_fma", "avx2_fma", None),
    ("basic", "Nearbyintf", "nearbyintf", "nearbyintf", "AArch64", "aarch64", "aarch64", None),
    ("basic", "Roundf", "roundf", "roundf", "GenericSse2", "generic_sse2", "sse2", "fputil::round"),
    ("basic", "Roundf", "roundf", "roundf", "AArch64", "aarch64", "aarch64", None),
    ("basic", "Roundf", "roundf", "roundf", "Sse42", "sse42", "sse42", None),
    ("basic", "Roundf", "roundf", "roundf", "Avx2Fma", "avx2_fma", "avx2_fma", None),
    ("basic", "Fmaxf", "fmaxf", "fmaxf", "GenericSse2", "generic_sse2", "sse2", "fputil::fmax"),
    ("basic", "Fmaxf", "fmaxf", "fmaxf", "Sse42", "sse42", "sse42", None),
    ("basic", "Fmaxf", "fmaxf", "fmaxf", "Avx2Fma", "avx2_fma", "avx2_fma", None),
    ("basic", "Fmaxf", "fmaxf", "fmaxf", "AArch64", "aarch64", "aarch64", None),
    ("basic", "Fminf", "fminf", "fminf", "GenericSse2", "generic_sse2", "sse2", "fputil::fmin"),
    ("basic", "Fminf", "fminf", "fminf", "Sse42", "sse42", "sse42", None),
    ("basic", "Fminf", "fminf", "fminf", "Avx2Fma", "avx2_fma", "avx2_fma", None),
    ("basic", "Fminf", "fminf", "fminf", "AArch64", "aarch64", "aarch64", None),
    ("basic", "Fmaximumf", "fmaximumf", "fmaximumf", "GenericSse2", "generic_sse2", "sse2", "fputil::fmaximum"),
    ("basic", "Fmaximumf", "fmaximumf", "fmaximumf", "Sse42", "sse42", "sse42", None),
    ("basic", "Fmaximumf", "fmaximumf", "fmaximumf", "Avx2Fma", "avx2_fma", "avx2_fma", None),
    ("basic", "Fmaximumf", "fmaximumf", "fmaximumf", "AArch64", "aarch64", "aarch64", None),
    ("basic", "Fminimumf", "fminimumf", "fminimumf", "GenericSse2", "generic_sse2", "sse2", "fputil::fminimum"),
    ("basic", "Fminimumf", "fminimumf", "fminimumf", "Sse42", "sse42", "sse42", None),
    ("basic", "Fminimumf", "fminimumf", "fminimumf", "Avx2Fma", "avx2_fma", "avx2_fma", None),
    ("basic", "Fminimumf", "fminimumf", "fminimumf", "AArch64", "aarch64", "aarch64", None),
    ("basic", "FmaximumNumf", "fmaximum_numf", "fmaximum_numf", "GenericSse2", "generic_sse2", "sse2", "fputil::fmaximum_num"),
    ("basic", "FmaximumNumf", "fmaximum_numf", "fmaximum_numf", "Sse42", "sse42", "sse42", None),
    ("basic", "FmaximumNumf", "fmaximum_numf", "fmaximum_numf", "Avx2Fma", "avx2_fma", "avx2_fma", None),
    ("basic", "FmaximumNumf", "fmaximum_numf", "fmaximum_numf", "AArch64", "aarch64", "aarch64", None),
    ("basic", "FminimumNumf", "fminimum_numf", "fminimum_numf", "GenericSse2", "generic_sse2", "sse2", "fputil::fminimum_num"),
    ("basic", "FminimumNumf", "fminimum_numf", "fminimum_numf", "Sse42", "sse42", "sse42", None),
    ("basic", "FminimumNumf", "fminimum_numf", "fminimum_numf", "Avx2Fma", "avx2_fma", "avx2_fma", None),
    ("basic", "FminimumNumf", "fminimum_numf", "fminimum_numf", "AArch64", "aarch64", "aarch64", None),
    ("basic", "FmaximumMagf", "fmaximum_magf", "fmaximum_magf", "GenericSse2", "generic_sse2", "sse2", "fputil::fmaximum_mag"),
    ("basic", "FmaximumMagf", "fmaximum_magf", "fmaximum_magf", "Sse42", "sse42", "sse42", None),
    ("basic", "FmaximumMagf", "fmaximum_magf", "fmaximum_magf", "Avx2Fma", "avx2_fma", "avx2_fma", None),
    ("basic", "FmaximumMagf", "fmaximum_magf", "fmaximum_magf", "AArch64", "aarch64", "aarch64", None),
    ("basic", "FminimumMagf", "fminimum_magf", "fminimum_magf", "GenericSse2", "generic_sse2", "sse2", "fputil::fminimum_mag"),
    ("basic", "FminimumMagf", "fminimum_magf", "fminimum_magf", "Sse42", "sse42", "sse42", None),
    ("basic", "FminimumMagf", "fminimum_magf", "fminimum_magf", "Avx2Fma", "avx2_fma", "avx2_fma", None),
    ("basic", "FminimumMagf", "fminimum_magf", "fminimum_magf", "AArch64", "aarch64", "aarch64", None),
    ("basic", "FmaximumMagNumf", "fmaximum_mag_numf", "fmaximum_mag_numf", "GenericSse2", "generic_sse2", "sse2", "fputil::fmaximum_mag_num"),
    ("basic", "FmaximumMagNumf", "fmaximum_mag_numf", "fmaximum_mag_numf", "Sse42", "sse42", "sse42", None),
    ("basic", "FmaximumMagNumf", "fmaximum_mag_numf", "fmaximum_mag_numf", "Avx2Fma", "avx2_fma", "avx2_fma", None),
    ("basic", "FmaximumMagNumf", "fmaximum_mag_numf", "fmaximum_mag_numf", "AArch64", "aarch64", "aarch64", None),
    ("basic", "FminimumMagNumf", "fminimum_mag_numf", "fminimum_mag_numf", "GenericSse2", "generic_sse2", "sse2", "fputil::fminimum_mag_num"),
    ("basic", "FminimumMagNumf", "fminimum_mag_numf", "fminimum_mag_numf", "Sse42", "sse42", "sse42", None),
    ("basic", "FminimumMagNumf", "fminimum_mag_numf", "fminimum_mag_numf", "Avx2Fma", "avx2_fma", "avx2_fma", None),
    ("basic", "FminimumMagNumf", "fminimum_mag_numf", "fminimum_mag_numf", "AArch64", "aarch64", "aarch64", None),
    # IEEE manipulation, remainder, and conversion family
    ("ieee", "Nextupf", "nextupf", "nextupf", "GenericSse2", "generic_sse2", "sse2", None),
    ("ieee", "Nextupf", "nextupf", "nextupf", "Sse42", "sse42", "sse42", None),
    ("ieee", "Nextupf", "nextupf", "nextupf", "Avx2Fma", "avx2_fma", "avx2_fma", None),
    ("ieee", "Nextupf", "nextupf", "nextupf", "AArch64", "aarch64", "aarch64", None),
    ("ieee", "Nextdownf", "nextdownf", "nextdownf", "GenericSse2", "generic_sse2", "sse2", None),
    ("ieee", "Nextdownf", "nextdownf", "nextdownf", "Sse42", "sse42", "sse42", None),
    ("ieee", "Nextdownf", "nextdownf", "nextdownf", "Avx2Fma", "avx2_fma", "avx2_fma", None),
    ("ieee", "Nextdownf", "nextdownf", "nextdownf", "AArch64", "aarch64", "aarch64", None),
    ("ieee", "Nextafterf", "nextafterf", "nextafterf", "GenericSse2", "generic_sse2", "sse2", None),
    ("ieee", "Nextafterf", "nextafterf", "nextafterf", "Sse42", "sse42", "sse42", None),
    ("ieee", "Nextafterf", "nextafterf", "nextafterf", "Avx2Fma", "avx2_fma", "avx2_fma", None),
    ("ieee", "Nextafterf", "nextafterf", "nextafterf", "AArch64", "aarch64", "aarch64", None),
    ("ieee", "Ldexpf", "ldexpf", "ldexpf", "GenericSse2", "generic_sse2", "sse2", None),
    ("ieee", "Ldexpf", "ldexpf", "ldexpf", "Sse42", "sse42", "sse42", None),
    ("ieee", "Ldexpf", "ldexpf", "ldexpf", "Avx2Fma", "avx2_fma", "avx2_fma", None),
    ("ieee", "Ldexpf", "ldexpf", "ldexpf", "AArch64", "aarch64", "aarch64", None),
    ("ieee", "Scalbnf", "scalbnf", "scalbnf", "GenericSse2", "generic_sse2", "sse2", None),
    ("ieee", "Scalbnf", "scalbnf", "scalbnf", "Sse42", "sse42", "sse42", None),
    ("ieee", "Scalbnf", "scalbnf", "scalbnf", "Avx2Fma", "avx2_fma", "avx2_fma", None),
    ("ieee", "Scalbnf", "scalbnf", "scalbnf", "AArch64", "aarch64", "aarch64", None),
    ("ieee", "Scalblnf", "scalblnf", "scalblnf", "GenericSse2", "generic_sse2", "sse2", None),
    ("ieee", "Scalblnf", "scalblnf", "scalblnf", "Sse42", "sse42", "sse42", None),
    ("ieee", "Scalblnf", "scalblnf", "scalblnf", "Avx2Fma", "avx2_fma", "avx2_fma", None),
    ("ieee", "Scalblnf", "scalblnf", "scalblnf", "AArch64", "aarch64", "aarch64", None),
    ("ieee", "Logbf", "logbf", "logbf", "GenericSse2", "generic_sse2", "sse2", None),
    ("ieee", "Logbf", "logbf", "logbf", "Sse42", "sse42", "sse42", None),
    ("ieee", "Logbf", "logbf", "logbf", "Avx2Fma", "avx2_fma", "avx2_fma", None),
    ("ieee", "Logbf", "logbf", "logbf", "AArch64", "aarch64", "aarch64", None),
    ("ieee", "Ilogbf", "ilogbf", "ilogbf", "GenericSse2", "generic_sse2", "sse2", None),
    ("ieee", "Ilogbf", "ilogbf", "ilogbf", "Sse42", "sse42", "sse42", None),
    ("ieee", "Ilogbf", "ilogbf", "ilogbf", "Avx2Fma", "avx2_fma", "avx2_fma", None),
    ("ieee", "Ilogbf", "ilogbf", "ilogbf", "AArch64", "aarch64", "aarch64", None),
    ("ieee", "Llogbf", "llogbf", "llogbf", "GenericSse2", "generic_sse2", "sse2", None),
    ("ieee", "Llogbf", "llogbf", "llogbf", "Sse42", "sse42", "sse42", None),
    ("ieee", "Llogbf", "llogbf", "llogbf", "Avx2Fma", "avx2_fma", "avx2_fma", None),
    ("ieee", "Llogbf", "llogbf", "llogbf", "AArch64", "aarch64", "aarch64", None),
    ("ieee", "Frexpf", "frexpf", "frexpf", "GenericSse2", "generic_sse2", "sse2", None),
    ("ieee", "Frexpf", "frexpf", "frexpf", "Sse42", "sse42", "sse42", None),
    ("ieee", "Frexpf", "frexpf", "frexpf", "Avx2Fma", "avx2_fma", "avx2_fma", None),
    ("ieee", "Frexpf", "frexpf", "frexpf", "AArch64", "aarch64", "aarch64", None),
    ("ieee", "Modff", "modff", "modff", "GenericSse2", "generic_sse2", "sse2", None),
    ("ieee", "Modff", "modff", "modff", "Sse42", "sse42", "sse42", None),
    ("ieee", "Modff", "modff", "modff", "Avx2Fma", "avx2_fma", "avx2_fma", None),
    ("ieee", "Modff", "modff", "modff", "AArch64", "aarch64", "aarch64", None),
    ("ieee", "Fmodf", "fmodf", "fmodf", "GenericSse2", "generic_sse2", "sse2", None),
    ("ieee", "Fmodf", "fmodf", "fmodf", "Sse42", "sse42", "sse42", None),
    ("ieee", "Fmodf", "fmodf", "fmodf", "Avx2Fma", "avx2_fma", "avx2_fma", None),
    ("ieee", "Fmodf", "fmodf", "fmodf", "AArch64", "aarch64", "aarch64", None),
    ("ieee", "Remainderf", "remainderf", "remainderf", "GenericSse2", "generic_sse2", "sse2", None),
    ("ieee", "Remainderf", "remainderf", "remainderf", "Sse42", "sse42", "sse42", None),
    ("ieee", "Remainderf", "remainderf", "remainderf", "Avx2Fma", "avx2_fma", "avx2_fma", None),
    ("ieee", "Remainderf", "remainderf", "remainderf", "AArch64", "aarch64", "aarch64", None),
    ("ieee", "Remquof", "remquof", "remquof", "GenericSse2", "generic_sse2", "sse2", None),
    ("ieee", "Remquof", "remquof", "remquof", "Sse42", "sse42", "sse42", None),
    ("ieee", "Remquof", "remquof", "remquof", "Avx2Fma", "avx2_fma", "avx2_fma", None),
    ("ieee", "Remquof", "remquof", "remquof", "AArch64", "aarch64", "aarch64", None),
    ("ieee", "Getpayloadf", "getpayloadf", "getpayloadf", "GenericSse2", "generic_sse2", "sse2", None),
    ("ieee", "Getpayloadf", "getpayloadf", "getpayloadf", "Sse42", "sse42", "sse42", None),
    ("ieee", "Getpayloadf", "getpayloadf", "getpayloadf", "Avx2Fma", "avx2_fma", "avx2_fma", None),
    ("ieee", "Getpayloadf", "getpayloadf", "getpayloadf", "AArch64", "aarch64", "aarch64", None),
    ("ieee", "Setpayloadf", "setpayloadf", "setpayloadf", "GenericSse2", "generic_sse2", "sse2", None),
    ("ieee", "Setpayloadf", "setpayloadf", "setpayloadf", "Sse42", "sse42", "sse42", None),
    ("ieee", "Setpayloadf", "setpayloadf", "setpayloadf", "Avx2Fma", "avx2_fma", "avx2_fma", None),
    ("ieee", "Setpayloadf", "setpayloadf", "setpayloadf", "AArch64", "aarch64", "aarch64", None),
    ("ieee", "Setpayloadsigf", "setpayloadsigf", "setpayloadsigf", "GenericSse2", "generic_sse2", "sse2", None),
    ("ieee", "Setpayloadsigf", "setpayloadsigf", "setpayloadsigf", "Sse42", "sse42", "sse42", None),
    ("ieee", "Setpayloadsigf", "setpayloadsigf", "setpayloadsigf", "Avx2Fma", "avx2_fma", "avx2_fma", None),
    ("ieee", "Setpayloadsigf", "setpayloadsigf", "setpayloadsigf", "AArch64", "aarch64", "aarch64", None),
    ("ieee", "Totalorderf", "totalorderf", "totalorderf", "GenericSse2", "generic_sse2", "sse2", None),
    ("ieee", "Totalorderf", "totalorderf", "totalorderf", "Sse42", "sse42", "sse42", None),
    ("ieee", "Totalorderf", "totalorderf", "totalorderf", "Avx2Fma", "avx2_fma", "avx2_fma", None),
    ("ieee", "Totalorderf", "totalorderf", "totalorderf", "AArch64", "aarch64", "aarch64", None),
    ("ieee", "Totalordermagf", "totalordermagf", "totalordermagf", "GenericSse2", "generic_sse2", "sse2", None),
    ("ieee", "Totalordermagf", "totalordermagf", "totalordermagf", "Sse42", "sse42", "sse42", None),
    ("ieee", "Totalordermagf", "totalordermagf", "totalordermagf", "Avx2Fma", "avx2_fma", "avx2_fma", None),
    ("ieee", "Totalordermagf", "totalordermagf", "totalordermagf", "AArch64", "aarch64", "aarch64", None),
    ("ieee", "Canonicalizef", "canonicalizef", "canonicalizef", "GenericSse2", "generic_sse2", "sse2", None),
    ("ieee", "Canonicalizef", "canonicalizef", "canonicalizef", "Sse42", "sse42", "sse42", None),
    ("ieee", "Canonicalizef", "canonicalizef", "canonicalizef", "Avx2Fma", "avx2_fma", "avx2_fma", None),
    ("ieee", "Canonicalizef", "canonicalizef", "canonicalizef", "AArch64", "aarch64", "aarch64", None),
    ("ieee", "Iscanonicalf", "iscanonicalf", "iscanonicalf", "GenericSse2", "generic_sse2", "sse2", None),
    ("ieee", "Iscanonicalf", "iscanonicalf", "iscanonicalf", "Sse42", "sse42", "sse42", None),
    ("ieee", "Iscanonicalf", "iscanonicalf", "iscanonicalf", "Avx2Fma", "avx2_fma", "avx2_fma", None),
    ("ieee", "Iscanonicalf", "iscanonicalf", "iscanonicalf", "AArch64", "aarch64", "aarch64", None),
    ("ieee", "Isnanf", "isnanf", "isnanf", "GenericSse2", "generic_sse2", "sse2", None),
    ("ieee", "Isnanf", "isnanf", "isnanf", "Sse42", "sse42", "sse42", None),
    ("ieee", "Isnanf", "isnanf", "isnanf", "Avx2Fma", "avx2_fma", "avx2_fma", None),
    ("ieee", "Isnanf", "isnanf", "isnanf", "AArch64", "aarch64", "aarch64", None),
    ("ieee", "Issignalingf", "issignalingf", "issignalingf", "GenericSse2", "generic_sse2", "sse2", None),
    ("ieee", "Issignalingf", "issignalingf", "issignalingf", "Sse42", "sse42", "sse42", None),
    ("ieee", "Issignalingf", "issignalingf", "issignalingf", "Avx2Fma", "avx2_fma", "avx2_fma", None),
    ("ieee", "Issignalingf", "issignalingf", "issignalingf", "AArch64", "aarch64", "aarch64", None),
    ("ieee", "Lrintf", "lrintf", "lrintf", "GenericSse2", "generic_sse2", "sse2", None),
    ("ieee", "Lrintf", "lrintf", "lrintf", "Sse42", "sse42", "sse42", None),
    ("ieee", "Lrintf", "lrintf", "lrintf", "Avx2Fma", "avx2_fma", "avx2_fma", None),
    ("ieee", "Lrintf", "lrintf", "lrintf", "AArch64", "aarch64", "aarch64", None),
    ("ieee", "Llrintf", "llrintf", "llrintf", "GenericSse2", "generic_sse2", "sse2", None),
    ("ieee", "Llrintf", "llrintf", "llrintf", "Sse42", "sse42", "sse42", None),
    ("ieee", "Llrintf", "llrintf", "llrintf", "Avx2Fma", "avx2_fma", "avx2_fma", None),
    ("ieee", "Llrintf", "llrintf", "llrintf", "AArch64", "aarch64", "aarch64", None),
    ("ieee", "Lroundf", "lroundf", "lroundf", "GenericSse2", "generic_sse2", "sse2", None),
    ("ieee", "Lroundf", "lroundf", "lroundf", "Sse42", "sse42", "sse42", None),
    ("ieee", "Lroundf", "lroundf", "lroundf", "Avx2Fma", "avx2_fma", "avx2_fma", None),
    ("ieee", "Lroundf", "lroundf", "lroundf", "AArch64", "aarch64", "aarch64", None),
    ("ieee", "Llroundf", "llroundf", "llroundf", "GenericSse2", "generic_sse2", "sse2", None),
    ("ieee", "Llroundf", "llroundf", "llroundf", "Sse42", "sse42", "sse42", None),
    ("ieee", "Llroundf", "llroundf", "llroundf", "Avx2Fma", "avx2_fma", "avx2_fma", None),
    ("ieee", "Llroundf", "llroundf", "llroundf", "AArch64", "aarch64", "aarch64", None),
    ("ieee", "Fromfpf", "fromfpf", "fromfpf", "GenericSse2", "generic_sse2", "sse2", None),
    ("ieee", "Fromfpf", "fromfpf", "fromfpf", "Sse42", "sse42", "sse42", None),
    ("ieee", "Fromfpf", "fromfpf", "fromfpf", "Avx2Fma", "avx2_fma", "avx2_fma", None),
    ("ieee", "Fromfpf", "fromfpf", "fromfpf", "AArch64", "aarch64", "aarch64", None),
    ("ieee", "Fromfpxf", "fromfpxf", "fromfpxf", "GenericSse2", "generic_sse2", "sse2", None),
    ("ieee", "Fromfpxf", "fromfpxf", "fromfpxf", "Sse42", "sse42", "sse42", None),
    ("ieee", "Fromfpxf", "fromfpxf", "fromfpxf", "Avx2Fma", "avx2_fma", "avx2_fma", None),
    ("ieee", "Fromfpxf", "fromfpxf", "fromfpxf", "AArch64", "aarch64", "aarch64", None),
    ("ieee", "Ufromfpf", "ufromfpf", "ufromfpf", "GenericSse2", "generic_sse2", "sse2", None),
    ("ieee", "Ufromfpf", "ufromfpf", "ufromfpf", "Sse42", "sse42", "sse42", None),
    ("ieee", "Ufromfpf", "ufromfpf", "ufromfpf", "Avx2Fma", "avx2_fma", "avx2_fma", None),
    ("ieee", "Ufromfpf", "ufromfpf", "ufromfpf", "AArch64", "aarch64", "aarch64", None),
    ("ieee", "Ufromfpxf", "ufromfpxf", "ufromfpxf", "GenericSse2", "generic_sse2", "sse2", None),
    ("ieee", "Ufromfpxf", "ufromfpxf", "ufromfpxf", "Sse42", "sse42", "sse42", None),
    ("ieee", "Ufromfpxf", "ufromfpxf", "ufromfpxf", "Avx2Fma", "avx2_fma", "avx2_fma", None),
    ("ieee", "Ufromfpxf", "ufromfpxf", "ufromfpxf", "AArch64", "aarch64", "aarch64", None),
]


# Flag kinds that compile for another target with `-nostdinc` and the headers of Clang only.
CROSS_KINDS = {"aarch64", "riscv64", "softfloat"}


def flags_for(kind: str, cpp_file: str, rdir: str) -> list[str]:
    upper = cpp_file.upper()
    if kind == "sse2":
        return ["-mno-sse4.2", "-mno-fma"]
    if kind == "ssse3":
        return ["-mssse3", "-mno-sse4.2", "-mno-fma"]
    if kind == "sse42":
        return ["-msse4.2", "-mno-fma"]
    if kind == "avx2_fma":
        return ["-mavx2", "-mfma"]
    if kind == "float_eval":
        return ["-mavx2", "-mfma", f"-DLIBC_MATH_{upper}_IMPL=float_eval", "-DLIBC_MATH=0x3F"]
    if kind == "integer_eval":
        return ["-mno-sse4.2", "-mno-fma", f"-DLIBC_MATH_{upper}_IMPL=integer_eval", "-DLIBC_MATH=0x2C"]
    if kind == "static_rounding":
        return ["-mno-sse4.2", "-mno-fma", f"-DLIBC_MATH_{upper}_IMPL=integer_eval", "-DLIBC_MATH=0x0C"]
    if kind == "aarch64":
        return ["--target=aarch64-none-elf", "-ffreestanding", "-nostdinc", "-isystem", f"{rdir}/include"]
    if kind == "riscv64":
        return ["--target=riscv64-none-elf", "-march=rv64gc", "-ffreestanding", "-nostdinc", "-isystem", f"{rdir}/include"]
    if kind == "softfloat":
        return ["--target=riscv32-none-elf", "-march=rv32i", "-ffreestanding", "-nostdinc", "-isystem", f"{rdir}/include"]
    raise ValueError(f"unknown flags kind: {kind}")


def host_include_flags() -> list[str]:
    """Return the system include directories of the C++ compiler as `-isystem` flags.

    `ast2lean` uses the resource directory of Clang but not the C library headers that the
    compiler wrapper adds, and some LLVM libc headers include them (`sys/syscall.h`).
    """
    cxx = os.environ.get("AST2LEAN_CXX", "clang++")
    res = subprocess.run([cxx, "-x", "c++", "-E", "-v", "-"], input="", capture_output=True,
                         text=True, check=True)
    lines = res.stderr.splitlines()
    start = lines.index("#include <...> search starts here:") + 1
    end = lines.index("End of search list.")
    dirs = [d.strip() for d in lines[start:end] if "resource-root" not in d]
    return [f for d in dirs for f in ("-isystem", d)]


def run_one(
    libc: Path,
    rdir: str,
    host_includes: list[str],
    entry: tuple[str, str, str, str, str, str, str, str | None],
) -> str:
    _, kdir, cpp_file, lean_fn, plan_mod, variant, fkind, target_override = entry
    src = libc / "src" / "math" / "generic" / f"{cpp_file}.cpp"
    out_dir = ROOT / "LibcMath" / "Kernels" / kdir / "Generated"
    out_dir.mkdir(parents=True, exist_ok=True)
    out = out_dir / f"{plan_mod}.lean"
    ns = f"LibcMath.Kernels.{kdir}.Generated.{plan_mod}"
    target = target_override or f"__llvm_libc::{cpp_file}"
    extra = flags_for(fkind, cpp_file, rdir)
    if fkind not in CROSS_KINDS:
        extra += host_includes
    cmd = [
        str(BIN),
        str(src),
        f"--function={target}",
        f"--name={lean_fn}",
        f"--namespace={ns}",
        f"--source-label=src/math/generic/{cpp_file}.cpp",
        f"--source-commit={COMMIT}",
        f"--variant={variant}",
        "--follow-helpers",
        "--drop-effects",
        "--strict",
        "-o",
        str(out),
        "--",
        f"-I{libc}",
        "-std=gnu++17",
        "-DLIBC_NAMESPACE=__llvm_libc",
        "-DLIBC_FULL_BUILD",
        "-DNDEBUG",
        *extra,
    ]
    res = subprocess.run(cmd, capture_output=True, text=True)
    if res.returncode != 0:
        raise RuntimeError(f"Failed {kdir}.{plan_mod}: {res.stderr.strip()}")
    return f"{kdir}.{plan_mod}"


def main() -> int:
    if len(sys.argv) < 2:
        print("usage: extract_f32_plans.py <llvm-project>/libc [family|all]", file=sys.stderr)
        return 2
    libc = Path(sys.argv[1]).resolve()
    fam = sys.argv[2] if len(sys.argv) >= 3 else "all"
    rdir = subprocess.check_output(["clang++", "-print-resource-dir"], text=True).strip()
    host_includes = host_include_flags()
    selected = [p for p in PLANS if fam == "all" or p[0] == fam]
    if not selected:
        print(f"error: no plans for family '{fam}'", file=sys.stderr)
        return 2
    with concurrent.futures.ThreadPoolExecutor(max_workers=os.cpu_count() or 8) as ex:
        futs = [ex.submit(run_one, libc, rdir, host_includes, e) for e in selected]
        done = [f.result() for f in futs]
    print(f"Extracted {len(done)} plans for family '{fam}'.")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
