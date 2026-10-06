# Vehicle authored-part collision mapping — unqualified WIP

2026-09-25. Public scene ABI 20, private producer factory V13.

Vehicle parts contain multiple convex hulls. They must remain one stress chunk:
creating a node for each hull would change the authored mass and bond graph.
`PxDestructionStressDesc.additionalShapes` maps additional contact identities to
existing chunks. Contact lookup includes every hull. Candidate collision binding,
compaction and final owner publication use hull capacity; stress, mass and motion
remain indexed by authored chunks. The collision record includes a stable hull
slot so two hulls on the same chunk cannot overwrite publication state.

All CPU/GPU consumers must be rebuilt together. The V13 factory prevents loading
the preceding GPU module against the changed collision record layout. No installed
SDK or deployed runtime was replaced.

Validation completed locally (CuMetal, functional evidence only):

- PhysX, PhysXGpu, PhysXVehicle, PhysXExtensions and the destruction runtime
  compile together in `out/build/garage-multihull`.
- `native_standard_scene_test --multihull`: both impact locations pass, checking
  two chunks/three hulls/one bond, both hull owners, one authored mass, ordinary
  overlap queries, corrected GPU motion, and invalid/duplicate identity rejection.
- Existing post-correction and compound-sleep fixtures pass.
- Expanded `native_shape_publication_test` passes same-chunk distinct hull slots,
  repeated migration, stale epochs and bounded publication overflow.
- Vehicle2 load observer: 540-frame CPU reference trajectory matches the
  installed original wrapper exactly. 474 moving substep groups conserve impulse
  (maximum linear discrepancy 0.002553 N s, angular 1.42e-7 rad/s).
  The observer delegates the existing rigid body component in its original order.
- `native_vehicle_loads_test` passes against the newly built wrapper as well.

The earlier CuMetal compiler failure was resolved by matching the working build's
explicit motion/hierarchy/aggregate-root and block-voted-trap flags. No compiler
source change or forced synchronous launch was introduced. The standalone
publication fixture initially dereferenced raw GPU managed-memory addresses on
its host. It now uses explicit uploads/readbacks; production GPU code is unchanged
by that fixture correction.

Logs: `/tmp/physx-garage-multihull-build.log`,
`/tmp/garage-multihull-test.log`, `/tmp/garage-native-regressions.log`
(the initial publication failure), `/tmp/garage-publication-fixed.log` (fixed),
`/tmp/garage-loads-baseline.json`, `/tmp/garage-loads-observed.json`.

The full frozen penetration regression, CUDA execution, and intact-idle/loaded
complete-step timings remain unqualified. The user explicitly deferred Vast CUDA
validation; no remote source upload or execution was performed. The installed SDK
and live garage were not replaced with this experimental ABI.

Still required for destructible Vehicle2 integration: native constraint/load
ownership and remapping, moving rig bindings, adopting the Vehicle2 actor,
fragment streaming/rendering, real trailer/hitch, and operational/impact strength
qualification. Do not remove the unsupported-constraint/force guards to bypass
these requirements. The current garage test drives are intact Vehicle2 bodies.


## Per-part command loads and parallel interfaces (2026-09-25)

`enableChunkLoads` and `setChunkLoads` describe commands that the caller has
already applied. World force/torque describe native GPU accumulators; world
impulse/angularImpulse describe ordinary actor commands, which this engine
integrates into velocity before the scene solve. Torques are about each chunk
COM. The GPU checks both aggregate channels against the actual rigid inputs.
A mismatch produces status bit 16384 and refuses the step. Inputs expire after
one complete timestep; every corrected solve of that step sees the same inputs
(see POST_CORRECTION_FRACTURE.md, "Chunk commands on every corrected pass").

The scene producer exposes its existing device command upload to the checkpoint.
Only load-enabled scenes allocate and clear a command-delta checkpoint. On a
split, the GPU subtracts the parent's already-applied delta, translates each
chunk wrench to its fragment COM, and reapplies that chunk's impulse once.
Native external force accumulators are similarly apportioned. Gravity is omitted
from the ordinary stress gravity input only for gravity-disabled actors whose
explicit chunk loads supply it (Vehicle2). No physical state readback or altered
ordinary driving integration order is introduced.

Distinct bonds sharing endpoints are now supported: each keeps its measured
interface and its own material/health. The local parallel-joint test breaks one
weak interface without changing ownership, observes the surviving bond's health,
and then breaks that last connection and verifies separate physical owners.

Local force tests cover rest, rotated orientation, inherited translation and
rotation on a moving source, a mismatched command, and
next-frame input expiration. The loaded one-kilogram fragment receives 100/60
m/s; the unloaded fragment remains at rest, with no spurious angular velocity.
Logs: `/tmp/garage-chunk-impulses-test.log`,
`/tmp/garage-parallel-bonds-test.log`, and the final six-test pass in
`/tmp/garage-chunk-final-regressions.log` (post-correction, multihull, chunk
loads, parallel interfaces, compound sleep and Vehicle2 observation).
The expected mismatch case emits an
incomplete-step diagnostic; the test requires rejection and unchanged owners.

These are engine prerequisites, not a destructible-vehicle release. Vehicle2's
four wheels still share a suspension/sticky constraint block, whose solved
impulses need native chunk ownership and whose constraints need remapping at
fracture. The unsupported-owned-constraint guard remains. Moving rigs, wheel
release, drive disablement, authoritative fragment packets and the strength
campaign remain pending. ABI 20 is isolated; the installed ABI 18 SDK and live
sessions continue using intact cars. The Vehicle2 observer explicitly reports
`available=false` when built against an older component-sequence SDK; no load
conservation claim may be made from that result.

Final checkpoint regression pass: all three of rigid checkpoint, correction-body
preparation and shape publication passed after the command metadata change.
See `/tmp/garage-chunk-checkpoint-regressions.log`. Together with the six tests
above, nine focused native/vehicle checks pass on the isolated local build.
The frozen penetration runner depends on Linux `/proc` mappings and CUDA `.so`
artifacts; it was not run on this macOS/CuMetal build. This remains unqualified
WIP for CUDA, penetration quality, and complete-step performance.
