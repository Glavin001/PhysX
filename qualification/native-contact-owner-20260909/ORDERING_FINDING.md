# Contact retention changes a numerical scheduling dependency

**Status: causal diagnostic, not a production fix or performance result.**

## Matched experiment

All captures use the frozen single penetration scene: 444 chunks, 896 bonds,
one projectile, 600 steps at 1/60 s, max one correction. The historical fixture
has Direct GPU enabled and sleeping disabled. No physical parameter or oracle
was changed. Rendering/video are disabled; heavy motion/identity observation and
temporary contact-order tracing make these correctness diagnostics only.

The reconstruction reference is the same internal ABI and GPU implementation,
with retention disabled in a temporary separately preserved test executable.
It passes the exact frozen wall oracle. No reference switch remains in source.

At the first corrected advance (diagnostic pass 20, accepted scene step 17):

- Reference and retention have identical sets of 128 changed contact pairs.
- Both have 41 dynamic contact patches in the ordinary partition traversal.
- The four projectile pairs have identical ordered shape identities and patch
  counts in narrowphase. Pair storage/edge allocation IDs differ as intended.
- Reference activates the new fragment contacts first, then projectile contacts
  in shape order 244, 245, 272, 273.
- Retention activates projectile contacts first in order 273, 272, 245, 244.
- This changes constraint coloring/order: the first partition in retention
  contains a projectile contact that is absent from the first reference partition.

These counts concern changed pairs and dynamic partition patches, not every
contact point or static/kinematic solver row in the scene.

## Why the order changes

`PxsContext::fillManagerTouchEvents` scans `mContactManagerTouchEvent` in ascending
CPU pool index, looks up each `PxsContactManager`, and appends the event.
`Sc::Scene::setEdgesConnected` consumes that sequence. Accurate island activation
then determines `PxgIncrementalPartition` constraint insertion and coloring.

Retaining the contact manager retains its old CPU pool index. Reconstructing the
manager reallocates an index from `Cm::PoolList`; that allocation history was an
implicit numerical scheduling input. Geometric pair identity and solver
registration lifetime cannot be treated as the same identity.

This is not evidence that NVIDIA's ordinary rigid-body solver is slow or wrong.
It exposes an integration requirement: finite-iteration contact solving depends
on constraint order, so changing our ownership lifecycle can change fracture
loads even when narrowphase pairs are unchanged.

## Counterfactual and rejected experiment

1. Delaying replacement edges to the ordinary speculative island insertion
   boundary did **not** change accurate-island activation order or pass the
   oracle. That queue was removed. `delayed-owner-rejected.patch` preserves it.
2. A temporary diagnostic applied the captured reference touch-event order only
   at the first correction, after checking all 128 event identities matched.
   Geometry, pair storage, material/stress equations and solver settings remained
   the candidate's. The projectile position matched the reference exactly through
   scene step 31. Later motion differs slightly, but the entire 600-step frozen
   topology hash and required final counts pass: 398 supported chunks, 46 detached,
   199 broken bonds and 43 clusters.

The counterfactual establishes this scheduling difference as sufficient to
explain the controlled failure. It does not qualify arbitrary retained-contact
workloads or prove that every remaining ownership invariant is correct.

The recorded-order table, CPU sort, trace printing and reference early return
have all been removed from production source. There is no hard-coded fixture
ordering rule or new compatibility backend.

## Required implementation next

- Keep geometric pair identity/generation and reusable storage persistent.
- Give rebuilt solver registration its own generation-bearing identity and
  deterministic activation key. Ownership changes invalidate solver registration;
  they do not end the geometric pair lifetime.
- Allocate/update that registration in the native GPU lifecycle and produce the
  ordered native touch/activation work on device. Do not add a CPU event sort or
  simulate the old CPU allocator as another permanent compatibility subsystem.
- Make the native consumer honor the GPU-produced sequence instead of silently
  replacing it with CPU contact-manager address/index order. Preserve ordinary
  contacts, supported constraints, wake propagation and required observations.
- Qualify the real GPU rule against frozen fracture/identity oracles and broader
  lifecycle tests. The counterfactual's recorded table is evidence, not that rule.

C1/C2/C3/C6 remain unfinished. No speedup, 60/120 Hz capability, or performance
qualification is claimed by this experiment.

## Reproduction evidence

- `order-trace.patch`: temporary narrowphase/partition instrumentation.
- `first-correction-order-probe.patch`: temporary diagnostic counterfactual.
- `order-trace-{reference,candidate,counterfactual}.log`: actual ordered records.
- `order-reference-quality.json`, `order-counterfactual-quality.json`: passing
  exact oracle results, including capture/artifact attestations.
- `order-counterfactual.json`: workload and experiment interpretation.
- Full captures/executables remain in `out/native-contact-owner-20260909/` under
  `wall-order-trace-*`, `wall-order-counterfactual`, `order-trace-*` and
  `order-counterfactual`. These are isolated artifacts, not deployed libraries.
