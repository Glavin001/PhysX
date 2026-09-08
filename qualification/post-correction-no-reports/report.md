# 🎯 Complete PhysX destruction advance — 8 ms gate

60 Hz physical timestep. Timer includes commands, projectile insertion, simulate/fetch, destruction/correction and mandatory completion. All measured steps, including startup, remain. Rendering and report output are outside the bracket.

❌ Deadline failed: 1278 steps exceeded 8.0 ms. Diagnostic only: five × 60-second qualification duration not met.

This timing gate checks convergence, correction limit, frozen wall counters and repeated counter histories. It does not substitute for the independent trajectory/hole/momentum audit or the 10-minute endurance gate; overall plan qualification remains incomplete until those pass.

⚠️ Chaotic workload variation: 256 buildings / 113664 chunks / 229376 bonds / 768 aerial projectiles, repeat 2: per-step counter history differs. Convergence and correction-limit checks passed, but exact trajectories and full physical quality are not qualified.

| Scene | Chunks | Bonds | Projectiles | Peak destruction clusters | Seconds per run | Correction limit | Sleeping |
|---|---|---|---|---|---|---|---|
| 256 buildings / 113664 chunks / 229376 bonds / 768 aerial projectiles | 113664 | 229376 | 767 | 37125 | 12 | 1 | Enabled |

Stress chunks are geometry/connectivity units, not independently solved rigid bodies while bonded. Peak destruction clusters is the maximum across all measured repeats and excludes ordinary actors such as the projectile and ground. Idle controls measure retained geometry, not concurrent destruction.

| Scene | Repeat | Steps | Min ms | Mean ms | p95 ms | p99 ms | Peak ms | Misses | Peak step | Commands at peak ms | Physics/destruction at peak ms | Completion at peak ms |
|---|---|---|---|---|---|---|---|---|---|---|---|---|
| 256 buildings / 113664 chunks / 229376 bonds / 768 aerial projectiles | 1 | 720 | 2.702 | 58.237 | 81.445 | 88.572 | 105.549 | 639 | 397 | 0.440 | 105.045 | 0.064 |
| 256 buildings / 113664 chunks / 229376 bonds / 768 aerial projectiles | 2 | 720 | 2.781 | 60.602 | 85.689 | 89.873 | 118.007 | 639 | 395 | 0.501 | 117.446 | 0.060 |

Commands and completion timings are disjoint from simulate/fetch. Detailed CPU/GPU subdivisions require a separate profiling capture; they must not be inferred from another run’s maximum. No percentile or outlier removal changes the deadline verdict.

## Separate phase capture: 256 buildings / 113664 chunks / 229376 bonds / 768 aerial projectiles

This is a separate instrumented run. CPU elapsed regions form a partition; CUDA stream stages overlap that partition and must not be added to it. The peak column below refers only to this scoped run, not the untraced peak above.

