# Native pre-addition command history — 10 September 2026

Installed private ABI **V14** captures ordinary additive command inputs inside
the native rigid-body upload, immediately before GPU velocity addition. SDK,
PhysX CPU/GPU modules and native consumers rebuilt together. The capture does
not modify velocities or integration. It supplies an exact baseline needed for
future corrected command redistribution; the production stress solver remains
legacy and the new command-motion transaction is not yet runtime-wired.

## Producer and scope

For correction-enabled ordinary scenes, `PxgSimulationCore::updateBodies`
initializes bodies and uploads changed physical properties before adding host
velocity deltas. At that boundary the runtime records the sparse upload list:
body ID, upload flags, exact original linear/angular velocities and submitted
linear/angular deltas. A record is 64 bytes; device status is 16 bytes with
original-checkpoint generation, upload count and error bits. Only entries with
`eHOST_VELOCITY_DELTA_GPU` are valid additive-command records. Other uploads are
marked kind zero, without reading an unrelated/uninitialized body slot. Invalid
body bounds/identity or nonfinite command values mark kind two and status error.

`commandInputHistory()` shares the original checkpoint's event/generation.
Consumers wait for that event, match generation and require zero status error.
Corrected-motion refresh retains the records. The next original input replaces
them; clear invalidates them. Retained allocations grow geometrically with the
upload list. There is no additional full body-pool snapshot or velocity readback.
The capture uses one status kernel plus one sparse kernel for nonempty uploads.

This is an exact pre-addition baseline for **that ordinary additive upload**.
It is not a full command-free scene checkpoint or a spatial load ledger. Already
written direct GPU commands, unknown application points, per-chunk distributions,
force/impulse modes and the physical interval are not reconstructed. Matching
original chunk ancestry is still required after a split. The existing correction
checkpoint, source-load guard and numerical path remain unchanged.

## Validation

Nine focused CTests pass: the existing seven checkpoint/correction/sleep checks,
the extended native command-wake check and the standalone producer check. The
native wake fixture covers TGS/PGS × optional acceleration reporting × correction
on/off (eight parameter combinations, not eight extra CTests). It uses three
actors, one stress chunk, no bonds/projectiles and dt 1/60. Correction-enabled
cases capture actual ordinary force 12 N on mass 2 kg and torque 6 N m about
inertia 0.4 kg m²; pre-addition velocities are zero and submitted increments are
0.1 m/s and 0.25 rad/s. The post-addition checkpoint, no-repeat next tick, invalid
wake batches and pending sleep checks still pass. A manual corrected refresh
retains original record bytes and generation. Uncaptured correction-disabled
inputs are not mislabeled as a valid command baseline.

The native fixture passes memcheck. The separate sparse producer passes
memcheck, initcheck, synccheck and racecheck. It covers 257 uploads / 515 body
slots, empty next generation, non-command uploads, out-of-range IDs, mismatched
native IDs and nonfinite source state. A rounding control demonstrates why the
capture is needed: adding float 1e8 to 1.25 loses the small value, and subtracting
1e8 does not recover it; the captured pre-addition value remains exactly 1.25.
The capture leaves all body bytes unchanged. Historical test tolerances/goldens
were not changed; earlier migration initialization failures are not waived.

The frozen ordinary/sleeping wall completed 600 steps / ten simulated seconds,
444 chunks, 896 bonds and one projectile. Simulation exit is zero. The wrapper
still exits one for the historical golden topology identity mismatch. Independent
invariants pass, and topology identity, fracture/correction steps, clearance step
43 and counts match V13: 400 supported, 44 detached, 182 broken bonds, 39 clusters.

## Hardware counters

Nsight Compute 2026.3.0 captured `captureCommandInputsKernel` on RTX 5060 Ti,
sm_120, CUDA 13.4.59, driver 615.71.09. Each selected capture uses ten replay
passes, cache flush enabled and clocks unlocked; desktop graphics remain active.

| Scope | Duration | Registers/thread | Achieved occupancy | DRAM / peak | Spills |
| --- | ---: | ---: | ---: | ---: | ---: |
| Actual native three-actor fixture, one 128-thread block | 2.37 µs | 26 | 2.87% | 0.49% | 0 |
| Synthetic 113,664-upload / 227,329-slot producer | 78.05 µs | 26 | 85.99% | 46.80% | 0 |

The native profiler run completes all fixture assertions; its exact selected
upload-row count was not separately archived. This small successful native
capture does not resolve the existing large-fracture conditional-graph profiler
issue. The large producer does not simulate a city or fracture bonds. Its
7,274,496 output bytes are identical profiled/unprofiled. These kernel durations
exclude status initialization, allocation, dispatch, solving and completion.
No whole-step speedup or physical-equivalence qualification is claimed. The
complete-step >8 ms, >1000/120 ms and >1000/60 ms gates retain startup/all steps.

## Evidence and next integration

[receipt.json](receipt.json) records source/binary/module hashes and commands.
[source.patch](source.patch) includes this integration plus prior uncommitted
runtime/checkpoint dependencies against the current committed base.
[validation-runs.json](validation-runs.json), [wall-comparison.json](wall-comparison.json),
[native-counters.txt](native-counters.txt), [producer-counters.txt](producer-counters.txt)
and [identity.json](identity.json) retain results. Raw captures are under
`out/elastic-command-inputs-20260910/`. All owned jobs completed.

Next join original command baselines to original chunk ancestry and explicit
spatial command records. The live GPU application must occur after host upload
and before the original post-command checkpoint; corrected child motion must
exclude the trial's command increment before redistributed commands are applied.
The full input/material ledger and exactly-once accepted transaction remain
incomplete. Do not infer physical load distribution from this body-level history.
