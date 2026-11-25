#!/usr/bin/env bash
# Compare an AST-extracted Lean binary32 kernel against compiled LLVM libc C++.
#
#   scripts/difftest-f32.sh --fn=<fn> --plan=<plan> <llvm-project>/libc [quick|dense]
#
# Two float results agree when they have identical bits or are both NaN.
# Integer and boolean results must match bit-for-bit (for `remquof`, low 3 bits and sign).
set -euo pipefail

if [[ ${1:-} != --fn=* || ${2:-} != --plan=* || $# -lt 3 ]]; then
  echo "usage: scripts/difftest-f32.sh --fn=<fn> --plan=<plan> <llvm-libc> [quick|dense]" >&2
  exit 2
fi
fn=${1#--fn=}
plan=${2#--plan=}
libc=$3
suite=${4:-quick}

root=$(cd "$(dirname "$0")/.." && pwd)
out="$root/extract/build/difftest-f32/${fn}__${plan}"
jobs=${JOBS:-8}
mkdir -p "$out"

# Select C++ signature macro, output comparison mode, and input shape.
sig="SIG_U_F32"
cmp_kind="f32_1"
case "$fn" in
  copysignf|fdimf|fmaxf|fminf|fmaximumf|fminimumf|fmaximum_numf|fminimum_numf|\
  fmaximum_magf|fminimum_magf|fmaximum_mag_numf|fminimum_mag_numf|\
  hypotf|atan2f|powf|fmodf|remainderf|nextafterf)
    sig="SIG_B_F32"; cmp_kind="f32_1_in2" ;;
  fmaf)
    sig="SIG_T_F32"; cmp_kind="f32_1_in3" ;;
  ilogbf|iscanonicalf|isnanf|issignalingf)
    sig="SIG_U_F32_I32"; cmp_kind="exact_1" ;;
  llogbf|lrintf|lroundf)
    sig="SIG_U_F32_LONG"; cmp_kind="exact_1" ;;
  llrintf|llroundf)
    sig="SIG_U_F32_LLONG"; cmp_kind="exact_1" ;;
  frexpf)
    sig="SIG_U_F32_OUT_I32"; cmp_kind="f32_i32" ;;
  modff)
    sig="SIG_U_F32_OUT_F32"; cmp_kind="f32_2" ;;
  sincosf)
    sig="SIG_U_F32_OUT_F32_F32"; cmp_kind="f32_2" ;;
  remquof)
    sig="SIG_B_F32_OUT_I32"; cmp_kind="remquo" ;;
  ldexpf|scalbnf)
    sig="SIG_U_F32_IN_I32"; cmp_kind="f32_1_in2" ;;
  scalblnf)
    sig="SIG_U_F32_IN_LONG"; cmp_kind="f32_1_in2" ;;
  fromfpf|fromfpxf|ufromfpf|ufromfpxf)
    sig="SIG_U_F32_FROMFP"; cmp_kind="f32_1_in3" ;;
  totalorderf|totalordermagf)
    sig="SIG_B_PTR_I32"; cmp_kind="exact_1_in2" ;;
  getpayloadf)
    sig="SIG_U_PTR_F32"; cmp_kind="f32_1" ;;
  canonicalizef)
    sig="SIG_U_OUT_PTR_I32"; cmp_kind="i32_f32" ;;
  setpayloadf|setpayloadsigf)
    sig="SIG_U_OUT_F32_I32"; cmp_kind="i32_f32" ;;
esac

