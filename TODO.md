# GPU destruction continuation checklist — 2026-09-10

Status anchor: VM port `795f9c0c`; read [AGENTS.md](AGENTS.md) first. This is a
resume checklist, not a claim that the long-term implementation plan is complete.
✅ done · 🟡 partial/unqualified · ⬜ remaining · ❌ failed/reverted.

## Immediate prerequisites and evidence

- [ ] **Stopped by user; handoff prepared.** Start with
  [current WIP and next steps](docs/destruction/HANDOFF-20260910-integrated-ab.md).
  Integrated polynomial barrier candidate B remains unaccepted in source/bin.
  A screen and matched A/B wall/numerical checks completed; B timing screen
  interrupted by foreign GPU compute. No A-after bracket or new counters run.
  All owned jobs terminal; do not resume until instructed. Preserve both arms
  and failed capture, and do not mistake the stale install/attestation for B.


- [ ] **User-directed priority: existing-engine A/B iteration.** Preserve the
  current integrated engine and artifacts as A; select a bounded change in the
  measured expensive stress/integration path as B. Run matched physical gates
  and complete-step idle/bombardment timing with maxima and 120/60 Hz misses.
  Large replacements are permitted, but do not keep extending the disconnected
  six-channel solver as the main workstream. Earlier prototype tasks below are
  retained context, not authorization to put them ahead of this direction.


- [x] 🟡 [Stable uniform-gravity cancellation](qualification/elastic-gravity-cancellation-20260910/README.md):
  complete-free load preparation no longer manufactures incompatible loads by
  subtracting rounded weight/inertia. Corrected/later compatibility failures
  fall 197/51 → 0/0. Small loads/spin and physical balance scales remain; no
  tolerance change. Nine CTests/four sanitizers and independent load checks pass.
  Initial full query unchanged; impact iteration/setup failures remain open.
  `--fine-check` distinguishes input failures without repeating capped solves.
  One load-kernel sample 899.488 → 930.016 µs; correctness progress, no speedup.

- [x] 🟡 [Native load join and accurate fine checks](qualification/elastic-load-join-20260910/README.md):
  GPU receipts/ownership/origin mapping through RHS and solve; initial city
  query passes independent loads, fine equations, response and energy. Nine
  CTests and staged sanitizers pass. Recurrence refresh and compensated
  residual/recovery/setup fix actual native numerical failures. General setup
  falsely rejected 105 free fragments; 142 still fail the unchanged limit.
  Isolated chunks use the verified zero operator and exact coordinate basis.
  Three paired later-state setup captures: 46.031–46.050 → 34.805–34.859 ms;
  statuses/mappings and numerical bases match, final tests/checks pass. This is
  an isolated profiler result, not complete-step timing.
  Material profile is uncalibrated, impact queries remain rejected, production
  stress stays legacy. No complete-step or physical-parity win is established.
- [ ] ⬜ Close G02/G05 material/precision envelope against captured impact,
  correction and free-component queries before promoting the numerical probe.
  Keep real incompatibility and pending status; do not loosen frozen tolerances
  or accept iteration limits. Add structural acceleration with setup/recovery
  included in its cost, then complete G06/G07 accepted native lifecycle joining.

- [x] 🟡 [Native deletion/support graph binding](qualification/elastic-native-graph-20260910/README.md):
  no bond-matrix copy; device topology keys reach numerical setup. Eight CTests,
  eight sanitizer runs and four captured-topology maps pass. Live numerical
  material/geometry producer and accepted runtime integration remain open.

- [x] 🟡 [GPU unknown-component mapping](qualification/elastic-components-20260910/README.md):
  shared supports, device counts and bounded setup/solve; seven CTests and final
  producer sanitizers pass. Parent-halving counter samples improve two mapping
  kernels; native integration and complete-step qualification remain pending.

