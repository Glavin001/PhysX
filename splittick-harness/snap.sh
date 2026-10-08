#!/bin/bash
# snap.sh <variant>: freeze the current private install's lib dir and bench binary as a variant.
V=/private/tmp/claude-501/splittick/variants/$1
[ -e "$V" ] && { echo "variant $1 exists"; exit 2; }
mkdir -p $V
cp -R /Users/glavin/Development/PhysX/.claude/worktrees/splittick/out/install/macos-cumetal/release/lib $V/lib
cp /private/tmp/claude-501/splittick/cargo/release/deps/web_fps_server-c88140cb4ccdc8ac $V/bench
git -C /Users/glavin/Development/PhysX/.claude/worktrees/splittick log -1 --format='physx %h %s' > $V/identity.txt
git -C /Users/glavin/Development/PhysX/.claude/worktrees/splittick status --short >> $V/identity.txt
git -C /Users/glavin/Development/cuda-metal/.claude/worktrees/splittick log -1 --format='cuda-metal %h %s' >> $V/identity.txt
git -C /Users/glavin/Development/cuda-metal/.claude/worktrees/splittick status --short 2>/dev/null >> $V/identity.txt
echo "snapped $1"; cat $V/identity.txt
