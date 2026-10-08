#!/bin/bash
# multi.sh <planfile>: run every line "<tag> <pkg|-> [ENV=VAL...]" of the plan (SCEN from the line's
# SCEN=..., default city_wreck) as perf_bench runs inside ONE GPU lock acquisition.
H=/Users/glavin/Development/PhysX/.claude/worktrees/steady-tick/perf-harness
plan=$1
/Users/glavin/Development/vibe-land/scripts/perf/gpu-run.sh "steady-tick-multi" bash -c '
H='$H'
while read -r tag pkg rest; do
  [ -z "$tag" ] && continue; case $tag in \#*) continue;; esac
  scen=city_wreck; envs=()
  for kv in $rest; do case $kv in SCEN=*) scen=${kv#SCEN=};; *) envs+=("$kv");; esac; done
  SCEN=$scen NOLOCK=1 $H/ab.sh $tag $pkg VIBE_PERF_ALL_TICKS=1 "${envs[@]}"
done < '$plan
