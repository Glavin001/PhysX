## V20: physical-state reconstruction works

The physical save/load contract is implemented in private runtime V20/schema7
(public API16). All **28** cases pass in
`out/snapshot-20260911/physical-state-v20/final-suite/`: two independent restores each,
ten complete ticks each, **560** checked ticks. The previously failing fragmented
building (444 chunks, 378 owners, 781 broken bonds at export) now passes. All
recorded inter-restore position, linear velocity and angular velocity errors are
zero. This is not a claim of bitwise continuation from an uninterrupted scene.

The format preserves physical bodies, materials, damage, connectivity and
ownership. It no longer saves stress guesses, response history, settled
certificates, cached inverses, GPU shape-transform caches, sleep filters or
native scheduling history. Native bodies enter through ordinary PhysX insertion
and upload. No warmup physics tick is performed. Current-tick contacts, stress,
at most one correction and the second stress evaluation remain in the step.

The test validates physical destruction bytes before stepping, all authored
shapes, mass/inertia/COM, initial sleep/wake state, material/topology equality,
monotone damage, convergence, correction/evaluation limits, free-fall acceleration
and exactly-once post-restore impulse. Corrupt/truncated/missing-ID inputs and
attempts to overwrite a configured destination are rejected. Numerical and
motion tolerances were not loosened. The comparison changed from uninterrupted
execution versus restore to two independent restores, as requested by the user.

[All scenario results and full-step measurements](snapshot-v20-results.md), with
raw samples, export/restore-validation scopes and separate linear/angular units
in the adjacent JSON. These are shared-GPU correctness diagnostics, not a
performance comparison: each case has two first-restored ticks and correlated
continuations. The 24-case performance suite is still the earlier prefix suite.
The retained N13 city measurements and installed SDK remain unchanged.

Fragmented-building destruction payload: V19 **517,940 bytes**, V20 **244,892
bytes**. Intact-building payload: **271,580 → 127,088 bytes**. Removing caches
reduces the saved data; it is not evidence of a faster game tick. Source-cache
labels `-cold` / `-warm` indicate the capture prefix; every loaded solver starts
with newly constructed caches.

Attempts retained in the same raw directory:

- `run-1/`, `debug-1/`: a stale incremental-build object caused an arithmetic
  exception before serialization. Restored pre-diagnostic files had old mtimes;
  touching the affected headers/sources and rebuilding dependencies fixed the
  mixed class layout. This was a build failure, not a physical-state exception.
- `run-2/`, `run-3/`: initial wake-counter validation failed on the projectile.
  The pending-force rejection check adds then clears a force, leaving the actor
  logically awake at 0.4 while the prior GPU value is 0.3. Export now preserves
  the ordinary actor's logical wake state; no force is lost or replayed twice.
- `run-4/`: all 28 cases pass on matching V20 modules. Isolated artifacts are in
  `artifacts-2/` (binary `probe-4`); receipts contain their exact SHA256 hashes.
- `memcheck/`: the broad 28-case sweep hit its 600-second harness limit after
  23 cases. No errors were reported before timeout, but this is incomplete and
  is not a full sanitizer pass.
- `final-suite/`: all 28 cases pass again; it also freezes the input immediately
  before the first observed fracture. No source-versus-restore tolerance change.
- `replay-building-warm/`, `debug-file/`: the first new-process replay helper
  attempted to construct a PhysX stream before its foundation/allocator. The
  backtrace identifies `PxGetAllocatorCallback`. Initializing the foundation
  before the streams fixes this helper initialization bug.
- `file-*/`: six new-process cases pass 20 independent restores and exactly one
  tick each (120 ticks). Input-file SHA256s are recorded. The first-fracture
  input breaks one bond and performs one correction/two stress evaluations in
  **all 20** samples. Position/linear/angular differences between independently
  restored outputs are zero. [Full one-tick measurements](snapshot-v20-file-replay.md).
- `mem-file-*/`: five targeted memchecks pass with **zero errors**, using two
  independent one-tick file restores each: the fragmented building, tall
  structure, partial damage, first-fracture correction and explicit impulse.
  All corresponding physical/repeatability checks pass under the sanitizer.
- `native-regressions.log`: **9/9 CTests pass**, covering materials, retained
  registry, rigid checkpoint, command wake, correction bodies, resimulation,
  post-correction, ordinary awake and wake boundary.

