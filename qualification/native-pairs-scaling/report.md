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
| One building, projectile penetration | 0.525 | 2.268 | 2.056 | 3.378 | 4.072 | 6.245 | 0 / 1200 | 0 / 1200 | 7.35× |
| 16 buildings, simultaneous aerial impacts | 0.560 | 4.159 | 4.331 | 6.940 | 7.710 | 9.466 | 10 / 1200 | 0 / 1200 | 4.01× |
| 256 buildings, simultaneous aerial impacts | 0.966 | 11.380 | 9.623 | 18.050 | 25.608 | 50.600 | 1038 / 1200 | 303 / 1200 | 1.46× |

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
| One building, projectile penetration | 1 / 0 | 6.245 | 1.449 | 4.738 | 0.058 | 1 | 0 | 86 | 0 |
| 16 buildings, simultaneous aerial impacts | 1 / 170 | 9.466 | 0.000 | 9.415 | 0.051 | 803 | 8725 | 630 | 1 |
| 256 buildings, simultaneous aerial impacts | 1 / 82 | 50.600 | 0.000 | 50.544 | 0.056 | 5120 | 1024 | 192 | 1 |

These three subintervals add to the complete timer. Untraced captures do not separately measure stress, collision or host waits: the zero stress_solve_ms placeholder is not a zero-cost measurement. Further attribution requires a separate scoped capture; it cannot be inferred from counts or another run’s maximum.

## 🛡️ Quality observations and initialization

| Scenario | All frames converged / correction ≤1 | Repeated counter history | Original wall counters | Initialization ms range |
|---|---|---|---|---|
| One building, projectile penetration | Passed | Match | Match | 321.015–329.081 |
| 16 buildings, simultaneous aerial impacts | Passed | Match | Different aerial workload | 442.427–449.908 |
| 256 buildings, simultaneous aerial impacts | Passed | Match | Different aerial workload | 1638.605–1680.055 |

Wall counters require 199 broken bonds, three corrected steps and exactly 42 additional clusters. This does not replace the full trajectory, exact bond-identity or chunk-membership audit at each new size. Counter agreement is reported separately from physical qualification; no new large workload is declared fully qualified here.

## 🧭 Separate phase attribution: penetration

One scoped 10-second run: 444 chunks, 896 bonds, 1 projectiles. Scoped peak step 33: 6.201 ms. This is not the same measured peak as the untraced table. CPU elapsed regions below form a partition; GPU stream timings overlap them and must not be added.

