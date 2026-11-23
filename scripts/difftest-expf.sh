#!/usr/bin/env bash
# Compare the Lean model of expf with the machine code of LLVM libc's expf.
#
#   scripts/difftest-expf.sh <llvm-project>/libc quick
#   scripts/difftest-expf.sh <llvm-project>/libc dense [<step>]
#   scripts/difftest-expf.sh <llvm-project>/libc range <first> <last> [<step>]
#
# The Lean side is the interpreter on LibcMath/Extracted/Expf.lean. The native side is expf.cpp
# compiled as extract/extract.sh compiles it, once as it is and once with the MarkCoreOps plugin,
# and run on this machine. Every input is evaluated in the four rounding modes. Two results agree
# when they have the same bits or are both NaN.
#
#   quick   special values with their neighbours, and patterns spread over all of binary32
#   dense   every <step>-th pattern (default 51) of the ranges 0x33800000-0x42B17217 and
#           0xB3000001-0xC2CFF1B4, where the result comes from the main computation
#   range   every <step>-th pattern (default 1) from <first> to <last>, both hexadecimal
#
# JOBS sets the number of parallel processes (default 8).
set -euo pipefail

libc=$1 suite=$2
shift 2
root=$(cd "$(dirname "$0")/.." && pwd)
build=$root/extract/build
out=$build/difftest
jobs=${JOBS:-8}
modes="nearest up down zero"

cmake -S "$root/extract" -B "$build" -G Ninja -DCMAKE_BUILD_TYPE=Release >/dev/null
ninja --quiet -C "$build" MarkCoreOps
mkdir -p "$out"

# The flags of extract/extract.sh.
libc_flags=(-std=gnu++17 -O3 -fno-vectorize -fno-slp-vectorize -I "$libc" -DLIBC_NAMESPACE=__llvm_libc)
expf=$libc/src/math/generic/expf.cpp
clang++ "${libc_flags[@]}" -c -o "$out/expf.o" "$expf"
clang++ "${libc_flags[@]}" -fpass-plugin="$build/MarkCoreOps.so" -c -o "$out/expf-coreops.o" "$expf"
clang++ "${libc_flags[@]}" -c -o "$out/libc_errno.o" "$libc/src/errno/libc_errno.cpp"
clang++ -O2 -frounding-math -c -o "$out/expf_native.o" "$root/test/difftest/expf_native.cpp"
clang++ -o "$out/expf-native" "$out/expf_native.o" "$out/expf.o" "$out/libc_errno.o"
clang++ -o "$out/expf-native-coreops" "$out/expf_native.o" "$out/expf-coreops.o" "$out/libc_errno.o"

(cd "$root" && lake build -q difftest-expf-model)
model=$root/.lake/build/bin/difftest-expf-model

# Print the ranges "<first> <step> <count>" of a suite, one per line.
ranges() {
  case $suite in
  quick)
    # Zeros, subnormals, exponent boundaries (which include the powers of two and the infinities),
    # NaNs, the thresholds of the special cases, and the hardest-to-round input 0xC236BD8C, each
    # with two neighbours on either side.
    local centers=(00000001 007FFFFF 80000001 807FFFFF 7FC00000 FFC00000 7FA5A5A5 FFA5A5A5
      7FFFFFFF FFFFFFFF C236BD8C 42B17217 C2CFF1B4 42B20000 3FC00000 BFC00000)
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

# Split the ranges on standard input into ranges of at most 2^16 inputs.
split_ranges() {
  local first step count chunk=65536
  while read -r first step count; do
    for ((done = 0; done < count; done += chunk)); do
      printf '%08X %d %d\n' $(((0x$first + done * step) & 0xFFFFFFFF)) "$step" \
        $((count - done < chunk ? count - done : chunk))
    done
  done
}

# Compare the three programs on ranges in one mode. Prints "compared <mode> <inputs>" and one line
# per disagreement: the mode, the input, and the results of the model, of the function as compiled
# and of the function compiled with the plugin.
compare() {
  local mode=$1
  shift
  paste -d' ' <("$model" "$mode" "$@") <("$out/expf-native" "$mode" "$@") \
    <("$out/expf-native-coreops" "$mode" "$@") |
    awk -v mode="$mode" '
      function nan(bits) { return bits ~ /^[7f]f[89a-f]/ && bits !~ /^[7f]f800000$/ }
      function agree(a, b) { return a == b || (nan(a) && nan(b)) }
      NF != 6 || $1 != $3 || $1 != $5 || !agree($2, $4) || !agree($2, $6) {
        print "mismatch", mode, $1, $2, $4, $6
      }
      END { print "compared", mode, NR }'
}
export -f compare
export model out

results=$(mktemp)
trap 'rm -f "$results"' EXIT
start=$SECONDS
# One task is a mode and sixteen ranges.
for mode in $modes; do
  ranges "$@" | split_ranges | xargs -n 48 echo "$mode"
done | xargs -P "$jobs" -L 1 bash -c 'compare "$@"' _ >"$results"

expected=$(ranges "$@" | awk '{ n += $3 } END { print n }')
awk -v expected="$expected" -v seconds=$((SECONDS - start)) '
  $1 == "compared" { compared[$2] += $3 }
  $1 == "mismatch" { if (++mismatches <= 20) print }
  END {
    split("nearest up down zero", modes, " ")
    for (i = 1; i <= 4; i++) {
      printf "%s: %d inputs compared\n", modes[i], compared[modes[i]]
      if (compared[modes[i]] != expected) incomplete = 1
    }
    printf "%d mismatches in %d seconds\n", mismatches, seconds
    if (incomplete) print "error: expected " expected " inputs in every mode"
    exit mismatches > 0 || incomplete
  }' "$results"
