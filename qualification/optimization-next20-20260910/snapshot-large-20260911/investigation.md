# Large snapshot coverage and failures exposed

The catalog adds 24 captured native city states: 25, 64 and 256 buildings,
with 11,100 / 28,416 / 113,664 chunks and 22,400 / 57,344 / 229,376 bonds.
At each scale the eight states are intact idle, airborne shots, initial impact,
immediate post-impact, cascading fracture, later loaded fragmentation,
three-second debris and ten-second debris. Source inputs are real native demo
trajectories using the frozen ordinary A/B configuration. The last state is
not asserted asleep. The largest inputs contain 10,905, 12,214 and 14,795
motion clusters at the later three captures. Authored chunks, motion clusters
and stress islands are distinct counts.

All raw evidence is in `out/snapshot-large-20260911/`. `capture-*` holds the
six source trajectories and 24 four-file snapshots. The source benchmark has
an opt-in `PHYSX_SNAPSHOT_STEPS` capture hook outside its complete-step timer.
Every authored shape must appear in the paired PhysX collection; snapshots use
the public destruction export API. Application capacity/contact-preparation
settings and source metadata are hashed sidecars. Input hashes remain fixed
across all replay attempts. No projectile is spawned after these saved inputs.

## Correction command-history capacity

The initial two-repeat screen passed 14/24 cases. Six later cases rejected
correction preparation with stage error 2056 (8 + 2048); the preparation receipt
reported error 64 despite a valid generation 1, zero-error, zero-command original
history. Corrected checkpoints contained newly born fragment IDs beyond the
original command stamp allocation. Continuing scene-query publication after
that failure also crashed; the saved GDB trace records it. These are failed
attempts, not timings to compare against a successful candidate.

`extendCorrectionCommandHistory` now extends stamp storage to the corrected
checkpoint's addressable count, copies every existing command stamp, and zeroes
only the new suffix. Both graph and explicit preparation consume the refreshed
pointer/capacity. New slots had no original command; original loads and invalid
receipts still reject. This rebuilds transient bookkeeping; it does not add
execution history to the physical snapshot format or change precision/physics.

The exact 11,100-chunk/1,282-cluster failing input subsequently completed both
restored ticks: 100 newly broken bonds, one correction and two stress passes.
The new regression grows corrected checkpoint storage with an existing parent
command and verifies the load guard survives; corrupt original receipts still
reject without changing native motion. All 29 native correction cases pass
(`native-correction-growth/`). The original 28 snapshot cases pass again
(`roundtrip-regressions/`, 560 checked continuation ticks). The former runtime
and a focused patch are retained in `pre-fix-artifacts/` and
`command-history-fix.patch`. Private ABI remains V20 / snapshot schema 7.

## Reference-world GPU memory

The first 20-repeat campaign (`file-*`) kept its reference simulation alive while
running the next restore. This exhausted GPU memory in two heavily fragmented
113,664-chunk cases when PhysX requested another 1 GiB contact solver buffer.
The scene itself had already completed one tick; the duplicate live reference
world was the unnecessary allocation. No foreign GPU job was stopped and no
scene capacity, contact work or chunk count was reduced.

The final harness records reference poses/velocities/mass/inertia/COM/roles on
the CPU, plus GPU-read bond health, topology and damage, then destroys that
simulation world before the next restore. One actual simulation world and the
empty context template remain. Comparison readbacks happen after the timed tick.
The one-world engine-step screen is `single-*`. The final application-complete timing campaign is `complete-*`; do not mix these timing cohorts.
Both failed-harness logs and their exact module/input hashes remain intact.

## Repeatability and physical qualification

A completed tick must preserve exact physical state on import, increment the
frame once, converge, respect one correction/two stress evaluations, and never
heal bond damage. Every repeat then compares motion at the existing bounds,
exact topology, damage and bond health. Health-only comparison failures are
retained for all 20 samples and return a nonzero process status; the gate is not
relaxed to obtain timings. The CPU-reference validator checks topology before
health, so a health-only failure does not mask a topology failure. Missing motion
comparisons have an explicit flag and numeric -1 sentinel.

Some bond-health differences are floating-point-scale, but their physical
significance and long-term accumulation are not qualified merely from size.
The report also records uninterrupted source verdicts separately. For example,
the 256-building source's first-impact tick broke 28,596 bonds and produced 5,204
clusters; its independently restored tick breaks 34,802 and produces 5,417.
Independent-restore repeatability does not establish equivalence to the warm
source trajectory. The user withdrew the exact execution-continuation
requirement; these differences remain material diagnostic evidence, not hidden
performance gains or proof of physical equivalence.