| Operation | CPU / GPU responsibility | Mean ms | At scoped peak ms |
|---|---|---|---|
| Checkpoint moving-body state | CPU submission → GPU copy; save state for possible rewind | 0.008 | 0.009 |
| Submit contact loads and destruction | CPU queues GPU loads, stress, material and topology work | 0.113 | 0.125 |
| Wait for GPU destruction result | CPU blocked/spinning until required GPU work completes; not extra GPU work | 1.322 | 2.852 |
| Grow native motion address capacity | CPU grants unused indices; GPU storage allocation/upload; no spare simulated bodies | 0.000 | 0.000 |
| Assign GPU motion slots and observe compatibility requests | GPU compacts and assigns slots; GPU → CPU selected indices/metadata and completion dependency | 0.000 | 0.063 |
| Create compatibility records for selected fragments | CPU PhysX body/lifecycle records at GPU-selected indices | 0.000 | 0.006 |
| Upload allocated body bindings | CPU → GPU indices for the reserved bodies | 0.000 | 0.000 |
| Validate compatibility registration | CPU dispatch → GPU failure merge; preserves device allocation verdict | 0.000 | 0.005 |
| Other reservation bookkeeping | Uninstrumented remainder within CPU reservation scope | 0.001 | 0.006 |
| Other destruction completion bookkeeping | Remaining host scope around destruction completion | 0.006 | 0.006 |
| Submit fragment initialization | CPU dispatch/lifecycle; GPU initializes and validates without a stage-local readback | 0.000 | 0.022 |
| Prepare chunk collision ownership | CPU dispatch + GPU persistent-shape ownership preparation | 0.001 | 0.023 |
| Prepare corrected motion states | CPU dispatch + GPU cluster/body preparation | 0.001 | 0.016 |
| Observe initialization/collision/correction verdicts | GPU → CPU combined validation status at the remaining ownership bridge; includes completion wait | 0.001 | 0.065 |
| Validate fragment owners and shape identities | CPU validates the migration batch against compatibility actors and persistent shapes | 0.000 | 0.002 |
| Activate fragment scheduler metadata | CPU updates kinematic/dynamic type and wake/island bookkeeping; physical state is GPU-owned | 0.000 | 0.001 |
| Mark changed collision filtering | CPU broad-phase lifecycle bookkeeping for migrating persistent shapes | 0.000 | 0.000 |
| Retire old-owner contact managers | CPU releases shape interactions, contact managers and lost-touch bookkeeping | 0.000 | 0.007 |
| Update narrow-phase ownership mirror | CPU updates persistent narrow-phase owner references; no geometry upload | 0.000 | 0.001 |
| Update shape/actor links and query-bound membership | CPU transfers element ownership and registers query-bound tracking | 0.000 | 0.000 |
| Update persistent query-owner observation | CPU owner-lookup and compatibility shape-array updates; query geometry, handles and bounds persist | 0.000 | 0.001 |
| Other shape migration work | CPU validation, target storage and gaps around instrumented migration operations | 0.000 | 0.003 |
| Other ownership bridge work | GPU-to-CPU metadata observation, completion waits and remaining host bookkeeping | 0.000 | 0.067 |
| Rewind and install fractured motion | CPU dispatch + GPU checkpoint restore and owner installation | 0.000 | 0.013 |
| Invalidate incompatible contact caches | CPU dispatch + GPU contact/friction cache reset | 0.000 | 0.005 |
| Resimulate changed interaction | CPU task scheduling + GPU collision, constraints and motion solve | 0.007 | 1.387 |
| Accept corrected step | GPU commit/status completion and CPU publication | 0.001 | 0.127 |
| Trial physics and remaining scene tasks | Original physics pass plus task/driver gaps outside destruction scopes | 0.822 | 1.319 |

## Trial physics tasks — overlapping diagnostic spans

These are existing CPU task wall scopes, not GPU kernel durations. They may nest or execute concurrently; do not sum them or add them to the complete advance. Means include all measured steps, including steps with no correction. The peak column uses the same scoped complete-step peak as the parent table.

| Task | Owner / responsibility | All-step mean ms | At scoped peak ms |
|---|---|---|---|
| Allocate contact-manager storage | CPU contact/interaction lifecycle bookkeeping | 0.002 | 0.021 |
| Register contact managers | CPU contact/interaction lifecycle bookkeeping | 0.000 | 0.014 |
| Register body/shape interactions | CPU contact/interaction lifecycle bookkeeping | 0.000 | 0.010 |
| Register scene interactions | CPU contact/interaction lifecycle bookkeeping | 0.000 | 0.013 |
| Complete broad phase and callbacks | CPU task; elapsed includes any GPU submission/dependency waits | 0.050 | 0.056 |
| Broad-phase completion stage 2 | CPU task; elapsed includes any GPU submission/dependency waits | 0.003 | 0.002 |
| Broad-phase completion stage 3 | CPU task; elapsed includes any GPU submission/dependency waits | 0.001 | 0.001 |
| Complete narrow phase | CPU task; elapsed includes any GPU submission/dependency waits | 0.110 | 0.161 |
| Insert contact dependencies into islands | CPU contact/interaction lifecycle bookkeeping | 0.002 | 0.006 |
| Generate simulation islands | CPU task; elapsed includes any GPU submission/dependency waits | 0.007 | 0.018 |
| Finish island scheduling | CPU task; elapsed includes any GPU submission/dependency waits | 0.003 | 0.001 |
| Prepare dynamics tasks | CPU task; elapsed includes any GPU submission/dependency waits | 0.001 | 0.001 |
| Submit dynamics/constraint solve | CPU task; elapsed includes any GPU submission/dependency waits | 0.013 | 0.022 |
| Finish constraint partitioning | CPU task; elapsed includes any GPU submission/dependency waits | 0.057 | 0.127 |
| Dispatch lost contacts | CPU task; elapsed includes any GPU submission/dependency waits | 0.002 | 0.005 |
| Lost-contact completion stage 2 | CPU task; elapsed includes any GPU submission/dependency waits | 0.002 | 0.006 |
| Lost-contact completion stage 3 | CPU task; elapsed includes any GPU submission/dependency waits | 0.001 | 0.004 |
| Finish motion integration and solver tasks | CPU task; elapsed includes any GPU submission/dependency waits | 0.002 | 0.001 |

