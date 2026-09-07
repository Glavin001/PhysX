# 🏙️ Integrated PhysX GPU destruction — scaling measurements

All measured advances include recorded commands, projectile insertion, ordinary physics, CUDA stress/material/topology work, up to one correction and mandatory completion. Timestep is 1/60 second. Rendering, video encoding, asset preparation and initial CUDA setup are excluded; initialization is reported separately. Every measured step is retained.

Run count and duration are reported per scenario. Five × 60-second runs with every complete step at or below 8 ms satisfy the timing gate; shorter captures are diagnostic. Timing alone does not establish full physical or ten-minute lifecycle qualification. A mean below a deadline does not pass the peak requirement. Sleeping is disabled in these fixtures.

| Scenario | Buildings | Chunks | Bonds | Projectiles | Launch | Runs × seconds | Peak clusters |
|---|---|---|---|---|---|---|---|
| One building, projectile penetration | 1 | 444 | 896 | 1 | through-wall | 2 × 10 | 43 |
| 16 buildings, simultaneous aerial impacts | 16 | 7104 | 14336 | 16 | aerial | 2 × 10 | 865 |
| 256 buildings, simultaneous aerial impacts | 256 | 113664 | 229376 | 256 | aerial | 2 × 10 | 14219 |

World-size cases keep the original target and wall projectile unchanged; extra buildings sit beside its flight corridor. Concurrent-impact cases use the existing aerial launch. Aerial and wall trajectories are different workloads; compare scaling within each family.

Recorded settings: projectile masses (kg) [18000], material-strength scales [24], frame-strength scales [40].

## ⏱️ Complete advance — all repeats pooled

| Scenario | Min ms | Mean ms | p50 ms | p95 ms | p99 ms | Worst ms | >8 ms / steps | >16.67 ms / steps | Mean simulation / realtime |
|---|---|---|---|---|---|---|---|---|---|
| One building, projectile penetration | 0.515 | 2.271 | 2.070 | 3.346 | 4.041 | 6.195 | 0 / 1200 | 0 / 1200 | 7.34× |
| 16 buildings, simultaneous aerial impacts | 0.542 | 4.154 | 4.269 | 6.909 | 7.697 | 9.429 | 8 / 1200 | 0 / 1200 | 4.01× |
| 256 buildings, simultaneous aerial impacts | 0.973 | 11.395 | 9.670 | 17.885 | 25.720 | 49.174 | 1038 / 1200 | 313 / 1200 | 1.46× |

The realtime ratio divides 16.667 ms of simulated time by mean complete-advance cost. It describes physics/destruction throughput, not rendering or a complete game tick. The 60 Hz miss counter uses the exact 1000/60 ms threshold.

## 💥 Actual work and memory

| Scenario | Peak registered bodies | Peak active dynamic bodies | Peak active kinematic bodies | Peak contact reports/step | Peak retained stress nodes | Peak retained stress bonds | Broken bonds | Corrected steps | Sampled GPU MiB |
|---|---|---|---|---|---|---|---|---|---|
| One building, projectile penetration | 44 | 43 | 1 | 506 | 380 | 784 | [199, 199] | [3, 3] | 580.000 |
| 16 buildings, simultaneous aerial impacts | 881 | 865 | 16 | 12227 | 6080 | 12544 | [3996, 3996] | [47, 47] | 984.000 |
| 256 buildings, simultaneous aerial impacts | 14475 | 14219 | 256 | 205914 | 97280 | 200704 | [62728, 62728] | [224, 224] | 5948.000 |

Chunks are persistent geometry/connectivity units; intact chunks share cluster motion. Active-body counts are PhysX scheduler observations, not chunk counts. Retained stress rows/bonds are not proof every row executed every solver iteration. GPU memory is sampled roughly every 250 ms and can miss brief allocation peaks; it includes the CUDA context and PhysX storage. Corrected steps count the whole run, while each step permits at most one correction.

## 🔍 What happened during each worst complete step

| Scenario | Repeat / step | Total ms | Commands ms | Physics + destruction ms | Completion ms | Active dynamic bodies | Contact reports | Stress iterations | Corrections |
|---|---|---|---|---|---|---|---|---|---|
| One building, projectile penetration | 1 / 0 | 6.195 | 1.418 | 4.720 | 0.056 | 1 | 0 | 86 | 0 |
| 16 buildings, simultaneous aerial impacts | 2 / 258 | 9.429 | 0.000 | 9.384 | 0.044 | 860 | 11467 | 587 | 1 |
| 256 buildings, simultaneous aerial impacts | 2 / 82 | 49.174 | 0.000 | 49.085 | 0.090 | 5120 | 1024 | 192 | 1 |

