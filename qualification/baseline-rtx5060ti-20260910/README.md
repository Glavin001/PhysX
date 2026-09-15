# RTX 5060 Ti ordinary-API baseline — 10 September 2026

Current implementation, before the new six-channel solver. CUDA 13.4.59, driver 615.71.09, RTX 5060 Ti 16 GB. Source 1155b7ffb60d4d65853f448b00485c21cfd06b99.

Each case has three untraced runs of 600 steps / 10 simulated seconds, plus a separate discarded warm-up and one separate phase capture. Both use 256 buildings, 113,664 chunks and 229,376 bonds. Idle has zero projectiles; bombardment has one simultaneous 256-projectile aerial wave. Ordinary actor API, sleeping on, dt 1/60, correction <=1, stress evaluations <=2, tolerance 1e-5 and iteration cap 8192.

**Diagnostic baseline, not physical-equivalence or isolated performance qualification.** Desktop graphics remained active. Migration failures remain unresolved. No solver settings or engine code changed. The timing campaign used no hardware counters; separate timeline and first-peak counter captures are documented below. Phase captures use CPU scopes and CUDA events.

## Untraced complete-step timings

All values are milliseconds. All steps remain, including the first step. Percentiles use nearest rank. Exceedances use exact 1000/120 and 1000/60 ms thresholds, strictly greater than the deadline. The 8 ms gate is separate; the physical timestep remains 1/60 second.

| Case | Repeat | Min | Mean | p50 | p95 | p99 | Maximum | Peak step | >8 ms | >8.33 ms (120 Hz) | >16.67 ms (60 Hz) |
| --- | ---: | ---: | ---: | ---: | ---: | ---: | ---: | ---: | ---: | ---: | ---: |
| idle-256 | 1 | 1.117 | 1.679 | 1.652 | 1.956 | 2.139 | 15.324 | 0 | 1/600 | 1/600 | 0/600 |
| impacts-256 | 1 | 3.661 | 63.859 | 35.831 | 140.203 | 153.693 | 212.592 | 82 | 519/600 | 519/600 | 519/600 |
| idle-256 | 2 | 1.092 | 1.633 | 1.596 | 2.014 | 2.255 | 16.426 | 0 | 1/600 | 1/600 | 0/600 |
| impacts-256 | 2 | 4.045 | 64.084 | 35.799 | 140.776 | 151.300 | 223.327 | 82 | 519/600 | 519/600 | 519/600 |
| idle-256 | 3 | 0.944 | 1.630 | 1.588 | 1.905 | 2.229 | 15.398 | 0 | 1/600 | 1/600 | 0/600 |
| impacts-256 | 3 | 3.801 | 64.192 | 35.493 | 141.803 | 152.326 | 195.116 | 82 | 519/600 | 519/600 | 519/600 |

Across all three repeats per case (1,800 complete steps), the 120 Hz budget is
exceeded by 3 idle steps (0.17%) and 1,557 bombardment steps (86.50%). The 60 Hz
budget is exceeded by 0 idle steps (0.00%) and 1,557 bombardment steps (86.50%).
All startup steps remain included; these are the existing baseline captures,
not a new timing campaign on later runtime changes.

## Startup, aftermath and physical work

Initialization is separate from the complete-step timer. Steps 1–599 and the final two seconds are supplementary windows; they do not replace the all-step maximum.

| Case | Repeat | Initialization ms | Step 0 ms | Steps 1–599 max ms | Last 2 s mean ms | Broken bonds | Peak clusters | Corrected steps |
| --- | ---: | ---: | ---: | ---: | ---: | ---: | ---: | ---: |
| idle-256 | 1 | 2272.395 | 15.324 | 2.547 | 1.563 | 0 | 256 | 0 |
| impacts-256 | 1 | 2605.585 | 74.787 | 212.592 | 23.144 | 62,666 | 14,795 | 235 |
| idle-256 | 2 | 2277.864 | 16.426 | 2.748 | 1.484 | 0 | 256 | 0 |
| impacts-256 | 2 | 2366.766 | 57.894 | 223.327 | 23.257 | 62,666 | 14,795 | 235 |
| idle-256 | 3 | 2307.734 | 15.398 | 5.000 | 1.568 | 0 | 256 | 0 |
| impacts-256 | 3 | 2339.539 | 71.748 | 195.116 | 23.999 | 62,666 | 14,795 | 235 |

All 3,600 measured steps report convergence, zero correction-status error, and compliance with the correction/evaluation caps. Idle remained pristine. These checks do not replace frozen penetration, pose, momentum or sanitizer gates.

## Untraced peak state