## Correction physics tasks — overlapping diagnostic spans

These are existing CPU task wall scopes, not GPU kernel durations. They may nest or execute concurrently; do not sum them or add them to the complete advance. Means include all measured steps, including steps with no correction. The peak column uses the same scoped complete-step peak as the parent table.

| Task | Owner / responsibility | All-step mean ms | At scoped peak ms |
|---|---|---|---|
| Allocate contact-manager storage | CPU contact/interaction lifecycle bookkeeping | 0.000 | 0.006 |
| Register contact managers | CPU contact/interaction lifecycle bookkeeping | 0.000 | 0.003 |
| Register body/shape interactions | CPU contact/interaction lifecycle bookkeeping | 0.000 | 0.005 |
| Register scene interactions | CPU contact/interaction lifecycle bookkeeping | 0.000 | 0.005 |
| Complete broad phase and callbacks | CPU task; elapsed includes any GPU submission/dependency waits | 0.001 | 0.106 |
| Broad-phase completion stage 2 | CPU task; elapsed includes any GPU submission/dependency waits | 0.000 | 0.008 |
| Broad-phase completion stage 3 | CPU task; elapsed includes any GPU submission/dependency waits | 0.000 | 0.001 |
| Complete narrow phase | CPU task; elapsed includes any GPU submission/dependency waits | 0.001 | 0.111 |
| Insert contact dependencies into islands | CPU contact/interaction lifecycle bookkeeping | 0.000 | 0.006 |
| Generate simulation islands | CPU task; elapsed includes any GPU submission/dependency waits | 0.000 | 0.004 |
| Finish island scheduling | CPU task; elapsed includes any GPU submission/dependency waits | 0.000 | 0.001 |
| Prepare dynamics tasks | CPU task; elapsed includes any GPU submission/dependency waits | 0.000 | 0.002 |
| Submit dynamics/constraint solve | CPU task; elapsed includes any GPU submission/dependency waits | 0.000 | 0.035 |
| Finish constraint partitioning | CPU task; elapsed includes any GPU submission/dependency waits | 0.001 | 0.142 |
| Dispatch lost contacts | CPU task; elapsed includes any GPU submission/dependency waits | 0.000 | 0.005 |
| Lost-contact completion stage 2 | CPU task; elapsed includes any GPU submission/dependency waits | 0.000 | 0.005 |
| Lost-contact completion stage 3 | CPU task; elapsed includes any GPU submission/dependency waits | 0.000 | 0.004 |
| Finish motion integration and solver tasks | CPU task; elapsed includes any GPU submission/dependency waits | 0.000 | 0.001 |

| GPU stream stage | Mean ms | At scoped peak ms |
|---|---|---|
| Convert solved contact impulses into chunk loads | 0.022 | 0.022 |
| Iterative stress solve to convergence | 1.316 | 2.759 |
| Evaluate material damage and fracture | 0.018 | 0.017 |
| Connectivity, cluster mass and fragment candidates | 0.027 | 0.121 |
| Commit changes and rebuild stress topology | 0.031 | 0.031 |

Scoped versus first untraced counter history: full run matches; through this peak matches. Broken bonds: scoped 199, first untraced 199. CUDA events include stream gaps; these data do not identify a hardware bandwidth or SM-utilization limit.

## 🧭 Separate phase attribution: impacts-16

