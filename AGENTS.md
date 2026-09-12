# AGENTS.md — PhysX GPU destruction: fresh-session entrypoint

Current continuation (2026-09-12, supersedes older status/process notes):
CPU attribution and graph counters qualify52/52; significant ordinary counters
qualify40/52,3243 launches,178 checked counter ticks. Parent390717 uses pinned
2025.3.1 application replay with3600-second watchdog and the existing pause file.
It is temporarily SIGSTOP at a completed capture boundary while the final-memory
coordinator finishes N20; do not resume or kill it independently. The automatic
service-restoration watcher338813 remains active and sees this parent. Old
parents146583/347295 are terminal; never SIGCONT them.

N20 completes52/52 physical comparisons,3120 full ticks,20/20/20 per case. Large
late-debris mean382.883ms versus422.663/426.525 controls; restore excluded. Earlier
independent confirmation also improved this case. Initial-impact/panel/cascade
regressions do not consistently repeat in reversed order. Warm600 heavy remains
54.378–54.444ms versus54.466–54.517 controls,519/600 60Hz misses throughout.
Four additional warm180 trials per arm measure the large fracture burst161.241ms
versus166.641/163.340 controls. Both600-tick ordinary/sleeping walls pass exact
physical history and zero position error. No large overall warm/peak gain claimed.
Full52 normal asynchronous memory qualification is running under
`out/n20-requalification-20260912/run-final-memory.py`; no N20 retention until it
passes. That coordinator resumes counters and leaves other services protected.
[Every scenario and stage](qualification/optimization-next20-20260910/end-to-end-attribution-20260912/n20-final.md).

N15 anchored/free specialization is rejected after numerical/sanitizer/physical
passes: seven-case light has no clear gain, large debris483.504ms versus459.421/
457.057 controls. N06a is also rejected. Batch13/20; do not count prepared work.
N14 retained-policy closure is building; N19 GPU-to-CPU active-record publication
requalification and N16 local vector workspace are separately prepared. The
`build-queued-solvers.py` and `run-next-isolated-screens.py` coordinators under
`out/end-to-end-attribution-20260912/` finish all CPU builds before serial GPU
screens at the next clean counter boundary. Monitor their receipts; no parallel
GPU candidates. Current compatible runtime includes unaccepted N14. Main source/
index, frozen best N13 and installed original SDK are unchanged. Keep every
first-use tick equally weighted across A/B/A. Follow OPTIMIZATION.md.


Latest recovery continuation (2026-09-12): the user explicitly authorized reversible
service/GPU recovery, then rebooted the host (boot07:05:39 UTC). This supersedes the
older no-recovery-authorization notes below. Desktop initially restarted, then
was temporarily stopped for clean counters; GPU is healthy with no other clients.
The other project server restart configuration is saved privately, never commit
its environment. `out/end-to-end-attribution-20260912/recovery/restore-after-counters-and-screen.py`
restores both desktop and server after owned counter jobs and queued screening end.
`out/n20-requalification-20260912/run-in-counter-gap.py` now parks only the
counter campaign parent while its current child capture finishes, then runs the
serial native/light screen and always resumes that parent. Inspect its
`counter-gap.json`; do not mistake the deliberately parked parent for a hang.
The gap coordinator itself is now held for result review (PID347295), while its
N20 child continues. `out/n20-requalification-20260912/manual-gap-extension.json`
records this hold. After N20 review and the separate prepared N06 structural
screen, send SIGCONT to that owned coordinator; its finally block resumes the
counter parent PID146583. Never resume while a separate GPU screen is active.
Server restart pins the hash-verified original `out/install/lib` SDK: its old
binary must not pick up later experimental libraries in the mutable build path. **52/52 CPU-attribution cases now pass**, 104 checked ticks,
21,401 CPU samples, 91,538 engine scopes and18,376 launches, with zero observed
position/velocity differences. Reduced-tracing retry passes the formerly faulted
city64 impact; all remaining city256 stages pass. Old Xid120 capture stays
quarantined; the precise trigger is unproven. New archived2026.2.1 and2026.1.1
NCU pilots both abort with the same heap symptom as2026.3.0. Do not keep trying
versions; stable2025 graph-level full counters now pass52/52 (461 graph launches,
98 checked ticks) with optional host analysis rules disabled. Rules-enabled
control crashes the collector; graph aggregates are NOT individual conditional-
node/source counters. Significant ordinary-kernel configuration expansion is
in progress with99% relative coverage plus a0.1ms family threshold. City25 impact
passes93 configurations /215 full-counter records via40 application replay passes
(1125.44s including audit). Full expansion uses kernel replay, explicitly reusing
that pilot;38 cases (all28 structural, all8 city25, city64 idle/airborne) pass. Latest campaign: `configs-full/`.
Invalid L2 hit ratios remain excluded: headless and narrow-metric controls do not
fix them, and newer collector whole-graph mode also aborts. Do not call every
metric or conditional-node capture qualified. Warm180-tick
idle/heavy traces pass exact work/convergence counters; lower-rate sampling
eliminates the earlier OS throttle warnings. Forced synchronization does not
fix the newer NCU injection failure.
Current benchmark runtime/physics artifacts unchanged; no new speedup or completed
optimization experiment. N20 capacity follow-up is built in isolated
`out/n20-requalification-20260912/build/{A,B}`; rebuilt control demo/probe are
byte-identical to the current baseline. Candidate GPU correctness/timing remains
pending; best N13 and main source/index remain unchanged. N06 one-block
cooperative launch through4096 total nodes is also built in isolated
`out/n06-granularity-20260912/build/{A,B}`; same multilevel preconditioner, no
small-component eligibility change. No N06 GPU checks or timings yet.
[Current attribution evidence](qualification/optimization-next20-20260910/end-to-end-attribution-20260912/README.md).


Latest end-to-end attribution expansion (2026-09-12): **38/52 CPU cases qualify**,
76 checked ticks, 6,536 CPU samples, 11,307 engine scopes and 9,280 GPU launches.
All 28 structural / eight city25 / first two city64 cases pass unchanged physical
comparisons. City64 initial-impact is quarantined despite application success:
Xid120 GSP firmware store fault at 05:30:46 UTC in its CUPTI worker PID1671498,
during context teardown. The next case cannot initialize CUDA; **GPU requires
reset**. No owned GPU jobs remain. Other project's server/desktop clients still
hold device handles; no service interruption, reset or reboot is authorized.
Preserved recovery plan and [all-scenario coverage/report](qualification/optimization-next20-20260910/end-to-end-attribution-20260912/README.md).
Do not call the 52-case expansion complete. CPU campaign resume preserves good
cases and failed attempts. Pilot reduced Systems tracing after authorized GPU
recovery; optional allocation/all-API tracing is now separate, not a proven fix.
Pinned 2025.3.1 NCU still qualifies the old selected/stress captures but skips
conditional-graph kernel nodes. Archived 2026.2.1 is extracted locally; its pilot
has NOT run. Expanded all-invocation significant-kernel inventory/audit is
implemented but unqualified. New continuous CPU captures remain pending. Both
probe builds and five accounting tests pass. Runtime/physics and installed SDK
unchanged; no new optimization or speedup. Follow OPTIMIZATION.md.

Latest Nsight Compute recording fix (2026-09-12): **52/52 scenarios now pass full
NCU capture and unprofiled-reference physical comparison**, 62 reports /
86 selected kernel launches / 124 checked full ticks. Pin the already
installed **2025.3.1** collector. 2026.3.0 aborts inside its injection worker on
new-fracture/correction even with no kernel selected; precise corrupting write
remains unresolved. The old collector passes matching inputs, full counters and
unchanged fidelity gates. No simulation/runtime change, speedup or N-series
experiment is credited. Full expansion 1,280.28 s reuses seven light cases;
normal light timing remains separate. `profile-suite.py` defaults to full metrics;
`audit-counter-suite.py` verifies coverage, counter groups and physical evidence.
[All 52 scenario results, diagnosis and commands](qualification/optimization-next20-20260910/ncu-fix-20260912/README.md).
Main index/unrelated changes and installed SDK are preserved. All owned captures
are terminal. Older four-case NCU coverage below is historical and superseded.