| Case | Repeat | Step | Commands ms | Simulate/fetch ms | Completion ms | Clusters | Awake bodies | Contact loads | New broken bonds | Max component iterations | Stress passes |
| --- | ---: | ---: | ---: | ---: | ---: | ---: | ---: | ---: | ---: | ---: | ---: |
| idle-256 | 1 | 0 | 0.002 | 15.006 | 0.316 | 256 | 0 | 0 | 0 | 45 | 1 |
| impacts-256 | 1 | 82 | 0.001 | 212.215 | 0.377 | 5,204 | 5,376 | 39,499 | 28,596 | 149 | 2 |
| idle-256 | 2 | 0 | 0.003 | 16.053 | 0.369 | 256 | 0 | 0 | 0 | 45 | 1 |
| impacts-256 | 2 | 82 | 0.001 | 223.025 | 0.301 | 5,204 | 5,376 | 39,499 | 28,596 | 149 | 2 |
| idle-256 | 3 | 0 | 0.003 | 15.089 | 0.306 | 256 | 0 | 0 | 0 | 45 | 1 |
| impacts-256 | 3 | 82 | 0.000 | 194.860 | 0.256 | 5,204 | 5,376 | 39,499 | 28,596 | 149 | 2 |

Contact loads are the recorded contacts_frame counter, not unique contact pairs. Maximum component iterations is not summed solver work. Stress topology membership is not a count of active iteration visits.

## Separate instrumented peak attribution

These are different executions from the timing table. The wall partitions below are disjoint portions of simulate/fetch. CUDA intervals overlap those wall partitions and must not be added to them. They do not establish hardware utilization or kernel bottlenecks.

### idle-256, step 0

| Wall interval | ms |
| --- | ---: |
| Wait for GPU destruction result | 10.758 |
| Submit contact loads and destruction | 2.813 |
| Trial physics and remaining scene tasks | 2.331 |
| Checkpoint moving-body state | 0.109 |

CUDA intervals at this same instrumented step: allocationAndPreparation 0.016 ms, commitAndStressTopology 0.088 ms, contactLoads 0.146 ms, materials 0.149 ms, stress 12.872 ms, topologyAndCandidates 0.069 ms.

### impacts-256, step 82

| Wall interval | ms |
| --- | ---: |
| Resimulate changed interaction | 87.809 |
| Wait for GPU destruction result | 58.710 |
| Construct fragment compatibility objects | 39.511 |
| Trial physics and remaining scene tasks | 20.264 |
| Other shape migration work | 18.321 |
| Accept corrected step | 7.720 |
| Finalize GPU state and CPU physical properties | 7.291 |
| Publish final actor and query ownership | 6.917 |
| Validate fragment owners and shape identities | 4.374 |
| Retire old-owner contact managers | 2.800 |
| Grow native motion address capacity | 2.581 |
| Update narrow-phase ownership mirror | 2.175 |
| Submit contact loads and destruction | 1.797 |
| Update shape/actor links and query-bound membership | 1.473 |
| Other ownership bridge work | 1.218 |
| Activate fragment scheduler metadata | 1.215 |
| Mark changed collision filtering | 0.806 |
| Observe GPU-selected fragment requests | 0.743 |
| Rewind and install fractured motion | 0.590 |
| Validate GPU preparation verdicts | 0.286 |
| Update fragment compatibility metadata | 0.186 |
| Other destruction completion bookkeeping | 0.105 |

CUDA intervals at this same instrumented step: allocationAndPreparation 0.032 ms, allocationAndPreparationRetry 0.510 ms, commitAndStressTopology 0.094 ms, contactLoads 0.437 ms, finalSplitFragments 0.018 ms, finalSplitOwners 0.015 ms, finalSplitState 0.033 ms, installFragments 0.136 ms, installOwners 0.121 ms, materials 0.239 ms, rewindState 0.044 ms, stress 57.983 ms, topologyAndCandidates 1.408 ms.

## Evidence and reproduction

- [Exact input configuration](config.json), [build receipt](baseline-receipt.json), [machine-readable stats](stats.json), [capture-tool changes](capture-tools.patch).
- Raw logs, GPU samples, per-process loaded-module maps/hashes, untraced rows and phase captures: `out/baseline-20260910-ordinary-sleeping/capture/`.
- Generated detailed report: `out/baseline-20260910-ordinary-sleeping/capture/report/report.md`.
- Capture runner exit 2 indicates the completed campaign failed timing/duration gates; it is not a simulation crash.

```bash
.toolchains/build-env/bin/python tools/scripts/run-destruction-timing.py out/NEW-BASELINE --config qualification/baseline-rtx5060ti-20260910/config.json --trials 3 --seconds 10 --gate-only --phase-scopes --allow-existing-graphics
```

GPU execution requires access outside the restricted sandbox. The graphics option permits only the recorded pre-existing graphics-only identities, retains every process sample, and rejects competing compute processes. No desktop/service shutdown or clock change occurred.

Capture/report tests: 35 passed. No production rebuild was necessary: every library matched the SDK attestation, whose simulation source contents match the current checkout. The older attestation revision reflects the pre-commit migration build; changed attested files were documentation only.

## Hardware-counter findings and profiler limits

**Working later-peak capture:** [direct CUPTI PM sampling with a same-run kernel
timeline](../pm-sampling-rtx5060ti-20260910/README.md) now completes the 180-step
scene and supplies memory, residency and instruction counters. The Nsight
Compute failure described below remains unresolved; FP64 replay is not qualified.