- [x] ✅ Track both exact 120 Hz (>1000/120 ms) and 60 Hz (>1000/60 ms)
  complete-step exceedances, including counts, percentages and startup steps.
- [x] 🟡 [ABI V13 command-owner wake bridge](qualification/elastic-command-wake-20260910/README.md):
  eight native CTests and command-wake memcheck pass; new test covers eight
  solver/acceleration/correction combinations. Corrected test storage assumptions
  at unchanged tolerance; initial failures preserved. Wall invariants/identity
  match V12, historical golden still fails. Native GPU application remains open.

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
- [ ] 🟡 [Current ordinary/sleeping baseline and first-peak counters](qualification/baseline-rtx5060ti-20260910/README.md):
  three 600-step runs each for pristine idle and one 256-shot wave, plus separate
  phase/timeline captures. First-peak stress counters collected; later target
  blocked by Nsight Compute-instrumented step-82 ownership failure (status 1288).
  [Investigation](qualification/baseline-rtx5060ti-20260910/nsight-investigation/README.md)
  shows skipped graph branches executing under attachment even with collection
  disabled; normal capacity retry becomes a rejection. Smaller controls pass.
  Preserve failed attempts; diagnose profiler interaction or validate isolated
  production-input replay. Shared desktop GPU, unresolved parity, no qualified win.
- [x] 🟡 [Working hardware sampling on completed trajectories](qualification/pm-sampling-rtx5060ti-20260910/README.md):
  direct CUPTI PM sampling, two 180-step runs, including one same-run Systems
  trace of all 267 stress evaluations. Counter histories match; iteration counts
  vary. Later-peak memory/residency/instruction counters available; FP64 and
  source/PC attribution still missing. Preserve timestamp flags and desktop scope.
- [ ] ⬜ Preserve remaining old-host raw evidence before any old-instance deletion;
  this source transfer was not a full `/tmp`/`out`/workspace backup.

- [x] 🟡 [Ordinary command correction guard](qualification/ordinary-command-correction-20260910/README.md):
  demonstrated force/torque bypass fixed using sparse GPU epoch stamps; both
  preparation paths count affected sources once. Zero/unrelated commands pass,
  invalid history rejects, Direct GPU without host upload publishes empty history.
  Nine focused CTests, native memcheck (29 cases) and four producer sanitizers
  pass; wall invariants/topology identity match V14, historical golden still fails.
  Synthetic producer counters 79.62 µs / 113,664 uploads, no spills; no speedup
  claim. Full spatial command replay remains required to remove this guard.
- [x] 🟡 [Isolate Nsight conditional-graph thread mismatch](qualification/nsight-cross-thread-20260910/README.md):
  standalone two-kernel IF graph reproduces false-branch execution when graph
  instantiation and launch use different CPU threads. Two repetitions of all
  six plain controls pass; three attached variants fail consistently. Moving
  instantiation to the launch thread passes; upload/re-upload alone does not.
  Memcheck passes. Vendor-component cause still unconfirmed; report is unsent.
- [x] 🟡 Isolated inline-dispatch native diagnostic passes all 29 correction cases
  plain/attached/counter-profiled with matching result lines. Source-load inspector
  counters: 3.23 µs, 22 registers, no spills, tiny 3-chunk/1-bond scope. Production
  scheduling and SDK remain unchanged; reusable build helper is validated.
- [x] 🟡 [Completed city counter diagnostic](qualification/ncu-city-20260910/README.md):
  six matched 180-step / 256-building runs; recorded poses byte-identical and
  checked physical counter histories match, iterations differ. First trial/correction
  and later trial counters plus source samples now available: 110 registers,
  near the 33.33% occupancy ceiling, low eligible warps, FP64 dependencies and
  polynomial-boundary barrier exposure. Production scheduling/modules unchanged;
  this is not a speedup or full physical qualification.