One scoped 10-second run: 7104 chunks, 14336 bonds, 16 projectiles. Scoped peak step 103: 10.853 ms. This is not the same measured peak as the untraced table. CPU elapsed regions below form a partition; GPU stream timings overlap them and must not be added.

| Operation | CPU / GPU responsibility | Mean ms | At scoped peak ms |
|---|---|---|---|
| Checkpoint moving-body state | CPU submission → GPU copy; save state for possible rewind | 0.009 | 0.030 |
| Submit contact loads and destruction | CPU queues GPU loads, stress, material and topology work | 0.108 | 0.115 |
| Wait for GPU destruction result | CPU blocked/spinning until required GPU work completes; not extra GPU work | 2.677 | 5.548 |
| Grow native motion address capacity | CPU grants unused indices; GPU storage allocation/upload; no spare simulated bodies | 0.000 | 0.045 |
| Assign GPU motion slots and observe compatibility requests | GPU compacts and assigns slots; GPU → CPU selected indices/metadata and completion dependency | 0.005 | 0.063 |
| Create compatibility records for selected fragments | CPU PhysX body/lifecycle records at GPU-selected indices | 0.002 | 0.076 |
| Upload allocated body bindings | CPU → GPU indices for the reserved bodies | 0.000 | 0.000 |
| Validate compatibility registration | CPU dispatch → GPU failure merge; preserves device allocation verdict | 0.000 | 0.006 |
| Other reservation bookkeeping | Uninstrumented remainder within CPU reservation scope | 0.001 | 0.008 |
| Other destruction completion bookkeeping | Remaining host scope around destruction completion | 0.006 | 0.008 |
| Submit fragment initialization | CPU dispatch/lifecycle; GPU initializes and validates without a stage-local readback | 0.001 | 0.022 |
| Prepare chunk collision ownership | CPU dispatch + GPU persistent-shape ownership preparation | 0.003 | 0.021 |
| Prepare corrected motion states | CPU dispatch + GPU cluster/body preparation | 0.002 | 0.014 |
| Observe initialization/collision/correction verdicts | GPU → CPU combined validation status at the remaining ownership bridge; includes completion wait | 0.006 | 0.069 |
| Validate fragment owners and shape identities | CPU validates the migration batch against compatibility actors and persistent shapes | 0.000 | 0.026 |
| Activate fragment scheduler metadata | CPU updates kinematic/dynamic type and wake/island bookkeeping; physical state is GPU-owned | 0.000 | 0.004 |
| Mark changed collision filtering | CPU broad-phase lifecycle bookkeeping for migrating persistent shapes | 0.000 | 0.005 |
| Retire old-owner contact managers | CPU releases shape interactions, contact managers and lost-touch bookkeeping | 0.001 | 0.040 |
| Update narrow-phase ownership mirror | CPU updates persistent narrow-phase owner references; no geometry upload | 0.000 | 0.020 |
| Update shape/actor links and query-bound membership | CPU transfers element ownership and registers query-bound tracking | 0.000 | 0.012 |
| Update persistent query-owner observation | CPU owner-lookup and compatibility shape-array updates; query geometry, handles and bounds persist | 0.001 | 0.024 |
| Other shape migration work | CPU validation, target storage and gaps around instrumented migration operations | 0.002 | 0.080 |
| Other ownership bridge work | GPU-to-CPU metadata observation, completion waits and remaining host bookkeeping | 0.006 | 0.074 |
| Rewind and install fractured motion | CPU dispatch + GPU checkpoint restore and owner installation | 0.001 | 0.016 |
| Invalidate incompatible contact caches | CPU dispatch + GPU contact/friction cache reset | 0.001 | 0.006 |
| Resimulate changed interaction | CPU task scheduling + GPU collision, constraints and motion solve | 0.120 | 2.825 |
| Accept corrected step | GPU commit/status completion and CPU publication | 0.012 | 0.155 |
| Trial physics and remaining scene tasks | Original physics pass plus task/driver gaps outside destruction scopes | 1.197 | 1.490 |

## Trial physics tasks — overlapping diagnostic spans

