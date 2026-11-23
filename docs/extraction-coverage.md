# Extraction coverage

This document records how much of LLVM libc's math library the tools in `extract/` can export to
Lean today, and what is missing for the rest. It was measured on 2026-11-23 with

- llvm-project `f0e7941beee3`,
- clang 23.1.3 targeting x86-64 with libc's default configuration, compiled exactly as
  `extract/extract.sh` compiles (`-O3 -fno-vectorize -fno-slp-vectorize`, no `-march`),
- the exporter and the Lean IR at commit `23c1079`.

The tables are the output of `scripts/survey-extraction.py`:

```bash
nix develop -c scripts/survey-extraction.py <llvm-project>/libc
```

The run takes about ten seconds. Nothing it generates is committed; the compiled IR is left in
`extract/build/survey`.

## What was surveyed

- Every entrypoint `src/math/generic/<name>.cpp` whose name ends in `f` (96 files, all with
  `float` arguments, including the `f16*f` functions that return `_Float16`) or in `f16`
  (88 files). The bfloat16 entrypoints and `modf`, which is a double-precision function, are left
  out. clang 23 on x86-64 compiles all `_Float16` sources.
- Nine double-precision entrypoints: `exp`, `log`, `sin`, `cos`, `pow`, `exp2`, `log2`, `sqrt`,
  `hypot`.

The survey includes entrypoints that are not unary or binary functions of floating-point numbers
(for example `frexpf(float, int*)` or `nanf(const char*)`); their signatures are in the tables.

## How to read the tables

**Body function.** Most entrypoints only forward to a function in `src/__support/math`. The
script starts at the entrypoint and, as long as the function is a single block that does nothing
but call one other function defined in the module, moves to that function. The result is the
function that would be passed to `ir2lean --function`. Where libc chooses between implementations
at compile time (`expf`, `exp2f`, `exp10f`, `powf`, `sinf`, `cosf`, `tanf`), the default
configuration selects the `double_eval` implementation, and that is what the table shows. The
alternatives are `float_eval` (selected with `LIBC_MATH_HAS_SKIP_ACCURATE_PASS` together with
`LIBC_MATH_HAS_SMALL_TABLES` or `LIBC_MATH_HAS_INTERMEDIATE_COMP_IN_FLOAT`; for `sinf`, `cosf`
and `tanf` also only on targets with FMA) and, for `expf`, `integer_eval` (targets without a
double-precision FPU). They were not surveyed.

**Exports.** Whether `ir2lean` exports the body function. This column and the column *First
construct `ir2lean` rejects* come from running the committed tool.

**Blocks / instructions.** Basic blocks and instructions of the body function in the optimized
IR. A number in parentheses is the number of instructions in the functions the body calls, other
than core operations, followed transitively.

**Loop.** Whether the control-flow graph of the body function has a cycle. `ir2lean` does not
check this.

**Missing groups.** The script reads the IR of the body function and of every function it calls
and lists each construct that `FunctionTranslator.cpp` rejects. Each construct belongs to one of
the groups of the work list below. The column therefore says what would have to be done before
the entrypoint, including the functions it calls, could be exported. The constructs themselves,
with instruction counts and the names of the constant tables read, are listed per entrypoint at
the end of the document.

The script's reading of the IR and `ir2lean` agree on which functions export for all 193
entrypoints. The script reports a disagreement on standard error if there is one.

## Functions that export today

27 of the 96 single-precision entrypoints export without any change. All 27 exported files were
also elaborated with Lean against `LibcMath/IR/DSL.lean`, and the export of `expf` is identical
to the committed `LibcMath/Extracted/Expf.lean`. No half-precision and no surveyed
double-precision entrypoint exports.

| Kind | Entrypoints |
|---|---|
| Approximations of a real function, unary | `expf` (done), `cospif`, `sinpif` |
| Rounding to an integral value, unary | `ceilf`, `floorf`, `truncf`, `roundevenf` |
| Other unary | `fabsf`, `nextupf`, `nextdownf`, `isnanf`, `iscanonicalf`, `issignalingf` |
| Binary | `copysignf`, `fdimf`, `nextafterf`, `fmaxf`, `fminf`, `fmaximumf`, `fminimumf`, `fmaximum_numf`, `fminimum_numf`, `fmaximum_magf`, `fminimum_magf`, `fmaximum_mag_numf`, `fminimum_mag_numf` |
| Ternary | `fmaf` |

Remarks for whoever takes these up:

- `cospif` and `sinpif` are the closest to `expf`: unary, 18 and 21 blocks, one table
  (`SIN_K_PI_OVER_32`), and a specification that is the correct rounding of a real function.
- The unary functions of the second and third row have 2^32 inputs and can be checked input by
  input, but their specifications are exact IEEE 754 operations, not roundings of a real
  function. Three of them return `int`.
- `Func.CorrectlyRounded` in `LibcMath/IR/Semantics.lean` is stated for unary functions. The
  binary functions have 2^64 inputs and `fmaf` has 2^96, so they cannot be checked by enumerating
  inputs.
- `fmaf` exports because x86-64 without `-mfma` uses libc's software implementation, which
  computes in `double`. `floorf`, `ceilf`, `truncf` and `roundevenf` likewise export because the
  baseline x86-64 target has no SSE4.2 and libc then uses integer code instead of the compiler
  builtins.
- The body of `cospif` contains `fmul nnan double`. See *Observations about the tools* below.

## Results per entrypoint

### Single precision

| Entrypoint | Body function | Exports | Blocks / instructions | Loop | First construct `ir2lean` rejects | Missing groups |
|---|---|---|---|---|---|---|
| `acosf(float)` | `math::acosf` | no | 14 / 98 (+58) | no | `memory access: %39 = load volatile float, ptr %2, align 4, !tbaa !11` | volatile local variables, local memory and aggregates, calls of other functions, switch, llvm.sqrt |
| `acoshf(float)` | `math::acoshf` | no | 24 / 185 (+40) | no | `memory access: %39 = load volatile float, ptr %11, align 4, !tbaa !12` | volatile local variables, calls of other functions, switch, fdiv, sitofp, uitofp, fptoui, llvm.sqrt |
| `acospif(float)` | `math::acospif` | no | 11 / 74 (+26) | no | `call: %26 = tail call noundef double @_ZN11__llvm_libc13asin_internal1` | calls of other functions, llvm.sqrt |
| `asinf(float)` | `math::asinf` | no | 11 / 98 | no | `intrinsic: %64 = tail call noundef double @llvm.sqrt.f64(double %63)` | llvm.sqrt |
| `asinhf(float)` | `math::asinhf` | no | 31 / 190 (+40) | no | `terminator: switch i32 %4, label %122 [` | calls of other functions, switch, sitofp, uitofp, fptoui, llvm.sqrt |
| `asinpif(float)` | `math::asinpif` | no | 9 / 68 (+26) | no | `call: %22 = tail call noundef double @_ZN11__llvm_libc13asin_internal1` | calls of other functions, llvm.sqrt |
| `atan2f(float, float)` | `math::atan2f` | no | 18 / 151 (+274) | no | `memory access: %55 = load double, ptr %54, align 8, !tbaa !11` | tables of other shapes, local memory and aggregates, calls of other functions, fdiv, integer intrinsics |
| `atanf(float)` | `math::atanf` | no | 27 / 179 | no | `memory access: %20 = load volatile double, ptr %4, align 8, !tbaa !11` | volatile local variables, tables of other shapes, fdiv |
| `atanhf(float)` | `math::atanhf` | no | 14 / 97 | no | `intrinsic: %17 = tail call float @llvm.copysign.f32(float +inf, float ` | fdiv, sitofp, uitofp, fptoui, llvm.copysign, llvm.is.fpclass |
| `canonicalizef(float*, float const*)` | `canonicalizef` | no | 4 / 17 | no | `type: ptr %0` | local memory and aggregates |
| `cbrtf(float)` | `math::cbrtf` | no | 6 / 100 | no | `memory access: %32 = load double, ptr %31, align 8, !tbaa !11` | tables of other shapes, local memory and aggregates, integer division, floating-point environment access |
| `ceilf(float)` | `ceilf` | yes | 7 / 26 | no |  |  |
| `copysignf(float, float)` | `copysignf` | yes | 1 / 7 | no |  |  |
| `cosf(float)` | `math::double_eval::cosf` | no | 28 / 114 (+75) | no | `memory access: %24 = load i32, ptr %23, align 4, !tbaa !12` | local memory and aggregates, calls of other functions, loops, switch |
| `coshf(float)` | `math::coshf` | no | 9 / 73 | no | `cast: %32 = sitofp i32 %30 to double` | sitofp, uitofp, fptoui |
| `cospif(float)` | `math::cospif` | yes | 18 / 87 | no |  |  |
| `erff(float)` | `math::erff` | no | 13 / 117 | no | `memory access: %39 = load volatile float, ptr %5, align 4, !tbaa !11` | volatile local variables, tables of other shapes, switch |
| `exp10f(float)` | `math::double_eval::exp10f` | no | 17 / 77 (+114) | no | `call: %75 = tail call noundef float @_ZN11__llvm_libc4math11double_eva` | calls of other functions, switch |
| `exp10m1f(float)` | `math::exp10m1f` | no | 33 / 141 (+154) | no | `call: %19 = tail call i64 @_ZNK11__llvm_libc6fputil12ExceptValuesIfLm1` | local memory and aggregates, calls of other functions, switch |
| `exp2f(float)` | `math::double_eval::exp2f` | no | 25 / 129 (+35) | no | `memory access: %58 = load volatile float, ptr %3, align 4, !tbaa !10` | volatile local variables, local memory and aggregates, calls of other functions, switch, sitofp, uitofp, fptoui |
| `exp2m1f(float)` | `math::exp2m1f` | no | 24 / 113 (+49) | no | `memory access: %62 = load i32, ptr %61, align 4, !tbaa !13` | local memory and aggregates, calls of other functions, switch, sitofp, uitofp, fptoui |
| `expf(float)` | `math::double_eval::expf` | yes | 22 / 87 | no |  |  |
| `expm1f(float)` | `math::expm1f` | no | 25 / 117 | no | `terminator: switch i32 %2, label %15 [` | switch |
| `f16addf(float, float)` | `fputil::generic::add_or_sub` | no | 44 / 196 (+171) | no | `memory access: %102 = load volatile float, ptr %3, align 4, !tbaa !11` | binary16 type, volatile local variables, local memory and aggregates, calls of other functions, switch, unreachable, llvm.assume, freeze, poison, llvm.copysign, llvm.is.fpclass, integer intrinsics |
| `f16divf(float, float)` | `fputil::generic::div` | no | 27 / 241 (+115) | no | `instruction: %3 = alloca %"struct.__llvm_libc::fputil::DyadicFloat", a` | binary16 type, local memory and aggregates, calls of other functions, switch, unreachable, llvm.assume, freeze, poison, integer intrinsics |
| `f16fmaf(float, float, float)` | `fputil::generic::fma` | no | 43 / 250 (+294) | no | `instruction: %4 = alloca %"struct.__llvm_libc::fputil::DyadicFloat", a` | binary16 type, local memory and aggregates, calls of other functions, switch, unreachable, llvm.assume, freeze, poison, integer intrinsics |
| `f16mulf(float, float)` | `fputil::generic::mul` | no | 26 / 150 (+123) | no | `instruction: %3 = alloca %"struct.__llvm_libc::fputil::DyadicFloat", a` | binary16 type, local memory and aggregates, calls of other functions, switch, unreachable, llvm.assume, freeze, poison, integer intrinsics |
| `f16sqrtf(float)` | `math::f16sqrtf` | no | 18 / 290 (+115) | no | `instruction: %2 = alloca %"struct.__llvm_libc::fputil::DyadicFloat", a` | binary16 type, local memory and aggregates, calls of other functions, switch, unreachable, llvm.assume, freeze, poison, integer intrinsics |
| `f16subf(float, float)` | `fputil::generic::add_or_sub` | no | 45 / 201 (+171) | no | `memory access: %102 = load volatile float, ptr %3, align 4, !tbaa !11` | binary16 type, volatile local variables, local memory and aggregates, calls of other functions, switch, unreachable, llvm.assume, freeze, poison, llvm.copysign, llvm.is.fpclass, integer intrinsics |
| `fabsf(float)` | `fabsf` | yes | 1 / 2 | no |  |  |
| `fdimf(float, float)` | `fdimf` | yes | 4 / 14 | no |  |  |
| `floorf(float)` | `floorf` | yes | 12 / 43 | no |  |  |
| `fmaf(float, float, float)` | `fmaf` | yes | 8 / 47 | no |  |  |
| `fmaxf(float, float)` | `fmaxf` | yes | 6 / 21 | no |  |  |
| `fmaximum_mag_numf(float, float)` | `fmaximum_mag_numf` | yes | 13 / 42 | no |  |  |
| `fmaximum_magf(float, float)` | `fmaximum_magf` | yes | 8 / 25 | no |  |  |
| `fmaximum_numf(float, float)` | `fmaximum_numf` | yes | 11 / 39 | no |  |  |
| `fmaximumf(float, float)` | `fmaximumf` | yes | 6 / 21 | no |  |  |
| `fminf(float, float)` | `fminf` | yes | 4 / 19 | no |  |  |
| `fminimum_mag_numf(float, float)` | `fminimum_mag_numf` | yes | 11 / 40 | no |  |  |
| `fminimum_magf(float, float)` | `fminimum_magf` | yes | 6 / 23 | no |  |  |
| `fminimum_numf(float, float)` | `fminimum_numf` | yes | 9 / 37 | no |  |  |
| `fminimumf(float, float)` | `fminimumf` | yes | 4 / 19 | no |  |  |
| `fmodf(float, float)` | `fmodf` | no | 12 / 52 (+153) | no | `call: %47 = tail call i32 @_ZN11__llvm_libc6fputil7generic4FModIfmNS1_` | calls of other functions, loops, integer division, llvm.copysign, llvm.is.fpclass, integer intrinsics |
| `frexpf(float, int*)` | `frexpf` | no | 9 / 38 | yes | `type: ptr %1` | local memory and aggregates, loops |
| `fromfpf(float, int, unsigned int)` | `fromfpf` | no | 6 / 22 (+79) | no | `call: %9 = tail call noundef float @_ZN11__llvm_libc6fputil34round_usi` | calls of other functions, switch |
| `fromfpxf(float, int, unsigned int)` | `fromfpxf` | no | 8 / 30 (+79) | no | `call: %9 = tail call noundef float @_ZN11__llvm_libc6fputil34round_usi` | calls of other functions, switch |
| `getpayloadf(float const*)` | `getpayloadf` | no | 1 / 9 | no | `type: ptr %0` | local memory and aggregates, sitofp, uitofp, fptoui |
| `hypotf(float, float)` | `math::hypotf` | no | 13 / 82 | no | `intrinsic: %36 = tail call noundef double @llvm.sqrt.f64(double %35)` | llvm.sqrt |
| `ilogbf(float)` | `ilogbf` | no | 5 / 33 | no | `intrinsic: %27 = tail call range(i32 0, 33) i32 @llvm.ctlz.i32(i32 %25` | integer intrinsics |
| `iscanonicalf(float)` | `iscanonicalf` | yes | 3 / 12 | no |  |  |
| `isnanf(float)` | `isnanf` | yes | 1 / 5 | no |  |  |
| `issignalingf(float)` | `issignalingf` | yes | 1 / 9 | no |  |  |
| `ldexpf(float, int)` | `fputil::ldexp` | no | 13 / 75 (+99) | no | `instruction: %3 = alloca %"struct.__llvm_libc::fputil::DyadicFloat", a` | volatile local variables, local memory and aggregates, calls of other functions, sitofp, uitofp, fptoui, llvm.copysign, llvm.is.fpclass, integer intrinsics |
| `lgammaf(float)` | `math::lgammaf` | no | 65 / 753 (+1942) | no | `memory access: %47 = load i32, ptr %46, align 4, !tbaa !12` | volatile local variables, tables of other shapes, local memory and aggregates, calls of other functions, switch, fdiv, sitofp, uitofp, fptoui, integer intrinsics |
| `llogbf(float)` | `llogbf` | no | 5 / 34 | no | `intrinsic: %27 = tail call range(i32 0, 33) i32 @llvm.ctlz.i32(i32 %25` | integer intrinsics |
| `llrintf(float)` | `llrintf` | no | 8 / 33 (+112) | no | `call: %2 = tail call noundef float @_ZN11__llvm_libc6fputil33round_usi` | calls of other functions, switch, unreachable, llvm.assume, freeze, poison, llvm.copysign, llvm.is.fpclass, integer intrinsics |
| `llroundf(float)` | `fputil::round_to_signed_integer` | no | 13 / 58 | no | `intrinsic: %18 = tail call float @llvm.copysign.f32(float 1.000000e+00` | llvm.copysign, llvm.is.fpclass |
| `log10f(float)` | `math::log10f` | no | 29 / 154 | no | `memory access: %25 = load volatile float, ptr %9, align 4, !tbaa !11` | volatile local variables, switch, sitofp, uitofp, fptoui |
| `log1pf(float)` | `math::log1pf` | no | 31 / 245 | no | `memory access: %24 = load volatile float, ptr %16, align 4, !tbaa !10` | volatile local variables, switch, sitofp, uitofp, fptoui |
| `log2f(float)` | `math::log2f` | no | 10 / 61 | no | `cast: %23 = sitofp i32 %2 to float` | sitofp, uitofp, fptoui |
| `logbf(float)` | `logbf` | no | 7 / 35 | no | `intrinsic: %28 = tail call range(i32 0, 33) i32 @llvm.ctlz.i32(i32 %26` | sitofp, uitofp, fptoui, integer intrinsics |
| `logf(float)` | `math::logf` | no | 28 / 182 | no | `memory access: %16 = load volatile float, ptr %11, align 4, !tbaa !10` | volatile local variables, switch, sitofp, uitofp, fptoui |
| `lrintf(float)` | `lrintf` | no | 8 / 33 (+112) | no | `call: %2 = tail call noundef float @_ZN11__llvm_libc6fputil33round_usi` | calls of other functions, switch, unreachable, llvm.assume, freeze, poison, llvm.copysign, llvm.is.fpclass, integer intrinsics |
| `lroundf(float)` | `fputil::round_to_signed_integer` | no | 13 / 58 | no | `intrinsic: %18 = tail call float @llvm.copysign.f32(float 1.000000e+00` | llvm.copysign, llvm.is.fpclass |
| `modff(float, float*)` | `modff` | no | 13 / 45 | no | `type: ptr %1` | local memory and aggregates |
| `nanf(char const*)` | `nanf` | no | 8 / 29 (+180) | yes | `type: ptr %0` | local memory and aggregates, calls of other functions, loops, switch, integer intrinsics |
| `nearbyintf(float)` | `fputil::round_using_current_rounding_mode` | no | 35 / 112 | no | `intrinsic: %3 = tail call i32 @llvm.fshl.i32(i32 %2, i32 %2, i32 22)` | switch, unreachable, llvm.assume, freeze, poison, llvm.copysign, llvm.is.fpclass, integer intrinsics |
| `nextafterf(float, float)` | `nextafterf` | yes | 12 / 39 | no |  |  |
| `nextdownf(float)` | `nextdownf` | yes | 7 / 21 | no |  |  |
| `nexttowardf(float, long double)` | `nexttowardf` | no | 17 / 50 | no | `type: x86_fp80 %1` | other floating-point types, switch |
| `nextupf(float)` | `nextupf` | yes | 7 / 21 | no |  |  |
| `powf(float, float)` | `math::double_eval::powf` | no | 107 / 455 (+1022) | no | `memory access: %93 = load i8, ptr %92, align 1, !tbaa !11` | volatile local variables, tables of other shapes, local memory and aggregates, calls of other functions, loops, switch, integer division, sitofp, uitofp, fptoui, llvm.sqrt, integer intrinsics |
| `remainderf(float, float)` | `remainderf` | no | 1 / 6 (+274) | no | `instruction: %3 = alloca i32, align 4` | local memory and aggregates, calls of other functions, loops, llvm.copysign, llvm.is.fpclass |
| `remquof(float, float, int*)` | `fputil::remquo` | no | 38 / 177 (+97) | yes | `type: ptr %2` | local memory and aggregates, calls of other functions, loops, llvm.copysign, llvm.is.fpclass |
| `rintf(float)` | `fputil::round_using_current_rounding_mode` | no | 35 / 112 | no | `intrinsic: %3 = tail call i32 @llvm.fshl.i32(i32 %2, i32 %2, i32 22)` | switch, unreachable, llvm.assume, freeze, poison, llvm.copysign, llvm.is.fpclass, integer intrinsics |
| `roundevenf(float)` | `roundevenf` | yes | 15 / 54 | no |  |  |
| `roundf(float)` | `roundf` | no | 6 / 27 | no | `intrinsic: %18 = tail call float @llvm.copysign.f32(float 1.000000e+00` | llvm.copysign, llvm.is.fpclass |
| `rsqrtf(float)` | `rsqrtf` | no | 10 / 31 | no | `intrinsic: %18 = tail call float @llvm.copysign.f32(float +inf, float ` | fdiv, llvm.sqrt, llvm.copysign, llvm.is.fpclass |
| `scalblnf(float, long)` | `fputil::ldexp` | no | 13 / 76 (+99) | no | `instruction: %3 = alloca %"struct.__llvm_libc::fputil::DyadicFloat", a` | volatile local variables, local memory and aggregates, calls of other functions, sitofp, uitofp, fptoui, llvm.copysign, llvm.is.fpclass, integer intrinsics |
| `scalbnf(float, int)` | `fputil::ldexp` | no | 13 / 75 (+99) | no | `instruction: %3 = alloca %"struct.__llvm_libc::fputil::DyadicFloat", a` | volatile local variables, local memory and aggregates, calls of other functions, sitofp, uitofp, fptoui, llvm.copysign, llvm.is.fpclass, integer intrinsics |
| `setpayloadf(float*, float)` | `setpayloadf` | no | 7 / 29 | no | `type: ptr %0` | local memory and aggregates |
| `setpayloadsigf(float*, float)` | `setpayloadsigf` | no | 4 / 27 | no | `type: ptr %0` | local memory and aggregates |
| `sincosf(float, float*, float*)` | `math::sincosf` | no | 31 / 158 (+75) | no | `type: ptr %1` | tables of other shapes, local memory and aggregates, calls of other functions, loops, switch |
| `sinf(float)` | `math::double_eval::sinf` | no | 26 / 121 (+75) | no | `memory access: %88 = load double, ptr %2, align 8, !tbaa !12` | local memory and aggregates, calls of other functions, loops, switch |
| `sinhf(float)` | `math::sinhf` | no | 17 / 102 | no | `intrinsic: %51 = tail call float @llvm.copysign.f32(float +inf, float ` | sitofp, uitofp, fptoui, llvm.copysign, llvm.is.fpclass |
| `sinpif(float)` | `math::sinpif` | yes | 21 / 102 | no |  |  |
| `sqrtf(float)` | `sqrtf` | no | 1 / 2 | no | `intrinsic: %2 = tail call noundef float @llvm.sqrt.f32(float %0)` | llvm.sqrt |
| `tanf(float)` | `math::double_eval::tanf` | no | 25 / 140 (+122) | no | `memory access: %34 = load volatile float, ptr %3, align 4, !tbaa !11` | volatile local variables, local memory and aggregates, calls of other functions, loops, switch, fdiv |
| `tanhf(float)` | `math::tanhf` | no | 15 / 104 | no | `memory access: %49 = load volatile float, ptr %3, align 4, !tbaa !11` | volatile local variables, fdiv, sitofp, uitofp, fptoui, llvm.copysign, llvm.is.fpclass |
| `tanpif(float)` | `math::tanpif` | no | 19 / 105 (+35) | no | `instruction: %2 = alloca %"struct.__llvm_libc::fputil::ExceptValues", ` | local memory and aggregates, calls of other functions, switch, fdiv |
| `totalorderf(float const*, float const*)` | `totalorderf` | no | 1 / 10 | no | `type: ptr %0` | local memory and aggregates |
| `totalordermagf(float const*, float const*)` | `totalordermagf` | no | 1 / 9 | no | `type: ptr %0` | local memory and aggregates |
| `truncf(float)` | `truncf` | yes | 6 / 23 | no |  |  |
| `ufromfpf(float, int, unsigned int)` | `ufromfpf` | no | 6 / 20 (+79) | no | `call: %9 = tail call noundef float @_ZN11__llvm_libc6fputil34round_usi` | calls of other functions, switch |
| `ufromfpxf(float, int, unsigned int)` | `ufromfpxf` | no | 8 / 28 (+79) | no | `call: %9 = tail call noundef float @_ZN11__llvm_libc6fputil34round_usi` | calls of other functions, switch |

