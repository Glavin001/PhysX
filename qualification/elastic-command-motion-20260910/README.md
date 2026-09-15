# GPU command-to-native-motion transaction — 10 September 2026

`PxgDestructionElasticCommandMotion.cuh` converts validated command body wrenches
into velocity changes in actual `PxgBodySim` storage. It is an executable GPU
transaction and device consumer of the existing explicit chunk-command evaluator.
The production runtime **does not call it yet**: installed private ABI remains
V13, production stress remains legacy and the loaded-source correction guard
remains. This is not native scene-level command/replay qualification or a speedup.

## Mechanics and transaction

For the explicit application interval h, linear increment is h F / m. Angular
increment is h R diag(inverse principal inertia) R^T T, where T is the already
aggregated world wrench about the native COM. The evaluator's impulse-valued
inputs were divided by the same h, so their velocity increment is not divided
again. Computation uses FP64 with one conversion of each increment to native
float before addition. The new native-float oracle limit is 2e-6 (1+|expected|);
existing numerical/native tolerances and historical tests are unchanged.

The caller supplies native ID/lifetime bindings and prescribed-support status.
Kinematic supports retain structural loads but get no dynamic response. A
non-prescribed body with zero inverse translation mass can still respond through
finite rotational inertia. Full rotated principal inertia is used. Native mass,
pose, flags, acceleration accumulators and unselected slots are preserved.

`begin → clearClaims → prepare → seal → apply → commit` runs on one exclusive
native stream. Preflight validates the entire batch before velocity mutation.
Duplicate IDs, stale/deleted lifetimes, wrong input receipts, invalid support/mass
combinations, invalid rotations, nonfinite loads and float overflow reject.
Claims clear only selected IDs, not every native slot. Empty command batches
skip body work even with a nonempty retained partition.

An exact duplicate query/native epoch is a no-op. A corrected evaluation requires
the same tick/input/command/interval, evaluation one and a newer native epoch;
new trials require newer tick/input/command/native epochs. These checks prevent
repeated application to the same supplied state. The native producer must make
epochs authoritative; the transaction cannot prove that a caller actually rewound
physics merely from an incremented integer.

**Corrected child input must be command-free.** Existing original checkpoints
are post-command. Restoring them and applying these deltas would double-count
commands. Live integration must preserve a pre-command baseline or account for
original contributions before child redistribution. It also must match native
advance duration to the evaluator's impulse interval and preserve chunk load
information for stress. Full exactly-once physical correction remains pending.

## Validation

The standalone regression checks 769 groups in 1,541 sparse native slots with
three-axis rotations, anisotropic inverse inertia, prescribed supports and an
infinite-translation-mass dynamic body. Rejection leaves body/history bytes
unchanged; untouched fields and slots remain byte-identical. It exercises stale
queries, duplicate replay, refreshed tick/epoch sequencing and empty input.

A one-to-two synthetic rewind applies a parent's command to its commanded child
only, preserving the other child's command-free velocity. A separate device-only
handoff uses two unit-mass chunks with symmetric COMs and aggregate inertia
matching the native body. A force at an offset point, free couple and impulse
pass through the actual command evaluator into native velocity writes. These
are independent kernel fixtures, not a fracture/contact scene or a producer-owned
rewind implementation.

All seven focused CTests pass (six numerical plus this transaction). Final
memcheck/initcheck/synccheck/racecheck pass with zero reported errors/hazards.
Checks and counter numbers are recorded in the receipt and logs linked below. The six preceding numerical CTests are distinct from the new transaction
CTest. No new native wall run is needed for these standalone-only kernels;
installed production libraries are hash-matched against the validated V13 build.
The latest V13 wall audit and unresolved historical golden remain authoritative.

## Counter scope

The large fixture has 113,664 independently targeted synthetic groups and
227,331 native slots. It has no rigid-body simulation, projectiles or fracture
bonds; this count is not 113,664 chunks independently simulated in the city.
It checks one application, with a separate Nsight Compute replay of `prepare`
and `apply` (10 passes each, 128 threads/block, 888 blocks, cache flush enabled,
clocks unlocked). Hardware is RTX 5060 Ti/sm_120, CUDA 13.4.59, Nsight Compute
2026.3.0, driver 615.71.09. Desktop graphics remain active.

| Kernel | Duration | Registers/thread | Achieved occupancy | DRAM / peak | Local/shared spills |
| --- | ---: | ---: | ---: | ---: | ---: |
| prepare | 105.47 µs | 56 | 66.95% | 52.04% | 0 / 0 |
| apply | 19.90 µs | 18 | 85.25% | 78.51% | 0 / 0 |

The write kernel's traffic is material in this synthetic large batch; dispatching
only groups requiring a motion change is a more direct next hypothesis than
register tuning. That selection must preserve zero-resultant structural loads
in the separate stress path. No whole-step improvement is established.

The profiled and unprofiled native-body arrays are byte-identical (58,196,736 bytes). These
selected kernel durations exclude claim clearing, receipt kernels, dispatch,
wakeup, stress and rigid solving. They cannot be added to older whole-step
numbers or used as city-performance evidence. The existing >8 ms, >1000/120 ms
and >1000/60 ms complete-step gates remain unchanged.

## Evidence and next work

[receipt.json](receipt.json), [source.patch](source.patch), [validation-runs.json](validation-runs.json),
[counters.txt](counters.txt) and [identity.json](identity.json) retain final evidence.
Raw captures: `out/elastic-command-motion-20260910/`; `qualified/` contains the
final symmetric-mass and empty-batch fixture. Earlier build errors and intermediate
passing versions remain at the parent and `final/` paths.

Next connect the native producer's command-free input checkpoint, wake-ID
selection and post-upload application, then carry the same spatial commands
through corrected topology and the full load/material transaction. The body
resultant is insufficient to reconstruct opposing per-chunk structural loads.

All owned jobs completed. No live build, sanitizer or profiler job remains.
