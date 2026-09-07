# 🏙️ Integrated PhysX GPU destruction — scaling measurements

All measured advances include recorded commands, projectile insertion, ordinary physics, CUDA stress/material/topology work, up to one correction and mandatory completion. Timestep is 1/60 second. Rendering, video encoding, asset preparation and initial CUDA setup are excluded; initialization is reported separately. Every measured step is retained.

Run count and duration are reported per scenario. Five × 60-second runs with every complete step at or below 8 ms satisfy the timing gate; shorter captures are diagnostic. Timing alone does not establish full physical or ten-minute lifecycle qualification. A mean below a deadline does not pass the peak requirement. Sleeping is disabled in these fixtures.

| Scenario | Buildings | Chunks | Bonds | Projectiles | Launch | Runs × seconds | Peak clusters |
|---|---|---|---|---|---|---|---|
| One building, projectile penetration | 1 | 444 | 896 | 1 | through-wall | 2 × 10 | 43 |
| One intact building, no projectile | 1 | 444 | 896 | 0 | aerial | 2 × 10 | 1 |
| 16 intact buildings, no projectiles | 16 | 7104 | 14336 | 0 | aerial | 2 × 10 | 16 |
| 16 buildings, simultaneous aerial impacts | 16 | 7104 | 14336 | 16 | aerial | 2 × 10 | 865 |
| 256 buildings, simultaneous aerial impacts | 256 | 113664 | 229376 | 256 | aerial | 2 × 10 | 14219 |

World-size cases keep the original target and wall projectile unchanged; extra buildings sit beside its flight corridor. Concurrent-impact cases use the existing aerial launch. Aerial and wall trajectories are different workloads; compare scaling within each family.

Recorded settings: projectile masses (kg) [18000], material-strength scales [24], frame-strength scales [40].

## ⏱️ Complete advance — all repeats pooled

| Scenario | Min ms | Mean ms | p50 ms | p95 ms | p99 ms | Worst ms | >8 ms / steps | >16.67 ms / steps | Mean simulation / realtime |
|---|---|---|---|---|---|---|---|---|---|
| One building, projectile penetration | 0.502 | 2.234 | 2.021 | 3.367 | 4.147 | 6.382 | 0 / 1200 | 0 / 1200 | 7.46× |
| One intact building, no projectile | 0.243 | 0.319 | 0.307 | 0.348 | 0.383 | 4.331 | 0 / 1200 | 0 / 1200 | 52.20× |
| 16 intact buildings, no projectiles | 0.271 | 0.328 | 0.323 | 0.356 | 0.390 | 4.102 | 0 / 1200 | 0 / 1200 | 50.79× |
| 16 buildings, simultaneous aerial impacts | 0.518 | 4.111 | 4.218 | 6.938 | 7.839 | 9.416 | 11 / 1200 | 0 / 1200 | 4.05× |
| 256 buildings, simultaneous aerial impacts | 0.931 | 11.548 | 9.771 | 18.428 | 27.316 | 59.478 | 1038 / 1200 | 329 / 1200 | 1.44× |

The realtime ratio divides 16.667 ms of simulated time by mean complete-advance cost. It describes physics/destruction throughput, not rendering or a complete game tick. The 60 Hz miss counter uses the exact 1000/60 ms threshold.

## 💥 Actual work and memory

| Scenario | Peak registered bodies | Peak active dynamic bodies | Peak active kinematic bodies | Peak contact reports/step | Peak retained stress nodes | Peak retained stress bonds | Broken bonds | Corrected steps | Sampled GPU MiB |
|---|---|---|---|---|---|---|---|---|---|
| One building, projectile penetration | 44 | 43 | 1 | 506 | 380 | 784 | [199, 199] | [3, 3] | 580.000 |
| One intact building, no projectile | 1 | 0 | 0 | 0 | 380 | 784 | [0, 0] | [0, 0] | 580.000 |
| 16 intact buildings, no projectiles | 16 | 0 | 0 | 0 | 6080 | 12544 | [0, 0] | [0, 0] | 726.000 |
| 16 buildings, simultaneous aerial impacts | 881 | 865 | 16 | 12227 | 6080 | 12544 | [3996, 3996] | [47, 47] | 984.000 |
| 256 buildings, simultaneous aerial impacts | 14475 | 14219 | 256 | 205914 | 97280 | 200704 | [62728, 62728] | [224, 224] | 5948.000 |

Chunks are persistent geometry/connectivity units; intact chunks share cluster motion. Active-body counts are PhysX scheduler observations, not chunk counts. Retained stress rows/bonds are not proof every row executed every solver iteration. GPU memory is sampled roughly every 250 ms and can miss brief allocation peaks; it includes the CUDA context and PhysX storage. Corrected steps count the whole run, while each step permits at most one correction.

## 🔍 What happened during each worst complete step

| Scenario | Repeat / step | Total ms | Commands ms | Physics + destruction ms | Completion ms | Active dynamic bodies | Contact reports | Stress iterations | Corrections |
|---|---|---|---|---|---|---|---|---|---|
| One building, projectile penetration | 2 / 33 | 6.382 | 0.000 | 6.309 | 0.073 | 43 | 488 | 476 | 1 |
| One intact building, no projectile | 2 / 0 | 4.331 | 0.001 | 4.231 | 0.099 | 0 | 0 | 86 | 0 |
| 16 intact buildings, no projectiles | 2 / 0 | 4.102 | 0.001 | 4.018 | 0.082 | 0 | 0 | 86 | 0 |
| 16 buildings, simultaneous aerial impacts | 2 / 103 | 9.416 | 0.000 | 9.363 | 0.053 | 722 | 6677 | 615 | 1 |
| 256 buildings, simultaneous aerial impacts | 2 / 82 | 59.478 | 0.000 | 59.414 | 0.064 | 5120 | 1024 | 192 | 1 |

These three subintervals add to the complete timer. Untraced captures do not separately measure stress, collision or host waits: the zero stress_solve_ms placeholder is not a zero-cost measurement. Further attribution requires a separate scoped capture; it cannot be inferred from counts or another run’s maximum.

## 🛡️ Quality observations and initialization