These three subintervals add to the complete timer. Untraced captures do not separately measure stress, collision or host waits: the zero stress_solve_ms placeholder is not a zero-cost measurement. Further attribution requires a separate scoped capture; it cannot be inferred from counts or another run’s maximum.

## 🛡️ Quality observations and initialization

| Scenario | All frames converged / correction ≤1 | Repeated counter history | Original wall counters | Initialization ms range |
|---|---|---|---|---|
| One building, projectile penetration | Passed | Match | Match | 307.767–310.014 |
| 16 buildings, simultaneous aerial impacts | Passed | Match | Different aerial workload | 427.306–430.945 |
| 256 buildings, simultaneous aerial impacts | Passed | Match | Different aerial workload | 1635.402–1658.188 |

Wall counters require 199 broken bonds, three corrected steps and exactly 42 additional clusters. This does not replace the full trajectory, exact bond-identity or chunk-membership audit at each new size. Counter agreement is reported separately from physical qualification; no new large workload is declared fully qualified here.

## 🧭 Separate phase attribution: penetration

One scoped 10-second run: 444 chunks, 896 bonds, 1 projectiles. Scoped peak step 0: 6.271 ms. This is not the same measured peak as the untraced table. CPU elapsed regions below form a partition; GPU stream timings overlap them and must not be added.

| Operation | CPU / GPU responsibility | Mean ms | At scoped peak ms |
|---|---|---|---|
| Checkpoint moving-body state | CPU submission → GPU copy; save state for possible rewind | 0.008 | 0.027 |
| Submit contact loads and destruction | CPU queues GPU loads, stress, material and topology work | 0.115 | 0.821 |
| Wait for GPU destruction result | CPU blocked/spinning until required GPU work completes; not extra GPU work | 1.322 | 0.286 |
| Grow native motion address capacity | CPU grants unused indices; GPU storage allocation/upload; no spare simulated bodies | 0.000 | 0.000 |
| Assign GPU motion slots and observe compatibility requests | GPU compacts and assigns slots; GPU → CPU selected indices/metadata and completion dependency | 0.000 | 0.000 |
| Create compatibility records for selected fragments | CPU PhysX body/lifecycle records at GPU-selected indices | 0.000 | 0.000 |
| Upload allocated body bindings | CPU → GPU indices for the reserved bodies | 0.000 | 0.000 |
| Validate compatibility registration | CPU dispatch → GPU failure merge; preserves device allocation verdict | 0.000 | 0.000 |
| Other reservation bookkeeping | Uninstrumented remainder within CPU reservation scope | 0.001 | 0.001 |
| Other destruction completion bookkeeping | Remaining host scope around destruction completion | 0.006 | 0.012 |
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
| Update persistent query-owner observation | CPU owner-lookup and compatibility shape-array updates; query geometry, handles and bounds persist | 0.000 | 0.000 |
| Other shape migration work | CPU validation, target storage and gaps around instrumented migration operations | 0.000 | 0.000 |
| Other ownership bridge work | GPU-to-CPU metadata observation, completion waits and remaining host bookkeeping | 0.000 | 0.000 |
| Rewind and install fractured motion | CPU dispatch + GPU checkpoint restore and owner installation | 0.000 | 0.000 |
| Invalidate incompatible contact caches | CPU dispatch + GPU contact/friction cache reset | 0.000 | 0.000 |
| Resimulate changed interaction | CPU task scheduling + GPU collision, constraints and motion solve | 0.007 | 0.000 |
| Accept corrected step | GPU commit/status completion and CPU publication | 0.001 | 0.000 |
| Trial physics and remaining scene tasks | Original physics pass plus task/driver gaps outside destruction scopes | 0.830 | 3.652 |

## Trial physics tasks — overlapping diagnostic spans

These are existing CPU task wall scopes, not GPU kernel durations. They may nest or execute concurrently; do not sum them or add them to the complete advance. Means include all measured steps, including steps with no correction. The peak column uses the same scoped complete-step peak as the parent table.

