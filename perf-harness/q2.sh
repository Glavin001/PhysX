#!/bin/bash
H=/Users/glavin/Development/PhysX/.claude/worktrees/steady-tick/perf-harness
# trace pair on the same libcumetal: streams separate vs serialized
SCEN=city_wreck $H/ab.sh ser1off-s steady-ser1 VIBE_PERF_ALL_TICKS=1 VIBE_PERF_MARKERS=1 CUMETAL_TRACE_SYNC=1 CUMETAL_TRACE_COMMITS=1
SCEN=city_wreck $H/ab.sh ser1on-s steady-ser1 VIBE_PERF_ALL_TICKS=1 VIBE_PERF_MARKERS=1 CUMETAL_TRACE_SYNC=1 CUMETAL_TRACE_COMMITS=1 CUMETAL_SERIALIZE_STREAMS=1
SCEN=city_wreck $H/ab.sh ser1on-t steady-ser1 VIBE_PERF_ALL_TICKS=1 CUMETAL_SERIALIZE_STREAMS=1
SCEN=city_wreck $H/ab.sh ser1off-t steady-ser1 VIBE_PERF_ALL_TICKS=1
