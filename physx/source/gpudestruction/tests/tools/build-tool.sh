#!/bin/bash
# build-tool.sh NAME|FILE.cu: compile physx/source/gpudestruction/tests/NAME.cu as the gpudestruction
# tests are (cumetalc, the garage build's flags) into $OUT/NAME${SUFFIX}. EXTRA: more cumetalc
# flags (e.g. EXTRA=-DEX_THREADS=512 SUFFIX=-t512). SRC_ROOT=<checkout> builds another checkout's source.
set -e
. "$(dirname "$0")/env.sh"
SRC=${SRC_ROOT:-$W}
case $1 in *.cu) SRCF=$(cd "$(dirname "$1")" && pwd)/$(basename "$1"); NAME=$(basename "$1" .cu);; *) SRCF=$SRC/physx/source/gpudestruction/tests/$1.cu; NAME=$1;; esac
mkdir -p "$OUT"; cd "$OUT"
SDK=$(xcrun --sdk macosx --show-sdk-path)
log=$("$CM/cumetalc" "$SRCF" -c --backend=cumetal-ir --cuda-clang "$CUDA_CLANG" --fp64=ieee64 -std=c++17 --cooperative-resident-grid \
  -DPX_CUMETAL_INLINE_REF_GJK_EPA=1 -I"$B/physx/include" -I"$CUMETAL_ROOT/runtime/api" -I"$SRC/blast/include/extensions/stress" \
  -I"$SRC/physx/source/gpudestruction/include" -I"$SRC/physx/include" -DPX_CUMETAL=1 -DPXG_TGS_WHOLE_ISLAND_MAX_BODIES=512 \
  -DPX_CUMETAL_SPLIT_RESPONSE_STAMP=1 -DPX_CUMETAL_SERIAL_CONTACT_IDS=1 -DPX_CUMETAL_DISABLE_GPU_SDF_BUILDER=1 -DPX_CUMETAL_DISABLE_CONVEX_CORE=1 \
  -DPX_CUMETAL_PACK_BOND_STRESS_SCALARS=1 -DPX_CUMETAL_BLOCK_VOTED_TRAPS=1 -DPX_CUMETAL_EXPLICIT_HIERARCHY_ROOT=1 -DPX_CUMETAL_EXPLICIT_AGGREGATE_ROOT=1 \
  -DPX_CUMETAL_EXPLICIT_MOTION_ROOT=1 $EXTRA -o "$OUT/$NAME${SUFFIX}.o" 2>&1) || true
printf '%s\n' "$log" | grep -v "^CUMETAL WARNING" || true
# cumetalc can exit 0 on a failed device compile (and leave the last object): fail on its message.
if printf '%s\n' "$log" | grep -q "cumetalc failed"; then echo "build-tool: $NAME failed" >&2; exit 1; fi
xcrun clang++ -O3 -arch arm64 -isysroot "$SDK" -mmacosx-version-min=14.4 "$OUT/$NAME${SUFFIX}.o" -o "$OUT/$NAME${SUFFIX}" -Wl,-rpath,"$CM" "$CM/libcumetal.dylib"
echo "built $OUT/$NAME${SUFFIX}"