| Task | Owner / responsibility | All-step mean ms | At scoped peak ms |
|---|---|---|---|
| Allocate contact-manager storage | CPU contact/interaction lifecycle bookkeeping | 0.002 | 0.001 |
| Register contact managers | CPU contact/interaction lifecycle bookkeeping | 0.001 | 0.000 |
| Register body/shape interactions | CPU contact/interaction lifecycle bookkeeping | 0.000 | 0.000 |
| Register scene interactions | CPU contact/interaction lifecycle bookkeeping | 0.000 | 0.000 |
| Complete broad phase and callbacks | CPU task; elapsed includes any GPU submission/dependency waits | 0.051 | 0.075 |
| Wait for GPU broad phase and pair publication | CPU spin/block awaiting GPU completion; overlaps GPU execution, not additional GPU work | 0.038 | 0.056 |
| Broad-phase completion stage 2 | CPU task; elapsed includes any GPU submission/dependency waits | 0.003 | 0.001 |
| Broad-phase completion stage 3 | CPU task; elapsed includes any GPU submission/dependency waits | 0.001 | 0.001 |
| Complete narrow phase | CPU task; elapsed includes any GPU submission/dependency waits | 0.111 | 0.017 |
| Insert contact dependencies into islands | CPU contact/interaction lifecycle bookkeeping | 0.002 | 0.002 |
| Generate simulation islands | CPU task; elapsed includes any GPU submission/dependency waits | 0.006 | 0.007 |
| Finish island scheduling | CPU task; elapsed includes any GPU submission/dependency waits | 0.003 | 0.003 |
| Prepare dynamics tasks | CPU task; elapsed includes any GPU submission/dependency waits | 0.001 | 0.003 |
| Submit dynamics/constraint solve | CPU task; elapsed includes any GPU submission/dependency waits | 0.013 | 0.017 |
| Finish constraint partitioning | CPU task; elapsed includes any GPU submission/dependency waits | 0.058 | 2.719 |
| Dispatch lost contacts | CPU task; elapsed includes any GPU submission/dependency waits | 0.003 | 0.001 |
| Lost-contact completion stage 2 | CPU task; elapsed includes any GPU submission/dependency waits | 0.002 | 0.001 |
| Lost-contact completion stage 3 | CPU task; elapsed includes any GPU submission/dependency waits | 0.001 | 0.001 |
| Finish motion integration and solver tasks | CPU task; elapsed includes any GPU submission/dependency waits | 0.002 | 0.002 |

## Correction physics tasks — overlapping diagnostic spans

These are existing CPU task wall scopes, not GPU kernel durations. They may nest or execute concurrently; do not sum them or add them to the complete advance. Means include all measured steps, including steps with no correction. The peak column uses the same scoped complete-step peak as the parent table.

| Task | Owner / responsibility | All-step mean ms | At scoped peak ms |
|---|---|---|---|
| Allocate contact-manager storage | CPU contact/interaction lifecycle bookkeeping | 0.000 | 0.000 |
| Register contact managers | CPU contact/interaction lifecycle bookkeeping | 0.000 | 0.000 |
| Register body/shape interactions | CPU contact/interaction lifecycle bookkeeping | 0.000 | 0.000 |
| Register scene interactions | CPU contact/interaction lifecycle bookkeeping | 0.000 | 0.000 |
| Complete broad phase and callbacks | CPU task; elapsed includes any GPU submission/dependency waits | 0.001 | 0.000 |
| Wait for GPU broad phase and pair publication | CPU spin/block awaiting GPU completion; overlaps GPU execution, not additional GPU work | 0.001 | 0.000 |
| Broad-phase completion stage 2 | CPU task; elapsed includes any GPU submission/dependency waits | 0.000 | 0.000 |
| Broad-phase completion stage 3 | CPU task; elapsed includes any GPU submission/dependency waits | 0.000 | 0.000 |
| Complete narrow phase | CPU task; elapsed includes any GPU submission/dependency waits | 0.001 | 0.000 |
| Insert contact dependencies into islands | CPU contact/interaction lifecycle bookkeeping | 0.000 | 0.000 |
| Generate simulation islands | CPU task; elapsed includes any GPU submission/dependency waits | 0.000 | 0.000 |
| Finish island scheduling | CPU task; elapsed includes any GPU submission/dependency waits | 0.000 | 0.000 |
| Prepare dynamics tasks | CPU task; elapsed includes any GPU submission/dependency waits | 0.000 | 0.000 |
| Submit dynamics/constraint solve | CPU task; elapsed includes any GPU submission/dependency waits | 0.000 | 0.000 |
| Finish constraint partitioning | CPU task; elapsed includes any GPU submission/dependency waits | 0.001 | 0.000 |
| Dispatch lost contacts | CPU task; elapsed includes any GPU submission/dependency waits | 0.000 | 0.000 |
| Lost-contact completion stage 2 | CPU task; elapsed includes any GPU submission/dependency waits | 0.000 | 0.000 |
| Lost-contact completion stage 3 | CPU task; elapsed includes any GPU submission/dependency waits | 0.000 | 0.000 |
| Finish motion integration and solver tasks | CPU task; elapsed includes any GPU submission/dependency waits | 0.000 | 0.000 |