Cold restoration rebuilds solver/contact caches. Its first tick and the ordinary
warm gameplay trajectory are different workloads. Keep both for optimization;
do not credit relocating setup into import as a free complete-step speedup.
Restore and complete-tick costs, spread, budget misses and active-work counts
are all reported. Bootstrap intervals describe these samples under an
exchangeability assumption, not systematic shared-GPU interference. First/last
half means remain in JSON to expose drift. No optimization experiment is credited
and no new application speedup or migration-quality qualification is claimed.
Retained N13 and the installed original A SDK remain untouched.


## Application completion boundary

The earlier file replay timer stopped after `simulate/fetchResults`. The native
application's complete-step contract additionally synchronizes its destruction
ready event and reads the two compact topology/stress status receipts. The final
`complete-*` campaign includes these operations inside the timer, with disjoint
command, integrated simulate/fetch and completion intervals. Large object/health
observation and comparison remain outside the timer. The preceding `file-*` and
`single-*` durations are preserved engine-step diagnostics, not final
application-complete measurements. All final per-tick and per-run durations use
monotonic clocks; no samples are discarded as warmup. The independent GPU
physical-state and numerical checks are unchanged.

## Memory validation and frozen wall gate

The final one-world probe's `city25-initial-impact` memcheck fails before it
produces a timed sample: 114 errors, starting in `root`/`connect` at
`PxgDestructionTopology.cu:65/79`, during topology transaction preparation.
Compute Sanitizer reports invalid global atomic accesses, including addresses
it also describes as inside the nearest 44,400-byte allocation. The native step
subsequently rejects. This is not a successful memory qualification.

A matched control uses the **same final probe and exact snapshot files**, with
the saved pre-command-history-fix runtime and identical GPU activity module.
It also fails at the same topology atomic sites (145 errors). The new stamp
growth fix therefore did not introduce this observed failure. These two captures
do not identify the underlying cause, establish a sanitizer exemption, or prove
equivalence to any older memory finding. Raw logs and exact loaded hashes:
`mem-city25-initial-impact/` and `mem-control-city25-initial-impact/`.
Plain replay success is reported separately; large-case memory qualification
remains open and must precede accepting performance changes on these fixtures.

The required 600-step ordinary/sleeping through-wall regression completes and
passes the invariant subset: both wall openings, projectile clearance, all
stress steps converged, correction cap, 400 supported / 44 detached chunks,
182 broken bonds and 39 final clusters. Its full historical frozen identity
gate still fails (`wall-regression.log`); this is not a full regression pass.
The separately named `wall/invariants.json` records only the invariant subset.
These results match the previously recorded migration topology counts; no
historical physical-equivalence gap is waived.

## Diagnostic leads, not exemptions

