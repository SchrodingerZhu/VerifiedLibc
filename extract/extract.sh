#!/usr/bin/env bash
# Extract one LLVM libc math function to Lean using the C++23 Clang-AST extractor (`ast2lean`).
#
#   extract/extract.sh <llvm-project>/libc <entrypoint> <function> <lean-name> \
#     [--namespace=<ns>] [--out=<file>] [--variant=<name>] [-- <extra-clang-flags...>]
#
# Examples:
#   extract/extract.sh ~/llvm-project/libc expf math::double_eval::expf expf \
#     --namespace=LibcMath.Kernels.Expf.Generated.DoubleEval \
#     --out=LibcMath/Kernels/Expf/Generated/DoubleEval.lean
#
#   extract/extract.sh ~/llvm-project/libc expf math::integer_eval::expf expf \
#     --namespace=LibcMath.Kernels.Expf.Generated.IntegerEval \
#     --out=LibcMath/Kernels/Expf/Generated/IntegerEval.lean \
#     -- -DLIBC_MATH_EXPF_IMPL=integer_eval -DLIBC_MATH=0x2C
set -euo pipefail

libc=$1 entrypoint=$2 function=$3 name=$4
shift 4

root=$(cd "$(dirname "$0")/.." && pwd)
build=$root/extract/build
ns="LibcMath.${name^}.Generated"
out="$root/LibcMath/${name^}/Generated/${name^}.lean"
variant=""
extra_clang=()

while [[ $# -gt 0 ]]; do
  case "$1" in
    --namespace=*) ns="${1#--namespace=}"; shift ;;
    --out=*)       out="${1#--out=}"; shift ;;
    --variant=*)   variant="${1#--variant=}"; shift ;;
    --)            shift; extra_clang=("$@"); break ;;
    *)             extra_clang+=("$1"); shift ;;
  esac
done

if [[ ! -x "$build/ast2lean" ]]; then
  cmake -S "$root/extract" -B "$build" -G Ninja \
    -DCMAKE_C_COMPILER="${AST2LEAN_CC:-clang}" -DCMAKE_CXX_COMPILER="${AST2LEAN_CXX:-clang++}" \
    ${AST2LEAN_CLANG_SCAN_DEPS:+-DCMAKE_CXX_COMPILER_CLANG_SCAN_DEPS="$AST2LEAN_CLANG_SCAN_DEPS"} \
    -DCMAKE_BUILD_TYPE=Release >/dev/null
fi
ninja --quiet -C "$build"

commit=$(git -C "$libc" rev-parse --short=12 HEAD 2>/dev/null || echo "unknown")
src_rel="src/math/generic/$entrypoint.cpp"

cmd=(
  "$build/ast2lean" "$libc/$src_rel"
  --function="$function"
  --name="$name"
  --namespace="$ns"
  --source-label="$src_rel"
  --source-commit="$commit"
  --drop-effects
  --follow-helpers
  --strict
)
if [[ -n "$variant" ]]; then
  cmd+=(--variant="$variant")
fi
cmd+=(-- -std=gnu++17 -I "$libc" -DLIBC_NAMESPACE=__llvm_libc "${extra_clang[@]}")

mkdir -p "$(dirname "$out")"
"${cmd[@]}" > "$out"
