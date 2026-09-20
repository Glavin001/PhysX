# Two fracture evaluations, one motion correction

The native scene now evaluates destruction once after the trial physics pass
and once after a required corrected physics pass. `internalCorrectionLimit=1`
permits at most two physics evaluations and two stress/material evaluations.
An unchanged trial that needs no motion correction still evaluates stress once.

The first evaluation uses actual trial impulses and commits its fracture
verdict when corrected physics completes. Before evaluating the corrected
impulses, the runtime takes a device snapshot of the corrected end-of-tick
motion. Additional splits inherit that motion, including the COM point-velocity
shift. They are installed and committed without scheduling another collide or
advance task. Newly eligible contacts from those final splits are solved during
the next normal tick, as with the external one-replay policy.

Each material evaluation uses the existing timestep and equations. The second
starts from the first accepted material state, matching the external two-tick
calls within one replay loop. This is an intentional change from the former
single-material-evaluation native policy, not a claim of identical fatigue or
crushing results. Neither evaluation is submitted twice by a numerical retry.
Scene commands are submitted only once; ordinary bodies advance by one timestep.

`PxDestructionStageStatus` reports one frame receipt: aggregate contact, damage
command and broken-bond counts, maximum numerical iteration count across all
evaluations, `stressPasses`, and `postCorrectionBrokenBonds` (a subset of
`brokenBonds`). `correctionPasses` is at most `internalCorrectionLimit`. Device
verdict buffers represent the most recent evaluation, while accepted topology
includes every pass. Public observation remains forbidden until scene
completion. The experimental API version is 17; rebuild all native consumers.

## Any number of corrections per tick

`internalCorrectionLimit` is a per-tick budget, not a flag. The tick is a loop
over task-graph traversals:

```
checkpoint = capture(start of tick)                 // copyToGpuBodySim, trial only
solve rigid                                         // trial
for pass in 0 .. limit:
    evaluate stress on the solved contacts          // prepareFrame(pass), advance
    if no membership change: break
    restore(checkpoint); install fragments + collision owners
    if pass == limit: apply the split at the final motion; break   // no re-solve
    checkpoint = capture(start of tick + fragments) // only if pass+1 < limit
    solve rigid again                               // corrected pass+1
merge every pass into one receipt                   // finishPostCorrection
```

Limit 0 never rewinds: one solve, one evaluation, verdicts split bodies at the
trial motion. This is the cheapest setting; a fresh cut exchanges no impulse
until the next tick. Limit 1 is the behaviour described above and is unchanged
byte for byte. Limit N lets an impact break N bond layers deep within one tick:
each corrected solve is re-evaluated, and while the evaluation still changes
membership the scene rewinds to the start of the tick (fragments from earlier
passes included, sourced from the snapshot taken right after their install) and
solves again. The loop ends at the first evaluation that changes nothing and is
bounded by the bond count, since accepted topology only shrinks.

Cost: every extra pass is a full collide+solve of the scene, so a fracturing
frame at limit N can cost up to N+1 rigid solves. Frames without fracture cost
the same at any limit. `PxgSimulationController` keeps the pass index; the Sc
pipeline alternates two finalization tasks so the task scheduling pass p+1 is
never the one currently running, and re-captures CPU activity (wake counters,
kinematic start poses, sleep notifications) before every solve that another
rewind may follow. Contact manifold and friction caches are reset before every
corrected solve when pair reuse is requested.

The standard-scene compatibility fix preserves world-space shape caches during
native ownership changes regardless of public Direct GPU mode. Rebuilding those
caches from a not-yet-published CPU fragment previously corrupted queries for a
split installed after the last physics pass.

Tests:

- `physx_native_post_correction`: four chunks, two bonds, two gravity-loaded
  columns and one ordinary sentinel. One bond breaks in each evaluation;
  verifies final ownership, CPU/GPU pose agreement, immediate raycast, exactly
  one timestep of ordinary motion, and no duplicate cuts on the next tick.
  Runs both with and without CPU contact report requests.
- `physx_native_post_correction_multi`: the same fixture at limits 2 and 3.
  The second verdict now triggers a corrected solve (`correctionPasses==2`,
  `stressPasses==3`), the late fragment falls for one timestep from its start
  pose, and limit 3 exits early with the same counts.
- `physx_native_chained_fracture`: one column of three chunks and two bonds,
  the lower bond too strong for the trial load but not for the load the freed
  upper chunk applies once it is its own body. Limit 1 breaks one layer and
  reports the second in `postCorrectionBrokenBonds`; limit 2 breaks both with
  two corrected solves.
- Existing standard-scene sleep/wake/query tests and native replay tests also
  assert the stress evaluation count.
- Frozen penetration regression retains its existing golden and tolerances.

This does not complete selective correction, GPU contact lifecycle ownership,
crush-fragment removal, or supported-joint rollback. Existing admission guards
remain. Timing comparisons must identify whether they use one or two stress
passes; a behavior change is not a performance optimization.

## Removing unused CPU contact exports

The native demo has no CPU contact callback. It now selects the simulation-only
filter instead of the external demo's per-contact notification filter. Solving
normal/friction contacts and borrowing native impulse streams remain enabled.
This removes unused actor-pair report state that forced correction to rebuild
all active contact registrations despite requesting pair reuse. Consumers that
request CPU reports retain their existing filtering and correctness guards.

The 256-building, 113,664-chunk, 229,376-bond test uses identical physical commands
and settings before/after this deletion, including the new second evaluation.
Two 12-second runs per arm give a measured worst complete peak of 355.506 ms
before and 118.007 ms after; full-run means are 175.274 and 59.420 ms. All 767
shots scheduled before the 12-second boundary are included. Counts differ in
these chaotic runs; controlled replay, query/sleep and penetration tests are
separate evidence. This is not an exact trajectory-equivalence claim.

The two subsequent 30-second optimized runs include all 768 shots, reach up to
40,926 bodies / 26,039 awake, and record 118.469/143.404 ms peaks. They do not
meet 60 Hz. No 8 ms, five-trial or full lifecycle endurance gate is claimed.

See the generated reports in `qualification/post-correction-performance/`,
`qualification/post-correction-no-reports-long/`, and
`qualification/post-correction-gpu-cost/`. The latter distinguishes actual
CUDA checkpoint restore/installation intervals from CPU enqueue time and the
combined CPU/GPU physics replay interval. CUDA markers run only in profiling
captures and are collected at existing acceptance waits.
