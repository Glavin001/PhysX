# WIP: reservation ordering and destruction timing

This is work in progress, not a completed GPU lifecycle implementation or a
qualified memory-safety fix.

## Changes in this snapshot

- The CUDA runtime receives the scene profiler callback explicitly across the
  shared-library boundary.
- Optional CUDA events measure consecutive contact-load, stress, material,
  topology/candidate and commit/stress-topology intervals. Elapsed times are
  collected after the existing completion wait; profiling adds no synchronization.
  These intervals include dependencies and submission gaps, not just kernels.
- Host scopes separate GPU completion, compact request readback, native body
  allocation, binding upload and publication.
- Two post-reservation host synchronizations are removed. Runtime-owned indices
  remain alive; downstream initialization, collision preparation and observations
  use the published CUDA event. Teardown/reconfiguration drains work.
- The phase collector writes a separate `native.phases.csv.device.csv` file.
  Analysis validates complete, unique, finite accepted-step GPU samples and host
  parent/child timing bounds. Legacy host-only captures remain readable.

## Evidence and limitations at the WIP commit

- Full SDK build passed: `out/native-reservation-timing-build.log`.
- 30 focused tests passed: `out/native-reservation-timing-tests.log`.
- Four timing-analysis tests passed:
  `out/native-reservation-timing-analysis-tests.log`.
- 64-building, 600-step audited capture completed:
  `out/recordings/native-reservation-timing-20260906`.
- CUDA memcheck on `native_gpu_allocation_test` returned 99 with 394 reported
  errors. The first reported API error is illegal address 700 in
  `ExtStressGpuSolverImpl::solveDeviceAsync`, called by `Runtime::advance`.
  Log: `out/native-reservation-timing-allocation-memcheck.log`.
  Attribution to this change versus an earlier failure is unproven. Ordinary
  passing tests do not qualify this synchronization change as memory safe.
- The full-scale 1,800-step capture was running when this snapshot was prepared:
  `out/recordings/native-reservation-timing-large-20260906`.
  Its process-result file and terminal exit status must be checked before citing
  completion. Shared-GPU timings do not establish isolated performance.

## Required architecture going forward

Build the integrated path around device-owned state from the outset:

1. Persistent chunk geometry/identity and bond graph, independent of motion.
2. GPU cluster ownership, mass properties, generation-bearing body-slot pools,
   active-motion lists and topology transactions.
3. GPU contact identities resolving chunk ownership to current motion slots,
   including new collision candidates after splitting.
4. Trial solve, actual solved impulses, stress/material verdicts, topology change,
   checkpoint restore and one correction, ordered within the GPU execution flow.
5. Committed event/snapshot publication for explicitly requested CPU observation.

The existing host body allocator, shape ownership transactions and island
compatibility registry are reference/transition code. They must not define the
new path's authoritative data model or require host decisions between trial and
correction. Capacity growth and unsupported-operation handling remain explicit;
no missing contacts, predicted fracture or weakened physical work is permitted.

Next implementation should establish the device allocation/lifecycle and solver
integration together, rather than continuing a sequence of CPU implementations
followed by GPU ports. Native CPU/WASM compatibility remains a separate supported
backend; it must not require a second simulation beside the integrated path.
