# End-to-end attribution after GPU recovery

**CPU attribution passes all52 scenarios.** The graph-counter expansion is
running with a verified workaround; representative ordinary-kernel expansion
follows it. [Live coverage by all52 scenarios and continuous controls](coverage-tiers.md),
[structured coverage](coverage-tiers.json), [full-step baselines and CPU stages](report.md).
No runtime optimization or speedup is claimed. Physical inputs, ordinary APIs,
sleep, correction limits, runtime modules and tolerances are unchanged.

## Recovery and CPU qualification

The user authorized reversible service/GPU recovery, then rebooted the host at
07:05:39 UTC on2026-09-12. Desktop and persistence services restarted. The GPU
recovered without a driver/toolkit update. The server from the other project
was temporarily stopped; its private restart configuration is retained locally.
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
injection corrupting write remains unproven.

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
at least0.1ms in the matched timeline, then captures the first and slowest observed
invocation at each launch configuration. Extra representatives selected by the
shared invocation filter are counted. This is explicit representative coverage,
not a claim to capture every invocation's counters. Complete timelines retain
every launch; thresholds and all-invocation tools remain available for deeper
investigations. Missing inventories never silently pass.

Sources: [NVIDIA graph profiling and metric limitations](https://docs.nvidia.com/nsight-compute/ProfilingGuide/index.html#graph-profiling),
[NVIDIA invocation/configuration filtering](https://docs.nvidia.com/nsight-compute/NsightComputeCli/index.html#profile),
[official archived collectors](https://developer.download.nvidia.com/compute/cuda/redist/nsight_compute/linux-x86_64/).
These documents describe capabilities, not proof of the precise bugs observed here.

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

The [ranked hypotheses](next-ranked-experiments.json) prioritize fragment lifecycle,
verified unchanged-input equilibrium reuse, direct solves for eligible components,
and compact CPU mirror updates. Each includes evidence, mechanism, scenarios,
estimated application savings, confidence, cost and support/refutation criteria.
Estimates are hypotheses, not subtraction of profiler time from baseline time.
The original N-series remains11/20 and best N13 stays retained.

Use exact commands in [OPTIMIZATION.md](../../../OPTIMIZATION.md). New tools are
`profile-graph-suite.py`, `profile-config-suite.py`, `profile-warm-suite.py`,
`analyze-warm-attribution.py` and `report-attribution-tiers.py`. Eight accounting,
classification and representative-selection tests pass. Historical pre-reboot
status is retained in [history-before-reboot.md](history-before-reboot.md).
Private process environments and crash cores are not published or committed.