| Scenario | All frames converged / correction ≤1 | Repeated counter history | Original wall counters | Initialization ms range |
|---|---|---|---|---|
| One building, projectile penetration | Passed | Match | Match | 331.927–342.314 |
| One intact building, no projectile | Passed | Match | Different aerial workload | 320.550–327.727 |
| 16 intact buildings, no projectiles | Passed | Match | Different aerial workload | 439.235–441.647 |
| 16 buildings, simultaneous aerial impacts | Passed | Match | Different aerial workload | 433.689–438.989 |
| 256 buildings, simultaneous aerial impacts | Passed | Match | Different aerial workload | 1639.445–1683.297 |

Wall counters require 199 broken bonds, three corrected steps and exactly 42 additional clusters. This does not replace the full trajectory, exact bond-identity or chunk-membership audit at each new size. Counter agreement is reported separately from physical qualification; no new large workload is declared fully qualified here.

## 🧭 Separate phase attribution: penetration

One scoped 10-second run: 444 chunks, 896 bonds, 1 projectiles. Scoped peak step 17: 7.994 ms. This is not the same measured peak as the untraced table. CPU elapsed regions below form a partition; GPU stream timings overlap them and must not be added.

| Operation | CPU / GPU responsibility | Mean ms | At scoped peak ms |
|---|---|---|---|
| Checkpoint moving-body state | CPU submission → GPU copy; save state for possible rewind | 0.008 | 0.010 |
| Submit contact loads and destruction | CPU queues GPU loads, stress, material and topology work | 0.113 | 0.133 |
| Wait for GPU destruction result | CPU blocked/spinning until required GPU work completes; not extra GPU work | 1.311 | 1.270 |
| Grow native motion address capacity | CPU grants unused indices; GPU storage allocation/upload; no spare simulated bodies | 0.000 | 0.015 |
| Assign GPU motion slots and observe compatibility requests | GPU compacts and assigns slots; GPU → CPU selected indices/metadata and completion dependency | 0.000 | 0.144 |
| Create compatibility records for selected fragments | CPU PhysX body/lifecycle records at GPU-selected indices | 0.000 | 0.022 |
| Upload allocated body bindings | CPU → GPU indices for the reserved bodies | 0.000 | 0.000 |
| Validate compatibility registration | CPU dispatch → GPU failure merge; preserves device allocation verdict | 0.000 | 0.015 |
| Other reservation bookkeeping | Uninstrumented remainder within CPU reservation scope | 0.001 | 0.006 |
| Other destruction completion bookkeeping | Remaining host scope around destruction completion | 0.006 | 0.006 |
| Submit fragment initialization | CPU dispatch/lifecycle; GPU initializes and validates without a stage-local readback | 0.000 | 0.054 |
| Prepare chunk collision ownership | CPU dispatch + GPU persistent-shape ownership preparation | 0.001 | 0.111 |
| Prepare corrected motion states | CPU dispatch + GPU cluster/body preparation | 0.001 | 0.097 |
| Observe initialization/collision/correction verdicts | GPU → CPU combined validation status at the remaining ownership bridge; includes completion wait | 0.001 | 0.039 |
| Validate fragment owners and shape identities | CPU validates the migration batch against compatibility actors and persistent shapes | 0.000 | 0.005 |
| Activate fragment scheduler metadata | CPU updates kinematic/dynamic type and wake/island bookkeeping; physical state is GPU-owned | 0.000 | 0.002 |
| Mark changed collision filtering | CPU broad-phase lifecycle bookkeeping for migrating persistent shapes | 0.000 | 0.001 |
| Retire old-owner contact managers | CPU releases shape interactions, contact managers and lost-touch bookkeeping | 0.000 | 0.004 |
| Update narrow-phase ownership mirror | CPU updates persistent narrow-phase owner references; no geometry upload | 0.000 | 0.002 |
| Update shape/actor links and query-bound membership | CPU transfers element ownership and registers query-bound tracking | 0.000 | 0.003 |
| Rebind CPU query and actor-shape records | CPU query removal/insertion and compatibility shape-array updates | 0.000 | 0.040 |
| Other shape migration work | CPU validation, target storage and gaps around instrumented migration operations | 0.000 | 0.027 |
| Other ownership bridge work | GPU-to-CPU metadata observation, completion waits and remaining host bookkeeping | 0.000 | 0.069 |
| Rewind and install fractured motion | CPU dispatch + GPU checkpoint restore and owner installation | 0.000 | 0.036 |
| Invalidate incompatible contact caches | CPU dispatch + GPU contact/friction cache reset | 0.000 | 0.004 |
| Resimulate changed interaction | CPU task scheduling + GPU collision, constraints and motion solve | 0.007 | 1.589 |
| Accept corrected step | GPU commit/status completion and CPU publication | 0.001 | 0.146 |
| Trial physics and remaining scene tasks | Original physics pass plus task/driver gaps outside destruction scopes | 0.811 | 4.091 |

## Trial physics tasks — overlapping diagnostic spans

These are existing CPU task wall scopes, not GPU kernel durations. They may nest or execute concurrently; do not sum them or add them to the complete advance. Means include all measured steps, including steps with no correction. The peak column uses the same scoped complete-step peak as the parent table.

| Task | Owner / responsibility | All-step mean ms | At scoped peak ms |
|---|---|---|---|
| Allocate contact-manager storage | CPU contact/interaction lifecycle bookkeeping | 0.002 | 0.168 |
| Register contact managers | CPU contact/interaction lifecycle bookkeeping | 0.000 | 0.011 |
| Register body/shape interactions | CPU contact/interaction lifecycle bookkeeping | 0.000 | 0.003 |
| Register scene interactions | CPU contact/interaction lifecycle bookkeeping | 0.000 | 0.002 |
| Complete broad phase and callbacks | CPU task; elapsed includes any GPU submission/dependency waits | 0.049 | 0.066 |
| Broad-phase completion stage 2 | CPU task; elapsed includes any GPU submission/dependency waits | 0.003 | 0.071 |
| Broad-phase completion stage 3 | CPU task; elapsed includes any GPU submission/dependency waits | 0.001 | 0.001 |
| Complete narrow phase | CPU task; elapsed includes any GPU submission/dependency waits | 0.108 | 0.071 |
| Insert contact dependencies into islands | CPU contact/interaction lifecycle bookkeeping | 0.002 | 0.034 |
| Generate simulation islands | CPU task; elapsed includes any GPU submission/dependency waits | 0.007 | 0.004 |
| Finish island scheduling | CPU task; elapsed includes any GPU submission/dependency waits | 0.003 | 0.001 |
| Prepare dynamics tasks | CPU task; elapsed includes any GPU submission/dependency waits | 0.001 | 0.002 |
| Submit dynamics/constraint solve | CPU task; elapsed includes any GPU submission/dependency waits | 0.022 | 3.041 |
| Finish constraint partitioning | CPU task; elapsed includes any GPU submission/dependency waits | 0.056 | 0.072 |
| Dispatch lost contacts | CPU task; elapsed includes any GPU submission/dependency waits | 0.002 | 0.001 |
| Lost-contact completion stage 2 | CPU task; elapsed includes any GPU submission/dependency waits | 0.002 | 0.001 |
| Lost-contact completion stage 3 | CPU task; elapsed includes any GPU submission/dependency waits | 0.001 | 0.001 |
| Finish motion integration and solver tasks | CPU task; elapsed includes any GPU submission/dependency waits | 0.002 | 0.001 |

