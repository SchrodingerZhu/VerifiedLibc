import FloatLib.Floats.Formats.BinaryInterchange.Model.Carrier
import LibcMath.Framework.Spec

/-!
# Build configuration and common notion for extracted LLVM libc math kernels

LLVM libc math implementations depend critically on preprocessor flags (`LIBC_MATH_*`) and
target CPU capabilities (`LIBC_TARGET_CPU_HAS_*`, `LIBC_TYPES_HAS_INT128`). Those flags select
both the algorithm family (e.g. `double_eval` vs `float_eval` vs `integer_eval` for `expf`) and
the rounding semantics of core building blocks (`fputil::multiply_add`, `fputil::sub_multiply`,
`fputil::nearest_integer`, `Frac64::operator*`).

This file defines:

* `MathConfig`: the exact snapshot of LLVM libc configuration macros and target CPU features
  captured by `ast2lean` from Clang's preprocessor;
* `KernelMeta`: machine-readable provenance attached to every extracted kernel;
* `UnaryKernel fmt`: the common bundle of a total executable kernel
  `IEEERoundingMode → Model fmt → Model fmt` with its `KernelMeta`.
-/

namespace LibcMath.Libc

open FloatLib.Floats.Formats.BinaryInterchange
open Model (IEEERoundingMode)

/-- Target CPU or GPU architecture family from `src/__support/macros/properties/architectures.h`. -/
inductive TargetArch where
  | x86_64
  | x86_32
  | aarch64
  | arm
  | riscv64
  | riscv32
  | gpu
  | wasm
  | other
  deriving DecidableEq, Repr, Inhabited

/-- Microarchitectural lowering selected by `src/__support/FPUtil/nearest_integer.h`. -/
inductive NearestIntKind where
  /-- Hardware ties-to-even instruction (`roundss`/`roundsd`, `frintn`, or ARMv8 `roundeven`). -/
  | hwTiesToEven
  /-- GPU `__builtin_rintf` / `__builtin_rint`, which uses the dynamic rounding mode. -/
  | gpuDynamicRint
  /-- Software `±2^fracWidth` shift-and-back trick with optional `±0.5` fixup. -/
  | genericMagic
  deriving DecidableEq, Repr, Inhabited

/-- Snapshot of LLVM libc `LIBC_MATH_*` flags and target microarchitecture macros
captured from Clang's preprocessor during extraction.

