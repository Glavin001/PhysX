# CUDA pre-solve island producer

The native demo's `--gpu-pre-solve-islands 1` switch enables CUDA-produced island
labels and static-touch counts as the actual PGS/TGS integration inputs. It also
requires `--gpu-island-repair 1`. The default remains the qualified native
metadata path pending wider configuration and performance qualification. This is internal engine
work on the solver CUDA stream, not an application physics replay.

## Preserve the solver phase

Native second-pass island generation merges newly connected nodes but postpones
splitting lost connections until the third pass. The solver observes the state
between those phases. A freshly rebuilt graph containing only current contacts
would split too early and could change stabilization and wake behavior.

The CUDA producer therefore starts with the preceding post-retirement GPU
components, inherits membership only for surviving dynamic node lifetimes,
merges the current native new-edge journal, and reduces node static-touch counts
into those components. It computes minimum live-node labels. Virtual component
hubs occupy a separate index range, so reusing a former component representative's
body index cannot accidentally merge its replacement into the old component.
Kinematic-to-dynamic changes start a new membership lifetime. Deleted and
prescribed nodes do not contribute; prescribed bodies never bridge components.

The kernel uses monotone atomic union/find and complete compression, without an
iteration budget or approximate termination. Integer static counts preserve the
native inputs. The final counts and labels feed the existing integration kernels
directly, replacing their input pointers; no integration formula changes.

The scene-owned eligibility predicate is shared with existing GPU island repair.
Sleeping, joints (including inactive registered joints), articulations, non-rigid
systems, CCD/speculative CCD, filtering callbacks and contact-modification
callbacks retain native fallback. The seed receipt also requires exactly the
next graph generation, so an enable/disable or unsupported interval cannot reuse
an older node-lifetime snapshot with a newer graph. First use and node-storage
growth initialize the lifetime cache through an explicit native fallback.

## Ordering, failure and current costs

The producer waits for the previous graph-ready event on the solver stream.
The next graph publication waits for producer completion before overwriting
borrowed labels; graph storage growth additionally synchronizes before freeing
those labels. All node, edge and output allocations are growable. Domain overflow,
allocation/launch failure, malformed endpoints or invalid seed graph state fail
the step; required work is never truncated.

The accurate native registry records new merge endpoints at its ordinary
insertion boundary. Lifetime counters are maintained during native node lifecycle
operations. The merge journal is enabled only for this producer. Pinned node and
merge staging lives until the solver stream has consumed it. Source staging,
recorded commands and the CPU island registry remain CPU work in this prototype.

[Persistent node transactions and native metadata bypass](GPU_PRE_SOLVE_NODE_TRANSACTIONS.md)
now replace the original full-node upload and redundant native metadata transfer.
CPU node lifecycle/static counters and the compatibility registry still remain.
The capture results below describe the original full-snapshot implementation at
its recorded revision; consult the newer qualification for current traffic.

`native.graph-diagnostics.json` reports actual CUDA producer passes, fallback
passes and node/merge H2D payload bytes separately from legacy solver metadata
and contact-graph transfers. These are not total engine traffic. The switch
currently lives in the private native demo/context API, not a stable public SDK
interface.

## Independent verification

`--audit-islands 1` captures full native arrays before solving and compares their
partition equivalence and per-live-node static-touch counts with the CUDA arrays
after each accepted step. Native island IDs and minimum-node CUDA labels are
different identifiers; the audit requires a bijection between their partitions,
then exact integer counts. On native fallback it retains the exact legacy-array comparison; on CUDA-produced
passes it independently compares every resident node record with native state. Intermediate trial outputs are not independently read back.

The native fixture drives both PGS and TGS through static support changes,
chain disconnection, body reuse, dynamic/kinematic transitions, capacity growth,
reference switching and speculative-CCD fallback/resumption. It requires actual
GPU producer use, and checks sleeping-enabled fallback. A 100,001-node kernel
fixture compares against independent phase-preserving CPU flood fill with deleted,
prescribed, newly dynamic and reused node lifetimes and reversed merge ordering.
Repeated-impact qualification compares fracture steps and 720 trajectory samples
against the native reference using the existing 2e-4 trajectory tolerance.

