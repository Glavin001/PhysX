# Persistent pre-solve nodes and native metadata bypass

The opt-in CUDA pre-solve producer now maintains node records across simulation
passes. It no longer uploads every native node each pass. When it supplies the
solver inputs, PGS and TGS also skip native island metadata staging, allocation
and upload. These changes preserve the existing solver phase and physical work.
The CPU compatibility island registry and component readback still remain.

## Persistent node transactions

Native node birth, deletion, dynamic/kinematic transitions and local static-touch
count changes mark a coalesced dirty-node bitmap. Island membership relabeling
does not dirty a record: the CUDA producer computes connectivity separately.
At the pre-solve boundary, only marked indices are staged as 24-byte records
(index, padding, 64-bit lifetime, local static count and liveness). CUDA scatters
these into its resident 16-byte node array before constructing components.

First use, runtime reconfiguration, producer re-enablement and node-buffer growth
require a full snapshot. Growth within already reserved capacity initializes new
index holes as inactive before applying updates. Node/update/merge/parent buffers
have explicit growable capacity; command buffers and parent storage grow
geometrically. No contact or node budget truncates a required transaction.

Host framing rejects missing full-snapshot rows, duplicate/unsorted indices,
out-of-domain nodes and live records without a lifetime before any mutation.
CUDA additionally checks each internal record. Invalid dirty indices reach framing
validation and fail the step; they are not silently skipped. A successful enqueue
acknowledges the native dirty bitmap. Unsupported passes retain dirty nodes for
later publication, and producer enable transitions force a complete snapshot.
The existing graph-generation receipt still prevents stale phase seeding.

Quiet frames upload no node or merge records. Component construction and support
reduction still run on CUDA; this does not suppress physical work. The previous
node snapshot remains a device-to-device copy. Native actor lifecycle commands
and local contact counters are still CPU-produced inputs, not a fully device-owned
actor registry.

## Native fallback refresh

The producer now runs before native metadata staging at the same pre-solver task
boundary. If it provides CUDA labels/counts, legacy arrays are unused and may be
stale or smaller than the current domain. They are neither allocated nor uploaded
for that pass. Any later native fallback forces a complete current snapshot before
integration can read the legacy buffers. Subsequent native passes can again use
the existing dirty-page mechanism.

`solver_metadata_gpu_produced_passes` counts bypasses. Together with full, page and
quiet native passes it equals total metadata submissions. Native metadata H2D
bytes exclude bypasses; the full-upload equivalent remains a theoretical count.
`cuda_pre_solve_host_to_device_bytes` includes actual submitted node-update and
merge payloads. `cuda_pre_solve_full_host_equivalent_bytes` computes the old
16-byte full-node payload plus the same submitted merges for these exact passes.
`cuda_pre_solve_node_updates` and `cuda_pre_solve_node_full_snapshots` distinguish
record traffic from full refreshes. These counters exclude diagnostic readbacks,
other engine inputs, allocator overhead and device-to-device copying.

## Qualification

The audit independently captures every native node's lifetime, local static count
and liveness at the pre-solve boundary and compares every resident GPU record.
This detects missed dirty updates even if errors would cancel within one island.
It also compares GPU component equivalence and exact per-live-node support counts.
On native fallback it compares both legacy arrays exactly. It does not require
unused legacy buffers to mirror current state during CUDA-produced passes.
Diagnostic full snapshots/readbacks are off when auditing is disabled.

The native fixture poisons an unused legacy count. CUDA-driven steps must leave
it untouched and submit zero legacy metadata bytes; native fallback must refresh
it and match the independent snapshot. Quiet intervals must upload zero node and
merge records. Malformed transactions must preserve all resident node data and
allow the next ordinary step to succeed. Existing trajectory/fracture tolerances
remain unchanged. Standalone kernels check sparse persistence and boundary
indices across lifetime, liveness and support changes.

## Measured results

The full SDK build, all 27 focused tests and both focused CUDA memory checks
passed. PGS and TGS each exercised 23 CUDA-produced passes and seven native
fallbacks in the native fixture; sleeping-enabled TGS retained native fallback.

| Audited workload | 64 buildings | 256 buildings |
| --- | ---: | ---: |
| Chunks / bonds | 28,416 / 57,344 | 113,664 / 229,376 |
| Accepted steps | 600 | 1,800 |
| CUDA-produced / fallback solver passes | 695 / 10 | 2,169 / 10 |
| Producer node + merge payload | 121,726,224 B | 767,978,928 B |
| Same-run full-upload equivalent | 335,211,920 B | 3,503,269,240 B |
| Producer payload reduction | 63.69% | 78.08% |
| Node payload reduction | 98.60% | 99.42% |
| Native metadata payload | 162,484 B | 622,500 B |
| Physics step mean / min / max | 68.33 / 0.61 / 472.42 ms | 245.57 / 0.99 / 2139.42 ms |
| Real-time factor | 0.244x | 0.068x |
| Steps exceeding 16.67 ms | 503 | 1,704 |

Both captures completed with all stress solves converged, at most one correction
per step, zero recorded motion error and no contact-boundary or registry mismatch
failures. The large capture reached 97,101 clusters with
200,269 broken bonds, 379 single-resim corrections and
4,192 contact-boundary audits. The CPU compatibility graph bridge
still read back 5,650,996,480 bytes; explicit diagnostic transfers
are additional.

Transfer reductions use theoretical full-upload equivalents for the exact same
submissions. They are not elapsed-time comparisons. These captures use a shared
GPU with profiling and independent full audits; they establish correctness at
scale, not isolated performance or whole-game 60 Hz. The large run's
245.57 ms mean does not demonstrate a runtime speedup
over the earlier producer capture.

See `qualification/native-node-transactions-20260906.json` for completed build,
test, memory-check and real-fracture evidence. Removing the compatibility registry
and component readback, moving contact lifecycle input generation to CUDA, and
qualifying the full SDK remain open. Earlier unexplained crash/real-fracture
sanitizer failures are not closed by focused passing tests.
