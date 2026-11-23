#!/usr/bin/env bash
# Extract one LLVM libc math function to Lean.
#
#   extract/extract.sh <llvm-project>/libc <entrypoint> <function> <lean-name>
#
# <entrypoint> names the source file src/math/generic/<entrypoint>.cpp, and <function> is the
# function to export, relative to the libc namespace. Example:
#
#   extract/extract.sh ~/llvm-project/libc expf math::double_eval::expf expf
#
# The entrypoint is compiled for x86-64 with libc's default configuration, which includes the
# accurate passes, and at the optimization level of a release build.
set -euo pipefail

libc=$1 entrypoint=$2 function=$3 name=$4
root=$(cd "$(dirname "$0")/.." && pwd)
build=$root/extract/build

cmake -S "$root/extract" -B "$build" -G Ninja -DCMAKE_BUILD_TYPE=Release >/dev/null
ninja --quiet -C "$build"

# The vectorizers are off because vector instructions are outside the exported fragment.
clang++ -std=gnu++17 -O3 -fno-vectorize -fno-slp-vectorize \
  -I "$libc" -DLIBC_NAMESPACE=__llvm_libc \
  -fpass-plugin="$build/MarkCoreOps.so" \
  -S -emit-llvm -o "$build/$entrypoint.ll" "$libc/src/math/generic/$entrypoint.cpp"

origin="llvm-project $(git -C "$libc" rev-parse --short=12 HEAD), $(clang++ --version | head -n1), x86-64"
"$build/ir2lean" "$build/$entrypoint.ll" --function="$function" --name="$name" \
  --origin="$origin" \
  > "$root/LibcMath/Extracted/${name^}.lean"