- [ ] ⬜ Use these mapped launches to assess actual component/operator work and
  reduce structural solve work in the six-channel replacement. Complete native
  command/load/material integration before physical/performance promotion; do
  not infer gains from inline CPU timing or profiler estimated speedups.

## New six-channel model: executable foundation, integration pending

- [x] ✅ Private GPU fine operator, full coupled block factors, prescribed/inelastic
  RHS and wrench/energy recovery. Independent analytical and dense checks pass.
- [x] ✅ Scaled projected GPU block-PCG with per-component stopping, six free modes,
  compatibility/original-row checks and explicit failures/iteration limits.
  [Current evidence and source patch](qualification/six-channel-pcg-20260910/README.md):
  both focused CTests pass; memcheck/initcheck/synccheck/racecheck pass. Current
  production backend remains unchanged; this is not an integrated performance win.
- [x] ✅ Standalone solver counter capture completes with matching iteration counts:
  228 registers/thread, two resident blocks/SM, no spills. Small mixed algebra
  batch, not representative city workload. Preserve that scope when ranking work.
- [x] 🟡 [Separate persistent setup from iteration](qualification/six-channel-setup-20260910/README.md):
  retained GPU factors/modes with explicit revision checks, selective rebuild
  and stale-setup rejection. Recurrence registers fall from 228 to 128; no spills.
  Three focused CTests and eight sanitizer executions pass. Standalone scope;
  producer-owned component partition/revisions and bounded restart state remain.
- [x] 🟡 [PhysX-record physical load adapter](qualification/six-channel-loads-20260910/README.md):
  full mass/inertia, free relief or supplied acceleration, spin, canonical torque
  origins and interval/ownership gating. Device adapter→RHS→PCG checks pass;
  four total CTests and all adapter sanitizers pass. Live scene inputs remain
  unqualified; synthetic fixture counters are not whole-step performance.
- [x] 🟡 [Capture real post-contact/pre-stress inputs and replay the adapter](qualification/live-loads-20260910/README.md):
  four snapshots from a 256-building, 113,664-chunk, 229,376-bond, 256-shot,
  180-step native run. Independent equations and all replay sanitizers pass.
  Fixed valid native ownership generation zero and exact free-singleton loads.
  Later-capture adapter profiler time 5.89→1.96 ms with 116 registers/no spills;
  offline numerical case only, not an integrated speedup or complete ledger.
- [x] 🟡 [GPU active motion partition](qualification/elastic-partition-20260910/README.md):
  sparse/empty layouts, stable-slot checks, versioned reuse and device counts
  feed the load adapter without count readback. Isolated live boundary proves
  reuse and rebuild across trial/correction. Five CTests, four captured-load
  comparisons and eight sanitizer runs pass. `pack` counters: 88.22 µs,
  36 registers, no spills on 113,664 chunks; not total setup/step time.
- [ ] ⬜ Finish the frozen live engine producer after `routeContacts`
  and before stress dispatch in `PxgDestructionRuntime.cu`. Preserve the precise
  evaluation's ownership, pose, full mass and command/contact ledger; post-fetch
  accepted topology may already differ. Then qualify trial/correction histories
  and accepted material transactions before replacing the backend.
  See [adapter contract](docs/destruction/elastic-load-adapter-contract.md).
- [x] 🟡 [Retain original pre-solve rigid input through corrected refresh](qualification/elastic-input-history-20260910/README.md):
  installed private ABI V11, rotating reusable storage, seven native tests and
  memcheck pass. Actual tick-83 trial/correction input bytes match; frozen wall
  remains migration-identical but fails historical golden. Matched old/new
  initchecks both have the same 10,028 findings; causes remain unresolved.
- [x] 🟡 [GPU original-motion ancestry](qualification/elastic-input-owners-20260910/README.md):
  installed private ABI V12 freezes body/root/slot/generation per authored chunk.
  All 4,864 new fragment bodies in the tick-83 correction resolve to original
  parents; four producer sanitizers pass. Counters: 22.66 µs / 113,664 chunks,
  16 registers, no spills, output byte-identical; not a complete-step speedup.
