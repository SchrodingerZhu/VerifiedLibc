#!/usr/bin/env bash
set -euo pipefail

root=$(cd "$(dirname "$0")/.." && pwd)
bin="$root/build/ast2lean"

if [[ ! -x "$bin" ]]; then
  cmake -S "$root" -B "$root/build" -G Ninja \
    -DCMAKE_C_COMPILER="${AST2LEAN_CC:-clang}" -DCMAKE_CXX_COMPILER="${AST2LEAN_CXX:-clang++}" \
    ${AST2LEAN_CLANG_SCAN_DEPS:+-DCMAKE_CXX_COMPILER_CLANG_SCAN_DEPS="$AST2LEAN_CLANG_SCAN_DEPS"} \
    -DCMAKE_BUILD_TYPE=Release
  ninja -C "$root/build"
fi

check_contains() {
  local label=$1 needle=$2 haystack=$3
  if ! grep -Fq -- "$needle" <<<"$haystack"; then
    echo "FAIL [$label]: expected to find: $needle" >&2
    exit 1
  fi
}

out_expf=$("$bin" "$root/test/expf_sample.cpp" --function=math::expf --name=expf \
  --drop-effects -Wno-undefined-inline -DLIBC_NAMESPACE=__llvm_libc)
check_contains "expf-config"   "def config : Libc.MathConfig :="      "$out_expf"
check_contains "expf-meta"     "def kernelMeta : Libc.KernelMeta :="  "$out_expf"
check_contains "expf-kernel"   "def kernel : Libc.UnaryKernel .binary32 :=" "$out_expf"
check_contains "expf-table"    "def EXP_M1 : Array (Model .binary64)" "$out_expf"
check_contains "expf-nearest"  "Libc.nearestInt config mode"          "$out_expf"
check_contains "expf-poly"     "horner[config, mode] r ["             "$out_expf"
check_contains "expf-option"   "(x : Model .binary32) : Option (Model .binary32) := do" "$out_expf"
check_contains "expf-join"     "let cont (_ : Unit) : Option (Model .binary32) := do" "$out_expf"
# Operations that C++ leaves undefined are emitted as checked ones.
check_contains "expf-fptosi"   "← Libc.fptosi? 32" "$out_expf"
check_contains "expf-index"    "← EXP_M1["          "$out_expf"
check_contains "expf-fpbits"   "Libc.FPBits.isInf xbits"              "$out_expf"

out_dyadic=$("$bin" "$root/test/dyadic_sample.cpp" --function=accurate_kernel)
check_contains "dyadic-table"  "0xAAAAAAAAAAAAAAAA5555555555555555#128" "$out_dyadic"
check_contains "dyadic-dd"     "Libc.NumberPair.exactMult config mode"  "$out_dyadic"
check_contains "dyadic-poly"   "horner[config, mode] dx ["              "$out_dyadic"
check_contains "dyadic-except" "Libc.ExceptValues.lookup config mode MY_EXCEPTS" "$out_dyadic"
check_contains "dyadic-except-fields" "rndTowardZero := 0x402DF854#32" "$out_dyadic"
check_contains "dyadic-fastas" "Libc.DyadicFloat.fastAs config .binary64 mode total" "$out_dyadic"
check_contains "dyadic-match"  "match Libc.quickGetRound mode with"     "$out_dyadic"

out_mut=$("$bin" "$root/test/dyadic_sample.cpp" --function=mutating_and_templates --strict)
check_contains "mut-set-sign"  "let fb := Libc.FPBits.setSign fb"       "$out_mut"
check_contains "mut-fast2sum"  "Libc.NumberPair.exactAdd mode"          "$out_mut"
check_contains "mut-fast2sum-f" "false"                                 "$out_mut"
check_contains "mut-splitb"    "Libc.NumberPair.exactMult config mode s.hi" "$out_mut"
check_contains "mut-splitb-28" " 28"                                    "$out_mut"
check_contains "mut-binary"    "def kernel : Libc.BinaryKernel .binary32 :=" "$out_mut"
check_contains "mut-keyword"   "(to' : Model .binary32)"                "$out_mut"
check_contains "mut-local-tbl" "def LOCAL_SCALE : Array (Model .binary64)" "$out_mut"

out_horner=$("$bin" "$root/test/dyadic_sample.cpp" --function=manual_horner)
# The coefficient list is longer than a line, so the emitter breaks it after a comma.
check_contains "horner-fold"   "horner[config, mode] r [f64(0x3FF0000000000000#64), f64(0x3FE0000000000000#64)," "$out_horner"
check_contains "horner-wrap"   "    f64(0x3FC5555555555555#64), f64(0x3FA5555555555555#64)]" "$out_horner"
if awk 'length > 100' <<<"$out_expf" | grep -q "f64("; then
  echo "FAIL [table-width]: a table row of the generated module is longer than 100 columns" >&2
  exit 1
fi

out_loop=$("$bin" "$root/test/dyadic_sample.cpp" --function=loop_reduce)
check_contains "loop-bounded"  "for _ in [:65536] do" "$out_loop"
check_contains "loop-cond"     "if !(BitVec.slt i n) then break" "$out_loop"

out_sol=$("$bin" "$root/test/dyadic_sample.cpp" --function=struct_outparam_lambda \
  --follow-helpers --strict)
check_contains "sol-struct"    "structure ReducedPair where" "$out_sol"
check_contains "sol-outparam"  "let (__cond_0, r) ← try_reduce mode x" "$out_sol"
check_contains "sol-lambda"    "let apply_sign (v : Model .binary64) : Option (Model .binary64)" "$out_sol"

out_cfg=$("$bin" "$root/test/expf_sample.cpp" --dump-config -Wno-undefined-inline -DLIBC_NAMESPACE=__llvm_libc)
check_contains "dump-config"   "MathConfig:" "$out_cfg"
check_contains "dump-arch"     "arch                    = x86_64" "$out_cfg"
check_contains "dump-x86-isa"  "CPU_X86_ISA" "$out_cfg"

echo "All ast2lean smoke tests passed."