### Half precision

| Entrypoint | Body function | Exports | Blocks / instructions | Loop | First construct `ir2lean` rejects | Missing groups |
|---|---|---|---|---|---|---|
| `acosf16(_Float16)` | `math::acosf16` | no | 36 / 185 (+171) | no | `type: half %0` | binary16 type, local memory and aggregates, calls of other functions, switch, unreachable, llvm.assume, freeze, poison, llvm.sqrt, integer intrinsics |
| `acoshf16(_Float16)` | `math::acoshf16` | no | 27 / 161 (+366) | no | `type: half %0` | binary16 type, volatile local variables, local memory and aggregates, calls of other functions, loops, switch, unreachable, llvm.assume, freeze, poison, sitofp, uitofp, fptoui, llvm.sqrt, integer intrinsics |
| `acospif16(_Float16)` | `math::acospif16` | no | 29 / 168 (+171) | no | `type: half %0` | binary16 type, local memory and aggregates, calls of other functions, switch, unreachable, llvm.assume, freeze, poison, llvm.sqrt, integer intrinsics |
| `asinf16(_Float16)` | `math::asinf16` | no | 30 / 175 (+171) | no | `type: half %0` | binary16 type, local memory and aggregates, calls of other functions, switch, unreachable, llvm.assume, freeze, poison, llvm.sqrt, integer intrinsics |
| `asinhf16(_Float16)` | `math::asinhf16` | no | 34 / 182 (+294) | no | `type: half %0` | binary16 type, local memory and aggregates, calls of other functions, switch, unreachable, llvm.assume, freeze, poison, sitofp, uitofp, fptoui, llvm.sqrt, integer intrinsics |
| `asinpif16(_Float16)` | `math::asinpif16` | no | 23 / 163 (+351) | no | `type: half %0` | binary16 type, volatile local variables, local memory and aggregates, calls of other functions, switch, unreachable, llvm.assume, freeze, poison, sitofp, uitofp, fptoui, llvm.sqrt, integer intrinsics |
| `atan2f16(_Float16, _Float16)` | `math::atan2f16` | no | 23 / 189 (+181) | no | `type: half %0` | binary16 type, tables of other shapes, local memory and aggregates, calls of other functions, switch, unreachable, llvm.assume, freeze, poison, fdiv, integer intrinsics |
| `atanf16(_Float16)` | `math::atanf16` | no | 37 / 192 (+171) | no | `type: half %0` | binary16 type, local memory and aggregates, calls of other functions, switch, unreachable, llvm.assume, freeze, poison, fdiv, llvm.sqrt, integer intrinsics |
| `atanhf16(_Float16)` | `math::atanhf16` | no | 24 / 151 (+294) | no | `type: half %0` | binary16 type, local memory and aggregates, calls of other functions, switch, unreachable, llvm.assume, freeze, poison, fdiv, sitofp, uitofp, fptoui, llvm.copysign, llvm.is.fpclass, integer intrinsics |
| `atanpif16(_Float16)` | `math::atanpif16` | no | 33 / 226 (+296) | no | `type: half %0` | binary16 type, volatile local variables, local memory and aggregates, calls of other functions, switch, unreachable, llvm.assume, freeze, poison, fdiv, sitofp, uitofp, fptoui, llvm.sqrt, integer intrinsics |
| `canonicalizef16(_Float16*, _Float16 const*)` | `canonicalizef16` | no | 4 / 17 | no | `type: ptr %0` | binary16 type, local memory and aggregates |
| `cbrtf16(_Float16)` | `math::cbrtf16` | no | 18 / 165 (+115) | no | `type: half %0` | binary16 type, tables of other shapes, local memory and aggregates, calls of other functions, switch, unreachable, llvm.assume, freeze, poison, integer division, integer intrinsics, floating-point environment access |
| `ceilf16(_Float16)` | `ceilf16` | no | 7 / 27 | no | `type: half %0` | binary16 type |
| `copysignf16(_Float16, _Float16)` | `copysignf16` | no | 1 / 7 | no | `type: half %0` | binary16 type |
| `cosf16(_Float16)` | `math::cosf16` | no | 30 / 145 (+171) | no | `type: half %0` | binary16 type, local memory and aggregates, calls of other functions, switch, unreachable, llvm.assume, freeze, poison, integer intrinsics |
| `coshf16(_Float16)` | `math::coshf16` | no | 35 / 70 (+223) | no | `type: half %0` | binary16 type, tables of other shapes, local memory and aggregates, calls of other functions, switch, unreachable, llvm.assume, freeze, poison, integer intrinsics |
| `cospif16(_Float16)` | `math::cospif16` | no | 28 / 144 (+171) | no | `type: half %0` | binary16 type, local memory and aggregates, calls of other functions, switch, unreachable, llvm.assume, freeze, poison, integer intrinsics |
| `erfcf16(_Float16)` | `math::erfcf16` | no | 41 / 237 (+620) | no | `type: half %0` | binary16 type, volatile local variables, tables of other shapes, local memory and aggregates, calls of other functions, switch, unreachable, llvm.assume, freeze, poison, fdiv, sitofp, uitofp, fptoui, integer intrinsics |
| `erff16(_Float16)` | `math::erff16` | no | 31 / 153 (+171) | no | `type: half %0` | binary16 type, tables of other shapes, local memory and aggregates, calls of other functions, switch, unreachable, llvm.assume, freeze, poison, integer intrinsics |
| `exp10f16(_Float16)` | `math::exp10f16` | no | 45 / 165 (+296) | no | `type: half %0` | binary16 type, tables of other shapes, local memory and aggregates, calls of other functions, switch, unreachable, llvm.assume, freeze, poison, integer intrinsics |
| `exp10m1f16(_Float16)` | `math::exp10m1f16` | no | 50 / 193 (+447) | no | `type: half %0` | binary16 type, volatile local variables, tables of other shapes, local memory and aggregates, calls of other functions, switch, unreachable, llvm.assume, freeze, poison, integer intrinsics |
| `exp2f16(_Float16)` | `math::exp2f16` | no | 34 / 144 (+115) | no | `type: half %0` | binary16 type, tables of other shapes, local memory and aggregates, calls of other functions, switch, unreachable, llvm.assume, freeze, poison, integer intrinsics |
| `exp2m1f16(_Float16)` | `math::exp2m1f16` | no | 45 / 180 (+459) | no | `type: half %0` | binary16 type, volatile local variables, tables of other shapes, local memory and aggregates, calls of other functions, switch, unreachable, llvm.assume, freeze, poison, integer intrinsics |
| `expf16(_Float16)` | `math::expf16` | no | 37 / 171 (+196) | no | `type: half %0` | binary16 type, tables of other shapes, local memory and aggregates, calls of other functions, switch, unreachable, llvm.assume, freeze, poison, integer intrinsics |
| `expm1f16(_Float16)` | `math::expm1f16` | no | 40 / 177 (+505) | no | `type: half %0` | binary16 type, volatile local variables, tables of other shapes, local memory and aggregates, calls of other functions, switch, unreachable, llvm.assume, freeze, poison, integer intrinsics |
| `fabsf16(_Float16)` | `fabsf16` | no | 1 / 2 | no | `type: half %0` | binary16 type |
| `fdimf16(_Float16, _Float16)` | `fdimf16` | no | 4 / 14 | no | `type: half %0` | binary16 type |
| `floorf16(_Float16)` | `floorf16` | no | 12 / 45 | no | `type: half %0` | binary16 type |
| `fmaf16(_Float16, _Float16, _Float16)` | `fputil::generic::fma` | no | 42 / 250 (+115) | no | `type: half %0` | binary16 type, local memory and aggregates, calls of other functions, switch, unreachable, llvm.assume, freeze, poison, integer intrinsics |
| `fmaxf16(_Float16, _Float16)` | `fmaxf16` | no | 4 / 18 | no | `type: half %0` | binary16 type |
| `fmaximum_mag_numf16(_Float16, _Float16)` | `fmaximum_mag_numf16` | no | 9 / 39 | no | `type: half %0` | binary16 type |
| `fmaximum_magf16(_Float16, _Float16)` | `fmaximum_magf16` | no | 6 / 22 | no | `type: half %0` | binary16 type |
| `fmaximum_numf16(_Float16, _Float16)` | `fmaximum_numf16` | no | 7 / 36 | no | `type: half %0` | binary16 type |
| `fmaximumf16(_Float16, _Float16)` | `fmaximumf16` | no | 4 / 18 | no | `type: half %0` | binary16 type |
| `fminf16(_Float16, _Float16)` | `fminf16` | no | 4 / 18 | no | `type: half %0` | binary16 type |
| `fminimum_mag_numf16(_Float16, _Float16)` | `fminimum_mag_numf16` | no | 9 / 39 | no | `type: half %0` | binary16 type |
| `fminimum_magf16(_Float16, _Float16)` | `fminimum_magf16` | no | 6 / 22 | no | `type: half %0` | binary16 type |
| `fminimum_numf16(_Float16, _Float16)` | `fminimum_numf16` | no | 7 / 36 | no | `type: half %0` | binary16 type |
| `fminimumf16(_Float16, _Float16)` | `fminimumf16` | no | 4 / 18 | no | `type: half %0` | binary16 type |
| `fmodf16(_Float16, _Float16)` | `fmodf16` | no | 12 / 52 (+134) | no | `type: half %0` | binary16 type, calls of other functions, loops, integer division, llvm.copysign, llvm.is.fpclass, integer intrinsics |
| `frexpf16(_Float16, int*)` | `frexpf16` | no | 9 / 41 | yes | `type: half %0` | binary16 type, local memory and aggregates, loops |
| `fromfpf16(_Float16, int, unsigned int)` | `fromfpf16` | no | 6 / 23 (+83) | no | `type: half %0` | binary16 type, calls of other functions, switch |
| `fromfpxf16(_Float16, int, unsigned int)` | `fromfpxf16` | no | 8 / 31 (+83) | no | `type: half %0` | binary16 type, calls of other functions, switch |
| `getpayloadf16(_Float16 const*)` | `getpayloadf16` | no | 1 / 9 | no | `type: ptr %0` | binary16 type, local memory and aggregates, sitofp, uitofp, fptoui |
| `hypotf16(_Float16, _Float16)` | `math::hypotf16` | no | 29 / 198 (+270) | no | `type: half %0` | binary16 type, volatile local variables, local memory and aggregates, calls of other functions, switch, unreachable, llvm.assume, freeze, poison, sitofp, uitofp, fptoui, llvm.sqrt, integer intrinsics, floating-point environment access |
| `iscanonicalf16(_Float16)` | `iscanonicalf16` | no | 3 / 12 | no | `type: half %0` | binary16 type |
| `isnanf16(_Float16)` | `isnanf16` | no | 1 / 5 | no | `type: half %0` | binary16 type |
| `issignalingf16(_Float16)` | `issignalingf16` | no | 1 / 9 | no | `type: half %0` | binary16 type |
| `ldexpf16(_Float16, int)` | `fputil::ldexp` | no | 15 / 79 (+124) | no | `type: half %0` | binary16 type, local memory and aggregates, calls of other functions, switch, unreachable, llvm.assume, freeze, poison, llvm.copysign, llvm.is.fpclass, integer intrinsics |
| `lgammaf16(_Float16)` | `math::lgammaf16` | no | 61 / 533 (+292) | no | `type: half %0` | binary16 type, volatile local variables, local memory and aggregates, calls of other functions, switch, unreachable, llvm.assume, freeze, poison, fdiv, sitofp, uitofp, fptoui, integer intrinsics |
| `llrintf16(_Float16)` | `llrintf16` | no | 4 / 14 (+118) | no | `type: half %0` | binary16 type, calls of other functions, switch, unreachable, llvm.assume, freeze, poison, llvm.copysign, llvm.is.fpclass, integer intrinsics |
| `llroundf16(_Float16)` | `llroundf16` | no | 9 / 41 | no | `type: half %0` | binary16 type, llvm.copysign, llvm.is.fpclass |
| `log10f16(_Float16)` | `math::log10f16` | no | 44 / 153 (+115) | no | `type: half %0` | binary16 type, tables of other shapes, local memory and aggregates, calls of other functions, switch, unreachable, llvm.assume, freeze, poison, sitofp, uitofp, fptoui, integer intrinsics |
| `log10p1f16(_Float16)` | `math::log10p1f16` | no | 44 / 169 (+216) | no | `type: half %0` | binary16 type, tables of other shapes, local memory and aggregates, calls of other functions, switch, unreachable, llvm.assume, freeze, poison, sitofp, uitofp, fptoui, integer intrinsics |
| `log2f16(_Float16)` | `math::log2f16` | no | 36 / 144 (+115) | no | `type: half %0` | binary16 type, tables of other shapes, local memory and aggregates, calls of other functions, switch, unreachable, llvm.assume, freeze, poison, sitofp, uitofp, fptoui, integer intrinsics |
| `log2p1f16(_Float16)` | `math::log2p1f16` | no | 37 / 160 (+232) | no | `type: half %0` | binary16 type, tables of other shapes, local memory and aggregates, calls of other functions, switch, unreachable, llvm.assume, freeze, poison, sitofp, uitofp, fptoui, integer intrinsics |
| `logf16(_Float16)` | `math::logf16` | no | 37 / 146 (+115) | no | `type: half %0` | binary16 type, tables of other shapes, local memory and aggregates, calls of other functions, switch, unreachable, llvm.assume, freeze, poison, sitofp, uitofp, fptoui, integer intrinsics |
| `lrintf16(_Float16)` | `lrintf16` | no | 4 / 14 (+118) | no | `type: half %0` | binary16 type, calls of other functions, switch, unreachable, llvm.assume, freeze, poison, llvm.copysign, llvm.is.fpclass, integer intrinsics |
| `lroundf16(_Float16)` | `lroundf16` | no | 9 / 41 | no | `type: half %0` | binary16 type, llvm.copysign, llvm.is.fpclass |
| `modff16(_Float16, _Float16*)` | `modff16` | no | 13 / 46 | no | `type: half %0` | binary16 type, local memory and aggregates |
| `nanf16(char const*)` | `nanf16` | no | 8 / 29 (+185) | yes | `type: ptr %0` | binary16 type, local memory and aggregates, calls of other functions, loops, switch, integer division, integer intrinsics |
| `nearbyintf16(_Float16)` | `fputil::round_using_current_rounding_mode` | no | 34 / 118 | no | `type: half %0` | binary16 type, switch, unreachable, llvm.assume, freeze, poison, llvm.copysign, llvm.is.fpclass, integer intrinsics |
| `nextafterf16(_Float16, _Float16)` | `nextafterf16` | no | 12 / 39 | no | `type: half %0` | binary16 type |
| `nextdownf16(_Float16)` | `nextdownf16` | no | 7 / 21 | no | `type: half %0` | binary16 type |
| `nexttowardf16(_Float16, long double)` | `fputil::nextafter` | no | 42 / 206 (+245) | no | `type: half %0` | binary16 type, other floating-point types, volatile local variables, local memory and aggregates, calls of other functions, switch, unreachable, llvm.assume, freeze, poison, sitofp, uitofp, fptoui, integer intrinsics |
| `nextupf16(_Float16)` | `nextupf16` | no | 7 / 21 | no | `type: half %0` | binary16 type |
| `remainderf16(_Float16, _Float16)` | `remainderf16` | no | 1 / 6 (+285) | no | `type: half %0` | binary16 type, local memory and aggregates, calls of other functions, loops, llvm.copysign, llvm.is.fpclass |
| `remquof16(_Float16, _Float16, int*)` | `fputil::remquo` | no | 38 / 179 (+106) | yes | `type: half %0` | binary16 type, local memory and aggregates, calls of other functions, loops, llvm.copysign, llvm.is.fpclass |
| `rintf16(_Float16)` | `fputil::round_using_current_rounding_mode` | no | 34 / 118 | no | `type: half %0` | binary16 type, switch, unreachable, llvm.assume, freeze, poison, llvm.copysign, llvm.is.fpclass, integer intrinsics |
| `roundevenf16(_Float16)` | `roundevenf16` | no | 15 / 57 | no | `type: half %0` | binary16 type |
| `roundf16(_Float16)` | `roundf16` | no | 6 / 29 | no | `type: half %0` | binary16 type, llvm.copysign, llvm.is.fpclass |
| `rsqrtf16(_Float16)` | `math::rsqrtf16` | no | 27 / 127 (+214) | no | `type: half %0` | binary16 type, volatile local variables, local memory and aggregates, calls of other functions, switch, unreachable, llvm.assume, freeze, poison, fdiv, sitofp, uitofp, fptoui, llvm.sqrt, llvm.copysign, llvm.is.fpclass, integer intrinsics |
| `scalblnf16(_Float16, long)` | `fputil::ldexp` | no | 15 / 80 (+124) | no | `type: half %0` | binary16 type, local memory and aggregates, calls of other functions, switch, unreachable, llvm.assume, freeze, poison, llvm.copysign, llvm.is.fpclass, integer intrinsics |
| `scalbnf16(_Float16, int)` | `fputil::ldexp` | no | 15 / 79 (+124) | no | `type: half %0` | binary16 type, local memory and aggregates, calls of other functions, switch, unreachable, llvm.assume, freeze, poison, llvm.copysign, llvm.is.fpclass, integer intrinsics |
| `setpayloadf16(_Float16*, _Float16)` | `setpayloadf16` | no | 7 / 33 | no | `type: ptr %0` | binary16 type, local memory and aggregates |
| `setpayloadsigf16(_Float16*, _Float16)` | `setpayloadsigf16` | no | 4 / 31 | no | `type: ptr %0` | binary16 type, local memory and aggregates |
| `sinf16(_Float16)` | `math::sinf16` | no | 37 / 168 (+115) | no | `type: half %0` | binary16 type, local memory and aggregates, calls of other functions, switch, unreachable, llvm.assume, freeze, poison, integer intrinsics |
| `sinhf16(_Float16)` | `math::sinhf16` | no | 59 / 114 (+223) | no | `type: half %0` | binary16 type, tables of other shapes, local memory and aggregates, calls of other functions, switch, unreachable, llvm.assume, freeze, poison, llvm.copysign, llvm.is.fpclass, integer intrinsics |
| `sinpif16(_Float16)` | `math::sinpif16` | no | 25 / 137 (+115) | no | `type: half %0` | binary16 type, local memory and aggregates, calls of other functions, switch, unreachable, llvm.assume, freeze, poison, integer intrinsics |
| `sqrtf16(_Float16)` | `math::sqrtf16` | no | 10 / 141 (+124) | no | `type: half %0` | binary16 type, local memory and aggregates, calls of other functions, switch, unreachable, llvm.assume, freeze, poison, integer intrinsics |
| `tanf16(_Float16)` | `math::tanf16` | no | 40 / 186 (+171) | no | `type: half %0` | binary16 type, local memory and aggregates, calls of other functions, switch, unreachable, llvm.assume, freeze, poison, fdiv, integer intrinsics |
| `tanhf16(_Float16)` | `math::tanhf16` | no | 42 / 174 (+352) | no | `type: half %0` | binary16 type, tables of other shapes, local memory and aggregates, calls of other functions, switch, unreachable, llvm.assume, freeze, poison, fdiv, llvm.copysign, llvm.is.fpclass, integer intrinsics |
| `tanpif16(_Float16)` | `math::tanpif16` | no | 27 / 161 (+222) | no | `type: half %0` | binary16 type, local memory and aggregates, calls of other functions, switch, unreachable, llvm.assume, freeze, poison, fdiv, integer intrinsics |
| `totalorderf16(_Float16 const*, _Float16 const*)` | `totalorderf16` | no | 1 / 10 | no | `type: ptr %0` | local memory and aggregates |
| `totalordermagf16(_Float16 const*, _Float16 const*)` | `totalordermagf16` | no | 1 / 9 | no | `type: ptr %0` | binary16 type, local memory and aggregates |
| `truncf16(_Float16)` | `truncf16` | no | 6 / 24 | no | `type: half %0` | binary16 type |
| `ufromfpf16(_Float16, int, unsigned int)` | `ufromfpf16` | no | 6 / 21 (+83) | no | `type: half %0` | binary16 type, calls of other functions, switch |
| `ufromfpxf16(_Float16, int, unsigned int)` | `ufromfpxf16` | no | 8 / 29 (+83) | no | `type: half %0` | binary16 type, calls of other functions, switch |

