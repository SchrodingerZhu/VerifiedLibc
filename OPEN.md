# Open proof obligations

Generated from every `sorry` under `LibcMath/` by `scripts/check-open.py`.
Do not edit by hand; run `python3 scripts/check-open.py --update` after changing
the open lemmas.

Total open obligations: **23**.

| File | Lemma | Summary |
|---|---|---|
| `LibcMath/Kernels/Exp10f.lean` | `exp10fDoubleEvalSse2_correctlyRounded` | **Open.** Prove `exp10f` (`double_eval_sse2`) is correctly rounded across all four C modes. |
| `LibcMath/Kernels/Exp10f.lean` | `exp10fDoubleEvalSse42_correctlyRounded` | **Open.** Prove `exp10f` (`double_eval_sse42`) is correctly rounded across all four modes. |
| `LibcMath/Kernels/Exp10f.lean` | `exp10fDoubleEvalAvx2Fma_correctlyRounded` | **Open.** Prove `exp10f` (`double_eval_avx2_fma`) is correctly rounded across all modes. |
| `LibcMath/Kernels/Exp10f.lean` | `exp10fDoubleEvalAArch64_correctlyRounded` | **Open.** Prove `exp10f` (`double_eval_aarch64`) is correctly rounded across all modes. |
| `LibcMath/Kernels/Exp10f.lean` | `exp10fIntegerEval_correctlyRounded` | **Open.** Prove `exp10f` (`integer_eval`) is correctly rounded in round-to-nearest-even. |
| `LibcMath/Kernels/Exp10f.lean` | `exp10fFloatEval_defined` | **Open.** Prove fast `exp10f` (`float_eval`) executes without C++ undefined behavior. |
| `LibcMath/Kernels/Exp10m1f.lean` | `exp10m1fSse2_correctlyRounded` | **Open.** Prove `exp10m1f` (`sse2`) is correctly rounded across all four C rounding modes. |
| `LibcMath/Kernels/Exp10m1f.lean` | `exp10m1fSse42_correctlyRounded` | **Open.** Prove `exp10m1f` (`sse42`) is correctly rounded across all four C rounding modes. |
| `LibcMath/Kernels/Exp10m1f.lean` | `exp10m1fAvx2Fma_correctlyRounded` | **Open.** Prove `exp10m1f` (`avx2_fma`) is correctly rounded across all four C modes. |
| `LibcMath/Kernels/Exp2f.lean` | `exp2fDoubleEvalSse2_correctlyRounded` | **Open.** Prove `exp2f` (`double_eval_sse2`) is correctly rounded across all four C modes. |
| `LibcMath/Kernels/Exp2f.lean` | `exp2fDoubleEvalSse42_correctlyRounded` | **Open.** Prove `exp2f` (`double_eval_sse42`) is correctly rounded across all four C modes. |
| `LibcMath/Kernels/Exp2f.lean` | `exp2fDoubleEvalAvx2Fma_correctlyRounded` | **Open.** Prove `exp2f` (`double_eval_avx2_fma`) is correctly rounded across all four modes. |
| `LibcMath/Kernels/Exp2f.lean` | `exp2fDoubleEvalAArch64_correctlyRounded` | **Open.** Prove `exp2f` (`double_eval_aarch64`) is correctly rounded across all four modes. |
| `LibcMath/Kernels/Exp2f.lean` | `exp2fIntegerEval_correctlyRounded` | **Open.** Prove `exp2f` (`integer_eval`) is correctly rounded in round-to-nearest-even. |
| `LibcMath/Kernels/Exp2f.lean` | `exp2fFloatEval_defined` | **Open.** Prove fast `exp2f` (`float_eval`) executes without C++ undefined behavior. |
| `LibcMath/Kernels/Exp2m1f.lean` | `exp2m1fSse2_correctlyRounded_nonNegNaN` | **Open.** Prove `exp2m1f` (`sse2`) is correctly rounded on all non-negative-NaN inputs. |
| `LibcMath/Kernels/Exp2m1f.lean` | `exp2m1fSse42_correctlyRounded_nonNegNaN` | **Open.** Prove `exp2m1f` (`sse42`) is correctly rounded on all non-negative-NaN inputs. |
| `LibcMath/Kernels/Exp2m1f.lean` | `exp2m1fAvx2Fma_correctlyRounded_nonNegNaN` | **Open.** Prove `exp2m1f` (`avx2_fma`) is correctly rounded on all non-negative-NaN inputs. |
| `LibcMath/Kernels/Expf/Proof/Microarch.lean` | `expfDoubleEvalSse42_correctlyRounded` | **Open.** Prove that `math::double_eval::expf` compiled with `-msse4.2 -mno-fma` is correctly rounded across all four IEEE rounding modes. |
| `LibcMath/Kernels/Expf/Proof/Microarch.lean` | `expfDoubleEvalAArch64_correctlyRounded` | **Open.** Prove that `math::double_eval::expf` compiled for AArch64 is correctly rounded across all four IEEE rounding modes. |
| `LibcMath/Kernels/Expm1f.lean` | `expm1fSse2_correctlyRounded` | **Open.** Prove `expm1f` (`sse2`) is correctly rounded across all four C rounding modes. |
| `LibcMath/Kernels/Expm1f.lean` | `expm1fSse42_correctlyRounded` | **Open.** Prove `expm1f` (`sse42`) is correctly rounded across all four C rounding modes. |
| `LibcMath/Kernels/Expm1f.lean` | `expm1fAvx2Fma_correctlyRounded` | **Open.** Prove `expm1f` (`avx2_fma`) is correctly rounded across all four C rounding modes. |