These are existing CPU task wall scopes, not GPU kernel durations. They may nest or execute concurrently; do not sum them or add them to the complete advance. Means include all measured steps, including steps with no correction. The peak column uses the same scoped complete-step peak as the parent table.

| Task | Owner / responsibility | All-step mean ms | At scoped peak ms |
|---|---|---|---|
| Allocate contact-manager storage | CPU contact/interaction lifecycle bookkeeping | 0.004 | 0.007 |
| Register contact managers | CPU contact/interaction lifecycle bookkeeping | 0.002 | 0.009 |
| Register body/shape interactions | CPU contact/interaction lifecycle bookkeeping | 0.002 | 0.018 |
| Register scene interactions | CPU contact/interaction lifecycle bookkeeping | 0.003 | 0.010 |
| Complete broad phase and callbacks | CPU task; elapsed includes any GPU submission/dependency waits | 0.084 | 0.091 |
| Broad-phase completion stage 2 | CPU task; elapsed includes any GPU submission/dependency waits | 0.005 | 0.003 |
| Broad-phase completion stage 3 | CPU task; elapsed includes any GPU submission/dependency waits | 0.001 | 0.001 |
| Complete narrow phase | CPU task; elapsed includes any GPU submission/dependency waits | 0.134 | 0.176 |
| Insert contact dependencies into islands | CPU contact/interaction lifecycle bookkeeping | 0.004 | 0.029 |
| Generate simulation islands | CPU task; elapsed includes any GPU submission/dependency waits | 0.009 | 0.011 |
| Finish island scheduling | CPU task; elapsed includes any GPU submission/dependency waits | 0.003 | 0.001 |
| Prepare dynamics tasks | CPU task; elapsed includes any GPU submission/dependency waits | 0.002 | 0.002 |
| Submit dynamics/constraint solve | CPU task; elapsed includes any GPU submission/dependency waits | 0.018 | 0.029 |
| Finish constraint partitioning | CPU task; elapsed includes any GPU submission/dependency waits | 0.057 | 0.061 |
| Dispatch lost contacts | CPU task; elapsed includes any GPU submission/dependency waits | 0.004 | 0.006 |
| Lost-contact completion stage 2 | CPU task; elapsed includes any GPU submission/dependency waits | 0.003 | 0.024 |
| Lost-contact completion stage 3 | CPU task; elapsed includes any GPU submission/dependency waits | 0.003 | 0.033 |
| Finish motion integration and solver tasks | CPU task; elapsed includes any GPU submission/dependency waits | 0.001 | 0.002 |

## Correction physics tasks — overlapping diagnostic spans

These are existing CPU task wall scopes, not GPU kernel durations. They may nest or execute concurrently; do not sum them or add them to the complete advance. Means include all measured steps, including steps with no correction. The peak column uses the same scoped complete-step peak as the parent table.

| Task | Owner / responsibility | All-step mean ms | At scoped peak ms |
|---|---|---|---|
| Allocate contact-manager storage | CPU contact/interaction lifecycle bookkeeping | 0.001 | 0.068 |
| Register contact managers | CPU contact/interaction lifecycle bookkeeping | 0.000 | 0.004 |
| Register body/shape interactions | CPU contact/interaction lifecycle bookkeeping | 0.001 | 0.025 |
| Register scene interactions | CPU contact/interaction lifecycle bookkeeping | 0.001 | 0.024 |
| Complete broad phase and callbacks | CPU task; elapsed includes any GPU submission/dependency waits | 0.016 | 0.200 |
| Broad-phase completion stage 2 | CPU task; elapsed includes any GPU submission/dependency waits | 0.001 | 0.021 |
| Broad-phase completion stage 3 | CPU task; elapsed includes any GPU submission/dependency waits | 0.000 | 0.001 |
| Complete narrow phase | CPU task; elapsed includes any GPU submission/dependency waits | 0.011 | 0.202 |
| Insert contact dependencies into islands | CPU contact/interaction lifecycle bookkeeping | 0.001 | 0.075 |
| Generate simulation islands | CPU task; elapsed includes any GPU submission/dependency waits | 0.001 | 0.010 |
| Finish island scheduling | CPU task; elapsed includes any GPU submission/dependency waits | 0.000 | 0.001 |
| Prepare dynamics tasks | CPU task; elapsed includes any GPU submission/dependency waits | 0.000 | 0.001 |
| Submit dynamics/constraint solve | CPU task; elapsed includes any GPU submission/dependency waits | 0.002 | 0.151 |
| Finish constraint partitioning | CPU task; elapsed includes any GPU submission/dependency waits | 0.006 | 0.488 |
| Dispatch lost contacts | CPU task; elapsed includes any GPU submission/dependency waits | 0.000 | 0.002 |
| Lost-contact completion stage 2 | CPU task; elapsed includes any GPU submission/dependency waits | 0.000 | 0.003 |
| Lost-contact completion stage 3 | CPU task; elapsed includes any GPU submission/dependency waits | 0.000 | 0.001 |
| Finish motion integration and solver tasks | CPU task; elapsed includes any GPU submission/dependency waits | 0.000 | 0.001 |

