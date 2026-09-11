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


Frozen commit: `8589185e659c8316b1828b7847b8780eb0f11006`.
Runtime SHA256: `29dee12c70e46a7d54b0d50f939f46748f5deee4ffa3b5e2f2909d86bf482a1a`.
The 29-case native correction regression now passes both plain and normal
asynchronous memcheck (zero errors). The 600-tick ordinary/sleeping wall passes
its hash-pinned pre-snapshot ordinary reference: all recorded topology, fracture
and correction histories match, with zero maximum position difference and all
stress steps converged. Final 400 supported / 44 detached / 182 broken bonds /
39 clusters. This does not establish historical cross-GPU equivalence or a
performance improvement. The full 52-case memory campaign is running next.

Rejected cooperative variant source commit: `2f1286b437fb2c668d3161c33b256627b32eef6f`.


The revised candidate now completes the full **52/52 normal asynchronous memory
suite**, 104 restored ticks, 622.9025 seconds summed harness wall time. Every
scenario has a zero-error memcheck summary. See `full-mem-results.json` for all
scenario receipts and hashes. This clears the previously failing asynchronous
snapshot and correction checks without serializing launches. Physical A/B smoke
and repeated unprofiled performance qualification follow; no speedup or final
retention is claimed yet.


The allocation oracle additionally passes normal initcheck and synccheck (zero
errors), covering the replaced global phase boundaries. All three physical A/B/A
smokes pass, including exact destruction outputs and existing rigid-state bounds.
Their 2-candidate / 4-control timings are noisy and are **not sufficient for
performance acceptance**; the city impact candidate mean is higher, while the
large debris before/after controls drift substantially. See `physical-smoke.md`.

Next matched qualification: `out/snapshot-finish-20260911/split-matched-full/`,
52 scenarios, A-before 10 / B 20 / A-after 10 independent restored ticks each.
No candidate runtime/source rebuild is permitted during this campaign. Each
scenario records exact physical comparison, independent controls, maxima, budget
misses and excluded restore cost. Do not accept from combined means alone when
the two controls disagree. Stable baseline remains preserved and deployed SDK
unchanged. Retention is pending this result, not established by sanitizer success.