### Double precision

| Entrypoint | Body function | Exports | Blocks / instructions | Loop | First construct `ir2lean` rejects | Missing groups |
|---|---|---|---|---|---|---|
| `exp(double)` | `math::exp` | no | 12 / 143 (+2705) | no | `memory access: %27 = load double, ptr %26, align 8, !tbaa !11` | volatile local variables, tables of other shapes, local memory and aggregates, calls of other functions, sitofp, uitofp, fptoui, integer intrinsics |
| `log(double)` | `math::log` | no | 11 / 86 (+1658) | no | `memory access: %39 = load double, ptr %38, align 8, !tbaa !14` | volatile local variables, tables of other shapes, local memory and aggregates, calls of other functions, sitofp, uitofp, fptoui, integer intrinsics |
| `sin(double)` | `math::sin` | no | 28 / 239 (+3096) | no | `memory access: %109 = load double, ptr %108, align 8, !tbaa !12` | volatile local variables, tables of other shapes, local memory and aggregates, calls of other functions, sitofp, uitofp, fptoui, integer intrinsics |
| `cos(double)` | `math::cos` | no | 22 / 229 (+3096) | no | `memory access: %18 = load volatile double, ptr %2, align 8, !tbaa !16` | volatile local variables, tables of other shapes, local memory and aggregates, calls of other functions, sitofp, uitofp, fptoui, integer intrinsics |
| `pow(double, double)` | `math::pow` | no | 110 / 707 (+8842) | no | `memory access: %99 = load double, ptr %98, align 16, !tbaa !12` | volatile local variables, tables of other shapes, local memory and aggregates, calls of other functions, loops, switch, unreachable, llvm.assume, freeze, poison, integer division, sitofp, uitofp, fptoui, llvm.sqrt, integer intrinsics, vectors |
| `exp2(double)` | `exp2` | no | 14 / 93 (+476) | no | `memory access: %47 = load double, ptr %46, align 16, !tbaa !12` | volatile local variables, tables of other shapes, local memory and aggregates, calls of other functions, loops, unreachable, llvm.assume, freeze, poison, sitofp, uitofp, fptoui, integer intrinsics, vectors |
| `log2(double)` | `math::log2` | no | 11 / 99 (+1584) | no | `memory access: %49 = load double, ptr %48, align 8, !tbaa !14` | volatile local variables, tables of other shapes, local memory and aggregates, calls of other functions, sitofp, uitofp, fptoui, integer intrinsics |
| `sqrt(double)` | `sqrt` | no | 1 / 2 | no | `intrinsic: %2 = tail call noundef double @llvm.sqrt.f64(double %0)` | llvm.sqrt |
| `hypot(double, double)` | `math::hypot` | no | 22 / 133 (+267) | no | `intrinsic: %10 = tail call i32 @llvm.umin.i32(i32 %6, i32 %8)` | calls of other functions, loops, switch, fdiv, llvm.sqrt, integer intrinsics |

## Work list

Each group below could be one unit of work. The first table repeats the generated table *Groups,
in the order that makes entrypoints exportable soonest* in shortened form. "Needed by" counts the
entrypoints whose body or called functions use the group; "only missing group" names the
entrypoints that need nothing else. An entrypoint becomes exportable only when all its groups are
done, so the last column of the generated table, which accumulates in that order, is the better
guide for planning. In that order the first seven groups bring the count from 27 to 82 of 193,
mostly functions that are exact IEEE 754 operations; the single-precision approximations of real
functions mostly become exportable with the groups after that (`switch`, volatile locals, tables
of other shapes, `fdiv`, loops).

| Group | Needed by: single (of 96) | half (of 88) | double (of 9) | Only missing group for |
|---|---|---|---|---|
| binary16 type | 6 | 87 | 0 | 23 half-precision entrypoints, the counterparts of the functions that export today except `fmaf16` |
| Local memory and aggregates | 33 | 53 | 7 | `canonicalizef`, `modff`, `setpayloadf`, `setpayloadsigf`, `totalorderf`, `totalordermagf`, `totalorderf16` |
| Calls of other functions | 36 | 52 | 8 | none |
| `switch` | 35 | 51 | 2 | `expm1f` |
| Integer intrinsics | 21 | 48 | 8 | `ilogbf`, `llogbf` |
| `unreachable`, `llvm.assume`, `freeze`, `poison` | 10 | 46 | 2 | none |
| `sitofp`, `uitofp`, `fptoui` | 19 | 16 | 7 | `coshf`, `log2f` |
| `llvm.copysign`, `llvm.is.fpclass` | 19 | 17 | 0 | `roundf`, `lroundf`, `llroundf` |
| Volatile local variables | 17 | 11 | 7 | none |
| Tables of other shapes | 7 | 18 | 7 | none |
| `llvm.sqrt` | 10 | 10 | 3 | `sqrtf`, `asinf`, `hypotf`, `sqrt` |
| `fdiv` | 9 | 10 | 1 | none |
| Loops | 10 | 6 | 3 | none |
| Integer division | 3 | 3 | 1 | none |
| Floating-point environment access | 1 | 2 | 0 | none |
| Vectors | 0 | 0 | 2 | none |
| Other floating-point types (`x86_fp80`) | 1 | 1 | 0 | none |

The FloatLib references are to v4.1.0, namespace `FloatLib.Floats.Formats.BinaryInterchange`.
Every operation named exists there with a rounding-direction argument unless stated otherwise.

### binary16 type

The exporter rejects the type `half`. The half-precision functions use `half` in parameters,
results, `bitcast`, `select`, `phi`, `fcmp`, `fpext`, `fptrunc`, `fptosi`, `llvm.fabs` and a few
`fadd`, `fsub`, `fmul`. `Instr` is already indexed by a `FloatFormat`, so the Lean side needs the
`half` keyword in the notation and nothing new in the semantics. FloatLib has
`FloatFormat.binary16`. One point needs a decision: x86-64 without AVX512-FP16 has no
half-precision arithmetic, and the code generator implements `fadd half` and the conversions
through `float` with calls to compiler runtime routines, so the assumption stated in `Semantics.lean`, that the
processor performs each instruction in the dynamic rounding direction, has to be re-examined for
`half`.

### Local memory and aggregates

Three different situations, all rejected today as `alloca`, non-table `load` and `store`, the
type `ptr`, `extractvalue` and `insertvalue`, `llvm.memcpy`, `llvm.memset`, `llvm.lifetime.*` and
`ret void`:

1. Entrypoints with pointer parameters: `modff`, `frexpf`, `remquof`, `sincosf`, `canonicalizef`,
   `setpayloadf`, `setpayloadsigf`, `getpayloadf`, `totalorderf`, `totalordermagf`, `nanf` and
   their half-precision counterparts.
2. Functions that return results through reference parameters, for example
   `large_range_reduction(double, int, double&)` used by `sinf`, `cosf`, `tanf` and `sincosf`,
   and everything that takes a `DyadicFloat` or `NumberPair` by reference in double precision.
3. Local structures that the optimizer does not turn into registers: `DyadicFloat<N>` (a sign, an
   exponent and an `N`-bit integer), `ExceptValues` tables copied to the stack, and arrays of
   128-bit and 256-bit integer limbs in the accurate passes of double precision.

The Lean semantics would need a memory: a map from allocations to byte or word arrays, pointers
as values (allocation and offset), and `load`, `store`, `getelementptr` on them; `Returns` would
relate arguments and initial memory to a result and final memory. A smaller first step that
covers situation 2 for scalars and many cases of 3 is to let the exporter run LLVM's
argument-promotion and scalar-replacement passes on functions it is about to export, or to
require callees to be inlined (see the next group), and only model what remains. FloatLib is not
involved.

### Calls of other functions

The surveyed functions call 84 distinct functions that are not core operations; the generated table
*Entrypoints calling each function* lists them. The most frequent are
`fputil::DyadicFloat<N>::generic_as<T>()` and `fast_as<T>()` (conversion of a `DyadicFloat` to a
floating-point number), `fputil::cast<_Float16>(float)`, `fputil::ExceptValues<T, N>::lookup`,
`fputil::round_using_specific_rounding_mode<T>(T, int)` and
`math::trigonometric_func_utils_internal::large_range_reduction`.

There are three ways to deal with a call, and they suit different callees:

- *Make it a core operation*, as for the rounding-mode queries. This fits small functions with a
  mathematical specification. Candidates with their signatures:
  - `T fputil::round_result_slightly_up<T>(T)` and `T fputil::round_result_slightly_down<T>(T)`:
    add or subtract the smallest normal number in the dynamic rounding direction (see *Volatile
    local variables*).
  - `int fputil::clear_except_if_required(int)`: no effect on values (see *Floating-point
    environment access*).
  - `double fputil::nearest_integer(double)`: `Model.roundToIntegral` to nearest.
  - `T fputil::round_using_current_rounding_mode<T>(T)` and
    `T fputil::round_using_specific_rounding_mode<T>(T, int)`: `Model.roundToIntegral`.
  - `_Float16 fputil::cast<_Float16, float>(float)`, `_Float16 fputil::cast<_Float16, double>(double)`,
    `float fputil::cast<float, _Float16>(_Float16)`: `Model.cast`.
  - `float fputil::sqrt<float, double>(double)`: `Model.sqrt` followed by `Model.cast` is not the
    same as one rounding, so this one needs its own specification.
  Each new core operation needs a proof or an argument that libc's implementation meets the
  specification given to it; that is extra work that exporting the callee avoids.
- *Export the callee too.* `Func` would become a set of functions and `Instr.call` would refer to
  one of them; `Run` needs a rule that runs the callee to its `ret`. This is needed for the
  accurate passes (`sin_accurate`, `exp_f128`, `log_accurate`, `pow_accurate`, …), which are too
  large to inline and are shared between entrypoints.
- *Inline the callee before exporting.* No change on the Lean side. Compiling with
  `-mllvm -inline-threshold=1000000` was tried: the number of entrypoints with a remaining call
  drops from 36 to 20 (single), 52 to 26 (half) and 8 to 6 (double), but no additional entrypoint
  exports, because the inlined bodies bring their own memory operations and loops with them.

### `switch`

Almost every `switch` dispatches on the result of `quick_get_round` (cases `0x400`, `0x800`,
`0xc00`) or on a small integer. Two options: add `Terminator.switch (a : Operand) (cases : List
(ℕ × ℕ)) (default : ℕ)` with one more rule in `Run`, or have the exporter rewrite switches into
conditional branches with LLVM's `lower-switch` pass, which needs no change in Lean. The second
was tried on `expm1f`: after `opt -passes=lower-switch`, `ir2lean` exports `math::expm1f`
unchanged. FloatLib is not involved.

### Integer intrinsics

By number of entrypoints: `llvm.ctlz` (65), `llvm.fshl` (57), `llvm.fshr` (17), `llvm.cttz`,
`llvm.umin`, `llvm.umax`, `llvm.smin`, `llvm.abs`, `llvm.ctpop`, and in the multi-word integer
arithmetic of the accurate passes `llvm.uadd.with.overflow`, `llvm.usub.with.overflow` and
`llvm.umul.with.overflow`. Each is one `Instr` constructor evaluated on `BitVec`; Lean's standard
library has count-leading-zeros, rotations and the overflow predicates. `ctlz` and `cttz` take a
flag that makes a zero argument poison, which matters for the stated treatment of poison. The
`with.overflow` intrinsics return a pair that is taken apart with `extractvalue`; the exporter
can emit them as two instructions, the wrapped result and the overflow bit, so that pairs need
not become values. FloatLib is not involved.

Integer types wider than 64 bits are not an obstacle: the exporter accepts `iN` for every `N` and
`Val` is a bit vector of any width, so a 64-by-64-bit multiplication through `i128` exports as it
is.

### `unreachable`, `llvm.assume`, `freeze`, `poison`

`unreachable` ends the default case of a switch over the rounding directions, for example in
`fputil::round_using_current_rounding_mode`; `freeze` appears in `DyadicFloat::generic_as` and
`sqrtf16`; `poison` appears as a vector operand in `pow` and `exp2`. `Semantics.lean` does not represent poison, so `freeze` is the
identity and `llvm.assume` can be dropped by the exporter. `unreachable` can be a terminator with
no rule in `Run`; then a function "has a result" only if the block is never reached, which is the
obligation one wants. FloatLib is not involved.

