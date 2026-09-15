# Starting point and retained integrated result

The ten-experiment batch is complete. **E12 (E3 factor reuse + E10 block-Jacobi) is retained in source and local runtime/test binaries.** The installed SDK remains original A. This is a verified relative application improvement on the recorded shared GPU; full physical-equivalence and endurance qualification remain open.

## What the numbers measure

`complete_step_ms` is the acceptance metric: CPU commands/preparation, integrated PhysX/destruction execution, transfers, synchronization, correction and required publication/completion. Initialization is separate and also included in the reported total. Rendering/audit/report I/O is outside simulation work. `physics_step_ms` contains destruction; it does not isolate stock PhysX.

Fixed 256 buildings, 113,664 chunks, 229,376 bonds, dt 1/60, ordinary API, sleeping on. Idle has 0 shots; heavy has one 256-shot wave. Keep material, numerical limits and at most one correction/two physics and stress evaluations unchanged. All measured steps converge.

## Where we started

The first retained change, E3, reduced matched 600-step heavy means from original A 66.696/66.538 ms to 63.841 ms: **2.697 ms (4.05%)** against the closer control. Idle confirmation was 1.617 ms versus 1.595/1.628 ms; no repeated idle regression. Heavy maxima overlapped (A 204.578–246.487 ms; E3 203.192–235.153 ms), with 519/600 deadline misses (86.5%) per run. [Full E3 evidence](E3.md).

The final experiment below compares **E12 against E3**, in a fresh matched cohort. Do not add percentages or treat the earlier original-A cohort as a simultaneous final control.

## Where we are now: repeated unprofiled complete steps

Three 600-step repeats per arm/scenario, bracketed E3-before/E12/E3-after. Both arms share the recorded existing server and graphics; no isolated-GPU claim.

| Scenario | Arm | Mean step ms | Per-run peaks ms | Peak indices | >8 ms | >120 Hz | >60 Hz | Initialization ms | Init + 600 steps ms |
|---|---|---:|---:|---|---|---|---|---:|---:|
| idle-256 | E3 A-before | 1.539351 | 15.801–16.902 | 0,0,0 | 3/1800 (0.167%) | 3/1800 (0.167%) | 1/1800 (0.056%) | 2266.667 | 3190.278 |
| idle-256 | E12 | 1.764769 | 15.080–16.247 | 0,0,0 | 3/1800 (0.167%) | 3/1800 (0.167%) | 0/1800 (0.000%) | 2251.705 | 3310.567 |
| idle-256 | E3 A-after | 1.585178 | 16.375–17.296 | 0,0,0 | 3/1800 (0.167%) | 3/1800 (0.167%) | 1/1800 (0.056%) | 2315.211 | 3266.318 |
| impacts-256 | E3 A-before | 63.364518 | 191.799–227.209 | 82,82,82 | 1557/1800 (86.500%) | 1557/1800 (86.500%) | 1557/1800 (86.500%) | 2365.118 | 40383.828 |
| impacts-256 | E12 | 62.312086 | 220.138–222.825 | 82,82,82 | 1557/1800 (86.500%) | 1557/1800 (86.500%) | 1557/1800 (86.500%) | 2317.788 | 39705.040 |
| impacts-256 | E3 A-after | 63.198525 | 211.720–218.145 | 82,82,82 | 1557/1800 (86.500%) | 1557/1800 (86.500%) | 1557/1800 (86.500%) | 2290.202 | 40209.317 |

E12 saves **0.886 ms/step (1.40%) beyond E3** against the closer E3-after control. The full heavy run including initialization saves 504.278 ms against that control. This is a mean/runtime gain; **no peak or deadline improvement is established**. Every heavy run still misses 8 ms, exact 120 Hz and exact 60 Hz on 519/600 steps (86.5%).

The initial idle means looked slower. Five additional 600-step repeats per arm do not reproduce that difference:

| Idle confirmation | Mean ms | Peak range ms | >8 ms | >120 Hz | >60 Hz | Init + 600 steps ms |
|---|---:|---:|---|---|---|---:|
| E3 A-before | 1.597673 | 15.049–16.979 | 5/3000 (0.167%) | 5/3000 (0.167%) | 3/3000 (0.100%) | 3244.486 |
| E12 | 1.623970 | 15.318–16.717 | 5/3000 (0.167%) | 5/3000 (0.167%) | 1/3000 (0.033%) | 3321.944 |
| E3 A-after | 1.640409 | 16.116–17.304 | 5/3000 (0.167%) | 5/3000 (0.167%) | 3/3000 (0.100%) | 3300.708 |

No repeatable idle improvement or regression is established. Initialization is retained, and no separate startup win is claimed. Exact 120/60 Hz thresholds are 1000/120 and 1000/60 ms; all counts use strict exceedance.

## Stage attribution: normal four-worker scheduling

Separate single 180-step instrumented runs explain costs; they do not replace repeated unprofiled 600-step acceptance. Values are host wall intervals including GPU dependencies, so GPU kernel times must not be added to them. Groups partition the traced work approximately; the signed closure residual reports scope/bookend mismatch. They do not isolate stock PhysX from destruction.