| GPU stream stage | Mean ms | At scoped peak ms |
|---|---|---|
| Convert solved contact impulses into chunk loads | 0.022 | 0.037 |
| Iterative stress solve to convergence | 1.318 | 0.864 |
| Evaluate material damage and fracture | 0.018 | 0.042 |
| Connectivity, cluster mass and fragment candidates | 0.027 | 0.058 |
| Commit changes and rebuild stress topology | 0.031 | 0.058 |

Scoped versus first untraced counter history: full run matches; through this peak matches. Broken bonds: scoped 199, first untraced 199. CUDA events include stream gaps; these data do not identify a hardware bandwidth or SM-utilization limit.

## 🧭 Separate phase attribution: impacts-16

One scoped 10-second run: 7104 chunks, 14336 bonds, 16 projectiles. Scoped peak step 181: 9.068 ms. This is not the same measured peak as the untraced table. CPU elapsed regions below form a partition; GPU stream timings overlap them and must not be added.

| Operation | CPU / GPU responsibility | Mean ms | At scoped peak ms |
|---|---|---|---|
| Checkpoint moving-body state | CPU submission → GPU copy; save state for possible rewind | 0.008 | 0.006 |
| Submit contact loads and destruction | CPU queues GPU loads, stress, material and topology work | 0.106 | 0.092 |
| Wait for GPU destruction result | CPU blocked/spinning until required GPU work completes; not extra GPU work | 2.690 | 5.819 |
| Grow native motion address capacity | CPU grants unused indices; GPU storage allocation/upload; no spare simulated bodies | 0.000 | 0.000 |
| Assign GPU motion slots and observe compatibility requests | GPU compacts and assigns slots; GPU → CPU selected indices/metadata and completion dependency | 0.004 | 0.047 |
| Create compatibility records for selected fragments | CPU PhysX body/lifecycle records at GPU-selected indices | 0.002 | 0.015 |
| Upload allocated body bindings | CPU → GPU indices for the reserved bodies | 0.000 | 0.000 |
| Validate compatibility registration | CPU dispatch → GPU failure merge; preserves device allocation verdict | 0.000 | 0.004 |
| Other reservation bookkeeping | Uninstrumented remainder within CPU reservation scope | 0.001 | 0.005 |
| Other destruction completion bookkeeping | Remaining host scope around destruction completion | 0.007 | 0.005 |
| Submit fragment initialization | CPU dispatch/lifecycle; GPU initializes and validates without a stage-local readback | 0.001 | 0.010 |
| Prepare chunk collision ownership | CPU dispatch + GPU persistent-shape ownership preparation | 0.002 | 0.017 |
| Prepare corrected motion states | CPU dispatch + GPU cluster/body preparation | 0.002 | 0.012 |
| Observe initialization/collision/correction verdicts | GPU → CPU combined validation status at the remaining ownership bridge; includes completion wait | 0.005 | 0.054 |
| Validate fragment owners and shape identities | CPU validates the migration batch against compatibility actors and persistent shapes | 0.000 | 0.002 |
| Activate fragment scheduler metadata | CPU updates kinematic/dynamic type and wake/island bookkeeping; physical state is GPU-owned | 0.000 | 0.001 |
| Mark changed collision filtering | CPU broad-phase lifecycle bookkeeping for migrating persistent shapes | 0.000 | 0.000 |
| Retire old-owner contact managers | CPU releases shape interactions, contact managers and lost-touch bookkeeping | 0.001 | 0.003 |
| Update narrow-phase ownership mirror | CPU updates persistent narrow-phase owner references; no geometry upload | 0.000 | 0.001 |
| Update shape/actor links and query-bound membership | CPU transfers element ownership and registers query-bound tracking | 0.000 | 0.000 |
| Update persistent query-owner observation | CPU owner-lookup and compatibility shape-array updates; query geometry, handles and bounds persist | 0.000 | 0.001 |
| Other shape migration work | CPU validation, target storage and gaps around instrumented migration operations | 0.001 | 0.004 |
| Other ownership bridge work | GPU-to-CPU metadata observation, completion waits and remaining host bookkeeping | 0.004 | 0.061 |
| Rewind and install fractured motion | CPU dispatch + GPU checkpoint restore and owner installation | 0.001 | 0.012 |
| Invalidate incompatible contact caches | CPU dispatch + GPU contact/friction cache reset | 0.000 | 0.005 |
| Resimulate changed interaction | CPU task scheduling + GPU collision, constraints and motion solve | 0.115 | 1.420 |
| Accept corrected step | GPU commit/status completion and CPU publication | 0.012 | 0.150 |
| Trial physics and remaining scene tasks | Original physics pass plus task/driver gaps outside destruction scopes | 1.184 | 1.267 |