Each field matches a macro in `src/__support/macros/optimization.h`,
`src/__support/macros/properties/architectures.h`,
`src/__support/macros/properties/cpu_features.h`, or
`src/__support/macros/properties/types.h`. -/
structure MathConfig where
  /-- `LIBC_MATH_HAS_SKIP_ACCURATE_PASS` (`LIBC_MATH & 0x01`). -/
  skipAccuratePass : Bool := false
  /-- `LIBC_MATH_HAS_SMALL_TABLES` (`LIBC_MATH & 0x02`). -/
  smallTables : Bool := false
  /-- `LIBC_MATH_HAS_NO_ERRNO` (`LIBC_MATH & 0x04`). -/
  noErrno : Bool := false
  /-- `LIBC_MATH_HAS_NO_EXCEPT` (`LIBC_MATH & 0x08`). -/
  noExcept : Bool := false
  /-- `LIBC_MATH_HAS_INTERMEDIATE_COMP_IN_FLOAT` (`LIBC_MATH & 0x10`). -/
  intermediateCompInFloat : Bool := false
  /-- `LIBC_MATH_HAS_ASSUME_ROUND_NEAREST_ONLY` (`LIBC_MATH & 0x20`). -/
  assumeRoundNearestOnly : Bool := false
  /-- Target architecture family (`LIBC_TARGET_ARCH_IS_*`). -/
  arch : TargetArch := .x86_64
  /-- `__ARM_ARCH` level for 32-bit ARM targets (`0` on non-ARM targets). -/
  armArchVersion : Nat := 0
  /-- `LIBC_TARGET_IS_BIG_ENDIAN`. -/
  isBigEndian : Bool := false
  /-- `LIBC_TARGET_CPU_HAS_SSE2`. -/
  hasSse2 : Bool := true
  /-- `__SSSE3__`. -/
  hasSsse3 : Bool := false
  /-- `LIBC_TARGET_CPU_HAS_SSE4_2`. -/
  hasSse42 : Bool := false
  /-- `LIBC_TARGET_CPU_HAS_AVX`. -/
  hasAvx : Bool := false
  /-- `LIBC_TARGET_CPU_HAS_AVX2`. -/
  hasAvx2 : Bool := false
  /-- `LIBC_TARGET_CPU_HAS_AVX512F`. -/
  hasAvx512f : Bool := false
  /-- Coarse `LIBC_TARGET_CPU_HAS_FMA` macro (checked by `double_double.h:292`). -/
  hasFmaGlobal : Bool := false
  /-- `LIBC_TARGET_CPU_HAS_FMA_HALF`. -/
  hasFmaHalf : Bool := false
  /-- `LIBC_TARGET_CPU_HAS_FMA_FLOAT`. -/
  hasFmaFloat : Bool := false
  /-- `LIBC_TARGET_CPU_HAS_FMA_DOUBLE`. -/
  hasFmaDouble : Bool := false
  /-- `LIBC_TARGET_CPU_HAS_NEAREST_INT` (x86-64 SSE4.2 or AArch64). -/
  hasNearestInt : Bool := false
  /-- `LIBC_TARGET_CPU_HAS_FPU_FLOAT`. -/
  hasFpuFloat : Bool := true
  /-- `LIBC_TARGET_CPU_HAS_FPU_DOUBLE`. -/
  hasFpuDouble : Bool := true
  /-- `LIBC_TARGET_CPU_HAS_ARM_FPU_FLOAT`. -/
  hasArmFpuFloat : Bool := false
  /-- `LIBC_TARGET_CPU_HAS_ARM_FPU_DOUBLE`. -/
  hasArmFpuDouble : Bool := false
  /-- `LIBC_TARGET_CPU_HAS_ARM_NEON`. -/
  hasArmNeon : Bool := false
  /-- `LIBC_TARGET_CPU_HAS_RISCV_FPU_FLOAT`. -/
  hasRiscVFpuFloat : Bool := false
  /-- `LIBC_TARGET_CPU_HAS_RISCV_FPU_DOUBLE`. -/
  hasRiscVFpuDouble : Bool := false
  /-- `LIBC_TARGET_CPU_HAS_FAST_FLOAT16_OPS`. -/
  hasFastFloat16 : Bool := false
  /-- `LIBC_TYPES_HAS_INT128` (selects exact 128-bit vs 32-bit split `quick_mul_hi`). -/
  hasInt128 : Bool := true
  /-- `__FP_LOGBNAN_MIN` (returns `INT_MIN` for `ilogb(NaN)` on glibc Linux). -/
  fpLogbNanMin : Bool := true
  /-- Clang target triple (for example `x86_64-unknown-linux-gnu`). -/
  targetTriple : String := "x86_64-unknown-linux-gnu"
  /-- Selected implementation plan name (for example `double_eval`, `integer_eval`). -/
  implVariant : String := "default"
  deriving DecidableEq, Repr, Inhabited

namespace MathConfig

/-- Baseline x86-64 SSE2 configuration (`LIBC_MATH = 0`, no SSE4.2, no FMA). -/
def x86_64Sse2 : MathConfig := {}

/-- Compatibility alias for baseline x86-64 SSE2 configuration. -/
abbrev defaultX86_64 : MathConfig := x86_64Sse2

/-- x86-64 with SSSE3 (`-mssse3 -mno-sse4.2 -mno-fma`). -/
def x86_64Ssse3 : MathConfig :=
  { hasSsse3 := true }

/-- x86-64 with SSE4.2 (`-msse4.2 -mno-fma`): hardware `roundss`/`roundsd`, no FMA. -/
def x86_64Sse42 : MathConfig :=
  { hasSsse3 := true
    hasSse42 := true
    hasNearestInt := true }