| Scenario / host group | E3 mean ms | E12 mean ms | E3 peak-step ms | E12 peak-step ms |
|---|---:|---:|---:|---:|
| idle-256: Destruction submission / completion dependency | 0.588 | 0.560 | 15.184 | 12.355 |
| idle-256: Correction / repeated physics and destruction | 0.000 | 0.000 | 0.000 | 0.000 |
| idle-256: Fragment ownership and registration | 0.019 | 0.018 | 0.040 | 0.037 |
| idle-256: Accepted-state publication | 0.000 | 0.000 | 0.000 | 0.000 |
| idle-256: Trial physics and remaining scene work | 1.177 | 1.140 | 1.763 | 2.331 |
| idle-256: Checkpoint | 0.053 | 0.054 | 0.104 | 0.216 |
| idle-256: Commands | 0.001 | 0.000 | 0.003 | 0.003 |
| idle-256: Mandatory completion | 0.156 | 0.233 | 0.324 | 0.336 |
| idle-256: signed closure residual | -0.005 | -0.006 | -0.007 | -0.006 |
| idle-256: complete instrumented step | 1.988 | 1.998 | 17.410 | 15.272 |
| impacts-256: Destruction submission / completion dependency | 45.360 | 42.897 | 64.385 | 86.951 |
| impacts-256: Correction / repeated physics and destruction | 8.407 | 8.424 | 88.643 | 45.997 |
| impacts-256: Fragment ownership and registration | 1.777 | 1.750 | 51.012 | 20.503 |
| impacts-256: Accepted-state publication | 1.706 | 1.710 | 9.687 | 5.975 |
| impacts-256: Trial physics and remaining scene work | 13.534 | 13.504 | 13.589 | 34.066 |
| impacts-256: Checkpoint | 0.069 | 0.067 | 0.043 | 0.061 |
| impacts-256: Commands | 0.269 | 0.280 | 0.000 | 0.000 |
| impacts-256: Mandatory completion | 0.308 | 0.292 | 0.326 | 0.326 |
| impacts-256: signed closure residual | -0.006 | -0.007 | -0.004 | -0.007 |
| impacts-256: complete instrumented step | 71.423 | 68.917 | 227.681 | 193.873 |

Peak indices: idle 0 in both arms; heavy 82 for E3 and 103 for E12. Peak columns therefore describe each capture's own worst step, not identical-step speedups. Matching physical histories pass in both scenarios; iteration counts may vary. [Stage data](stage-summary-E12.json). Raw: `out/optimization-20260910/E12-composition/production-phases/`.

## Same-step stage checkpoints

These single-run instrumented checkpoints align the work. They are diagnostic, not a repeated peak-speedup claim. All values are milliseconds.

| Step | Arm | Full step | Destruction dependency | Correction | Registration | Publication | Trial/scene work |
|---|---|---:|---:|---:|---:|---:|---:|
| 82 | E3 | 227.681 | 64.385 | 88.643 | 51.012 | 9.687 | 13.589 |
| 82 | E12 | 190.905 | 59.140 | 70.364 | 39.017 | 11.438 | 10.605 |
| 103 | E3 | 195.856 | 90.645 | 45.870 | 20.845 | 5.500 | 32.614 |
| 103 | E12 | 193.873 | 86.951 | 45.997 | 20.503 | 5.975 | 34.066 |
| 108 | E3 | 135.425 | 93.816 | 13.849 | 1.541 | 3.972 | 21.795 |
| 108 | E12 | 127.035 | 87.640 | 14.031 | 1.214 | 3.194 | 20.507 |

Checkpoint, command, mandatory completion and signed timestamp-bookend residual remain separately recorded in `out/optimization-20260910/E12-composition/production-phases/fixed-stage-checkpoints.json`.

## Systems and targeted kernel evidence

The separate inline-dispatch profiler build avoids the known cross-thread conditional-graph attachment defect. Its CPU times cannot represent production scheduling. Both new diagnostic runs finish 180 steps with byte-identical recorded poses and matching checked physical histories against E3; iteration counts differ.

| GPU stage, same 180-step diagnostic workload | E3 total ms | E12 total ms |
|---|---:|---:|
| Iterative component stress, 267 launches | 7803.615 | 7348.232 |
| Fine factor construction, 157 launches | 36.633 | 37.061 |
| Motion-mode construction, 157 launches | 302.866 | 304.244 |

Iterative stress remains **82.9% of aggregate GPU kernel duration**. These
intervals overlap host waits and must not be added to complete-step time.
Selected Nsight Compute stress launch 130 at step 108: **45.674 ms**, 109
registers/thread, 32.00% achieved occupancy and 33.44% elapsed FP64 activity.
Collection used 25 replay passes, cache flushing and unlocked clocks. Kernel
counters explain the mechanism; the repeated full-step result establishes the gain.

## Quality, failures and next work

All three numerical tests, unchanged factor-lifetime/block-inverse oracles, 3D memory/init/sync sanitizers and native wall invariants pass. Four native wall outputs match A byte-for-byte; full-suite checked histories match. Historical topology-golden, migration and native correction memory findings remain unresolved, not waived. There is no deployment or full fidelity/endurance claim.

Ten experiments are recorded with isolated commits and retained evidence. Barrier deletion, deferred inverse setup and residual fusion failed timing; actor batching and inline dispatch failed memory qualification; cooperative rows regressed strongly. Size-priority scheduling improved means but worsened measured peaks and was rejected for retention. Factor reuse and block-Jacobi compose into the retained E12.

Next ranked: component-specific preconditioner choice; diagnose the size-ordering peak regression before another scheduling policy; resume validated CPU binding reuse only after baseline correction-memory diagnosis. Stress dominates sustained GPU cost, while correction and fragment registration remain major full-step peak targets. [Ranked hypotheses](queue.json), [E12 experiment](E12.md), [workflow and commands](../../OPTIMIZATION.md).

Raw repeated results: `out/optimization-20260910/E12-shared-ab-600/measurements.json`, `E12-idle-confirm/measurements.json`. Final source/module selection: `out/optimization-20260910/final-selection.json`.
