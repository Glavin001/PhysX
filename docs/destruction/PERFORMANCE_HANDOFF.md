> Latest continuation: destruction-specific CPU physical properties now publish once after BOTH stress/fracture evaluations. GPU root epochs union changed owners in the existing ownership kernel; final selection/gather reuses existing buffers/scratch. Adds8bytes/chunk epoch metadata; bounded payload tail and count packed with mandatory status avoid a count-read/resubmit wait. Ordinary PhysX pose/sleep synchronization remains. See qualification/final-properties-20260909/README.md. Final43 affected tests,PGS/TGS boundary oracle,first+second fracture owner-union checks,memcheck,frozen600,ordinary128 and real64step disjoint finalPublication accounting pass. Broad baseline initialization/CUB sanitizer findings remain unresolved. Candidate out/final-properties-20260909/candidate; baseline out/accepted-properties-final-20260909/candidate. Same CPU benchmark,publicABI15/privateV4 unchanged (completion layout internal). ShortABBA96step city256/113664chunks/229376bonds/256shots+idle: candidate fracture134.398/134.690ms versus baseline133.345/133.305; observed~1% higher peak, not a win or dismissed as noise. Retained architectural change removes intermediate destruction property publication; loaded means/idle similar. No full/endurance/real-time qualification. No service changes or active job. Ranked1 still needs actual GPU simulation registration and shape ownership to remove CPU BodySim/island/rebind prerequisites;2–7 pending. Do not label normal PhysX CPU synchronization as eliminated.

> Latest continuation: accepted GPU physical-property publication removes the fitted CPU mass/COM/motion prerequisite before corrected physics. Native ordinary PGS/TGS kinematic solver setup now reads GPU body state in the existing initialization kernel; this fixes the initial strict wall mismatch caused by stale CPU inputs. See qualification/accepted-properties-20260909/README.md. Frozen600 and ordinary128 prefix pass,42 affected tests plus new PGS oracle pass, memcheck/phase accounting pass; broader baseline sanitizer findings remain unresolved. Matched candidate GPU/runtime/CPU benchmark is out/accepted-properties-final-20260909/candidate; baselineGPU/runtime is out/device-preparation-packed-20260909/candidate and baselineCPU is out/accepted-properties-20260909/baseline/embedded_city_bench. PrivateV4/publicABI15 unchanged. ShortABBA96step city256/113664chunks/229376bonds/256shots+idle does not establish a robust gain or reliable regression. No service changes. CPU registration/scheduler/shape rebinding remain prerequisites; per-transaction physical publication still occurs before post-correction stress, so final-only publication is not done. Ranked1 incomplete,2–7 pending. Continue actual GPU scheduling/ownership, preserving numerical order, then final CPU observation union. No active build/GPU job remains from this qualification.

> Latest 2026-09-09 continuation: device allocation now conditionally runs collision/corrected-motion preparation in the same graph before the host completion boundary. Canonical completion statuses use one pinned readback; an initial separate-transfer idle regression was addressed. See qualification/device-preparation-20260909/README.md. Final immutable modules: out/device-preparation-packed-20260909/candidate, private producer V4/public ABI15. 41 affected tests, exact frozen wall, ordinary prefix, production-order oracle, memory check and real phase accounting pass. Integrated initcheck/CUB synccheck/racecheck findings reproduce at baseline locations and remain unresolved; do not claim all sanitizer gates pass. Final paired screen: 256 buildings/113664 chunks/229376 bonds, 256 shots or zero-shot idle, 96steps, two runs/arm/regime; no full qualification or robust speedup claim. CPU simulation registration/rebinding still precede correction: ranked #1 incomplete, #2–7 pending. No deployment/service changes or active benchmark remain. Resume at GPU registration/ownership, not another standalone cache experiment.

> 2026-09-09 continuation: standalone L2 paged contact-to-chunk index was implemented, tested, paired-screened and REVERTED. See qualification/native-chunk-index-20260909/README.md and candidate.patch. Sparse/full-width/recycled-ID GPU oracle, memcheck/initcheck, ten material/ordinary tests and frozen wall all passed; 256-building /113664-chunk /229376-bond /768-shot /600-step ABBA peaks overlap and means do not consistently improve. Separate phase pair changes contact-load interval only0.278528→0.271360ms at matched tick48 counts. Do not advertise a robust peak gain or repeat the same standalone table experiment. Predecessor baseline for this test is settled-cache69f601ad, NOT livea85f. Production source restored to pre-experiment; new test target removed from generated topology CMake, tested binary archived under out/native-chunk-index-20260909/candidate. Exact current restored SDK-module hash is in that receipt (rebuild need not match old binary hash). Live modules/services unchanged. Ranked ledger now treats idle/settling/sleeping/reactivation benefits independently; idle promotion does not require a peak gain. C1–C6 review is recorded in docs/destruction/CONTACT_OWNERSHIP_REVIEW.md; no contact retention transaction has yet been implemented. Continue the full plan, especially that lifecycle work and active stress, not another status-only turn.