## Trial physics tasks — overlapping diagnostic spans

These are existing CPU task wall scopes, not GPU kernel durations. They may nest or execute concurrently; do not sum them or add them to the complete advance. Means include all measured steps, including steps with no correction. The peak column uses the same scoped complete-step peak as the parent table.

| Task | Owner / responsibility | All-step mean ms | At scoped peak ms |
|---|---|---|---|
| Allocate contact-manager storage | CPU contact/interaction lifecycle bookkeeping | 0.004 | 0.002 |
| Register contact managers | CPU contact/interaction lifecycle bookkeeping | 0.002 | 0.003 |
| Register body/shape interactions | CPU contact/interaction lifecycle bookkeeping | 0.002 | 0.004 |
| Register scene interactions | CPU contact/interaction lifecycle bookkeeping | 0.002 | 0.004 |
| Complete broad phase and callbacks | CPU task; elapsed includes any GPU submission/dependency waits | 0.087 | 0.056 |
| Wait for GPU broad phase and pair publication | CPU spin/block awaiting GPU completion; overlaps GPU execution, not additional GPU work | 0.075 | 0.041 |
| Broad-phase completion stage 2 | CPU task; elapsed includes any GPU submission/dependency waits | 0.004 | 0.006 |
| Broad-phase completion stage 3 | CPU task; elapsed includes any GPU submission/dependency waits | 0.001 | 0.001 |
| Complete narrow phase | CPU task; elapsed includes any GPU submission/dependency waits | 0.132 | 0.138 |
| Insert contact dependencies into islands | CPU contact/interaction lifecycle bookkeeping | 0.003 | 0.004 |
| Generate simulation islands | CPU task; elapsed includes any GPU submission/dependency waits | 0.009 | 0.009 |
| Finish island scheduling | CPU task; elapsed includes any GPU submission/dependency waits | 0.003 | 0.003 |
| Prepare dynamics tasks | CPU task; elapsed includes any GPU submission/dependency waits | 0.001 | 0.001 |
| Submit dynamics/constraint solve | CPU task; elapsed includes any GPU submission/dependency waits | 0.018 | 0.028 |
| Finish constraint partitioning | CPU task; elapsed includes any GPU submission/dependency waits | 0.056 | 0.059 |
| Dispatch lost contacts | CPU task; elapsed includes any GPU submission/dependency waits | 0.003 | 0.003 |
| Lost-contact completion stage 2 | CPU task; elapsed includes any GPU submission/dependency waits | 0.003 | 0.003 |
| Lost-contact completion stage 3 | CPU task; elapsed includes any GPU submission/dependency waits | 0.003 | 0.005 |
| Finish motion integration and solver tasks | CPU task; elapsed includes any GPU submission/dependency waits | 0.002 | 0.001 |

## Correction physics tasks — overlapping diagnostic spans

These are existing CPU task wall scopes, not GPU kernel durations. They may nest or execute concurrently; do not sum them or add them to the complete advance. Means include all measured steps, including steps with no correction. The peak column uses the same scoped complete-step peak as the parent table.

