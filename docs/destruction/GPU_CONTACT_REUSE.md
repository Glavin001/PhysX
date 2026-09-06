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
bodies slide against a static floor during a remote fracture. All 32 corrected
contact velocities match within the existing 2e-4 tolerance; projectile and
fracture checks remain unchanged. Native pair constructions fall from 35 to 3,
showing that unchanged ordinary contacts were retained.

An instrumented complete-rebuild fallback handles CPU narrowphase pairs,
contact modification, trigger interactions and pending CPU contact reports.
The independent SDK build and all 16 focused native/ownership/demo-launch
tests passed with this guard (out/native-aerial-fix-tests.log). The dormant
contact-modification callback fixture verifies one fallback, full-reference
pair constructions and projectile parity. Other guard branches still need
dedicated event fixtures.
Large/repeated-fracture and broader event qualification are also pending. Keep
this option experimental until those checks establish its valid scope.

`GpuDestruction.resetContactCaches` measures host cache-reset submission time,
including any driver overhead. It is not a CUDA kernel timing. The phase
analyzer includes this optional phase independently of the corrected solve.
