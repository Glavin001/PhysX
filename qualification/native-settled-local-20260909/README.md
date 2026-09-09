# Component-local settled-stress reuse

**Implemented and correctness-tested; unpromoted optimization WIP.** Matched short
screens establish lower intact-idle cost. They do **not** establish better massive-
destruction peaks, 60/120 Hz, five-run qualification, endurance or completion of
the engine-ownership plan. No running service or installed runtime was changed.

## What changed

The GPU owns exact input snapshots and per-component convergence certificates.
A certificate requires a zero-update warm solve of the stored bond forces, identical
six-component physical loads and unchanged numerical settings. The existing topology
producer invalidates certificates for exactly the old components containing removed
bonds, before replacing their labels. Unrelated components retain their valid forces
and certificates, including across consecutive fractures. New split roots cannot
inherit their old parent's certificate. Material/crushing/damage evaluation remains
active independently of stress reuse.

This uses existing changed-component flags. It adds no host decision, readback,
reference-backend switch, relaxed tolerance or skipped physical verdict. The shared
Blast device observation view adds a read-only reuse-mask pointer; its C++ consumers
were rebuilt. PxDestructionScene and Rust's native ABI descriptors did not change.

The cache currently compares all active component loads and retains capacity-sized
storage; producer dirty lists, complete component-local hierarchy preservation,
GPU motion-slot lifecycle, contact ownership and selective correction remain open.

## Measurements

All runs use Direct GPU OFF, sleeping ON, dt=1/60, at most one correction/two stress
passes. Each regime uses **two baseline and two candidate runs of 600 steps / 10
simulated seconds**, alternating baseline/candidate/candidate/baseline. Every complete
step includes commands, physics, destruction, correction and accepted consumer state.
Rendering/networking are excluded; startup peaks are retained.

| Scene | Workload | Idle median baseline → candidate, ms | Fracture peak baseline → candidate, ms | Interpretation |
|---|---|---|---|---|
| 256-building city | 113,664 chunks / 229,376 bonds; idle zero shots, bombardment 768 shots | 0.567–0.580 → 0.413–0.433 | 133.140–133.482 → 131.589–138.358 | Idle improves; no demonstrated destruction-peak improvement |
| Connected downtown | 24,105 chunks / 74,543 bonds / 27 authored groups; idle zero shots, impact three shots | 0.621–0.638 → 0.357–0.359 | 128.316–128.777 → 128.048–128.398 | Idle improves; peak difference too small to establish improvement |

- [Generated city idle report](idle/report.md) / [bombardment report](shots/report.md).
- [Generated downtown idle report](downtown/idle/report.md) / [impact report](downtown/shots/report.md).
- All-step city peaks remain 159.619–159.716 ms baseline and 161.243–161.608 ms
  candidate during bombardment. Downtown peaks remain 201.589–202.288 ms baseline
  and 200.478–203.779 ms candidate. Neither deadline gate passes.
- Downtown ends with exactly 481 broken bonds, 32 fragment bodies and six corrected
  steps in every arm. City late chaotic counts vary in both arms; full raw results
  are preserved and counts are not substituted for physical equivalence.
- The global-generation predecessor is separately retained in
  [its receipt](../native-settled-20260909/README.md). It is superseded, not a runtime option.

[Existing startup diagnostic](startup-existing-evidence/report.md) is a regenerated
report from the **earlier baseline capture**, not this candidate: the 158.558 ms first
step contains 154.321 ms in the still-broad trial/game scope, while destruction
submission is 1.004 ms. That evidence does not support blaming the whole startup
spike on stress graph creation. More precise attribution remains required.

## Correctness and resources

- Three full numerical suites pass, including free-body modes, 3D analytic loads,
  independent force/couple checks and cooperative/block component transitions.
- 64 nodes / 62 bonds: repeated byte-exact reuse; one-ULP input change; tolerance/
  cold-start invalidation; rejected unconverged reuse; partial cut retaining the
  old root; new split-root invalidation; consecutive unrelated-cut preservation.
- 1,040 nodes / 1,039 bonds: cooperative component splits into two/four block-sized
  components with permuted IDs and preserved analytic forces.
- CUDA memcheck and initcheck: zero errors across the full analytic suite.
- All ten material, correction, ordinary actor, contact reporting and sleep/wake
  regressions pass. Old material executable ABI failure and its baseline control
  were retained in the preceding receipt; rebuilding the fixture fixed it.
- Historical 600-step penetration: exact unchanged hash, 444 chunks / 896 bonds /
  one projectile, 398 supported, 46 detached, 199 broken bonds and 43 clusters.
  Its historical scene uses Direct GPU mode. Ordinary-mode baseline/candidate topology hashes, fracture steps, correction steps
  and hole identities match exactly: 400 supported chunks, 44 detached, 199 broken
  bonds and 41 clusters. Both differ from the historical mode; the golden was not changed.
- Compiled begin/commit/certificate-refresh kernels use 20/32/14 registers,
  respectively, with zero stack, local or explicit shared memory reported by
  cuobjdump. These are compiler resource counts, not measured occupancy or bandwidth.

[evidence/](evidence/) holds logs, exact historical quality output, mapped module
hashes and compiler resources. Full captures are under
`out/native-settled-local-20260909` and `out/native-settled-downtown-20260909`.
The final candidate runtime SHA-256 is
`69f601ad367b7b6977e628907c8953ed4a2606d6862572b2e83b27a5ad63f15b`.

## Reproduction / next required gates

Run `../native-settled-20260909/run-screen.py --capture CAPTURE --reports REPORTS`
with the candidate in `CAPTURE/candidate/`. Add `--scene fractured-downtown.json
--commands downtown-commands.json` for the connected workload. The runner attests
loaded modules and refuses an occupied GPU; it never stops services.

Before promotion: preserve current-mode controlled identities, qualify five
60-second runs and endurance, and demonstrate useful peak improvement. The leading
remaining architectural work is C1–C6. CPU-created BodySim records, ActorSim references,
island edges and contact-manager bookkeeping still precede corrected physics.
Simply retaining a manager or delaying these CPU records leaves stale owners.
