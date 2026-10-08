#!/bin/bash
# mklib.sh <name>: lib-<name> = lib-base with this worktree's freshly built GPU dylibs.
P=/Users/glavin/Development/vibe-land/target/perf-tools/steady
A=/Users/glavin/Development/PhysX/.claude/worktrees/steady/out/build/macos-cumetal/release/gpu/artifacts/bin/mac.arm64/release
D=$P/lib-$1; rm -rf $D; mkdir -p $D
cp -p $P/lib-base/libcumetal.dylib $D/; ln -s $P/lib-base/cumetal-pipeline-archive $D/cumetal-pipeline-archive
cp -p $A/libPhysXDestructionGpuRuntime_64.dylib $A/libPhysXGpuActivity_64.dylib $D/
shasum $D/*.dylib $P/lib-base/*.dylib | sort | awk '{print $1, $2}'
