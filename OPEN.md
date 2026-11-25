# Open proof obligations

Generated from every `sorry` under `LibcMath/` by `scripts/check-open.py`.
Do not edit by hand; run `python3 scripts/check-open.py --update` after changing
the open lemmas.

Total open obligations: **166**.

| File | Lemma | Summary |
|---|---|---|
| `LibcMath/Kernels/Acosf.lean` | `acosfSse2_correctlyRounded` | **Open.** Prove `acosf` (`sse2`) is correctly rounded in all four C modes. |
| `LibcMath/Kernels/Acosf.lean` | `acosfAvx2Fma_correctlyRounded` | **Open.** Prove `acosf` (`avx2_fma`) is correctly rounded in all four C modes. |
| `LibcMath/Kernels/Acoshf.lean` | `acoshfSse2_correctlyRounded` | **Open.** Prove `acoshf` (`sse2`) is correctly rounded in all four C modes. |
| `LibcMath/Kernels/Acoshf.lean` | `acoshfAvx2Fma_correctlyRounded` | **Open.** Prove `acoshf` (`avx2_fma`) is correctly rounded in all four C modes. |
| `LibcMath/Kernels/Acospif.lean` | `acospifSse2_correctlyRounded` | **Open.** Prove `acospif` (`sse2`) is correctly rounded in all four C modes. |
| `LibcMath/Kernels/Acospif.lean` | `acospifAvx2Fma_correctlyRounded` | **Open.** Prove `acospif` (`avx2_fma`) is correctly rounded in all four C modes. |
| `LibcMath/Kernels/Asinf.lean` | `asinfSse2_correctlyRounded` | **Open.** Prove `asinf` (`sse2`) is correctly rounded in all four C modes. |
| `LibcMath/Kernels/Asinf.lean` | `asinfAvx2Fma_correctlyRounded` | **Open.** Prove `asinf` (`avx2_fma`) is correctly rounded in all four C modes. |
| `LibcMath/Kernels/Asinhf.lean` | `asinhfSse2_correctlyRounded` | **Open.** Prove `asinhf` (`sse2`) is correctly rounded in all four C modes. |
| `LibcMath/Kernels/Asinhf.lean` | `asinhfAvx2Fma_correctlyRounded` | **Open.** Prove `asinhf` (`avx2_fma`) is correctly rounded in all four C modes. |
| `LibcMath/Kernels/Asinpif.lean` | `asinpifSse2_correctlyRounded` | **Open.** Prove `asinpif` (`sse2`) is correctly rounded in all four C modes. |
| `LibcMath/Kernels/Asinpif.lean` | `asinpifAvx2Fma_correctlyRounded` | **Open.** Prove `asinpif` (`avx2_fma`) is correctly rounded in all four C modes. |
| `LibcMath/Kernels/Atan2f.lean` | `atan2fDoubleEvalSse2_correctlyRounded` | **Open.** Prove `atan2f` (`double_eval_sse2`) is correctly rounded in all four C modes. |
| `LibcMath/Kernels/Atan2f.lean` | `atan2fDoubleEvalAvx2Fma_correctlyRounded` | **Open.** Prove `atan2f` (`double_eval_avx2_fma`) is correctly rounded in all four C modes. |
| `LibcMath/Kernels/Atan2f.lean` | `atan2fFloatEval_defined` | **Open.** Prove `atan2f` (`float_eval`) executes without C++ undefined behavior. |
| `LibcMath/Kernels/Atanf.lean` | `atanfDoubleEvalSse2_correctlyRounded` | **Open.** Prove `atanf` (`double_eval_sse2`) is correctly rounded in all four C modes. |
| `LibcMath/Kernels/Atanf.lean` | `atanfDoubleEvalAvx2Fma_correctlyRounded` | **Open.** Prove `atanf` (`double_eval_avx2_fma`) is correctly rounded in all four C modes. |
| `LibcMath/Kernels/Atanf.lean` | `atanfFloatEval_defined` | **Open.** Prove `atanf` (`float_eval`) executes without C++ undefined behavior. |
| `LibcMath/Kernels/Atanhf.lean` | `atanhfSse2_correctlyRounded` | **Open.** Prove `atanhf` (`sse2`) is correctly rounded in all four C modes. |
| `LibcMath/Kernels/Atanhf.lean` | `atanhfAvx2Fma_correctlyRounded` | **Open.** Prove `atanhf` (`avx2_fma`) is correctly rounded in all four C modes. |
| `LibcMath/Kernels/Canonicalizef.lean` | `canonicalizefGenericSse2_defined` | **Open.** Prove `canonicalizef` (`generic_sse2`) executes without C++ undefined behavior. |
| `LibcMath/Kernels/Cbrtf.lean` | `cbrtfSse2_correctlyRounded` | **Open.** Prove `cbrtf` (`sse2`) is correctly rounded in all four C modes. |
| `LibcMath/Kernels/Cbrtf.lean` | `cbrtfAvx2Fma_correctlyRounded` | **Open.** Prove `cbrtf` (`avx2_fma`) is correctly rounded in all four C modes. |
| `LibcMath/Kernels/Ceilf.lean` | `ceilfGenericSse2_correctlyRounded` | **Open.** Prove `ceilf` (`generic_sse2`) is correctly rounded in all four C modes. |
| `LibcMath/Kernels/Ceilf.lean` | `ceilfBuiltinSse42_correctlyRounded` | **Open.** Prove `ceilf` (`builtin_sse42`) is correctly rounded in all four C modes. |
| `LibcMath/Kernels/Copysignf.lean` | `copysignfGenericSse2_correctlyRounded` | **Open.** Prove `copysignf` (`generic_sse2`) is correctly rounded in all four C modes. |
| `LibcMath/Kernels/Cosf.lean` | `cosfDoubleEvalSse2_correctlyRounded` | **Open.** Prove `cosf` (`double_eval_sse2`) is correctly rounded in all four C modes. |
| `LibcMath/Kernels/Cosf.lean` | `cosfDoubleEvalSse42_correctlyRounded` | **Open.** Prove `cosf` (`double_eval_sse42`) is correctly rounded in all four C modes. |
| `LibcMath/Kernels/Cosf.lean` | `cosfDoubleEvalAvx2Fma_correctlyRounded` | **Open.** Prove `cosf` (`double_eval_avx2_fma`) is correctly rounded in all four C modes. |
| `LibcMath/Kernels/Cosf.lean` | `cosfFloatEval_defined` | **Open.** Prove `cosf` (`float_eval`) executes without C++ undefined behavior. |
| `LibcMath/Kernels/Coshf.lean` | `coshfSse2_correctlyRounded` | **Open.** Prove `coshf` (`sse2`) is correctly rounded in all four C modes. |
| `LibcMath/Kernels/Coshf.lean` | `coshfSse42_correctlyRounded` | **Open.** Prove `coshf` (`sse42`) is correctly rounded in all four C modes. |
| `LibcMath/Kernels/Coshf.lean` | `coshfAvx2Fma_correctlyRounded` | **Open.** Prove `coshf` (`avx2_fma`) is correctly rounded in all four C modes. |
| `LibcMath/Kernels/Cospif.lean` | `cospifSse2_correctlyRounded` | **Open.** Prove `cospif` (`sse2`) is correctly rounded in all four C modes. |
| `LibcMath/Kernels/Cospif.lean` | `cospifSse42_correctlyRounded` | **Open.** Prove `cospif` (`sse42`) is correctly rounded in all four C modes. |
| `LibcMath/Kernels/Cospif.lean` | `cospifAvx2Fma_correctlyRounded` | **Open.** Prove `cospif` (`avx2_fma`) is correctly rounded in all four C modes. |
| `LibcMath/Kernels/Erff.lean` | `erffSse2_correctlyRounded` | **Open.** Prove `erff` (`sse2`) is correctly rounded in all four C modes. |
| `LibcMath/Kernels/Erff.lean` | `erffAvx2Fma_correctlyRounded` | **Open.** Prove `erff` (`avx2_fma`) is correctly rounded in all four C modes. |
| `LibcMath/Kernels/Exp10f.lean` | `exp10fDoubleEvalSse2_correctlyRounded` | **Open.** Prove `exp10f` (`double_eval_sse2`) is correctly rounded across all four C modes. |
| `LibcMath/Kernels/Exp10f.lean` | `exp10fDoubleEvalSse42_correctlyRounded` | **Open.** Prove `exp10f` (`double_eval_sse42`) is correctly rounded across all four modes. |
| `LibcMath/Kernels/Exp10f.lean` | `exp10fDoubleEvalAvx2Fma_correctlyRounded` | **Open.** Prove `exp10f` (`double_eval_avx2_fma`) is correctly rounded across all modes. |
| `LibcMath/Kernels/Exp10f.lean` | `exp10fDoubleEvalAArch64_correctlyRounded` | **Open.** Prove `exp10f` (`double_eval_aarch64`) is correctly rounded across all modes. |
| `LibcMath/Kernels/Exp10f.lean` | `exp10fIntegerEval_correctlyRounded` | **Open.** Prove `exp10f` (`integer_eval`) is correctly rounded in round-to-nearest-even. |
| `LibcMath/Kernels/Exp10f.lean` | `exp10fStaticRounding_correctlyRounded` | **Open.** Prove `exp10f` (`static_rounding`) is correctly rounded across all four C modes. |
| `LibcMath/Kernels/Exp10f.lean` | `exp10fFloatEval_defined` | **Open.** Prove fast `exp10f` (`float_eval`) executes without C++ undefined behavior. |
| `LibcMath/Kernels/Exp10m1f.lean` | `exp10m1fSse2_correctlyRounded` | **Open.** Prove `exp10m1f` (`sse2`) is correctly rounded across all four C rounding modes. |
| `LibcMath/Kernels/Exp10m1f.lean` | `exp10m1fSse42_correctlyRounded` | **Open.** Prove `exp10m1f` (`sse42`) is correctly rounded across all four C rounding modes. |
| `LibcMath/Kernels/Exp10m1f.lean` | `exp10m1fAvx2Fma_correctlyRounded` | **Open.** Prove `exp10m1f` (`avx2_fma`) is correctly rounded across all four C modes. |
| `LibcMath/Kernels/Exp2f.lean` | `exp2fDoubleEvalSse2_correctlyRounded` | **Open.** Prove `exp2f` (`double_eval_sse2`) is correctly rounded across all four C modes. |
| `LibcMath/Kernels/Exp2f.lean` | `exp2fDoubleEvalSse42_correctlyRounded` | **Open.** Prove `exp2f` (`double_eval_sse42`) is correctly rounded across all four C modes. |
| `LibcMath/Kernels/Exp2f.lean` | `exp2fDoubleEvalAvx2Fma_correctlyRounded` | **Open.** Prove `exp2f` (`double_eval_avx2_fma`) is correctly rounded across all four modes. |
| `LibcMath/Kernels/Exp2f.lean` | `exp2fDoubleEvalAArch64_correctlyRounded` | **Open.** Prove `exp2f` (`double_eval_aarch64`) is correctly rounded across all four modes. |
| `LibcMath/Kernels/Exp2f.lean` | `exp2fIntegerEval_correctlyRounded` | **Open.** Prove `exp2f` (`integer_eval`) is correctly rounded in round-to-nearest-even. |
| `LibcMath/Kernels/Exp2f.lean` | `exp2fStaticRounding_correctlyRounded` | **Open.** Prove `exp2f` (`static_rounding`) is correctly rounded across all four C modes. |
| `LibcMath/Kernels/Exp2f.lean` | `exp2fFloatEval_defined` | **Open.** Prove fast `exp2f` (`float_eval`) executes without C++ undefined behavior. |
| `LibcMath/Kernels/Exp2m1f.lean` | `exp2m1fSse2_correctlyRounded_nonNegNaN` | **Open.** Prove `exp2m1f` (`sse2`) is correctly rounded on all non-negative-NaN inputs. |
| `LibcMath/Kernels/Exp2m1f.lean` | `exp2m1fSse42_correctlyRounded_nonNegNaN` | **Open.** Prove `exp2m1f` (`sse42`) is correctly rounded on all non-negative-NaN inputs. |
| `LibcMath/Kernels/Exp2m1f.lean` | `exp2m1fAvx2Fma_correctlyRounded_nonNegNaN` | **Open.** Prove `exp2m1f` (`avx2_fma`) is correctly rounded on all non-negative-NaN inputs. |
| `LibcMath/Kernels/Expf/Proof/DoubleEvalFma.lean` | `expfDoubleEvalFma_mainRangesChecked` | **Open.** Prove that `Generated.DoubleEvalFma.expf` is correct on both main polynomial ranges in each C rounding direction. A proof follows `Proof.DoubleEval.MainPath` with the FMA error bounds. |
| `LibcMath/Kernels/Expf/Proof/FloatEval.lean` | `expfFloatEval_defined` | **Open.** Prove that `math::float_eval::expf` reaches no operation that C++ leaves undefined in round to nearest. |
| `LibcMath/Kernels/Expf/Proof/FloatEvalCrRn.lean` | `expfFloatEvalCrRn_correctlyRounded` | **Open.** Prove that `math::float_eval_cr_rn::expf` is correctly rounded in round to nearest. |
| `LibcMath/Kernels/Expf/Proof/Microarch.lean` | `expfDoubleEvalSse42_correctlyRounded` | **Open.** Prove that `math::double_eval::expf` compiled with `-msse4.2 -mno-fma` is correctly rounded across all four IEEE rounding modes. |
| `LibcMath/Kernels/Expf/Proof/Microarch.lean` | `expfDoubleEvalAArch64_correctlyRounded` | **Open.** Prove that `math::double_eval::expf` compiled for AArch64 is correctly rounded across all four IEEE rounding modes. |
| `LibcMath/Kernels/Expf/Proof/StaticRounding.lean` | `expfStaticRounding_mainRangesChecked` | **Open.** Prove that `Generated.StaticRounding.kernel` is correct on both main polynomial ranges in each C rounding direction. A proof bounds the error of the `Frac64` polynomial and clears the rounding boundaries with TMD certificates. |
| `LibcMath/Kernels/Expm1f.lean` | `expm1fSse2_correctlyRounded` | **Open.** Prove `expm1f` (`sse2`) is correctly rounded across all four C rounding modes. |
| `LibcMath/Kernels/Expm1f.lean` | `expm1fSse42_correctlyRounded` | **Open.** Prove `expm1f` (`sse42`) is correctly rounded across all four C rounding modes. |
| `LibcMath/Kernels/Expm1f.lean` | `expm1fAvx2Fma_correctlyRounded` | **Open.** Prove `expm1f` (`avx2_fma`) is correctly rounded across all four C rounding modes. |
| `LibcMath/Kernels/Fabsf.lean` | `fabsfGenericSse2_correctlyRounded` | **Open.** Prove `fabsf` (`generic_sse2`) is correctly rounded in all four C modes. |
| `LibcMath/Kernels/Fdimf.lean` | `fdimfGenericSse2_correctlyRounded` | **Open.** Prove `fdimf` (`generic_sse2`) is correctly rounded in all four C modes. |
| `LibcMath/Kernels/Floorf.lean` | `floorfGenericSse2_correctlyRounded` | **Open.** Prove `floorf` (`generic_sse2`) is correctly rounded in all four C modes. |
| `LibcMath/Kernels/Floorf.lean` | `floorfBuiltinSse42_correctlyRounded` | **Open.** Prove `floorf` (`builtin_sse42`) is correctly rounded in all four C modes. |
| `LibcMath/Kernels/Fmaf.lean` | `fmafGenericSse2_correctlyRounded` | **Open.** Prove `fmaf` (`generic_sse2`) is correctly rounded in all four C modes. |
| `LibcMath/Kernels/Fmaf.lean` | `fmafAvx2Fma_correctlyRounded` | **Open.** Prove `fmaf` (`avx2_fma`) is correctly rounded in all four C modes. |
| `LibcMath/Kernels/Fmaxf.lean` | `fmaxfGenericSse2_correctlyRounded` | **Open.** Prove `fmaxf` (`generic_sse2`) is correctly rounded in all four C modes. |
| `LibcMath/Kernels/FmaximumMagNumf.lean` | `fmaximum_mag_numfGenericSse2_correctlyRounded` | **Open.** Prove `fmaximum_mag_numf` (`generic_sse2`) is correctly rounded in all four C modes. |
| `LibcMath/Kernels/FmaximumMagf.lean` | `fmaximum_magfGenericSse2_correctlyRounded` | **Open.** Prove `fmaximum_magf` (`generic_sse2`) is correctly rounded in all four C modes. |
| `LibcMath/Kernels/FmaximumNumf.lean` | `fmaximum_numfGenericSse2_correctlyRounded` | **Open.** Prove `fmaximum_numf` (`generic_sse2`) is correctly rounded in all four C modes. |
| `LibcMath/Kernels/Fmaximumf.lean` | `fmaximumfGenericSse2_correctlyRounded` | **Open.** Prove `fmaximumf` (`generic_sse2`) is correctly rounded in all four C modes. |
| `LibcMath/Kernels/Fminf.lean` | `fminfGenericSse2_correctlyRounded` | **Open.** Prove `fminf` (`generic_sse2`) is correctly rounded in all four C modes. |
| `LibcMath/Kernels/FminimumMagNumf.lean` | `fminimum_mag_numfGenericSse2_correctlyRounded` | **Open.** Prove `fminimum_mag_numf` (`generic_sse2`) is correctly rounded in all four C modes. |
| `LibcMath/Kernels/FminimumMagf.lean` | `fminimum_magfGenericSse2_correctlyRounded` | **Open.** Prove `fminimum_magf` (`generic_sse2`) is correctly rounded in all four C modes. |
| `LibcMath/Kernels/FminimumNumf.lean` | `fminimum_numfGenericSse2_correctlyRounded` | **Open.** Prove `fminimum_numf` (`generic_sse2`) is correctly rounded in all four C modes. |
| `LibcMath/Kernels/Fminimumf.lean` | `fminimumfGenericSse2_correctlyRounded` | **Open.** Prove `fminimumf` (`generic_sse2`) is correctly rounded in all four C modes. |
| `LibcMath/Kernels/Fmodf.lean` | `fmodfGenericSse2_defined` | **Open.** Prove `fmodf` (`generic_sse2`) executes without C++ undefined behavior. |
| `LibcMath/Kernels/Frexpf.lean` | `frexpfGenericSse2_defined` | **Open.** Prove `frexpf` (`generic_sse2`) executes without C++ undefined behavior. |
| `LibcMath/Kernels/Fromfpf.lean` | `fromfpfGenericSse2_defined` | **Open.** Prove `fromfpf` (`generic_sse2`) executes without C++ undefined behavior. |
| `LibcMath/Kernels/Fromfpxf.lean` | `fromfpxfGenericSse2_defined` | **Open.** Prove `fromfpxf` (`generic_sse2`) executes without C++ undefined behavior. |
| `LibcMath/Kernels/Getpayloadf.lean` | `getpayloadfGenericSse2_correctlyRounded` | **Open.** Prove `getpayloadf` (`generic_sse2`) matches `FloatLibSpec.getpayload` in C modes. |
| `LibcMath/Kernels/Hypotf.lean` | `hypotfGenericSse2_correctlyRounded` | **Open.** Prove `hypotf` (`generic_sse2`) is correctly rounded in all four C modes. |
| `LibcMath/Kernels/Hypotf.lean` | `hypotfAvx2Fma_correctlyRounded` | **Open.** Prove `hypotf` (`avx2_fma`) is correctly rounded in all four C modes. |
| `LibcMath/Kernels/Ilogbf.lean` | `ilogbfGenericSse2_defined` | **Open.** Prove `ilogbf` (`generic_sse2`) executes without C++ undefined behavior. |
| `LibcMath/Kernels/Iscanonicalf.lean` | `iscanonicalfGenericSse2_correct` | **Open.** Prove `iscanonicalf` (`generic_sse2`) matches IEEE canonical encoding predicate. |
| `LibcMath/Kernels/Isnanf.lean` | `isnanfGenericSse2_correct` | **Open.** Prove `isnanf` (`generic_sse2`) matches IEEE NaN classification. |
| `LibcMath/Kernels/Issignalingf.lean` | `issignalingfGenericSse2_correct` | **Open.** Prove `issignalingf` (`generic_sse2`) matches IEEE sNaN test. |
| `LibcMath/Kernels/Ldexpf.lean` | `ldexpfGenericSse2_defined` | **Open.** Prove `ldexpf` (`generic_sse2`) executes without C++ undefined behavior. |
| `LibcMath/Kernels/Lgammaf.lean` | `lgammafSse2_correctlyRounded` | **Open.** Prove `lgammaf` (`sse2`) is correctly rounded in all four C modes. |
| `LibcMath/Kernels/Lgammaf.lean` | `lgammafAvx2Fma_correctlyRounded` | **Open.** Prove `lgammaf` (`avx2_fma`) is correctly rounded in all four C modes. |
| `LibcMath/Kernels/Llogbf.lean` | `llogbfGenericSse2_defined` | **Open.** Prove `llogbf` (`generic_sse2`) executes without C++ undefined behavior. |
| `LibcMath/Kernels/Llrintf.lean` | `llrintfGenericSse2_defined` | **Open.** Prove `llrintf` (`generic_sse2`) executes without C++ undefined behavior. |
| `LibcMath/Kernels/Llroundf.lean` | `llroundfGenericSse2_defined` | **Open.** Prove `llroundf` (`generic_sse2`) executes without C++ undefined behavior. |
| `LibcMath/Kernels/Log10f.lean` | `log10fDoubleEvalSse2_correctlyRounded` | **Open.** Prove `log10f` (`double_eval_sse2`) is correctly rounded in all four C modes. |
| `LibcMath/Kernels/Log10f.lean` | `log10fDoubleEvalAvx2Fma_correctlyRounded` | **Open.** Prove `log10f` (`double_eval_avx2_fma`) is correctly rounded in all four C modes. |
| `LibcMath/Kernels/Log1pf.lean` | `log1pfDoubleEvalSse2_correctlyRounded` | **Open.** Prove `log1pf` (`double_eval_sse2`) is correctly rounded in all four C modes. |
| `LibcMath/Kernels/Log1pf.lean` | `log1pfDoubleEvalAvx2Fma_correctlyRounded` | **Open.** Prove `log1pf` (`double_eval_avx2_fma`) is correctly rounded in all four C modes. |
| `LibcMath/Kernels/Log2f.lean` | `log2fDoubleEvalSse2_correctlyRounded` | **Open.** Prove `log2f` (`double_eval_sse2`) is correctly rounded in all four C modes. |
| `LibcMath/Kernels/Log2f.lean` | `log2fDoubleEvalAvx2Fma_correctlyRounded` | **Open.** Prove `log2f` (`double_eval_avx2_fma`) is correctly rounded in all four C modes. |
| `LibcMath/Kernels/Logbf.lean` | `logbfGenericSse2_defined` | **Open.** Prove `logbf` (`generic_sse2`) executes without C++ undefined behavior. |
| `LibcMath/Kernels/Logf.lean` | `logfDoubleEvalSse2_correctlyRounded` | **Open.** Prove `logf` (`double_eval_sse2`) is correctly rounded in all four C modes. |
| `LibcMath/Kernels/Logf.lean` | `logfDoubleEvalAvx2Fma_correctlyRounded` | **Open.** Prove `logf` (`double_eval_avx2_fma`) is correctly rounded in all four C modes. |
| `LibcMath/Kernels/Lrintf.lean` | `lrintfGenericSse2_defined` | **Open.** Prove `lrintf` (`generic_sse2`) executes without C++ undefined behavior. |
| `LibcMath/Kernels/Lroundf.lean` | `lroundfGenericSse2_defined` | **Open.** Prove `lroundf` (`generic_sse2`) executes without C++ undefined behavior. |
| `LibcMath/Kernels/Modff.lean` | `modffGenericSse2_defined` | **Open.** Prove `modff` (`generic_sse2`) executes without C++ undefined behavior. |
| `LibcMath/Kernels/Nearbyintf.lean` | `nearbyintfGenericSse2_correctlyRounded` | **Open.** Prove `nearbyintf` (`generic_sse2`) is correctly rounded in all four C modes. |
| `LibcMath/Kernels/Nearbyintf.lean` | `nearbyintfBuiltinSse42_correctlyRounded` | **Open.** Prove `nearbyintf` (`builtin_sse42`) is correctly rounded in all four C modes. |
| `LibcMath/Kernels/Nextafterf.lean` | `nextafterfGenericSse2_defined` | **Open.** Prove `nextafterf` (`generic_sse2`) executes without C++ undefined behavior. |
| `LibcMath/Kernels/Nextdownf.lean` | `nextdownfGenericSse2_correctlyRounded` | **Open.** Prove `nextdownf` (`generic_sse2`) matches `FloatLibSpec.nextdown` in all C modes. |
| `LibcMath/Kernels/Nextupf.lean` | `nextupfGenericSse2_correctlyRounded` | **Open.** Prove `nextupf` (`generic_sse2`) matches `FloatLibSpec.nextup` in all four C modes. |
| `LibcMath/Kernels/Powf.lean` | `powfDoubleEvalSse2_correctlyRounded` | **Open.** Prove `powf` (`double_eval_sse2`) is correctly rounded in all four C modes. |
| `LibcMath/Kernels/Powf.lean` | `powfDoubleEvalSse42_correctlyRounded` | **Open.** Prove `powf` (`double_eval_sse42`) is correctly rounded in all four C modes. |
| `LibcMath/Kernels/Powf.lean` | `powfDoubleEvalAvx2Fma_correctlyRounded` | **Open.** Prove `powf` (`double_eval_avx2_fma`) is correctly rounded in all four C modes. |
| `LibcMath/Kernels/Powf.lean` | `powfFloatEval_defined` | **Open.** Prove `powf` (`float_eval`) executes without C++ undefined behavior. |
| `LibcMath/Kernels/Remainderf.lean` | `remainderfGenericSse2_correctlyRounded` | **Open.** Prove `remainderf` (`generic_sse2`) matches IEEE remainder in all C modes. |
| `LibcMath/Kernels/Remquof.lean` | `remquofGenericSse2_defined` | **Open.** Prove `remquof` (`generic_sse2`) executes without C++ undefined behavior. |
| `LibcMath/Kernels/Rintf.lean` | `rintfGenericSse2_correctlyRounded` | **Open.** Prove `rintf` (`generic_sse2`) is correctly rounded in all four C modes. |
| `LibcMath/Kernels/Rintf.lean` | `rintfBuiltinSse42_correctlyRounded` | **Open.** Prove `rintf` (`builtin_sse42`) is correctly rounded in all four C modes. |
| `LibcMath/Kernels/Roundevenf.lean` | `roundevenfGenericSse2_correctlyRounded` | **Open.** Prove `roundevenf` (`generic_sse2`) is correctly rounded in all four C modes. |
| `LibcMath/Kernels/Roundevenf.lean` | `roundevenfBuiltinSse42_correctlyRounded` | **Open.** Prove `roundevenf` (`builtin_sse42`) is correctly rounded in all four C modes. |
| `LibcMath/Kernels/Roundf.lean` | `roundfGenericSse2_correctlyRounded` | **Open.** Prove `roundf` (`generic_sse2`) is correctly rounded in all four C modes. |
| `LibcMath/Kernels/Roundf.lean` | `roundfAArch64_correctlyRounded` | **Open.** Prove `roundf` (`aarch64`) is correctly rounded in all four C modes. |
| `LibcMath/Kernels/Rsqrtf.lean` | `rsqrtfSse2_correctlyRounded` | **Open.** Prove `rsqrtf` (`sse2`) is correctly rounded in all four C modes. |
| `LibcMath/Kernels/Rsqrtf.lean` | `rsqrtfAvx2Fma_correctlyRounded` | **Open.** Prove `rsqrtf` (`avx2_fma`) is correctly rounded in all four C modes. |
| `LibcMath/Kernels/Scalblnf.lean` | `scalblnfGenericSse2_defined` | **Open.** Prove `scalblnf` (`generic_sse2`) executes without C++ undefined behavior. |
| `LibcMath/Kernels/Scalbnf.lean` | `scalbnfGenericSse2_defined` | **Open.** Prove `scalbnf` (`generic_sse2`) executes without C++ undefined behavior. |
| `LibcMath/Kernels/Setpayloadf.lean` | `setpayloadfGenericSse2_defined` | **Open.** Prove `setpayloadf` (`generic_sse2`) executes without C++ undefined behavior. |
| `LibcMath/Kernels/Setpayloadsigf.lean` | `setpayloadsigfGenericSse2_defined` | **Open.** Prove `setpayloadsigf` (`generic_sse2`) executes without C++ undefined behavior. |
| `LibcMath/Kernels/Sincosf.lean` | `sincosfSse2_correctlyRounded` | **Open.** Prove `sincosf` (`sse2`) is correctly rounded in all four C modes. |
| `LibcMath/Kernels/Sincosf.lean` | `sincosfSse42_correctlyRounded` | **Open.** Prove `sincosf` (`sse42`) is correctly rounded in all four C modes. |
| `LibcMath/Kernels/Sincosf.lean` | `sincosfAvx2Fma_correctlyRounded` | **Open.** Prove `sincosf` (`avx2_fma`) is correctly rounded in all four C modes. |
| `LibcMath/Kernels/Sinf.lean` | `sinfDoubleEvalSse2_correctlyRounded` | **Open.** Prove `sinf` (`double_eval_sse2`) is correctly rounded in all four C modes. |
| `LibcMath/Kernels/Sinf.lean` | `sinfDoubleEvalSse42_correctlyRounded` | **Open.** Prove `sinf` (`double_eval_sse42`) is correctly rounded in all four C modes. |
| `LibcMath/Kernels/Sinf.lean` | `sinfDoubleEvalAvx2Fma_correctlyRounded` | **Open.** Prove `sinf` (`double_eval_avx2_fma`) is correctly rounded in all four C modes. |
| `LibcMath/Kernels/Sinf.lean` | `sinfFloatEval_defined` | **Open.** Prove `sinf` (`float_eval`) executes without C++ undefined behavior. |
| `LibcMath/Kernels/Sinhf.lean` | `sinhfSse2_correctlyRounded` | **Open.** Prove `sinhf` (`sse2`) is correctly rounded in all four C modes. |
| `LibcMath/Kernels/Sinhf.lean` | `sinhfSse42_correctlyRounded` | **Open.** Prove `sinhf` (`sse42`) is correctly rounded in all four C modes. |
| `LibcMath/Kernels/Sinhf.lean` | `sinhfAvx2Fma_correctlyRounded` | **Open.** Prove `sinhf` (`avx2_fma`) is correctly rounded in all four C modes. |
| `LibcMath/Kernels/Sinpif.lean` | `sinpifSse2_correctlyRounded` | **Open.** Prove `sinpif` (`sse2`) is correctly rounded in all four C modes. |
| `LibcMath/Kernels/Sinpif.lean` | `sinpifSse42_correctlyRounded` | **Open.** Prove `sinpif` (`sse42`) is correctly rounded in all four C modes. |
| `LibcMath/Kernels/Sinpif.lean` | `sinpifAvx2Fma_correctlyRounded` | **Open.** Prove `sinpif` (`avx2_fma`) is correctly rounded in all four C modes. |
| `LibcMath/Kernels/Sqrtf.lean` | `sqrtfX86Sse2_correctlyRounded` | **Open.** Prove `sqrtf` (`x86_sse2`) is correctly rounded in all four C modes. |
| `LibcMath/Kernels/Sqrtf.lean` | `sqrtfGenericSoftFloat_correctlyRounded` | **Open.** Prove `sqrtf` (`generic_softfloat`) is correctly rounded in all four C modes. |
| `LibcMath/Kernels/Tanf.lean` | `tanfDoubleEvalSse2_correctlyRounded` | **Open.** Prove `tanf` (`double_eval_sse2`) is correctly rounded in all four C modes. |
| `LibcMath/Kernels/Tanf.lean` | `tanfDoubleEvalSse42_correctlyRounded` | **Open.** Prove `tanf` (`double_eval_sse42`) is correctly rounded in all four C modes. |
| `LibcMath/Kernels/Tanf.lean` | `tanfDoubleEvalAvx2Fma_correctlyRounded` | **Open.** Prove `tanf` (`double_eval_avx2_fma`) is correctly rounded in all four C modes. |
| `LibcMath/Kernels/Tanf.lean` | `tanfFloatEval_defined` | **Open.** Prove `tanf` (`float_eval`) executes without C++ undefined behavior. |
| `LibcMath/Kernels/Tanhf.lean` | `tanhfSse2_correctlyRounded` | **Open.** Prove `tanhf` (`sse2`) is correctly rounded in all four C modes. |
| `LibcMath/Kernels/Tanhf.lean` | `tanhfSse42_correctlyRounded` | **Open.** Prove `tanhf` (`sse42`) is correctly rounded in all four C modes. |
| `LibcMath/Kernels/Tanhf.lean` | `tanhfAvx2Fma_correctlyRounded` | **Open.** Prove `tanhf` (`avx2_fma`) is correctly rounded in all four C modes. |
| `LibcMath/Kernels/Tanpif.lean` | `tanpifSse2_correctlyRounded` | **Open.** Prove `tanpif` (`sse2`) is correctly rounded in all four C modes. |
| `LibcMath/Kernels/Tanpif.lean` | `tanpifSse42_correctlyRounded` | **Open.** Prove `tanpif` (`sse42`) is correctly rounded in all four C modes. |
| `LibcMath/Kernels/Tanpif.lean` | `tanpifAvx2Fma_correctlyRounded` | **Open.** Prove `tanpif` (`avx2_fma`) is correctly rounded in all four C modes. |
| `LibcMath/Kernels/Totalorderf.lean` | `totalorderfGenericSse2_correct` | **Open.** Prove `totalorderf` (`generic_sse2`) matches `FloatLibSpec.totalorder`. |
| `LibcMath/Kernels/Totalordermagf.lean` | `totalordermagfGenericSse2_correct` | **Open.** Prove `totalordermagf` (`generic_sse2`) matches `FloatLibSpec.totalordermag`. |
| `LibcMath/Kernels/Truncf.lean` | `truncfGenericSse2_correctlyRounded` | **Open.** Prove `truncf` (`generic_sse2`) is correctly rounded in all four C modes. |
| `LibcMath/Kernels/Truncf.lean` | `truncfBuiltinSse42_correctlyRounded` | **Open.** Prove `truncf` (`builtin_sse42`) is correctly rounded in all four C modes. |
| `LibcMath/Kernels/Ufromfpf.lean` | `ufromfpfGenericSse2_defined` | **Open.** Prove `ufromfpf` (`generic_sse2`) executes without C++ undefined behavior. |
| `LibcMath/Kernels/Ufromfpxf.lean` | `ufromfpxfGenericSse2_defined` | **Open.** Prove `ufromfpxf` (`generic_sse2`) executes without C++ undefined behavior. |
