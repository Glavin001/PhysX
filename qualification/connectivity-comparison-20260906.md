# GPU connectivity ownership: matched comparison

The opt-in path uses the existing GPU component graph as solver connectivity and skips CPU path searches and island splitting. CPU actor/contact registration and constraint partitioning remain. Sleeping and unsupported scenes retain the existing path. One correction per step and physical settings are unchanged.

Campaign: `out/connectivity-comparison-20260906`. Timing tables exclude the first 60 steps of each run. Trial 0 uses CUPTI concurrent activity tracing; the remaining trials are untraced. Each run advances 12 simulated seconds. This is a bounded comparison, not the full 60-second/five-trial scale qualification.

Both modes include the fragment-readiness fix `6a3ac3f9`; earlier captures without it are not matched performance baselines. Validation evidence is recorded separately in `qualification/connectivity-validation-20260906.json`.

## Untraced step times

| Workload | Chunks / bonds | CPU-owned mean ms | GPU-owned mean ms | Speed ratio | GPU-owned min / p95 / max ms | GPU-owned missed deadlines |
|---|---:|---:|---:|---:|---:|---:|
| idle g16 | 113,664 / 229,376 | 0.472 | 0.466 | 1.01× | 0.424 / 0.514 / 0.570 | 0/1320 |
| single-impact g16† | 113,664 / 229,376 | 3.909 | 2.923 | 1.34×† | 0.922 / 6.813 / 25.209 | 4/1320 |
| burst g1 | 444 / 896 | 1.178 | 1.166 | 1.01× | 0.490 / 1.319 / 9.092 | 0/1320 |
| burst g4 | 7,104 / 14,336 | 2.692 | 2.349 | 1.15× | 0.518 / 4.936 / 10.279 | 0/1320 |
| burst g8 | 28,416 / 57,344 | 8.587 | 7.374 | 1.16× | 0.592 / 15.922 / 29.374 | 39/1320 |

† single-impact g16: CPU-owned runs broke [1524, 3092] bonds; GPU-owned runs broke [1524, 1524]. The displayed ratio includes different realized destruction work and is **not an attributable optimization speedup**. No run was discarded.

## Traced phase costs

Each cell is CPU-owned → GPU-owned. CPU values are exclusive core-ms; concurrent GPU times use interval unions. These columns cannot be added together as elapsed step time.

| Workload | Step wall ms | CPU island maintenance core-ms | CPU contact lifecycle core-ms | GPU busy ms | No GPU activity ms | Graph readback bytes/step |
|---|---:|---:|---:|---:|---:|---:|
| idle g16 | 0.687 → 0.666 | 0.042 → 0.041 | 0.008 → 0.007 | 0.263 → 0.263 | 0.425 → 0.405 | 0.000 → 0.000 |
| single-impact g16 | 3.705 → 3.683 | 0.072 → 0.052 | 0.045 → 0.043 | 2.226 → 2.211 | 1.481 → 1.474 | 25639.152 → 0.000 |
| burst g1 | 1.501 → 1.499 | 0.053 → 0.043 | 0.025 → 0.026 | 0.707 → 0.701 | 0.796 → 0.800 | 11751.442 → 0.000 |
| burst g4 | 3.136 → 2.826 | 0.271 → 0.139 | 0.234 → 0.213 | 1.426 → 1.355 | 1.711 → 1.473 | 195791.006 → 0.000 |
| burst g8 | 9.163 → 7.985 | 1.766 → 1.172 | 1.606 → 1.635 | 3.498 → 3.346 | 5.666 → 4.640 | 831023.588 → 0.000 |

## Work and fallback counters

| Workload | Mode | Awake bodies mean | Processed pairs/step mean | Stress bonds mean | Broken bonds across runs | Device-owned passes across runs | Host restores across runs |
|---|---|---:|---:|---:|---|---|---|
| idle g16 | CPU-owned | 0.0 | 0.0 | 200704.0 | 0, 0, 0 | 0, 0, 0 | 0, 0, 0 |
| idle g16 | GPU-owned | 0.0 | 0.0 | 200704.0 | 0, 0, 0 | 0, 0, 0 | 0, 0, 0 |
| single-impact g16 | CPU-owned | 886.2 | 3514.1 | 198807.5 | 1524, 1524, 3092 | 0, 0, 0 | 0, 0, 0 |
| single-impact g16 | GPU-owned | 663.2 | 2411.8 | 199299.8 | 1524, 1524, 1524 | 769, 769, 769 | 2, 2, 2 |
| burst g1 | CPU-owned | 369.3 | 1065.7 | 27.2 | 783, 783, 783 | 0, 0, 0 | 0, 0, 0 |
| burst g1 | GPU-owned | 369.3 | 1065.7 | 27.2 | 783, 783, 783 | 718, 718, 718 | 3, 3, 3 |
| burst g4 | CPU-owned | 5777.9 | 23411.0 | 706.6 | 12533, 12533, 12533 | 0, 0, 0 | 0, 0, 0 |
| burst g4 | GPU-owned | 5777.9 | 23411.0 | 706.6 | 12533, 12533, 12533 | 752, 752, 752 | 7, 7, 7 |
| burst g8 | CPU-owned | 23062.7 | 108842.6 | 2905.0 | 50111, 50111, 50111 | 0, 0, 0 | 0, 0, 0 |
| burst g8 | GPU-owned | 23062.7 | 108842.6 | 2905.0 | 50111, 50111, 50111 | 798, 798, 798 | 8, 8, 8 |

