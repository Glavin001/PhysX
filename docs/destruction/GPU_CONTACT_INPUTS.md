# GPU construction of native narrowphase inputs

Native destruction now resolves narrowphase geometry references on CUDA from
persistent shape-instance identities. The generated descriptors are the input
buffers consumed by PhysX's ordinary GPU contact generation, in both the trial
and corrected solve. This is an integrated consumer of persistent GPU shape
storage; it does not yet make pair allocation or solver scheduling GPU-owned.

## Data flow

Previously, `PrepareInputTask` visited each new CPU contact manager, looked up
both CPU geometry registrations and filled `PxgContactManagerInput`. In native
mode the compatibility record now supplies only the two persistent transform
IDs. The corresponding CPU preparation tasks are omitted for rigid geometry
buckets 1 through 12. `buildNativeContactInputs` resolves the geometry references
from `PxgShapeSim::mHullDataIndex` directly into the GPU narrowphase input array.

The same construction handles supported rigid primitive, convex, plane, mesh
and heightfield buckets. Deformable/particle buckets retain their original
path. Actual exercised geometry is listed under validation; the bucket range
alone is not a claim of complete geometry qualification.

Scene task dependencies place shape upload before broadphase/narrowphase. The
new kernel runs on the narrowphase stream, after pair-ID upload and before
contact generation. It adds no host synchronization or physical-state readback.
Geometry references are independent of current cluster motion ownership.

The existing 16-byte input upload remains for compatibility; its geometry
fields are placeholders in native mode. Thus this removes per-pair CPU geometry
lookups and preparation tasks, but does not yet reduce input-transfer bytes.
Host descriptor arrays are no longer authoritative for geometry references in
native mode. GPU compaction retains complete device descriptors. The optional
legacy debug validator checks geometry against the CPU registration map rather
than those placeholders.

`internalCorrectionLimit=1` enables the integrated path. Ordinary PhysX and the
reference/diagnostic destruction mode retain CPU descriptor construction.
Clearing destruction returns new pairs to the original path, while existing GPU
descriptors continue to be valid. Private runtime interfaces and all consumers
are rebuilt together; no public destruction API layout changes are required.

## Failure behavior

Existing contact-buffer allocation remains responsible for capacity growth.
Missing launch buffers or launch failure abort the native simulation rather
than bypassing required pairs. Out-of-range or unregistered device shape IDs
are internal invariant violations and deliberately trap the CUDA context before
narrowphase can consume invalid references. This is a fail-stop guard, not
recoverable capacity handling; automatic recovery from that invariant failure
is not implemented or claimed.

## Validation

The collision test runs the reference and native paths with 514 instances
sharing box, sphere, capsule and cooked-convex geometry, plus a plane. It grows
shape storage, removes sparse instances, reinserts replacements after deferred
ID recycling, and transitions back to ordinary PhysX. Every observed GPU
narrowphase descriptor is checked against CPU contact-pair identities and the
independent geometry-registration map.

Each mode checked 1,798 live descriptors. The reference dispatched zero native
constructions; native mode dispatched 772 and kept CPU geometry placeholders,
proving the old preparation tasks did not fill those descriptors. All observed
descriptors matched. Six focused native suites passed after the independent
SDK build/install, including allocation, collision preparation, checkpoint,
correction bodies, resimulation and publication. The analytic impact still
produces a 6 m/s projectile after fracture versus 0 m/s for the intact wall,
with exactly one correction and the existing momentum/force checks.

The 113,664-chunk / 229,376-bond diagnostic completed 180 steps with 56 corrected
steps and no unconverged stress result. It reached 89,920 clusters and 185,008
broken bonds, matching the previous owner-compaction run's endpoint counts.
This is not proof of bit-identical chaotic trajectories. The worst step was
728.024 ms; all corrected steps missed 16.67 ms. No real-time or isolated
performance improvement is claimed.

The nine-building, 30-second capture completed all 1,800 steps, with 228
corrected steps and 6,541 broken bonds. Every stress result converged at the
unchanged 1e-5 tolerance; the maximum was 2,350 iterations with an 8,192 cap.
The 1080p/60 fps video is offline playback of those accepted states, not proof
of real-time simulation. Its worst step was 49.139 ms, with 12 missed deadlines.

See [the qualification record](qualification/native-device-contact-20260906.json)
for capture paths, build hashes, sustained-run results and test logs. The full imported test matrix was not
repeated for this GPU-only internal change; existing fidelity failures remain.

## Remaining collision integration

CPU code still creates and filters pairs, allocates contact managers, registers
actor/scene interactions and builds solver partition data. Our correction still
uses a complete CPU contact invalidation/rebuild. The new GPU descriptor consumer
is ready for device-produced pair IDs, but a device pair registry alone would
not eliminate those costs: solver connectivity, filtering, cache invalidation
and accepted event publication must also consume it. The full correction path
remains the reference throughout that work.

## Sustained scale capture and storage

The larger four-wave run uses:

```sh
out/destruction-sdk/reference/native_destruction_demo \
  --grid 16 --waves 4 --seconds 30 --stress-iterations 8192 \
  --profile-phases 1 --record-state 0 \
  --output out/recordings/native-device-contact-113664-sustained-20260906
```

For the historical capture below, `--record-state 0` disabled only file output
and still performed CPU pose observations. The current demo defaults to `0` and
omits those observations unless recording or motion auditing is requested; see
[GPU_RENDER_CONSUMER.md](GPU_RENDER_CONSUMER.md). A completed summary records
the mode and transfer counts. The larger run subsequently completed all 1,800 steps and 1,024 projectile
launches with converged stress and at most one correction per step. It reached
87,506 clusters, broke 190,334 bonds and corrected 1,398 steps. Median simulation
time was 794.973 ms and worst time 1,349.69 ms: this is sustained correctness
evidence, not a real-time result. Full CPU contact rebuild and solver scheduling
remain major scaling work.

The completed nine-building video is at:

```text
out/recordings/native-device-contact-sustained-20260906/native-gpu-contact-inputs.mp4
```

Its original raw recording was losslessly compressed to `native.twstate.gz`
in the same directory, with a verified round-trip SHA-256 in `state-archive.json`.
The video was retained and fully decoded successfully. To render again, first
restore the raw state with `gzip -dk native.twstate.gz` when space permits.
Capture directories contain the source patch and binary hashes used for each
run; the later recording toggle rebuilt only the demo executable.