Latest hardware-counter atlas (2026-09-11): light-first collection followed by
**52/52 full-process-drained Systems + non-replaying CUPTI PM captures** passes
104 restored physical ticks. Final refresh388.11 s;43,788 first-tick samples,
minimum96.90% interior coverage, no overflow or CUDA-event completeness warnings.
Generic NVTX warning is preserved; all four analyzed tick ranges are present and
closed. Detailed NCU supplements cover four scenarios/seven launches only;
first-fracture NCU aborts in three tested replay modes and remains unqualified.
No runtime change, speedup or N-series experiment is credited. Prior unprofiled
20-sample full-step baseline stays separate; all52 scenario metrics and next
ranked CPU/GPU/solver hypotheses: [counter atlas](qualification/optimization-next20-20260910/snapshot-counters-20260911/README.md).
Use `profile-suite.py` and the exact commands in OPTIMIZATION.md. Installed SDK
and retained N13 are unchanged; no owned profiling job remains live.


Optimization screening now supports `run-suite.py --preset light`: seven fixed
semantic cases / 40 full ticks, measured 27.99/28.44 seconds including restore,
checks and report generation.
Use the frozen profile in `tools/profiles/destruction-snapshot-light.json` and
[light-suite evidence](qualification/optimization-next20-20260910/snapshot-light-20260911/README.md).
It includes 113,664-chunk idle/debris and actual fracture/correction; original
inputs/tolerances and full-tick timing are unchanged. Light passes only prioritize
candidates. Finalists still require all 52 ×20, cross-build physical observations,
normal asynchronous memory checks, and continuous ordinary/sleeping qualification.
See OPTIMIZATION.md for exact commands. No runtime implementation changed for this
shortlist; no N-series experiment or speedup is credited.

Latest reusable snapshot workspace (2026-09-11): retained R2 pinned-storage pool,
R3 bulk cluster-motion transfers and R4 decoded-input/object-arena reuse, with
transactional input publication and CUDA-context-aware cleanup. Code is on isolated
`codex/snapshot-reset-20260911`, hardened commit
`38112ec7123fc63da56d651660b9bdd5f25b16d4`; main source/local runtime rebuilt, installed
SDK unchanged. Four local-build cases (bridge, city256 idle/impact/debris) also
pass 20 full ticks each and physical comparisons. An idle timing increase in
the first local screen did not persist in a balanced 20/20/20 repeat: control/local/
control means 67.835/61.275/61.061 ms; no speedup claimed. Frozen R4 passes **52/52 ×20 full restored ticks** and prior physical
A/B checks, plus **52/52 ×2 normal asynchronous memcheck ticks** (zero errors).
Final hardening passes all 28 structural/continuation/negative-input round trips,
three targeted asynchronous memory cases, and the 600-tick ordinary/sleeping wall
with exact physical counters and zero position difference. Full suite harness is
**388.529 s (6m29s)** versus 1051.101 s; ticks 58.473 versus 58.688 s; restore 127.149
versus 579.412 s, excluded from ticks. This is a setup improvement, not an application
speedup or N-series experiment; batch remains 11/20, best N13 unchanged. All 52
scenario timings and stage accounting are in
[the reset report](qualification/optimization-next20-20260910/snapshot-reset-20260911/README.md).
Large idle/impact/late-debris tick mean/max ms are 59.200/73.979,
236.880/254.511 and 394.491/458.203; repeated restores 370.612/372.699/468.164 ms.
Restore is not yet cheaper than the tick throughout the suite. Next attribute
immutable destruction-asset preparation and runtime allocation/reset costs.
R1 live-scene remove/reinsert is rejected (body-property mismatch and inflated
idle tick); never reuse that path. Retained storage never carries contact history,
solver guesses or certificates; every import is re-exported/checked. Pool retains
up to 8 GiB unused pinned capacity (2.771 GB observed large idle); decoded cache is
one <=64 MiB payload plus its representation per thread. Follow OPTIMIZATION.md
for exact build, separate restore/full-tick timing and qualification commands.

Current snapshot qualification: frozen split candidate
`8589185e659c8316b1828b7847b8780eb0f11006` now passes the native 29-case correction
regression plain and **normal asynchronous memcheck**, plus the 600-tick ordinary
sleeping wall against the pinned pre-snapshot reference (exact physical counters
and zero position difference). It replaces remaining conditional allocation with
four ordered GPU phases; no CPU per-tick wait or suppression. Full 52-case normal asynchronous memory
requalification passes, 104 ticks / 622.90 s, in
`out/snapshot-finish-20260911/device-enabled-split-mem-suite/`.
Allocation initcheck/synccheck and the three physical A/B/A smoke cases also pass.
The full matched snapshot comparison now passes **52/52**, 2,080 full ticks,
20 candidate / 20 total control samples each. Raw first-segment force-byte failure
is preserved; the existing scaled `2e-4` force gate passes all A/B and A/A checks,
with exact material/topology/load state and unchanged solver/motion tolerances.
The one chain timing signal is neutral in a fresh balanced 20/20/20 repeat.
Candidate suite harness 1,051.10 s; measured ticks 58.6884 s; restore 579.4125 s
excluded. See `device-enabled-split/matched/` in the report below. No overall or
peak speedup is claimed. Continuous 600-tick ordinary/sleeping idle/heavy A/B/A
is complete with no physical-counter or iteration-history differences. Heavy means
54.596–54.990 ms versus 54.765–55.136 controls; peaks 178.072–184.494 versus
177.557–207.905 ms; all heavy runs miss 60 Hz on 519/600 ticks. Idle means
1.694–1.830 versus 1.544–1.769 ms; zero 60 Hz misses. The possible 0.068–0.106 ms
pooled idle cost is recorded explicitly; no proven wash or speedup. The fix is
retained for asynchronous correctness and clearer GPU phase ordering, enabling
N20 requalification. Source is applied and local runtime rebuilt; the local 29-case asynchronous
correction memcheck and four physical restored comparisons pass. Best N13 artifacts and unaccepted N14 source are untouched.
The native demo source now defaults to ordinary/sleeping; historical Direct GPU
control tests explicitly select their legacy mode. The default itself completed
600 wall ticks in ordinary/sleeping mode; effective-option verifier reanalysis
passes with zero position difference. All 16 verifier tests pass. No candidate runtime change accompanied the checker/default fix.
The full physical/matched campaign is complete. Installed SDK remains unchanged. Rejected cooperative variant
`2f1286b437fb2c668d3161c33b256627b32eef6f` stalled the allocation oracle and was
killed by its watchdog; do not reuse it. Current scripts/artifacts/evidence:
[split follow-up](qualification/optimization-next20-20260910/snapshot-finish-20260911/device-enabled-split/README.md).

Previous publication-only candidate `d5d0ca49ba37f7273e8532ce77d1beec3bd4df82`
passes 52/52 default asynchronous memcheck scenarios (104 ticks; 623.12 s), but
fails the separate correction memory regression and is not retained. Three
physical A/B screens pass (flying body, 11,100-chunk impact, 113,664-chunk late
debris), including exact destruction arrays and identical measured body
positions/velocities. Older diagnostic statuses below are historical; do not
restart rejected atomic/index workarounds.

Latest asynchronous follow-up: explicit index guards do not fix memcheck; the first
error moves to a fixed field in a live status allocation. A high synchronization
limit preserves concurrency in an independent rendezvous but still fails native
impact. CUDA-only graph failures are intermittent; neither that option nor the
guarded topology module is an accepted fix. A standalone vendor reproduction is
prepared locally, not submitted. [Evidence](qualification/optimization-next20-20260910/snapshot-finish-20260911/asynchronous-followup/README.md).

Latest qualification continuation (2026-09-11): the user confirms **ordinary APIs,
Direct GPU disabled, sleeping enabled**. The full wall wrapper now defaults to
this mode and compares the hash-pinned pre-snapshot ordinary reference. A new
600-tick run passes exact fracture/topology/correction history and all existing
physical checks, with zero measured position difference. Historical Direct GPU
golden is unchanged and only selected explicitly. All 13 verifier tests pass.
The 52-case memcheck campaign also passes 104 restored ticks **with serialized
launches**; this does **not** clear the default asynchronous memcheck failure,
which remains open. Neither attempted topology workaround is retained. No
production wait/suppression or speedup is claimed.
[Current evidence and all-scale timing summary](qualification/optimization-next20-20260910/snapshot-finish-20260911/README.md).

