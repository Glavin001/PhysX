# Device contact and stress integration — 2026-09-05

This implementation establishes an executable PhysX → contact decoder → load producer → stress solver chain in one CUDA context. Contact payloads and node loads remain on the GPU between those stages. It is a validated integration primitive, not a replacement for the city adapter, a complete fracture transaction, or a city-scale performance result.

The tested engine is **PhysX 5.10.0**, from `/root/PhysX/physx`. This repository's bundled PhysX source is 5.6.1; do not mistake it for the engine linked by the current Vast build. CUDA is 12.8.93; the test GPU is an RTX 4090 with driver 595.71.05.

## Interfaces and ownership

- `ExtStressPhysXDirectGpuMotionBuffer` captures poses and linear/angular velocities into persistent device allocations. Restore uses those allocations directly. Only GPU indices cross from host to device. Three ordered PhysX copies share a completion event and one host wait. Invalid captures invalidate the previous checkpoint; removed actors are rejected before restoration; all three transfers must succeed. The CPU fallback is used only for ordinary scenes. Keep supplied actors alive through the next capture or release. This is a **motion checkpoint**, without topology, force-journal, sleeping, contact-cache or complete shared-scene rollback semantics.
- `ExtStressPhysXDirectGpuContactDrain::copyContactsDevice` returns borrowed device records and a completion event. Wait on that event before consuming the records or starting another simulation. Finish consuming the records before another drain or release. Each nonzero normal impulse and friction-anchor impulse retains its world application point, actor identity, and shape transform-cache identifiers. Record order is unspecified. A nonzero device overflow flag invalidates the result; consumers must not apply a partial load set. `copyContacts` is the synchronous host reference/debug interface, and `lastCopyComplete` distinguishes empty success from failure.
- `ExtStressGpuSolver::solveDevice` accepts a device load array in solver node order, its exact element count, and an optional producer event. The array/event must remain valid through return. Without an event the producer must already be complete. A device-to-device copy keeps captured graph addresses and the previous input baseline stable. Solving is synchronous at the public boundary, like the host API. There is no load download/re-upload and no implicit bond-impulse readback. The existing GPU bond-stress walk can consume the solver's resident impulses.

The device input path preserves converged-only settled-island skipping. A GPU comparison against the previous device inputs produces one dirty flag per island; the current host scheduler reads those compact flags. Host input after device input conservatively invalidates the obsolete host comparison baseline. The implementation retains the existing CG/CGLS kernels, tolerance, damage formulas, materials and iteration policy.

Two particularly consequential defects were removed. The old motion prototype overwrote its device checkpoint from stale CPU motion and treated any successful component transfer as a successful restoration. The old contact drain returned actor pairs with zero positions and impulses. Neither was a valid destruction input path.

There is also a local PhysX 5.10 workaround: `PxgGpuNarrowphaseCore::copyContactData` returns early when `mTotalNumPairs == 0`, leaving both the output count and completion event unchanged. The wrapper resets its count and seeds an event on its own stream before the call. The nonempty engine path waits for that event and re-records it after copying; the empty path already has a valid zero-count completion. This also orders reuse after the previous decode, without a steady-state host synchronization. The installed engine was not modified.

The CMake link places the CUDA runtime before PhysX's static library group. Otherwise PhysX's private `CudaKernelWrangler` can capture application CUDA registration symbols and produce unresolved engine-only `PxGpuCudaRegister*` references. The decoder builds when `BLAST_ENABLE_CUDA_STRESS` is enabled; other builds report the contact drain unavailable instead of fabricating contacts.

## Validation

Configure against the actual 5.10 installation, then build:

```sh
cmake -S demos/blast-stress-demo -B demos/blast-stress-demo/build \
  -DPHYSX_ROOT=/root/PhysX/physx \
  -DPHYSX_LIB_DIR=/root/PhysX/physx/bin/linux.x86_64/release \
  -DBLAST_ENABLE_CUDA_STRESS=ON -DCMAKE_BUILD_TYPE=Release
cmake --build demos/blast-stress-demo/build \
  --target direct_gpu_resim_test direct_gpu_contact_test gpu_device_input_test gpu_stress_test -j8
ctest --test-dir demos/blast-stress-demo/build \
  -R 'blast_stress_(physx_direct_gpu|gpu_)' --output-on-failure
```

Run GPU tests exclusively; the campaign paused only the idle, checkout-owned city deployment and restored the same binary/environment afterward.

All four selected tests passed. Compute Sanitizer memcheck reported **zero errors** for both the contact pipeline and device-input regressions.