- [ ] ⬜ Use original motion ancestry and command/contact intervals for complete
  GPU chunk loads. Ancestry does not define a physical force/torque distribution.
  Qualify prescribed motion, command modes and exactly-once correction before
  marking the native ledger complete or using it for new material verdicts.
- [x] 🟡 [Explicit GPU chunk-command evaluation](qualification/elastic-commands-20260910/README.md):
  world force/impulse point/couple records produce node stress and grouped body
  wrenches; split replay, zero-resultant stress, expiration and adapter handoff
  pass. Six numerical CTests and four final command sanitizers pass. Synthetic
  113,664-command counters: resolve 101.95 µs / aggregate 33.57 µs, no spills,
  byte-identical outputs. Wider independent torque oracle fixes reference
  cancellation without relaxing limits. Native submission/application is pending.

- [x] 🟡 [GPU command-to-native-motion transaction](qualification/elastic-command-motion-20260910/README.md):
  checked native velocity writes with sparse ID/lifetime validation and duplicate
  suppression; seven focused CTests and four sanitizers pass. Synthetic split
  and matching-mass device handoff pass. Counters at 113,664 groups: prepare
  105.47 µs / apply 19.90 µs, no spills, byte-identical outputs. Not runtime-wired.
- [ ] ⬜ Produce command-free native correction input and integrate validated
  application after CPU upload. Existing checkpoint is post-command; replaying
  deltas into it would double-count. Epoch validation alone does not prove rewind.

- [x] 🟡 [ABI V14 native pre-addition command history](qualification/elastic-command-inputs-20260910/README.md):
  exact pre-addition velocities and submitted deltas captured in sparse upload
  records, retained across corrected refresh. Nine focused CTests, native memcheck
  and four producer sanitizers pass. Native/large producer counters captured;
  wall invariants/identity match V13, historical golden remains unresolved.
  This covers ordinary additive uploads only, not a complete spatial ledger.

- [x] 🟡 [GPU corrected child baseline and device replay](qualification/elastic-command-baseline-20260910/README.md):
  sparse command index and original ancestry join, rigid transfer and independent
  momentum checks, verified baseline→command→native-write chain. Nine focused
  CTests and four sanitizers each for baseline/motion pass. Resolve counters:
  27.01 µs for 113,664 authored chunks / 512 children; no spills, identical outputs.
  Runtime remains V14; live submission/material/correction use remains pending.

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
  report every-step 8 ms / 120 Hz (8.333… ms) / 60 Hz (16.667… ms) misses
  separately from whole-game tick cost.
- [ ] ⬜ Rust/game consumers on new VM, after native parity. No deployment implied.

Read [findings](docs/destruction/PERFORMANCE_FINDINGS.md) before reopening inverse-
only shared caching, four-stage polynomial, six-mode additive coarse correction,
colored sweeps, dead-adjacency compaction, register/precision variants or parent
reprojection. Prior versions failed to establish qualified gains; a materially
new mechanism is needed. A neutral, verified ownership improvement may be kept
when it removes obsolete dependencies and enables a named next consumer. Label
it architectural progress, never speedup; physical regressions are not waived.

Latest timing baseline used source 1155b7ff with its then-unchanged simulation binaries.
The installed runtime has since been rebuilt for private ABI V12 input history/ancestry;
new solver/runtime/test sources now exist as uncommitted WIP, alongside the
capture/report tools and evidence/handoff documents. Capture/report
tests: 36 passed. All timing/timeline and standalone validation jobs completed; profiler failures and the
intentional one-kernel stop are recorded in the linked evidence. No live jobs.

At session end record code commit, precise test disposition, artifacts and any
live job PID/log. Keep this checklist short; detailed old experiments stay indexed
in the findings/inventory.