| Task | Owner / responsibility | All-step mean ms | At scoped peak ms |
|---|---|---|---|
| Allocate contact-manager storage | CPU contact/interaction lifecycle bookkeeping | 0.001 | 0.004 |
| Register contact managers | CPU contact/interaction lifecycle bookkeeping | 0.000 | 0.002 |
| Register body/shape interactions | CPU contact/interaction lifecycle bookkeeping | 0.001 | 0.003 |
| Register scene interactions | CPU contact/interaction lifecycle bookkeeping | 0.001 | 0.003 |
| Complete broad phase and callbacks | CPU task; elapsed includes any GPU submission/dependency waits | 0.017 | 0.223 |
| Wait for GPU broad phase and pair publication | CPU spin/block awaiting GPU completion; overlaps GPU execution, not additional GPU work | 0.016 | 0.213 |
| Broad-phase completion stage 2 | CPU task; elapsed includes any GPU submission/dependency waits | 0.001 | 0.004 |
| Broad-phase completion stage 3 | CPU task; elapsed includes any GPU submission/dependency waits | 0.000 | 0.001 |
| Complete narrow phase | CPU task; elapsed includes any GPU submission/dependency waits | 0.010 | 0.146 |
| Insert contact dependencies into islands | CPU contact/interaction lifecycle bookkeeping | 0.001 | 0.004 |
| Generate simulation islands | CPU task; elapsed includes any GPU submission/dependency waits | 0.001 | 0.010 |
| Finish island scheduling | CPU task; elapsed includes any GPU submission/dependency waits | 0.000 | 0.004 |
| Prepare dynamics tasks | CPU task; elapsed includes any GPU submission/dependency waits | 0.000 | 0.001 |
| Submit dynamics/constraint solve | CPU task; elapsed includes any GPU submission/dependency waits | 0.002 | 0.020 |
| Finish constraint partitioning | CPU task; elapsed includes any GPU submission/dependency waits | 0.006 | 0.058 |
| Dispatch lost contacts | CPU task; elapsed includes any GPU submission/dependency waits | 0.000 | 0.003 |
| Lost-contact completion stage 2 | CPU task; elapsed includes any GPU submission/dependency waits | 0.000 | 0.001 |
| Lost-contact completion stage 3 | CPU task; elapsed includes any GPU submission/dependency waits | 0.000 | 0.001 |
| Finish motion integration and solver tasks | CPU task; elapsed includes any GPU submission/dependency waits | 0.000 | 0.002 |

| GPU stream stage | Mean ms | At scoped peak ms |
|---|---|---|
| Convert solved contact impulses into chunk loads | 0.024 | 0.025 |
| Iterative stress solve to convergence | 2.659 | 5.646 |
| Evaluate material damage and fracture | 0.017 | 0.017 |
| Connectivity, cluster mass and fragment candidates | 0.040 | 0.169 |
| Commit changes and rebuild stress topology | 0.033 | 0.031 |

Scoped versus first untraced counter history: full run matches; through this peak matches. Broken bonds: scoped 3996, first untraced 3996. CUDA events include stream gaps; these data do not identify a hardware bandwidth or SM-utilization limit.

## 🧭 Separate phase attribution: impacts-256

One scoped 10-second run: 113664 chunks, 229376 bonds, 256 projectiles. Scoped peak step 82: 54.678 ms. This is not the same measured peak as the untraced table. CPU elapsed regions below form a partition; GPU stream timings overlap them and must not be added.