### `sitofp`, `uitofp`, `fptoui`

`sitofp` is in 29 entrypoints (mostly the exponent of the argument converted to `double` in
logarithms and hyperbolic functions), `uitofp` in 22, `fptoui` in 2. FloatLib has
`ExecDType.convertFromInt fmt (x : FixedInt width) mode` for signed integers, and
`ExecDType.convertToInteger`, which `fptosi` already uses. `FixedInt` is signed, so the unsigned
conversions go through an integer one bit wider. `sitofp` and `uitofp` round in the dynamic
direction when the integer has more bits than the significand.

### `llvm.copysign`, `llvm.is.fpclass`

`llvm.copysign` is in 34 entrypoints (`roundf`, `lroundf`, the hyperbolic functions, `atanhf`,
`rsqrtf`, …), `llvm.is.fpclass` in 2. Both are exact operations on the bit pattern, like `fneg`
and `fabs`. FloatLib has `Model.copySign` and `Model.classify`.

### Volatile local variables

libc writes a value to a `volatile` local and reads it back to keep the compiler from evaluating
a floating-point operation at compile time: in `fputil::round_result_slightly_up` and
`round_result_slightly_down` (56 uses in `src/__support`), in the exceptional cases of `atanf`,
`tanf`, `powf` and `pow`, and in `DyadicFloat`. In the IR this is an `alloca` whose
only uses are volatile loads and stores. Since the variable does not escape, a load returns the
last value stored; the exporter can replace each load by that value and emit ordinary
instructions (`fadd`, `fsub`), which needs no change in Lean. The alternative is to make the two
`round_result_slightly_*` functions core operations. FloatLib is not involved.

### Tables of other shapes

`ir2lean` accepts a `load` only through a `getelementptr` with one index into a constant array of
numbers. The other constants libc reads are two- and three-dimensional arrays
(`[N x [M x double]]`), arrays of structures (`NumberPair<double>`, `TripleDouble`,
`DyadicFloat<128>`), `cpp::array` wrapped in a structure, `ExceptValues` (pairs of input bit
pattern and four results), and single elements read at a constant address without a
`getelementptr`. All of these can be handled in the exporter by flattening the initializer to an
array of numbers of one width and turning the address computation into an index; `Table` in Lean
can stay as it is as long as every read of a table has the same width, and otherwise needs a
byte-addressed variant. FloatLib is not involved.

### `llvm.sqrt`

On x86-64 `sqrtf` and `sqrt` are the processor's instruction, and `asinf`, `acosf`, `asinpif`,
`acospif`, `asinhf`, `acoshf`, `hypotf`, `rsqrtf`, `powf`, `hypot` and `pow` use it. The semantics is `Model.sqrt` in
the dynamic rounding direction, under the same assumption as for `fadd`. `llvm.fma` does not
occur: without `-mfma` libc uses `llvm.fmuladd`, which is in the fragment, or its software
implementation. FloatLib has `Model.fma` should a target with FMA be surveyed.

### `fdiv`

In 20 entrypoints (`atanf`, `atan2f`, `atanhf`, `tanf`, `tanhf`, `tanpif`, `acoshf`, `rsqrtf`,
`lgammaf`, `hypot`, …). One more case of `FBinOp`, evaluated with `Model.div`. `frem` does not
occur.

### Loops

19 entrypoints have a loop in the body or in a called function: `sinf`, `cosf`, `tanf` and
`sincosf` (in `large_range_reduction`, the reduction of large arguments), `frexpf`, `fmodf`,
`remquof`, `remainderf`, `nanf`, `powf`, `hypot` (in `fputil::hypot`), `exp2`, `pow`, and six
half-precision entrypoints. `ir2lean` does not reject loops, and `Run`
is an inductive relation that already gives them a meaning. What depends on the absence of loops
is the comment in `Syntax.lean` and whatever evaluates a `Func` on an input: it needs a bound on
the number of blocks executed.

### Integer division

`udiv` and `urem` in `cbrtf`, `fmodf`, `powf`, `pow`, `cbrtf16`, `fmodf16` and `nanf16`.
Two more cases of `IntBinOp` with no result when the divisor is zero. FloatLib is not involved.

### Floating-point environment access

`cbrtf`, `cbrtf16` and `hypotf16` call `fputil::clear_except_if_required(FE_INEXACT)`, which is
inlined into the `stmxcsr` and `ldmxcsr` intrinsics and inline assembly (`fnstenv`, `fldenv`). Adding the
function to `extract/CoreOps.cpp` with the same meaning as `raiseExcept` removes all of it.

### Vectors

`pow` and `exp2` contain `<2 x double>` values (`insertelement`, `extractelement`) although both
vectorizers are off. The pass that creates them was not identified; finding it and turning it off
is likely cheaper than modelling vectors.

### Other floating-point types

Only `nexttowardf` and `nexttowardf16`, whose second parameter is `long double`.

## What double precision needs

`sqrt` needs only `llvm.sqrt`. `hypot` needs calls, a loop, `switch`, `fdiv`, `llvm.sqrt` and
integer intrinsics, and no memory. The other seven have the same structure: a fast pass of 86 to
239 instructions in the body function (707 for `pow`) and an accurate pass of 476 (`exp2`) to
8,842 (`pow`) instructions in called functions. For the fast pass alone the obstacles are tables of structures
(`NumberPair`, `TripleDouble`, two-dimensional arrays), `sitofp`, the volatile local of the
exceptional cases, and for `sin`, `cos` and `exp` local variables passed by reference to called
functions (for example a `NumberPair<double>` to `range_reduction_small`). The
accurate pass is `DyadicFloat<128>` arithmetic (`quick_add`, `quick_mul`, `polyeval`, `fast_as`):
structures passed by reference and returned through memory, multi-word integers built from
`llvm.uadd.with.overflow`, `llvm.usub.with.overflow` and `llvm.ctlz`, `memcpy` and `memset`. So
double precision needs, in this order, tables of other shapes, `sitofp`/`uitofp`, volatile
locals, calls between exported functions, local memory and aggregates, and the integer
intrinsics; `pow` and `exp2` additionally need loops and the vector issue resolved.

## Observations about the tools

- `ir2lean` drops fast-math flags without a diagnostic. 45 of the surveyed entrypoints contain
  `nnan` or `ninf` on some instruction, among them `cospif`, which exports today. The flags are
  not in the source; the optimizer adds them where it has proved that no NaN or infinity can
  occur, so they have the same standing as `nsw` and `nuw`, which `Semantics.lean` documents as
  not represented. No `nsz`, `arcp`, `contract`, `reassoc` or `afn` occurs anywhere.
- `ir2lean` does not check that the control-flow graph is free of cycles, although
  `Syntax.lean` describes the fragment as loop-free. No function that exports today has a loop.
- `relativeName` in `extract/CoreOps.cpp` strips template arguments by counting `<` and `>`. A
  name whose template arguments contain a comparison, such as the return type
  `enable_if<... && sizeof(T) <= sizeof(U), T>::type` of `fputil::generic::add_or_sub`, comes out
  as `cpp::enable_if`. `--function` therefore cannot name the body functions of `f16addf`,
  `f16subf`, `f16mulf`, `f16divf` and `f16fmaf` by their real names, and a lambda inside a
  function gets the same name as the function (`math::double_eval::exp2f` in the module of
  `powf`); the tool takes the first match in module order.
- Which functions export depends on the target. With `-march` values that provide SSE4.2 or FMA,
  libc uses compiler builtins for `floor`, `rint`, `fma` and similar operations in place of the
  integer code measured here. None of the corresponding intrinsics occurs in the default
  configuration, and other targets were not surveyed.

## Generated details

### Entrypoints using each construct

| Construct | Single | Half | Double |
|---|---|---|---|
| type half | 6 | 87 | 0 |
| type ptr | 32 | 53 | 7 |
| terminator switch | 35 | 51 | 2 |
| load from a pointer parameter | 25 | 49 | 7 |
| instruction alloca | 22 | 44 | 7 |
| intrinsic llvm.lifetime.end | 22 | 44 | 7 |
| intrinsic llvm.lifetime.start | 22 | 44 | 7 |
| store to a local variable | 15 | 44 | 7 |
| intrinsic llvm.ctlz | 15 | 43 | 7 |
| intrinsic llvm.fshl | 10 | 46 | 1 |
| terminator unreachable | 10 | 46 | 0 |
| instruction freeze | 6 | 42 | 0 |
| load from a computed pointer | 9 | 25 | 1 |
| volatile local variable | 17 | 11 | 7 |
| intrinsic llvm.copysign | 17 | 17 | 0 |
| load from a constant not in table form | 7 | 18 | 7 |
| cast sitofp | 15 | 9 | 5 |
| operand global | 5 | 24 | 0 |
| store to a pointer parameter | 13 | 7 | 6 |
| intrinsic llvm.sqrt | 10 | 10 | 3 |
| cast uitofp | 6 | 9 | 7 |
| intrinsic llvm.assume | 2 | 19 | 1 |
| load from a local variable | 11 | 5 | 6 |
| instruction fdiv | 9 | 10 | 1 |
| loop | 10 | 6 | 3 |
| intrinsic llvm.fshr | 2 | 14 | 1 |
| intrinsic llvm.memcpy.p0.p0 | 4 | 7 | 6 |
| ret void | 4 | 2 | 6 |
| instruction extractvalue | 2 | 1 | 7 |
| type aggregate | 2 | 1 | 7 |
| intrinsic llvm.uadd.with.overflow | 1 | 0 | 7 |
| intrinsic llvm.usub.with.overflow | 1 | 0 | 7 |
| intrinsic llvm.experimental.noalias.scope.decl | 1 | 1 | 5 |
| intrinsic llvm.cttz | 3 | 2 | 1 |
| intrinsic llvm.memset.p0 | 1 | 0 | 5 |
| intrinsic llvm.umin | 2 | 3 | 1 |
| instruction insertvalue | 1 | 1 | 3 |
| instruction udiv | 2 | 2 | 1 |
| instruction urem | 2 | 2 | 0 |
| intrinsic llvm.smin | 3 | 1 | 0 |
| intrinsic llvm.umax | 1 | 2 | 1 |
| store to a computed pointer | 2 | 1 | 1 |
| inline assembly | 1 | 2 | 0 |
| intrinsic llvm.x86.sse.ldmxcsr | 1 | 2 | 0 |
| intrinsic llvm.x86.sse.stmxcsr | 1 | 2 | 0 |
| cast fptoui | 1 | 0 | 1 |
| instruction extractelement | 0 | 0 | 2 |
| instruction insertelement | 0 | 0 | 2 |
| intrinsic llvm.abs | 1 | 0 | 1 |
| intrinsic llvm.ctpop | 1 | 0 | 1 |
| intrinsic llvm.is.fpclass | 2 | 0 | 0 |
| operand null | 0 | 0 | 2 |
| operand poison | 0 | 0 | 2 |
| type vector | 0 | 0 | 2 |
| type x86_fp80 | 1 | 1 | 0 |
| intrinsic llvm.umul.with.overflow | 1 | 0 | 0 |

### Entrypoints calling each function

| Function | Single | Half | Double |
|---|---|---|---|
| fputil::DyadicFloat::generic_as | 6 | 42 | 0 |
| fputil::cast | 3 | 23 | 0 |
| fputil::DyadicFloat::fast_as | 4 | 8 | 7 |
| fputil::ExceptValues::lookup | 4 | 6 | 0 |
| fputil::round_using_specific_rounding_mode | 4 | 4 | 0 |
| fputil::NormalFloat::NormalFloat | 2 | 2 | 0 |
| fputil::quick_add | 0 | 0 | 4 |
| fputil::round_using_current_rounding_mode | 2 | 2 | 0 |
| math::trigonometric_func_utils_internal::large_range_reduction | 4 | 0 | 0 |
| fputil::ExceptValues::lookup_odd | 2 | 1 | 0 |
| fputil::round_result_slightly_down | 0 | 3 | 0 |
| math::log_range_reduction_internal::log_range_reduction | 1 | 0 | 2 |
| acoshf_internal::log_eval | 2 | 0 | 0 |
| asin_internal::asinpi_eval | 2 | 0 | 0 |
| fputil::NormalFloat::operator _Float16 | 0 | 2 | 0 |
| fputil::NormalFloat::operator float | 2 | 0 | 0 |
| fputil::generic::FMod::eval_internal | 1 | 1 | 0 |
| fputil::nearest_integer | 1 | 0 | 1 |
| fputil::polyeval | 0 | 0 | 2 |
| fputil::remquo | 1 | 1 | 0 |
| internal::b36_char_to_int | 1 | 1 | 0 |
| internal::isalnum | 1 | 1 | 0 |
| internal::strtointeger | 1 | 1 | 0 |
| math::double_eval::exp10f_slow | 2 | 0 | 0 |
| math::double_eval::exp2_eval_frac128 | 0 | 0 | 2 |
| math::double_eval::exp2f(float)::'lambda'()::operator() | 2 | 0 | 0 |
| math::double_eval::exp_accurate_128 | 0 | 0 | 2 |
| math::double_eval::exp_denorm | 0 | 0 | 2 |
| math::double_eval::set_exceptional | 0 | 0 | 2 |
| math::expxf16_internal::eval_sinh_or_cosh | 0 | 2 | 0 |
| math::gamma_internal::lg_ln | 1 | 1 | 0 |
| math::gamma_internal::lg_sinpi | 1 | 1 | 0 |
| math::log_internal::log_accurate | 1 | 0 | 1 |
| math::range_reduction_double_internal::LargeRangeReduction::accurate | 0 | 0 | 2 |
| math::range_reduction_double_internal::LargeRangeReduction::fast | 0 | 0 | 2 |
| math::range_reduction_double_internal::range_reduction_small | 0 | 0 | 2 |
| math::range_reduction_double_internal::range_reduction_small_f128 | 0 | 0 | 2 |
| math::sincos_eval_internal::sincos_eval | 0 | 0 | 2 |
| asin_internal::asin_eval | 1 | 0 | 0 |
| exp10_denorm | 0 | 0 | 1 |
| exp10_double_double | 0 | 0 | 1 |
| exp10_f128 | 0 | 0 | 1 |
| exp10_poly_approx_dd | 0 | 0 | 1 |
| exp10_poly_approx_f128 | 0 | 0 | 1 |
| exp10_set_exceptional | 0 | 0 | 1 |
| fputil::DyadicFloat::DyadicFloat | 0 | 0 | 1 |
| fputil::DyadicFloat::normalize | 0 | 0 | 1 |
| fputil::floor | 1 | 0 | 0 |
| fputil::hypot | 0 | 0 | 1 |
| fputil::internal::FPRepImpl::make_value | 0 | 1 | 0 |
| fputil::quick_mul | 0 | 0 | 1 |
| fputil::round_result_slightly_up | 0 | 1 | 0 |
| fputil::sqrt | 0 | 1 | 0 |
| math::atan2f_internal::atan2f_double_double | 1 | 0 | 0 |
| math::atanpif16(_Float16)::'lambda'(double)::operator() | 0 | 1 | 0 |
| math::cos_accurate | 0 | 0 | 1 |
| math::double_eval::check_exact_boundary | 1 | 0 | 0 |
| math::double_eval::exp10f | 1 | 0 | 0 |
| math::double_eval::exp2f | 1 | 0 | 0 |
| math::double_eval::powf_accurate | 1 | 0 | 0 |
| math::exp10 | 0 | 0 | 1 |
| math::exp_internal::exp_f128 | 0 | 0 | 1 |
| math::exp_internal::poly_approx_dd | 0 | 0 | 1 |
| math::exp_internal::poly_approx_f128 | 0 | 0 | 1 |
| math::exp_internal::set_exceptional | 0 | 0 | 1 |
| math::hypot_internal::hypot_denorm | 0 | 0 | 1 |
| math::log | 1 | 0 | 0 |
| math::log2_internal::log2_accurate | 0 | 0 | 1 |
| math::pow_internal::exp2_f128 | 0 | 0 | 1 |
| math::pow_internal::exp2_f256 | 0 | 0 | 1 |
| math::pow_internal::is_exact_rounding_boundary | 0 | 0 | 1 |
| math::pow_internal::log2_f128 | 0 | 0 | 1 |
| math::pow_internal::log2_f256 | 0 | 0 | 1 |
| math::pow_internal::pow_accurate | 0 | 0 | 1 |
| math::pow_internal::pow_accurate_256 | 0 | 0 | 1 |
| math::pow_internal::set_overflow | 0 | 0 | 1 |
| math::pow_internal::set_underflow | 0 | 0 | 1 |
| math::pow_internal::ziv_test_denorm | 0 | 0 | 1 |
| math::powf_internal::is_exact_rounding_boundary | 1 | 0 | 0 |
| math::powf_internal::set_overflow | 1 | 0 | 0 |
| math::powf_internal::set_underflow | 1 | 0 | 0 |
| math::sin_accurate | 0 | 0 | 1 |
| ziv_test_denorm | 0 | 0 | 1 |

### Groups, in the order that makes entrypoints exportable soonest

| Group | Blocks: single | half | double | Becoming exportable at this step | Exportable so far |
|---|---|---|---|---|---|
| binary16 type | 6 | 87 | 0 | ceilf16, copysignf16, fabsf16, fdimf16, floorf16, fmaxf16, fmaximum_mag_numf16, fmaximum_magf16, fmaximum_numf16, fmaximumf16, fminf16, fminimum_mag_numf16, fminimum_magf16, fminimum_numf16, fminimumf16, iscanonicalf16, isnanf16, issignalingf16, nextafterf16, nextdownf16, nextupf16, roundevenf16, truncf16 | 50 of 193 |
| local memory and aggregates | 33 | 53 | 7 | canonicalizef, canonicalizef16, modff, modff16, setpayloadf, setpayloadf16, setpayloadsigf, setpayloadsigf16, totalorderf, totalorderf16, totalordermagf, totalordermagf16 | 62 of 193 |
| llvm.copysign, llvm.is.fpclass | 19 | 17 | 0 | llroundf, llroundf16, lroundf, lroundf16, roundf, roundf16 | 68 of 193 |
| sitofp, uitofp, fptoui | 19 | 16 | 7 | coshf, getpayloadf, getpayloadf16, log2f, sinhf | 73 of 193 |
| llvm.sqrt | 10 | 10 | 3 | asinf, hypotf, sqrtf, sqrt | 77 of 193 |
| integer intrinsics | 21 | 48 | 8 | ilogbf, llogbf, logbf | 80 of 193 |
| calls of other functions | 36 | 52 | 8 | acospif, asinpif | 82 of 193 |
| switch | 35 | 51 | 2 | asinhf, exp10f, exp10m1f, exp2m1f, expm1f, fromfpf, fromfpf16, fromfpxf, fromfpxf16, ufromfpf, ufromfpf16, ufromfpxf, ufromfpxf16 | 95 of 193 |
| unreachable, llvm.assume, freeze, poison | 10 | 46 | 2 | acosf16, acospif16, asinf16, asinhf16, cosf16, cospif16, f16divf, f16fmaf, f16mulf, f16sqrtf, fmaf16, ldexpf16, llrintf, llrintf16, lrintf, lrintf16, nearbyintf, nearbyintf16, rintf, rintf16, scalblnf16, scalbnf16, sinf16, sinpif16, sqrtf16 | 120 of 193 |
| volatile local variables | 17 | 11 | 7 | acosf, asinpif16, exp2f, f16addf, f16subf, ldexpf, log10f, log1pf, logf, scalblnf, scalbnf | 131 of 193 |
| tables of other shapes | 7 | 18 | 7 | coshf16, erff, erff16, exp10f16, exp10m1f16, exp2f16, exp2m1f16, expf16, expm1f16, log10f16, log10p1f16, log2f16, log2p1f16, logf16, sinhf16, exp, log, sin, cos, log2 | 151 of 193 |
| fdiv | 9 | 10 | 1 | acoshf, atan2f, atan2f16, atanf, atanf16, atanhf, atanhf16, atanpif16, erfcf16, lgammaf, lgammaf16, rsqrtf, rsqrtf16, tanf16, tanhf, tanhf16, tanpif, tanpif16 | 169 of 193 |
| loops | 10 | 6 | 3 | acoshf16, cosf, frexpf, frexpf16, nanf, remainderf, remainderf16, remquof, remquof16, sincosf, sinf, tanf, hypot | 182 of 193 |
| integer division | 3 | 3 | 1 | fmodf, fmodf16, nanf16, powf | 186 of 193 |
| floating-point environment access | 1 | 2 | 0 | cbrtf, cbrtf16, hypotf16 | 189 of 193 |
| vectors | 0 | 0 | 2 | pow, exp2 | 191 of 193 |
| other floating-point types | 1 | 1 | 0 | nexttowardf, nexttowardf16 | 193 of 193 |

