# Native command-owner wake bridge — 10 September 2026

Private runtime ABI **V13** adds `wakeCommandOwners` for a future GPU chunk-command
producer. The SDK, PhysX CPU/GPU libraries and native consumers rebuilt together.
This is scheduler integration: CPU code handles selected native owner IDs and
ordinary sleep/wake compatibility. Force, mass and velocity evaluation are not
moved to the CPU. Native GPU command submission/application is still pending;
the six-channel solver is not yet the production backend.

The allocator validates every ID before waking any owner, finishes queued GPU
sleep writes, then wakes dynamic bodies using existing PhysX wake semantics.
Duplicate IDs produce one notification; supports remain kinematic. Invalid,
deleted, disabled and in-simulation inputs reject. This uses current native IDs
under ordinary scene access/lifetime rules, not generation-free queued handles.
The runtime and allocator keep their accepted-step write guards.

## Failure attribution and focused validation

The initial regression wrongly expected ordinary `addForce`/`addTorque` commands
to remain in GPU acceleration accumulators. A preserved diagnostic observed
linear velocity 0.100000009 m/s, angular velocity 0.25 rad/s and zero accumulators.
The native upload source explains why: ordinary correction-enabled commands are
velocity deltas at the checkpoint. A first corrected test still failed with
optional accelerations and correction disabled, which selects the other native
representation. Both failed attempts are retained; this was a test-model error,
not evidence that production force integration lost commands.

The final fixture explicitly covers TGS/PGS × optional acceleration reporting
on/off × correction enabled/disabled: eight combinations. Each uses three actors
(two dynamics and one kinematic support), one configured stress chunk, no bonds,
no projectiles, dt 1/60, gravity/damping zero and at most one correction. The
commands use ordinary APIs: force 12 N on mass 2 kg, torque 6 N m about inertia
0.4 kg m². The expected increments are 0.1 m/s and 0.25 rad/s.

Checks include whole-batch rejection, duplicate notifications, selective wake,
kinematic preservation, rejection during simulation, pre-solve pose and command
representation, total impulse, no next-tick reapplication, pending sleep cleanup
and stale owner rejection. Numerical tolerance remains the original new-test
absolute 2e-5; no historical test, golden or tolerance changed.

The new CTest passes and its memory check reports zero errors. Seven existing
checkpoint/correction/sleep CTests passed with the same runtime and consumer
hashes (excluding the subsequently corrected new test binary). Thus eight unique
native tests pass; the eight parameter combinations are not eight additional
CTest tests. Earlier broad migration/initcheck failures remain unresolved.

## Frozen wall audit

The ordinary/sleeping wall completed 600 steps / ten simulated seconds, with
444 chunks, 896 bonds and one projectile. Simulation exit code is zero; the
frozen-golden wrapper exits one for the existing topology identity mismatch.
The independently checked geometric invariants pass. Compared with V12, topology
identity, fracture/correction steps, projectile clearance step 43 and final
counts all match: 400 supported chunks, 44 detached, 182 broken bonds, 39 clusters.
[wall-comparison.json](wall-comparison.json) records the matched fields. This does
not resolve the migration's historical golden or large-pose failures.

## Scope and next boundary

This introduces no new GPU kernel and establishes no speedup. Existing command
kernel hardware counters remain in the command-evaluator evidence. No new
complete-step timing campaign was run. The frozen wall audit below is a physical
audit, not a timing claim. Deadline reports retain exact >1000/120 ms and
>1000/60 ms counts/percentages, the separate >8 ms gate and all startup steps.

The next command producer must select current owners, wake them before sleep
cleanup can erase writes, apply validated GPU command values after CPU input
upload/before checkpoint, and account for trial/correction exactly once. The
existing loaded-source correction guard stays intact. A stored body resultant
cannot reconstruct a spatial chunk load distribution; the explicit command
records and original ownership remain necessary.

## Evidence

Raw captures: `out/elastic-command-wake-20260910/`. `diagnostic/` preserves the
original assertion and observed values; `final/` preserves the intermediate
failed representation assumption; `verified/` contains the final test/memcheck
and wall captures. Despite its name, `final/` is a failed attempt.

[receipt.json](receipt.json) records source, binary and loaded-module hashes and
commands. [source.patch](source.patch) contains the bridge and test changes against
the current committed base, including prior uncommitted checkpoint dependencies.
[validation-runs.json](validation-runs.json) and [prior-validation-runs.json](prior-validation-runs.json)
retain focused results and actual mapped modules. [command-wake-memcheck.log](command-wake-memcheck.log)
records all eight configurations and sanitizer completion.

All owned build, validation and audit jobs completed; no live job needs resuming.
