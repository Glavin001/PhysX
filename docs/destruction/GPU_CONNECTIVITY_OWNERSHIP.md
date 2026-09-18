# Device-owned contact connectivity

The opt-in native rigid destruction mode uses CUDA contact components as the
solver's authoritative connectivity. It skips CPU path searches and component
splitting, and does not observe CUDA component arrays on the CPU unless an
explicit audit requests them. This is a connectivity migration; CPU contact
registration, actor/node lifetimes, active-body staging and constraint partition
bookkeeping remain.

Enable in the native demo with `--gpu-connectivity-owner 1`, together with
`--gpu-island-repair 1 --gpu-pre-solve-islands 1 --gpu-pre-solve-contacts 1
--gpu-pre-solve-support 1`. It remains opt-in. The internal entry point is
`PxgGpuContext::enableDeviceConnectivityOwnership`; this is not yet a stable
public SDK configuration interface.

## Ownership and fallback

Immutable shape identity and current motion ownership feed the existing CUDA
contact graph. The pre-solver GPU components include the previous completed phase’s
connectivity required by PhysX's deferred-removal phase, then current eligible
contacts and support. The final accurate/speculative GPU graphs split that
connectivity after contacts are retired.

The host island registry maintains nodes, edges, activation lists and lifetime
notifications. Its partitions may retain old merges while device ownership is
active. Those coarse partitions are not uploaded as solver connectivity in an
owned pass. GPU components remain exact; this is not approximate physics or a
budget that suppresses contact processing.

Eligibility currently requires sleeping disabled, native destruction correction,
all three GPU pre-solver producers, and the existing rigid contact-graph eligibility
checks. Unsupported joints, articulations, CCD, callbacks and other actor types
retain the normal path. GPU-native sleeping propagation is not implemented by
this change.

On feature disable or a missing eligible GPU pre-solver result, restore host
connectivity before a native metadata consumer reads it. Restoration invalidates
old route witnesses and completes the component split, but does **not** repeat
node/edge retirement, deactivation or lifecycle-queue clearing. Those operations
belong to their ordinary task boundary. Replaying them after partitioning caused
invalid solver-body references during development; the fracture regression covers
that failure.

The separate GPU shared library invokes host-only restoration/audit operations
through callbacks installed by the host `IslandSim` constructor. It does not
require the executable to export private static-library symbols or carry a second
copy of the island implementation.

`native.graph-diagnostics.json` reports `device_connectivity_passes` and
`host_connectivity_restores`. Buffer growth and missing previous GPU graph history
can still cause restores. Removing those ordinary-operation fallbacks requires
preserving the GPU history through growth/correction; it must not be disguised by
uploading coarse host partitions.

## Validation

- `physx_native_gpu_connectivity_owner`: PGS/TGS pre-solve metadata, support changes,
  kinematic transitions, handle reuse, buffer growth, explicit disable/re-enable,
  unsupported CCD, and sleeping fallback.
- `physx_native_gpu_connectivity_fracture`: six simulated seconds of bombardment,
  graph audits, motion audits, correction and host restoration. Uses a unique
  temporary capture directory, so repeated test runs are safe.
- `physx_native_gpu_resimulation`: controlled repeated impacts, matching fracture
  steps and 720 trajectory samples within the existing `2e-4` tolerance; existing
  momentum, ordinary friction participants, query identity and correction checks.
- Graph audits flood-fill CPU edge adjacency independently of both GPU labels and
  host partitions. While owned, the host partition is checked as a coarse
  compatibility superset; GPU connectivity still has to match the flood fill
  exactly. The pre-solver oracle retains an independent previous-phase partition
  with node lifetimes.

A separate fidelity fix, commit `6a3ac3f9`, clears allocation-placeholder sleep
readiness when installing moving fragment state. Previously, a falling fragment
could deactivate after contact separation even in an `eDISABLE_SLEEPING` scene.
The repeated-impact fixture now checks continued gravity analytically. Both
comparison modes include that fix; old timing results are not a matched baseline.

## Reproduce measurements

Build the SDK and demo with GPU profiling enabled, then run:

```sh
python3 tools/scripts/run-native-connectivity-comparison.py out/connectivity-comparison
python3 tools/scripts/report-native-connectivity-comparison.py out/connectivity-comparison \
  --output qualification/connectivity-comparison.md
```

The campaign alternates mode ordering, records hashes and GPU conditions, and
runs idle city, isolated impact and three bombardment sizes. One traced trial
provides actual concurrent CUDA activity; two untraced trials provide elapsed
step comparisons. Timings are simulation-only. This bounded campaign does not
replace the longer five-trial, 60-second scaling qualification.

Next ownership boundaries are GPU activation/sleep, constraint partition inputs,
and contact-manager lifecycle. No claim is made that the remaining CPU work or
all readbacks have been eliminated.