> 2026-09-09 continuation: GPU-owned exact settled certificates are implemented as **unpromoted WIP**, including preservation across unrelated topology changes. Read qualification/native-settled-local-20260909/README.md and docs/destruction/IMPLEMENTATION_LEDGER.md. Final runtime SHA 69f601ad367b7b6977e628907c8953ed4a2606d6862572b2e83b27a5ad63f15b is isolated under out/native-settled-local-20260909/candidate, NOT deployed. Three numerical suites, memcheck/initcheck, ten material/lifecycle tests, historical frozen penetration and exact ordinary-mode baseline/candidate identities pass. Initial material executable had a baseline/candidate ABI crash; rebuilding fixed it. Ordinary mode retains400/444 chunks and differs from the historical Direct-GPU golden398/444 in BOTH arms; do not weaken the golden. Two runs per arm/regime,600steps each: city256/113664chunks/229376bonds/768shots and downtown27groups/24105chunks/74543bonds/3shots. Idle improves in both; loaded peaks do NOT establish improvement (city candidate131.589–138.358ms; downtown128.048–128.398ms). Five60-second qualification/endurance, C1–C6GPU lifecycle and the broader63-item plan remain unfinished. No benchmark/build/service change remains active. Runtime source is the candidate; live modules remain unchanged. Do not confuse compiled candidate binaries with deployment.

> Latest continuation, 2026-09-09: exact peak-equation diagnostic capture is implemented, separately built and memchecked; see qualification/peak-problem-20260909/README.md. Archived snapshots cover both tick-48 stress solves in the 256-building /113664-chunk /229376-bond /768-shot /600-step workload. Independent FP64 polynomial counts closely match native here; IC0 adds deep triangular dependencies, parent-solution reprojection worsens both selected hard corrected components. Six-mode additive coarse correction and its topology-cached GPU revision passed numerical/memcheck/ordinary/frozen-wall tests but failed to improve loaded peaks convincingly and worsened idle. BOTH ARE REVERTED, NEVER DEPLOYED; patches/reports under qualification/rigid-additive{,-cached}-20260909. After reversion, numerical binaries were rebuilt and all three suites passed. No GPU benchmark/build job remains from this campaign; owned empty demo restored, exact existing live hashes below unchanged. The new isolated CMake target requires rerunning cmake configure before its first build. Diagnostic module copies were deduplicated to one immutable module under out/peak-problem-20260909/shared-module (resolve symlinks for future map attestation). General GPU fragment/contact lifecycle and selective correction remain the major unfinished work; do not repeat coarse/cache experiments based only on fewer iterations. No baseline parity, peak gain, 60 Hz or architecture-completion claim.

> Continuation: resident inverse shared-cache experiment is rejected and all source/test cache edits reverted. See qualification/shared-inverse-20260909/README.md and capacity-only control. Live server/modules remain the deployed sleep deletion below. Next work is a diagnostic-only snapshot of peak stress equations/loads (both tick48 evaluations, solve ordinals50/51 in the reference mapping), to screen stronger preconditioners with an independent offline oracle. No production CPU solver is planned. Restore/check the numerical test binaries after reverting the cache before relying on them; current tests still contain the rejected cache until rebuilt. No GPU job remains from the cache campaign.

> Latest verified state, 2026-09-09: engine c4e1fff7 sleep-placeholder deletion IS deployed and browser-tested; see qualification/native-sleep-notification-20260909/deployment.json and browser/. Server SHA 6318b6f16b9aec6a522d74ccfc310567417549c20deb639fd023eee00e600632; runtime a85f2170833f1cc39a56062be9f5f783a25d0a120d72537138059f1541ec5af5; GPU module 073c0448421013734b228db718ba56656e3e3d8cb5a80d186978027b073162d0. Game source unchanged at 97364dd. Exact-diagonal inverse candidate is REJECTED and production source restored; stronger 771-block inverse tests retained and numerical/memcheck passed. Both fused sleep and diagonal shader candidates remain only in archived artifacts. No build, benchmark or browser job remains active. Reread current owned-server PID and health.players before any stop. Current benchmark binary includes CPU deletion; archived older binary is out/native-sleep-notification-20260909/baseline/embedded_city_bench. Current profiled binary is out/native-sleep-notification-20260909/profiled-bench. Repeated bombardment loaded peaks overlap (baseline134.416–141.050 ms, candidate131.285–138.123 ms), startup ~160ms; full baseline parity/real time/architecture remain INCOMPLETE. Next work must address major GPU stress and fragment/contact lifecycle cost, not treat these small deletions as completion.

> 2026-09-09 update: placeholder sleep notification deletion is qualified and accepted for eliminating proven redundant work. See qualification/native-sleep-notification-20260909/README.md. Three idle/destruction runs per arm complete; loaded-peak ranges overlap. New compound/pre-upload, nine ordinary, memcheck, exact wall and full 256-building mapping audit pass. CPU source/static library changed; candidate-bench and baseline binary are archived under out/native-sleep-notification-20260909. Owned server still uses old CPU binary, live GPU modules unchanged. No active GPU job remains from this campaign. Next candidate explores exact diagonal fine-block inverse specialization; no production speed claim until measured.