| GPU stream stage | Mean ms | At scoped peak ms |
|---|---|---|
| Convert solved contact impulses into chunk loads | 0.025 | 0.025 |
| Iterative stress solve to convergence | 2.648 | 5.392 |
| Evaluate material damage and fracture | 0.018 | 0.019 |
| Connectivity, cluster mass and fragment candidates | 0.040 | 0.171 |
| Commit changes and rebuild stress topology | 0.033 | 0.030 |

Scoped versus first untraced counter history: full run matches; through this peak matches. Broken bonds: scoped 3996, first untraced 3996. CUDA events include stream gaps; these data do not identify a hardware bandwidth or SM-utilization limit.

## 🧭 Separate phase attribution: impacts-256

One scoped 10-second run: 113664 chunks, 229376 bonds, 256 projectiles. Scoped peak step 82: 51.552 ms. This is not the same measured peak as the untraced table. CPU elapsed regions below form a partition; GPU stream timings overlap them and must not be added.

| Operation | CPU / GPU responsibility | Mean ms | At scoped peak ms |
|---|---|---|---|
| Checkpoint moving-body state | CPU submission → GPU copy; save state for possible rewind | 0.022 | 0.011 |
| Submit contact loads and destruction | CPU queues GPU loads, stress, material and topology work | 0.121 | 0.158 |
| Wait for GPU destruction result | CPU blocked/spinning until required GPU work completes; not extra GPU work | 5.876 | 3.709 |
| Grow native motion address capacity | CPU grants unused indices; GPU storage allocation/upload; no spare simulated bodies | 0.000 | 0.038 |
| Assign GPU motion slots and observe compatibility requests | GPU compacts and assigns slots; GPU → CPU selected indices/metadata and completion dependency | 0.023 | 0.177 |
| Create compatibility records for selected fragments | CPU PhysX body/lifecycle records at GPU-selected indices | 0.048 | 5.906 |
| Upload allocated body bindings | CPU → GPU indices for the reserved bodies | 0.000 | 0.000 |
| Validate compatibility registration | CPU dispatch → GPU failure merge; preserves device allocation verdict | 0.002 | 0.021 |
| Other reservation bookkeeping | Uninstrumented remainder within CPU reservation scope | 0.003 | 0.052 |
| Other destruction completion bookkeeping | Remaining host scope around destruction completion | 0.006 | 0.006 |
| Submit fragment initialization | CPU dispatch/lifecycle; GPU initializes and validates without a stage-local readback | 0.005 | 0.088 |
| Prepare chunk collision ownership | CPU dispatch + GPU persistent-shape ownership preparation | 0.009 | 0.105 |
| Prepare corrected motion states | CPU dispatch + GPU cluster/body preparation | 0.006 | 0.079 |
| Observe initialization/collision/correction verdicts | GPU → CPU combined validation status at the remaining ownership bridge; includes completion wait | 0.066 | 0.175 |
| Validate fragment owners and shape identities | CPU validates the migration batch against compatibility actors and persistent shapes | 0.006 | 0.854 |
| Activate fragment scheduler metadata | CPU updates kinematic/dynamic type and wake/island bookkeeping; physical state is GPU-owned | 0.001 | 0.220 |
| Mark changed collision filtering | CPU broad-phase lifecycle bookkeeping for migrating persistent shapes | 0.002 | 0.289 |
| Retire old-owner contact managers | CPU releases shape interactions, contact managers and lost-touch bookkeeping | 0.018 | 0.552 |
| Update narrow-phase ownership mirror | CPU updates persistent narrow-phase owner references; no geometry upload | 0.007 | 0.506 |
| Update shape/actor links and query-bound membership | CPU transfers element ownership and registers query-bound tracking | 0.004 | 0.508 |
| Update persistent query-owner observation | CPU owner-lookup and compatibility shape-array updates; query geometry, handles and bounds persist | 0.012 | 1.443 |
| Other shape migration work | CPU validation, target storage and gaps around instrumented migration operations | 0.025 | 4.492 |
| Other ownership bridge work | GPU-to-CPU metadata observation, completion waits and remaining host bookkeeping | 0.030 | 0.112 |
| Rewind and install fractured motion | CPU dispatch + GPU checkpoint restore and owner installation | 0.006 | 0.058 |
| Invalidate incompatible contact caches | CPU dispatch + GPU contact/friction cache reset | 0.003 | 0.005 |
| Resimulate changed interaction | CPU task scheduling + GPU collision, constraints and motion solve | 1.586 | 28.219 |
| Accept corrected step | GPU commit/status completion and CPU publication | 0.108 | 0.462 |
| Trial physics and remaining scene tasks | Original physics pass plus task/driver gaps outside destruction scopes | 3.547 | 3.249 |