Latest snapshot repeatability fix: isolated candidate `a68fd705cec9e6f64a65d0ca116a910331b6a1d3`
uses fixed-order parallel per-chunk contact accumulation. **52/52 scenarios pass,
20 independent one-tick restores each (1,040 ticks)** with original inputs,
frozen checker and unchanged tolerances. Previous nine health failures are the
baseline below. Full suite: 1,036.48 s harness, 59.08 s ticks, 579.74 s restore
excluded. Largest idle 62.324/82.158 ms mean/max, initial impact 242.483/278.238,
late debris 403.159/502.157; shared-GPU restored measurements, no speedup claim.
[All scales/stages and remaining diagnostic limitations](qualification/optimization-next20-20260910/snapshot-fixes-20260911/README.md).
The contact-order source fix is applied and the local runtime rebuilt; a further
20-repeat post-impact check passes. Exact full-suite artifacts remain isolated. All 28 continuation cases and 29 correction cases pass;
600-step wall physical invariants match baseline, historical golden still fails.
Default topology memcheck still fails; a CUDA-only conditional-graph control reproduces
the diagnostic exposure, but its exact cause is unresolved. No suppression or
extra production CPU wait was added. Earlier statuses below are historical.


Scenario navigation: [all 52 entries](qualification/optimization-next20-20260910/snapshot-scenarios.md)
includes the original 28 bridge/cantilever/chain/flying-body/ladder/panel/tower
and other cases plus 24 cities. All 52 now have **20-restores × 1-complete-tick**
coverage on matching frozen artifacts: 1,040 ticks, 43 repeatability passes and
9 city bond-health failures. All 28 structural cases pass (560 ticks; 139.01 s
harness wall). Both campaigns total 1,159.65 s, with 63.68 s measured ticks and
623.50 s restore excluded. Use `tools/diagnostics/destruction-snapshot/run-suite.py`.
Historical two-restores × ten-continuation-tick tests remain separate coverage.
Uniform timing coverage does not resolve the native memory or physical-quality
gaps below. Compile-time topology memcheck also fails (6,817 findings); its first
reported status read is described as out of bounds while inside the allocation.
Do not treat that contradiction as a proven tool exemption.


Latest large-snapshot continuation (2026-09-11): added **24 native city cases**
(25/64/256 buildings; 11,100/28,416/113,664 chunks; up to 229,376 bonds), eight
phases per scale, alongside the existing 28 cases. Final `complete-*` campaign:
**480/480 ticks completed; 15/24 strict repeatability passes, 9 bond-health-only
failures**, maximum health difference 0.000006079673767; observed motion
position/velocity differences zero. One final-pass case failed the prior cohort;
14 cases pass both. No tolerance relaxed. **Restore and validation are excluded
from complete_step_ms**; the timer includes commands, integrated simulate/fetch,
ready synchronization and two compact completion transfers. 54.46 s measured
compute; 1,020.64 s summed harness time including restore/validation/teardown.
Full-step idle mean/max ms: 25 buildings 11.113/21.975; 64 18.986/25.729;
256 69.177/85.129. First-impact mean/max: 44.796/53.138, 68.260/91.882,
260.453/288.678. Largest late-debris 463.076/502.288 ms, health gate failed.
These are shared-GPU fresh-restored ticks, not warm gameplay or speedup evidence.
See [all scenarios/stages/spread/budget misses](qualification/optimization-next20-20260910/snapshot-large-20260911/README.md)
and [failures and controls](qualification/optimization-next20-20260910/snapshot-large-20260911/investigation.md).

A correction stamp-capacity fix preserves original command guards while extending
storage for new fragment IDs. All 29 native correction cases and the original
28 snapshot cases pass (560 checked continuation ticks). CPU reference outputs
replace a second live GPU world, fixing large-harness GPU exhaustion. Public16 /
privateV20 / schema7 unchanged. **The complete optimization acceptance gate is
not green:** large native memcheck fails in topology atomics on updated and saved
pre-fix runtimes, and also with inline CPU dispatch. The original native demo
fails at the same sites without any save/restore. The standalone topology test
(100k chunks / 200k bonds) and four direct/graph micro-controls pass memcheck.
Do not waive the integrated finding as a proven tool issue. The frozen wall
invariants pass at 400 supported / 44 detached / 182 broken / 39 clusters; its
historical identity gate still fails. Restored and uninterrupted fracture
verdicts also differ; exact cached execution continuation is not required, but
physical-quality implications remain unqualified. Raw: `out/snapshot-large-20260911/`;
final artifacts frozen there. Source remains unaccepted N14 plus snapshot work;
retained N13 and installed original A unchanged. No optimization experiment or
speedup credited for this expansion. All owned jobs have ended.

Current snapshot implementation (2026-09-11): **V20/schema7 physical save/load
passes all 28 scenarios**, including the 444-chunk/378-owner fragmented building.
Two independent restores per case, ten full ticks each: 560 checked ticks with
zero observed pose/velocity differences. No warmup tick. Solver guesses/inverses,
certificates, response history, contact/shape caches and CPU/native scheduling
history are removed from the codec. Rebuild matching consumers. All authored
shapes, damage, mass/inertia/COM, wake state, convergence and correction caps are
checked. See [SNAPSHOT.md](docs/destruction/SNAPSHOT.md) and
[all scenario measurements](qualification/optimization-next20-20260910/snapshot-v20-results.md).
Six saved states also pass 20 independent one-tick file restores each (120 ticks),
including first fracture with one correction/two stress evaluations every time.
Five targeted file-replay memchecks pass with zero errors; nine surrounding
native CTests pass. The broad 28-case memcheck hit its 600-second harness limit
after 23 cases and is recorded incomplete, not a pass. See
[single-tick results](qualification/optimization-next20-20260910/snapshot-v20-file-replay.md).
Raw evidence: `out/snapshot-20260911/physical-state-v20/`. All owned GPU jobs ended.
Prior V19 execution-history requirements below are historical and superseded.
Source remains N14 plus snapshot work; retained N13 and installed SDK unchanged.
Snapshot correctness does not yet qualify the 24-case performance suite as
restored one-tick benchmarks, and no new speedup is claimed.

Latest user clarification (2026-09-11, supersedes execution-history requirements
below): implement **physical-state save/load**, rebuilding disposable numerical
and contact caches without advancing physics. Preserve body/shape state, ownership,
connectivity, bond health, chunk damage, materials and simulation settings. Exact
continuation of the uninterrupted scene's allocation/contact scheduling is not
required. Stop pursuing CPU pool/free-list serialization for this feature.
Validate exact physical state at import, loaded-step physical quality/convergence,
and repeatability between independent restores of the same input. Preserve prior
exact-continuation failures as diagnostics; do not relabel them as passes. Cold
restore benchmarks and continuous warm simulation measure different workloads;
retain both. Current V19 implementation/tests still need this contract migration.

Latest user priority (2026-09-11): **keep implementing full accepted-world snapshot
export/restore before more optimization experiments**. Public destruction API16 /
private runtimeV19 (schema6) is WIP; see [SNAPSHOT.md](docs/destruction/SNAPSHOT.md)
and [qualification](qualification/optimization-next20-20260910/snapshot-export-restore.md).
The full V19 suite passes 27 cold/warm/material/impact/command cases; the
444-chunk, 378-owner fractured building still fails continuation. Canonical shape
restore makes all 1,308 contact pairs exact. A PRE-tick partition diagnostic now
matches all 1,203 regular partition assignments and reduces next-step position
error from 8.872mm to 2.070mm, but does not pass the unchanged gate. V19 preserves
CPU/GPU upload ownership, reducing sleep-filter differences from353 bodies to1;
remaining motion error is unchanged. Adding prior friction history and static
contact ordering now makes the first TWO continuation ticks exact in chunk
position/velocity. Third tick still fails (1.545mm/velocity0.3874) because CPU contact-manager pool
indices reverse two newly touching pairs' activation order. Source69/345 versus
restored318/319 is confirmed in `run-cm-pool-audit/`. Causal NP slot replay restores
found-patch order but does not fix this separate activation path. Next preserve
CPU contact allocation/activation history; see the qualification report. These
are diagnostic file hooks, not the public serializer. Root GPU contains those
hooks; do not benchmark it as incumbent or claim the snapshot suite qualified.
V19 sanitizers remain pending. Never waive the motion gate.
Source/runtime are N14 plus snapshot WIP; retained N13 and installed SDK unchanged.
All raw records: `out/snapshot-20260911/`. Snapshot work is not an optimization
experiment or a speedup, and the snapshot benchmark suite is not yet qualified.

