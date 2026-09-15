# GPU original-motion ancestry — 10 September 2026

The installed native runtime now freezes authored-chunk-to-original-body
ownership beside its original pre-solve rigid checkpoint. Correction retains
both records while the current body pool and motion handles change. Private ABI
is **V12**; SDK, GPU module and native consumers were rebuilt together. Source
remains uncommitted WIP on `1155b7ff`. Public scene ABI and the production stress
backend are unchanged. The guard against unapportioned force/torque commands
during correction remains; ancestry does not define a physical load distribution.

`inputRigidCheckpoint()` supplies authored-order body/root/slot/generation records
and a device receipt with input/topology generations, counts, validity and errors.
Consumers wait for the ready event and require a valid matching receipt before
using any records. Inactive entries have invalid IDs; partial failed maps are
unusable. The producer checks active masks, packed cluster/root agreement,
slot/root agreement, body bounds and native identity, using the configured
runtime's valid-capacity arrays. It is not an arbitrary-topology repair routine.
The original slot is not a current handle after correction. Next BeforeSolve
overwrites the map; clear invalidates the borrowed view. No host count readback
is needed. Storage is 24 bytes per chunk plus a 32-byte receipt: 2,727,968 bytes
for this city fixture. The producer currently writes the map every input capture.

## Native evidence

One ordinary/sleeping diagnostic trajectory completed 180 steps / three simulated
seconds: 256 buildings, 113,664 chunks, 229,376 authored bonds, one 256-shot wave,
dt 1/60, correction limit one and at most two stress evaluations.

| Tick / evaluation | Current motion groups | Groups with a new body ID | Original body-pool count |
| --- | ---: | ---: | ---: |
| 1 / trial | 256 | 0 | 512 |
| 83 / trial | 256 | 0 | 512 |
| 83 / correction | 5,120 | 4,864 | 512 |
| 109 / trial | 10,905 | 0 | 11,161 |

All current fragments resolve to exactly one original body through active
authored chunks. At tick 83, original bodies, ancestry and receipt bytes are
identical across trial/correction. Later trial inputs refresh correctly; trial
handles agree with captured topology slots/generations. The native ledger is
still explicitly incomplete. Fracture, cluster, contact, correction/evaluation
and active-node/bond histories match V11. Iterations differ on 23 later steps,
first at step 133. This is not full physical-equivalence qualification.

Seven focused native tests and checkpoint memcheck pass. The checkpoint fixture
covers eight TGS/PGS, sleeping and optional-acceleration combinations. A focused
producer test covers sparse/empty layouts, invalid slots/body IDs/packed mappings,
invalid generations and recovery. Its standalone build passes all four CUDA
sanitizers; the same source is registered as `physx_native_gpu_input_owners`.
Prior native initialization failures were not waived or claimed fixed.

The frozen ordinary/sleeping wall audit completed 600 steps / ten simulated
seconds: 444 chunks, 896 bonds, one projectile. Invariants, topology identity,
fracture/correction steps, clearance step 43 and final counts match V11 and the
migration capture: 400 supported, 44 detached, 182 broken bonds, 39 clusters.
The historical golden identity gate still fails; its failed log is retained
separately from the successful invariant subset.

## Hardware counters and limits

Nsight Compute 2026.3.0 captured the native `captureInputOwners` kernel on
113,664 chunks / 256 original groups: one startup launch, ten replay passes,
cache flush on, clocks unlocked, desktop graphics active. Hardware: RTX 5060 Ti,
sm_120, CUDA 13.4.59, driver 615.71.09.

| Kernel duration | Registers/thread | Achieved occupancy | DRAM / peak | Local/shared spills |
| ---: | ---: | ---: | ---: | ---: |
| 22.66 µs | 16 | 91.73% | 73.30% | 0 / 0 |

Ancestry and receipt outputs are byte-identical to the unprofiled startup capture.
The one-step target returns exit 1 because the bombardment demo requires
demonstrated destruction, which startup alone does not produce. The captured
step/kernel completed; the exit and log are retained. This is separate from the
unresolved later-fracture Nsight conditional-graph failure, which is not fixed.

These counters exclude receipt kernels, event ordering, allocation and complete
step cost. No integrated speedup or unchanged complete-step cost is claimed.
High occupancy and memory traffic suggest authoritative revision-based reuse
instead of register tuning; that remains an optimization hypothesis. Previous
untraced baseline counts retain exact >8 ms, >1000/120 ms and >1000/60 ms gates,
startup and all-step maxima.

## Evidence and next work

[receipt.json](receipt.json) records hashes and commands. [source.patch](source.patch),
[input-history-check.json](input-history-check.json), [native-analysis.json](native-analysis.json),
[counters.txt](counters.txt) and [wall-comparison.json](wall-comparison.json) retain
results. Raw directory: `out/elastic-input-owners-20260910/`. All owned jobs finished.

After the normal SDK build/install, reproduce using fresh output directories:

```bash
.toolchains/build-env/bin/ctest --test-dir out/destruction-sdk -R '^physx_native_gpu_input_owners$' --output-on-failure
.toolchains/build-env/bin/python tools/diagnostics/destruction-load-capture/build.py out/owners-NEW/build
.toolchains/build-env/bin/python tools/diagnostics/destruction-load-capture/run.py out/owners-NEW/native
.toolchains/build-env/bin/python tools/diagnostics/destruction-load-capture/check_input_history.py out/owners-NEW/native --require-owners
```

Next consume ancestry in a complete GPU command/contact interval producer.
Force/torque modes, impulses, prescribed motion, damping/locks and exactly-once
correction need defined chunk loads and native validation. Fine bond/material
conversion, component/setup keys and accepted trial/correction transactions still
precede replacing the legacy backend.
