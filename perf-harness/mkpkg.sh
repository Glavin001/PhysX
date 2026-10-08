#!/bin/bash
# mkpkg.sh <name> [cumetal|physx|both]: cuda-metal/out/pkg/steady-<name> = steady-base with this
# session's freshly built libcumetal and/or PhysX GPU dylibs swapped into lib/.
N=/Users/glavin/Development/cuda-metal/out/pkg/steady-$1; what=${2:-both}
CM=/Users/glavin/Development/cuda-metal/.claude/worktrees/steady-tick/out/build/macos-cumetal/release
PX=/Users/glavin/Development/PhysX/.claude/worktrees/steady-tick/out/build/macos-cumetal/release/gpu/artifacts/bin/mac.arm64/release
[ -e $N ] && { echo "exists: $N"; exit 2; }
cp -Rc /Users/glavin/Development/cuda-metal/out/pkg/steady-base $N
case $what in cumetal|both) cp -p $CM/libcumetal.dylib $N/lib/ ;; esac
case $what in physx|both) cp -p $PX/libPhysXGpuActivity_64.dylib $PX/libPhysXDestructionGpuRuntime_64.dylib $N/lib/ ;; esac
echo "pkg $N ($what)"; shasum -a 256 $N/lib/*.dylib | awk '{print substr($1,1,12), $2}'
