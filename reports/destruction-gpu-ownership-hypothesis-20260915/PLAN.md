# GPU ownership migration — implementation checklist

Status: implementation in progress. The isolated native transaction is built and
initial control/candidate GPU checks pass. Transaction-specific rejection, focused memcheck and synccheck pass.
All seven remaining focused native regressions pass. The complete contact/solver migration is not
implemented and no application gain is claimed. See [implementation evidence](IMPLEMENTATION.md).

## Objective and acceptance

Implement a complete fracture-to-corrected-physics path that consumes GPU ownership
directly, removing CPU fragment registration as a blocking prerequisite. Follow
the [hypothesis, scope and acceptance contract](README.md).

Success requires current fractured ownership without the legacy CPU dependency;
independently confirmed **at least 10 ms reduction** in the fixed City256 impact
window's mean complete-tick time; unchanged physical quality, ordinary APIs,
sleeping and maximum one correction; and no unresolved material regressions.
The 10 ms threshold is an acceptance target, not a predicted gain.

## 1. Establish the implementation boundary

- [x] Document the main hypothesis, evidence, scope and acceptance criteria.
- [x] Record that E1–E3 are supporting prototypes; the main migration remains unimplemented.
- [x] Create this checklist file and link it from the hypothesis report.
- [x] Preserve the selected baseline and unrelated changes; create an isolated candidate source directory; selected source and modules remain untouched.
- [ ] Enumerate every consumer between GPU fracture assignments and corrected physics.
- [ ] Classify each operation: required physical update, redundant reconstruction, or CPU-facing observation.
- [x] Specify transaction ownership, generations, lifetimes and completion events (resident transaction interface; see implementation evidence).
- [x] Identify shared consumers before expanding scope: active-body indexing and incremental contact partitioning in `PxgGpuContext::update`; CPU body and island records remain prerequisites.

## 2. Implement one complete path

- [ ] Supply current GPU body/shape assignments directly to collision and solver registration.
- [ ] Implement required filtering, contact retirement and current constraint preparation.
- [ ] Update affected island membership, activity, readiness and sleep/wake consumers.
- [ ] Remove CPU fragment construction/registration from corrected-physics prerequisites.
- [ ] Preserve CPU actor/query/callback visibility and complete publication before tick return.
- [ ] Handle capacity growth, slot reuse, stale generations, teardown and failure paths.
- [ ] Instrument removed and replacement work, including remaining CPU publication.

Do not automatically combine E1–E3. Record explicitly which foundations the
candidate uses. Keep unrelated sleeping eligibility restrictions until their
consumers are implemented.

## 3. Prove correctness and the mechanism

- [ ] Compare a complete fracture tick against the selected baseline.
- [ ] Test contact creation/removal, simultaneous cuts and second-pass ownership changes.
- [ ] Test ordinary-body interactions, filtering, sleeping, waking and callbacks.
- [ ] Test queries, snapshot round trips, capacity growth and slot reuse.
- [ ] Validate current inputs, unchanged physical tolerances and one-correction ordering.
- [ ] Run focused memory, initialization and synchronization checks.
- [ ] Resolve initialization defects affecting this path; preserve unrelated known failures explicitly.
- [ ] Demonstrate that the original CPU prerequisite disappeared rather than moving elsewhere inside the tick.

## 4. Measure and qualify

- [ ] Run the existing nine-case warm screen with first-impact Systems attribution and targeted GPU counters.
- [ ] Report every scenario's mean, observed peak, deadline misses, stages, preparation and actual work.
- [ ] Check City25/64/256 scaling and uninterrupted City256 idle/destruction.
- [ ] Confirm promising results using the contract's fixed independent paired design.
- [ ] Apply the at-least-10-ms primary target and per-scenario regression margins; retain inconclusive outcomes.
- [ ] For a qualifying candidate, run full52, relevant cold companions and uninterrupted physical-state comparisons.
- [ ] Complete memory/lifetime qualification and resolve all promotion blockers.
- [ ] Record the final decision: verified improvement, neutral architecture, rejected, or inconclusive.