> Current continuation, 2026-09-09: shared normalization (23894297) IS deployed and browser-tested (qualification/shared-normalization-20260908/deployment.json and browser/). Live runtime a85f2170833f1cc39a56062be9f5f783a25d0a120d72537138059f1541ec5af5; GPU 073c0448421013734b228db718ba56656e3e3d8cb5a80d186978027b073162d0. Current phase replay completed at 49ffe707. Fused GPU sleep commit was screened, did not improve whole-step performance, and is reverted; qualification/native-sleep-commit-20260908 records why. Its 6,345 mostly empty sleepCommit calls at tick 48 exposed new-placeholder notifications, not one 4.9 ms GPU operation. WIP deletes those initial notifications at ScScene::onBodySleep (creation-time notInScene plus FIRST_BODY_COPY_GPU) and allocator cleanup. CPU libraries and consumers must be rebuilt for this change. Check /tmp/qualify-native-sleep-notification.log and live process before running more GPU work. No parity/real-time claim.

> Current continuation: engine 23894297 accepts shared component normalization (not yet deployed); multilevel and three-block/register-budget candidates are rejected and source reverted. See qualification/shared-normalization-20260908 and qualification/component-residency3-20260908. Live runtime remains committed deltas below. Next work is a current ABI-v15 diagnostic phase replay of mass fracture using accepted normalization, to prioritize the remaining peak. Check live jobs before re-running.

> Latest override, 2026-09-08: engine cf053e45 / game 97364dd are deployed and browser-tested, including GPU committed topology deltas (API v15), accurate warm residual initialization and per-node polynomial scaling. Read qualification/vibe-committed-changes-20260908/README.md and deployment.json. Runtime 7c7fead20c47a2c92dec0d09d628df7ed4a09c7d2a8e7a5d6f89c7dfd9d82de3, GPU module 073c0448421013734b228db718ba56656e3e3d8cb5a80d186978027b073162d0. The old API-v14 runtime must NOT be paired with the current GPU module or new consumer executable. A complete old comparison module pair is in out/vibe-committed-changes-20260908/baseline/lib, and the old consumer is baseline/embedded_city_bench. Both CMake caches currently target the isolated SDK under out/vibe-committed-changes-20260908/sdk/physx; qualified libraries were also deployed to physx/bin. Historical /tmp qualifiers using archived v14 runtimes plus live libraries are no longer safe. No GPU qualification job is still running from this turn. Reread the owned server PID and health before any stop.
>
> The large-scene objective is NOT complete: two 256-building / 113,664-chunk / 229,376-bond / 768-shot / 600-step runs per arm improve complete means 54.493/54.837 → 47.698/44.285 ms, primarily accepted CPU observation 10.199/11.376 → 3.036/2.874 ms. Loaded peaks still overlap (~137 ms); startup remains ~160 ms. The next work must target the retained-building stress/correction peak and CPU fragment compatibility creation, not claim this average gain meets real time or historical external-backend parity. The prior external downtown reference still fails the pristine-idle physical comparator. A new every-tick full GPU/CPU audit, publication memcheck, eight ordinary lifecycle tests, frozen wall and deployed browser checks pass. Seven browser resource errors are preserved; software rendering FPS is not simulation timing.

> Latest resumption note, 2026-09-08 21:00 UTC: engine c8405252 is deployed with the narrow-inverse runtime. Read the newest PERFORMANCE_FINDINGS entry and qualification/vibe-coarse-assembly-20260908/implementation.md before using older status below. Downtown loaded peak is 130.319 ms for 24,105 chunks / 74,543 bonds / three shots / 600 steps, down from matched 719.880 ms. Full baseline parity and real-time bombardment are NOT achieved. The 256-building small-component path remains the measured primary scale bottleneck. Latest browser audit passed. /tmp/vibe-embedded-city/server.pid must be reread and players checked before any stop. Grid-constant and smaller row-group experiments are reverted. No GPU job remains running from these captures.

# Dated performance handoff and implementation map

## Latest override — 2026-09-08 downtown idle fix deployed

The owned Vibe-land downtown demo now loads runtime SHA-256
`007cf78206ac00abdacf5498d7244cd5fd1c3678597be9e67c57f2d8ca5e0372`.
See [paired generated report](../../qualification/vibe-downtown-idle-fix-20260908/report.md).
Coarse hierarchy rows now use full CUDA blocks; all contributions and existing
convergence remain. The older convergence-exit and rigid-inverse changes are
included and qualified by the recorded native/penetration/browser checks.
Pristine idle improves substantially; startup and post-impact peaks still fail
real-time. Do not claim the large-scale objective complete or conflate this
with exact settled-stress reuse (still absent). Deployment was explicitly
authorized for this owned demo; older broad exclusions below are historical.


## 2026-09-08: idle and destruction are mandatory paired measurements

User explicitly requires both fresh intact idle and peak during destruction going
forward. Persisted in AGENTS, the performance skill and measurement contract.
Comparator now supports truly fracture-free runs, reports intact-idle distributions
and impact/aftermath peaks alongside new-fracture and all-step peaks, and marks a
single-regime comparison incomplete until its matching companion is attached.
A zero-awake damaged scene is not labelled intact idle. First-step spikes remain
in the all-step gate. Scene/manifest mismatches now reject comparison when metadata
is supplied. Seven reporter tests pass; no GPU measurement or deployment occurred.
This changes reporting, not either staged solver candidate's qualification status.