## Trial physics tasks — overlapping diagnostic spans

These are existing CPU task wall scopes, not GPU kernel durations. They may nest or execute concurrently; do not sum them or add them to the complete advance. Means include all measured steps, including steps with no correction. The peak column uses the same scoped complete-step peak as the parent table.

| Task | Owner / responsibility | All-step mean ms | At scoped peak ms |
|---|---|---|---|
| Allocate contact-manager storage | CPU contact/interaction lifecycle bookkeeping | 0.022 | 0.177 |
| Register contact managers | CPU contact/interaction lifecycle bookkeeping | 0.020 | 0.076 |
| Register body/shape interactions | CPU contact/interaction lifecycle bookkeeping | 0.025 | 0.309 |
| Register scene interactions | CPU contact/interaction lifecycle bookkeeping | 0.043 | 0.072 |
| Complete broad phase and callbacks | CPU task; elapsed includes any GPU submission/dependency waits | 0.480 | 0.245 |
| Broad-phase completion stage 2 | CPU task; elapsed includes any GPU submission/dependency waits | 0.010 | 0.030 |
| Broad-phase completion stage 3 | CPU task; elapsed includes any GPU submission/dependency waits | 0.001 | 0.001 |
| Complete narrow phase | CPU task; elapsed includes any GPU submission/dependency waits | 0.315 | 0.115 |
| Insert contact dependencies into islands | CPU contact/interaction lifecycle bookkeeping | 0.052 | 0.093 |
| Generate simulation islands | CPU task; elapsed includes any GPU submission/dependency waits | 0.026 | 0.034 |
| Finish island scheduling | CPU task; elapsed includes any GPU submission/dependency waits | 0.002 | 0.005 |
| Prepare dynamics tasks | CPU task; elapsed includes any GPU submission/dependency waits | 0.002 | 0.002 |
| Submit dynamics/constraint solve | CPU task; elapsed includes any GPU submission/dependency waits | 0.065 | 0.036 |
| Finish constraint partitioning | CPU task; elapsed includes any GPU submission/dependency waits | 0.070 | 0.088 |
| Dispatch lost contacts | CPU task; elapsed includes any GPU submission/dependency waits | 0.003 | 0.001 |
| Lost-contact completion stage 2 | CPU task; elapsed includes any GPU submission/dependency waits | 0.031 | 0.001 |
| Lost-contact completion stage 3 | CPU task; elapsed includes any GPU submission/dependency waits | 0.056 | 0.001 |
| Finish motion integration and solver tasks | CPU task; elapsed includes any GPU submission/dependency waits | 0.002 | 0.001 |