| Operation | CPU / GPU responsibility | Mean ms | At scoped peak ms |
|---|---|---|---|
| Checkpoint moving-body state | CPU submission → GPU copy; save state for possible rewind | 0.011 | 0.009 |
| Submit contact loads and destruction | CPU queues GPU loads, stress, material and topology work | 0.119 | 0.165 |
| Wait for GPU destruction result | CPU blocked/spinning until required GPU work completes; not extra GPU work | 5.915 | 3.577 |
| Grow native motion address capacity | CPU grants unused indices; GPU storage allocation/upload; no spare simulated bodies | 0.001 | 0.040 |
| Assign GPU motion slots and observe compatibility requests | GPU compacts and assigns slots; GPU → CPU selected indices/metadata and completion dependency | 0.022 | 0.174 |
| Create compatibility records for selected fragments | CPU PhysX body/lifecycle records at GPU-selected indices | 0.046 | 5.606 |
| Upload allocated body bindings | CPU → GPU indices for the reserved bodies | 0.000 | 0.000 |
| Validate compatibility registration | CPU dispatch → GPU failure merge; preserves device allocation verdict | 0.002 | 0.019 |
| Other reservation bookkeeping | Uninstrumented remainder within CPU reservation scope | 0.003 | 0.058 |
| Other destruction completion bookkeeping | Remaining host scope around destruction completion | 0.006 | 0.006 |
| Submit fragment initialization | CPU dispatch/lifecycle; GPU initializes and validates without a stage-local readback | 0.005 | 0.066 |
| Prepare chunk collision ownership | CPU dispatch + GPU persistent-shape ownership preparation | 0.009 | 0.106 |
| Prepare corrected motion states | CPU dispatch + GPU cluster/body preparation | 0.006 | 0.075 |
| Observe initialization/collision/correction verdicts | GPU → CPU combined validation status at the remaining ownership bridge; includes completion wait | 0.066 | 0.172 |
| Validate fragment owners and shape identities | CPU validates the migration batch against compatibility actors and persistent shapes | 0.006 | 0.761 |
| Activate fragment scheduler metadata | CPU updates kinematic/dynamic type and wake/island bookkeeping; physical state is GPU-owned | 0.002 | 0.221 |
| Mark changed collision filtering | CPU broad-phase lifecycle bookkeeping for migrating persistent shapes | 0.002 | 0.286 |
| Retire old-owner contact managers | CPU releases shape interactions, contact managers and lost-touch bookkeeping | 0.018 | 0.691 |
| Update narrow-phase ownership mirror | CPU updates persistent narrow-phase owner references; no geometry upload | 0.008 | 1.010 |
| Update shape/actor links and query-bound membership | CPU transfers element ownership and registers query-bound tracking | 0.004 | 0.518 |
| Update persistent query-owner observation | CPU owner-lookup and compatibility shape-array updates; query geometry, handles and bounds persist | 0.013 | 1.736 |
| Other shape migration work | CPU validation, target storage and gaps around instrumented migration operations | 0.023 | 4.427 |
| Other ownership bridge work | GPU-to-CPU metadata observation, completion waits and remaining host bookkeeping | 0.029 | 0.098 |
| Rewind and install fractured motion | CPU dispatch + GPU checkpoint restore and owner installation | 0.006 | 0.058 |
| Invalidate incompatible contact caches | CPU dispatch + GPU contact/friction cache reset | 0.003 | 0.006 |
| Resimulate changed interaction | CPU task scheduling + GPU collision, constraints and motion solve | 1.569 | 31.272 |
| Accept corrected step | GPU commit/status completion and CPU publication | 0.108 | 0.382 |
| Trial physics and remaining scene tasks | Original physics pass plus task/driver gaps outside destruction scopes | 3.484 | 3.075 |

## Trial physics tasks — overlapping diagnostic spans

These are existing CPU task wall scopes, not GPU kernel durations. They may nest or execute concurrently; do not sum them or add them to the complete advance. Means include all measured steps, including steps with no correction. The peak column uses the same scoped complete-step peak as the parent table.

| Task | Owner / responsibility | All-step mean ms | At scoped peak ms |
|---|---|---|---|
| Allocate contact-manager storage | CPU contact/interaction lifecycle bookkeeping | 0.022 | 0.029 |
| Register contact managers | CPU contact/interaction lifecycle bookkeeping | 0.017 | 0.059 |
| Register body/shape interactions | CPU contact/interaction lifecycle bookkeeping | 0.024 | 0.103 |
| Register scene interactions | CPU contact/interaction lifecycle bookkeeping | 0.042 | 0.146 |
| Complete broad phase and callbacks | CPU task; elapsed includes any GPU submission/dependency waits | 0.465 | 0.264 |
| Wait for GPU broad phase and pair publication | CPU spin/block awaiting GPU completion; overlaps GPU execution, not additional GPU work | 0.452 | 0.253 |
| Broad-phase completion stage 2 | CPU task; elapsed includes any GPU submission/dependency waits | 0.009 | 0.084 |
| Broad-phase completion stage 3 | CPU task; elapsed includes any GPU submission/dependency waits | 0.001 | 0.001 |
| Complete narrow phase | CPU task; elapsed includes any GPU submission/dependency waits | 0.313 | 0.110 |
| Insert contact dependencies into islands | CPU contact/interaction lifecycle bookkeeping | 0.050 | 0.145 |
| Generate simulation islands | CPU task; elapsed includes any GPU submission/dependency waits | 0.025 | 0.019 |
| Finish island scheduling | CPU task; elapsed includes any GPU submission/dependency waits | 0.001 | 0.009 |
| Prepare dynamics tasks | CPU task; elapsed includes any GPU submission/dependency waits | 0.002 | 0.002 |
| Submit dynamics/constraint solve | CPU task; elapsed includes any GPU submission/dependency waits | 0.064 | 0.034 |
| Finish constraint partitioning | CPU task; elapsed includes any GPU submission/dependency waits | 0.064 | 0.088 |
| Dispatch lost contacts | CPU task; elapsed includes any GPU submission/dependency waits | 0.003 | 0.001 |
| Lost-contact completion stage 2 | CPU task; elapsed includes any GPU submission/dependency waits | 0.030 | 0.001 |
| Lost-contact completion stage 3 | CPU task; elapsed includes any GPU submission/dependency waits | 0.055 | 0.001 |
| Finish motion integration and solver tasks | CPU task; elapsed includes any GPU submission/dependency waits | 0.001 | 0.002 |