- Motion tests compare device-observed position, orientation, linear velocity and angular velocity after replay. They cover growing allocations, repeated restore, recapture, invalid capture and actor removal. Isolated runs at 32 and 5,000 bodies passed. At 5,000 bodies, 100 capture/restore repetitions averaged 0.0413/0.0444 ms respectively. These numbers measure motion copying only, not fracture remapping, a whole city tick, or a matched comparison with the production checkpoint.
- The contact test uses an actual sliding impact. Twenty-seven GPU contact-to-stress submissions passed; the largest difference between decoded impulse and measured momentum change was **2.68247e-7 kg·m/s**. It separately checks a zero-resultant contact couple with nonzero torque, output overflow, and the transition from live contacts to an empty scene. The integration fixture's load kernel is deliberately small; production still needs the real compound-shape/node mapping, local-frame load construction and full fracture semantics.
- The device-input test uses a deliberately delayed producer in a separate nonblocking stream. Cold/warm solves, unchanged islands, a changed middle island, host/device transitions, bond removal and cold restart all matched the host-input solver with maximum observed relative difference **zero**. It also mutates producer storage immediately after return to test snapshot ownership. Device load submission reports zero load bytes through the host bus.
- The existing independent CPU/GPU stress equivalence test passed.

Before enabling this path for the city, complete shared-world rollback and force replay; preserve gameplay queries and sleep semantics; implement production shape-to-node load mapping and fracture provenance; remove eager impulse readback only after auditing every consumer; and validate numerical load paths and multi-impact destruction at equal material settings. The small fixtures here establish interface correctness, not that the large-structure solver has converged or that an iteration budget can be reduced.

## Sleeping and the activity benchmark

`gpu_activity_bench` compares native sleeping, ordinary GPU with a verified awake control, Direct GPU, and a disable-sleep-flag-only diagnostic. Existing `PhysXScene` callers retain their default behavior; a new trailing `disableSleeping` argument configures this experiment. The benchmark is opt-in and has no machine-dependent latency assertion in CTest.

```sh
cmake --build demos/blast-stress-demo/build --target gpu_activity_bench -j8
./demos/blast-stress-demo/build/gpu_activity_bench 4096 3 > gpu-activity.csv 2> gpu-activity.log
```

The installed 5.10 ordinary-GPU path can report zero active rigid-body island nodes at rest even with `eDISABLE_SLEEPING`, while `isSleeping()` reports false. The flag-only arm reproduces that inconsistency. The verified awake control sets a 3,600-second wake counter **after insertion**, which otherwise resets it, and requires every dynamic to remain active. Direct GPU also remained fully active. All bodies must settle at the correct height and respond to the mass-wake command. The control is a finite experiment, not a production sleeping replacement.

With 4,096 independent cubes and three trials in rotated order, mean airborne simulate/fetch time was 0.450 ms for the verified awake control versus 0.380 ms for Direct GPU. Resting native sleep averaged 0.103 ms versus Direct GPU's 0.382 ms. All physical/activity checks passed. CSV records per-step timing plus separately timed command submission; there is no application readback or logging between measured steps. These measurements exclude stress, fracture, replay, queries and streaming; they do not establish a city speedup. The game repository's `docs/direct-gpu-sleep-2026-09-05.md` contains the full table, sample counts, provenance, engine audit and proposed wake contracts.

The first fixture run caught `PxBoxGeometry(x)` leaving two extents at zero in the activity, checkpoint and contact fixtures. They now use an explicit uniform vector and assert geometry validity. The validation figures above have been replaced by the corrected runs: both affected CTests passed, contact memcheck reported zero errors, and the 5,000-body checkpoint passed again. The device-input solver fixture is independent and unchanged.

Sleeping migration remains an explicit implementation task. Native energy/counter work already runs on GPU, but CPU island transitions and motion ownership still matter. Evaluate a narrow engine extension with compact activity transitions against fully GPU-owned active lists before choosing a production replacement. Dormant bodies must leave expensive work while retaining collision/support discovery and correct same-tick finite-mass wake response.

## Explicit high-level impulse observation

`BLAST_GPU_IMPULSE_READBACK=0` opts the high-level solver into GPU-resident
impulses; unset or `=1` retains eager readback. CPU walks, backend changes,
converged-solution steadiness and diagnostics refresh the host mirror on demand.
Deferred CPU strips observe before their parallel dispatch. Queued bond swaps
are flushed before readback; removing the final bond permits the existing empty
CPU fallback. The impulse array now follows swap-with-last even for its final
two entries, fixing a trailing-element compaction defect.