## Correction physics tasks — overlapping diagnostic spans

These are existing CPU task wall scopes, not GPU kernel durations. They may nest or execute concurrently; do not sum them or add them to the complete advance. Means include all measured steps, including steps with no correction. The peak column uses the same scoped complete-step peak as the parent table.

| Task | Owner / responsibility | All-step mean ms | At scoped peak ms |
|---|---|---|---|
| Allocate contact-manager storage | CPU contact/interaction lifecycle bookkeeping | 0.000 | 0.007 |
| Register contact managers | CPU contact/interaction lifecycle bookkeeping | 0.000 | 0.002 |
| Register body/shape interactions | CPU contact/interaction lifecycle bookkeeping | 0.000 | 0.006 |
| Register scene interactions | CPU contact/interaction lifecycle bookkeeping | 0.000 | 0.012 |
| Complete broad phase and callbacks | CPU task; elapsed includes any GPU submission/dependency waits | 0.001 | 0.110 |
| Broad-phase completion stage 2 | CPU task; elapsed includes any GPU submission/dependency waits | 0.000 | 0.012 |
| Broad-phase completion stage 3 | CPU task; elapsed includes any GPU submission/dependency waits | 0.000 | 0.001 |
| Complete narrow phase | CPU task; elapsed includes any GPU submission/dependency waits | 0.001 | 0.121 |
| Insert contact dependencies into islands | CPU contact/interaction lifecycle bookkeeping | 0.000 | 0.012 |
| Generate simulation islands | CPU task; elapsed includes any GPU submission/dependency waits | 0.000 | 0.017 |
| Finish island scheduling | CPU task; elapsed includes any GPU submission/dependency waits | 0.000 | 0.002 |
| Prepare dynamics tasks | CPU task; elapsed includes any GPU submission/dependency waits | 0.000 | 0.002 |
| Submit dynamics/constraint solve | CPU task; elapsed includes any GPU submission/dependency waits | 0.000 | 0.036 |
| Finish constraint partitioning | CPU task; elapsed includes any GPU submission/dependency waits | 0.001 | 0.143 |
| Dispatch lost contacts | CPU task; elapsed includes any GPU submission/dependency waits | 0.000 | 0.001 |
| Lost-contact completion stage 2 | CPU task; elapsed includes any GPU submission/dependency waits | 0.000 | 0.003 |
| Lost-contact completion stage 3 | CPU task; elapsed includes any GPU submission/dependency waits | 0.000 | 0.002 |
| Finish motion integration and solver tasks | CPU task; elapsed includes any GPU submission/dependency waits | 0.000 | 0.001 |

| GPU stream stage | Mean ms | At scoped peak ms |
|---|---|---|
| Convert solved contact impulses into chunk loads | 0.022 | 0.044 |
| Iterative stress solve to convergence | 1.305 | 1.172 |
| Evaluate material damage and fracture | 0.018 | 0.019 |
| Connectivity, cluster mass and fragment candidates | 0.027 | 0.116 |
| Commit changes and rebuild stress topology | 0.031 | 0.032 |

Scoped versus first untraced counter history: full run matches; through this peak matches. Broken bonds: scoped 199, first untraced 199. CUDA events include stream gaps; these data do not identify a hardware bandwidth or SM-utilization limit.

## 🧭 Separate phase attribution: idle-1

One scoped 10-second run: 444 chunks, 896 bonds, 0 projectiles. Scoped peak step 0: 1.744 ms. This is not the same measured peak as the untraced table. CPU elapsed regions below form a partition; GPU stream timings overlap them and must not be added.

| Operation | CPU / GPU responsibility | Mean ms | At scoped peak ms |
|---|---|---|---|
| Checkpoint moving-body state | CPU submission → GPU copy; save state for possible rewind | 0.007 | 0.034 |
| Submit contact loads and destruction | CPU queues GPU loads, stress, material and topology work | 0.108 | 0.942 |
| Wait for GPU destruction result | CPU blocked/spinning until required GPU work completes; not extra GPU work | 0.033 | 0.229 |
| Grow native motion address capacity | CPU grants unused indices; GPU storage allocation/upload; no spare simulated bodies | 0.000 | 0.000 |
| Assign GPU motion slots and observe compatibility requests | GPU compacts and assigns slots; GPU → CPU selected indices/metadata and completion dependency | 0.000 | 0.000 |
| Create compatibility records for selected fragments | CPU PhysX body/lifecycle records at GPU-selected indices | 0.000 | 0.000 |
| Upload allocated body bindings | CPU → GPU indices for the reserved bodies | 0.000 | 0.000 |
| Validate compatibility registration | CPU dispatch → GPU failure merge; preserves device allocation verdict | 0.000 | 0.000 |
| Other reservation bookkeeping | Uninstrumented remainder within CPU reservation scope | 0.001 | 0.001 |
| Other destruction completion bookkeeping | Remaining host scope around destruction completion | 0.005 | 0.007 |
| Submit fragment initialization | CPU dispatch/lifecycle; GPU initializes and validates without a stage-local readback | 0.000 | 0.000 |
| Prepare chunk collision ownership | CPU dispatch + GPU persistent-shape ownership preparation | 0.001 | 0.001 |
| Prepare corrected motion states | CPU dispatch + GPU cluster/body preparation | 0.001 | 0.001 |
| Observe initialization/collision/correction verdicts | GPU → CPU combined validation status at the remaining ownership bridge; includes completion wait | 0.001 | 0.001 |
| Validate fragment owners and shape identities | CPU validates the migration batch against compatibility actors and persistent shapes | 0.000 | 0.000 |
| Activate fragment scheduler metadata | CPU updates kinematic/dynamic type and wake/island bookkeeping; physical state is GPU-owned | 0.000 | 0.000 |
| Mark changed collision filtering | CPU broad-phase lifecycle bookkeeping for migrating persistent shapes | 0.000 | 0.000 |
| Retire old-owner contact managers | CPU releases shape interactions, contact managers and lost-touch bookkeeping | 0.000 | 0.000 |
| Update narrow-phase ownership mirror | CPU updates persistent narrow-phase owner references; no geometry upload | 0.000 | 0.000 |
| Update shape/actor links and query-bound membership | CPU transfers element ownership and registers query-bound tracking | 0.000 | 0.000 |
| Rebind CPU query and actor-shape records | CPU query removal/insertion and compatibility shape-array updates | 0.000 | 0.000 |
| Other shape migration work | CPU validation, target storage and gaps around instrumented migration operations | 0.000 | 0.000 |
| Other ownership bridge work | GPU-to-CPU metadata observation, completion waits and remaining host bookkeeping | 0.000 | 0.000 |
| Rewind and install fractured motion | CPU dispatch + GPU checkpoint restore and owner installation | 0.000 | 0.000 |
| Invalidate incompatible contact caches | CPU dispatch + GPU contact/friction cache reset | 0.000 | 0.000 |
| Resimulate changed interaction | CPU task scheduling + GPU collision, constraints and motion solve | 0.000 | 0.000 |
| Accept corrected step | GPU commit/status completion and CPU publication | 0.000 | 0.000 |
| Trial physics and remaining scene tasks | Original physics pass plus task/driver gaps outside destruction scopes | 0.200 | 0.470 |