Restore and fixed warmup remain outside tick timing. All recurring CPU/GPU work,
transfers, synchronization, correction and publication remain inside it.

## 5. Maintain progress and evidence

Check an item only when its deliverable or validation exists. After each completed
stage, update the record below. Source and raw evidence stay local under the
current commit policy. After three unsuccessful experiments in the same family,
reassess the diagnosis instead of continuing minor variants.

| Field | Current entry |
|---|---|
| Current stage | Stage 2 foundation: native ownership transaction built; contact/solver consumer migration pending |
| Candidate identity | `out/ownership-migration-20260915/source`, build `transaction-build-v3`; hashes in build receipt; no E1/E2/E3 composition; selected runtime unchanged |
| Result | Initial five control + five candidate native invocations pass; four transaction rejection/memcheck/synccheck invocations also pass; all seven final focused native regressions pass; no benchmark result |
| Evidence | [Contract](README.md), [prior prototypes](../destruction-ownership-implementation-20260915/README.md), [isolation receipt](../../out/ownership-migration-20260915/preparation.json) |
| Limitations | Main migration unimplemented; prior native initialization qualification gap remains |
| Next action | Replace the shared contact/solver registration dependency for affected contact islands; do not defer invalid CPU consumers |

## Progress history

- 2026-09-15: Created this checklist after implementation authorization. Preserved
  the existing working tree and prior prototypes. No runtime change or GPU run
  has occurred at this checkpoint.
- 2026-09-15: Copied and hash-checked all 2,215 baseline source files into the
  isolated directory. Restored seven E1-modified files from the frozen commit
  while copying; excluded the prototype's added files. Preserved the initial
  working-tree status and source manifest in ignored evidence. An external
  read-only GPU check confirms the device is available with no compute clients;
  the sandbox-only driver check failed and was not treated as a host GPU fault.

## Initial consumer audit — incomplete

These findings identify dependencies to address, not completed migration work.
Paths below are relative to the isolated source tree.

| Consumer | Current dependency | Required disposition |
|---|---|---|
| `PxgSimulationController::advanceDestruction` | Calls compatibility preparation and binding before returning control to corrected collision scheduling | Replace the simulation prerequisite; retain required final CPU observation |
| `ShapeSimBase::rebindRigidOwner` | Refilters bounds, retires contacts, registers the narrowphase owner and changes actor links | Separate mandatory physical changes from host representation changes; preserve lost-touch behavior |
| `Scene::processNewOverlaps` and `islandInsertion` | Allocate contact/interaction records and insert CPU island edges before narrowphase/solver continuation | Supply valid pair lifetime and connectivity data without requiring newly constructed fragment actors |
| `ShapeInteraction::createManager` | Reads actor/body types, body/core pointers and node identities | Migrate the required collision inputs and preserve ordinary reporting/filtering behavior |
| `PxgGpuContext::update` | Reads CPU active-body/kinematic lists and passes CPU islands/body manager to incremental partitioning | Supply current solver work membership and partition inputs; GPU shape ownership alone is insufficient |
| `PxgGpuContext::updatePostPartitioning` | Uses CPU node liveness, generations and retained edges even with GPU pre-solve connectivity | Cover these producers/consumers before removing their host dependency |

The existing device-connectivity ownership predicate still requires sleeping to
be disabled. It must remain guarded until its activity/readiness/sleep consumers
are correctly supported. Simply postponing body allocation would leave the
above consumers invalid; it is not an implementation of the hypothesis.

- 2026-09-15 implementation: added resident body/shape/node transaction and native
  commit call, generation/storage validation, single completion boundary, and
  rejection fixtures. V1 compiles and passes ten initial control/candidate native
  invocations. V2 test link failed because a frozen scene object had an older
  constructor than the frozen source header; V3 builds the matching scene source
  and links successfully. Failed receipts are preserved. No timing or promotion.

- 2026-09-15 validation checkpoint: V3 passes two transaction fixtures, focused
  memcheck and synccheck, and seven native regressions. Main contact/solver
  migration and application timing remain pending. No full initialization
  qualification, selected-runtime change, or promotion.