| Operation | Owner / responsibility | Mean elapsed ms | At scoped peak ms |
|---|---|---|---|
| Apply recorded commands | CPU submission and GPU command execution | 0.114 | 0.119 |
| Checkpoint moving-body state | CPU submission → GPU copy; save state for possible rewind | 0.012 | 0.010 |
| Submit contact loads and destruction | CPU queues GPU loads, stress, material and topology work | 0.272 | 0.277 |
| Wait for GPU destruction result | CPU blocked/spinning until required GPU work completes; not extra GPU work | 34.996 | 54.006 |
| Grow native motion address capacity | CPU grants unused indices; GPU storage allocation/upload; no spare simulated bodies | 0.001 | 0.000 |
| Assign GPU motion slots and observe compatibility requests | GPU compacts and assigns slots; GPU → CPU selected indices/metadata and completion dependency | 0.138 | 0.305 |
| Create compatibility records for selected fragments | CPU PhysX body/lifecycle records at GPU-selected indices | 0.064 | 0.096 |
| Upload allocated body bindings | CPU → GPU indices for the reserved bodies | 0.000 | 0.000 |
| Validate compatibility registration | CPU dispatch → GPU failure merge; preserves device allocation verdict | 0.009 | 0.025 |
| Other reservation bookkeeping | Uninstrumented remainder within CPU reservation scope | 0.009 | 0.014 |
| Other destruction completion bookkeeping | Remaining host scope around destruction completion | 0.017 | 0.018 |
| Submit fragment initialization | CPU dispatch/lifecycle; GPU initializes and validates without a stage-local readback | 0.027 | 0.038 |
| Prepare chunk collision ownership | CPU dispatch + GPU persistent-shape ownership preparation | 0.086 | 0.119 |
| Prepare corrected motion states | CPU dispatch + GPU cluster/body preparation | 0.029 | 0.037 |
| Observe initialization/collision/correction verdicts | GPU → CPU combined validation status at the remaining ownership bridge; includes completion wait | 0.310 | 0.425 |
| Validate fragment owners and shape identities | CPU validates the migration batch against compatibility actors and persistent shapes | 0.025 | 0.075 |
| Activate fragment scheduler metadata | CPU updates kinematic/dynamic type and wake/island bookkeeping; physical state is GPU-owned | 0.006 | 0.015 |
| Mark changed collision filtering | CPU broad-phase lifecycle bookkeeping for migrating persistent shapes | 0.008 | 0.032 |
| Retire old-owner contact managers | CPU releases shape interactions, contact managers and lost-touch bookkeeping | 0.124 | 0.651 |
| Update narrow-phase ownership mirror | CPU updates persistent narrow-phase owner references; no geometry upload | 0.030 | 0.123 |
| Update shape/actor links and query-bound membership | CPU transfers element ownership and registers query-bound tracking | 0.014 | 0.053 |
| Update persistent query-owner observation | CPU owner-lookup and compatibility shape-array updates; query geometry, handles and bounds persist | 0.044 | 0.177 |
| Other shape migration work | CPU validation, target storage and gaps around instrumented migration operations | 0.076 | 0.356 |
| Other ownership bridge work | GPU-to-CPU metadata observation, completion waits and remaining host bookkeeping | 0.236 | 0.389 |
| Rewind and install fractured motion | CPU dispatch + GPU checkpoint restore and owner installation | 0.031 | 0.046 |
| Invalidate incompatible contact caches | CPU dispatch + GPU contact/friction cache reset | 0.009 | 0.010 |
| Resimulate changed interaction | CPU task scheduling + GPU collision, constraints and motion solve | 7.380 | 32.301 |
| Accept corrected step | GPU commit/status completion and CPU publication | 2.275 | 2.680 |
| Trial physics and remaining scene tasks | Original physics pass plus task/driver gaps outside destruction scopes | 12.979 | 16.804 |
| Mandatory completion and status | CPU completion boundary and compact GPU status observation | 0.075 | 0.095 |
| TOTAL complete advance | Commands through accepted state and mandatory status | 59.394 | 109.293 |

| GPU stream stage | Mean ms | At scoped peak ms |
|---|---|---|
| Convert solved contact impulses into chunk loads | 0.372 | 0.468 |
| Iterative stress solve to convergence | 33.406 | 52.118 |
| Evaluate material damage and fracture | 0.128 | 0.131 |
| Connectivity, cluster mass and fragment candidates | 1.074 | 1.306 |
| Commit changes and rebuild stress topology | 0.159 | 0.080 |

## Trial physics tasks — overlapping diagnostic spans

These are existing CPU task wall scopes, not GPU kernel durations. They may nest or execute concurrently; do not sum them or add them to the complete advance. Means include all measured steps, including steps with no correction. The peak column uses the same scoped complete-step peak as the parent table.

| Task | Owner / responsibility | All-step mean ms | At scoped peak ms |
|---|---|---|---|
| Allocate contact-manager storage | CPU contact/interaction lifecycle bookkeeping | 0.097 | 0.126 |
| Register contact managers | CPU contact/interaction lifecycle bookkeeping | 0.057 | 0.112 |
| Register body/shape interactions | CPU contact/interaction lifecycle bookkeeping | 0.082 | 0.087 |
| Register scene interactions | CPU contact/interaction lifecycle bookkeeping | 0.170 | 0.193 |
| Complete broad phase and callbacks | CPU task; elapsed includes any GPU submission/dependency waits | 1.665 | 1.789 |
| Wait for GPU broad phase and pair publication | CPU spin/block awaiting GPU completion; overlaps GPU execution, not additional GPU work | 1.648 | 1.775 |
| Broad-phase completion stage 2 | CPU task; elapsed includes any GPU submission/dependency waits | 0.014 | 0.007 |
| Broad-phase completion stage 3 | CPU task; elapsed includes any GPU submission/dependency waits | 0.001 | 0.001 |
| Complete narrow phase | CPU task; elapsed includes any GPU submission/dependency waits | 0.481 | 0.600 |
| Insert contact dependencies into islands | CPU contact/interaction lifecycle bookkeeping | 0.238 | 0.329 |
| Generate simulation islands | CPU task; elapsed includes any GPU submission/dependency waits | 0.057 | 0.113 |
| Finish island scheduling | CPU task; elapsed includes any GPU submission/dependency waits | 0.001 | 0.002 |
| Prepare dynamics tasks | CPU task; elapsed includes any GPU submission/dependency waits | 0.548 | 0.681 |
| Submit dynamics/constraint solve | CPU task; elapsed includes any GPU submission/dependency waits | 0.290 | 0.302 |
| Finish constraint partitioning | CPU task; elapsed includes any GPU submission/dependency waits | 0.379 | 0.421 |
| Dispatch lost contacts | CPU task; elapsed includes any GPU submission/dependency waits | 0.005 | 0.005 |
| Lost-contact completion stage 2 | CPU task; elapsed includes any GPU submission/dependency waits | 0.100 | 0.166 |
| Lost-contact completion stage 3 | CPU task; elapsed includes any GPU submission/dependency waits | 0.169 | 0.287 |
| Finish motion integration and solver tasks | CPU task; elapsed includes any GPU submission/dependency waits | 0.002 | 0.002 |