## Correction physics tasks — overlapping diagnostic spans

These are existing CPU task wall scopes, not GPU kernel durations. They may nest or execute concurrently; do not sum them or add them to the complete advance. Means include all measured steps, including steps with no correction. The peak column uses the same scoped complete-step peak as the parent table.

| Task | Owner / responsibility | All-step mean ms | At scoped peak ms |
|---|---|---|---|
| Allocate contact-manager storage | CPU contact/interaction lifecycle bookkeeping | 0.015 | 3.986 |
| Register contact managers | CPU contact/interaction lifecycle bookkeeping | 0.003 | 0.497 |
| Register body/shape interactions | CPU contact/interaction lifecycle bookkeeping | 0.009 | 1.284 |
| Register scene interactions | CPU contact/interaction lifecycle bookkeeping | 0.019 | 3.064 |
| Complete broad phase and callbacks | CPU task; elapsed includes any GPU submission/dependency waits | 0.558 | 7.147 |
| Wait for GPU broad phase and pair publication | CPU spin/block awaiting GPU completion; overlaps GPU execution, not additional GPU work | 0.554 | 7.136 |
| Broad-phase completion stage 2 | CPU task; elapsed includes any GPU submission/dependency waits | 0.014 | 1.353 |
| Broad-phase completion stage 3 | CPU task; elapsed includes any GPU submission/dependency waits | 0.000 | 0.001 |
| Complete narrow phase | CPU task; elapsed includes any GPU submission/dependency waits | 0.105 | 0.842 |
| Insert contact dependencies into islands | CPU contact/interaction lifecycle bookkeeping | 0.021 | 2.727 |
| Generate simulation islands | CPU task; elapsed includes any GPU submission/dependency waits | 0.006 | 0.231 |
| Finish island scheduling | CPU task; elapsed includes any GPU submission/dependency waits | 0.001 | 0.001 |
| Prepare dynamics tasks | CPU task; elapsed includes any GPU submission/dependency waits | 0.001 | 0.002 |
| Submit dynamics/constraint solve | CPU task; elapsed includes any GPU submission/dependency waits | 0.026 | 1.506 |
| Finish constraint partitioning | CPU task; elapsed includes any GPU submission/dependency waits | 0.041 | 0.863 |
| Dispatch lost contacts | CPU task; elapsed includes any GPU submission/dependency waits | 0.001 | 0.003 |
| Lost-contact completion stage 2 | CPU task; elapsed includes any GPU submission/dependency waits | 0.001 | 0.001 |
| Lost-contact completion stage 3 | CPU task; elapsed includes any GPU submission/dependency waits | 0.001 | 0.001 |
| Finish motion integration and solver tasks | CPU task; elapsed includes any GPU submission/dependency waits | 0.001 | 0.002 |

| GPU stream stage | Mean ms | At scoped peak ms |
|---|---|---|
| Convert solved contact impulses into chunk loads | 0.169 | 0.070 |
| Iterative stress solve to convergence | 5.516 | 3.090 |
| Evaluate material damage and fracture | 0.065 | 0.071 |
| Connectivity, cluster mass and fragment candidates | 0.215 | 0.436 |
| Commit changes and rebuild stress topology | 0.043 | 0.038 |

Scoped versus first untraced counter history: full run matches; through this peak matches. Broken bonds: scoped 62728, first untraced 62728. CUDA events include stream gaps; these data do not identify a hardware bandwidth or SM-utilization limit.

## Reproduce and inspect

Inputs: tools/profiles/destruction-scaling.json. Capture one case with run-destruction-timing.py NEW_OUTPUT --config tools/profiles/destruction-scaling.json --case CASE_ID --gate-only --trials 2 --seconds 10. Regenerate this document with report-destruction-scaling.py CAPTURE... --output REPORT. Each capture retains exact commands, binary hashes, GPU isolation observations and lossless per-step CSVs.
