# Experimental correction contact-pair reuse

`PxDestructionStressDesc::preserveUnchangedContactPairs` selects an experimental
native correction path. The default remains false, selecting the complete
contact rebuild. The experimental destruction descriptor version is 11; rebuild
all native consumers with the matching SDK.

The correction still checkpoints and restores the full supported rigid scene,
evaluates actual solved trial impulses, applies the existing fracture/material
verdict and performs one corrected collision/solver pass. It does not predict
breakage, skip stress work or selectively integrate only the fractured bodies.

## Persistent records and regenerated data

Affected shape ownership transactions already refilter their broadphase bounds
and remove incompatible contact managers. That includes retained cluster bodies
whose mass or support state changes, as well as shapes moving to new owners.
The corrected broadphase rediscovers newly eligible fragment pairs.

For other shapes, the experimental path retains pair registrations and solver
connectivity. It resets persistent GPU manifolds using PhysX's empty-manifold
initialization kernel and clears both generations of GPU friction-patch counts.
This makes trial friction anchors unreachable. Corrected narrowphase regenerates
contact geometry from restored motion; solver preparation rebuilds constraint
rows and recomputes interaction response. No cached trial impulse is accepted
as the corrected response.

All required dynamic bounds still refresh from GPU motion. Pair registration
reuse does not eliminate broadphase or narrowphase work, and does not yet make
new-pair allocation, filtering or solver partition construction GPU-owned.

## Qualification in progress

The first independent SDK build/install and nine native GPU suites passed.
A controlled fixture compares the full rebuild with reuse while 32 ordinary
bodies slide against a static floor during a remote fracture. All 32 contact trajectories match over 30 steps within the existing 2e-4
tolerance; projectile and fracture checks remain unchanged. A second fixture
produces two independent impacts on steps 6 and 16. Both correction modes
match those fracture decisions and all 720 sampled positions/velocities.
Test GPU input/observation buffers use explicit upload-to-consumer events. Native pair constructions fall from 35 to 3,
showing that unchanged ordinary contacts were retained.

An instrumented complete-rebuild fallback handles CPU narrowphase pairs,
contact modification, trigger interactions and pending CPU contact reports.
The independent SDK build and all 16 focused native/ownership/demo-launch
tests passed with this guard (out/native-aerial-fix-tests.log). The dormant
contact-modification callback fixture verifies one fallback, full-reference
pair constructions and projectile parity. Other guard branches still need
dedicated event fixtures.
Both 30-second aerial bombardments (3,996 and 113,664 chunks) completed with
reuse enabled, converged stress, at most one correction per step and zero
recorded-versus-physical chunk position error. These are shared-GPU diagnostic
runs, not isolated benchmarks or complete fidelity qualification. The chaotic
runs diverge in later topology and correction counts; controlled fixture parity
must not be generalized to identical city trajectories.

On the large diagnostic, mean corrected-collision time fell from approximately
666 ms in the recorded reference to 51 ms with reuse, but mean total physics
step time remained approximately 201 ms versus 200 ms. Time outside the measured
destruction/correction phases increased from approximately 32 ms to 188 ms.
This does **not** establish a total simulation speedup. Reuse remains opt-in
while the slower ordinary pass and broader event behavior are investigated.

`GpuDestruction.trialDetail.*` scopes now expose ordinary-pass task wall time
alongside `GpuDestruction.detail.*` for the corrected pass, including island
management, partitioning submission and lost-contact processing. These scopes
may overlap or nest; they must not be added as independent simulation costs.
See `qualification/native-pair-reuse-20260906.json` for the diagnostic results.

`GpuDestruction.resetContactCaches` measures host cache-reset submission time,
including any driver overhead. It is not a CUDA kernel timing. The phase
analyzer includes this optional phase independently of the corrected solve.

The completed 10-second denser city probe identifies CPU contact-island
maintenance as an additional hotspot: accurate third-pass calls peak at
824.84 ms and speculative third-pass calls at 599.73 ms. All 600 simulation
steps converged with at most one correction and zero chunk-position audit
error. This shorter launch schedule is a hotspot probe, not a speed comparison
against the 30-second bombardment. See `GPU_CONTACT_GRAPH_NEXT.md` for the
source-level integration seam and required correctness boundaries.