## 2026-09-08: user reports identify quiet-city cost; cooperative retirement WIP

User asked to continue optimizing while they test the demo, then submitted two
reports and asked why joining/idle is slow. Do not restart the live demo or run a
competing large GPU benchmark while they play. Read-only diagnostics and CPU builds
continue; only a tiny two-CTA correctness test + memcheck ran (both pass).

Game analysis: `vibe-land-2/docs/reports/embedded-user-idle-2026-09-08/report.md`.
Two reports at 16:38 UTC: 24,105 chunks / 74,543 bonds, 8/12 ordinary dynamic bodies,
5/22 fragments (1/5 awake), 91/342 broken bonds. Client rendering ~2 ms; server
rolling mean 50.021/87.671 ms and peak 734.120/978.840 ms. First ring contains
204/300 ticks with zero awake fragments, median total 38.944 ms. These are post-shot
reports, not pristine idle data. Smoothed GPU-wait values cannot be subtracted from
current-step fetch durations. No claim that all cost is stress or pure GPU work.

Confirmed source issues: native settled-island skip flags are rejected, so warm
starts are still solved each tick; downtown has stress components >1,024 nodes
using the costly cooperative multilevel path; its final converged iteration still
traverses the inactive preconditioner. New `StressCooperativeRetirement.cuh` exits
at the existing convergence boundary, preserving finalization writes. Focused
GPU/memcheck pass; full physical parity and timing remain pending. See
`qualification/vibe-cooperative-retirement-20260908/README.md`.

Game `embedded_city_bench` now accepts optional SCENE_FILE only when waves=0;
default 256-building tape remains unchanged. Reports count actual authored graph
components and include manifest hash. Untraced binary is built; profiled binary is
`out/vibe-native/diagnostics/embedded_scene_bench-downtown-profile`. Do not reuse the
old fixed-four-building profile binary for the new optional scene argument.
Example next isolated capture: `embedded_city_bench FRESH 1 600 0 fractured-downtown.json`.
It uses the documented benchmark physical settings, not a user-input replay.

Next after retirement qualification: exact unchanged-input/converged-result reuse,
with operator/load/support/topology and damage accounting proofs. Preserve the
user's live runtime; no new engine candidate was deployed this turn.

## 2026-09-08: structured inverse screened; downtown consumer deployed on baseline

The new `StressNativeRigidInverse.cuh` candidate stores ten coefficients for the
physical block D=[A,-K;K,cI], applying its Schur block inverse instead of a full
21-coefficient symmetric matrix. Same physical operator/precision/tolerances;
general coarse solvers are unchanged. General dense-cache tests remain test-only.
A new 257-physical-block oracle validates actual cache construction/application
and cold/reuse/unknown/generation semantics. GPU memcheck reports zero errors;
three resident suites, eight ordinary tests and the exact 10-second frozen wall
signature all pass (398 supported / 46 detached chunks / 199 broken bonds).

[Screening evidence](../../qualification/vibe-rigid-inverse-20260908/comparison/report.md):
256 buildings / 113,664 chunks / 229,376 bonds / 768 physical rounds, two untraced
600-step / 10-second runs per arm in baseline/candidate/candidate/baseline order.
Baseline fracture peaks 145.893 / 140.909 ms; candidate 138.129 / 139.459 ms.
Complete peaks overlap (baseline 151.165 / 149.301; candidate 150.722 / 150.594 ms).
This is a promising short screen, not endurance or real-time qualification.
Further phase attribution / qualification and the deployment decision are pending.
Archives/runner: `out/vibe-rigid-inverse-20260908`, `/tmp/run-vibe-rigid-inverse.py`.
The live library remains the qualified 45ae3488 behavior, SHA-256
`1437bd31b875b71222331224aa6c3670a8d53bc812095727b7d67d60ec733f9e`.
Candidate and baseline libraries are separately archived; do not accidentally
replace the live library while the user is playing.

The user steered this turn to a larger, more interesting playable city. Game
commit `ad57f01` changes the launcher default to `fractured-downtown.json`, grid 1:
27 connected building groups / 24,105 chunks / 74,543 bonds, mixed heights/hulls.
Both grid 1 and grid 2 (108 groups / 96,420 chunks / 298,172 bonds) passed browser
join, physical shooting, native correction, movement, ownership, 30 settling
samples and reset. Grid 2 has excessive even-quiet server cost (~50–60 ms in the
browser session); grid 1 is the playable default. Impact pauses remain in both.
No real-time claim. All eleven detached bodies slept in the final grid-1 sample.
Evidence: `vibe-land-2/docs/reports/embedded-downtown-2026-09-08/`.
The browser uses local WT host/port routing, not independent external testing;
the user separately confirmed the public demo works. Do not restart an occupied
owned server or disturb another developer's process. Next work returns to the
larger-scale peak objective while preserving the user's playable deployment.

## 2026-09-08: diagnostic census fixed; production remains 45ae3488 behavior

Latest work is diagnostic-only: component work maps both evaluations per tick,
counts polynomial visits / fine inverse applications, and records anchor cohorts.
The old reporter's one-solve/tick assumption is not applicable to the native game.
New reporter: `tools/scripts/report-vibe-component-work.py`; seven new tests plus
six existing component-accounting tests pass. Actual macro publication is tested
on the host; missing/invalid subphase GPU counters reject the small smoke capture
before the full job. Global subphase atomics now publish once per CTA, not inside
every iteration. Production preprocessing equivalence is archived.

