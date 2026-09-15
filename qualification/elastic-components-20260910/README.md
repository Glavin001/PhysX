# GPU unknown components — 10 September 2026

The six-channel solver now constructs unknown components on the GPU. Shared
prescribed supports do not merge independent systems. Device-owned counts feed
bounded setup and solve dispatches without CPU count readback. Native runtime
integration, revision production and accepted material transactions remain open;
installed ABI V14 still uses the legacy stress solver.

## Validation

Seven six-channel CTests pass. Default and large component fixtures pass memcheck,
initcheck, synccheck and racecheck after the final parent-halving change (eight
runs). Setup passed the same four sanitizers before that isolated producer edit.
Exact commands, exits and loaded-module hashes are in each validation-runs.json.

Checks include shared supports against an independent dense solve, support release,
bond deletion, free singletons, empty/rejected graphs, and a 275-node network with
two 137-unknown systems sharing a prescribed support. Two solver blocks exercise
component reuse. Integer scan checks cover warp/block boundaries through 113,664
entries, including a multilevel 16,385-entry case.

The large mapping fixture has 113,664 nodes, 226,559 bonds, 256 components and
113,408 unknowns. Independent serial connectivity and stable ordering agree.
There are no projectiles or physics timesteps: this is not a city simulation.

## Selected hardware counters

RTX 5060 Ti, CUDA 13.4.59, Nsight Compute 2026.3.0. One selected launch per kernel
per version, ten replay passes per kernel; cache flush enabled, clocks unlocked,
desktop active. These are diagnostic kernel samples, not complete-step timings.

| Kernel | Before atomic parent halving | After | Registers/thread |
|---|---:|---:|---:|
| Union of unknown endpoints | 495.07 µs | 76.06 µs | 16 / 16 |
| Final root labels | 35.46 µs | 3.36 µs | 16 / 16 |

Union occupancy changed 73.07%→89.25%, DRAM throughput 4.10%→27.04%.
Shortening dependent parent walks reduced these measured kernel durations; this
single pair does not establish a repeatable or integrated speedup. Both versions
report zero spills. No-eligible-scheduler percentage actually rose 90.22%→97.15%,
so that percentage alone is not evidence of improvement or regression.

All four baseline/candidate plain/profiled mapping exports are byte-identical:
`1fb013e5d01c37f38d4bea669516f596e268d835ef39e43a73b6b94fba3940d4`.
The optimized producer is retained, with native performance qualification pending.

## Failed attempt and provenance

The initial CUB inclusive scan produced correct sums but three initialization
findings at the 275-node consumer. No vendor cause or exemption is established.
It was replaced with an explicit hierarchical integer scan; final checks pass
without output zeroing or suppression. Earlier readback of unused allocation tail
was also corrected to export only the active prefix.

Raw captures, failed binary/source, maps and profiler archives remain under
`out/elastic-components-20260910/`: `final/` is the failed scan attempt,
`verified/` is the pre-halving baseline, and `halving/` is the current candidate.
The earlier `attempt-1/` used a different tree graph and is not the matched baseline.
Current source and binary hashes and a focused source patch accompany this report.
No native physical-equivalence gates were waived. No owned jobs remain live.
