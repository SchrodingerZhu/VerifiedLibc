# `extract`: C++23 Clang-AST to Lean 4 Math Extractor (`ast2lean`)

Module-first C++23 extractor that parses LLVM libc math sources directly from Clang's C++ AST,
captures the active `LIBC_MATH_*` and target CPU feature macros from Clang's preprocessor, lifts
C++ control flow and mathematical idioms into a typed High-Level Math IR, and emits clean Lean 4
modules targeting `LibcMath.Core` and `LibcMath.Core.DSL`.

## Module architecture

All extractor components are C++23 modules (`FILE_SET CXX_MODULES` in `CMakeLists.txt`):

- `src/core_ops.cppm` (`libc_extract.core_ops`) — Catalog of LLVM libc math core types
  (`FPBits`, `Frac64`, `NumberPair`/`FloatFloat`/`DoubleDouble`, `TripleDouble`, `DyadicFloat`,
  `ExceptValues`, `Sign`) and core operations (`multiply_add`, `multiply_sub`, `sub_multiply`,
  `nearest_integer`, `polyeval`, `altpolyeval`, `estrin_polyeval`, `set_overflow`, `set_underflow`,
  rounding-mode queries, compiler builtins).
- `src/ir.cppm` (`libc_extract.ir`) — Typed High-Level Math IR + `MathConfig` snapshot + exact
  bit-level `ConstVal` (including 128/256-bit `DyadicFloat` and `Frac64` tables) + first-class
  `PolyevalExpr` + lazy join points (`LetJoinExpr`).
- `src/clang_parse.cppm` (`libc_extract.clang_parse`) — Clang LibTooling frontend isolated in
  `module :private;`. Snapshots `LIBC_MATH_*` / `LIBC_TARGET_CPU_HAS_*` / `LIBC_TYPES_HAS_INT128`
  from `CompilerInstance::getPreprocessor()`, resolves `if constexpr`, evaluates `constexpr` tables
  via `APValue`/`APFloat`, folds `cpp::is_constant_evaluated()` to `false`, captures template
  offsets (`estrin_polyeval<OFFSET>`), and follows helper functions.
- `src/lift.cppm` (`libc_extract.lift`) — Constant-branch folding, small constant-bound `for`-loop
  unrolling, bottom-up Horner recognition, field-update lifting (`{ v with f := ... }`),
  imperative-to-functional lifting with lazy zero-arg join points, and transitive rounding-mode
  analysis.
- `src/emit_lean.cppm` (`libc_extract.emit_lean`) — Lean 4 emitter (`LibcMath.Core.DSL` notation,
  `config : Core.MathConfig`, `kernelMeta : Core.KernelMeta`, `kernel : Core.UnaryKernel`),
  `--emit-ir`, and `--dump-config`.
- `src/extract.cppm` (`libc_extract`) — Umbrella module.
- `src/cli.cppm` (`libc_extract.cli`) & `src/main.cpp` — CLI driver.

## Build & test

```bash
cmake -S extract -B extract/build -G Ninja \
  -DCMAKE_C_COMPILER=clang -DCMAKE_CXX_COMPILER=clang++ -DCMAKE_BUILD_TYPE=Release
ninja -C extract/build
extract/test/run_tests.sh
```

## Extracting LLVM libc functions

```bash
# Inspect active LIBC_MATH_* and target CPU flags for any flag combination:
extract/build/ast2lean <libc>/src/math/generic/expf.cpp --dump-config \
  -- -std=gnu++17 -I <libc> -DLIBC_NAMESPACE=__llvm_libc -mavx2 -mfma

# Extract different evaluation plans of expf:
extract/extract.sh <libc> expf math::double_eval::expf expf \
  --namespace=LibcMath.Extracted.Expf.DoubleEval --out=LibcMath/Extracted/Expf/DoubleEval.lean

extract/extract.sh <libc> expf math::integer_eval::expf expf \
  --namespace=LibcMath.Extracted.Expf.IntegerEval --out=LibcMath/Extracted/Expf/IntegerEval.lean \
  -- -DLIBC_MATH_EXPF_IMPL=integer_eval -DLIBC_MATH=0x2C
```
