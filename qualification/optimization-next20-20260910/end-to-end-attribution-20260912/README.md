# End-to-end attribution after GPU recovery

**CPU and full graph counters pass all52 scenarios.** The graph expansion
contains461 nonempty graph invocations /49 reports /98 checked ticks; three
zero-graph scenarios have explicit inventory rows. The representative ordinary-
kernel expansion qualifies39/52 scenarios and is continuing. [Live coverage by all52 scenarios and continuous controls](coverage-tiers.md),
[structured coverage](coverage-tiers.json), [full-step baselines and CPU stages](report.md),
and [ordinary-kernel counter ranges](ordinary-counter-summary.md).
The profiling expansion itself makes no runtime or speedup claim. Isolated N20
shows a restored-debris benefit but remains unretained pending full-suite review;
N06a is rejected. [All candidate scenario/stage evidence](n20-followup.md). Physical inputs, ordinary APIs,
sleep, correction limits, runtime modules and tolerances are unchanged.

## Recovery and CPU qualification

The user authorized reversible service/GPU recovery, then rebooted the host at
07:05:39 UTC on2026-09-12. Desktop and persistence services restarted. The GPU
recovered without a driver/toolkit update. The server from the other project
was temporarily stopped; its private restart configuration is retained locally.
Automatic restoration pins the hash-verified original installed SDK because the
old server binary must not load experimental libraries added later to the mutable
build path. No server source, installed SDK or permanent service setting changes.
The original Xid120 capture remains quarantined. A reduced-tracing retry passes
city64 initial impact, and the remaining13 captures pass. This does not prove
which option caused the original firmware fault.

CPU coverage totals104 checked ticks,21,401 CPU samples,91,538 engine scopes and
18,376 kernel launches. All28 structural cases and all24 city stages qualify.
Observed position, linear-velocity and angular-velocity differences are zero;
maximum orientation-dot error5.2338594e-7 passes the unchanged gate. The resumed
13-case campaign took352.43 seconds, plus the separate impact pilot; earlier good
captures were reused. Raw scope counts agree with native phase CSVs, and each
main-thread scheduler partition sums to its same-clock tick interval.

Every case retains Systems/SQLite, all recorded CPU stacks/scheduling, CUDA/OS
callers, GPU launches/copies/memsets, stream correlations and native phase clocks.
Unresolved proprietary driver/kernel frames and sample-throttling warnings are
explicit. Samples are statistical counts, not CPU milliseconds. Detached scopes
are not assigned invented thread CPU time. Runtime binaries remain unchanged.

## Counter diagnosis and working collection mode

The original2025.3.1 selected/stress campaign still qualifies52 cases /62 files /
86 launches. It does not capture individual conditional-graph nodes. New locally
extracted2026.2.1 and2026.1.1 pilots both reproduce the2026.3.0 heap-abort symptom
on the same city25-impact input. No fourth version retry is planned. The precise
injection corrupting write remains unproven. A2026.3.0 pilot with forced
`CUDA_LAUNCH_BLOCKING=1` and analysis rules disabled still aborts after its first
stress capture; synchronization is not a fix.

A different collection route records whole graphs with the stable2025.3.1 tool.
With optional host analysis rules enabled, its **collector process** segfaults;
the application completes. The local crash dump identifies the collector and
its stack is preserved in `graph-host-stack.log`. A matching graph-only control
still crashes with rules enabled. **Disabling those rules succeeds**, collecting
all18 expected graph invocations with full hardware metrics and passing the
unchanged physical comparison. Rules off removes optional derived analysis, not
the requested full hardware metric set. The full graph campaign applies this
workaround and audits nonempty graph invocations against Systems.

Graph counters aggregate their nodes and do not provide individual conditional-
node/source counters. The ordinary-kernel supplement selects every family costing
at least0.1ms, plus enough additional families for99% of matched kernel duration
including graphs, then captures the first and slowest observed
invocation at each launch configuration. Extra representatives selected by the
shared invocation filter are counted. This is explicit representative coverage,
not a claim to capture every invocation's counters. Complete timelines retain
every launch; thresholds and all-invocation tools remain available for deeper
investigations. Missing inventories never silently pass. The strengthened offline plan covers
at least99.0002% of kernel duration in every case:2,701 configurations and5,449
representative launches. This is planned coverage until captures and audits pass.