The final standalone replay binary is `final-artifacts/file-replay-verified`;
the full-suite binary is `final-artifacts/native_destruction_snapshot_test`.
Their GPU/runtime modules match. The standalone helper's only subsequent change
fixed initialization order in its new file-replay branch. Receipt hashes identify
each tested executable exactly. Root build contains the final helper.

Use the [file-replay command](../../tools/diagnostics/destruction-snapshot/README.md)
to load saved files without rerunning a capture prefix. The helper recreates its
fixed fixture scene settings; general applications continue to supply their own
scene configuration. Restore costs (scene creation plus stress configuration)
are reported separately from the complete tick, which includes optional command
submission, physics, stress, transfers/synchronization and correction/publication.
All owned runs are terminal. No installation or deployment occurred.

Scope remains the current native ordinary rigid destruction path. Removed/crushed
geometry, joints/articulations/CCD and unapportioned loaded-source commands retain
the engine's existing restrictions. This does not resolve historical migration
or native-memory findings and is not a deployment or optimization experiment.

The following material is the preserved history of the stronger checkpoint
investigation; its unsuccessful exact-continuation results are unchanged.

## Scope correction: physical-state save/load

The user clarified that rebuilding solver/contact caches from saved physical
state is acceptable. The investigation below pursued the stronger requirement
of matching an uninterrupted scene's execution history. Preserve its results,
but do not continue CPU allocator/free-list serialization as a prerequisite.
See [the clarified contract](../../docs/destruction/SNAPSHOT.md). V19 has not yet
been migrated or qualified against that contract; existing failures are not
retroactively passes. No performance claim changes.

## Historical status: CPU contact activation history remains

Full public V19/schema6 export/import: **27/28 cases pass**, including explicit
post-restore stimulus, cold/warm geometries and small fracture continuations.
[Per-scenario correctness and scoped diagnostic timings](snapshot-v19-results.md)
are generated from `out/snapshot-20260911/v19-suite/`. No current sanitizer
qualification or new application speedup is claimed.

For the heavily fractured444-chunk/378-owner building, prior friction and static
contact ordering plus retained regular partitions give two consecutive ticks
with zero chunk-position and velocity differences. The third tick still fails:
1.544910716mm maximum chunk position difference, velocity difference0.387431562.
The unchanged gates are0.1mm,0.0001m/s linear and0.0001rad/s angular velocity. Full restoration is not done.

The remaining cause is now localized. At tick2, two newly touching pairs activate
in CPU contact-manager pool-index order (`PxsContext::fillManagerTouchEvents` →
`Sc::Scene::setEdgesConnected` → partition activation). Source pair369/303 uses
poolindex69 and precedes368/303 at345. Restored368/303 uses318 and precedes369/303
at319. Their two regular partition assignments reverse. Full contacts/geometry
and static-contact ordering still match. Evidence: `run-cm-pool-audit/` managers,
activated, found-order and partitions CSVs, plus receipt/module hashes.

A causal NP slot-compaction model reproduces every source NP index for all three
audited ticks using only source PRE-tick slots and the restored scene's own
new/removed pair sets. The live v2 diagnostic restores found-patch order, but CPU
activation order is a separate pool and remains different. Persistent node-rank
compaction did not remove this failure either. Do not claim these diagnostics as
qualified implementations, or simply reverse/sort contacts using future output.

Next target: preserve CPU contact pool allocation/activation history (including
free-list/batched-allocation semantics and new/lost lifetimes), then integrate
validated history into the public codec instead of trusted-file hooks. General
wake/sleep, new fracture/correction, pool reuse and native pending metadata still
need qualification. After correctness: full suite/sanitizers, restored one-tick
semantic benchmarks, then resume the remaining9 optimization experiments.

Root runtime/GPU and native consumers are rebuilt unaccepted N14+V19 diagnostics;
installedSDK and retainedN13 are unchanged. All owned runs are terminal. Detailed
source builds and immutable artifacts: `out/snapshot-20260911/contact-order-v2/`.

## Contact-history diagnosis: first two ticks exact

`out/snapshot-20260911/v19-suite/`: normal V19 suite completes27 passing cases;
fragmented444-chunk building still fails without diagnostic state restoration.
No tolerance changes. V19 sanitizers are still pending.

Matched source PRE-tick history, same frozen building input and current contact
discovery, produces the following diagnostic sequence:

| Additional restored history | Maximum first-tick chunk position difference | Max of linear/angular error magnitudes (m/s,rad/s) | Result |
|---|---:|---:|---|
| Regular partitions + CPU upload ownership |2.06994mm|0.246088|Fail|
| Plus154 valid friction patches |0.941364mm|0.160145|Fail|
| Plus static-contact ordering (92/105 entries reordered) |0|0|First two ticks pass; third fails|

The third tick changes two regular partition assignments despite identical
contact pairs. Persistent source-node compaction order is now under test.
Source actor insertion order alone, even with friction/partition restoration,
does not change the remaining error. Saved friction includes6 single-anchor
patches; unused second anchors are normalized, not read from unused storage.

These trusted-file hooks are diagnostics, **not** the public export/restore
implementation. No snapshot benchmark or performance win is qualified. Next:
qualify persistent scheduling and native contact lifetimes, then replace file
hooks with validated first-class serialized state. Logs, module hashes and
commands: `out/snapshot-20260911/continuation-diagnosis.json` and each run receipt.

## V19 continuation update

The full V19 suite passes27/28; the fragmented444-chunk/378-owner case
remains unqualified. `out/snapshot-20260911/run-v19-upload-state/` confirms exact
destruction re-export and all regular contact partition assignments with a
PRE-tick-only diagnostic seed. Position/velocity continuation still differs by
2.06994mm/0.246088 (the latter is the legacy max of linear and angular error magnitudes). All1,308 contact geometries match. V19 fixes ownership of
initial CPU metadata upload: sleep-filter input discrepancies fall353→1. That
remaining body (stableID4294967321) also has a one-step wake-counter discrepancy.

This is diagnostic progress, not accepted full-world restoration or performance.
V19 sanitizers remain pending. New friction-history diagnostic captures
only valid prior-tick anchors, matches them to freshly discovered pairs, and seeds
after new-edge cache clearing. It has not yet produced a correctness result.
The root GPU contains these temporary hooks; retainedN13 and installedSDK are
unchanged. The optimization batch remains11/20.

## Latest diagnostic: native rigid, shape and scheduling state

Earlier private runtime V18/schema5 WIP evidence follows. Frozen V17 passes 27 cases (the
additional case verifies post-restore impulse and angular-velocity commands).
The large fragmented building still fails. V16 canonical rigid bodies alone did
not change the error. V17 shape-transform capture resolves **all** contact-point
position differences: 1,308/1,308 pairs match exactly, compared with 1,210/1,308
before this fix. Full continuation still differs by 8.8715mm / velocity1.46746.
V17 pre-solve positions, velocities, mass and inertia match. CPU sleep bookkeeping
and flags differ; V18 records CPU state separately but remains unqualified.

The retained rigid constraint schedule is missing from object serialization:
805/1,203 contacts change partition and 1,182 change partition-entry position on
the restored next tick. The source has 1,251 partition edges before export; next
tick loses54/adds6, and57 retained edges change partition through normal repair.
A correct restore must preserve prior partition/contact state and let ordinary
current-tick discovery apply those changes. Do not freeze an old schedule, use
future-step data, reset source caches or weaken the motion gate to force parity.

Raw: `out/snapshot-20260911/v17-partition-audit/`, `v18-cpu-audit/`,
`run-v17-shape-state/`, `v17-suite/`, and `contact-audit-findings.md`.
V15's 26-case zero-error memcheck does not qualify newer native snapshot fields.
No new optimization result; retained N13 idle/heavy timings are unchanged.

---
Historical implementation record follows (V15):

# Snapshot implementation status — 2026-09-11 continuation

The first-class destruction API is now implemented: `PxDestructionScene::exportState` /
`importState`, public API16/private runtimeV15. See [the API contract](../../docs/destruction/SNAPSHOT.md).
It restores accepted topology/material state, stable shape/body bindings, cluster
handles, frame status, normalized force guesses, valid exact-input certificates,
response history and fine inverse caches. Import does not advance physics. A native
CTest is registered and all private ABI consumers were rebuilt. This is new
architecture/correctness work on the preserved N14 source, not a promoted runtime
optimization. Retained N13 and the installed SDK remain separate artifacts.