## Trial physics tasks — overlapping diagnostic spans

These are existing CPU task wall scopes, not GPU kernel durations. They may nest or execute concurrently; do not sum them or add them to the complete advance. Means include all measured steps, including steps with no correction. The peak column uses the same scoped complete-step peak as the parent table.

| Task | Owner / responsibility | All-step mean ms | At scoped peak ms |
|---|---|---|---|
| Allocate contact-manager storage | CPU contact/interaction lifecycle bookkeeping | 0.001 | 0.001 |
| Complete broad phase and callbacks | CPU task; elapsed includes any GPU submission/dependency waits | 0.012 | 0.033 |
| Broad-phase completion stage 2 | CPU task; elapsed includes any GPU submission/dependency waits | 0.003 | 0.010 |
| Broad-phase completion stage 3 | CPU task; elapsed includes any GPU submission/dependency waits | 0.001 | 0.001 |
| Complete narrow phase | CPU task; elapsed includes any GPU submission/dependency waits | 0.009 | 0.014 |
| Insert contact dependencies into islands | CPU contact/interaction lifecycle bookkeeping | 0.001 | 0.002 |
| Generate simulation islands | CPU task; elapsed includes any GPU submission/dependency waits | 0.005 | 0.005 |
| Finish island scheduling | CPU task; elapsed includes any GPU submission/dependency waits | 0.002 | 0.002 |
| Prepare dynamics tasks | CPU task; elapsed includes any GPU submission/dependency waits | 0.001 | 0.003 |
| Submit dynamics/constraint solve | CPU task; elapsed includes any GPU submission/dependency waits | 0.006 | 0.007 |
| Finish constraint partitioning | CPU task; elapsed includes any GPU submission/dependency waits | 0.009 | 0.010 |
| Dispatch lost contacts | CPU task; elapsed includes any GPU submission/dependency waits | 0.001 | 0.001 |
| Lost-contact completion stage 2 | CPU task; elapsed includes any GPU submission/dependency waits | 0.002 | 0.003 |
| Lost-contact completion stage 3 | CPU task; elapsed includes any GPU submission/dependency waits | 0.001 | 0.001 |
| Finish motion integration and solver tasks | CPU task; elapsed includes any GPU submission/dependency waits | 0.001 | 0.002 |

| GPU stream stage | Mean ms | At scoped peak ms |
|---|---|---|
| Convert solved contact impulses into chunk loads | 0.007 | 0.047 |
| Iterative stress solve to convergence | 0.039 | 0.895 |
| Evaluate material damage and fracture | 0.017 | 0.049 |
| Connectivity, cluster mass and fragment candidates | 0.026 | 0.061 |
| Commit changes and rebuild stress topology | 0.031 | 0.059 |

Scoped versus first untraced counter history: full run matches; through this peak matches. Broken bonds: scoped 0, first untraced 0. CUDA events include stream gaps; these data do not identify a hardware bandwidth or SM-utilization limit.

## 🧭 Separate phase attribution: idle-16

One scoped 10-second run: 7104 chunks, 14336 bonds, 0 projectiles. Scoped peak step 0: 4.317 ms. This is not the same measured peak as the untraced table. CPU elapsed regions below form a partition; GPU stream timings overlap them and must not be added.

