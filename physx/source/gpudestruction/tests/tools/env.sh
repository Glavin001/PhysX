# Sourced by the tools here: where things are, from this checkout and its build.
#   W     this PhysX checkout (from the script's own location)
#   B     a configured garage build of it (PHYSX_BUILD; default $W/out/build/garage-impact,
#         else the first sibling worktree's): its generated PxConfig.h and CMake cache
#   CM    the cuda-metal build (CUMETAL_BUILD; default: the build's CMake cache)
#   OUT   where tools are built (TOOLS_OUT; default $W/out/tools, git-ignored)
#   G     vibe-land's gpu-run.sh (VIBE_LAND; default ~/Development/vibe-land)
#   F     the gpudestruction test fixtures
TOOLS_DIR=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)
W=$(git -C "$TOOLS_DIR" rev-parse --show-toplevel)
if [ -n "${PHYSX_BUILD:-}" ]; then B=$PHYSX_BUILD
elif [ -f "$W/out/build/garage-impact/destruction/CMakeCache.txt" ]; then B=$W/out/build/garage-impact
else B=$(ls -d "$(dirname "$W")"/*/out/build/garage-impact "$(git -C "$W" rev-parse --path-format=absolute --git-common-dir)"/../out/build/garage-impact 2>/dev/null | while read -r d; do [ -f "$d/destruction/CMakeCache.txt" ] && echo "$d" && break; done)
fi
[ -n "$B" ] && [ -f "$B/destruction/CMakeCache.txt" ] || { echo "env.sh: no configured garage build; set PHYSX_BUILD" >&2; return 1 2>/dev/null || exit 1; }
cache() { sed -n "s|^$1:[A-Z]*=||p" "$B/destruction/CMakeCache.txt" | head -1; }
CM=${CUMETAL_BUILD:-$(dirname "$(cache CUMETALC_EXECUTABLE)")}
CUDA_CLANG=${CUDA_CLANG:-$(cache CUMETAL_CUDA_CLANG)}
CUMETAL_ROOT=${CUMETAL_ROOT:-$(cache CUMETAL_ROOT_DIR)}
OUT=${TOOLS_OUT:-$W/out/tools}
VIBE_LAND=${VIBE_LAND:-$HOME/Development/vibe-land}
G=$VIBE_LAND/scripts/perf/gpu-run.sh
F=$W/physx/source/gpudestruction/tests/fixtures
