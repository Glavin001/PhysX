#!/bin/bash
# ab.sh <n> <tag> <variantA> <variantB> [ENV=VAL...]: interleaved A/B meteor runs, then pooled split stats.
H=/Users/glavin/Development/PhysX/.claude/worktrees/splittick/splittick-harness
n=$1;tag=$2;A=$3;B=$4;shift 4
for i in $(seq 1 $n); do $H/run.sh $A $tag "$@"; $H/run.sh $B $tag "$@"; done
cd /private/tmp/claude-501/splittick/runs && python3 $H/splitstats.py $A.$tag.* $B.$tag.* | sed -n '/pooled/,$p'