For performance optimization, follow [OPTIMIZATION.md](OPTIMIZATION.md) for exact
build, correctness, matched A/B, profiling and experiment-record commands. The
2026-09-10 workflow request resumes optimization; preserve the historical handoff
below and its artifact/fidelity constraints, and require a verified baseline
and available GPU before candidate experiments.

Semantic measurement update (2026-09-11): use the [24-case suite](qualification/optimization-next20-20260910/semantic-suite-20260911.md)
and `tools/profiles/destruction-semantic-suite.json` for event/structure coverage.
Sixteen native trajectory cases and eight synthetic physical structures have
passed GPU discovery and ten independent baseline repetitions with isolated N13
runtime; [results](qualification/optimization-next20-20260910/semantic-suite-results.md)
are under `out/semantic-suite-20260911/`. The latest user direction prioritizes
first-class PhysX + destruction export/restore before expanding prefix runs. Fixed-prefix execution is not qualified
full-state snapshot restoration. Retain full trajectories, current-tick fidelity,
all timing samples and explicit unobserved settled/reawakening/support-loss cases.
Do not count this harness work as an optimization experiment or promote N14.
Export/restore audit: [current findings](qualification/optimization-next20-20260910/snapshot-export-restore.md).
The existing PhysX collection lost private fragment shapes; `ExtCollection.cpp`
now includes their accepted scene owners and a five-case GPU round trip passes.
Destruction state itself still does not round-trip (2 source chunks → 0 restored).
Complete first-class restore remains the priority; do not call the feature done.

Current active request: run the next **20** prioritized experiments from E12,
following `OPTIMIZATION.md` and `qualification/optimization-next20-20260910/`.
The user explicitly permits breaking internal changes and qualified precision
compromises, prioritizing deletion/structural algorithms. Preserve current-tick
contact → stress/fracture → at most one correction → second stress → accepted
publication. Never use stale physics inputs or defer equilibrium across ticks.
Retain explicit physical-quality evidence; report full-step idle/heavy metrics.
The2026-09-11 clarification also allows qualified performance-neutral changes
that clearly simplify architecture or enable a concrete follow-up. Record their
benefit separately from speedups; do not waive quality or hide regressions.
The completed ten-experiment entry below is the preserved starting point.
Current batch: **11/20 completed**; retained **N13** guarded mixed block arithmetic,
commit `c1e6faca7af6cba0e65c215d7a8710c5bf3ebf59`. Heavy600-step mean56.190 ms
vs N10 controls57.396/57.168 ms (1.71–2.10% lower); idle1.644 vs1.718/1.854 ms.
Heavy maxima221.513 vs217.487/216.858 ms; no peak gain. Heavy misses remain
519/600(86.5%). N12 and N10 earlier gains are separate cohorts; do not add them.
Numerical/sanitizer and relative wall/trajectory checks pass; historical migration
and native-memory gaps remain. Installed SDK stays original A. Eight non-retained
candidates are recorded. N20 CPU source/consumers are restored; its capacity
change remains unqualified after candidate/control memory failures, with no timings.
Use isolated artifacts and queue.json for current experimental source state.
Retained N13 is frozen in its isolated B directory. Source CUDA is now
unaccepted N14 response-history work; runtime/tests are built and its short
screen is complete. Retained N13 remains the selected implementation.
Latest measurement direction: use semantic events and structural traits, with
fixed-input replay where qualified, alongside full trajectories. Follow
`qualification/optimization-next20-20260910/semantic-scenarios.md`. Existing
load captures/correction checkpoints are not complete-world tick snapshots.
N14's short screen is complete; it shows a mean/peak tradeoff and is unaccepted.
No owned benchmark remains live; reassess with semantic evidence before promotion.
CPU/GPU audit: `qualification/optimization-next20-20260910/dataflow-audit.md`.

Latest continuation: the shared-GPU ten-experiment batch is complete. Always
report idle and heavy-destruction complete-step means, maxima, exact budget
misses, initialization and clearly scoped stage evidence. Retained **E12**
combines fine-factor reuse and block-Jacobi; source and local runtime/tests match
isolated commit `8bde0e228f576fed58fdcb9c4c4ed11da922250a`. Heavy mean is
62.312 ms versus matched E3 controls 63.199–63.365 ms (1.4% additional gain).
Idle confirmation is 1.624 ms versus 1.598/1.640 ms controls. No verified peak,
deadline or startup gain: heavy misses remain 519/600 (86.5%). Earlier E3
independently improved original A by ~4.1%; do not add cohort percentages.
Failed candidates and exact commits remain in the experiment ledger. E11's
mean improvement came with worse peaks and was not retained. CPU binding work
requires resolving existing correction-memory findings first. Installed SDK
remains original A; no deployment. All owned jobs are terminal. Existing
fidelity failures remain unresolved. The older stopped/B-artifact status below
is historical. Follow the [current scenario/stage report](qualification/optimization-20260910/status-scenarios.md)
and [ranked queue](qualification/optimization-20260910/queue.json).

## Current task and machine — updated 2026-09-10

**STOPPED BY USER — handoff only.** Read
[the current WIP handoff](docs/destruction/HANDOFF-20260910-integrated-ab.md)
before doing anything. No owned experiments remain live. Do not resume GPU
experiments without a new user instruction. Current source and `physx/bin/`
contain the **unaccepted integrated barrier candidate B**; `out/install/` and
`out/sdk-artifacts.json` still describe A. Isolated A/B artifacts and exact hashes
are retained. The B timing campaign failed when another project's GPU server
appeared; it was not a completed comparison. No new speedup is established.

**Latest user direction:** iterate on the existing integrated engine with matched
A/B tests. Large internal replacements are allowed, but standalone solver gains
are not the deliverable. Stop expanding the disconnected six-channel backend;
use its retained findings only when they justify a concrete change in the current
engine path. A is the current benchmarked engine; B must run identical commands,
physics/material settings and fidelity gates, then matched complete-step idle
and destruction timing, including maxima and exact 120/60 Hz misses. The term
“production” in earlier notes meant the benchmarked implementation, not a deployed
product. No deployment is authorized.

The last disconnected precision experiment is closed and retained as
unqualified evidence in `qualification/elastic-precision-reference-20260910/`.
It is not installed in the engine. Four captured-component sanitizers pass;
all three anchored samples and the scaled control pass independent 80-digit
force/moment, response and energy checks. Nine rebuilt CTests pass; all jobs
are terminal. No additional prototype counter capture was started. This work does not supersede the user's
A/B direction or establish a complete-step improvement.

Work in `/root/workspace/physx-2` **on the new VM** (`vast-new` from the old
machine). If already inside the VM, run commands locally; the SSH alias need not
exist there. This is the user's custom embedded destruction project, not an
ovphysx/Python package installation task.

**Resume from:** branch `codex/rtx5060ti-cuda134`, migration commit `795f9c0c`.
Transferred source baseline: `471ea8a55bef3d1320a06d65d238f351f9015859`.
Check actual Git state before work: another session may have advanced it.