**Full scene replay is still not qualified.** Twenty-six small/structure cold/warm
GPU cases pass, with exact destruction section re-export and ten matching physical
continuation ticks. The additional real integrated projectile-fractured building
(444 chunks, 378 owners, 781 broken bonds) fails the first resumed physical tick:
maximum chunk position error8.871mm and velocity error1.46746. Destruction state
re-export, health/connectivity/damage, fracture/correction counts and 4,537 reported
contact points match. Source/restored one-tick times5.779/10.011ms are diagnostic,
not acceptance samples. All scenario timing scopes and numbers are in
[snapshot results](snapshot-results-20260911.md).

Two diagnoses were tested: CPU/GPU rigid velocity mirrors match exactly, with only
2.13248micrometres maximum actor-pose conversion difference; inserting restored
actors in source native order leaves the larger error unchanged. A frictionless diagnostic also fails (11.327mm maximum position error, velocity
error4.14213), so friction anchors alone do not explain the mismatch. The next
hypothesis is omitted canonical native GPU body state (COM transforms, internal
flags, sleep accumulators, previous velocities and prescribed kinematic input),
which PhysX object loading reconstructs instead of restoring. This is a new
diagnosis, not an accepted fix. Contact-manifold state remains another possibility. NVIDIA's [simulation determinism documentation](https://nvidia-omniverse.github.io/PhysX/physx/5.7.0/docs/Simulation.html)
and [serialization contract](https://nvidia-omniverse.github.io/PhysX/physx/5.6.0/docs/Serialization.html)
do not establish a complete persistent-contact cache checkpoint. No tolerance is
relaxed and the existing semantic benchmark is not switched to restored snapshots.

Raw runs: `out/snapshot-20260911/`. V2 frozen modules are in `v2/`; the 26-case
success is `run-v3/`; the large-case failures/controls are `run-v4/` through
`run-v7-native-order/`. The memcheck of all26 passing fixtures completed in `memcheck-v3/` with
**zero errors**. The stronger full-building motion gate remains failed. The historical substrate-only investigation below is preserved.

---

# PhysX / destruction export and restore — current finding

The2026-09-11 user direction makes **first-class accepted-world export/restore the next prerequisite**, ahead of additional prefix campaigns or a larger scenario count. A benchmark repetition must restore one accepted input state, apply the frozen current command batch, then execute one complete tick: ordinary physics → current-contact stress/material/fracture → at most one corrected physics advance → second stress → accepted publication. A two-evaluation tick is still one tick.

## What was verified on this GPU

This checkout provides `PxCollectionExt::createCollection(scene)`, `PxSerialization::serializeCollectionToBinary`, `createCollectionFromBinary` and `scene.addCollection`. The SDK's [serialization documentation](https://nvidia-omniverse.github.io/PhysX/physx/5.6.0/docs/Serialization.html) describes collection-based object export/import. The local binary serializer supports the tested dynamic body pose/velocity/sleep data. The in-tree snippet is `physx/snippets/snippetserialization/SnippetSerialization.cpp`.

Five actual ordinary/sleeping GPU fixtures were exported/restored: flying, sliding contact, resting, intact destruction, and a projectile-fractured two-chunk structure. We compared the next tick and ten continuation ticks against the untouched source. In the final diagnostic, selected rigid-body positions/velocities and both authored chunk positions matched exactly. Sliding contact was confirmed through callbacks (four reported points); the generic GPU simulation-statistics contact counter was zero and is not a valid presence test here.

**The existing serializer is not a complete destruction save/load feature.** Intact and fractured source scenes each had two destruction chunks; imported scenes had zero. `PxDestructionScene` has no serialization participation or restore API. A matching actor pose cannot certify a restored stress/material simulation when that simulation is absent.

A second concrete bug was found and fixed: private accepted fragment actors were absent from the public actor enumeration used by `PxCollectionExt`. After fracture, the original collection contained only **one of two authored shapes**. The fix includes GPU-scene rigid owners discovered through their persistent published shapes, filters by the target scene and avoids instantiating the optional destruction runtime. Both shapes now round-trip; source-versus-restored positions remain exact through ten continuation ticks in this fixture. An additional collection while both scenes exist verifies that other-scene actors are excluded. This is an export correctness/architecture change, **not a speedup**. It changes only `ExtCollection.cpp`; runtime solver and installed SDK are unchanged.

Read-only source evidence also shows that `Sc::ActorCore(PxEMPTY)` resets its simulation pointer and scene insertion reconstructs simulation internals. Thus object serialization cannot simply be assumed to clone every persistent contact/solver cache. The simple round trips passing do not prove cache-equivalent replay for a large impact. The existing destruction `restoreRigidState` explicitly excludes CPU/island/contact state.

Raw baseline: `out/semantic-suite-20260911/serialization-probe-v4/run/`.
Fixed collector: `out/semantic-suite-20260911/serialization-probe-v5/run/`.
Small durable results: [serialization-coverage.json](serialization-coverage.json).
The first diagnostic accidentally used a degenerate one-argument box constructor; it emitted inertia warnings and is excluded. Valid cube probes supersede it; the final run has no warnings. No tolerance was loosened.

## First-class feature contract to implement

Use PhysX object serialization as a substrate and add a versioned destruction state section referencing stable serialized actor/shape IDs. Do not write device pointers, temporary GPU indices or pool addresses as persistent identities. An export must be taken after a successful accepted fetch with all consumers joined; reject pending/failed correction or incomplete publication.

The destruction section must include immutable chunk/bond geometry and materials/settings; accepted live masks, bond health and chunk damage/crush state; current support, topology and motion ownership; physical mass/COM/inertia; accepted frame/event/command accounting; and numerical warm state/certificates with their validity keys. Persist authored identities across reordered allocations. Capture the game's command/stimulus batch separately with exact ordering and interval identity. Preserve ordinary actor/query compatibility and distinguish imported application actors from scene-owned fragments.

Restore into a new world transactionally: validate the entire manifest/schema/lengths/identities first, construct/import object dependencies, remap shape-contact and body IDs, rebuild or restore destruction topology and material state, establish GPU readiness without advancing physical time, then make the world available. Existing `configureStress` cannot currently do this alone: it requires positive initial bond health and initial bindings matching the intact bond components, while post-fracture snapshots contain broken bonds across different owners. That import path needs explicit support, not skipped validation.

Physical resume and benchmark replay need separate guarantees. A portable restore may rebuild caches, but benchmarking a naturally warm tick requires restoring or recreating the valid state that existed at capture. Report benchmark restoration separately; keep genuinely new candidate preparation and cache construction visible in setup/amortized application cost. Never give a candidate free precomputation or charge only one arm for state reconstruction. A restored tick must not include an undocumented warmup physics advance.

Acceptance gates: export→restore state identity; untouched-versus-restored next-tick and short/full continuation physical checks; broken-bond/material/support preservation; all fragments/contacts/queries; exactly-once commands/events; rejected corrupt/incompatible inputs without damaging the source world; restore A→B→A without contamination; convergence and the one-correction/two-evaluation limits. Include intact idle, active contact, first split, already fragmented, settled and reawakened cases. Only after those pass should the24-case harness switch its execution mode from fixed prefix to `restore + one tick`.

## Structure and island coverage after restore

The current24 cases and [ten-repeat results](semantic-suite-results.md) are retained. Expand by mechanism, not arbitrary frame count: tall and long thin walls; wide low halls with sparse columns; supported panels and cantilevers; densely braced loops; narrow connecting necks between large regions; many tiny free components; a few large supported/free components; mixed/bimodal island populations; and a large quiescent background with one active region. Cross those with cold/valid-warm/invalidated state, contact onset, continued loading, fracture/correction, and settled/reawakened states. Select roughly50 useful coverage cells rather than their entire Cartesian product. Keep motion-cluster counts separate from actual stress unknown components and PhysX contact islands.

## Commands

```bash
.toolchains/build-env/bin/cmake --build out/sdk-release --target PhysXExtensions -j6
python3 tools/diagnostics/destruction-snapshot/build-probe.py out/NEW-serialization-probe
python3 tools/diagnostics/destruction-snapshot/run-probe.py out/NEW-serialization-run \
  --binary out/NEW-serialization-probe/serialization-probe \
  --artifacts out/semantic-suite-20260911/N13-geometry --require-complete-shapes \
  --allow-existing-graphics --allow-compute-pid 435374
```

The probe uses the existing native compiler/link flags and static PhysX libraries, records exact commands/source/binary hashes, and runs with frozen N13 CUDA modules. It is a diagnostic prerequisite, not a user-facing snapshot API or a complete restore qualification. Do not report the feature as implemented yet.