[Accepted report](../../qualification/vibe-component-work-accepted-20260908/report.md):
256 buildings / 113,664 chunks / 229,376 bonds / 768 rounds, 600 steps / 10 seconds,
920 stress evaluations. First split's 69.4M inverse applications are overwhelmingly
anchored-building work (99.990% of combined outer/polynomial adjacency visits).
Preconditioner = 66.14% instrumented CTA cycles; polynomial = 82.61% of that
subphase census. These are not wall-time savings or hardware-counter conclusions.
Full raw/packed census paths and hashes are retained in the report folder.

Earlier diagnostic paths `out/vibe-component-work-{,local-,final-}20260908`
are superseded or contain the rejected zero-counter publication bug. Use
`out/vibe-component-work-accepted-20260908`, its archived runner and the final
runtime hash. The owned server was restored; production runtime remains the
previously qualified anchored-residual build, not the intrusive diagnostic.

A separate isolated sparse-inverse reproduction again fails memcheck (30 errors).
Adding address prints masks the failure; no cause or safe optimization is proven.
Source copies/binaries are under `out/sparse-inverse-repro-20260908`, evidence under
`qualification/sparse-inverse-repro-20260908`. Do not enable it in production.
Next meaningful solver work should reduce retained-component preconditioner cost
or its required iteration count with full residual/physical checks; do not repeat
the already rejected queue-order or partial cache changes without new evidence.


## 2026-09-08: anchored residual cleanup retained after numerical and timing checks

Engine `45ae3488` is deployed and passed browser join/shoot/move/settle/reset:
444 chunks / 896 bonds, four 150 ms trigger holds, 265 broken bonds / 57 fragment
bodies after shooting, 30 settling samples, then reset to zero broken/detached.
Six known resource errors remain; local WT routing is used by browser tests.
Evidence is in `qualification/vibe-anchored-residual-20260908/browser/`.

The size-priority queue remains reverted. The only subsequent production change
is a six-line guard in `detail/StressNativePreconditioner.cuh`, deleting identity
FP32/FP64 residual rewrites and a barrier for a fully anchored component. The
current validated motion-mode certificate makes this decision, not sleeping,
convergence guesses or a user-selected alternate backend. Free components retain
full projection. All focused numerical/ordinary and frozen-wall checks pass.

[Evidence](../../qualification/vibe-anchored-residual-20260908/comparison/report.md).
Matched game-consumer 256 buildings / 113,664 chunks / 229,376 bonds / 768 rounds,
two 600-step/10-second untraced runs per arm: baseline fracture-peak range
146.158–158.171 ms versus candidate 146.181–151.395 ms. These overlap, and means
overlap too; do not call this a robust complete-peak improvement. Separate CUDA
event captures at first split show stress 35.978 -> 33.728 ms over two evaluations,
with matching reported work counts. Retained as deletion of redundant work, not
an 8 ms/60 Hz or historical external-backend superiority qualification.

Runtime archives and runners: `out/vibe-anchored-residual-20260908`,
`out/vibe-anchored-residual-phases-20260908`,
`/tmp/run-vibe-anchored-residual.py`, `/tmp/run-vibe-anchored-residual-phases.py`.
Production candidate runtime hash is recorded in the receipt. The CPU-compatible
body creation phase still creates `NpRigidDynamic` / `BodySim` and island nodes
before correction; GPU slot assignment alone has not removed that dependence.
Do not optimize these CPU mirrors as though that completes GPU-owned lifecycle.
The current component-work diagnostic reporter still assumes one solve/tick;
fix its mapping before using it with the present two-evaluation game consumer.


## 2026-09-08: size-priority stress dispatch rejected; deployed runtime unchanged

A GPU-only descending-size permutation was added to the existing dynamic CTA
queue and tested, then reverted. It changed dispatch order only, preserving
component/node identities and internal numerical order. Three resident suites,
eight ordinary integration tests and the frozen penetration signature passed.

Matched game consumer: 256 buildings / 113,664 chunks / 229,376 bonds / 768
physical projectiles, 600 steps / 10 simulated seconds, two untraced runs per
arm in baseline/candidate/candidate/baseline order. Direct GPU API off, sleeping
on, correction <=1, stress evaluations <=2. Worst complete peaks 150.872 ->
152.147 ms; worst fracture peaks 140.191 -> 143.766 ms. Lower averages are not a
peak win. First fracture peak remains tick 48. Do not reactivate this experiment
merely because its mean improved. Report includes baseline-to-baseline physical
count divergence and all accepted samples; no endurance or 60 Hz claim.

[Generated report](../../qualification/vibe-stress-order-20260908/comparison/report.md),
[patch](../../qualification/vibe-stress-order-20260908/rejected-scheduling.patch).
The benchmark comparison now supports repeated baseline runs and experiment
notes, and removes hardcoded claims of passing tests or startup being the peak.
Three reporter validation tests cover malformed/instrumented data, altered
commands, retained first-step peaks and absence of invented qualification.
Production code remains the targeted-report-repair runtime (69fe462a behavior).
Remaining priority is reducing required stress work at the retained-building
peaks and replacing CPU compatibility fragment creation with its final GPU
owner, not another queue-order-only change. Existing phase evidence still
applies; this experiment provides no hardware-counter bottleneck conclusion.