- ✅ RTX 5060 Ti 16 GB, CC 12.0 (`sm_120`), driver 615.71.09 after reboot.
- ✅ CUDA 13.4.59; Nsight Compute 2026.3.0; Nsight Systems 2026.3.2.
- ✅ CMake 3.31.10 in `.toolchains/build-env`; Clang 14 for CPU, GCC 12.3 as NVCC host compiler.
- ✅ SDK built/installed; hardware counters captured from a motion-slot kernel and the first 256-building fracture-peak stress kernel.
- ✅ Current installed private runtime ABI V14 captures sparse pre-addition command history and guards ordinary loaded-source correction. Nine focused CTests, native memcheck and four producer sanitizers pass. Native GPU spatial command replay is pending; production stress backend remains legacy.
- ⚠️ Physical equivalence is **not qualified** on the new GPU/toolchain. No new performance win has been established by counters.
- No game deployment or Rust/WASM consumer qualification occurred on this VM.

The previous RTX 4090/CUDA 12.8 machine remains a historical reference. Dated
4090-only, unavailable-counter, RAM-build, server-PID and deployment statements in
older documents do **not** describe this VM. This section and the migration report
supersede their environment/status claims, not their physical requirements.

## Objective and decisions to preserve

Maximize physically equivalent destruction work, especially simultaneous
256-building bombardment. 8 ms and 16.67 ms complete-step peaks are milestones,
not permission to leave avoidable work. Focus on destruction/integration added
to PhysX; retain NVIDIA's ordinary rigid-body solver as the foundation.

- User-facing path: `PxDestructionScene`, normal `simulate`/`fetchResults`,
  **Direct GPU mode disabled, sleeping enabled**, current-tick queries/actors.
- Fixed timestep **1/60 second**; **one correction maximum**, hence at most two
  physics advances and two stress/fracture evaluations per tick. Stress runs
  again after corrected physics. Iterations are not correction passes.
- Trial solves actual intact contact impulses → stress/material verdict →
  topology/motion update → rewind/correction of all affected participants →
  second verdict → accepted publication. No predicted/pre-authored breakage.
- GPU owns persistent chunk/bond state and numerical work; one motion per rigid
  cluster, not one independently simulated body per intact chunk. CPU submits
  commands and publishes required accepted actor/query compatibility data.
  **CPU fragment/contact registration prerequisites still remain.** Do not claim
  the final GPU-owned lifecycle is complete.
- Preserve convergence, forces/torques, contact discovery, mass/COM continuity,
  energy/damage and exactly-once commands/events. Do not spend unfinished stress
  convergence across ticks or loosen tests to manufacture performance/parity.
- No production compatibility fallback. This port requires CUDA >=13.4 and
  selected architecture 120; retained architecture 89 is not requalified here.
- Keep source siblings `vibe-land-4` and `blast-stress-solver-2` read-only. Do not
  stop other users' services, desktop or GPU jobs. This handoff does not authorize
  deployment, another reboot, instance deletion or driver changes.

## Validation state: do not restart these investigations from scratch

| Evidence | Status |
|---|---|
| CUDA probe / PTX JIT / memcheck / counters / timeline | ✅ Passed |
| CPU report tests | ✅ 52 passed |
| Broad native/numerical screen | ⚠️ 57/61 passed; includes 8 standalone GPU tests and 6 smoke checks (do not add those again) |
| Motion-slot memcheck | ✅ Zero errors; fixture capacities through 113,664 slots, not a city simulation |
| Ordinary penetration, sleeping on | ⚠️ 600 steps / 10 sim seconds; 444 chunks, 896 bonds, 1 projectile. Both holes, projectile clearance and motion invariants pass. 400 supported, 44 detached, 182 broken bonds, 39 clusters; historical golden is 398/46/199/43. Exact identity gate fails. |
| Direct GPU penetration control | ❌ Same fixture/duration; displaced-wall-chunk invariant fails |
| Two large native audit failures | ❌ 256 buildings, 113,664 chunks, 229,376 bonds, 256 shots, 180 steps. Exact-zero pose assertion fails by ~22 micrometres (Direct GPU) / ~17 micrometres (ordinary + sleep). |
| Other two native failures | ❌ Accepted-properties TGS/PGS initcheck; isolated CUB scan reproduces warnings with correct outputs. Cause unresolved. |
| New six-channel numerics and mapping | ✅ Nine six-channel CTests pass, including native graph/load binding and setup accuracy. Load join, PCG, operator and setup have focused four-sanitizer evidence in their recorded stages. Live full command/material integration remains pending. |

Frozen tests/tolerances were not changed. An aligned-transform pose experiment
did not fix the discrepancy and was reverted; temporary logging was removed.
Do not repeat that unchanged experiment. CUB poisoned-output control clears the
warnings, but **production zeroing/suppression was not added**. A sanitizer issue
is a hypothesis, not an established exemption. Historical golden API-mode parity
has not been independently established in this migration; do not assert a specific
compiler/device cause before comparing matched controls.

Committed evidence: [migration report](qualification/rtx5060ti-cuda134-20260910/README.md).
Raw VM captures: `out/vm-port-20260910/`; probe: `/root/cuda-upgrade-check/postboot.qVQlHO/`.
Current baseline and counter evidence:
[ordinary/sleeping baseline](qualification/baseline-rtx5060ti-20260910/README.md).
Three 600-step / 10-second runs per regime: 256 buildings, 113,664 chunks,
229,376 bonds; pristine idle has 0 shots, bombardment has one 256-shot wave.
Complete-step idle means 1.630–1.679 ms, all-step peaks 15.324–16.426 ms;
bombardment means 63.859–64.192 ms, peaks 195.116–223.327 ms at step 82.
All 3,600 measured steps report convergence and correction/evaluation-cap
compliance; migration physical-equivalence gates remain unresolved.

A separate 180-step timeline identifies step-82 trial/correction stress and
the later expensive step-108 trial. First-peak trial counters were collected
(21 replay passes, cache flush on, clocks unlocked); the profiler intentionally
stopped its own target after the selected kernel. Continuing with Nsight Compute
attached fails at step 82 with status 1288, including an attempt targeting only
the later launch. [Follow-up diagnostics](qualification/baseline-rtx5060ti-20260910/nsight-investigation/README.md)
show allocation/preparation branches executing under Nsight when their condition
is false, promoting a normal capacity-growth receipt into rejection. Collection
disabled still fails; simpler graph/allocator controls pass. Underlying cause
remains unresolved; first-peak counters are indicative, not a verified identical
production-state replay. **A working alternative now captures later peaks:**
[direct CUPTI PM sampling + Systems timeline](qualification/pm-sampling-rtx5060ti-20260910/README.md).
Two 180-step runs complete with matching fracture/cluster/contact/topology
histories and convergence/correction checks; iteration counts vary on some
steps. All 267 stress launches map to the timeline. Selected step-82/87/108
kernel interiors show 28–30% resident warps and 11–30 GB/s DRAM traffic.
These device-wide counters include desktop contexts. Flagged timestamps are
retained/excluded from attribution; no hardware overflow occurred. FP64 counters
require multiple passes and remain unavailable through this PM sampling path.
Desktop graphics stayed active: these are diagnostic shared-GPU measurements.
Raw evidence: `out/baseline-20260910-ordinary-sleeping/`. No new jobs remain live.
Production simulation binaries were unchanged; isolated logging/range-marker
builds are under the raw capture directory. Capture/report tooling now explicitly
permits recorded pre-existing graphics identities and records loaded modules.

New solver WIP now includes the six-channel fine operator, RHS/recovery, full
block Cholesky, scaled free-mode projection and GPU component-local PCG.
[Contract](docs/destruction/elastic-operator-contract.md) and
[source patch / current evidence](qualification/six-channel-loads-20260910/README.md).
Independent supported/free algebra, 129 mixed components (774 nodes/1,032 bonds)
and separate 137-node components pass. A receipt-padding initcheck defect was
fixed with an explicit initialized residual-check count; all four final solver
sanitizers pass. It is unrelated to the unresolved production CUB findings.
Setup and recurrence are now separate GPU kernels. A checked producer-version
receipt retains connectedness, scaled rigid modes and Cholesky factors across
load-only changes; stale setup cannot enter iteration. Standalone counters show
recurrence reduced from 228 to 128 registers/thread, a four-block register limit
and 24.38% achieved occupancy, with no reported spills. Fresh preparation has
its own cost; matching setup skips its adjacency/factor work. This tiny
six-nodes-per-component fixture is not city-performance evidence. Engine-owned
partition/revision production, load conversion, material transactions and
runtime replacement remain pending.

