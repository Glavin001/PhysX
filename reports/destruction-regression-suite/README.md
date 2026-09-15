# Destruction regression suite: physical contracts and independent oracles

Published 2026-09-13. **Implementation is prepared; remaining native and sanitizer
qualification is queued behind attribution at the user's request.** This is a
regression-harness change, not a runtime optimization or a claim that all physical
model errors are fixed. The new unequal-mass oracle exposes a real, pre-existing
mass-normalization approximation that remains unresolved.

The suite strengthens accepted physics checks while removing accidental dependence
on internal labels, arithmetic bit patterns and scheduling counts. Production
solver, runtime and installed SDK files were not changed by this work. The earlier
[coverage audit](../destruction-test-coverage-audit/README.md) is preserved as the
pre-change assessment. The executable contract and exact commands are in
[REGRESSION.md](../../tests/destruction/REGRESSION.md).

## Qualification at this checkpoint

| Layer / scenarios | Result | Evidence and limits |
|---|---|---|
| CPU checkers, negative controls, measurement integrity | **Pass: 125 methods in ten scripts; final admission follow-up passes seven, adding one distinct method (126 total)** | [CPU summary](evidence/cpu-summary.json). Follow-up adds replay-prefix attestation. A fresh combined run is also queued. |
| Free equal-mass body: ordinary APIs, gravity, COM impulse, spin; reordered/rotated variants | **Pass: four cases, 240 full ticks** | [Native physical log](evidence/native-v5-retry--physical-outcomes.log). Independent trajectory, velocity, orientation and zero-internal-stress checks. |
| Supported equal-mass columns: reordered/rotated variants, half timestep, below-elastic load | **Pass: six cases, 96 full ticks** | Same log. Axial load versus supported mass × gravity; scalar section-loss history catches skipped/duplicated damage under unchanged stimulus. |
| Independent 3D equilibrium: 18 nodes / 33 bonds and 1,058 nodes / 2,553 bonds; free/supported; amplitudes 0.5, 1, 0, −0.75 | **Pass: 16 solves; four deliberate force corruptions rejected** | [3D log](evidence/native-v5-retry--independent-equilibrium.log). Independent published-gradient gate plus precise six-channel force reference. |
| Preserved 52-scenario corpus, A1 and B versus A0 | **Pass: 104 post-tick observation comparisons** | [Every scenario](evidence/all52-checks.csv), [complete results](evidence/historical-v2--results.json). Historical N20 observations; no new GPU ticks or timings. Checks compare first exported post-tick observations, not a new independent equation solution for every repetition. |
| Preserved ordinary/sleeping penetration wall | **Pass: 600 ticks × 444 chunk motion records** | Same result file. Position, linear and angular differences zero; maximum quaternion dot error 2.22e−16. One projectile; 896 initial bonds. This revalidates historical data. |
| Unequal-mass supported column | **Fail: 27.746870 N versus physical 29.430000 N** | [Original failed native log](evidence/native-v4--physical-outcomes.log). Not waived; separate model-accuracy tier remains failing. |
| Complete native tier, new-fixture memcheck/initcheck/synccheck, fresh CMake registration | **Pending after attribution** | [Live deferred receipt](../../out/regression-suite-20260913/deferred-v2/validation.json). Earlier native run passed its first two commands, then stopped on lock contention. No whole-tier pass claimed. |
| Fresh final application qualification | **Not run for this harness change** | Available final tier runs CPU/native, sanitizers, matched full52, asynchronous full52 memory checks and a 600-tick wall. It does not automatically promote a candidate. |

The 52-case table retains bridges, cantilevers, chains, ladders, panels, towers,
other structural edge cases and all city25/city64/city256 destruction stages.
Restore time is not added to full-step latency. This report contains no new
application timing comparison: executable wall durations include test setup,
readbacks and assertions and must not be used as simulation performance numbers.

## What changed and why

| Change | Physical protection / optimization freedom | Status |
|---|---|---|
| Continuous checker now reads orientation and linear/angular velocity | Catches velocity/spin regressions even when positions still agree | CPU negative tests and 600-tick historical replay pass |
| Snapshot checker validates finite state and static poses | Equal NaNs/infinities and moved stationary bodies cannot silently pass | Negative tests and all52 historical comparisons pass |
| Canonical connectivity by authored membership | Component root renumbering is allowed; actual merges/splits still fail | Positive relabel and negative partition tests pass |
| Generation, array order, work/contact counts and CPU/GPU ownership settings become explicit diagnostics | Implementation can change without requiring identical bookkeeping | Strict investigation mode retained; physical settings/material outcomes remain required |
| Quaternion sign equivalence | q and −q are the same orientation, including COM orientation | Invalid norm and true rotation errors still fail |
| Independent published-gradient check in 3D oracle | A solver's own convergence flag or agreement with legacy approximation is insufficient | All16 native systems pass; deliberate corruptions fail |
| Hierarchy bit patterns and graph-build count become optional diagnostics | Valid arithmetic/scheduling changes are not rejected solely for changing bits or launch organization | Independent diagonal/sparse operator equations remain mandatory; full native rerun pending |
| Independent free-body and material-history fixtures | Detect lost/double impulse, wrong gravity/spin, false internal stress and skipped subfatal damage | Ten cases /336 ticks pass |
| Isolated benchmark-admission fixtures | Tests do not contend with the live benchmark lock; real private-lock contention still fails | Six CPU methods pass |
| Attested serial build/run entrypoints and CTest serialization | Missing/changed binaries, incomplete52 inputs and mismatched replay-prefix attestation fail closed | CPU admission tests pass; fresh CMake configure queued |