/-- x86-64 with AVX2, FMA, and SSE4.2 (`-march=x86-64-v3`). -/
def x86_64Avx2Fma : MathConfig :=
  { hasSsse3 := true
    hasSse42 := true
    hasAvx := true
    hasAvx2 := true
    hasFmaGlobal := true
    hasFmaFloat := true
    hasFmaDouble := true
    hasNearestInt := true }

/-- Compatibility alias for x86-64 AVX2 + FMA configuration. -/
abbrev x86_64Fma : MathConfig := x86_64Avx2Fma

/-- AArch64 with NEON, FMA, `frintn`, and fast float16 operations. -/
def aarch64 : MathConfig :=
  { arch := .aarch64
    hasSse2 := false
    hasFmaGlobal := true
    hasFmaHalf := true
    hasFmaFloat := true
    hasFmaDouble := true
    hasNearestInt := true
    hasArmFpuFloat := true
    hasArmFpuDouble := true
    hasArmNeon := true
    hasFastFloat16 := true
    targetTriple := "aarch64-unknown-none-elf" }

/-- 32-bit ARMv8 hard-float (`__ARM_ARCH = 8`, VFP/NEON, FMA, no 128-bit integer). -/
def armV8HardFloat : MathConfig :=
  { arch := .arm
    armArchVersion := 8
    hasSse2 := false
    hasFmaGlobal := true
    hasFmaHalf := true
    hasFmaFloat := true
    hasFmaDouble := true
    hasArmFpuFloat := true
    hasArmFpuDouble := true
    hasArmNeon := true
    hasInt128 := false
    targetTriple := "armv8a-unknown-none-eabihf" }

/-- RISC-V 64-bit GC (`rv64gc`): F/D hardware FPU and FMA, software `nearest_integer`. -/
def riscv64G : MathConfig :=
  { arch := .riscv64
    hasSse2 := false
    hasFmaGlobal := true
    hasFmaFloat := true
    hasFmaDouble := true
    hasRiscVFpuFloat := true
    hasRiscVFpuDouble := true
    targetTriple := "riscv64-unknown-none-elf" }

/-- GPU target (NVPTX / AMDGPU / SPIR-V): FMA and dynamic-mode `__builtin_rintf`. -/
def gpuNvptx : MathConfig :=
  { arch := .gpu
    hasSse2 := false
    hasFmaGlobal := true
    hasFmaFloat := true
    hasFmaDouble := true
    hasFastFloat16 := true
    targetTriple := "nvptx64-nvidia-cuda" }

/-- Generic soft-float 32-bit target (`rv32i`): no FPU, no FMA, no 128-bit integer. -/
def genericSoftFloat : MathConfig :=
  { arch := .riscv32
    hasSse2 := false
    hasFpuFloat := false
    hasFpuDouble := false
    hasInt128 := false
    targetTriple := "riscv32-unknown-none-elf" }

/-- Whether hardware FMA is enabled for binary interchange format `fmt`, matching
`fputil::internal::HasHardwareFma<T>` in LLVM libc's `multiply_add.h`. -/
@[inline, grind]
def hasFma (cfg : MathConfig) (fmt : FloatFormat) : Bool :=
  if fmt == .binary16 then cfg.hasFmaHalf
  else if fmt == .binary32 then cfg.hasFmaFloat
  else if fmt == .binary64 then cfg.hasFmaDouble
  else false

/-- Whether coarse `LIBC_TARGET_CPU_HAS_FMA` is active (`double_double.h:292`). -/
@[inline, grind]
def hasAnyFma (cfg : MathConfig) : Bool :=
  cfg.hasFmaGlobal || cfg.hasFmaHalf || cfg.hasFmaFloat || cfg.hasFmaDouble

/-- Whether ARM hardware FPU is active for `fmt`. -/
@[inline, grind]
def hasArmFpu (cfg : MathConfig) (fmt : FloatFormat) : Bool :=
  if fmt == .binary32 then cfg.hasArmFpuFloat
  else if fmt == .binary64 then cfg.hasArmFpuDouble
  else false

