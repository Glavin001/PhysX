# Flat allocation/preparation follow-up — unaccepted candidate

Topology plus publication candidate d5d0ca49 passes 52/52 normal asynchronous
memory scenarios, but its native correction memcheck fails in the remaining
motion-allocation conditional graph (1,588 reported errors).

The first follow-up (device-enabled-all) tried to device-toggle its cooperative
allocation kernel. The unchanged allocation oracle stalled and its 180-second
watchdog killed that owned process. No candidate native or timing campaign ran.
The combination is rejected; the precise CUDA component responsible is unknown.

The revised candidate (device-enabled-split) replaces three grid barriers with
ordinary graph dependencies between count, prefix, compact and assignment kernels.
Each phase reads the immutable GPU work flag produced by the unchanged validation
logic. Capacity failures, invalid grants and malformed requests retain their
original rejection behavior. Canonical assignment still follows complete batch
validation; CPU resource growth and same-tick correction order are preserved.
Preparation/publication bodies remain GPU-enabled flat graphs. No conditional
nodes, cooperative launch, extra CPU per-tick wait, blocking sanitizer option or
suppression is introduced in these destruction graphs.

The existing allocation oracle passes plain and normal asynchronous memcheck,
including 113,664 slots, repeated/growing allocations, malformed counts, duplicate
addresses, committed parent splits, ownership isolation and commit-once behavior.
Native correction/wall, full restored suite, physical A/B and full-step timings
remain required before retaining this implementation. Performance hypothesis:
remove fragile conditional execution with small extra launch overhead in allocation;
this is an enabling architecture candidate, not a claimed speedup. Refute retention
if physical outputs change or matched scenario full-tick costs materially regress.
CPU setup and restore are recorded separately. Main source/SDK remain unchanged.

Exact build commands and raw receipts: `out/snapshot-finish-20260911/device-enabled-split/`.
CUDA API reference for device-updatable kernel attributes:
https://docs.nvidia.com/cuda/cuda-runtime-api/structcudaGraphKernelNodeUpdate.html