## Correction physics tasks — overlapping diagnostic spans

These are existing CPU task wall scopes, not GPU kernel durations. They may nest or execute concurrently; do not sum them or add them to the complete advance. Means include all measured steps, including steps with no correction. The peak column uses the same scoped complete-step peak as the parent table.

| Task | Owner / responsibility | All-step mean ms | At scoped peak ms |
|---|---|---|---|
| Allocate contact-manager storage | CPU contact/interaction lifecycle bookkeeping | 0.031 | 0.086 |
| Register contact managers | CPU contact/interaction lifecycle bookkeeping | 0.007 | 0.060 |
| Register body/shape interactions | CPU contact/interaction lifecycle bookkeeping | 0.022 | 0.097 |
| Register scene interactions | CPU contact/interaction lifecycle bookkeeping | 0.057 | 0.175 |
| Complete broad phase and callbacks | CPU task; elapsed includes any GPU submission/dependency waits | 1.206 | 1.345 |
| Wait for GPU broad phase and pair publication | CPU spin/block awaiting GPU completion; overlaps GPU execution, not additional GPU work | 1.193 | 1.333 |
| Broad-phase completion stage 2 | CPU task; elapsed includes any GPU submission/dependency waits | 0.041 | 0.101 |
| Broad-phase completion stage 3 | CPU task; elapsed includes any GPU submission/dependency waits | 0.001 | 0.001 |
| Complete narrow phase | CPU task; elapsed includes any GPU submission/dependency waits | 0.362 | 0.617 |
| Insert contact dependencies into islands | CPU contact/interaction lifecycle bookkeeping | 0.098 | 0.389 |
| Generate simulation islands | CPU task; elapsed includes any GPU submission/dependency waits | 0.022 | 0.055 |
| Finish island scheduling | CPU task; elapsed includes any GPU submission/dependency waits | 0.002 | 0.002 |
| Prepare dynamics tasks | CPU task; elapsed includes any GPU submission/dependency waits | 0.002 | 0.002 |
| Submit dynamics/constraint solve | CPU task; elapsed includes any GPU submission/dependency waits | 0.200 | 0.392 |
| Finish constraint partitioning | CPU task; elapsed includes any GPU submission/dependency waits | 0.336 | 0.618 |
| Dispatch lost contacts | CPU task; elapsed includes any GPU submission/dependency waits | 0.004 | 0.007 |
| Lost-contact completion stage 2 | CPU task; elapsed includes any GPU submission/dependency waits | 0.003 | 0.020 |
| Lost-contact completion stage 3 | CPU task; elapsed includes any GPU submission/dependency waits | 0.003 | 0.008 |
| Finish motion integration and solver tasks | CPU task; elapsed includes any GPU submission/dependency waits | 0.001 | 0.002 |

Scoped peak: repeat 1, step 417, complete advance 109.293 ms. CUDA-event timings measure stream intervals, including gaps; they do not establish SM utilization or hardware bandwidth limits.

Observer comparison: scoped mean 59.394 ms versus untraced repeat means 58.237–60.602 ms; scoped peak 109.293 ms versus untraced peaks 105.549–118.007 ms. This includes run variation and observer effects, not a correction factor. Thread CPU time for detailed migration leaves is intentionally unmeasured; the enclosing scope retains it.

Scoped versus first untraced counter history: complete run differs; through the scoped peak differs. Broken bonds: scoped 111555, first untraced 112900. These are separate trajectories, not a decomposition of the same measured peak.
