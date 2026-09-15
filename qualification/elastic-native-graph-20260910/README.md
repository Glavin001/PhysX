# Native topology to six-channel graph — 10 September 2026

The new graph binding consumes native deletion/support state and passes native
device revisions into GPU component/setup construction. Bond matrices are retained
in authored order rather than copied after fracture. The production ABI V14
runtime and native demo binaries remain unchanged; this is a private numerical
integration component, not a replacement production stress backend.

[Input, lifetime and error contract](../../docs/destruction/elastic-native-graph-contract.md).

## Checks

Eight six-channel CTests pass, including the new native graph test. Its small
fixture checks shared supports, support release/join, deletion, inactive chunks,
endpoint identity, invalid masks/versions, stale generation rejection and empty
graphs. Operator and RHS agree with independent equations; GPU PCG residuals pass
the existing limits. Diagonal, recovered response and energy agree with a separate
graph having physically deleted bonds. No tolerance was changed.

The new fixture passes memcheck, initcheck, synccheck and racecheck. The later
captured mapping also passes all four: eight sanitizer runs, zero errors/hazards.
Exact commands, exit codes and loaded-module hashes: [validation-runs.json](validation-runs.json).

## Native capture replay

Source captures are from the existing 180-step / 3-second, 256-building native
trajectory: 113,664 chunks, 229,376 bonds, 256 shots, ordinary API, sleeping on,
physical timestep 1/60 second. These replays perform no physics advances and no
material decisions. Captured centers provide geometry; interface coefficients
are supplied algebra-test values, not calibrated native material parameters.

| Stress launch ordinal | Native state | Live bonds | Unknown components | Unknown nodes |
|---:|---|---:|---:|---:|
| 0 | Initial | 229,376 | 256 | 97,280 |
| 82 | Tick 83 trial | 229,376 | 256 | 97,280 |
| 83 | Tick 83 correction | 201,216 | 5,120 | 97,280 |
| 130 | Tick 109 trial | 176,336 | 10,905 | 97,280 |

All four GPU partitions match independent serial graph traversal and stable node
ordering. The 16,384 prescribed chunks are absent from the unknown set. Actual
capture manifests and raw-input hashes: [input-captures.json](input-captures.json).
The numerical fixture's shared-support test separately proves that prescribed
connections do not merge unknown systems.

## Selected hardware counters

RTX 5060 Ti 16 GB / sm_120, CUDA 13.4.59, Nsight Compute 2026.3.0. One selected
launch of each kernel on ordinal-130 data; ten replay passes each, cache flush
enabled, clocks unlocked, desktop active. These scopes omit other validation,
sorting, scanning, setup and solver work; they cannot be summed into total cost.

| Kernel | Duration | Registers/thread | Achieved occupancy | DRAM throughput |
|---|---:|---:|---:|---:|
| Bind node support/activity | 11.94 µs | 16 | 91.03% | 77.98% |
| Validate native bond binding | 38.18 µs | 16 | 95.47% | 68.99% |
| Union unknown components | 52.16 µs | 16 | 82.85% | 44.28% |

All report zero local-memory spills. The first two kernels show substantial DRAM
use; these samples do not identify the bottleneck of the complete solver or step.
Plain and profiled ordinal-130 mapping exports are byte-identical. See
[counter details](counters.txt), [raw metrics](counters.csv) and
[output hashes](output-hashes.json). No before/after performance claim is made.

## Provenance and remaining work

Raw captures/maps/profiler archive and the saved test binary remain in
`out/elastic-native-graph-20260910/attempt-1/` (successful). The original native
snapshots remain under `out/elastic-input-owners-20260910/native/`. Source is WIP on
1155b7ff; [hashes](hashes.json), compiler flags and [current source patch](source.patch)
record this implementation. The patch includes earlier uncommitted dependencies.

Remaining: live numerical geometry/material authoring, complete load and command
ledger, producer-controlled lifetime/dirty scheduling, material trial/acceptance,
correction integration and structural acceleration. Production physical gates and
full idle/bombardment timing qualification remain open. Both 120 Hz and 60 Hz
complete-step exceedances remain tracked. All owned jobs completed.