# Map plan names to exact LLVM libc compiler flags and supported rounding modes.
extra_flags=()
modes="nearest up down zero"
upper_fn=$(echo "$fn" | tr '[:lower:]' '[:upper:]')
case "$plan" in
  sse2|double_eval|double_eval_sse2|generic)
    extra_flags=(-mno-sse4.2 -mno-fma) ;;
  ssse3|double_eval_ssse3)
    extra_flags=(-mssse3 -mno-sse4.2 -mno-fma) ;;
  sse42|double_eval_sse42|builtin_sse42)
    extra_flags=(-msse4.2 -mno-fma) ;;
  avx2_fma|double_eval_fma|double_eval_avx2_fma)
    extra_flags=(-mavx2 -mfma) ;;
  integer_eval)
    extra_flags=(-mno-sse4.2 -mno-fma "-DLIBC_MATH_${upper_fn}_IMPL=integer_eval" -DLIBC_MATH=0x2C)
    modes="nearest" ;;
  float_eval)
    extra_flags=(-mavx2 -mfma "-DLIBC_MATH_${upper_fn}_IMPL=float_eval" -DLIBC_MATH=0x3F)
    modes="nearest" ;;
  float_eval_cr_rn)
    extra_flags=(-mavx2 -mfma "-DLIBC_MATH_${upper_fn}_IMPL=float_eval_cr_rn" -DLIBC_MATH=0x3E)
    modes="nearest" ;;
  skip_accurate_sse2)
    extra_flags=(-mno-sse4.2 -mno-fma -DLIBC_MATH=0x04) ;;
  skip_accurate_fma)
    extra_flags=(-mavx2 -mfma -DLIBC_MATH=0x04) ;;
  *)
    echo "error: unknown plan '$plan'" >&2
    exit 2 ;;
esac

libc_flags=(-std=gnu++17 -O3 -fno-vectorize -fno-slp-vectorize -I "$libc" \
  -DLIBC_NAMESPACE=__llvm_libc -DLIBC_FULL_BUILD -DNDEBUG "${extra_flags[@]}")
clang++ "${libc_flags[@]}" -c -o "$out/fn.o" "$libc/src/math/generic/${fn}.cpp"
clang++ "${libc_flags[@]}" -c -o "$out/libc_errno.o" "$libc/src/errno/libc_errno.cpp"
clang++ -O2 -frounding-math "-DFN_NAME=${fn}" "-DFN_SIG=${sig}" \
  -c -o "$out/native.o" "$root/test/difftest/f32_native.cpp"
clang++ -o "$out/f32-native" "$out/native.o" "$out/fn.o" "$out/libc_errno.o"

model="$root/.lake/build/bin/difftest-f32-model"
if [[ ! -x "$model" ]]; then
  echo "error: build difftest-f32-model first (lake build difftest-f32-model)" >&2
  exit 2
fi

run_unary_mode() {
  local mode=$1
  local ranges=(
    00000000 1 16
    007FFFF8 1 16
    80000000 1 16
    807FFFF8 1 16
    3EFFFFFF 1 16
    3F7FFFF8 1 16
    3FC90FD4 1 16
    40490FD4 1 16
    7F7FFFF8 1 16
    7F800000 1 8
    7FC00000 1 8
    FF7FFFF8 1 16
    FF800000 1 8
    FFC00000 1 8
    BF7FFFF8 1 16
    00000000 2097143 2048
  )
  if [[ "$suite" == "dense" ]]; then
    ranges+=(00000000 131071 32768)
  fi
  paste -d' ' <("$model" "--fn=$fn" "--plan=$plan" "$mode" "${ranges[@]}") \
              <("$out/f32-native" "$mode" "${ranges[@]}") |
    awk -v fn="$fn" -v plan="$plan" -v mode="$mode" -v ck="$cmp_kind" '
      function nan(b) { return b ~ /^[7f]f[89a-f]/ && b !~ /^[7f]f800000$/ }
      function fagree(a, b) { return a == b || (nan(a) && nan(b)) }
      {
        ok = 0
        if (ck == "f32_1") ok = (NF == 4 && $1 == $3 && fagree($2, $4))
        else if (ck == "exact_1") ok = (NF == 4 && $1 == $3 && $2 == $4)
        else if (ck == "f32_i32") ok = (NF == 6 && $1 == $4 && fagree($2, $5) && (nan($2) || $3 == $6))
        else if (ck == "f32_2") ok = (NF == 6 && $1 == $4 && fagree($2, $5) && fagree($3, $6))
        else if (ck == "i32_f32") ok = (NF == 6 && $1 == $4 && $2 == $5 && fagree($3, $6))
        if (!ok) {
          if (++mism <= 10) print "mismatch", fn, plan, mode, $0
        }
        n++
      }
      END {
        printf "[%s/%s] %s: %d inputs, %d mismatches\n", fn, plan, mode, n, mism
        exit (mism > 0 || n == 0)
      }'
}