The ordinary-kernel pilot passes strict application replay:93 configurations,
215 full-counter records, exact inventory and physical comparison;40 replay
processes took1099.56seconds plus export/audit (1125.44seconds total). It did not
establish a collection-time advantage over kernel replay. The first39 cases use kernel replay except the reused city25 application pilot.
The city64-impact240-record capture finished while its parent was paused; its
recovered export/inventory/physical audit passes. Remaining cases now pilot
application replay with a3600-second watchdog because kernel-replay cost grew
sharply with world memory. This is a collection-cost hypothesis, not an established
advantage. Original attempts and replay mode remain explicit.
Application replay repeats the process for counter passes; each process runs
the native two-restore repeatability check. The final two outputs also receive
the explicit unprofiled-reference physical comparison. Intermediate process
outputs are overwritten by the native runner; they are not separately claimed
as reference comparisons. A wrapper update moves repeated artifact hashing
outside execution, retaining per-poll file-identity guards and final hashes.
Future application A/B tests must use the same wrapper for both arms.

Sources: [NVIDIA graph profiling and metric limitations](https://docs.nvidia.com/nsight-compute/ProfilingGuide/index.html#graph-profiling),
[NVIDIA invocation/configuration filtering](https://docs.nvidia.com/nsight-compute/NsightComputeCli/index.html#profile),
[official archived collectors](https://developer.download.nvidia.com/compute/cuda/redist/nsight_compute/linux-x86_64/).
These documents describe capabilities, not proof of the precise bugs observed here.
The graph audit flags49 L2 hit-rate results above100%; those ratios are not valid
quantitative evidence. NVIDIA documents both asynchronous display/device traffic
and multipass variability as possible causes. The reports retain the raw values;
neither cause is established here. A headless full-counter control still gives104.60%; a narrow L2-only
control still requires two passes and produces further impossible ratios. Both
pass physical checks. Neither display removal nor reduced metric selection fixes
this case; those ratios remain unusable. New2026.3 whole-graph mode also
aborts at first impact, so it supplies no remedy. The full ordinary expansion
is now running headless with the stable2025 collector. See [the controls](l2-controls.json).
Offline `--import --apply-rules yes` is rejected by the2025 CLI, so rule reruns
cannot be assumed to work without recapturing.

The recorded collector commands explicitly select cache control `all` and clock
control `none`. The installed CLI default clock policy is `base`, but the wrapper
overrides it; actual clocks remain driver-managed. Counters characterize diagnostic
replay with collector cache handling, not normal cross-kernel cache reuse. Use Systems and unprofiled ticks for application attribution. A
specific cache-reuse experiment may need a targeted application-replay capture
with cache control disabled. [Recorded collector policies](collector-policies.json).

## Continuous application controls

Both180-tick ordinary/sleeping idle and heavy runs pass exact per-tick work,
convergence and correction-counter comparisons against their unprofiled controls.
At500,000 reference cycles per CPU sample, the OS throttled collection. At10million
cycles, both repeated traces have no sampling-throttle warning. Those contain
281 idle and2,193 heavy CPU samples, plus11,242 /88,917 GPU launches. The original
higher-rate captures remain available for comparison. The generic NVTX warning
remains; native frame clocks and native phase CSVs define the continuous windows.
CUDA-event completeness warnings are rejected. No extra production synchronization
was added. Clock-boundary time outside the trace anchors is explicitly unlocated.

Across the two unprofiled controls, full-step idle means are1.621/1.678ms and peaks
13.965/12.426ms, with0/180 misses at60Hz. Heavy means are54.926/55.457ms and peaks
174.362/195.027ms, with99/180 misses at60Hz. Both scenes contain113,664 chunks and
229,376 bonds; heavy uses256 projectiles. Initialization, stages and exact budget
counts are in the linked tier report. These are diagnostic controls, not new
candidate speedup experiments or the required600-tick final acceptance campaign.

Cold-restored and continuous gameplay measurements differ materially: the largest
restored idle baseline is59.200ms mean, whereas warm continuous idle is around
1.6ms. Rebuilt disposable caches and initial scene work are part of the cold tick.
Use both workloads; do not mistake cold reconstruction work for recurring gameplay
cost, and do not move work outside the timer to manufacture an optimization.

## Next experiments and reproducibility

The [current transfer census](dataflow.md) records all52 snapshots and warm
checkpoints. Fully idle warm traffic is negligible (~2KB H2D/~1KB D2H), so
transfer reduction promises no meaningful gain there. Active-projectile pre-
impact reads7.741MB D2H, first fracture24.516MB and later debris35.386MB.
Copy/kernel overlap is explicit; these durations are not removable full-step
cost. Ordinary trial mirrors remain necessary for sleep/activity processing.

The [ranked hypotheses](next-ranked-experiments.json) prioritize fragment lifecycle,
anchored/free and size-based solver decomposition, eligible small
component direct solves, compact CPU mirrors and exact-input certificates. Each includes evidence, mechanism, scenarios,
estimated application savings, confidence, cost and support/refutation criteria.
Estimates are hypotheses, not subtraction of profiler time from baseline time.
The N-series now records12/20 completed experiments after N06a rejection; best N13 stays retained.

Use exact commands in [OPTIMIZATION.md](../../../OPTIMIZATION.md). New tools are
`profile-graph-suite.py`, `profile-config-suite.py`, `profile-warm-suite.py`,
`analyze-warm-attribution.py` and `report-attribution-tiers.py`. Sixteen accounting,
classification and representative-selection tests pass. Historical pre-reboot
status is retained in [history-before-reboot.md](history-before-reboot.md).
Private process environments and crash cores are not published or committed.

The isolated N20 CPU-capacity candidate passes16 native behavior commands and
three normal asynchronous memory gates per arm. Matched control demo/probe are
byte-identical to the current baseline. Corrected light and20/20/20 targeted
comparisons pass physical gates. Large restored debris improves38.525ms; the
smaller impact's first regression does not consistently repeat with reversed
order. Warm600 gameplay gains are small/inconclusive, with unchanged deadline
misses. Full52×20/20/20 is queued before any retention decision.
[Complete results, stage costs, peaks and raw pointers](n20-followup.md).

Queue audit: N10 operator caches already exist; N02 intermediate-projection
removal remains rejected by its numerical fixture. Neither is a new queued
optimization. Current follow-ups preserve those conclusions.

Native N20 correctness consumers are now rebuilt from fresh scene/test sources
in `fresh-native/{A,B}`. Earlier linked test artifacts are preserved and were
never executed as qualification. The benchmark demo and plain probe controls
remain byte-identical; fresh native and asynchronous memory gates now pass.

The [physical-trait census](physical-traits.md) covers all52 existing outputs.
Tower64 contains2368 connected chunks (2304 stress unknowns), dense12 has1728
(1584 unknowns), and panel32 has1024 (1020 unknowns). Their cold full-step means
are117.766,33.748 and22.249ms. These are substantial structural workloads,
complementing the many-component cities. The tower
[source-counter audit](tower-source-review.json) covers all26,832 disassembled
instructions, removes4,498 duplicate source correlations, and leaves no SASS
instructions unaccounted for. Barrier and short-scoreboard samples motivate a
separate execution-granularity experiment; they are not speedup percentages.


Counter collection now uses a pause file at capture boundaries, replacing the
old signal-held parents. Completed GPU receipts can be recovered only after
identity, policy, collector, fault, inventory and physical checks. The N20 full
comparison waits for status `paused`, runs alone, then resumes collection on
success. `full52-driver.json` records transitions. The restoration watcher stays
responsible for returning the desktop/server against the original installed SDK.

The [N06a structural pilot](n06a-result.md) is rejected. All233 device functions
match, and native physical/memory checks pass, but dense/tower means rise from
32.106/109.121ms to513.374/2284.911ms. Reduced parallelism overwhelms any barrier
savings. Original size-specialized N06 remains untested; do not repeat this
one-block threshold approach. N15 instead builds distinct anchored/free component
kernels while retaining parallel component scheduling. Its isolated commit is
`dccbe23f0022b2d3b68c66bb97a877ff5e3532a4`; GPU qualification remains pending.
Neither changes the main runtime, installed SDK or retained N13.


A timing-protocol audit found that shorter A-before/A-after processes double the
weight of slower first-use ticks in pooled controls compared with B. The initial
N20 light screen passes all physical gates but is **not qualified timing evidence**.
[All seven first-use measurements and the correction](first-use-bias.json) are
preserved. The replacement screen uses the original40-tick light preset in each
of A-before/B/A-after (120 ticks total), includes every tick, and changes no inputs
or tolerances. A GPU-free orchestration regression verifies equal first-use
weight and selection of the distinct CPU candidate executable. Final full comparisons
use20/20/20; historical10/20/10 physical checks remain valid, while small timing
claims from that protocol must be revisited. Continuous600-tick controls already
use equal process lengths and are unaffected.
