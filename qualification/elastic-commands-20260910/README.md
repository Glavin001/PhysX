# Explicit GPU chunk commands — 10 September 2026

The new private command evaluator supplies consistent per-node structural loads
and per-motion rigid force/torque totals from explicit authored-chunk commands.
See the [contract](../../docs/destruction/elastic-command-contract.md). Source is
uncommitted WIP on `1155b7ff`. The installed V12 native runtime and legacy stress
backend are unchanged by this step; it does not yet invoke this evaluator.
No public submission/wakeup path or exactly-once physical application is claimed.

## Numerical evidence

Six focused CTests pass. The command fixture uses 137 authored / 109 active
chunks, seven motion groups and 218 force/impulse commands, then splits to
14 groups while retaining the same authored command tape. Independent rotation
matrix and force/moment oracles verify both node and body outputs. Explicit
expiration, duplicate chunk contributions, stale queries, invalid/inactive
chunks, frames, units, capacity and accumulation overflow are checked.
An independent two-node axial case retains nonzero stress inputs despite zero
body resultant. The GPU command-to-load-adapter handoff passes; its completeness
assertion describes only the declared command-only/free-body algebra fixture.
All four CUDA sanitizers pass on the final command test binary.

A separate synthetic batch has 113,664 active chunks, 256 motion groups and
113,664 commands, half force-valued and half impulse-valued with an explicit
20 ms loading interval. It is a single algebra evaluation, not a city trajectory
or a change to the engine's 1/60 physical timestep. Its generated groups can span
over 11 km; that creates substantial opposing moment cancellation. Both final
independent oracles pass at the unchanged `2e-11 * (1 + abs(reference))` threshold.

The initial double-precision reference accumulation failed by about 2.36e-9 on
a body torque near -108.302. A wider independent rotation/COM/moment oracle
resolves the discrepancy without changing GPU arithmetic or acceptance limits.
Initial failure logs are retained. An earlier build also lacked the CUDA NaN
constant header; adding the explicit include fixed compilation. The existing
partition test fixture was extracted into a shared header for real partition
producer reuse; its tests still pass.

## Hardware counters

RTX 5060 Ti, sm_120, CUDA 13.4.59, driver 615.71.09, Nsight Compute 2026.3.0.
One counter capture of the synthetic large batch, ten replay passes per selected
kernel, cache flush on, clocks unlocked, desktop graphics active:

| Kernel | Profiler duration | Registers/thread | Achieved occupancy | DRAM / peak | Local/shared spills |
| --- | ---: | ---: | ---: | ---: | ---: |
| Command `resolve` | 101.95 µs | 62 | 60.67% | 36.48% | 0 / 0 |
| Motion `aggregate` | 33.57 µs | 56 | 54.43% | 58.60% | 0 / 0 |

Resolve launches 340,992 capacity threads for 113,664 active commands; aggregate
launches 256 blocks of 128 threads. These are individual kernel scopes, excluding
partition construction, clear/scatter/receipt/gate work, transfers and physics.
No integrated speedup is claimed. The complete node and body output buffers
match the final unprofiled batch byte-for-byte. Both profiled oracles pass.
The first filter used qualified names with function-only matching and collected
no kernels; it is retained separately. The corrected basename filter captures
both intended kernels. This does not resolve the native conditional-graph issue.

## Evidence and next integration

[receipt.json](receipt.json) records source/binary/module hashes and commands.
[source.patch](source.patch), [counters.txt](counters.txt) and
[counter-identity.json](counter-identity.json) retain results. Raw directory:
`out/elastic-commands-20260910/`. All owned jobs finished. Prior native migration,
golden and initialization failures remain unresolved; they were not rerun for
this standalone-only addition. Installed library hashes still match V12 evidence.

```bash
.toolchains/build-env/bin/cmake --build out/destruction-sdk --target stress_elastic_commands_test stress_elastic_partition_test --parallel 8
.toolchains/build-env/bin/ctest --test-dir out/destruction-sdk -R '^blast_stress_six_channel_' --output-on-failure -j1
out/destruction-sdk/reference/stress_elastic_commands_test --large out/command-NEW
```

Next build the native command submission/interval producer and wakeup boundary,
using original authored ancestry and actual command semantics. Match complete
native inputs before removing the loaded-source correction guard. Then wire
fine bond/material conversion and accepted trial/correction transactions. The
untraced complete-step baseline still tracks strict >8 ms, >1000/120 ms and
>1000/60 ms exceedances with startup and all-step maxima retained.