The new [physical load adapter](docs/destruction/elastic-load-adapter-contract.md)
now consumes PhysX full chunk mass/inertia and surface wrenches, handles free
inertial relief or supplied engine acceleration, and gates fine-solver input
with an exact interval/ownership/evaluation receipt. Independent free-fall,
spin, impact, supported-body and frame tests pass, including a device-only
load/RHS/PCG handoff. A real boundary mismatch (~12 nm between float legacy and
double fine moment origins) initially failed compatibility; canonical GPU
positions and explicit torque transport fixed it without changing tolerances.
This does not explain the older migration pose failures. Adapter fixture
counters: 116 registers/thread, 30.11% occupancy, no spills (129 aggregates,
774 chunks); no city-performance claim. The live runtime does not invoke this
adapter yet. Capture its real inputs after `routeContacts` and before stress
dispatch, not by assuming post-fetch ownership matches the earlier evaluation.
Production binaries are unchanged. Source remains uncommitted WIP on 1155b7ff;
the focused patch and current source/binary/module hashes are preserved above.

[Frozen native-load capture and adapter replay](qualification/live-loads-20260910/README.md)
now records four post-contact/pre-stress evaluations from one 180-step run with
256 buildings, 113,664 chunks, 229,376 bonds and 256 shots. Trial/correction at
tick 83 have 256/5,120 motion aggregates; tick-109 trial has 10,905. All four
independent load-equation comparisons pass, as do four focused CTests and four
sanitizers on the later replay. Native topology generation zero is now accepted;
an exact free-singleton path removes cancellation residuals without relaxing
tolerances. Later-capture adapter counter duration changes 5.89→1.96 ms, still
116 registers/no spills. Counter and unprofiled replay outputs are byte-identical.
This is a surface-plus-gravity numerical replay, not an integrated performance
win or certification of all engine commands. The actual native ledger remains
marked incomplete. Trajectory fracture/contact/topology histories match the
existing timeline; iterations differ on 26 later steps. Installed runtime stays
unchanged; all owned jobs finished. Raw inputs/maps: `out/live-loads-20260910/`.

[Active GPU partition](qualification/elastic-partition-20260910/README.md) now
maps native topology to compact canonical geometry, physical mass and load
storage, with device-owned counts and revision/allocation/slot validation.
An isolated live runtime retains the initial map at tick-83 trial and rebuilds
for its 5,120-cluster correction and tick-109's 10,905 clusters. Final 180-step
trajectory matches physical counter histories; iterations differ on 24 later
steps. Five CTests, four independent captured-load checks and eight sanitizer
runs pass. Sparse-test readback initially touched unused capacity; active-prefix
readbacks fix it without production zeroing. Invalid partition counts now publish
zero usable entries and propagate failure. Counters: fresh `pack` 88.22 µs,
36 registers; device-count adapter 1.95 ms, 118 registers; no spills. These are
selected profiler scopes on 113,664 chunks, not whole-step performance.
Global rebuild/guarded launch costs remain; conditional scheduling and per-dirty-
component reuse are pending. Command/interval completeness and general producer
revisions remain distinct from mapping readiness. Actual corrected snapshots are
refreshed after corrected motion, so do not infer original load acceleration
from them. Raw final evidence: `out/elastic-partition-20260910/final/`.
Installed runtime remains unchanged and no owned jobs remain live.

**Latest installed-runtime update (supersedes the preceding unchanged-runtime
status):** [Original input history](qualification/elastic-input-history-20260910/README.md)
now survives corrected checkpoint refresh through rotating reusable storage.
SDK/GPU/native consumers were rebuilt together for private ABI V11. Seven
focused native tests and checkpoint memcheck pass. Saved V10 and rebuilt V11
checkpoint initchecks both report 10,028 findings with identical device sites
and counts; they predate this change but remain unresolved, not waived.
A new 180-step city diagnostic preserves byte-identical original body arrays
across tick-83 fracture correction. Physical counter histories match the prior
partition capture; iterations differ on 21 later steps. The 600-step ordinary
wall invariants and topology identity match the migration capture; historical
golden still fails. Raw arrays are not a complete chunk load ledger: current
fragment IDs need ancestry before joining original body inputs. No speedup
claimed. Raw evidence: `out/elastic-input-history-20260910/`; no live owned jobs.

**Current ABI V12:** [GPU original-motion ancestry](qualification/elastic-input-owners-20260910/README.md)
adds original body/root/slot/generation records keyed by authored chunk, captured
at the native pre-solve boundary. Device receipts gate use; correction retains
the records. In a new 180-step city capture, all 4,864 newly assigned fragment
bodies at tick-83 correction resolve to original parents with unchanged original
bytes. Seven native checks, checkpoint memcheck and four producer sanitizers pass;
the producer regression is also registered with CTest. Physical counter histories
match V11; iterations differ on 23 later steps. Wall invariants and migration
topology identity match; historical golden still fails. Startup ancestry counters:
22.66 µs, 16 registers, 91.73% occupancy, no spills; output byte-identical.
One-step profile exits 1 for absent demonstrated destruction, not kernel failure.
No whole-step speed claim. Command apportionment/interval completeness remain
pending and the loaded-source correction guard remains. Raw:
`out/elastic-input-owners-20260910/`; no owned jobs remain live.

[Explicit GPU chunk commands](qualification/elastic-commands-20260910/README.md)
now convert frozen world force/impulse points and couples into node loads and
grouped body wrenches. Six focused numerical CTests, final four command
sanitizers, split replay and command-to-adapter handoff pass. A 113,664-command
synthetic batch passes a wider independent torque oracle at unchanged limits;
the initial reference cancellation failure is retained. Counters: resolve
101.95 µs, aggregate 33.57 µs, no spills; outputs byte-identical. These are algebra
kernel scopes, not city-step performance. Native submission, wakeup, interval
accounting and physical command replay are pending. Installed runtime remains
V12 with the loaded-source guard intact. Raw: `out/elastic-commands-20260910/`.

**Current ABI V13:** [Native command-owner wake bridge](qualification/elastic-command-wake-20260910/README.md)
validates selected owner IDs, finalizes pending GPU sleep writes and wakes only
dynamics between accepted steps. The new regression passes eight TGS/PGS ×
optional-acceleration × correction combinations and memcheck (zero errors).
Together with seven unchanged checkpoint/correction/sleep checks, eight unique
native CTests pass. Initial failures were incorrect test assumptions about
ordinary command storage: correction-enabled input uses GPU velocity deltas;
correction-disabled input with optional accelerations uses accumulators. Exact
representation and total impulse checks now cover both; tolerance unchanged.
The 600-step ordinary wall invariant subset and topology identity match V12;
the historical golden mismatch remains. This private wake hook does not apply
GPU commands or complete their ledger/replay. No speedup claimed. Failed attempts
and final hashes/maps are retained in `out/elastic-command-wake-20260910/`;
`verified/` is successful, `final/` is an intermediate failed attempt. No owned
jobs remain live. Next implement validated GPU command application after CPU
input upload and before checkpoint, with explicit trial/correction accounting.

[GPU command-to-native-motion transaction](qualification/elastic-command-motion-20260910/README.md)
now consumes command evaluator outputs into checked `PxgBodySim` velocity writes.
Seven numerical/motion CTests and four sanitizers pass. Sparse lifetime/duplicate
checks, a one-to-two synthetic rewind, rotated inertia, empty batches and a
matching-mass device evaluator handoff are covered. Large synthetic scope:
113,664 groups / 227,331 slots; prepare 105.47 µs, apply 19.90 µs, no spills,
profiled outputs byte-identical. This is NOT a native city simulation or speedup.
Runtime binaries remain hash-identical V13 and do not invoke the new kernels.
Next supply a producer-owned **command-free** correction baseline; the original
checkpoint is post-command and cannot receive these deltas again. Native wake,
application boundary, full ledger and material transactions must be joined before
claiming exactly-once physical replay. Raw: `out/elastic-command-motion-20260910/qualified/`.
No owned jobs remain live.