| Operation | CPU / GPU responsibility | Mean ms | At scoped peak ms |
|---|---|---|---|
| Checkpoint moving-body state | CPU submission → GPU copy; save state for possible rewind | 0.007 | 0.034 |
| Submit contact loads and destruction | CPU queues GPU loads, stress, material and topology work | 0.108 | 0.863 |
| Wait for GPU destruction result | CPU blocked/spinning until required GPU work completes; not extra GPU work | 0.038 | 0.351 |
| Grow native motion address capacity | CPU grants unused indices; GPU storage allocation/upload; no spare simulated bodies | 0.000 | 0.000 |
| Assign GPU motion slots and observe compatibility requests | GPU compacts and assigns slots; GPU → CPU selected indices/metadata and completion dependency | 0.000 | 0.000 |
| Create compatibility records for selected fragments | CPU PhysX body/lifecycle records at GPU-selected indices | 0.000 | 0.000 |
| Upload allocated body bindings | CPU → GPU indices for the reserved bodies | 0.000 | 0.000 |
| Validate compatibility registration | CPU dispatch → GPU failure merge; preserves device allocation verdict | 0.000 | 0.000 |
| Other reservation bookkeeping | Uninstrumented remainder within CPU reservation scope | 0.001 | 0.001 |
| Other destruction completion bookkeeping | Remaining host scope around destruction completion | 0.006 | 0.007 |
| Submit fragment initialization | CPU dispatch/lifecycle; GPU initializes and validates without a stage-local readback | 0.000 | 0.000 |
| Prepare chunk collision ownership | CPU dispatch + GPU persistent-shape ownership preparation | 0.001 | 0.001 |
| Prepare corrected motion states | CPU dispatch + GPU cluster/body preparation | 0.001 | 0.001 |
| Observe initialization/collision/correction verdicts | GPU → CPU combined validation status at the remaining ownership bridge; includes completion wait | 0.001 | 0.001 |
| Validate fragment owners and shape identities | CPU validates the migration batch against compatibility actors and persistent shapes | 0.000 | 0.000 |
| Activate fragment scheduler metadata | CPU updates kinematic/dynamic type and wake/island bookkeeping; physical state is GPU-owned | 0.000 | 0.000 |
| Mark changed collision filtering | CPU broad-phase lifecycle bookkeeping for migrating persistent shapes | 0.000 | 0.000 |
| Retire old-owner contact managers | CPU releases shape interactions, contact managers and lost-touch bookkeeping | 0.000 | 0.000 |
| Update narrow-phase ownership mirror | CPU updates persistent narrow-phase owner references; no geometry upload | 0.000 | 0.000 |
| Update shape/actor links and query-bound membership | CPU transfers element ownership and registers query-bound tracking | 0.000 | 0.000 |
| Rebind CPU query and actor-shape records | CPU query removal/insertion and compatibility shape-array updates | 0.000 | 0.000 |
| Other shape migration work | CPU validation, target storage and gaps around instrumented migration operations | 0.000 | 0.000 |
| Other ownership bridge work | GPU-to-CPU metadata observation, completion waits and remaining host bookkeeping | 0.000 | 0.000 |
| Rewind and install fractured motion | CPU dispatch + GPU checkpoint restore and owner installation | 0.000 | 0.000 |
| Invalidate incompatible contact caches | CPU dispatch + GPU contact/friction cache reset | 0.000 | 0.000 |
| Resimulate changed interaction | CPU task scheduling + GPU collision, constraints and motion solve | 0.000 | 0.000 |
| Accept corrected step | GPU commit/status completion and CPU publication | 0.000 | 0.000 |
| Trial physics and remaining scene tasks | Original physics pass plus task/driver gaps outside destruction scopes | 0.213 | 2.982 |

## Trial physics tasks — overlapping diagnostic spans

These are existing CPU task wall scopes, not GPU kernel durations. They may nest or execute concurrently; do not sum them or add them to the complete advance. Means include all measured steps, including steps with no correction. The peak column uses the same scoped complete-step peak as the parent table.

| Task | Owner / responsibility | All-step mean ms | At scoped peak ms |
|---|---|---|---|
| Allocate contact-manager storage | CPU contact/interaction lifecycle bookkeeping | 0.001 | 0.001 |
| Complete broad phase and callbacks | CPU task; elapsed includes any GPU submission/dependency waits | 0.012 | 0.055 |
| Broad-phase completion stage 2 | CPU task; elapsed includes any GPU submission/dependency waits | 0.003 | 0.005 |
| Broad-phase completion stage 3 | CPU task; elapsed includes any GPU submission/dependency waits | 0.001 | 0.001 |
| Complete narrow phase | CPU task; elapsed includes any GPU submission/dependency waits | 0.010 | 0.018 |
| Insert contact dependencies into islands | CPU contact/interaction lifecycle bookkeeping | 0.001 | 0.001 |
| Generate simulation islands | CPU task; elapsed includes any GPU submission/dependency waits | 0.005 | 0.014 |
| Finish island scheduling | CPU task; elapsed includes any GPU submission/dependency waits | 0.002 | 0.010 |
| Prepare dynamics tasks | CPU task; elapsed includes any GPU submission/dependency waits | 0.001 | 0.001 |
| Submit dynamics/constraint solve | CPU task; elapsed includes any GPU submission/dependency waits | 0.007 | 0.006 |
| Finish constraint partitioning | CPU task; elapsed includes any GPU submission/dependency waits | 0.011 | 0.014 |
| Dispatch lost contacts | CPU task; elapsed includes any GPU submission/dependency waits | 0.001 | 0.001 |
| Lost-contact completion stage 2 | CPU task; elapsed includes any GPU submission/dependency waits | 0.002 | 0.001 |
| Lost-contact completion stage 3 | CPU task; elapsed includes any GPU submission/dependency waits | 0.001 | 0.001 |
| Finish motion integration and solver tasks | CPU task; elapsed includes any GPU submission/dependency waits | 0.001 | 0.001 |

| GPU stream stage | Mean ms | At scoped peak ms |
|---|---|---|
| Convert solved contact impulses into chunk loads | 0.008 | 0.049 |
| Iterative stress solve to convergence | 0.040 | 0.941 |
| Evaluate material damage and fracture | 0.018 | 0.047 |
| Connectivity, cluster mass and fragment candidates | 0.027 | 0.059 |
| Commit changes and rebuild stress topology | 0.032 | 0.058 |

Scoped versus first untraced counter history: full run matches; through this peak matches. Broken bonds: scoped 0, first untraced 0. CUDA events include stream gaps; these data do not identify a hardware bandwidth or SM-utilization limit.

## 🧭 Separate phase attribution: impacts-16

One scoped 10-second run: 7104 chunks, 14336 bonds, 16 projectiles. Scoped peak step 258: 9.483 ms. This is not the same measured peak as the untraced table. CPU elapsed regions below form a partition; GPU stream timings overlap them and must not be added.