## Largest bombardment: detailed traced breakdown

Means are amortized across measured steps, including steps without correction. CPU core times and overlapping GPU kernel sums are not additive wall times.

| Measurement | CPU-owned | GPU-owned |
|---|---:|---:|
| physics_step_ms | 9.163 | 7.985 |
| process_cpu_ms | 17.104 | 15.133 |
| gpu_busy_ms | 3.498 | 3.346 |
| no_gpu_activity_ms | 5.666 | 4.640 |
| correction_wall_ms | 0.612 | 0.632 |
| correction_gpu_busy_ms | 0.316 | 0.309 |
| trial_and_other_gpu_busy_ms | 3.182 | 3.037 |
| checkpoint_gpu_copy_union_ms | 0.011 | 0.010 |
| checkpoint_gpu_copy_bytes | 5527100.000 | 5527100.000 |
| cuda_wait_api_union_ms | 1.832 | 1.103 |
| no_gpu_inside_cuda_wait_ms | 0.413 | 0.315 |

| CPU scope | CPU-owned core-ms | GPU-owned core-ms |
|---|---:|---:|
| task.prepareIslandRepair | 1.158 | 0.080 |
| finishDetail.waitForGpu | 0.623 | 0.823 |
| trialDetail.processLostContacts3 | 0.431 | 0.432 |
| trialDetail.postNarrowPhase | 0.430 | 0.428 |
| submit | 0.300 | 0.279 |
| trialDetail.islandInsertion | 0.284 | 0.280 |
| trialDetail.postBroadPhase | 0.284 | 0.283 |
| task.speculativeIsland.removeEdgesFromIslands | 0.264 | 0.279 |
| task.speculativeIsland.removeDestroyedConnections | 0.276 | 0.239 |
| task.accurateIsland.findPathsAndBreakIslands | 0.269 | 0.008 |
| task.accurateIsland.removeDestroyedConnections | 0.261 | 0.225 |
| task.speculativeIsland.findPathsAndBreakIslands | 0.248 | 0.005 |
| trialDetail.updateDynamics | 0.245 | 0.240 |
| trialDetail.registerSceneInteractions | 0.242 | 0.234 |
| task.accurateIsland.removeEdgesFromIslands | 0.228 | 0.234 |
| trialDetail.registerInteractions | 0.201 | 0.214 |
| trialDetail.registerContactManagers | 0.129 | 0.166 |
| trialDetail.processLostContacts2 | 0.161 | 0.153 |

| GPU category | CPU-owned summed kernel ms | GPU-owned summed kernel ms |
|---|---:|---:|
| physics constraint preparation / solve / integration | 0.904 | 0.900 |
| destruction contact graph | 0.383 | 0.374 |
| physics narrow phase / contact lifecycle | 0.316 | 0.315 |
| physics broad phase | 0.295 | 0.293 |
| stress solver / stress topology | 0.263 | 0.262 |
| destruction load gathering | 0.164 | 0.163 |
| destruction pre-solve contacts / islands | 0.110 | 0.114 |
| shared physics utilities | 0.096 | 0.096 |
| shared CUDA scan / sort primitives | 0.096 | 0.007 |
| destruction orchestration / motion | 0.055 | 0.055 |
| destruction connectivity / mass / slots | 0.052 | 0.052 |
| CUDA memory utility kernels | 0.042 | 0.042 |
| destruction material / damage | 0.015 | 0.015 |
| physics body / shape updates | 0.014 | 0.014 |

## Interpretation limits

- Chaotic bombardment trajectories differ between repeated GPU runs; inspect actual processed work alongside timing. Controlled repeated-impact tests separately require identical fracture steps, momentum checks, and trajectory differences below the existing 2e-4 tolerance.
- No sleeping benefit is measured here. Sleeping scenes fall back; GPU-owned activation and sleep propagation are still future work.
- The new mode removes CPU connectivity searches and component observation. It does not remove CPU contact creation, registration, active-body staging, or constraint partitioning.
- Restoring CPU connectivity is explicit and counted. Buffer growth or a missing eligible previous GPU graph can still trigger it; unsupported features also restore the host path.
- No physical work is capped or omitted. Every completed frame requires converged stress and at most one correction. Captures require zero dropped activity records and valid timestamps.
- CPU core-ms include spinning and profiler/driver work. No-GPU-activity time refers to this process, not global device idleness. See the campaign for GPU samples, process inventory, exact commands, source hashes, and binary hashes.
- Rendering is disabled. These are simulation times, not whole-game tick or rendering rates.