## Correction physics tasks — overlapping diagnostic spans

These are existing CPU task wall scopes, not GPU kernel durations. They may nest or execute concurrently; do not sum them or add them to the complete advance. Means include all measured steps, including steps with no correction. The peak column uses the same scoped complete-step peak as the parent table.

| Task | Owner / responsibility | All-step mean ms | At scoped peak ms |
|---|---|---|---|
| Allocate contact-manager storage | CPU contact/interaction lifecycle bookkeeping | 0.017 | 3.826 |
| Register contact managers | CPU contact/interaction lifecycle bookkeeping | 0.003 | 0.309 |
| Register body/shape interactions | CPU contact/interaction lifecycle bookkeeping | 0.007 | 0.570 |
| Register scene interactions | CPU contact/interaction lifecycle bookkeeping | 0.019 | 3.003 |
| Complete broad phase and callbacks | CPU task; elapsed includes any GPU submission/dependency waits | 0.573 | 9.235 |
| Broad-phase completion stage 2 | CPU task; elapsed includes any GPU submission/dependency waits | 0.015 | 1.509 |
| Broad-phase completion stage 3 | CPU task; elapsed includes any GPU submission/dependency waits | 0.000 | 0.001 |
| Complete narrow phase | CPU task; elapsed includes any GPU submission/dependency waits | 0.108 | 0.853 |
| Insert contact dependencies into islands | CPU contact/interaction lifecycle bookkeeping | 0.021 | 2.385 |
| Generate simulation islands | CPU task; elapsed includes any GPU submission/dependency waits | 0.006 | 0.088 |
| Finish island scheduling | CPU task; elapsed includes any GPU submission/dependency waits | 0.001 | 0.001 |
| Prepare dynamics tasks | CPU task; elapsed includes any GPU submission/dependency waits | 0.001 | 0.002 |
| Submit dynamics/constraint solve | CPU task; elapsed includes any GPU submission/dependency waits | 0.030 | 1.274 |
| Finish constraint partitioning | CPU task; elapsed includes any GPU submission/dependency waits | 0.041 | 0.687 |
| Dispatch lost contacts | CPU task; elapsed includes any GPU submission/dependency waits | 0.001 | 0.004 |
| Lost-contact completion stage 2 | CPU task; elapsed includes any GPU submission/dependency waits | 0.001 | 0.001 |
| Lost-contact completion stage 3 | CPU task; elapsed includes any GPU submission/dependency waits | 0.001 | 0.002 |
| Finish motion integration and solver tasks | CPU task; elapsed includes any GPU submission/dependency waits | 0.001 | 0.003 |

| GPU stream stage | Mean ms | At scoped peak ms |
|---|---|---|
| Convert solved contact impulses into chunk loads | 0.170 | 0.059 |
| Iterative stress solve to convergence | 5.478 | 3.218 |
| Evaluate material damage and fracture | 0.066 | 0.076 |
| Connectivity, cluster mass and fragment candidates | 0.216 | 0.452 |
| Commit changes and rebuild stress topology | 0.043 | 0.040 |

Scoped versus first untraced counter history: full run matches; through this peak matches. Broken bonds: scoped 62728, first untraced 62728. CUDA events include stream gaps; these data do not identify a hardware bandwidth or SM-utilization limit.

## Reproduce and inspect

Inputs: tools/profiles/destruction-scaling.json. Capture one case with run-destruction-timing.py NEW_OUTPUT --config tools/profiles/destruction-scaling.json --case CASE_ID --gate-only --trials 2 --seconds 10. Regenerate this document with report-destruction-scaling.py CAPTURE... --output REPORT. Each capture retains exact commands, binary hashes, GPU isolation observations and lossless per-step CSVs.