| Operation | CPU / GPU responsibility | Mean ms | At scoped peak ms |
|---|---|---|---|
| Checkpoint moving-body state | CPU submission → GPU copy; save state for possible rewind | 0.008 | 0.010 |
| Submit contact loads and destruction | CPU queues GPU loads, stress, material and topology work | 0.109 | 0.094 |
| Wait for GPU destruction result | CPU blocked/spinning until required GPU work completes; not extra GPU work | 2.666 | 6.078 |
| Grow native motion address capacity | CPU grants unused indices; GPU storage allocation/upload; no spare simulated bodies | 0.000 | 0.000 |
| Assign GPU motion slots and observe compatibility requests | GPU compacts and assigns slots; GPU → CPU selected indices/metadata and completion dependency | 0.005 | 0.047 |
| Create compatibility records for selected fragments | CPU PhysX body/lifecycle records at GPU-selected indices | 0.002 | 0.009 |
| Upload allocated body bindings | CPU → GPU indices for the reserved bodies | 0.000 | 0.000 |
| Validate compatibility registration | CPU dispatch → GPU failure merge; preserves device allocation verdict | 0.000 | 0.004 |
| Other reservation bookkeeping | Uninstrumented remainder within CPU reservation scope | 0.001 | 0.004 |
| Other destruction completion bookkeeping | Remaining host scope around destruction completion | 0.006 | 0.005 |
| Submit fragment initialization | CPU dispatch/lifecycle; GPU initializes and validates without a stage-local readback | 0.001 | 0.010 |
| Prepare chunk collision ownership | CPU dispatch + GPU persistent-shape ownership preparation | 0.003 | 0.017 |
| Prepare corrected motion states | CPU dispatch + GPU cluster/body preparation | 0.002 | 0.012 |
| Observe initialization/collision/correction verdicts | GPU → CPU combined validation status at the remaining ownership bridge; includes completion wait | 0.006 | 0.061 |
| Validate fragment owners and shape identities | CPU validates the migration batch against compatibility actors and persistent shapes | 0.000 | 0.003 |
| Activate fragment scheduler metadata | CPU updates kinematic/dynamic type and wake/island bookkeeping; physical state is GPU-owned | 0.000 | 0.001 |
| Mark changed collision filtering | CPU broad-phase lifecycle bookkeeping for migrating persistent shapes | 0.000 | 0.001 |
| Retire old-owner contact managers | CPU releases shape interactions, contact managers and lost-touch bookkeeping | 0.001 | 0.010 |
| Update narrow-phase ownership mirror | CPU updates persistent narrow-phase owner references; no geometry upload | 0.000 | 0.002 |
| Update shape/actor links and query-bound membership | CPU transfers element ownership and registers query-bound tracking | 0.000 | 0.001 |
| Rebind CPU query and actor-shape records | CPU query removal/insertion and compatibility shape-array updates | 0.002 | 0.011 |
| Other shape migration work | CPU validation, target storage and gaps around instrumented migration operations | 0.002 | 0.006 |
| Other ownership bridge work | GPU-to-CPU metadata observation, completion waits and remaining host bookkeeping | 0.005 | 0.048 |
| Rewind and install fractured motion | CPU dispatch + GPU checkpoint restore and owner installation | 0.001 | 0.011 |
| Invalidate incompatible contact caches | CPU dispatch + GPU contact/friction cache reset | 0.001 | 0.008 |
| Resimulate changed interaction | CPU task scheduling + GPU collision, constraints and motion solve | 0.117 | 1.480 |
| Accept corrected step | GPU commit/status completion and CPU publication | 0.012 | 0.152 |
| Trial physics and remaining scene tasks | Original physics pass plus task/driver gaps outside destruction scopes | 1.167 | 1.335 |

## Trial physics tasks — overlapping diagnostic spans

These are existing CPU task wall scopes, not GPU kernel durations. They may nest or execute concurrently; do not sum them or add them to the complete advance. Means include all measured steps, including steps with no correction. The peak column uses the same scoped complete-step peak as the parent table.

| Task | Owner / responsibility | All-step mean ms | At scoped peak ms |
|---|---|---|---|
| Allocate contact-manager storage | CPU contact/interaction lifecycle bookkeeping | 0.004 | 0.005 |
| Register contact managers | CPU contact/interaction lifecycle bookkeeping | 0.002 | 0.003 |
| Register body/shape interactions | CPU contact/interaction lifecycle bookkeeping | 0.002 | 0.003 |
| Register scene interactions | CPU contact/interaction lifecycle bookkeeping | 0.003 | 0.002 |
| Complete broad phase and callbacks | CPU task; elapsed includes any GPU submission/dependency waits | 0.072 | 0.071 |
| Broad-phase completion stage 2 | CPU task; elapsed includes any GPU submission/dependency waits | 0.004 | 0.002 |
| Broad-phase completion stage 3 | CPU task; elapsed includes any GPU submission/dependency waits | 0.001 | 0.001 |
| Complete narrow phase | CPU task; elapsed includes any GPU submission/dependency waits | 0.133 | 0.164 |
| Insert contact dependencies into islands | CPU contact/interaction lifecycle bookkeeping | 0.004 | 0.003 |
| Generate simulation islands | CPU task; elapsed includes any GPU submission/dependency waits | 0.009 | 0.017 |
| Finish island scheduling | CPU task; elapsed includes any GPU submission/dependency waits | 0.003 | 0.002 |
| Prepare dynamics tasks | CPU task; elapsed includes any GPU submission/dependency waits | 0.001 | 0.001 |
| Submit dynamics/constraint solve | CPU task; elapsed includes any GPU submission/dependency waits | 0.020 | 0.023 |
| Finish constraint partitioning | CPU task; elapsed includes any GPU submission/dependency waits | 0.058 | 0.057 |
| Dispatch lost contacts | CPU task; elapsed includes any GPU submission/dependency waits | 0.003 | 0.001 |
| Lost-contact completion stage 2 | CPU task; elapsed includes any GPU submission/dependency waits | 0.003 | 0.002 |
| Lost-contact completion stage 3 | CPU task; elapsed includes any GPU submission/dependency waits | 0.003 | 0.004 |
| Finish motion integration and solver tasks | CPU task; elapsed includes any GPU submission/dependency waits | 0.002 | 0.001 |

## Correction physics tasks — overlapping diagnostic spans

These are existing CPU task wall scopes, not GPU kernel durations. They may nest or execute concurrently; do not sum them or add them to the complete advance. Means include all measured steps, including steps with no correction. The peak column uses the same scoped complete-step peak as the parent table.

