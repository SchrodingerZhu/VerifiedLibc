#!/usr/bin/env bash
# Compare an AST-extracted Lean model of `expf` with compiled LLVM libc C++ machine code.
#
#   scripts/difftest-expf.sh --plan=<plan> <llvm-project>/libc quick
#   scripts/difftest-expf.sh --plan=<plan> <llvm-project>/libc dense [<step>]
#   scripts/difftest-expf.sh --plan=<plan> <llvm-project>/libc range <first> <last> [<step>]
#
# Plans (required):
#   double_eval      x86-64 non-FMA, all 4 rounding modes
#   double_eval_fma  -mavx2 -mfma, all 4 rounding modes
#   integer_eval     LIBC_MATH_EXPF_IMPL=integer_eval, LIBC_MATH=0x2C (RN only)
#   float_eval       -mavx2 -mfma, LIBC_MATH_EXPF_IMPL=float_eval, LIBC_MATH=0x3F (RN only)
#   float_eval_cr_rn -mavx2 -mfma, LIBC_MATH_EXPF_IMPL=float_eval_cr_rn, LIBC_MATH=0x3E (RN only)
#
# Two results agree when they have the same bits or are both NaN.
# JOBS sets the number of parallel processes (default 8).
set -euo pipefail

if [[ ${1:-} != --plan=* ]]; then
  echo "usage: scripts/difftest-expf.sh --plan=<plan> <llvm-project>/libc <quick|dense|range> ..." >&2
  exit 2
fi
plan=${1#--plan=}
shift

libc=$1 suite=$2
shift 2
root=$(cd "$(dirname "$0")/.." && pwd)
out=$root/extract/build/difftest/$plan
jobs=${JOBS:-8}

extra_cpp_flags=()
modes="nearest up down zero"
case "$plan" in
  double_eval)
    ;;
  double_eval_fma)
    extra_cpp_flags=(-mavx2 -mfma)
    ;;
  integer_eval)
    extra_cpp_flags=(-DLIBC_MATH_EXPF_IMPL=integer_eval -DLIBC_MATH=0x2C)
    modes="nearest"
    ;;
  float_eval)
    extra_cpp_flags=(-mavx2 -mfma -DLIBC_MATH_EXPF_IMPL=float_eval -DLIBC_MATH=0x3F)
    modes="nearest"
    ;;
  float_eval_cr_rn)
    extra_cpp_flags=(-mavx2 -mfma -DLIBC_MATH_EXPF_IMPL=float_eval_cr_rn -DLIBC_MATH=0x3E)
    modes="nearest"
    ;;
  *)
    echo "unknown plan: $plan" >&2
    exit 2
    ;;
esac

mkdir -p "$out"

libc_flags=(-std=gnu++17 -O3 -fno-vectorize -fno-slp-vectorize -I "$libc" -DLIBC_NAMESPACE=__llvm_libc "${extra_cpp_flags[@]}")
expf=$libc/src/math/generic/expf.cpp
clang++ "${libc_flags[@]}" -c -o "$out/expf.o" "$expf"
clang++ "${libc_flags[@]}" -c -o "$out/libc_errno.o" "$libc/src/errno/libc_errno.cpp"
clang++ -O2 -frounding-math -c -o "$out/expf_native.o" "$root/test/difftest/expf_native.cpp"
clang++ -o "$out/expf-native" "$out/expf_native.o" "$out/expf.o" "$out/libc_errno.o"

model=$root/.lake/build/bin/difftest-expf-model
if [[ ! -x "$model" ]]; then
  (cd "$root" && lake build -q difftest-expf-model)
fi

ranges() {
  case $suite in
  quick)
    local centers=(00000001 007FFFFF 80000001 807FFFFF 7FC00000 FFC00000 7FA5A5A5 FFA5A5A5
      7FFFFFFF FFFFFFFF C236BD8C 42B17217 42B17218 C2CFF1B4 C2CFF1B5 42B20000 3FC00000 BFC00000)
    for c in "${centers[@]}"; do
      printf '%08X 1 5\n' $(((0x$c - 2) & 0xFFFFFFFF))
    done
    for ((bits = 0; bits < 1 << 32; bits += 1 << 23)); do
      printf '%08X 1 5\n' $(((bits - 2) & 0xFFFFFFFF))
    done
    echo "00000000 1048573 4096"
    ;;
  dense)
    local step=${1:-51}
    echo "33800000 $step $(((0x42B17217 - 0x33800000) / step + 1))"
    echo "B3000001 $step $(((0xC2CFF1B4 - 0xB3000001) / step + 1))"
    ;;
  range)
    local step=${3:-1}
    echo "$1 $step $(((0x$2 - 0x$1) / step + 1))"
    ;;
  *)
    echo "unknown suite: $suite" >&2
    return 2
    ;;
  esac
}

split_ranges() {
  local first step count chunk=65536
  while read -r first step count; do
    for ((done = 0; done < count; done += chunk)); do
      printf '%08X %d %d\n' $(((0x$first + done * step) & 0xFFFFFFFF)) "$step" \
        $((count - done < chunk ? count - done : chunk))
    done
  done
}

compare() {
  local mode=$1
  shift
  paste -d' ' <("$model" "--plan=$plan" "$mode" "$@") <("$out/expf-native" "$mode" "$@") |
    awk -v mode="$mode" -v plan="$plan" '
      function nan(bits) { return bits ~ /^[7f]f[89a-f]/ && bits !~ /^[7f]f800000$/ }
      function agree(a, b) { return a == b || (nan(a) && nan(b)) }
      NF != 4 || $1 != $3 || !agree($2, $4) {
        print "mismatch", plan, mode, $1, $2, $4
      }
      END { print "compared", mode, NR }'
}
export -f compare
export model out plan

results=$(mktemp)
trap 'rm -f "$results"' EXIT
start=$SECONDS
for mode in $modes; do
  ranges "$@" | split_ranges | xargs -n 48 echo "$mode"
done | xargs -P "$jobs" -L 1 bash -c 'compare "$@"' _ >"$results"

expected=$(ranges "$@" | awk '{ n += $3 } END { print n }')
awk -v expected="$expected" -v seconds=$((SECONDS - start)) -v modes_str="$modes" -v plan="$plan" '
  $1 == "compared" { compared[$2] += $3 }
  $1 == "mismatch" { if (++mismatches <= 20) print }
  END {
    nmodes = split(modes_str, modes, " ")
    for (i = 1; i <= nmodes; i++) {
      printf "[%s] %s: %d inputs compared\n", plan, modes[i], compared[modes[i]]
      if (compared[modes[i]] != expected) incomplete = 1
    }
    printf "[%s] %d mismatches in %d seconds\n", plan, mismatches, seconds
    if (incomplete) print "error: expected " expected " inputs in every mode"
    exit mismatches > 0 || incomplete
  }' "$results"