## 2026-09-08: targeted report repair wins the native game-consumer screen

Engine `69fe462a`, game `45b41d2`. The previous full-world refilter opportunity
is now addressed; do not repeat that optimization. See
[local contact-report repair](LOCAL_CONTACT_REPORT_REPAIR.md), the generated
[comparison](../../qualification/vibe-consumer-local-report-repair-20260908/report.md)
and [new fracture-peak phases](../../qualification/vibe-consumer-local-report-fracture-20260908/report.md).

Workload: 256 buildings / 113,664 chunks / 229,376 bonds / 768 physical rounds,
600 steps (10 simulated seconds), Direct GPU API off, sleep on, correction <=1,
max two stress evaluations. One baseline and two candidate untraced runs with
identical recorded command tapes. Complete peaks: 186.782 -> 151.490/151.405 ms
(startup now largest). Fracture peaks: 186.782 -> 135.903/147.162 ms. Means:
94.641 -> 55.996/57.516 ms. Worse-candidate peak reductions: 18.9% overall,
21.2% fracture. This is a short screen, not an 8 ms/60 Hz/endurance or historical
external-backend superiority qualification. Final broken bonds differ (78,046
baseline; 76,217/76,743 candidate); raw work counts and divergence are published.

Ordinary reports now select only their active dynamic shapes for CPU report
relationship repair, keeping unrelated GPU managers/islands. Static boundaries
and sleepers are excluded. Trigger/modifier/CPU-contact fallback remains complete.
Eight ordinary tests, an additional reported-reuse sleep-boundary comparison,
and exact frozen penetration pass. The optimized server was rebuilt without the
profiling feature and passed browser join/shoot/move/settle/reset on 444 chunks /
896 bonds with six rounds (310 broken bonds, 74 fragments). Public demo remains
one building; six known browser COEP/404 resource errors remain.

Remaining measured opportunity: the initial large split at tick 48, not the old
late refilter peak. New diagnostic fracture peak: 10,449 fragments / 10,193 awake,
256 projectiles present, 216,220 reported normal contacts, 57,788 cumulative breaks;
CUDA stress 33.479 ms, compatibility body creation 20.397 ms, correction 51.371 ms.
GPU completion/stress dominates the ten worst fracture steps. Subsequent corrected
step 78: correction 20.411 ms, refilter 0.016651 ms, GPU completion wait 52.013 ms.
These are different physical states; use untraced comparison for speed claims.

Game `embedded-profiling` is optional and excluded from the production dependency
graph. It reuses the SDK profiler through Rust and writes host/CUDA phase CSVs.
`report-vibe-consumer-phases.py --fracture-peak` uses existing disjoint accounting;
`compare-vibe-consumer-bench.py` checks input tapes/settings and archives full rows.
Never mix instrumented samples into the untraced report. Capture roots are
`out/vibe-game-local-report-repair-20260908` and
`out/vibe-game-local-report-phases-20260908`. The source reference repos remain
read-only. The full goal is still incomplete.


## 2026-09-08: actual Vibe-land consumer scale screen and contact-report crash

Engine `6ef3fd47`, game `5ec74bf` (vibe-land-2). See
[contact report correction](CONTACT_REPORT_CORRECTION.md). The game now has an
`embedded_city_bench` example and validated automatic report generator. Four
buildings per asset let 64 wire asset IDs represent 256 independent buildings.

Three baseline 256-building attempts crashed during the second wave in CPU
`onContact` / `PxContactPair::extractContacts`. Correction recycled trial report
storage without invalidating retained actor/shape report stamps. The fix preserves
ordinary callbacks and the single accepted scene timestamp. Eight ordinary native
tests, the unchanged frozen penetration signature, and browser play/reset pass.

Fixed isolated screens: one 600-step / 10-second run each, 4/64/256 buildings,
1,776/28,416/113,664 chunks, 3,584/57,344/229,376 bonds, 12/192/768 physical
18,000 kg spheres at 40 m/s in three waves. Direct GPU API off, sleep on,
correction <=1 and exactly one additional stress evaluation after correction.
Complete-step peaks: 40.234 / 70.608 / 186.782 ms. This is not a performance win
or a 60 Hz qualification. First-step setup remains measured; no peaks discarded.

At the 256-building peak (tick 139): 256 projectiles present, 16,587 fragment
bodies / 13,747 awake, 16,843 total destruction clusters, 400,481 reported native
normal-contact count, 72,407 cumulative broken bonds, one correction/two stress
passes. Native advance = 169.699817 ms; accepted game event/snapshot processing =
17.081810 ms. These disjoint intervals do not identify native CPU vs CUDA limits.
Next useful measurement is the existing internal phase profiler on this exact
consumer workload, not another unmatched standalone scene or optimization of the
legacy CPU bridge. Accepted GPU event/topology deltas remain a final-owner gap,
but removing all current observation cost would still miss 60 Hz substantially.

