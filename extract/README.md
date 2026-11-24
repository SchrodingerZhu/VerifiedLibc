# `extract`: C++23 Clang-AST to Lean 4 Math Extractor (`ast2lean`)

Module-first C++23 extractor that parses LLVM libc math sources directly from Clang's C++ AST,
captures the active `LIBC_MATH_*` and target CPU feature macros from Clang's preprocessor, lifts
C++ control flow and mathematical idioms into a typed High-Level Math IR, and emits clean Lean 4
modules targeting `LibcMath.Libc` and `LibcMath.Libc.DSL`.

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
- `src/emit_lean.cppm` (`libc_extract.emit_lean`) — Lean 4 emitter (`LibcMath.Libc.DSL` notation,
  `config : Libc.MathConfig`, `kernelMeta : Libc.KernelMeta`, `kernel : Libc.UnaryKernel`),
  `--emit-ir`, and `--dump-config`.
- `src/extract.cppm` (`libc_extract`) — Umbrella module.
- `src/cli.cppm` (`libc_extract.cli`) & `src/main.cpp` — CLI driver.

## Build & test

Build inside the flake shell (`nix develop`), which provides Clang 23 with its development
libraries and sets `AST2LEAN_CC`, `AST2LEAN_CXX`, `LLVM_DIR` and `Clang_DIR`:

```bash
extract/test/run_tests.sh      # configures and builds extract/build on first use, then tests
```

The scripts pass `AST2LEAN_CC` and `AST2LEAN_CXX` to CMake and fall back to `clang` and `clang++`
when they are unset. Do not rely on that fallback inside the flake shell: the first `clang` in
`PATH` there is the one bundled with Lean, which cannot compile C++ against the system headers.
The committed files under `LibcMath/Extracted/` are generated with the toolchain of the flake, and
they record its version; regenerate them there so that the result is reproducible.

Format the sources with `clang-format -i extract/src/* extract/test/*.cpp` (`extract/.clang-format`).
The emitter keeps generated Lean within 100 columns where a break is possible.

## Extracting LLVM libc functions

```bash
# Inspect active LIBC_MATH_* and target CPU flags for any flag combination:
extract/build/ast2lean <libc>/src/math/generic/expf.cpp --dump-config \
  -- -std=gnu++17 -I <libc> -DLIBC_NAMESPACE=__llvm_libc -mavx2 -mfma

# Extract different evaluation plans of expf:
extract/extract.sh <libc> expf math::double_eval::expf expf \
  --namespace=LibcMath.Expf.Generated.DoubleEval --out=LibcMath/Expf/Generated/DoubleEval.lean

extract/extract.sh <libc> expf math::integer_eval::expf expf \
  --namespace=LibcMath.Expf.Generated.IntegerEval --out=LibcMath/Expf/Generated/IntegerEval.lean \
  -- -DLIBC_MATH_EXPF_IMPL=integer_eval -DLIBC_MATH=0x2C
```