/-- Selects the exact microarchitectural `fputil::nearest_integer` strategy for `fmt`,
matching `src/__support/FPUtil/nearest_integer.h`. -/
@[inline, grind]
def nearestIntKind (cfg : MathConfig) (fmt : FloatFormat) : NearestIntKind :=
  if cfg.hasNearestInt ||
      (cfg.arch == .x86_64 && cfg.hasSse42) ||
      (cfg.arch == .aarch64 && cfg.hasFpuFloat && cfg.hasFpuDouble) then
    .hwTiesToEven
  else if cfg.arch == .gpu then
    .gpuDynamicRint
  else if cfg.arch == .arm && cfg.armArchVersion ≥ 8 && cfg.hasArmFpu fmt then
    .hwTiesToEven
  else
    .genericMagic

/-- Whether hardware FPU operations are assumed for `fmt`, matching `fputil::internal::HAS_HW_FPU`.
-/
@[inline, grind]
def hasHwFpu (cfg : MathConfig) (fmt : FloatFormat) : Bool :=
  if fmt == .binary16 then cfg.hasFastFloat16
  else if fmt == .binary32 then cfg.hasFpuFloat
  else if fmt == .binary64 then cfg.hasFpuDouble
  else false

/-- The rounding directions this configuration claims to support. -/
def supportedModes (cfg : MathConfig) : Set IEEERoundingMode :=
  if cfg.assumeRoundNearestOnly then {.nearest} else cModes

/-- Bitmask encoding of the six `LIBC_MATH_*` flags matching `optimization.h`. -/
def libcMathMask (cfg : MathConfig) : Nat :=
  (if cfg.skipAccuratePass then 0x01 else 0) |||
  (if cfg.smallTables then 0x02 else 0) |||
  (if cfg.noErrno then 0x04 else 0) |||
  (if cfg.noExcept then 0x08 else 0) |||
  (if cfg.intermediateCompInFloat then 0x10 else 0) |||
  (if cfg.assumeRoundNearestOnly then 0x20 else 0)

/-- Compact human/agent-readable summary of active flags. -/
def summary (cfg : MathConfig) : String :=
  let flags : List String :=
    (if cfg.skipAccuratePass then ["SKIP_ACCURATE_PASS"] else []) ++
    (if cfg.smallTables then ["SMALL_TABLES"] else []) ++
    (if cfg.noErrno then ["NO_ERRNO"] else []) ++
    (if cfg.noExcept then ["NO_EXCEPT"] else []) ++
    (if cfg.intermediateCompInFloat then ["INTERMEDIATE_COMP_IN_FLOAT"] else []) ++
    (if cfg.assumeRoundNearestOnly then ["ASSUME_ROUND_NEAREST_ONLY"] else [])
  let cpu : List String :=
    (if cfg.hasFmaHalf then ["FMA_HALF"] else []) ++
    (if cfg.hasFmaFloat then ["FMA_FLOAT"] else []) ++
    (if cfg.hasFmaDouble then ["FMA_DOUBLE"] else []) ++
    (if cfg.hasNearestInt then ["NEAREST_INT"] else []) ++
    (if cfg.hasInt128 then ["INT128"] else ["NO_INT128"])
  let flagStr := if flags.isEmpty then "none (LIBC_MATH=0)" else String.intercalate "|" flags
  let cpuStr := String.intercalate "," cpu
  s!"variant={cfg.implVariant} target={cfg.targetTriple} LIBC_MATH=[{flagStr}] cpu=[{cpuStr}]"

@[simp, grind =] theorem hasFma_binary16 (cfg : MathConfig) :
    cfg.hasFma .binary16 = cfg.hasFmaHalf := rfl

@[simp, grind =] theorem hasFma_binary32 (cfg : MathConfig) :
    cfg.hasFma .binary32 = cfg.hasFmaFloat := rfl

@[simp, grind =] theorem hasFma_binary64 (cfg : MathConfig) :
    cfg.hasFma .binary64 = cfg.hasFmaDouble := rfl

end MathConfig