Game report: `vibe-land-2/docs/reports/embedded-scale-2026-09-08/report.md` with
compressed raw samples, command tapes, build receipts and debugger captures.
Native capture root: `out/vibe-game-screen-20260908-fixed2`. The live public game
was restored to the tested one-building scene. Larger browser/network/endurance
qualification and matched external-backend speed superiority remain unproven.


Snapshot: **2026-09-08**, base commit `ab30a85b410603c284255f562f92f7733ab5ad8e`
plus native contact-property WIP. This is a resumption aid, not live status.
Inspect Git changes, processes and artifact hashes first. The goal remains full
integrated GPU destruction with more verified work inside an 8 ms complete-step
peak; no completion or real-time qualification is claimed.

Latest change: native freeze/unfreeze query membership is deferred to one accepted publication; see `ACCEPTED_QUERY_OBSERVATION.md` and `qualification/native-query-publish/cpu-sync.md`. CPU activity rollback and body/shape readback remain. Earlier CPU synchronization/activity evidence is in `qualification/native-cpu-sync/`.

Newer work: [two-evaluation correction and ordinary-mode report deletion](POST_CORRECTION_FRACTURE.md), with current measured results at the top of [findings](PERFORMANCE_FINDINGS.md). The dated implementation notes below predate that change.

Navigation: [playbook](PERFORMANCE_PLAYBOOK.md),
[measurement contract](PERFORMANCE_MEASUREMENT.md),
[findings/rejections](PERFORMANCE_FINDINGS.md),
[full optimization inventory](OPTIMIZATION_INDEX.md).

## Current contact-property migration

The native contact-input builder now derives rest distance and torsional-friction
parameters on the GPU from a persistent per-geometry property palette. CPU
loading/property-edit commands update changed palette entries. Ordinary PhysX
retains its existing path. Native per-contact rest/torsion uploads are removed;
quiet steps skip palette scanning/upload. This is a prerequisite for GPU-owned
pair allocation, not completion of contact/fragment lifecycle.

| Location | Responsibility |
|---|---|
| `physx/source/gpunarrowphase/src/PxgShapeContactProperties.inl` | Persistent property storage, changed-entry commands, growth and upload scheduling |
| `physx/source/gpunarrowphase/include/PxgContactManager.h` | 16-byte property record; distinct from PxgShape/PxgShapeSim layout |
| `physx/source/gpunarrowphase/src/PxgNarrowphaseCore.cpp` | Registration, palette update/scheduling, native payload-upload bypass |
| `physx/source/gpudestruction/src/PxgDestructionRuntime.cu` | GPU contact descriptor/parameter construction and bounds validation |
| `physx/source/physx/src/NpShape.cpp` | Shape-property edit notification, including shared shapes |
| `demos/blast-stress-demo/tests/native_gpu_collision_test.cpp` | Ordinary/native parameter law, shared edits, quiet upload skip, reuse and disable transition |

Final palette-guard revision: six focused collision/lifecycle suites passed and
the frozen **444-chunk / 896-bond / one-projectile, 10-second** wall audit passed
with 398 retained, 46 detached and 199 broken bonds. Evidence:
[collision tests](../../qualification/native-contact-properties/final-collision-tests.log),
[wall audit log](../../qualification/native-contact-properties/final-wall.log),
[archived quality result](../../qualification/native-contact-properties/final-wall-quality.json).
Earlier revision parameter memcheck reported zero errors. Do not call the final
revision sanitizer-qualified merely from that earlier result.

The earlier property migration's **256-building / 113,664-chunk / 229,376-bond /
256-projectile, two 3-second runs per arm** comparison had mean/worst
**16.751 / 58.579 ms** baseline versus **16.740 / 58.068 ms** candidate. Its other
impact peak worsened. This establishes no speedup; the final quiet guard was
added afterward. [Comparison](../../qualification/native-contact-properties-initial-comparison/comparison.md).
The later 15-second launch-capacity campaign uses the final matched build and
compares schedules, not old/new implementations.

## Known pre-existing sanitizer issue

`compute-sanitizer --tool initcheck` reports uninitialized global reads in the
rigid-to-shape radix sort, including `radixSortWarp` and
`radixSortCalculateRanks`, called from
`PxgGpuNarrowphaseCore::computeRigidsToShapes()`.

The saved original baseline produces the same category of errors. The baseline
used the broader `--reference` fixture; the candidate used `--contact-properties`.
Different total error counts are **not** a regression-rate comparison. Neither
log establishes a clean path. Suspected tail/vectorized-read initialization is
not a proven diagnosis; inspect producers, active count and sort padding before
adding clears or changing sorting.

Evidence: [candidate initcheck](../../qualification/native-contact-properties/initcheck.log),
[baseline initcheck](../../qualification/native-contact-properties/baseline-initcheck.log),
[earlier memcheck](../../qualification/native-contact-properties/memcheck.log).
Keep this fix separate from the property migration and performance attribution.

## Code map: measured work to final owner

Paths are relative to repository root. Use source symbols, not stale line numbers.