Physical tolerances remain explicit in the contract. The wall retains its existing
1 mm position/COM bound; restored vectors retain 1e−4 bounds, orientations 1e−5
dot-error, derived bond forces 2e−4 scaled error. Material health, crush, active
bonds and loads remain exact in matched snapshots. No approximate-damage policy
was introduced. Exported physical schemas and public lifetime safety remain
contracts, even when private implementation details change.

The published-gradient checker propagates a conservative single-FP32-ULP force
export uncertainty through the absolute forward and transpose operators. The
resulting bound is calculated from the operator and actual exported values, not
fitted to a candidate. It can be conservative, so independent force-reference
comparison remains necessary, especially for self-stress invisible to equilibrium.

## Known model-accuracy failure

A column with unequal dynamic chunk masses of 1 kg and 2 kg should carry 29.43 N
above its support under gravity. The frozen solver reports 27.746870 N, consistent
with replacing the two masses by their geometric mean: `2 × sqrt(2) × 9.81`.
The source's mass-equalization path explains this result. This is a model
approximation, not a harmless change in reduction order or FP32 export rounding.

The regression fixtures use equal masses to validate behaviors for which the
current model has the hand-derived physical answer. The unequal-mass assertion
was preserved as `--tier model-accuracy`, exits nonzero, and is explicitly outside
the passing current-model regression tier. This separation must not be described
as fixing or certifying unequal-mass physics. Changing normalization requires this
case, broader heterogeneous-mass/inertia cases, full material/trajectory checks
and matched application qualification; production changes are outside this
regression-harness patch.

## Pending execution and retained failures

The user selected **let attribution finish first**. Coordinator PID1062367 waits
for both the primary attribution campaign and its phase-only supplement to report
completion. It does not stop either job or change services. Its
[receipt](../../out/regression-suite-20260913/deferred-v2/validation.json) is the live
status authority; this report is a dated checkpoint. It then configures a fresh
CTest tree, verifies registration/serialization, runs the CPU/native/sanitizer
tiers, and separately records the unequal-mass model audit. Source changes while
queued, lock contention or infrastructure errors stop it. Attribution failure
keeps it waiting for that campaign's owner to recover and finish successfully;
it never treats collector failure as permission to take the GPU. No failure is
converted into a physical pass. A future process ID alone is not proof
of progress—read the receipt and logs.

Preserved attempts under `out/regression-suite-20260913/` include the initial
stale `physx_scene` object ABI link failure (fixed by rebuilding that consumer
object), unsorted authored bond endpoints in an early fixture (corrected to the
public API's ordered-endpoint requirement), the unequal-mass physical failure,
and two GPU-lock contention exits. These are distinct causes, not solver failures
that were made green by weakening a tolerance.

The first deferred coordinator stopped when attribution failed during `cpu-full`;
[its receipt](evidence/deferred--validation.json) is preserved. The replacement
waits through collector recovery, with the same twelve-hour bound. It does not
restart or debug the separate attribution campaign.

## Reproduce and provenance

[Build evidence](evidence/build-v5--build.json) hashes actual linked objects,
headers, consumers and GPU modules. Runtime SHA256 begins `d5770a80`, activity
module `4c82a917`; the frozen solver build is
`out/n24-component-multilevel-20260912/build/A`. Test consumers are isolated in
`out/regression-suite-20260913/build-v5/`; the installed SDK is unchanged. The GPU
is the available RTX5060Ti; CUDA13.4 tools are used. These are correctness runs,
not profiled or exclusive-clock performance measurements.

[Provenance](evidence/provenance.json) records original paths, archived names and
SHA256 values. The decisive logs and summaries are included here; larger input
snapshots and binaries remain in their exact `out/` locations. Historical
revalidation and the queued continuation can be reproduced with:

```bash
python3 reports/destruction-regression-suite/revalidate-history.py out/NEW-history-check
python3 reports/destruction-regression-suite/finish-validation.py out/NEW-deferred-check \
  --artifacts out/regression-suite-20260913/build-v5 \
  --wait-for out/destruction-baseline-20260913/campaign.json \
  --wait-for out/destruction-baseline-20260913/phase-only/campaign.json
```

Do not start a duplicate while the recorded continuation is live. Exact general
CPU/build/native/sanitizer/final commands are in
[the regression contract](../../tests/destruction/REGRESSION.md).

This work does not provide a code-coverage percentage, comprehensive production
mutation testing or a proof of every possible destruction behavior. Independent
small oracles, native integration tests, large restored states and continuous
trajectories complement each other. Momentic/browser checks remain useful for UI
behavior; they are not the numerical authority for the native C++/CUDA engine.