gen_stdin_inputs() {
  python3 - "$sig" "$suite" <<'PY'
import sys
sig, suite = sys.argv[1], sys.argv[2]
vals = [
  0x00000000, 0x80000000, 0x00000001, 0x80000001, 0x007FFFFF, 0x00800000,
  0x3E800000, 0x3F000000, 0x3F3504F3, 0x3F800000, 0x3FC00000, 0x40000000,
  0x40400000, 0x40490FDB, 0x41200000, 0x42C80000, 0x4B000000, 0x5F000000,
  0x7F7FFFFF, 0x7F800000, 0x7FC00000, 0x7FA00001,
  0xBE800000, 0xBF000000, 0xBF800000, 0xBFC00000, 0xC0000000, 0xC0400000,
  0xC1200000, 0xFF7FFFFF, 0xFF800000, 0xFFC00000, 0xFFA00001,
  0x3F7FFFFF, 0x3F800001, 0x3F123456, 0xBF987654, 0x43210FED, 0xC456789A
]
if sig in ("SIG_B_F32", "SIG_B_F32_OUT_I32", "SIG_B_PTR_I32"):
    for x in vals:
        for y in vals:
            print(f"{x:08x} {y:08x}")
elif sig == "SIG_T_F32":
    sub = vals[:20]
    for x in sub:
        for y in sub[:12]:
            for z in sub[:12]:
                print(f"{x:08x} {y:08x} {z:08x}")
elif sig == "SIG_U_F32_IN_I32":
    exps = [0, 1, -1, 2, -2, 10, -10, 126, -126, 127, -127, 128, -128, 150, -150, 300, -300, 0x7FFFFFFF, -0x7FFFFFFF]
    for x in vals:
        for k in exps:
            print(f"{x:08x} {k & 0xFFFFFFFF:08x}")
elif sig == "SIG_U_F32_IN_LONG":
    exps = [0, 1, -1, 10, -10, 127, -127, 300, -300, 1000000, -1000000]
    for x in vals:
        for k in exps:
            print(f"{x:08x} {k & 0xFFFFFFFFFFFFFFFF:016x}")
elif sig == "SIG_U_F32_FROMFP":
    for x in vals:
        for rnd in (0, 1, 2, 3, 4):
            for w in (0, 1, 4, 8, 16, 24, 32, 64):
                print(f"{x:08x} {rnd:08x} {w:08x}")
PY
}

run_stdin_mode() {
  local mode=$1
  local inp
  inp=$(mktemp)
  trap 'rm -f "$inp"' RETURN
  gen_stdin_inputs >"$inp"
  paste -d' ' <("$model" "--fn=$fn" "--plan=$plan" "$mode" --stdin <"$inp") \
              <("$out/f32-native" "$mode" --stdin <"$inp") |
    awk -v fn="$fn" -v plan="$plan" -v mode="$mode" -v ck="$cmp_kind" '
      function nan(b) { return b ~ /^[7f]f[89a-f]/ && b !~ /^[7f]f800000$/ }
      function fagree(a, b) { return a == b || (nan(a) && nan(b)) }
      {
        ok = 0
        if (ck == "f32_1_in2") ok = (NF == 6 && $1 == $4 && $2 == $5 && fagree($3, $6))
        else if (ck == "exact_1_in2") ok = (NF == 6 && $1 == $4 && $2 == $5 && $3 == $6)
        else if (ck == "f32_1_in3") ok = (NF == 8 && $1 == $5 && $2 == $6 && $3 == $7 && fagree($4, $8))
        else if (ck == "remquo") ok = (NF == 8 && $1 == $5 && $2 == $6 && fagree($3, $7) && (nan($3) || $4 == $8))
        if (!ok) {
          if (++mism <= 10) print "mismatch", fn, plan, mode, $0
        }
        n++
      }
      END {
        printf "[%s/%s] %s: %d inputs, %d mismatches\n", fn, plan, mode, n, mism
        exit (mism > 0 || n == 0)
      }'
}

is_stdin=0
case "$sig" in
  SIG_B_F32|SIG_T_F32|SIG_B_F32_OUT_I32|SIG_U_F32_IN_I32|SIG_U_F32_IN_LONG|SIG_U_F32_FROMFP|SIG_B_PTR_I32)
    is_stdin=1 ;;
esac

for mode in $modes; do
  if [[ "$is_stdin" == "1" ]]; then
    run_stdin_mode "$mode"
  else
    run_unary_mode "$mode"
  fi
done