| Area | Source / symbol | Current gap or rule |
|---|---|---|
| Scene lifecycle | `physx/source/simulationcontroller/src/ScPipeline.cpp`, `canCorrect`, finalization and correction tasks | Trial, stress, restore/correction and acceptance; correction still has sleep/joint/CCD restrictions |
| Fragment reservation | `physx/source/physx/src/NpDestructionBodyAllocator.h`, `prepare`, `applyBindings` | GPU chooses slots but CPU creates compatibility actors/BodySim and applies shape/query lifecycle |
| Shape migration | `physx/source/simulationcontroller/src/ScShapeSimBase.cpp`, `rebindRigidOwner`; `physx/source/physx/src/NpShapeManager.cpp`, `rebindShapeInternal` | GPU physical ownership does not delete CPU actor links/filter/query dependencies |
| New contacts | `physx/source/gpunarrowphase/src/PxgNarrowphaseCore.cpp`, `registerContactManagerInternal`; `ScPipeline.cpp`, `postBroadPhaseStage2` | Native GPU descriptors exist; CPU contact-manager/interaction/edge allocation still remains |
| GPU body scheduling | `physx/source/gpusimulationcontroller/src/PxgSimulationController.cpp`; `physx/source/gpudynamics/src/PxgContext.cpp` | Active CPU body lists and internal pointers have consumers; cannot delete BodySim independently |
| Native CUDA integration | `physx/source/gpudestruction/src/PxgDestructionRuntime.cu` and private `.cuh` files | Contact loads, stress/material/topology, checkpoints, correction preparation and commit |
| Topology transaction | `physx/source/gpudestruction/src/PxgDestructionTransaction.cuh`, `buildPrepare`, `buildCommit` | GPU accepted/trial topology; some capacity-sized copies remain; copy cost not separately established |
| Stress iteration | `blast/source/sdk/extensions/stressgpu/detail/StressComponentIteration.cuh` | CTA-resident full component loop and work queue; vectors still use global arrays |
| Preconditioner | `.../detail/StressNativePreconditioner.cuh`, `StressNativePolynomial.cuh` | Current two-stage polynomial; qualify cost of the whole recurrence, not one cache fragment |
| Stress hierarchy/modes | `.../NvBlastExtStressGpuTopology.cuh`, `.../detail/StressMotionModes.cuh` | Changed setup still broad; protect support/free-body null spaces and stable topology |
| Activity/reuse entry | `.../detail/StressResidentAPI.inl`, `solveDeviceAsync` | General settled/unconverged skip flags rejected; device validity mechanism still needed |
| Benchmarks/consumer | `demos/blast-stress-demo/native_destruction_main.cpp`, `native_gpu_consumer.cpp` | Complete timer, committed observations, safe aerial launch and optional GPU rendering |

## What the next implementation should resolve

1. Preserve the matched build and qualify/archive the property migration
   independently. Investigate the pre-existing sort initialization issue without
   attributing it to the new palette or hiding it.
2. For **simultaneous mass fracture**, finish GPU motion/shape/contact lifecycle
   with generation-bearing handles, capacity growth/failure, ordinary-body
   interaction, filtering, query observation and removal/reuse. Avoid a faster
   version of the CPU bridge as the architectural destination.
3. For **sustained destruction**, refresh current component work/phase attribution
   before another recurrence variant. The new staggered evidence puts stress
   above the whole 60 Hz budget. Fix the old diagnostic reader's schema mismatch
   before launching it; count polynomial traversal too. Evaluate full local
   recurrence/preconditioner cost and valid across-step reuse separately.
4. Preserve full correction when selective reuse cannot prove validity. Measure
   actual affected closure and new contact candidates before promising savings.
5. Re-rank using both workload axes, then short physical/performance checks,
   five 60-second gates and full lifecycle endurance. No existing short run
   establishes the maximum sustainable destruction rate.

## Existing architecture documentation

Read only the relevant module; older documents can describe intermediate states:

- [Native MVP/support boundary](NATIVE_MVP.md), [GPU ownership](GPU_OWNERSHIP.md),
  [reservation flow](WIP_GPU_RESERVATION_FLOW.md).
- [GPU connectivity ownership](GPU_CONNECTIVITY_OWNERSHIP.md),
  [stable motion slots](GPU_STABLE_MOTION_SLOTS.md),
  [persistent collision ownership](PERSISTENT_GPU_COLLISION_OWNERSHIP.md).
- [Contact inputs](GPU_CONTACT_INPUTS.md), [contact reuse](GPU_CONTACT_REUSE.md),
  [pre-solve contacts](GPU_PRE_SOLVE_CONTACT_INPUTS.md),
  [pre-solve support](GPU_PRE_SOLVE_STATIC_SUPPORT.md).
- [Rigid checkpoint](NATIVE_GPU_RIGID_CHECKPOINT.md),
  [correction bodies](NATIVE_GPU_CORRECTION_BODIES.md),
  [single-resimulation reference](SINGLE_RESIM_REFERENCE.md).
- [Native stress](NATIVE_GPU_STRESS.md),
  [stress topology](NATIVE_GPU_STRESS_TOPOLOGY.md),
  [GPU render consumer](GPU_RENDER_CONSUMER.md),
  [bombardment recording](NATIVE_BOMBARDMENT_RECORDING.md).

Both original source repositories remain read-only. Their historical policy,
CPU/WASM compatibility and game orchestration are not the final native CUDA
architecture. Deployment and service changes remain outside this work.