/-- Provenance and configuration metadata attached to every extracted kernel. -/
structure KernelMeta where
  /-- Lean-facing kernel name (e.g. `expf_double_eval`). -/
  name : String
  /-- Qualified C++ function extracted (e.g. `math::double_eval::expf`). -/
  cppFunction : String
  /-- Mangled C++ symbol name. -/
  mangledName : String := ""
  /-- Source file path relative to `llvm-project/libc`. -/
  sourceFile : String := ""
  /-- Git commit hash of `llvm-project` at extraction time. -/
  sourceCommit : String := ""
  /-- Clang frontend version used to parse the AST. -/
  clangVersion : String := ""
  /-- Preprocessor and target CPU configuration active during extraction. -/
  config : MathConfig := {}
  /-- Names of constant lookup tables extracted with this kernel. -/
  tables : List String := []
  deriving DecidableEq, Repr, Inhabited

namespace KernelMeta

/-- One-line summary suitable for diagnostics and logs. -/
def summary (m : KernelMeta) : String :=
  s!"{m.name} ({m.cppFunction}) [{m.config.summary}] tables={m.tables}"

end KernelMeta

/-- Common representation for a unary math kernel extracted from LLVM libc.

The model returns `none` on an execution that reaches an operation C++ leaves undefined (see
`LibcMath/Libc/Ops.lean`).

Because `UnaryKernel` coerces to `IEEERoundingMode → Model fmt → Option (Model fmt)`, a kernel can
be
passed directly to `CorrectlyRounded`, `checkRange`, `HoldsOnBits`, and diagnostics while keeping
its build configuration and provenance inspectable at compile time and runtime. -/
structure UnaryKernel (fmt : FloatFormat) where
  /-- Extraction metadata and active `LIBC_MATH` / CPU configuration. -/
  info : KernelMeta
  /-- Executable high-level Lean model of the C++ function. -/
  eval : IEEERoundingMode → Model fmt → Option (Model fmt)

instance {fmt : FloatFormat} :
    CoeFun (UnaryKernel fmt) (fun _ => IEEERoundingMode → Model fmt → Option (Model fmt)) where
  coe k := k.eval

/-- The rounding directions this kernel's configuration claims to support. -/
abbrev UnaryKernel.supportedModes {fmt : FloatFormat} (k : UnaryKernel fmt) :
    Set IEEERoundingMode :=
  k.info.config.supportedModes

/-- Statement that a unary kernel is correctly rounded for `S` under all modes in `modes`. -/
@[grind]
def UnaryKernel.CorrectlyRounded {fmt : FloatFormat} (k : UnaryKernel fmt)
    (S : Spec fmt) (modes : Set IEEERoundingMode := k.supportedModes) : Prop :=
  LibcMath.CorrectlyRounded S modes k.eval

/-- Common representation for a binary math kernel extracted from LLVM libc. -/
structure BinaryKernel (fmt : FloatFormat) where
  /-- Extraction metadata and active `LIBC_MATH` / CPU configuration. -/
  info : KernelMeta
  /-- Executable high-level Lean model of the C++ function. -/
  eval : IEEERoundingMode → Model fmt → Model fmt → Option (Model fmt)

instance {fmt : FloatFormat} :
    CoeFun (BinaryKernel fmt)
      (fun _ => IEEERoundingMode → Model fmt → Model fmt → Option (Model fmt)) where
  coe k := k.eval

/-- The rounding directions this binary kernel's configuration claims to support. -/
abbrev BinaryKernel.supportedModes {fmt : FloatFormat} (k : BinaryKernel fmt) :
    Set IEEERoundingMode :=
  k.info.config.supportedModes

/-- Common representation for a ternary math kernel extracted from LLVM libc. -/
structure TernaryKernel (fmt : FloatFormat) where
  /-- Extraction metadata and active `LIBC_MATH` / CPU configuration. -/
  info : KernelMeta
  /-- Executable high-level Lean model of the C++ function. -/
  eval : IEEERoundingMode → Model fmt → Model fmt → Model fmt → Option (Model fmt)

instance {fmt : FloatFormat} :
    CoeFun (TernaryKernel fmt)
      (fun _ => IEEERoundingMode → Model fmt → Model fmt → Model fmt → Option (Model fmt)) where
  coe k := k.eval

/-- The rounding directions this ternary kernel's configuration claims to support. -/
abbrev TernaryKernel.supportedModes {fmt : FloatFormat} (k : TernaryKernel fmt) :
    Set IEEERoundingMode :=
  k.info.config.supportedModes

end LibcMath.Libc
