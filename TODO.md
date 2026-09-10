# GPU destruction continuation checklist — 2026-09-10

Status anchor: VM port `795f9c0c`; read [AGENTS.md](AGENTS.md) first. This is a
resume checklist, not a claim that the long-term implementation plan is complete.
✅ done · 🟡 partial/unqualified · ⬜ remaining · ❌ failed/reverted.

## Immediate prerequisites and evidence

- [x] ✅ Repair/reboot VM; CUDA 13.4, driver, PTX execution and profiling tools work.
- [x] ✅ Copy/verify source and Git history; independent SDK build/install for sm_120.
- [x] ✅ Commit port and [test evidence](qualification/rtx5060ti-cuda134-20260910/README.md).
- [x] ✅ Capture real motion-slot kernel counters; no stress-bottleneck conclusion yet.
- [ ] 🟡 Resolve/attribute 4 native failures: two large exact-pose audits and two
  accepted-properties initchecks. Current broad result is 57/61, not all passing.
- [ ] 🟡 Resolve frozen penetration differences. Ordinary mode passes geometric
  invariants but differs in topology/counts; Direct GPU control fails a wall-hole
  invariant. First establish old/new controls with matching API mode/settings.
- [x] ❌ Aligned-transform observation experiment rejected: identical error remained;
  reverted source and temporary logging. Do not repeat unchanged.
- [x] 🟡 Isolate CUB initcheck findings outside PhysX. Correct sums plus clean
  poisoned-output control do not settle the instrumentation cause; gates remain.
- [ ] ⬜ Profile real 256-building destruction peaks and paired pristine idle.
  Counters may proceed diagnostically before parity resolution; no qualified win.
- [ ] ⬜ Preserve remaining old-host raw evidence before any old-instance deletion;
  this source transfer was not a full `/tmp`/`out`/workspace backup.

## Ranked replacements: historical exposure order, remeasure on this VM

The ordering comes from [REPLACEMENT_PLAN.md](docs/destruction/REPLACEMENT_PLAN.md).
Its conditional savings and old 4090 timings are **not 5060 Ti forecasts**.

1. [ ] 🟡 **GPU fragment lifecycle / simulation registration.** GPU owner state,
   birth records, iteration limits and final property/shape publication exist;
   CPU registration, active scheduling and contact dependencies remain. Static
   registration has an isolated tested prototype and an **unapplied** integration
   patch in [its review](qualification/native-static-registration-20260909/REVIEW.md).
   Earlier automatic review rejected integration edits; preserve that context,
   assess current authorized scope and review the patch against current source.
   This documentation task does not apply/authorize that patch or waive validation.
2. [ ] ⬜ **Structural solving replacement.** Existing resident component kernels,
   warm starts and local inverse preservation are foundations. Factored local
   substructures/interface solving remains a proposed mechanism; screen exact
   equations with full setup/application/residual costs. Counter-profile current
   iterations before committing to a replacement. No production win established.
3. [ ] 🟡 **Persistent contact lifecycle.** Some pair/response preservation exists;
   remove remaining ownership-induced registration churn while preserving valid
   geometry, new fragment pairs and incompatible row/impulse invalidation.
4. [ ] 🟡 **Cluster-level accepted publication.** Committed deltas and accepted-only
   properties exist; audit remaining expansion of unchanged chunk rows when only
   a cluster frame changes. Preserve current-tick actor/query and consumer state.
5. [ ] ⬜ **Selective correction.** One corrected physics advance works, but exact
   contact/joint dependency work sets and validated collision reuse remain. A
   massive burst may affect most bodies; do not promise savings from world size.
6. [ ] 🟡 **Local structural activity/topology.** Unchanged-topology bypass and
   resident convergence retirement exist; general cross-tick converged-stress
   certificates, dirty inputs and affected-component rebuilds remain incomplete.
   Measure pristine idle, localized impacts and sustained debris separately.
7. [ ] ⬜ **Remaining necessary passes.** Contact/material fusion, tiny-cluster mass
   reductions, repeated asset/operator sharing, sparse events, initialization and
   storage layout. Keep exact material/damage evolution and explicit overflow.

## Qualification and prior lessons

- [ ] ⬜ Matched ordinary API/sleeping 444/896 wall, 113664/229376 city, and connected
  downtown 24105/74543 scenarios, each with fresh idle and impacts. Record actual
  projectile tape (256 versus historical 768), all steps, repeats and fidelity.
- [ ] ⬜ Five 60-second candidate runs plus 10-minute lifecycle/endurance gate;
  report every-step 8 ms / 16.67 ms misses separately from whole-game tick cost.
- [ ] ⬜ Rust/game consumers on new VM, after native parity. No deployment implied.

Read [findings](docs/destruction/PERFORMANCE_FINDINGS.md) before reopening inverse-
only shared caching, four-stage polynomial, six-mode additive coarse correction,
colored sweeps, dead-adjacency compaction, register/precision variants or parent
reprojection. Prior versions failed to establish qualified gains; a materially
new mechanism is needed. A neutral, verified ownership improvement may be kept
when it removes obsolete dependencies and enables a named next consumer. Label
it architectural progress, never speedup; physical regressions are not waived.

At session end record code commit, precise test disposition, artifacts and any
live job PID/log. Keep this checklist short; detailed old experiments stay indexed
in the findings/inventory. No GPU/build job was started for this docs handoff.