See `qualification/native-pre-solve-producer-20260906.json` for verified results
and exact scope. Full destruction SDK qualification, CPU registry removal,
selective correction scheduling and prior unexplained native/sanitizer failures
remain open.

## Next producer migration boundaries

1. Persistent node transactions are implemented; see the successor document.
   Continue moving lifecycle input generation into GPU topology transactions. Retain generation checks across body removal/reinsertion
   and kinematic transitions; inverse mass alone cannot identify prescribed
   motion. Native actor commands may remain CPU bookkeeping, while GPU-created
   clusters should update device membership in their topology transaction.
2. Direct GPU merge inputs are implemented as an opt-in path; see
   [GPU_PRE_SOLVE_CONTACT_INPUTS.md](GPU_PRE_SOLVE_CONTACT_INPUTS.md). Generation
   of static-boundary inputs remains open. Use the narrowphase's resident
   contact state at the pre-solver boundary. Counting contact points is incorrect:
   native static counts count inserted static edges. Current retired managers and
   retained managerless edges must both be represented at this earlier boundary.
   The existing late retained-edge publication cannot simply be moved earlier.
   Compare these new device inputs against native per-node counts and lifecycle
   evidence before replacing the currently staged inputs.
3. Native island metadata upload bypass is implemented; see the successor
   document. Reinitialize those buffers when entering native fallback;
   stale arrays must not become an implicit fallback. Keep the native full
   snapshots as explicit diagnostics, not mandatory production transfers.
4. Move compatibility registry maintenance and its consumers onto device state.
   Removing the component readback alone while retaining CPU code that traverses
   it would be incorrect. Preserve joint/sleep/fallback semantics and independently
   qualify each consumer before retiring its host mirror.

Items 1 and 3 have implemented transfer changes; their remaining producer and
registry migration work is still required. Item 2 still needs GPU static counts
and managerless lifecycle input generation; item 4 remains open.

## Original producer qualification

These measurements precede persistent node transactions and native metadata
bypass. See [the successor qualification](GPU_PRE_SOLVE_NODE_TRANSACTIONS.md)
for those changes.

The final build passed all 27 focused native/CPU-reference tests and both focused
CUDA memchecks. The native producer fixtures exercised 22 CUDA-produced passes
and seven explicit fallback passes per solver; sleeping-enabled TGS used native
fallback throughout. The controlled repeated-impact fixture retained both fracture
steps and all 720 reference trajectory samples at the original tolerance.

The final 64-building run completed 600 steps with 28,416 chunks, 57,344 bonds and
108 single-resim corrections. CUDA-produced state supplied 698 of 708 solver
passes. The 256-building run completed 1,800 steps (30 simulated seconds) with
113,664 chunks, 229,376 bonds, 1,024 projectiles and 373 single-resim corrections.
It reached 97,105 active clusters and 200,273 broken bonds. CUDA-produced state
supplied 2,163 of 2,173 solver passes; ten initialization/growth fallbacks used
native metadata. All accepted-step checks, 4,180 contact-boundary audits and
stress convergence checks passed, with zero recorded motion error or registry
mismatch fallback.

The large run averaged 236.12 ms per physics step (7.06% of real time), peaked at
2,054.75 ms, and missed 1,703 of 1,800 16.67 ms deadlines. Auditing/profiling and
shared GPU conditions make this a correctness-at-scale result, not a speedup
comparison. Producer node/merge inputs uploaded 3,472,113,616 bytes; legacy solver
metadata uploaded 825,312,176 bytes; the compatibility graph bridge read back
5,624,257,888 bytes. Other engine transfers and explicit audit readbacks are
additional. These measurements identify substantial remaining CPU staging and
observation work; they do not establish the full GPU-owned SDK end state.