Research found a [reported CUDA graph atomic/allocation tracking failure](https://forums.developer.nvidia.com/t/compute-sanitizer-and-cuda-graph-false-positives/373484)
and a [Warp conditional-graph allocation reproducer](https://github.com/NVIDIA/warp/issues/1406).
Both discuss recently allocated asynchronous storage and synchronization controls.
Our topology uses ordinary `cudaMalloc` and synchronizes its initialization, so
those reports do not establish the cause of this failure. No error suppression,
tool downgrade or production synchronization workaround is justified from them.

The repository already has an isolated inline-dispatcher control for a separately
established Nsight cross-thread conditional-graph problem. The diagnostic builder
now accepts the snapshot target as well. This permits testing the same captured
input with graph construction and execution on one CPU thread. Its timings
cannot replace ordinary four-worker application timings; a passing diagnostic
would narrow the failure, not qualify the production scheduler by itself.

The inline native control **also fails** at the same atomic sites (111 memcheck
errors, `mem-inline-city25-initial-impact/`). Single-thread graph construction
and execution therefore do not remove this failure; do not reuse the earlier
Nsight diagnosis as its explanation.

A standalone integer union/flatten diagnostic with synchronous allocations,
11,100 nodes and 22,400 edges passes direct launch, a flat graph, one conditional
level and two nested conditional levels. Each mode passes five independent
resets both plain and under memcheck (all four memchecks report zero errors).
Raw source, build and run evidence: `topology-repro/`. This rules out the simple
claim that the integer union operation or nested IF nodes alone necessarily
trigger the failure. It does not qualify their use in the integrated lifetime.

The existing `destruction_topology_test` was rebuilt from the current topology
source and also passes plain and memcheck with zero errors. Its cases include
100,000 chunks / 200,000 bonds, candidate replacement, exact singleton mass and
inertia checks, stable slots and randomized CPU graph equivalence. This further
narrows the problem to the native integration or its instrumentation, rather
than a failure reproduced by the production topology primitive alone. Receipts
and logs: `topology-repro/native-topology-*`.

Finally, the original 25-building native demo was run through the first-impact
interval under memcheck, **with no export or restore at all**. It also fails in
`root`/`connect` during transaction preparation (273 errors). This demonstrates
that restoration is not required to trigger the native failure. The standalone
production primitive passes while both ordinary native execution and restored
native execution fail under the tool. The remaining diagnosis is native
integration/lifetime or its instrumentation; the evidence does not yet choose
between them. Raw: `mem-uninterrupted-city25-impact/`, including the exact
83-step command, module hashes and the failed process receipt. Its buffered
frame file is incomplete and must not be treated as an exact failure-step label.

A final diagnostic uses the documented
[`NV_COMPUTE_SANITIZER_SHARED_ADDRESSING_SUPPORT=none`](https://docs.nvidia.com/compute-sanitizer/ComputeSanitizer/index.html#environment-variables)
setting. It still fails, now with CUDA illegal-address error 700 at completion
and without the precise atomic attribution (`mem-addressing-city25-impact/`).
This is neither a fix nor a qualification; retain the default instrumentation.
The setting is isolated to that failed diagnostic process and is not added to
the benchmark or correctness commands.

## Final measured campaign and readiness

The `complete-*` campaign produces all 480 requested ticks: 24 native snapshots,
20 independent restores each. All samples pass convergence, correction-cap,
material-monotonicity and finite-state checks. All observed motion differences
are zero and topology/mass/inertia/COM comparisons pass. Fifteen cases pass
the exact repeatability gate in this campaign; nine retain bond-health-only
differences, at most 0.000006079673767. No tolerance was changed.
`city25-fragmented-loaded` passes this campaign but failed exact health in the
earlier `single-*` campaign; do not turn a passing cohort into a claim of
unconditional determinism. Fourteen cases pass both cohorts' strict gates.

Summed replay harness time is 1,020.64 seconds (about 17 minutes). The measured
ticks account for 54.46 seconds, restoration for 551.07 seconds, and context/
process setup, validation, teardown and other harness work for 415.12 seconds.
**Restoration and validation are excluded from every `complete_step_ms`.**
Measured commands, integrated simulate/fetch and mandatory completion sum to
each full tick; a separate record audit verifies that equality, all 480 sample
counts, fixed input hashes and matching frozen probe/runtime hashes.
The audit is `final-measurement-verification.json`, not a physical or memory
qualification. All timings remain shared-GPU diagnostics, not speedup claims.

The suite is usable for investigating large workloads, but is **not yet fully
qualified as the optimization acceptance gate**. Resolve the native memory
finding and establish a defensible physical-quality treatment of the health
variance and restored/uninterrupted verdict differences. Exact continuation
through discarded caches is not reinstated as a requirement. Preserve both
fresh-restored and continuous warm tests to demonstrate real application gains.
Improving import/teardown speed later can shorten the harness; it cannot be
credited as a faster simulation tick.

## Compile-time instrumentation control

An isolated runtime compiled the entire topology CUDA translation unit with
CUDA 13.4 `-fdevice-sanitize=memcheck`, using the same generated optimization
flags, other object files and GPU activity module. This follows the installed
tool documentation's translation-unit hybrid instrumentation support, without
mixing instrumented and uninstrumented functions within that compilation unit.
Production runtime binaries were not replaced. Build commands and hashes are
in `out/snapshot-large-20260911/compile-memcheck/`.

The same two-repeat initial-impact input still fails before producing a timed
sample (`mem-compile-city25-impact/`, 6,817 findings). Its first reported access
is now `captureClusterMotion` reading the accepted topology status at offset 8
inside a 24-byte allocation, again described as out of bounds. Changing the
instrumentation changes the first observed site but does not fix or qualify the
run. This is evidence against treating a simple atomic rewrite as an established
solution. Native integration/lifetime and instrumentation remain competing
explanations; no suppression or tolerance change is accepted.