| Task | Owner / responsibility | All-step mean ms | At scoped peak ms |
|---|---|---|---|
| Allocate contact-manager storage | CPU contact/interaction lifecycle bookkeeping | 0.001 | 0.010 |
| Register contact managers | CPU contact/interaction lifecycle bookkeeping | 0.000 | 0.003 |
| Register body/shape interactions | CPU contact/interaction lifecycle bookkeeping | 0.001 | 0.003 |
| Register scene interactions | CPU contact/interaction lifecycle bookkeeping | 0.001 | 0.005 |
| Complete broad phase and callbacks | CPU task; elapsed includes any GPU submission/dependency waits | 0.015 | 0.203 |
| Broad-phase completion stage 2 | CPU task; elapsed includes any GPU submission/dependency waits | 0.001 | 0.006 |
| Broad-phase completion stage 3 | CPU task; elapsed includes any GPU submission/dependency waits | 0.000 | 0.001 |
| Complete narrow phase | CPU task; elapsed includes any GPU submission/dependency waits | 0.010 | 0.173 |
| Insert contact dependencies into islands | CPU contact/interaction lifecycle bookkeeping | 0.001 | 0.009 |
| Generate simulation islands | CPU task; elapsed includes any GPU submission/dependency waits | 0.001 | 0.007 |
| Finish island scheduling | CPU task; elapsed includes any GPU submission/dependency waits | 0.000 | 0.003 |
| Prepare dynamics tasks | CPU task; elapsed includes any GPU submission/dependency waits | 0.000 | 0.002 |
| Submit dynamics/constraint solve | CPU task; elapsed includes any GPU submission/dependency waits | 0.002 | 0.030 |
| Finish constraint partitioning | CPU task; elapsed includes any GPU submission/dependency waits | 0.006 | 0.052 |
| Dispatch lost contacts | CPU task; elapsed includes any GPU submission/dependency waits | 0.000 | 0.002 |
| Lost-contact completion stage 2 | CPU task; elapsed includes any GPU submission/dependency waits | 0.000 | 0.001 |
| Lost-contact completion stage 3 | CPU task; elapsed includes any GPU submission/dependency waits | 0.000 | 0.001 |
| Finish motion integration and solver tasks | CPU task; elapsed includes any GPU submission/dependency waits | 0.000 | 0.001 |

| GPU stream stage | Mean ms | At scoped peak ms |
|---|---|---|
| Convert solved contact impulses into chunk loads | 0.025 | 0.026 |
| Iterative stress solve to convergence | 2.638 | 5.907 |
| Evaluate material damage and fracture | 0.018 | 0.017 |
| Connectivity, cluster mass and fragment candidates | 0.040 | 0.171 |
| Commit changes and rebuild stress topology | 0.033 | 0.032 |

Scoped versus first untraced counter history: full run matches; through this peak matches. Broken bonds: scoped 3996, first untraced 3996. CUDA events include stream gaps; these data do not identify a hardware bandwidth or SM-utilization limit.

## 🧭 Separate phase attribution: impacts-256

One scoped 10-second run: 113664 chunks, 229376 bonds, 256 projectiles. Scoped peak step 82: 60.079 ms. This is not the same measured peak as the untraced table. CPU elapsed regions below form a partition; GPU stream timings overlap them and must not be added.

| Operation | CPU / GPU responsibility | Mean ms | At scoped peak ms |
|---|---|---|---|
| Checkpoint moving-body state | CPU submission → GPU copy; save state for possible rewind | 0.012 | 0.007 |
| Submit contact loads and destruction | CPU queues GPU loads, stress, material and topology work | 0.118 | 0.165 |
| Wait for GPU destruction result | CPU blocked/spinning until required GPU work completes; not extra GPU work | 5.889 | 3.655 |
| Grow native motion address capacity | CPU grants unused indices; GPU storage allocation/upload; no spare simulated bodies | 0.000 | 0.043 |
| Assign GPU motion slots and observe compatibility requests | GPU compacts and assigns slots; GPU → CPU selected indices/metadata and completion dependency | 0.021 | 0.195 |
| Create compatibility records for selected fragments | CPU PhysX body/lifecycle records at GPU-selected indices | 0.050 | 6.697 |
| Upload allocated body bindings | CPU → GPU indices for the reserved bodies | 0.000 | 0.000 |
| Validate compatibility registration | CPU dispatch → GPU failure merge; preserves device allocation verdict | 0.002 | 0.025 |
| Other reservation bookkeeping | Uninstrumented remainder within CPU reservation scope | 0.002 | 0.073 |
| Other destruction completion bookkeeping | Remaining host scope around destruction completion | 0.006 | 0.008 |
| Submit fragment initialization | CPU dispatch/lifecycle; GPU initializes and validates without a stage-local readback | 0.005 | 0.070 |
| Prepare chunk collision ownership | CPU dispatch + GPU persistent-shape ownership preparation | 0.008 | 0.105 |
| Prepare corrected motion states | CPU dispatch + GPU cluster/body preparation | 0.006 | 0.074 |
| Observe initialization/collision/correction verdicts | GPU → CPU combined validation status at the remaining ownership bridge; includes completion wait | 0.066 | 0.183 |
| Validate fragment owners and shape identities | CPU validates the migration batch against compatibility actors and persistent shapes | 0.006 | 0.750 |
| Activate fragment scheduler metadata | CPU updates kinematic/dynamic type and wake/island bookkeeping; physical state is GPU-owned | 0.001 | 0.219 |
| Mark changed collision filtering | CPU broad-phase lifecycle bookkeeping for migrating persistent shapes | 0.002 | 0.231 |
| Retire old-owner contact managers | CPU releases shape interactions, contact managers and lost-touch bookkeeping | 0.018 | 0.699 |
| Update narrow-phase ownership mirror | CPU updates persistent narrow-phase owner references; no geometry upload | 0.008 | 0.999 |
| Update shape/actor links and query-bound membership | CPU transfers element ownership and registers query-bound tracking | 0.004 | 0.519 |
| Rebind CPU query and actor-shape records | CPU query removal/insertion and compatibility shape-array updates | 0.045 | 5.896 |
| Other shape migration work | CPU validation, target storage and gaps around instrumented migration operations | 0.026 | 4.432 |
| Other ownership bridge work | GPU-to-CPU metadata observation, completion waits and remaining host bookkeeping | 0.030 | 0.115 |
| Rewind and install fractured motion | CPU dispatch + GPU checkpoint restore and owner installation | 0.006 | 0.061 |
| Invalidate incompatible contact caches | CPU dispatch + GPU contact/friction cache reset | 0.003 | 0.005 |
| Resimulate changed interaction | CPU task scheduling + GPU collision, constraints and motion solve | 1.582 | 30.318 |
| Accept corrected step | GPU commit/status completion and CPU publication | 0.110 | 0.440 |
| Trial physics and remaining scene tasks | Original physics pass plus task/driver gaps outside destruction scopes | 3.645 | 4.020 |

