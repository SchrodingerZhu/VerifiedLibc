#!/usr/bin/env bash
set -euo pipefail

root=$(cd "$(dirname "$0")/.." && pwd)
bin="$root/build/ast2lean"

if [[ ! -x "$bin" ]]; then
  cmake -S "$root" -B "$root/build" -G Ninja \
    -DCMAKE_C_COMPILER=clang -DCMAKE_CXX_COMPILER=clang++ -DCMAKE_BUILD_TYPE=Release
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
check_contains "expf-config"   "def config : Core.MathConfig :="      "$out_expf"
check_contains "expf-meta"     "def kernelMeta : Core.KernelMeta :="  "$out_expf"
check_contains "expf-kernel"   "def kernel : Core.UnaryKernel .binary32 :=" "$out_expf"
check_contains "expf-table"    "def EXP_M1 : Array (Model .binary64)" "$out_expf"
check_contains "expf-nearest"  "Core.nearestInt config mode"          "$out_expf"
check_contains "expf-poly"     "horner[config, mode] r ["             "$out_expf"
check_contains "expf-join"     "let cont (_ : Unit) : Model .binary32" "$out_expf"
check_contains "expf-fpbits"   "Core.FPBits.isInf xbits"              "$out_expf"

out_dyadic=$("$bin" "$root/test/dyadic_sample.cpp" --function=accurate_kernel)
check_contains "dyadic-table"  "0xAAAAAAAAAAAAAAAA5555555555555555#128" "$out_dyadic"
check_contains "dyadic-dd"     "Core.NumberPair.exactMult config mode"  "$out_dyadic"
check_contains "dyadic-poly"   "horner[config, mode] dx ["              "$out_dyadic"
check_contains "dyadic-except" "Core.ExceptValues.lookup config mode MY_EXCEPTS" "$out_dyadic"
check_contains "dyadic-match"  "match Core.quickGetRound mode with"     "$out_dyadic"

out_horner=$("$bin" "$root/test/dyadic_sample.cpp" --function=manual_horner)
check_contains "horner-fold"   "horner[config, mode] r [f64(0x3FF0000000000000#64), f64(0x3FE0000000000000#64), f64(0x3FC5555555555555#64), f64(0x3FA5555555555555#64)]" "$out_horner"

out_loop=$("$bin" "$root/test/dyadic_sample.cpp" --function=loop_reduce)
check_contains "loop-do"       "Id.run do"           "$out_loop"
check_contains "loop-while"    "while BitVec.slt i n do" "$out_loop"

out_cfg=$("$bin" "$root/test/expf_sample.cpp" --dump-config -Wno-undefined-inline -DLIBC_NAMESPACE=__llvm_libc)
check_contains "dump-config"   "MathConfig:" "$out_cfg"

echo "All ast2lean smoke tests passed."
