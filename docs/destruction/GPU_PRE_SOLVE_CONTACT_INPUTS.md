# Direct GPU contact inputs for pre-solve connectivity

The native demo's opt-in `--gpu-pre-solve-contacts 1` reads current narrowphase
contact records on CUDA to merge the pre-solve components. It requires
`--gpu-pre-solve-islands 1 --gpu-island-repair 1`. The original native merge
journal remains selectable with `--gpu-pre-solve-contacts 0`; ordinary PhysX
and the default demo configuration are unchanged.

## Phase and lifecycle

The producer runs at the existing post-partitioning, pre-solver boundary on the
solver stream. It seeds the previous accurate component labels for surviving
node lifetimes, preserving the native deferred-split semantics. Current touching,
response-enabled dynamic contacts merge those seeded components. It does not
predict impulses or fracture. Stress evaluation, correction and damage accounting
remain unchanged, with the demo's one-correction limit.

The narrowphase supplies borrowed current-pass input, lifetime-identity and touch
buffers. These do not reuse the late graph's borrowed pair view, whose contents
can have been compacted or replaced by this point. A current retirement list is
staged separately; a CUDA mask prevents retired managers from dereferencing their
old geometry. Invalid identity/domain data raises the existing incomplete-step
failure path. Omitted CPU-fallback or non-rigid contact buckets select native
metadata rather than silently dropping their interactions.

The CUDA kernel excludes no-touch and disabled-response pairs, static/kinematic
bridges and inactive/deleted motion nodes. Newly touching pairs are incorporated
before solver integration. The previous phase remains responsible for connections
whose native removal is deferred until the later island pass.

Managerless accurate edges have no narrowphase row. Until their lifecycle producer
moves onto CUDA, the pre-solve boundary stages their current inserted dynamic
endpoints from the retained-edge map. This is an explicit remaining CPU bridge;
using the late retained-edge receipt here would have the wrong phase semantics.
Native merge-journal recording is disabled in direct-contact mode, while node
lifetime/support dirty tracking remains enabled.

## Observation and qualification

Independent native pre-solve snapshots still verify resident node records,
partition equivalence and exact static-touch counts after each accepted step.
These expensive observations are optional diagnostics, not production inputs.
PGS and TGS fixtures exercise support changes, body reuse, kinematic transitions,
growth, reference switches and unsupported-scene fallback. Repeated-impact
fracture decisions and 720 trajectory samples use the unchanged 2e-4 tolerance.

The kernel regression separately checks prior lost connectivity, newly touching
pairs, managerless edges, retired invalid geometry, no-touch/disabled contacts,
static/kinematic boundaries, inactive nodes and invalid identity reporting.

New counters distinguish GPU contact passes, processed pair records and retirement
H2D bytes. Existing producer H2D counts remain node updates plus the residual
managerless merge payload; add retirement bytes for this producer's full measured
payload. Full-node-upload equivalents use the same current bridge inputs, so they
are not an estimate of the removed historical native merge journal.

## Qualified results

The complete SDK build, all 28 focused regressions and both focused CUDA memory
checks passed. The source/library hashes, commands and capture checks are recorded
in [the qualification report](qualification/device-pre-solve-contacts-20260906.json).

| Audited workload | 64 buildings | 256 buildings |
| --- | ---: | ---: |
| Chunks / bonds | 28,416 / 57,344 | 113,664 / 229,376 |
| Accepted steps | 600 | 1,800 |
| GPU contact producer / native fallback passes | 696 / 10 | 2,157 / 10 |
| GPU contact records processed | 71,852,798 | 888,394,141 |
| Producer H2D payload | 3,025,488 B | 16,213,032 B |
| Managerless merge / retirement H2D payload | 0 / 0 B | 0 / 0 B |
| Physics mean / min / max | 57.07 / 0.63 / 320.17 ms | 253.54 / 0.98 / 2268.79 ms |
| Real-time factor | 0.292x | 0.066x |
| Steps exceeding 16.67 ms | 498 | 1,702 |

Both captures completed with all stress solves converged, zero recorded motion
error, no registry mismatch fallback and no contact-boundary audit failures.
The large run completed 367 single-resimulation corrections, reached
97,124 clusters, broke 200,292 bonds and passed
4,168 contact-boundary audits. Graph builds equal accepted steps
plus corrections, and same-pass reuse counts match those builds.

The producer payload in these captures consists entirely of persistent node
updates. Managerless dynamic merges and pre-solve retirements were zero in these
workloads; their paths still exist and are not assumed universally empty. Native
metadata uploaded 622,948 bytes in the large run.
The compatibility graph bridge still read back 5,610,102,208 bytes,
and explicit diagnostic observations are additional.

The 253.54 ms large-scene mean does not establish a
runtime speedup over the native-journal producer. Physical settings and correction
limits were preserved, but these are separate chaotic captures under shared GPU
conditions with full audits. No isolated performance or whole-game claim follows
from them.

## Remaining work

Local static-support counts and lifecycle commands still originate on CPU. The
native compatibility island registry, component readback, ordinary interaction
registration and managerless-edge input producer remain. This is not complete
GPU ownership of the PhysX actor/contact lifecycle. Shared-GPU audited captures
cannot establish an isolated runtime speedup or whole-game 60 Hz. Earlier native
crash and real-fracture sanitizer failures remain separate open issues.