**Latest installed ABI V14:** [Native pre-addition command history](qualification/elastic-command-inputs-20260910/README.md)
captures ordinary host velocity deltas and exact pre-addition velocities after
body initialization/property upload, before GPU delta addition. Sparse 64-byte
records share original checkpoint generation/readiness and survive corrected
refresh; no extra whole-body copy. Nine focused CTests, native memcheck and four
producer sanitizers pass. The rounding-loss counterexample validates why subtracting
an already rounded delta is insufficient. Actual native capture counters: 2.37 µs,
26 registers, no spills (small three-actor fixture); synthetic 113,664 uploads:
78.05 µs, profiled records byte-identical. The ordinary 600-step wall invariant
subset/topology identity match V13; historical golden still fails. This preserves
that upload's baseline, not all command channels or spatial load distribution.
No speedup claimed. Native command-motion application/full ledger remain pending.
Raw: `out/elastic-command-inputs-20260910/`; no owned jobs remain live.

[GPU child-baseline join and command replay](qualification/elastic-command-baseline-20260910/README.md)
now indexes sparse original command records, verifies every child's original
chunk ancestry and transfers saved rigid velocity to its rewound COM. The motion
transaction accepts the matching baseline before corrected command application.
Nine focused numerical/command CTests pass, with four sanitizers each for baseline
and motion. A matched parent-force/child-replay device chain preserves total
linear/angular impulse and avoids cloning the command to the other child.
Standalone resolve counters: 27.01 µs, 38 registers, no spills, byte-identical
outputs (113,664 authored chunks / 512 children / 256 original parents).
Runtime binaries remain V14 and do not invoke the join/motion application yet;
this is not native fracture or performance qualification. Explicit command
submission, before-images for new GPU commands, a complete spatial ledger and
accepted material/replay integration remain. Raw:
`out/elastic-command-baseline-20260910/final/`; no owned jobs remain live.

[Ordinary command correction guard](qualification/ordinary-command-correction-20260910/README.md)
now consumes sparse GPU command-generation stamps in both graph and explicit
correction preparation. A verified ordinary force/torque bypass is closed;
unapportioned nonzero parent loads reject, unrelated/zero commands still allow
fracture correction. Invalid history rejects with preparation error 64. The
Direct GPU/no-host-upload path now publishes an explicit empty ordinary history;
its accumulator guard remains. Private ABI stays V14. Nine focused CTests,
29-case native correction memcheck and four producer sanitizers pass. The
600-step ordinary wall invariants/topology identity match prior V14; historical
golden remains unresolved. Standalone 113,664-upload stamp/capture counters:
79.62 µs, 26 registers, no spills; records match plain and prior captures. No
complete-step speedup is claimed; spatial replay/full material ledger is pending.
**Cheaper Nsight reproducer:** native_gpu_correction_body_test fails at its first
three-chunk/one-bond ordinary fracture with stage 1288 under Nsight attachment,
even `--profile-from-start off`; plain and memcheck pass. Native counter output is
unqualified. This small native reproducer led to the independent thread-boundary diagnosis
below; the precise faulty profiler/driver component remains unresolved. Raw: `out/ordinary-command-correction-20260910/`;
failed intermediate Direct GPU history case is in `attempt-1/`. All owned jobs
finished; final modules/maps/source hashes are in the linked receipt.

**Latest Nsight diagnosis:** [Cross-thread conditional-graph reproduction](qualification/nsight-cross-thread-20260910/README.md)
is independent of PhysX/Blast: two one-thread kernels and one IF node. With
Nsight 2026.3 attached, an executable graph instantiated on one CPU thread and
launched on another executes false branches. Two matched repetitions confirm
all six plain controls pass; three attached thread-mismatch variants fail in
both repetitions. Instantiation on the launching worker passes; upload/re-upload
alone does not help. Cross-thread memcheck passes. No claim identifies the exact
faulty vendor component. Standalone report/archive is prepared, not submitted.
An isolated native **inline CPU dispatcher** diagnostic passes all 29 correction
cases plain, attached without collection, and with selected counters; result lines
match. Actual native source-load inspector: 3.23 µs, 22 registers, no spills
(3 chunks / 1 bond / 2 source clusters, not a city stress bottleneck). Reusable
helper: `tools/diagnostics/nsight-cross-thread-conditional/build-native-inline.py`.
Production four-worker scheduling, sources and SDK modules are unchanged.
**City diagnostic now validated:** [completed trajectory counters](qualification/ncu-city-20260910/README.md)
cover step-82 trial/correction and step-108 trial. Six 180-step runs (256 buildings,
113,664 chunks, 229,376 bonds, 256 shots) complete with byte-identical recorded
chunk/projectile poses and matching checked physical counter histories across
production, inline plain, timeline and counter captures. Iteration counts differ;
this does not qualify full numerical/material equivalence or migration gates.
Actual stress kernels use 110 registers, 31.77–33.23% occupancy, no reported spills;
FP64 pipeline 54.42–61.11%, DRAM 1.69–3.41%, only 0.088–0.100 eligible warps per
scheduler. Source sampling locates polynomial-boundary barriers and dependent
FP64 arithmetic; later barrier exposure grows. Reduce repeated structural work
and dependency depth before another cache/precision experiment. No speedup claim.
Inline CPU/complete-step times cannot represent production timing. Production
scheduling and SDK modules remain unchanged; all six runs load matching modules.
Raw: `out/ncu-city-20260910/`; all owned jobs finished. Original reproducer evidence
remains in `out/nsight-small-context-20260910/`. Next connect this work census to
six-channel solver/native command-load-material integration; preserve the frozen
quality gates and both untraced idle/impact timing regimes.

[GPU unknown components](qualification/elastic-components-20260910/README.md) now
separate independent unknown systems across shared prescribed supports. A device
count drives bounded setup/solve dispatch. Seven six-channel CTests and eight
final producer sanitizer runs pass; setup also passed four sanitizers before the
isolated producer optimization. An explicit integer scan replaces an unqualified
CUB scan attempt without suppression. Matched single-launch counters on a
113,664-node / 226,559-bond synthetic graph change union 495.07→76.06 µs and
labels 35.46→3.36 µs after atomic parent halving, with identical mapping exports.
This is not native city or complete-step performance evidence. Installed V14
runtime remains unchanged; native keys/load/material integration remains open.
Raw evidence: `out/elastic-components-20260910/`; no owned jobs remain live.

[Native topology to six-channel graph](qualification/elastic-native-graph-20260910/README.md)
now binds native deletion/support state without copying bond matrices, and supplies
native device setup keys to the component builder. Eight six-channel CTests and
eight native-graph sanitizer runs pass. Four existing native topology captures
map 97,280 unknowns into 256 / 256 / 5,120 / 10,905 components, matching independent
traversal. These are mapping replays with supplied algebra coefficients, not new
material verdicts or native physics runs. Later-state selected counters: node
binding 11.94 µs, bond binding 38.18 µs, union 52.16 µs, 16 registers/no spills;
plain/profiled mapping exports match. No complete-step speedup claim. Production
V14 runtime/demo hashes remain unchanged. Live geometry/material authoring,
complete loads/commands, dirty lifetime and accepted material/correction joining
remain. Raw: `out/elastic-native-graph-20260910/attempt-1/` (successful); no live jobs.

[Native load join and numerical accuracy](qualification/elastic-load-join-20260910/README.md)
now connects compact physical loads to the six-channel graph entirely on the GPU.
Frozen initial city input (113,664 chunks / 229,376 bonds / 97,280 unknowns)
converges all 256 components in 271 maximum / 69,376 summed iterations, with
independent load, fine force/moment, response and energy checks passing.
The explicit stiffness/accuracy profile is uncalibrated; this is not native
physics or material parity. Captured impact/correction/later queries still reject.
The recurrence-refresh target now respects per-node limits; compensated original-
equation residual/recovery fixes independently demonstrated cancellation errors.
Hardware-only counters work: the earlier accepted initial solver-kernel sample
is 795.894 ms at 75.7% FP64 pipe utilization, far outside the real-time budget.
A full-section attempt timed out in software-counter instrumentation (CUDA 702);
do not confuse it with the older conditional-graph attachment issue.

