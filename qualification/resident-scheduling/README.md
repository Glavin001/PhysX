# Resident CUDA scheduling — selected implementation and rejected experiment

The complete plan remains unfinished and the 8 ms peak gate fails.

- ✅ Small components retain one six-variable Cholesky solve per CUDA thread.
- ✅ Multilevel smoothing uses the same per-thread factor solve. Sparse rows use
  eight physical lanes to emulate the original 32-lane summation tree; matrix
  equations and FP64 arithmetic remain unchanged. Existing cooperative and local
  operator results agree bit-for-bit, with independent dense-oracle checks.
- ✅ Converged small components retire immediately after the existing convergence
  test, preserving final status and scratch writes. No tolerance, cap, input,
  damage or correction decision is changed.
- ✅ Exact frozen wall audit passes: 444 chunks, 896 bonds, one projectile,
  398 supported chunks, 46 detached, 199 broken bonds, identical topology hash,
  COM/collision/render checks, timestep 1/60 second and correction limit one.
- ✅ Original native analytic regression passes through 131,072 nodes / 98,304
  bonds; memory and synchronization checks pass. Multilevel operator memory and
  synchronization checks also pass through 100,000 nodes / 199,997 bonds.
- ❌ Larger independent 3D fixtures (1,058 nodes / 2,553 bonds) still fail warm
  zero-load convergence and supported force accuracy. Original thresholds stand.
- ❌ Native racecheck is still unqualified. The latest recorded attempt, in
  ../thread-diagonal/racecheck-mixed.log, aborts before completing the test.

## Measured performance and selection

The [generated final timing report](../retire-tail-impacts-256/report.html)
is authoritative: 256 buildings, 113,664 chunks, 229,376 bonds, 256 simultaneous
projectiles, sleep disabled, fixed physical settings. Two untraced three-second
runs retain all 180 steps each. A separate scope capture and complete CUPTI capture
provide the phase breakdown. This is not the five-by-60-second qualification.

Compared with [the previous warp-based candidate](../pivot-local-impacts-256/report.html),
the main gain is the per-thread six-variable solve. Deleting the converged iteration
tail did not establish an additional timing gain in the short runs. All recorded
non-timing fields match the immediately preceding selected candidate across all
180 steps of the first repeats; exact wall topology is separately checked.

### Tried and rejected

Applying multilevel preconditioning to the small components reduced numerical
iterations but increased complete simulation cost. The
[rejected experiment report](../eight-lane-vcycle-impacts-256/report.html)
is retained. That selection was removed from production; no runtime experiment
switch was added. Large components retain their required multilevel implementation.

The retained standalone gravity probes contain one intact building (444 nodes /
896 bonds), no physics, projectile, damage or correction. Both multilevel probes
converge in 38 iterations. Eight-lane sparse scheduling improves that multilevel
operation but does not beat the selected simpler preconditioner for this fixture.
Summed CTA cycle counts include instrumentation overhead and are not additive
multi-SM milliseconds. These probes are diagnostics, not whole-simulation timings.

## Remaining

Resolve the independent 3D and native racecheck failures; remove unnecessary
small-component hierarchy preparation and unused workspace; improve active sparse
work layout; finish GPU lifecycle/ownership and device-controlled correction;
qualify fidelity, complete-step 8 ms scaling, five 60-second runs and endurance.
No production speedup is claimed over older historical implementations measured
with different durations or timer scopes.