## Trial physics tasks — overlapping diagnostic spans

These are existing CPU task wall scopes, not GPU kernel durations. They may nest or execute concurrently; do not sum them or add them to the complete advance. Means include all measured steps, including steps with no correction. The peak column uses the same scoped complete-step peak as the parent table.

| Task | Owner / responsibility | All-step mean ms | At scoped peak ms |
|---|---|---|---|
| Allocate contact-manager storage | CPU contact/interaction lifecycle bookkeeping | 0.021 | 0.119 |
| Register contact managers | CPU contact/interaction lifecycle bookkeeping | 0.022 | 0.054 |
| Register body/shape interactions | CPU contact/interaction lifecycle bookkeeping | 0.027 | 0.217 |
| Register scene interactions | CPU contact/interaction lifecycle bookkeeping | 0.042 | 0.122 |
| Complete broad phase and callbacks | CPU task; elapsed includes any GPU submission/dependency waits | 0.464 | 0.239 |
| Broad-phase completion stage 2 | CPU task; elapsed includes any GPU submission/dependency waits | 0.010 | 0.112 |
| Broad-phase completion stage 3 | CPU task; elapsed includes any GPU submission/dependency waits | 0.001 | 0.001 |
| Complete narrow phase | CPU task; elapsed includes any GPU submission/dependency waits | 0.311 | 0.108 |
| Insert contact dependencies into islands | CPU contact/interaction lifecycle bookkeeping | 0.053 | 0.097 |
| Generate simulation islands | CPU task; elapsed includes any GPU submission/dependency waits | 0.027 | 0.010 |
| Finish island scheduling | CPU task; elapsed includes any GPU submission/dependency waits | 0.002 | 0.001 |
| Prepare dynamics tasks | CPU task; elapsed includes any GPU submission/dependency waits | 0.002 | 0.002 |
| Submit dynamics/constraint solve | CPU task; elapsed includes any GPU submission/dependency waits | 0.065 | 0.043 |
| Finish constraint partitioning | CPU task; elapsed includes any GPU submission/dependency waits | 0.070 | 0.114 |
| Dispatch lost contacts | CPU task; elapsed includes any GPU submission/dependency waits | 0.003 | 0.001 |
| Lost-contact completion stage 2 | CPU task; elapsed includes any GPU submission/dependency waits | 0.033 | 0.001 |
| Lost-contact completion stage 3 | CPU task; elapsed includes any GPU submission/dependency waits | 0.057 | 0.001 |
| Finish motion integration and solver tasks | CPU task; elapsed includes any GPU submission/dependency waits | 0.002 | 0.001 |

## Correction physics tasks — overlapping diagnostic spans

These are existing CPU task wall scopes, not GPU kernel durations. They may nest or execute concurrently; do not sum them or add them to the complete advance. Means include all measured steps, including steps with no correction. The peak column uses the same scoped complete-step peak as the parent table.

| Task | Owner / responsibility | All-step mean ms | At scoped peak ms |
|---|---|---|---|
| Allocate contact-manager storage | CPU contact/interaction lifecycle bookkeeping | 0.016 | 3.855 |
| Register contact managers | CPU contact/interaction lifecycle bookkeeping | 0.003 | 0.453 |
| Register body/shape interactions | CPU contact/interaction lifecycle bookkeeping | 0.008 | 0.665 |
| Register scene interactions | CPU contact/interaction lifecycle bookkeeping | 0.020 | 3.115 |
| Complete broad phase and callbacks | CPU task; elapsed includes any GPU submission/dependency waits | 0.563 | 9.168 |
| Broad-phase completion stage 2 | CPU task; elapsed includes any GPU submission/dependency waits | 0.015 | 1.533 |
| Broad-phase completion stage 3 | CPU task; elapsed includes any GPU submission/dependency waits | 0.000 | 0.001 |
| Complete narrow phase | CPU task; elapsed includes any GPU submission/dependency waits | 0.105 | 0.778 |
| Insert contact dependencies into islands | CPU contact/interaction lifecycle bookkeeping | 0.021 | 2.195 |
| Generate simulation islands | CPU task; elapsed includes any GPU submission/dependency waits | 0.006 | 0.178 |
| Finish island scheduling | CPU task; elapsed includes any GPU submission/dependency waits | 0.001 | 0.001 |
| Prepare dynamics tasks | CPU task; elapsed includes any GPU submission/dependency waits | 0.001 | 0.002 |
| Submit dynamics/constraint solve | CPU task; elapsed includes any GPU submission/dependency waits | 0.026 | 1.223 |
| Finish constraint partitioning | CPU task; elapsed includes any GPU submission/dependency waits | 0.042 | 0.640 |
| Dispatch lost contacts | CPU task; elapsed includes any GPU submission/dependency waits | 0.001 | 0.003 |
| Lost-contact completion stage 2 | CPU task; elapsed includes any GPU submission/dependency waits | 0.001 | 0.001 |
| Lost-contact completion stage 3 | CPU task; elapsed includes any GPU submission/dependency waits | 0.001 | 0.002 |
| Finish motion integration and solver tasks | CPU task; elapsed includes any GPU submission/dependency waits | 0.001 | 0.002 |

| GPU stream stage | Mean ms | At scoped peak ms |
|---|---|---|
| Convert solved contact impulses into chunk loads | 0.170 | 0.067 |
| Iterative stress solve to convergence | 5.487 | 3.167 |
| Evaluate material damage and fracture | 0.065 | 0.074 |
| Connectivity, cluster mass and fragment candidates | 0.216 | 0.456 |
| Commit changes and rebuild stress topology | 0.043 | 0.038 |

Scoped versus first untraced counter history: full run matches; through this peak matches. Broken bonds: scoped 62728, first untraced 62728. CUDA events include stream gaps; these data do not identify a hardware bandwidth or SM-utilization limit.

## Reproduce and inspect

Inputs: tools/profiles/destruction-scaling.json. Capture one case with run-destruction-timing.py NEW_OUTPUT --config tools/profiles/destruction-scaling.json --case CASE_ID --gate-only --trials 2 --seconds 10. Regenerate this document with report-destruction-scaling.py CAPTURE... --output REPORT. Each capture retains exact commands, binary hashes, GPU isolation observations and lossless per-step CSVs.