Later-state setup rejection was independently attributed: ordinary arithmetic
falsely rejected rigid modes. Compensated setup accepts 105 formerly rejected
components, leaving 142 represented bases that still fail the same 1e-10 limit.
All 63,042 modes of 10,507 accepted free components pass independent checks.
A native four-chunk regression and all nine CTests pass; tighter failed limits
still reject. Isolated free chunks use an exact coordinate basis only after
checking that no live interface remains; incompatible loads and invalid
partitions still reject. See the report for staged sanitizer/counter evidence.
Three paired later-state setup counter captures reduce this kernel from
46.031–46.050 ms to 34.805–34.859 ms by removing general setup for 9,114 isolated
chunks. Setup statuses and mappings match exactly; basis/mode values match with
only zero-sign representation differences. Final nine CTests/four setup
sanitizers and all accepted-mode checks pass. This is a profiled local change,
not an untraced complete-step win. All jobs in the report are terminal.
Production V14 runtime/demo remain unchanged. Next resolve the material/precision
envelope and pending impact queries, then structural acceleration
and accepted native transactions; do not rerun the unchanged 8192-iteration city
failures just to retime them. Raw: `out/elastic-load-join-20260910/`.

[Uniform-gravity cancellation](qualification/elastic-gravity-cancellation-20260910/README.md)
then removed 197 corrected-impact and 51 later-state false compatibility failures.
Complete free aggregates now compute internal loads relative to uniform gravity;
physical acceleration receipts and physical external/inertial balance scales
retain gravity. No tiny-load cutoff or tolerance change. Zero-iteration diagnostic
checks now report no incompatible loads on those two captures; 333 / 1,539
components still need iterations, and later setup still rejects 142 bases.
This is not a full impact solve. All nine CTests/four load sanitizers and captured
Newton–Euler comparisons pass; the initial full solve is byte-identical to the
prior verified one. One load-kernel counter sample is 899.488 → 930.016 µs,
not a speedup claim. The failed first patch that accidentally changed balance
scales is retained. Raw: `out/elastic-gravity-cancellation-20260910/`; all jobs
terminal, production binaries unchanged. Use `--fine-check` to investigate input
compatibility without repeating capped iterations. Private test/replay hashes
are recorded separately; refresh the SDK-wide attestation at the next SDK build.

Timing reports retain exact >1000/120 ms and >1000/60 ms exceedance counts and
show percentages alongside them. The separate >8 ms goal and all-step maximum
remain; the physical timestep stays 1/60 second.

## Start working: commands and immediate priorities

```bash
cd /root/workspace/physx-2
git status --short
git log -3 --oneline
nvidia-smi
ps -eo pid,etime,comm,args | grep -E 'nvcc|cicc|ctest|native_destruction|ncu|nsys'
df -h .
export PATH="$PWD/.toolchains/build-env/bin:/usr/local/cuda-13.4/bin:$PATH"
# Incremental build/install; do not discard existing build directories.
python tools/scripts/build-destruction-sdk.py --jobs 8 \
  --cuda /usr/local/cuda-13.4/bin/nvcc --cuda-architectures 120 \
  --cc /usr/bin/clang --cxx /usr/bin/clang++ --gpu-renderer
```

1. Resolve/attribute migration validation failures with matched captures; compare
   the first differing contact/load/stress verdict, not just final counts.
2. Continue from the current baseline and working PM sampling counters above.
   Obtain component-work and source/PC evidence to distinguish arithmetic,
   dependency and synchronization costs. Nsight Compute's graph issue remains
   separate; use a verified production-input replay if kernel replay is needed.
   Exploration can proceed while parity
   is unresolved, but cannot establish a physically equivalent performance win.
3. Resume ranked replacements from [TODO.md](TODO.md). Rank 1 lifecycle is partial;
   the static-registration integration patch is **unapplied**, not a completed win.
   For the new six-channel model, continue from the verified standalone GPU
   iteration and reusable setup, not a fresh operator rewrite. Implement the
   live engine producer at `prepareLoads`/`contactLoad` in
   `PxgDestructionRuntime.cu`, using the tested physical adapter. Existing inputs
   are acceleration-style, with physical torque retained separately in surface
   loads. Reuse the frozen post-contact/pre-stress captures and active GPU
   partition above. Next preserve the original command/load interval separately
   from corrected-state checkpoints, publish a complete input receipt and wire
   general producer revisions. Numerical component/setup keys and full bond/
   material/correction transactions remain; do not rebuild the mapping prototype.
4. Measure fresh intact idle and peak destruction separately on matched settings.
   Use untraced complete-step timing for claims; keep first-step/allocation spikes.
   Hardware profiler time, nested scopes and CPU core-ms are not additive wall time.

Every number needs workload, chunks/bonds/projectiles, active work if available,
duration/repeats and timer scope. Do not substitute means/p99 for maximums. Report
fidelity, architecture/maintainability and measured speed separately: a neutral
architectural step may be useful, but is not a speedup.

## Skills, code and evidence routing

Read only the workflow needed; the essential current status is above.

- [VM build and validation skill](.agent/skills/physx-vm-validation/SKILL.md): exact commands, failures, captures and migration pitfalls.
- [Counter profiling skill](.agent/skills/physx-destruction-profiling/SKILL.md): capture selection, measurement separation and counter interpretation.
- [Existing performance skill](.agents/skills/physx-destruction-performance/SKILL.md): optimization method, experiment rules and historical index. Both `.agent/` and `.agents/` intentionally exist; keep old links valid.
- [Optimization inventory](docs/destruction/OPTIMIZATION_INDEX.md), [ranked replacements](docs/destruction/REPLACEMENT_PLAN.md), [failed experiments](docs/destruction/PERFORMANCE_FINDINGS.md): historical mechanisms/evidence, not current-device performance promises.
- Public API: `physx/include/PxDestructionScene.h`; GPU orchestration/topology:
  `physx/source/gpudestruction/src/`; stress: `blast/source/sdk/extensions/stressgpu/`
  and `detail/`; actor bridge: `physx/source/physx/src/NpDestructionBodyAllocator.h`;
  simulation integration: `physx/source/simulationcontroller/src/` and
  `physx/source/gpusimulationcontroller/`; demos/tests: `demos/blast-stress-demo/`.

## Storage and handoff hygiene

8,493 source entries and Git history were copied and hash/symlink-verified.
Old `out/`, build caches and `/tmp` captures were NOT fully migrated. Do not claim
this is a complete old-instance backup or advise deleting it. Old recorded RAM
symlinks are not inputs to this VM's rebuilt SDK. Transfer manifest:
`/root/cuda-upgrade-check/physx-transfer/source-manifest.json`.

Existing `docs/destruction/visual-audit-20260909/` is untracked user WIP; preserve
it and exclude it from unrelated commits. All migration code is committed at
795f9c0c. Use fresh capture directories, preserve failed attempts, and record actual
loaded modules (`/proc/PID/maps` for dynamically loaded libraries), hashes and
commands. `out/sdk-artifacts.json` is refreshed by the build helper; later manual
builds require refreshed attestation. No Git remote push is implied.

At handoff update this dated snapshot, TODO dispositions and evidence links.
Record any live job PID/log instead of leaving a new agent to rerun it. A docs-only
handoff needs link/command review, not another expensive simulation campaign.

## ovphysx (unrelated upstream project)

Self-contained Python/C library for USD-based physics simulation — the fastest
path to running PhysX from Python for reinforcement learning and robotics.

```bash
pip install ovphysx
```

- **Documentation:** https://nvidia-omniverse.github.io/PhysX/ovphysx/index.html
- **Source subfolder:** [`ovphysx/`](ovphysx/)
- **Samples:** `ovphysx/tests/python_samples/` (hello_world.py, clone.py, etc.)

The installed wheel ships `SKILLS.md` with step-by-step playbooks for common
tasks (scene loading, environment cloning, tensor bindings, resetting).

## Other projects in this repo

| Directory | What it is |
|---|---|
| [`physx/`](physx/) | PhysX SDK — C++ real-time physics engine |
| [`blast/`](blast/) | Blast SDK — destruction and fracture simulation |
| [`flow/`](flow/) | Flow SDK — fluid and fire simulation |

Each subfolder has its own README with build and usage instructions.