### Constructs outside the fragment, per entrypoint

Counts are numbers of instructions. Constructs after the semicolon are in functions the body calls.

- `acosf`: call asin_internal::asin_eval (1), call fputil::ExceptValues::lookup (1), intrinsic llvm.sqrt (1), volatile local variable (1); load from a computed pointer (2), load from a pointer parameter (4), terminator switch (1), type ptr (2)
- `acosf16`: call fputil::DyadicFloat::generic_as (2), call fputil::cast (2), instruction alloca (2), intrinsic llvm.ctlz (2), intrinsic llvm.lifetime.end (2), intrinsic llvm.lifetime.start (2), intrinsic llvm.sqrt (1), load from a computed pointer (2), operand global (1), store to a local variable (10), terminator switch (2), type half (14), type ptr (1); call fputil::DyadicFloat::generic_as (1), instruction alloca (1), instruction freeze (2), intrinsic llvm.ctlz (1), intrinsic llvm.fshl (1), intrinsic llvm.lifetime.end (1), intrinsic llvm.lifetime.start (1), load from a pointer parameter (7), store to a local variable (5), terminator switch (2), terminator unreachable (1), type half (12), type ptr (1)
- `acoshf`: call acoshf_internal::log_eval (2), cast sitofp (1), instruction fdiv (1), intrinsic llvm.sqrt (1), terminator switch (1), volatile local variable (10); cast sitofp (1). Fast-math flags: nnan. Constants read: acoshf_internal::C_LOG, acoshf_internal::LOG_R, acoshf_internal::R_LOG
- `acoshf16`: call fputil::DyadicFloat::generic_as (1), call fputil::cast (1), call fputil::sqrt (1), cast sitofp (1), instruction alloca (1), intrinsic llvm.ctlz (1), intrinsic llvm.lifetime.end (1), intrinsic llvm.lifetime.start (1), intrinsic llvm.sqrt (1), load from a computed pointer (2), operand global (1), store to a local variable (5), terminator switch (2), type half (13), type ptr (1); call fputil::DyadicFloat::fast_as (1), call fputil::DyadicFloat::generic_as (1), cast uitofp (2), instruction alloca (2), instruction freeze (3), intrinsic llvm.assume (1), intrinsic llvm.ctlz (3), intrinsic llvm.fshl (1), intrinsic llvm.fshr (1), intrinsic llvm.lifetime.end (2), intrinsic llvm.lifetime.start (2), load from a pointer parameter (12), loop (1), store to a local variable (10), terminator switch (2), terminator unreachable (1), type half (12), type ptr (2), volatile local variable (1). Fast-math flags: nnan. Constants read: acoshf_internal::C_LOG, acoshf_internal::LOG_R, acoshf_internal::R_LOG
- `acospif`: call asin_internal::asinpi_eval (1), intrinsic llvm.sqrt (1). Fast-math flags: ninf
- `acospif16`: call fputil::DyadicFloat::generic_as (2), call fputil::cast (2), instruction alloca (2), intrinsic llvm.ctlz (2), intrinsic llvm.lifetime.end (2), intrinsic llvm.lifetime.start (2), intrinsic llvm.sqrt (1), store to a local variable (10), type half (13); call fputil::DyadicFloat::generic_as (1), instruction alloca (1), instruction freeze (2), intrinsic llvm.ctlz (1), intrinsic llvm.fshl (1), intrinsic llvm.lifetime.end (1), intrinsic llvm.lifetime.start (1), load from a pointer parameter (7), store to a local variable (5), terminator switch (2), terminator unreachable (1), type half (12), type ptr (1)
- `asinf`: intrinsic llvm.sqrt (1). Constants read: __const._ZN11__llvm_libc4math5asinfEf.TWO
- `asinf16`: call fputil::DyadicFloat::generic_as (2), call fputil::cast (1), instruction alloca (2), intrinsic llvm.ctlz (2), intrinsic llvm.lifetime.end (2), intrinsic llvm.lifetime.start (2), intrinsic llvm.sqrt (1), store to a local variable (10), type half (13); call fputil::DyadicFloat::generic_as (1), instruction alloca (1), instruction freeze (2), intrinsic llvm.ctlz (1), intrinsic llvm.fshl (1), intrinsic llvm.lifetime.end (1), intrinsic llvm.lifetime.start (1), load from a pointer parameter (7), store to a local variable (5), terminator switch (2), terminator unreachable (1), type half (12), type ptr (1)
- `asinhf`: call acoshf_internal::log_eval (1), cast sitofp (1), intrinsic llvm.sqrt (1), terminator switch (2); cast sitofp (1). Fast-math flags: nnan. Constants read: __const._ZN11__llvm_libc4math6asinhfEf.SIGN, acoshf_internal::C_LOG, acoshf_internal::LOG_R, acoshf_internal::R_LOG
- `asinhf16`: call fputil::DyadicFloat::generic_as (1), call fputil::cast (4), cast sitofp (1), instruction alloca (1), intrinsic llvm.ctlz (1), intrinsic llvm.lifetime.end (1), intrinsic llvm.lifetime.start (1), intrinsic llvm.sqrt (1), load from a computed pointer (2), operand global (1), store to a local variable (5), terminator switch (2), type half (13), type ptr (1); call fputil::DyadicFloat::generic_as (1), instruction alloca (1), instruction freeze (4), intrinsic llvm.assume (1), intrinsic llvm.ctlz (1), intrinsic llvm.fshl (2), intrinsic llvm.fshr (1), intrinsic llvm.lifetime.end (1), intrinsic llvm.lifetime.start (1), load from a pointer parameter (14), store to a local variable (5), terminator switch (4), terminator unreachable (2), type half (20), type ptr (2). Fast-math flags: nnan. Constants read: __const._ZN11__llvm_libc4math8asinhf16EDF16_.SIGN, acoshf_internal::C_LOG, acoshf_internal::LOG_R, acoshf_internal::R_LOG
- `asinpif`: call asin_internal::asinpi_eval (1), intrinsic llvm.sqrt (1). Fast-math flags: ninf
- `asinpif16`: call fputil::DyadicFloat::fast_as (1), call fputil::DyadicFloat::generic_as (1), call fputil::cast (2), instruction alloca (2), intrinsic llvm.ctlz (2), intrinsic llvm.lifetime.end (2), intrinsic llvm.lifetime.start (2), intrinsic llvm.sqrt (1), store to a local variable (10), type half (10); call fputil::DyadicFloat::fast_as (1), call fputil::DyadicFloat::generic_as (1), cast uitofp (2), instruction alloca (2), instruction freeze (2), intrinsic llvm.assume (2), intrinsic llvm.ctlz (2), intrinsic llvm.fshl (1), intrinsic llvm.fshr (2), intrinsic llvm.lifetime.end (2), intrinsic llvm.lifetime.start (2), load from a pointer parameter (12), store to a local variable (10), terminator switch (2), terminator unreachable (1), type half (18), type ptr (2), volatile local variable (1). Fast-math flags: nnan
- `atan2f`: call math::atan2f_internal::atan2f_double_double (1), instruction alloca (1), instruction fdiv (1), intrinsic llvm.lifetime.end (1), intrinsic llvm.lifetime.start (1), intrinsic llvm.memcpy.p0.p0 (1), intrinsic llvm.umax (1), intrinsic llvm.umin (1), load from a constant not in table form (10), load from a local variable (1), operand global (1), type ptr (1); instruction fdiv (2), load from a constant not in table form (2), load from a pointer parameter (2), type ptr (1). Constants read: __const._ZN11__llvm_libc4math6atan2fEff.EXCEPTS (not in table form), atan_internal::ATAN_COEFFS (not in table form), math::atan2f_internal::ATAN_I (not in table form)
- `atan2f16`: call fputil::DyadicFloat::generic_as (1), call fputil::cast (1), instruction alloca (1), instruction fdiv (1), intrinsic llvm.ctlz (1), intrinsic llvm.lifetime.end (1), intrinsic llvm.lifetime.start (1), intrinsic llvm.umax (1), intrinsic llvm.umin (1), load from a computed pointer (1), load from a constant not in table form (9), operand global (1), store to a local variable (5), type half (15), type ptr (1); call fputil::DyadicFloat::generic_as (1), instruction alloca (1), instruction freeze (2), intrinsic llvm.assume (1), intrinsic llvm.ctlz (1), intrinsic llvm.fshl (1), intrinsic llvm.fshr (1), intrinsic llvm.lifetime.end (1), intrinsic llvm.lifetime.start (1), load from a pointer parameter (7), store to a local variable (5), terminator switch (2), terminator unreachable (1), type half (12), type ptr (1). Constants read: __const._ZN11__llvm_libc4math8atan2f16EDF16_DF16_.EXCEPTS (not in table form), __const._ZN11__llvm_libc4math8atan2f16EDF16_DF16_.IS_NEG, atan_internal::ATAN_COEFFS (not in table form), atan_internal::ATAN_K_OVER_16
- `atanf`: instruction fdiv (2), load from a constant not in table form (10), volatile local variable (3). Fast-math flags: nnan. Constants read: atan_internal::ATAN_COEFFS (not in table form)
- `atanf16`: call fputil::DyadicFloat::generic_as (2), call fputil::cast (1), instruction alloca (2), instruction fdiv (1), intrinsic llvm.ctlz (2), intrinsic llvm.lifetime.end (2), intrinsic llvm.lifetime.start (2), intrinsic llvm.sqrt (1), load from a computed pointer (2), operand global (1), store to a local variable (10), terminator switch (2), type half (15), type ptr (1); call fputil::DyadicFloat::generic_as (1), instruction alloca (1), instruction freeze (2), intrinsic llvm.ctlz (1), intrinsic llvm.fshl (1), intrinsic llvm.lifetime.end (1), intrinsic llvm.lifetime.start (1), load from a pointer parameter (7), store to a local variable (5), terminator switch (2), terminator unreachable (1), type half (12), type ptr (1). Fast-math flags: nnan
- `atanhf`: cast sitofp (1), instruction fdiv (1), intrinsic llvm.copysign (1). Fast-math flags: nnan. Constants read: acoshf_internal::C_LOG, acoshf_internal::LOG_R, acoshf_internal::R_LOG
- `atanhf16`: call fputil::DyadicFloat::generic_as (1), call fputil::cast (2), cast sitofp (1), instruction alloca (1), instruction fdiv (1), intrinsic llvm.copysign (1), intrinsic llvm.ctlz (1), intrinsic llvm.lifetime.end (1), intrinsic llvm.lifetime.start (1), store to a local variable (5), type half (12); call fputil::DyadicFloat::generic_as (1), instruction alloca (1), instruction freeze (4), intrinsic llvm.assume (1), intrinsic llvm.ctlz (1), intrinsic llvm.fshl (2), intrinsic llvm.fshr (1), intrinsic llvm.lifetime.end (1), intrinsic llvm.lifetime.start (1), load from a pointer parameter (14), store to a local variable (5), terminator switch (4), terminator unreachable (2), type half (20), type ptr (2). Fast-math flags: nnan. Constants read: math::atanhf16_internal::LOG_F_FLOAT, math::atanhf16_internal::ONE_OVER_F_FLOAT
- `atanpif16`: call fputil::DyadicFloat::fast_as (1), call fputil::DyadicFloat::generic_as (1), call math::atanpif16(_Float16)::'lambda'(double)::operator() (4), instruction alloca (3), instruction fdiv (3), intrinsic llvm.ctlz (2), intrinsic llvm.lifetime.end (3), intrinsic llvm.lifetime.start (3), intrinsic llvm.sqrt (2), load from a local variable (1), store to a local variable (11), type half (10); call fputil::DyadicFloat::generic_as (1), cast uitofp (2), instruction alloca (1), instruction freeze (2), intrinsic llvm.assume (2), intrinsic llvm.ctlz (1), intrinsic llvm.fshl (1), intrinsic llvm.fshr (2), intrinsic llvm.lifetime.end (1), intrinsic llvm.lifetime.start (1), load from a pointer parameter (13), store to a local variable (5), terminator switch (2), terminator unreachable (1), type half (12), type ptr (3), volatile local variable (1). Fast-math flags: nnan
- `canonicalizef`: load from a pointer parameter (1), store to a pointer parameter (2), type ptr (1)
- `canonicalizef16`: load from a pointer parameter (1), store to a pointer parameter (2), type half (5), type ptr (1)
- `cbrtf`: inline assembly (2), instruction alloca (3), instruction udiv (1), instruction urem (1), intrinsic llvm.lifetime.end (3), intrinsic llvm.lifetime.start (3), intrinsic llvm.x86.sse.ldmxcsr (1), intrinsic llvm.x86.sse.stmxcsr (1), load from a constant not in table form (7), load from a local variable (2), store to a local variable (2). Constants read: math::cbrtf_internal::CBRT2, math::cbrtf_internal::COEFFS (not in table form)
- `cbrtf16`: call fputil::DyadicFloat::generic_as (1), inline assembly (2), instruction alloca (6), instruction udiv (1), instruction urem (1), intrinsic llvm.ctlz (1), intrinsic llvm.lifetime.end (6), intrinsic llvm.lifetime.start (6), intrinsic llvm.x86.sse.ldmxcsr (2), intrinsic llvm.x86.sse.stmxcsr (2), load from a constant not in table form (5), load from a local variable (3), store to a local variable (8), type half (10); instruction freeze (2), intrinsic llvm.fshl (1), load from a pointer parameter (7), terminator switch (2), terminator unreachable (1), type half (8), type ptr (1). Constants read: __const._ZN11__llvm_libc4math7cbrtf16EDF16_.CBRT2, __const._ZN11__llvm_libc4math7cbrtf16EDF16_.COEFFS (not in table form)
- `ceilf16`: type half (9)
- `copysignf16`: type half (6)
- `cosf`: call math::trigonometric_func_utils_internal::large_range_reduction (1), instruction alloca (1), intrinsic llvm.lifetime.end (1), intrinsic llvm.lifetime.start (1), load from a computed pointer (2), load from a local variable (1), operand global (1), terminator switch (2), type ptr (1); loop (1), store to a pointer parameter (1), type ptr (1). Fast-math flags: ninf nnan. Constants read: math::sincosf_utils_internal::SIN_K_PI_OVER_32, math::trigonometric_func_utils_internal::THIRTYTWO_OVER_PI_28, math::trigonometric_func_utils_internal::THIRTYTWO_OVER_PI_28_LSB_EXP
- `cosf16`: call fputil::DyadicFloat::generic_as (1), call fputil::cast (1), instruction alloca (1), intrinsic llvm.ctlz (1), intrinsic llvm.lifetime.end (1), intrinsic llvm.lifetime.start (1), load from a computed pointer (2), operand global (1), store to a local variable (5), terminator switch (2), type half (11), type ptr (1); call fputil::DyadicFloat::generic_as (1), instruction alloca (1), instruction freeze (2), intrinsic llvm.ctlz (1), intrinsic llvm.fshl (1), intrinsic llvm.lifetime.end (1), intrinsic llvm.lifetime.start (1), load from a pointer parameter (7), store to a local variable (5), terminator switch (2), terminator unreachable (1), type half (12), type ptr (1). Constants read: math::sincosf16_internal::SIN_K_PI_OVER_32
- `coshf`: cast sitofp (1). Fast-math flags: nnan. Constants read: ExpBase::EXP_2_MID
- `coshf16`: call math::expxf16_internal::eval_sinh_or_cosh (1), load from a computed pointer (4), operand global (2), terminator switch (5), type half (9), type ptr (2); call fputil::DyadicFloat::generic_as (1), instruction alloca (1), instruction freeze (2), intrinsic llvm.ctlz (1), intrinsic llvm.fshl (1), intrinsic llvm.lifetime.end (1), intrinsic llvm.lifetime.start (1), load from a constant not in table form (2), load from a pointer parameter (7), store to a local variable (5), terminator switch (2), terminator unreachable (1), type half (14), type ptr (1). Constants read: math::expxf16_internal::EXP2_MID_5_BITS (not in table form)
- `cospif`: Fast-math flags: nnan. Constants read: math::sincosf_utils_internal::SIN_K_PI_OVER_32
- `cospif16`: call fputil::DyadicFloat::generic_as (1), call fputil::cast (4), instruction alloca (1), intrinsic llvm.ctlz (1), intrinsic llvm.lifetime.end (1), intrinsic llvm.lifetime.start (1), store to a local variable (5), type half (10); call fputil::DyadicFloat::generic_as (1), instruction alloca (1), instruction freeze (2), intrinsic llvm.ctlz (1), intrinsic llvm.fshl (1), intrinsic llvm.lifetime.end (1), intrinsic llvm.lifetime.start (1), load from a pointer parameter (7), store to a local variable (5), terminator switch (2), terminator unreachable (1), type half (12), type ptr (1). Constants read: math::sincosf16_internal::SIN_K_PI_OVER_32
- `erfcf16`: call fputil::DyadicFloat::fast_as (1), call fputil::DyadicFloat::generic_as (2), call fputil::cast (5), instruction alloca (3), instruction fdiv (1), intrinsic llvm.ctlz (3), intrinsic llvm.lifetime.end (3), intrinsic llvm.lifetime.start (3), load from a computed pointer (2), load from a constant not in table form (8), operand global (1), store to a local variable (15), terminator switch (2), type half (16), type ptr (1); call fputil::DyadicFloat::fast_as (1), call fputil::DyadicFloat::generic_as (2), cast uitofp (4), instruction alloca (3), instruction freeze (4), intrinsic llvm.assume (2), intrinsic llvm.ctlz (3), intrinsic llvm.fshl (2), intrinsic llvm.fshr (2), intrinsic llvm.lifetime.end (3), intrinsic llvm.lifetime.start (3), load from a pointer parameter (24), store to a local variable (15), terminator switch (4), terminator unreachable (2), type half (30), type ptr (4), volatile local variable (2). Fast-math flags: nnan. Constants read: __const._ZN11__llvm_libc4math7erfcf16EDF16_.COEFFS (not in table form)
- `erff`: load from a constant not in table form (8), terminator switch (1), volatile local variable (4). Constants read: __const._ZN11__llvm_libc4math4erffEf.ONE, __const._ZN11__llvm_libc4math4erffEf.SMALL, math::erff_internal::COEFFS (not in table form)
- `erff16`: call fputil::DyadicFloat::generic_as (1), call fputil::cast (3), instruction alloca (1), intrinsic llvm.ctlz (1), intrinsic llvm.lifetime.end (1), intrinsic llvm.lifetime.start (1), load from a computed pointer (2), load from a constant not in table form (8), operand global (1), store to a local variable (5), terminator switch (2), type half (16), type ptr (1); call fputil::DyadicFloat::generic_as (1), instruction alloca (1), instruction freeze (2), intrinsic llvm.ctlz (1), intrinsic llvm.fshl (1), intrinsic llvm.lifetime.end (1), intrinsic llvm.lifetime.start (1), load from a pointer parameter (7), store to a local variable (5), terminator switch (2), terminator unreachable (1), type half (12), type ptr (1). Constants read: __const._ZN11__llvm_libc4math6erff16EDF16_.ERFF16_COEFFS (not in table form)
- `exp10f`: call math::double_eval::exp10f_slow (1); terminator switch (1). Constants read: ExpBase::EXP_2_MID
- `exp10f16`: call fputil::DyadicFloat::generic_as (1), call fputil::cast (4), instruction alloca (1), intrinsic llvm.ctlz (1), intrinsic llvm.lifetime.end (1), intrinsic llvm.lifetime.start (1), load from a computed pointer (2), load from a constant not in table form (1), operand global (1), store to a local variable (5), terminator switch (4), type half (12), type ptr (1); call fputil::DyadicFloat::generic_as (1), instruction alloca (1), instruction freeze (4), intrinsic llvm.assume (1), intrinsic llvm.ctlz (1), intrinsic llvm.fshl (2), intrinsic llvm.fshr (1), intrinsic llvm.lifetime.end (1), intrinsic llvm.lifetime.start (1), load from a pointer parameter (14), store to a local variable (5), terminator switch (4), terminator unreachable (2), type half (20), type ptr (2). Constants read: EXP2_MID_BITS (not in table form)
- `exp10m1f`: call fputil::ExceptValues::lookup (2), terminator switch (1); load from a computed pointer (4), load from a pointer parameter (30), terminator switch (2), type ptr (4). Constants read: ExpBase::EXP_2_MID
- `exp10m1f16`: call fputil::DyadicFloat::generic_as (1), call fputil::ExceptValues::lookup (1), call fputil::cast (6), call fputil::round_result_slightly_down (1), instruction alloca (2), intrinsic llvm.ctlz (1), intrinsic llvm.lifetime.end (2), intrinsic llvm.lifetime.start (2), intrinsic llvm.memcpy.p0.p0 (1), load from a computed pointer (2), load from a constant not in table form (1), operand global (1), store to a local variable (5), terminator switch (5), type half (13), type ptr (1); call fputil::DyadicFloat::generic_as (3), instruction alloca (3), instruction freeze (4), intrinsic llvm.assume (1), intrinsic llvm.ctlz (3), intrinsic llvm.fshl (2), intrinsic llvm.fshr (1), intrinsic llvm.lifetime.end (3), intrinsic llvm.lifetime.start (3), load from a computed pointer (2), load from a pointer parameter (17), store to a local variable (15), terminator switch (5), terminator unreachable (2), type half (30), type ptr (4), volatile local variable (1). Constants read: EXP2_MID_BITS (not in table form)
- `exp2f`: call math::double_eval::exp2f(float)::'lambda'()::operator() (1), cast sitofp (1), instruction alloca (2), intrinsic llvm.lifetime.end (1), intrinsic llvm.lifetime.start (1), load from a local variable (2), store to a local variable (2), terminator switch (1), volatile local variable (2); cast sitofp (1), load from a computed pointer (1), load from a pointer parameter (1), type ptr (1). Fast-math flags: nnan. Constants read: ExpBase::EXP_2_MID
- `exp2f16`: call fputil::DyadicFloat::generic_as (1), instruction alloca (1), intrinsic llvm.ctlz (1), intrinsic llvm.lifetime.end (1), intrinsic llvm.lifetime.start (1), load from a computed pointer (2), load from a constant not in table form (1), operand global (1), store to a local variable (5), terminator switch (3), type half (12), type ptr (1); instruction freeze (2), intrinsic llvm.fshl (1), load from a pointer parameter (7), terminator switch (2), terminator unreachable (1), type half (8), type ptr (1). Constants read: EXP2_MID_BITS (not in table form)
- `exp2m1f`: call fputil::ExceptValues::lookup (1), cast sitofp (1), instruction alloca (1), intrinsic llvm.lifetime.end (1), intrinsic llvm.lifetime.start (1), intrinsic llvm.memcpy.p0.p0 (1), load from a computed pointer (2), operand global (1), terminator switch (2), type ptr (1); load from a computed pointer (2), load from a pointer parameter (8), terminator switch (1), type ptr (2). Fast-math flags: nnan. Constants read: ExpBase::EXP_2_MID
- `exp2m1f16`: call fputil::DyadicFloat::generic_as (1), call fputil::ExceptValues::lookup (1), call fputil::cast (3), call fputil::round_result_slightly_down (1), instruction alloca (2), intrinsic llvm.ctlz (1), intrinsic llvm.lifetime.end (2), intrinsic llvm.lifetime.start (2), intrinsic llvm.memcpy.p0.p0 (1), load from a computed pointer (2), load from a constant not in table form (1), operand global (1), store to a local variable (5), terminator switch (4), type half (13), type ptr (1); call fputil::DyadicFloat::generic_as (3), instruction alloca (3), instruction freeze (4), intrinsic llvm.assume (1), intrinsic llvm.ctlz (3), intrinsic llvm.fshl (2), intrinsic llvm.fshr (1), intrinsic llvm.lifetime.end (3), intrinsic llvm.lifetime.start (3), load from a computed pointer (2), load from a pointer parameter (20), store to a local variable (15), terminator switch (5), terminator unreachable (2), type half (30), type ptr (4), volatile local variable (1). Constants read: EXP2_MID_BITS (not in table form)
- `expf`: Constants read: math::EXP_M1, math::EXP_M2
- `expf16`: call fputil::DyadicFloat::generic_as (1), call fputil::ExceptValues::lookup (1), call fputil::cast (1), instruction alloca (2), intrinsic llvm.ctlz (1), intrinsic llvm.lifetime.end (2), intrinsic llvm.lifetime.start (2), intrinsic llvm.memcpy.p0.p0 (1), load from a computed pointer (2), load from a constant not in table form (2), operand global (1), store to a local variable (5), terminator switch (3), type half (14), type ptr (1); call fputil::DyadicFloat::generic_as (1), instruction alloca (1), instruction freeze (2), intrinsic llvm.ctlz (1), intrinsic llvm.fshl (1), intrinsic llvm.lifetime.end (1), intrinsic llvm.lifetime.start (1), load from a computed pointer (2), load from a pointer parameter (9), store to a local variable (5), terminator switch (3), terminator unreachable (1), type half (12), type ptr (3). Constants read: EXP_HI (not in table form), EXP_MID (not in table form)
- `expm1f`: terminator switch (1). Constants read: common_constants_internal::EXP_M1, common_constants_internal::EXP_M2
- `expm1f16`: call fputil::DyadicFloat::generic_as (1), call fputil::ExceptValues::lookup (1), call fputil::cast (2), call fputil::round_result_slightly_down (1), call fputil::round_result_slightly_up (1), instruction alloca (2), intrinsic llvm.ctlz (1), intrinsic llvm.lifetime.end (2), intrinsic llvm.lifetime.start (2), intrinsic llvm.memcpy.p0.p0 (1), load from a computed pointer (2), load from a constant not in table form (2), operand global (1), store to a local variable (5), terminator switch (3), type half (13), type ptr (1); call fputil::DyadicFloat::generic_as (4), instruction alloca (4), instruction freeze (5), intrinsic llvm.assume (1), intrinsic llvm.ctlz (4), intrinsic llvm.fshl (2), intrinsic llvm.fshr (1), intrinsic llvm.lifetime.end (4), intrinsic llvm.lifetime.start (4), load from a pointer parameter (17), store to a local variable (20), terminator switch (5), terminator unreachable (2), type half (36), type ptr (3), volatile local variable (2). Constants read: EXP_HI (not in table form), EXP_MID (not in table form)
- `f16addf`: call fputil::DyadicFloat::generic_as (1), call fputil::cast (2), instruction alloca (1), instruction freeze (1), intrinsic llvm.ctlz (1), intrinsic llvm.is.fpclass (1), intrinsic llvm.lifetime.end (1), intrinsic llvm.lifetime.start (1), intrinsic llvm.smin (1), store to a local variable (5), type half (10), volatile local variable (1); call fputil::DyadicFloat::generic_as (1), instruction alloca (1), instruction freeze (2), intrinsic llvm.ctlz (1), intrinsic llvm.fshl (1), intrinsic llvm.lifetime.end (1), intrinsic llvm.lifetime.start (1), load from a pointer parameter (7), store to a local variable (5), terminator switch (2), terminator unreachable (1), type half (12), type ptr (1)
- `f16divf`: call fputil::DyadicFloat::generic_as (1), instruction alloca (1), instruction freeze (13), intrinsic llvm.ctlz (3), intrinsic llvm.lifetime.end (1), intrinsic llvm.lifetime.start (1), store to a local variable (4), terminator switch (1), type half (8); instruction freeze (2), intrinsic llvm.fshl (1), load from a pointer parameter (7), terminator switch (2), terminator unreachable (1), type half (8), type ptr (1)
- `f16fmaf`: call fputil::DyadicFloat::generic_as (1), call fputil::cast (3), instruction alloca (1), instruction freeze (3), intrinsic llvm.assume (2), intrinsic llvm.ctlz (1), intrinsic llvm.fshr (2), intrinsic llvm.lifetime.end (1), intrinsic llvm.lifetime.start (2), store to a computed pointer (1), store to a local variable (4), type half (5), type ptr (1); call fputil::DyadicFloat::generic_as (1), instruction alloca (1), instruction freeze (4), intrinsic llvm.assume (1), intrinsic llvm.ctlz (1), intrinsic llvm.fshl (2), intrinsic llvm.fshr (1), intrinsic llvm.lifetime.end (1), intrinsic llvm.lifetime.start (1), load from a pointer parameter (14), store to a local variable (5), terminator switch (4), terminator unreachable (2), type half (20), type ptr (2)
- `f16mulf`: call fputil::DyadicFloat::generic_as (1), instruction alloca (1), intrinsic llvm.ctlz (2), intrinsic llvm.lifetime.end (1), intrinsic llvm.lifetime.start (1), store to a local variable (2), type half (7); instruction freeze (2), intrinsic llvm.assume (1), intrinsic llvm.fshl (1), intrinsic llvm.fshr (1), load from a pointer parameter (7), terminator switch (2), terminator unreachable (1), type half (8), type ptr (1)
- `f16sqrtf`: call fputil::DyadicFloat::generic_as (2), instruction alloca (2), instruction freeze (1), intrinsic llvm.ctlz (3), intrinsic llvm.lifetime.end (2), intrinsic llvm.lifetime.start (2), store to a local variable (10), type half (4); instruction freeze (2), intrinsic llvm.fshl (1), load from a pointer parameter (7), terminator switch (2), terminator unreachable (1), type half (8), type ptr (1)
- `f16subf`: call fputil::DyadicFloat::generic_as (1), call fputil::cast (2), instruction alloca (1), instruction freeze (1), intrinsic llvm.ctlz (1), intrinsic llvm.is.fpclass (1), intrinsic llvm.lifetime.end (1), intrinsic llvm.lifetime.start (1), intrinsic llvm.smin (1), store to a local variable (5), type half (10), volatile local variable (1); call fputil::DyadicFloat::generic_as (1), instruction alloca (1), instruction freeze (2), intrinsic llvm.ctlz (1), intrinsic llvm.fshl (1), intrinsic llvm.lifetime.end (1), intrinsic llvm.lifetime.start (1), load from a pointer parameter (7), store to a local variable (5), terminator switch (2), terminator unreachable (1), type half (12), type ptr (1)
- `fabsf16`: type half (4)
- `fdimf16`: type half (12)
- `floorf16`: type half (12)
- `fmaf16`: call fputil::DyadicFloat::generic_as (1), instruction alloca (1), instruction freeze (3), intrinsic llvm.assume (2), intrinsic llvm.ctlz (1), intrinsic llvm.lifetime.end (1), intrinsic llvm.lifetime.start (2), store to a computed pointer (1), store to a local variable (4), type half (53), type ptr (1); instruction freeze (2), intrinsic llvm.fshl (1), load from a pointer parameter (7), terminator switch (2), terminator unreachable (1), type half (8), type ptr (1)
- `fmaxf16`: type half (12)
- `fmaximum_mag_numf16`: type half (18)
- `fmaximum_magf16`: type half (14)
- `fmaximum_numf16`: type half (18)
- `fmaximumf16`: type half (12)
- `fminf16`: type half (12)
- `fminimum_mag_numf16`: type half (18)
- `fminimum_magf16`: type half (14)
- `fminimum_numf16`: type half (18)
- `fminimumf16`: type half (12)
- `fmodf`: call fputil::generic::FMod::eval_internal (1), intrinsic llvm.copysign (1); instruction urem (5), intrinsic llvm.ctlz (4), intrinsic llvm.cttz (1), intrinsic llvm.smin (2), loop (1)
- `fmodf16`: call fputil::generic::FMod::eval_internal (1), intrinsic llvm.copysign (1), type half (19); call fputil::internal::FPRepImpl::make_value (3), instruction urem (5), intrinsic llvm.ctlz (2), intrinsic llvm.cttz (1), intrinsic llvm.smin (2), loop (1)
- `frexpf`: loop (1), store to a pointer parameter (2), type ptr (1)
- `frexpf16`: loop (1), store to a pointer parameter (2), type half (6), type ptr (1)
- `fromfpf`: call fputil::round_using_specific_rounding_mode (1); terminator switch (2)
- `fromfpf16`: call fputil::round_using_specific_rounding_mode (1), type half (11); terminator switch (2), type half (24)
- `fromfpxf`: call fputil::round_using_specific_rounding_mode (1); terminator switch (2)
- `fromfpxf16`: call fputil::round_using_specific_rounding_mode (1), type half (15); terminator switch (2), type half (24)
- `getpayloadf`: cast uitofp (1), load from a pointer parameter (1), type ptr (1)
- `getpayloadf16`: cast uitofp (1), load from a pointer parameter (1), type half (8), type ptr (1)
- `hypotf`: intrinsic llvm.sqrt (1)
- `hypotf16`: call fputil::DyadicFloat::fast_as (2), call fputil::DyadicFloat::generic_as (1), call fputil::cast (2), inline assembly (2), instruction alloca (6), intrinsic llvm.ctlz (3), intrinsic llvm.lifetime.end (6), intrinsic llvm.lifetime.start (6), intrinsic llvm.sqrt (1), intrinsic llvm.umax (1), intrinsic llvm.umin (1), intrinsic llvm.x86.sse.ldmxcsr (1), intrinsic llvm.x86.sse.stmxcsr (1), load from a local variable (2), store to a local variable (17), type half (13); call fputil::DyadicFloat::generic_as (1), cast uitofp (2), instruction alloca (1), instruction freeze (2), intrinsic llvm.ctlz (1), intrinsic llvm.fshl (1), intrinsic llvm.lifetime.end (1), intrinsic llvm.lifetime.start (1), load from a pointer parameter (12), store to a local variable (5), terminator switch (2), terminator unreachable (1), type half (12), type ptr (2), volatile local variable (1). Fast-math flags: nnan
- `ilogbf`: intrinsic llvm.ctlz (1)
- `iscanonicalf16`: type half (5)
- `isnanf16`: type half (4)
- `issignalingf16`: type half (5)
- `ldexpf`: call fputil::DyadicFloat::fast_as (1), instruction alloca (1), intrinsic llvm.copysign (3), intrinsic llvm.ctlz (1), intrinsic llvm.lifetime.end (1), intrinsic llvm.lifetime.start (1), store to a local variable (3); cast uitofp (2), load from a pointer parameter (5), type ptr (1), volatile local variable (1). Fast-math flags: nnan
- `ldexpf16`: call fputil::DyadicFloat::generic_as (1), instruction alloca (1), intrinsic llvm.copysign (3), intrinsic llvm.ctlz (1), intrinsic llvm.lifetime.end (1), intrinsic llvm.lifetime.start (1), store to a local variable (3), type half (6); instruction freeze (2), intrinsic llvm.assume (2), intrinsic llvm.fshl (1), load from a pointer parameter (7), terminator switch (2), terminator unreachable (1), type half (8), type ptr (1)
- `lgammaf`: call fputil::ExceptValues::lookup (4), call fputil::floor (1), call math::gamma_internal::lg_ln (2), call math::gamma_internal::lg_sinpi (1), call math::log (3), cast sitofp (3), instruction alloca (4), instruction fdiv (1), intrinsic llvm.cttz (1), intrinsic llvm.lifetime.end (7), intrinsic llvm.lifetime.start (4), intrinsic llvm.memcpy.p0.p0 (4), load from a computed pointer (2), operand global (1), terminator switch (3), type ptr (1), volatile local variable (1); call fputil::DyadicFloat::fast_as (1), call math::log_internal::log_accurate (1), call math::log_range_reduction_internal::log_range_reduction (1), cast sitofp (3), cast uitofp (2), instruction alloca (8), instruction extractvalue (104), intrinsic llvm.ctlz (21), intrinsic llvm.lifetime.end (8), intrinsic llvm.lifetime.start (9), intrinsic llvm.memcpy.p0.p0 (16), intrinsic llvm.memset.p0 (1), intrinsic llvm.uadd.with.overflow (41), intrinsic llvm.usub.with.overflow (17), load from a computed pointer (8), load from a constant not in table form (6), load from a local variable (6), load from a pointer parameter (33), ret void (1), store to a computed pointer (4), store to a local variable (20), store to a pointer parameter (26), terminator switch (3), type aggregate (9), type ptr (12), volatile local variable (1). Fast-math flags: nnan. Constants read: __const._ZN11__llvm_libc4math14gamma_internal5lg_lnEd.IL, __const._ZN11__llvm_libc4math14gamma_internal5lg_lnEd.IX, common_constants_internal::CD, common_constants_internal::LOG_R_DD (not in table form), common_constants_internal::RD, common_constants_internal::S2, common_constants_internal::S3, common_constants_internal::S4, math::log_internal::LOG_TABLE (not in table form)
- `lgammaf16`: call fputil::DyadicFloat::fast_as (1), call fputil::DyadicFloat::generic_as (1), call math::gamma_internal::lg_ln (2), call math::gamma_internal::lg_sinpi (1), cast sitofp (3), instruction alloca (2), instruction fdiv (3), intrinsic llvm.ctlz (2), intrinsic llvm.cttz (1), intrinsic llvm.lifetime.end (2), intrinsic llvm.lifetime.start (2), store to a local variable (10), terminator switch (1), type half (14); cast sitofp (1), cast uitofp (2), instruction freeze (2), intrinsic llvm.assume (2), intrinsic llvm.fshl (1), intrinsic llvm.fshr (2), load from a pointer parameter (12), terminator switch (2), terminator unreachable (1), type half (8), type ptr (2), volatile local variable (1). Fast-math flags: nnan. Constants read: __const._ZN11__llvm_libc4math14gamma_internal5lg_lnEd.IL, __const._ZN11__llvm_libc4math14gamma_internal5lg_lnEd.IX
- `llogbf`: intrinsic llvm.ctlz (1)
- `llrintf`: call fputil::round_using_current_rounding_mode (1); intrinsic llvm.copysign (1), intrinsic llvm.fshl (1), terminator switch (1), terminator unreachable (1)
- `llrintf16`: call fputil::round_using_current_rounding_mode (1), type half (3); intrinsic llvm.copysign (1), intrinsic llvm.fshl (1), terminator switch (1), terminator unreachable (1), type half (23)
- `llroundf`: intrinsic llvm.copysign (1)
- `llroundf16`: intrinsic llvm.copysign (1), type half (7)
- `log10f`: cast sitofp (1), terminator switch (2), volatile local variable (8). Fast-math flags: ninf nnan. Constants read: common_constants_internal::R, math::log10f_internal::LOG10_R
- `log10f16`: call fputil::DyadicFloat::generic_as (2), cast sitofp (1), instruction alloca (2), intrinsic llvm.ctlz (1), intrinsic llvm.lifetime.end (2), intrinsic llvm.lifetime.start (2), load from a computed pointer (2), load from a constant not in table form (2), operand global (1), store to a local variable (8), terminator switch (3), type half (15), type ptr (1); instruction freeze (2), intrinsic llvm.fshl (1), load from a pointer parameter (7), terminator switch (2), terminator unreachable (1), type half (8), type ptr (1). Fast-math flags: ninf nnan. Constants read: math::expxf16_internal::LOG10F_F (not in table form), math::expxf16_internal::ONE_OVER_F_F (not in table form)
- `log10p1f16`: call fputil::DyadicFloat::generic_as (1), call fputil::ExceptValues::lookup (1), call fputil::cast (1), cast sitofp (1), instruction alloca (2), intrinsic llvm.ctlz (1), intrinsic llvm.lifetime.end (2), intrinsic llvm.lifetime.start (2), intrinsic llvm.memcpy.p0.p0 (1), load from a computed pointer (2), load from a constant not in table form (2), operand global (1), store to a local variable (5), terminator switch (2), type half (14), type ptr (1); call fputil::DyadicFloat::generic_as (1), instruction alloca (1), instruction freeze (2), intrinsic llvm.ctlz (1), intrinsic llvm.fshl (1), intrinsic llvm.lifetime.end (1), intrinsic llvm.lifetime.start (1), load from a computed pointer (2), load from a pointer parameter (14), store to a local variable (5), terminator switch (3), terminator unreachable (1), type half (12), type ptr (3). Fast-math flags: nnan. Constants read: math::expxf16_internal::LOG10F_F (not in table form), math::expxf16_internal::ONE_OVER_F_F (not in table form)
- `log1pf`: cast sitofp (1), terminator switch (2), volatile local variable (15). Fast-math flags: nnan. Constants read: acoshf_internal::C_LOG, acoshf_internal::LOG_R, acoshf_internal::R_LOG
- `log2f`: cast sitofp (2). Fast-math flags: ninf nnan. Constants read: common_constants_internal::LOG2_R, common_constants_internal::RD
- `log2f16`: call fputil::DyadicFloat::generic_as (2), cast sitofp (1), instruction alloca (2), intrinsic llvm.ctlz (1), intrinsic llvm.lifetime.end (2), intrinsic llvm.lifetime.start (2), load from a computed pointer (2), load from a constant not in table form (2), operand global (1), store to a local variable (8), terminator switch (3), type half (15), type ptr (1); instruction freeze (2), intrinsic llvm.fshl (1), load from a pointer parameter (7), terminator switch (2), terminator unreachable (1), type half (8), type ptr (1). Fast-math flags: ninf nnan. Constants read: math::expxf16_internal::LOG2F_F (not in table form), math::expxf16_internal::ONE_OVER_F_F (not in table form)
- `log2p1f16`: call fputil::DyadicFloat::generic_as (1), call fputil::ExceptValues::lookup (1), call fputil::cast (1), cast sitofp (1), instruction alloca (2), intrinsic llvm.ctlz (1), intrinsic llvm.lifetime.end (2), intrinsic llvm.lifetime.start (2), intrinsic llvm.memcpy.p0.p0 (1), load from a computed pointer (2), load from a constant not in table form (2), operand global (1), store to a local variable (5), terminator switch (2), type half (14), type ptr (1); call fputil::DyadicFloat::generic_as (1), instruction alloca (1), instruction freeze (2), intrinsic llvm.ctlz (1), intrinsic llvm.fshl (1), intrinsic llvm.lifetime.end (1), intrinsic llvm.lifetime.start (1), load from a computed pointer (2), load from a pointer parameter (18), store to a local variable (5), terminator switch (3), terminator unreachable (1), type half (12), type ptr (3). Constants read: math::expxf16_internal::LOG2F_F (not in table form), math::expxf16_internal::ONE_OVER_F_F (not in table form)
- `logbf`: cast sitofp (1), intrinsic llvm.ctlz (1)
- `logf`: cast sitofp (2), terminator switch (2), volatile local variable (10). Fast-math flags: ninf nnan. Constants read: common_constants_internal::LOG_R, common_constants_internal::RD
- `logf16`: call fputil::DyadicFloat::generic_as (2), cast sitofp (1), instruction alloca (2), intrinsic llvm.ctlz (1), intrinsic llvm.lifetime.end (2), intrinsic llvm.lifetime.start (2), load from a computed pointer (2), load from a constant not in table form (2), operand global (1), store to a local variable (8), terminator switch (3), type half (15), type ptr (1); instruction freeze (2), intrinsic llvm.fshl (1), load from a pointer parameter (7), terminator switch (2), terminator unreachable (1), type half (8), type ptr (1). Fast-math flags: ninf nnan. Constants read: math::expxf16_internal::LOGF_F (not in table form), math::expxf16_internal::ONE_OVER_F_F (not in table form)
- `lrintf`: call fputil::round_using_current_rounding_mode (1); intrinsic llvm.copysign (1), intrinsic llvm.fshl (1), terminator switch (1), terminator unreachable (1)
- `lrintf16`: call fputil::round_using_current_rounding_mode (1), type half (3); intrinsic llvm.copysign (1), intrinsic llvm.fshl (1), terminator switch (1), terminator unreachable (1), type half (23)
- `lroundf`: intrinsic llvm.copysign (1)
- `lroundf16`: intrinsic llvm.copysign (1), type half (7)
- `modff`: store to a pointer parameter (3), type ptr (1)
- `modff16`: store to a pointer parameter (3), type half (14), type ptr (1)
- `nanf`: call internal::isalnum (1), call internal::strtointeger (1), instruction extractvalue (2), intrinsic llvm.umin (1), load from a pointer parameter (3), loop (1), terminator switch (1), type ptr (1); call internal::b36_char_to_int (5), call internal::isalnum (6), instruction extractvalue (1), instruction insertvalue (2), intrinsic llvm.experimental.noalias.scope.decl (5), intrinsic llvm.umul.with.overflow (1), load from a pointer parameter (14), loop (1), terminator switch (4), type aggregate (1), type ptr (1). Constants read: switch.table._ZN11__llvm_libc8internal15b36_char_to_intEc
- `nanf16`: call internal::isalnum (1), call internal::strtointeger (1), instruction extractvalue (2), intrinsic llvm.umin (1), load from a pointer parameter (3), loop (1), terminator switch (1), type half (4), type ptr (1); call internal::b36_char_to_int (5), call internal::isalnum (6), instruction insertvalue (2), instruction udiv (1), intrinsic llvm.experimental.noalias.scope.decl (5), load from a pointer parameter (14), loop (1), terminator switch (4), type aggregate (1), type ptr (1). Constants read: switch.table._ZN11__llvm_libc8internal15b36_char_to_intEc
- `nearbyintf`: intrinsic llvm.copysign (1), intrinsic llvm.fshl (1), terminator switch (1), terminator unreachable (1)
- `nearbyintf16`: intrinsic llvm.copysign (1), intrinsic llvm.fshl (1), terminator switch (1), terminator unreachable (1), type half (23)
- `nextafterf16`: type half (16)
- `nextdownf16`: type half (9)
- `nexttowardf`: terminator switch (1), type x86_fp80 (7)
- `nexttowardf16`: call fputil::DyadicFloat::fast_as (2), call fputil::DyadicFloat::generic_as (1), instruction alloca (3), intrinsic llvm.ctlz (3), intrinsic llvm.lifetime.end (3), intrinsic llvm.lifetime.start (3), store to a local variable (15), terminator switch (2), type half (15), type x86_fp80 (8); cast uitofp (2), instruction freeze (2), intrinsic llvm.assume (1), intrinsic llvm.fshl (1), intrinsic llvm.fshr (2), load from a pointer parameter (12), terminator switch (2), terminator unreachable (1), type half (8), type ptr (2), type x86_fp80 (23), volatile local variable (1)
- `nextupf16`: type half (9)
- `powf`: call fputil::nearest_integer (1), call math::double_eval::check_exact_boundary (2), call math::double_eval::exp10f (1), call math::double_eval::exp2f (2), call math::double_eval::powf_accurate (2), call math::powf_internal::set_overflow (5), call math::powf_internal::set_underflow (5), cast sitofp (3), intrinsic llvm.abs (1), intrinsic llvm.ctlz (1), intrinsic llvm.ctpop (1), intrinsic llvm.cttz (3), intrinsic llvm.sqrt (1), load from a computed pointer (1), operand global (1), type ptr (1), volatile local variable (2); call math::double_eval::exp10f_slow (1), call math::double_eval::exp2f(float)::'lambda'()::operator() (1), call math::powf_internal::is_exact_rounding_boundary (1), call math::powf_internal::set_overflow (1), cast fptoui (1), cast sitofp (4), cast uitofp (2), instruction alloca (4), instruction udiv (2), intrinsic llvm.ctlz (2), intrinsic llvm.cttz (2), intrinsic llvm.lifetime.end (3), intrinsic llvm.lifetime.start (3), intrinsic llvm.sqrt (1), load from a computed pointer (1), load from a constant not in table form (7), load from a local variable (6), load from a pointer parameter (1), loop (2), store to a local variable (4), store to a pointer parameter (4), terminator switch (4), type ptr (2), volatile local variable (2). Fast-math flags: ninf nnan. Constants read: EXP2_MID1 (not in table form), ExpBase::EXP_2_MID, __const._ZN11__llvm_libc4math11double_eval13powf_accurateEffdm.LOG2_COEFFS (not in table form), common_constants_internal::R, math::powf_internal::LOG2_R_32, math::powf_internal::LOG2_R_TD (not in table form), math::powf_internal::R_32_D
- `remainderf`: call fputil::remquo (1), instruction alloca (1), intrinsic llvm.lifetime.end (1), intrinsic llvm.lifetime.start (1), store to a local variable (1); call fputil::NormalFloat::NormalFloat (2), call fputil::NormalFloat::operator float (1), instruction alloca (3), intrinsic llvm.copysign (3), intrinsic llvm.lifetime.end (3), intrinsic llvm.lifetime.start (3), load from a local variable (9), load from a pointer parameter (7), loop (2), ret void (1), store to a local variable (5), store to a pointer parameter (15), type ptr (3)
- `remainderf16`: call fputil::remquo (1), instruction alloca (1), intrinsic llvm.lifetime.end (1), intrinsic llvm.lifetime.start (1), store to a local variable (1), type half (2); call fputil::NormalFloat::NormalFloat (2), call fputil::NormalFloat::operator _Float16 (1), instruction alloca (3), intrinsic llvm.copysign (3), intrinsic llvm.lifetime.end (3), intrinsic llvm.lifetime.start (3), load from a local variable (9), load from a pointer parameter (7), loop (2), ret void (1), store to a local variable (5), store to a pointer parameter (15), type half (35), type ptr (3)
- `remquof`: call fputil::NormalFloat::NormalFloat (2), call fputil::NormalFloat::operator float (1), instruction alloca (3), intrinsic llvm.copysign (3), intrinsic llvm.lifetime.end (3), intrinsic llvm.lifetime.start (3), load from a local variable (9), load from a pointer parameter (3), loop (1), store to a local variable (5), store to a pointer parameter (8), type ptr (1); load from a pointer parameter (4), loop (1), ret void (1), store to a pointer parameter (7), type ptr (2)
- `remquof16`: call fputil::NormalFloat::NormalFloat (2), call fputil::NormalFloat::operator _Float16 (1), instruction alloca (3), intrinsic llvm.copysign (3), intrinsic llvm.lifetime.end (3), intrinsic llvm.lifetime.start (3), load from a local variable (9), load from a pointer parameter (3), loop (1), store to a local variable (5), store to a pointer parameter (8), type half (29), type ptr (1); load from a pointer parameter (4), loop (1), ret void (1), store to a pointer parameter (7), type half (6), type ptr (2)
- `rintf`: intrinsic llvm.copysign (1), intrinsic llvm.fshl (1), terminator switch (1), terminator unreachable (1)
- `rintf16`: intrinsic llvm.copysign (1), intrinsic llvm.fshl (1), terminator switch (1), terminator unreachable (1), type half (23)
- `roundevenf16`: type half (13)
- `roundf`: intrinsic llvm.copysign (1)
- `roundf16`: intrinsic llvm.copysign (1), type half (6)
- `rsqrtf`: instruction fdiv (1), intrinsic llvm.copysign (1), intrinsic llvm.sqrt (1)
- `rsqrtf16`: call fputil::DyadicFloat::fast_as (1), call fputil::DyadicFloat::generic_as (1), instruction alloca (2), instruction fdiv (1), intrinsic llvm.copysign (1), intrinsic llvm.ctlz (2), intrinsic llvm.lifetime.end (2), intrinsic llvm.lifetime.start (2), intrinsic llvm.sqrt (1), store to a local variable (10), terminator switch (1), type half (10); cast uitofp (2), instruction freeze (2), intrinsic llvm.fshl (1), load from a pointer parameter (12), terminator switch (2), terminator unreachable (1), type half (8), type ptr (2), volatile local variable (1). Fast-math flags: nnan
- `scalblnf`: call fputil::DyadicFloat::fast_as (1), instruction alloca (1), intrinsic llvm.copysign (3), intrinsic llvm.ctlz (1), intrinsic llvm.lifetime.end (1), intrinsic llvm.lifetime.start (1), store to a local variable (3); cast uitofp (2), load from a pointer parameter (5), type ptr (1), volatile local variable (1). Fast-math flags: nnan
- `scalblnf16`: call fputil::DyadicFloat::generic_as (1), instruction alloca (1), intrinsic llvm.copysign (3), intrinsic llvm.ctlz (1), intrinsic llvm.lifetime.end (1), intrinsic llvm.lifetime.start (1), store to a local variable (3), type half (6); instruction freeze (2), intrinsic llvm.assume (2), intrinsic llvm.fshl (1), load from a pointer parameter (7), terminator switch (2), terminator unreachable (1), type half (8), type ptr (1)
- `scalbnf`: call fputil::DyadicFloat::fast_as (1), instruction alloca (1), intrinsic llvm.copysign (3), intrinsic llvm.ctlz (1), intrinsic llvm.lifetime.end (1), intrinsic llvm.lifetime.start (1), store to a local variable (3); cast uitofp (2), load from a pointer parameter (5), type ptr (1), volatile local variable (1). Fast-math flags: nnan
- `scalbnf16`: call fputil::DyadicFloat::generic_as (1), instruction alloca (1), intrinsic llvm.copysign (3), intrinsic llvm.ctlz (1), intrinsic llvm.lifetime.end (1), intrinsic llvm.lifetime.start (1), store to a local variable (3), type half (6); instruction freeze (2), intrinsic llvm.assume (2), intrinsic llvm.fshl (1), load from a pointer parameter (7), terminator switch (2), terminator unreachable (1), type half (8), type ptr (1)
- `setpayloadf`: store to a pointer parameter (3), type ptr (1)
- `setpayloadf16`: store to a pointer parameter (3), type half (3), type ptr (1)
- `setpayloadsigf`: store to a pointer parameter (1), type ptr (1)
- `setpayloadsigf16`: store to a pointer parameter (1), type half (5), type ptr (1)
- `sincosf`: call math::trigonometric_func_utils_internal::large_range_reduction (1), instruction alloca (1), intrinsic llvm.lifetime.end (1), intrinsic llvm.lifetime.start (1), load from a constant not in table form (8), load from a local variable (1), ret void (1), store to a pointer parameter (12), terminator switch (2), type ptr (1); loop (1), store to a pointer parameter (1), type ptr (1). Constants read: math::sincosf_internal::EXCEPT_OUTPUTS_COS (not in table form), math::sincosf_internal::EXCEPT_OUTPUTS_SIN (not in table form), math::sincosf_utils_internal::SIN_K_PI_OVER_32, math::trigonometric_func_utils_internal::THIRTYTWO_OVER_PI_28, math::trigonometric_func_utils_internal::THIRTYTWO_OVER_PI_28_LSB_EXP
- `sinf`: call math::trigonometric_func_utils_internal::large_range_reduction (1), instruction alloca (1), intrinsic llvm.lifetime.end (1), intrinsic llvm.lifetime.start (1), load from a local variable (1), terminator switch (1); loop (1), store to a pointer parameter (1), type ptr (1). Constants read: math::sincosf_utils_internal::SIN_K_PI_OVER_32, math::trigonometric_func_utils_internal::THIRTYTWO_OVER_PI_28, math::trigonometric_func_utils_internal::THIRTYTWO_OVER_PI_28_LSB_EXP
- `sinf16`: call fputil::DyadicFloat::generic_as (1), instruction alloca (1), intrinsic llvm.ctlz (1), intrinsic llvm.lifetime.end (1), intrinsic llvm.lifetime.start (1), load from a computed pointer (2), operand global (1), store to a local variable (5), terminator switch (3), type half (15), type ptr (1); instruction freeze (2), intrinsic llvm.fshl (1), load from a pointer parameter (7), terminator switch (2), terminator unreachable (1), type half (8), type ptr (1). Constants read: math::sincosf16_internal::SIN_K_PI_OVER_32
- `sinhf`: cast sitofp (1), intrinsic llvm.copysign (1). Fast-math flags: nnan. Constants read: ExpBase::EXP_2_MID
- `sinhf16`: call math::expxf16_internal::eval_sinh_or_cosh (1), intrinsic llvm.copysign (3), load from a computed pointer (4), operand global (2), terminator switch (4), type half (11), type ptr (2); call fputil::DyadicFloat::generic_as (1), instruction alloca (1), instruction freeze (2), intrinsic llvm.ctlz (1), intrinsic llvm.fshl (1), intrinsic llvm.lifetime.end (1), intrinsic llvm.lifetime.start (1), load from a constant not in table form (2), load from a pointer parameter (7), store to a local variable (5), terminator switch (2), terminator unreachable (1), type half (14), type ptr (1). Constants read: math::expxf16_internal::EXP2_MID_5_BITS (not in table form)
- `sinpif`: Constants read: math::sincosf_utils_internal::SIN_K_PI_OVER_32
- `sinpif16`: call fputil::DyadicFloat::generic_as (1), instruction alloca (1), intrinsic llvm.ctlz (1), intrinsic llvm.lifetime.end (1), intrinsic llvm.lifetime.start (1), store to a local variable (5), type half (12); instruction freeze (2), intrinsic llvm.fshl (1), load from a pointer parameter (7), terminator switch (2), terminator unreachable (1), type half (8), type ptr (1). Constants read: math::sincosf16_internal::SIN_K_PI_OVER_32
- `sqrtf`: intrinsic llvm.sqrt (1)
- `sqrtf16`: call fputil::DyadicFloat::generic_as (1), instruction alloca (1), instruction freeze (1), intrinsic llvm.ctlz (2), intrinsic llvm.lifetime.end (1), intrinsic llvm.lifetime.start (1), store to a local variable (5), type half (7); instruction freeze (2), intrinsic llvm.assume (2), intrinsic llvm.fshl (1), load from a pointer parameter (7), terminator switch (2), terminator unreachable (1), type half (8), type ptr (1)
- `tanf`: call fputil::ExceptValues::lookup_odd (1), call math::trigonometric_func_utils_internal::large_range_reduction (1), instruction alloca (1), instruction fdiv (1), intrinsic llvm.lifetime.end (1), intrinsic llvm.lifetime.start (2), load from a local variable (1), volatile local variable (1); load from a computed pointer (2), load from a pointer parameter (6), loop (1), store to a pointer parameter (1), terminator switch (1), type ptr (3). Fast-math flags: nnan. Constants read: math::sincosf_utils_internal::SIN_K_PI_OVER_32, math::trigonometric_func_utils_internal::THIRTYTWO_OVER_PI_28, math::trigonometric_func_utils_internal::THIRTYTWO_OVER_PI_28_LSB_EXP
- `tanf16`: call fputil::DyadicFloat::generic_as (1), call fputil::cast (2), instruction alloca (1), instruction fdiv (1), intrinsic llvm.ctlz (1), intrinsic llvm.lifetime.end (1), intrinsic llvm.lifetime.start (1), load from a computed pointer (2), operand global (1), store to a local variable (5), terminator switch (2), type half (14), type ptr (1); call fputil::DyadicFloat::generic_as (1), instruction alloca (1), instruction freeze (2), intrinsic llvm.ctlz (1), intrinsic llvm.fshl (1), intrinsic llvm.lifetime.end (1), intrinsic llvm.lifetime.start (1), load from a pointer parameter (7), store to a local variable (5), terminator switch (2), terminator unreachable (1), type half (12), type ptr (1). Constants read: math::sincosf16_internal::SIN_K_PI_OVER_32
- `tanhf`: cast sitofp (1), instruction fdiv (1), intrinsic llvm.copysign (1), volatile local variable (2). Fast-math flags: nnan. Constants read: ExpBase::EXP_2_MID
- `tanhf16`: call fputil::DyadicFloat::generic_as (1), call fputil::cast (3), instruction alloca (1), instruction fdiv (1), intrinsic llvm.copysign (2), intrinsic llvm.ctlz (1), intrinsic llvm.lifetime.end (1), intrinsic llvm.lifetime.start (1), load from a computed pointer (2), load from a constant not in table form (1), operand global (1), store to a local variable (5), terminator switch (4), type half (13), type ptr (1); call fputil::DyadicFloat::generic_as (2), instruction alloca (2), instruction freeze (4), intrinsic llvm.assume (1), intrinsic llvm.ctlz (2), intrinsic llvm.fshl (2), intrinsic llvm.fshr (1), intrinsic llvm.lifetime.end (2), intrinsic llvm.lifetime.start (2), load from a pointer parameter (14), store to a local variable (10), terminator switch (4), terminator unreachable (2), type half (24), type ptr (2). Constants read: math::expxf16_internal::EXP2_MID_5_BITS (not in table form)
- `tanpif`: call fputil::ExceptValues::lookup_odd (1), instruction alloca (1), instruction fdiv (1), intrinsic llvm.lifetime.end (1), intrinsic llvm.lifetime.start (1), intrinsic llvm.memcpy.p0.p0 (1); load from a computed pointer (2), load from a pointer parameter (3), terminator switch (1), type ptr (2). Constants read: math::sincosf_utils_internal::SIN_K_PI_OVER_32
- `tanpif16`: call fputil::DyadicFloat::generic_as (1), call fputil::ExceptValues::lookup_odd (1), instruction alloca (2), instruction fdiv (1), intrinsic llvm.ctlz (1), intrinsic llvm.lifetime.end (2), intrinsic llvm.lifetime.start (2), intrinsic llvm.memcpy.p0.p0 (1), store to a local variable (5), type half (14); instruction freeze (2), intrinsic llvm.fshl (1), load from a computed pointer (2), load from a pointer parameter (28), terminator switch (3), terminator unreachable (1), type half (11), type ptr (3). Constants read: math::sincosf16_internal::SIN_K_PI_OVER_32
- `totalorderf`: load from a pointer parameter (2), type ptr (1)
- `totalorderf16`: load from a pointer parameter (2), type ptr (1)
- `totalordermagf`: load from a pointer parameter (2), type ptr (1)
- `totalordermagf16`: load from a pointer parameter (2), type half (8), type ptr (1)
- `truncf16`: type half (6)
- `ufromfpf`: call fputil::round_using_specific_rounding_mode (1); terminator switch (2)
- `ufromfpf16`: call fputil::round_using_specific_rounding_mode (1), type half (10); terminator switch (2), type half (24)
- `ufromfpxf`: call fputil::round_using_specific_rounding_mode (1); terminator switch (2)
- `ufromfpxf16`: call fputil::round_using_specific_rounding_mode (1), type half (14); terminator switch (2), type half (24)
- `exp`: call fputil::DyadicFloat::fast_as (1), call math::exp_internal::exp_f128 (1), call math::exp_internal::poly_approx_dd (1), call math::exp_internal::set_exceptional (1), call ziv_test_denorm (2), cast sitofp (1), instruction alloca (2), instruction extractvalue (6), intrinsic llvm.lifetime.end (2), intrinsic llvm.lifetime.start (2), load from a constant not in table form (4), store to a local variable (2); call fputil::quick_add (1), call math::exp_internal::poly_approx_f128 (1), cast uitofp (2), instruction alloca (3), instruction extractvalue (178), instruction insertvalue (4), intrinsic llvm.ctlz (33), intrinsic llvm.experimental.noalias.scope.decl (1), intrinsic llvm.lifetime.end (3), intrinsic llvm.lifetime.start (3), intrinsic llvm.memcpy.p0.p0 (2), intrinsic llvm.memset.p0 (2), intrinsic llvm.uadd.with.overflow (73), intrinsic llvm.usub.with.overflow (27), load from a constant not in table form (6), load from a local variable (4), load from a pointer parameter (20), ret void (3), store to a local variable (11), store to a pointer parameter (14), type aggregate (18), type ptr (5), volatile local variable (1). Fast-math flags: nnan. Constants read: EXP2_MID1 (not in table form), EXP2_MID2 (not in table form)
- `log`: call math::log_internal::log_accurate (1), cast sitofp (1), load from a constant not in table form (2); call fputil::DyadicFloat::fast_as (1), call math::log_range_reduction_internal::log_range_reduction (1), cast sitofp (1), cast uitofp (2), instruction alloca (8), instruction extractvalue (104), intrinsic llvm.ctlz (21), intrinsic llvm.lifetime.end (8), intrinsic llvm.lifetime.start (9), intrinsic llvm.memcpy.p0.p0 (16), intrinsic llvm.memset.p0 (1), intrinsic llvm.uadd.with.overflow (41), intrinsic llvm.usub.with.overflow (17), load from a computed pointer (2), load from a constant not in table form (4), load from a local variable (6), load from a pointer parameter (22), ret void (1), store to a computed pointer (4), store to a local variable (20), store to a pointer parameter (26), type aggregate (9), type ptr (6), volatile local variable (1). Fast-math flags: nnan. Constants read: common_constants_internal::CD, common_constants_internal::LOG_R_DD (not in table form), common_constants_internal::RD, common_constants_internal::S2, common_constants_internal::S3, common_constants_internal::S4, math::log_internal::LOG_TABLE (not in table form)
- `sin`: call math::range_reduction_double_internal::LargeRangeReduction::fast (1), call math::range_reduction_double_internal::range_reduction_small (1), call math::sin_accurate (2), instruction alloca (2), intrinsic llvm.lifetime.end (2), intrinsic llvm.lifetime.start (2), intrinsic llvm.memset.p0 (2), load from a constant not in table form (4), load from a local variable (2), store to a local variable (2); call fputil::DyadicFloat::fast_as (1), call fputil::polyeval (2), call fputil::quick_add (1), call math::range_reduction_double_internal::LargeRangeReduction::accurate (1), call math::range_reduction_double_internal::range_reduction_small_f128 (1), call math::sincos_eval_internal::sincos_eval (1), cast uitofp (2), instruction alloca (9), instruction extractvalue (209), intrinsic llvm.ctlz (33), intrinsic llvm.experimental.noalias.scope.decl (1), intrinsic llvm.lifetime.end (9), intrinsic llvm.lifetime.start (9), intrinsic llvm.memcpy.p0.p0 (4), intrinsic llvm.memset.p0 (7), intrinsic llvm.uadd.with.overflow (90), intrinsic llvm.usub.with.overflow (27), load from a constant not in table form (11), load from a local variable (12), load from a pointer parameter (55), ret void (5), store to a local variable (21), store to a pointer parameter (36), type aggregate (16), type ptr (9), volatile local variable (1). Fast-math flags: nnan. Constants read: math::range_reduction_double_internal::ONE_TWENTY_EIGHT_OVER_PI (not in table form), math::range_reduction_double_internal::SIN_K_PI_OVER_128 (not in table form), math::range_reduction_double_internal::SIN_K_PI_OVER_128_F128 (not in table form)
- `cos`: call math::cos_accurate (2), call math::range_reduction_double_internal::LargeRangeReduction::fast (1), call math::range_reduction_double_internal::range_reduction_small (1), instruction alloca (2), intrinsic llvm.lifetime.end (2), intrinsic llvm.lifetime.start (2), intrinsic llvm.memset.p0 (2), load from a constant not in table form (4), load from a local variable (2), store to a local variable (3), volatile local variable (1); call fputil::DyadicFloat::fast_as (1), call fputil::polyeval (2), call fputil::quick_add (1), call math::range_reduction_double_internal::LargeRangeReduction::accurate (1), call math::range_reduction_double_internal::range_reduction_small_f128 (1), call math::sincos_eval_internal::sincos_eval (1), cast uitofp (2), instruction alloca (9), instruction extractvalue (209), intrinsic llvm.ctlz (33), intrinsic llvm.experimental.noalias.scope.decl (1), intrinsic llvm.lifetime.end (9), intrinsic llvm.lifetime.start (9), intrinsic llvm.memcpy.p0.p0 (4), intrinsic llvm.memset.p0 (7), intrinsic llvm.uadd.with.overflow (90), intrinsic llvm.usub.with.overflow (27), load from a constant not in table form (11), load from a local variable (12), load from a pointer parameter (55), ret void (5), store to a local variable (21), store to a pointer parameter (36), type aggregate (16), type ptr (9), volatile local variable (1). Fast-math flags: nnan. Constants read: math::range_reduction_double_internal::ONE_TWENTY_EIGHT_OVER_PI (not in table form), math::range_reduction_double_internal::SIN_K_PI_OVER_128 (not in table form), math::range_reduction_double_internal::SIN_K_PI_OVER_128_F128 (not in table form)
- `pow`: call fputil::DyadicFloat::fast_as (1), call fputil::nearest_integer (2), call math::double_eval::exp_accurate_128 (2), call math::double_eval::exp_denorm (2), call math::double_eval::set_exceptional (2), call math::exp10 (1), call math::pow_internal::is_exact_rounding_boundary (1), call math::pow_internal::pow_accurate (2), call math::pow_internal::set_overflow (2), call math::pow_internal::set_underflow (2), call math::pow_internal::ziv_test_denorm (1), cast sitofp (2), instruction alloca (3), instruction extractelement (2), instruction extractvalue (2), instruction insertelement (4), intrinsic llvm.abs (1), intrinsic llvm.ctlz (5), intrinsic llvm.ctpop (1), intrinsic llvm.cttz (3), intrinsic llvm.lifetime.end (5), intrinsic llvm.lifetime.start (3), intrinsic llvm.sqrt (1), load from a constant not in table form (8), load from a local variable (2), operand poison (4), store to a local variable (12), type vector (16), volatile local variable (2); call exp10_denorm (1), call exp10_double_double (1), call exp10_f128 (2), call exp10_poly_approx_dd (2), call exp10_poly_approx_f128 (1), call exp10_set_exceptional (1), call fputil::DyadicFloat::DyadicFloat (1), call fputil::DyadicFloat::fast_as (9), call fputil::DyadicFloat::normalize (1), call fputil::quick_add (6), call fputil::quick_mul (1), call math::double_eval::exp2_eval_frac128 (1), call math::double_eval::exp_accurate_128 (1), call math::pow_internal::exp2_f128 (1), call math::pow_internal::exp2_f256 (1), call math::pow_internal::is_exact_rounding_boundary (1), call math::pow_internal::log2_f128 (1), call math::pow_internal::log2_f256 (1), call math::pow_internal::pow_accurate_256 (1), call math::pow_internal::set_overflow (4), call math::pow_internal::set_underflow (1), cast fptoui (2), cast sitofp (9), cast uitofp (5), instruction alloca (49), instruction extractvalue (832), instruction insertvalue (8), instruction udiv (2), intrinsic llvm.assume (10), intrinsic llvm.ctlz (86), intrinsic llvm.cttz (4), intrinsic llvm.experimental.noalias.scope.decl (3), intrinsic llvm.fshl (60), intrinsic llvm.fshr (19), intrinsic llvm.lifetime.end (40), intrinsic llvm.lifetime.start (41), intrinsic llvm.memcpy.p0.p0 (18), intrinsic llvm.memset.p0 (15), intrinsic llvm.sqrt (1), intrinsic llvm.uadd.with.overflow (373), intrinsic llvm.usub.with.overflow (67), load from a constant not in table form (68), load from a local variable (166), load from a pointer parameter (75), loop (6), operand null (2), ret void (10), store to a local variable (126), store to a pointer parameter (64), terminator switch (2), type aggregate (38), type ptr (26), volatile local variable (6). Fast-math flags: nnan. Constants read: EXP2_MID1 (not in table form), EXP2_MID2 (not in table form), common_constants_internal::CD, common_constants_internal::RD, math::double_eval::EXP2_MID (not in table form), math::double_eval::EXP2_MID_FRAC128 (not in table form), math::double_eval::EXP2_POLY_128 (not in table form), math::pow_internal::EXP2_MID_FRAC256 (not in table form), math::pow_internal::EXP2_POLY_128 (not in table form), math::pow_internal::EXP2_POLY_256 (not in table form), math::pow_internal::LOG2_POLY_128 (not in table form), math::pow_internal::LOG2_POLY_256 (not in table form), math::pow_internal::LOG2_RD_FRAC256 (not in table form), math::pow_internal::LOG2_R_DD (not in table form)
- `exp2`: call math::double_eval::exp_accurate_128 (1), call math::double_eval::exp_denorm (1), call math::double_eval::set_exceptional (1), instruction extractelement (1), instruction insertelement (2), load from a constant not in table form (2), operand poison (2), type vector (8); call fputil::DyadicFloat::fast_as (1), call math::double_eval::exp2_eval_frac128 (1), call math::double_eval::exp_accurate_128 (1), cast sitofp (1), cast uitofp (2), instruction alloca (2), instruction extractvalue (33), instruction insertvalue (2), intrinsic llvm.experimental.noalias.scope.decl (1), intrinsic llvm.lifetime.end (2), intrinsic llvm.lifetime.start (2), intrinsic llvm.uadd.with.overflow (16), intrinsic llvm.usub.with.overflow (1), load from a constant not in table form (4), load from a pointer parameter (12), loop (1), operand null (2), store to a local variable (6), type aggregate (1), type ptr (6), volatile local variable (1). Fast-math flags: nnan. Constants read: math::double_eval::EXP2_MID (not in table form), math::double_eval::EXP2_MID_FRAC128 (not in table form), math::double_eval::EXP2_POLY_128 (not in table form)
- `log2`: call math::log2_internal::log2_accurate (1), cast sitofp (1), load from a constant not in table form (2); call fputil::DyadicFloat::fast_as (1), call math::log_range_reduction_internal::log_range_reduction (1), cast sitofp (1), cast uitofp (2), instruction alloca (7), instruction extractvalue (98), intrinsic llvm.ctlz (21), intrinsic llvm.lifetime.end (7), intrinsic llvm.lifetime.start (7), intrinsic llvm.memcpy.p0.p0 (12), intrinsic llvm.uadd.with.overflow (38), intrinsic llvm.usub.with.overflow (17), load from a constant not in table form (4), load from a local variable (8), load from a pointer parameter (22), ret void (1), store to a local variable (11), store to a pointer parameter (26), type aggregate (9), type ptr (2), volatile local variable (1). Fast-math flags: nnan. Constants read: common_constants_internal::CD, common_constants_internal::RD, common_constants_internal::S2, common_constants_internal::S3, common_constants_internal::S4, math::log2_internal::LOG2_TABLE (not in table form), math::log2_internal::LOG_R1 (not in table form)
- `sqrt`: intrinsic llvm.sqrt (1)
- `hypot`: call fputil::hypot (1), call math::hypot_internal::hypot_denorm (1), instruction fdiv (1), intrinsic llvm.sqrt (1), intrinsic llvm.umax (1), intrinsic llvm.umin (1); call fputil::hypot (1), instruction fdiv (1), intrinsic llvm.ctlz (1), intrinsic llvm.sqrt (1), intrinsic llvm.umax (2), intrinsic llvm.umin (1), loop (1), terminator switch (1). Fast-math flags: nnan