**Follow-up:** [conditional-graph investigation](nsight-investigation/README.md)
identifies execution of branches that should be skipped under Nsight attachment,
including with counter collection disabled. This precedes the reported failure.
The first-peak numbers below are indicative samples, not a verified replay of
identical production state. The underlying integration/profiler cause remains
unresolved; production binaries and physical gates were preserved.

Both CUDA optimization guides were read. Work avoidance, ownership and dependency analysis remain ahead of instruction tuning; hardware counters supplement that analysis.

A separate 180-step / 3-simulated-second Nsight Systems capture completed on the same 256-building, 113,664-chunk, 229,376-bond, 256-shot ordinary/sleeping inputs. Hardware tracing was used. All 267 reported stress evaluations match 267 `componentStressSolve` launches. Nsight warned that not all NVTX events might have been collected; launch selection uses the complete matching kernel/evaluation sequence, not NVTX coverage.

The timeline's complete-step peak was step 82. Trial/correction stress kernels there took 23.022/33.966 ms. Its largest individual stress kernel was 47.055 ms at step 108, trial evaluation (zero-based matching launch 130). These are traced kernel times, not untraced complete-step measurements. Across the entire short trace, stress accounted for 7,170.414 ms of summed kernel durations; this is device work, not an additive wall-time partition.

Successful focused Nsight Compute capture: step 82 trial, matching launch 82, `componentStressSolve`, 72 blocks × 256 threads, 110 registers/thread, 576 bytes static shared/block, 36 SMs. One launch, 21 kernel-replay passes, cache flushing enabled, clock control disabled, graph-node profiling. Nsight intentionally terminates its own target immediately after collecting this launch. This is a kernel diagnostic, not a completed physics run.

| Counter | First-peak trial |
| --- | ---: |
| Profiler kernel duration | 22.939 ms |
| FP64 pipeline utilization, elapsed-cycle basis | 60.92% |
| DRAM throughput, profiler peak basis | 2.32% |
| L2 hit rate | 99.62% |
| Achieved occupancy | 33.33% |
| Eligible warps per scheduler | 0.0995 |
| Cycles with an issuing scheduler | 8.25% |
| Reported local spilling requests | 0 |

The register limit permits two resident blocks/SM. The dominant sampled stall category is short scoreboard; barriers and long scoreboard also contribute. There is no source-PC attribution yet, and aggregate stall labels do not prove one particular source operation is responsible. The profiler's estimated speedups are not adopted as forecasts.

**Interpretation:** investigate repeated FP64 preconditioner/operator work and dependency/collective costs, while preserving the existing accurate residual and convergence requirements. High L2 reuse and low DRAM throughput do not support prioritizing a DRAM-bandwidth rewrite from this sample. Reducing precision or forcing occupancy is not justified by these counters alone. On the whole-step path, fragment compatibility creation, shape migration/publication and correction remain separate high-exposure targets.

**Preserved failures:** an initial two-launch kernel-replay capture collected the trial kernel but the subsequent native step failed with status 1288 (correction required + native body allocation + collision binding preparation). A fresh-process application-replay attempt also failed there. A later-launch attempt targeting ordinal 130 failed at step 82 before collecting its target, so the issue is not established as replay-memory restoration specifically. Cause is unresolved. No production workaround, synchronization change, suppression or numerical change was introduced. The completed untraced and Systems trajectories are separate evidence. Later-peak counters require diagnosing the profiler interaction or a validated standalone replay of captured production inputs.

See [counter evidence and exact commands](counter-evidence.json), [full counter details](first-peak-counters.txt), [raw metrics](first-peak-metrics.csv), and [kernel-to-step selection](kernel-selection.json). Raw `.nsys-rep`, `.sqlite`, `.ncu-repz`, attempt logs, module maps and GPU samples remain under `out/baseline-20260910-ordinary-sleeping/`. `profile_capture.py` and `replay_target.py` preserve the diagnostic drivers; use a fresh output directory for new attempts.

Sampled total device memory, including the existing desktop, peaked at 5,493 MiB in idle and 7,553 MiB during bombardment in each measured repeat. These roughly quarter-second samples can miss transient peaks and are not allocator high-water marks.

## Next optimization investigations

1. Resolve the counter-profiler ownership interaction or create a verified standalone production-kernel replay for the later solve before generalizing the first-peak counters.
2. Use the existing work-capture instrumentation to locate FP64 work, collectives and dependency stalls within the preconditioner/operator; screen algorithmic work reduction before repeating rejected precision or occupancy tweaks.
3. Re-review GPU fragment registration and accepted publication against the measured first-fracture lifecycle exposure. Keep improvements to solver math and ownership as separate experiments.
4. Establish event-driven exact idle reuse: all measured idle runs remained intact, yet recurring complete-step work is approximately 1.6 ms despite zero final-step stress iterations.

No solver implementation or optimization was applied in this baseline task. All launched jobs have completed or ended as explicitly recorded failed profiler attempts.