For strict audits, `BLAST_GPU_DETERMINISTIC_REDUCTIONS=1` replaces floating
atomic reductions with exclusive scalar writes and a fixed reduction tree over
1,024-element island tiles. Use the existing `BLAST_GPU_GATHER=1` operator to
keep the matrix-vector products reproducible as well. Island index lists update
on topology changes, with persistent device storage proportional to graph size.
This option adds a pass and topology uploads and remains off by default pending
performance qualification. It does not change materials, tolerances, iteration
budgets or convergence/steadiness policy. GPU results can differ in rounding
from the atomic mode; this is an audit mode, not bitwise equivalence to the old
unordered reduction.

On an idle GPU, build `gpu_lazy_readback_test` and run:

```sh
ctest --test-dir demos/blast-stress-demo/build-gpu-activity \
  -R blast_stress_gpu_lazy_ --output-on-failure
```

CTest supplies the deterministic/gather flags. The three cases compare eager
observation against device, serial CPU and parallel CPU consumers. A 1,331-node,
3,630-bond fixture covers capped/converged solves, tail compaction, island cuts,
backend switching, complete shattering and reset. The device case avoids
4,218,656 reported D2H bytes across its capped solves while comparing stress and
health arrays exactly. CUDA memcheck passes all three observer modes. Separate
bond-space/Jacobi comparisons and the 32-iteration CPU/GPU numerical suite pass.
These are correctness and transfer results, not a city performance claim.

The current implementation still constructs host changed-bond lists. Converged
steadiness observers download the whole live impulse array; sparse converged
scenes can therefore lose against eager compact readback. Measure both regimes
before a default change. The game's `docs/gpu-lazy-readback-2026-09-05.md` records
city integration tests, unresolved qualification gates and benchmark status.

### Exact host/device stress preparation

The CPU observer now uses the device walk's explicit fused vector accumulation
and fixed-order dot product for normal normalization and node distance. Host
impulse repacking uses the same `(length * length) * mass` angular factor and
`value * (physicalScale * columnScale)` association as the device. The final
torsional contribution to shear uses explicit `fmaf` in the shared formula.
An impulse-mirror audit alone could not detect these differences: both sides
of that audit used the same host repacking routine.

`blast_stress_gpu_cpu_walk_preparation` compares the actual CPU and GPU walk
outputs bit for bit on an oblique 1,331-node graph, including topology cuts,
complete shattering, backend switches, convergence and retirement. It uses
fixed-order CG reductions to isolate walk arithmetic from atomic reduction
variation. No material limits or iteration budgets were changed.

### Fidelity requirement for the city integration (2026-09-05)

The owner explicitly prohibits improving performance by clipping forces,
impulses or velocities, limiting fractures/broken bonds/body counts, or dropping
required interactions. A test expectation about facade damage is not a runtime
damage budget. A physically warranted collapse must be allowed; changing the
simulation to satisfy an empirical outcome band is not a valid optimization.

Apply this requirement to GPU load assembly, solver output, topology edits,
contact/wake queues, full same-tick replay and committed-state observation.
Finite capacities must report exhaustion rather than silently truncate required
work. A numerical-stability label does not establish physical correctness;
measure residual/error and preserve the intended physical model.

The current implementation is not fully qualified against this requirement.
The city disables the adapter's body and per-actor fracture caps, but the shared
stress formula still ceilings bending/torsion gain (`BLAST_BEND_MAX_GAIN`,
default 3). PhysX also supplies a default 100 rad/s dynamic-body angular-speed
ceiling, and the adapter/bridge default to a 1 m/s depenetration correction limit.
These are pre-existing mechanisms, not changes introduced by lazy impulse
readback or the host/device arithmetic correction. They require correction or
validated physical treatment; retaining them merely to prevent a fixture from
breaking or to improve retirement time is unacceptable. Existing no-cap comments
do not override the actual engine defaults. The game's
`docs/simulation-fidelity-contract.md` records the initial audit and follow-up.

### Rotation fidelity checkpoint

The adapter now preserves high angular momentum through body creation and
fracture, using the SDK's numerical range. Centrifugal acceleration is the
outward inertial load `-omega x (omega x r)`, yielding tensile radial stress.
The experimental SDK's speculative CCD radius now comes from local geometry in
the body's mass frame; stale CPU world bounds are not used in Direct GPU mode.
Its rotational envelope covers the geometric swept space without capping speed.
See `tests/velocity_fidelity_test.cpp` and `patches/physx/README.md` at the repo
root for the proofs and remaining limits. These changes do not close the wider
no-clipping audit or establish a city performance gain.
