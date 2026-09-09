# Current solved-contact response validity — qualified fixtures and short paired screen

This continuation fixes a pre-existing destruction input defect while qualifying
ranked replacement 1's deferred public shape ownership. It does not complete GPU
simulation registration/contact ownership, and is not a claimed speedup.

## Defect and evidence

Narrowphase retains contact geometry and normal-force offsets for pairs which
may have no current solved response. The native destruction consumer previously
read every such force slot. Non-null storage and geometric contact count were
not evidence of a current impulse. Post-step sleeping flags are also insufficient:
a body can receive a valid response and then go to sleep in the same step.

A separate diagnostic fills normal-force/face-index OUTPUT storage with NaNs
before each outer simulation advance. It does not modify friction caches, solver warm starts,
physical inputs or equations. Both committed 965803d8/V5 and the prior V6 WIP
completed steps 0–81, then failed with stage error 4130 at step 82, the first
sleep transition. The fixture is one building, 444 chunks, 896 bonds and one
projectile, Direct GPU off, sleeping on, dt=1/60, correction limit one.

With the fix, that poisoned-output diagnostic completes all 128 steps. This
establishes a real stale/unwritten-output consumption defect in both versions.
It identifies a defect at the boundary of the previously intermittent extra-bond
verdict; the precise original unpoisoned one-bond outlier has not been reproduced
causally and must not be erased from the earlier receipt.

## Final implementation and costs

- A 64-bit response epoch advances at every narrowphase pass, including idle and
  corrected passes. Zero means never solved; exhaustion reports an error and
  aborts explicitly rather than wrapping.
- New/recycled contact managers start with epoch zero. The epoch occupies former
  contact-output padding, without expanding that record.
- Existing constraint preparation retains the contact-manager output index in
  each work lane (four additional bytes per allocated contact work lane).
- PGS and TGS share one writeback helper. Only actual nonempty normal writeback
  publishes the current epoch, after normal/friction outputs are produced.
  Multiple patches use an atomic exchange; the existing kernel dependencies,
  not this stamp, establish consumer readiness.
- The native load consumer rejects responses from a different pass before
  reading force/friction storage. There is no sleep-state heuristic, force-buffer
  clearing kernel, force readback or additional launch/host wait.
- Private factory/interface is V7; public API ABI remains 15. CPU, GPU and Rust
  consumers have been rebuilt together. Do not load V5/V6 consumers with V7.

The timing comparison includes BOTH deferred final shape publication and response
validity against committed 965803d8. It cannot isolate the cost of either change.

## Verification

- All 49 selected native tests passed, including ordinary queries, correction,
  publication, contact loads, renderer consumers and sleeping.
- New PGS and TGS fixtures: two chunks, one bond, one ordinary load body, 180
  steps each. Both retain valid response on the sleep-transition step, report no
  current response during quiet sleep, and produce fresh responses after waking.
  Normal output storage is poisoned every step. CUDA memcheck reports zero errors.
- The small fixture removes sleeping pairs from NP; absent geometry is valid.
  It does not pretend to exercise retained sleeping geometry. The building poison
  counterexample covers the stale-output failure that the small fixture cannot.
- Historical penetration: 444 chunks, 896 bonds, one projectile, 600 steps,
  Direct GPU on/sleeping off. The unchanged frozen gate passes: 398 supported
  chunks, 46 detached, 199 broken bonds, exact topology and real wall clearance.
- Ordinary penetration: same asset/projectile, 128 steps, Direct GPU off/sleeping
  on. The original `native-settled-local-20260909/wall-standard` reference passes
  without changing its tolerances or golden data.
- The optional compressed stress trace reads accepted health and the last solve's
  forces/loads after the complete-step timer. It is a diagnostic, not a new
  production readback or a trace of both internal solve passes.

Initial test development failures are preserved: missing header includes, a
hidden internal-symbol link attempt removed in favor of existing inline test
access, and an incorrect fixture assumption that sleeping NP pairs must remain
listed. An initial wall driver log-name collision prevented those invocations
from starting; the actual subsequent audits pass. An initial timing attempt
failed to load the module from a no-exec RAM mount; its captures are retained
separately and are not counted as completed performance trials.

## Artifacts and remaining work

Current builds, logs, quality files and command receipts:
`out/contact-response-20260909`. Earlier negative controls and four-way stress
observations: `out/final-shape-owner-20260909/stress-diagnostic`.

The matched short screen uses 256 buildings, 113,664 chunks, 229,376 bonds and
256 simultaneous projectiles, plus an independent pristine zero-shot scene;
96 complete steps per run in ABBA order. Initialization/first-step spikes remain.
[Generated destruction comparison](shots/report.md) and [fresh idle comparison](idle/report.md)
retain all samples. Destruction peaks are baseline 132.286/131.901 ms and candidate
133.337/131.040 ms. There is no demonstrated peak win; the observed worst fracture
peak is 0.8% higher. Idle medians overlap (baseline 0.424–0.453 ms, candidate
0.449–0.453 ms); first-step peaks remain roughly 154–158 ms. These intervals do
not establish statistical equivalence or a reliable slowdown.

Both candidates first differ in reported normal-contact counts at tick 59
(145,869 vs 145,969), while broken bonds, fragment counts and awake counts first
differ at tick 78, also the first divergence of the two baseline runs. This is
consistent with excluding unsolved contact outputs, not proof of large-scene
trajectory equivalence. Correction counts match throughout. The primary tick-48
fracture remains before these counted differences.

A separate 64-step ordinary wall phase capture exercises `finalShapePublication`.
The report's nested parent residual plus child times pass disjoint accounting;
GPU preparation still precedes CPU registration. Its initial validator used the
obsolete unsplit parent key; the validator was corrected and the same capture
validated without rerunning simulation. See [accounting receipt](evidence/phase-accounting.json).

The changes are retained as a physical input fix and bounded architectural progress,
not a speedup. Full endurance and large-scale physical qualification remain outstanding.

CPU simulation registration, activity/iteration metadata and shape/contact
rebinding still precede corrected physics. Continue their GPU ownership migration,
then ranked replacements 2–7. No source-sibling edits, deployment or service changes.
