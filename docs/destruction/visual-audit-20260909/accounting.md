## Exact accounting appendix (generated)

Dataset A, tick 48; all nonzero disjoint scopes. Denominator: **145.463127 ms** profiler bracket.

| Responsibility | Owner / interpretation | Disposition | ms | % of bracket | Calls |
|---|---|---|---:|---:|---:|
| Resimulate changed interaction | CPU task scheduling + GPU collision, constraints and motion solve | opt | 52.364950 | 35.99878% | 1 |
| Host dependency containing GPU destruction | CPU blocked/spinning until required GPU work completes; not extra GPU work | gpu | 31.709998 | 21.79934% | 2 |
| Trial + commands + observations / uncovered tasks | Trial physics, commands, accepted consumer observations and unclassified task/driver gaps (A) | unknown | 22.751891 | 15.64100% | remainder |
| Create compatibility records for selected fragments | CPU PhysX body/lifecycle records at GPU-selected indices | replace | 11.800076 | 8.11207% | 2 |
| Shape migration remainder (unresolved) | CPU validation, target storage and gaps around instrumented migration operations | unknown | 9.605889 | 6.60366% | remainder |
| Update persistent query-owner observation | CPU owner-lookup and compatibility shape-array updates; query geometry, handles and bounds persist | replace | 3.571720 | 2.45541% | 10376 |
| Accept corrected step | GPU topology/motion commit and required status completion; older captures include CPU property publication | keep | 2.652995 | 1.82383% | 1 |
| Retire old-owner contact managers | CPU releases shape interactions, contact managers and lost-touch bookkeeping | replace | 2.546379 | 1.75053% | 10376 |
| Update narrow-phase ownership mirror | CPU updates persistent narrow-phase owner references; no geometry upload | replace | 2.074457 | 1.42611% | 10376 |
| Validate fragment owners and shape identities | CPU validates the migration batch against compatibility actors and persistent shapes | replace | 1.508613 | 1.03711% | 2 |
| Other ownership bridge work | GPU-to-CPU metadata observation, completion waits and remaining host bookkeeping | unknown | 1.278963 | 0.87924% | remainder |
| Update shape/actor links and query-bound membership | CPU transfers element ownership and registers query-bound tracking | replace | 1.217664 | 0.83709% | 10376 |
| Mark changed collision filtering | CPU broad-phase lifecycle bookkeeping for migrating persistent shapes | replace | 0.504828 | 0.34705% | 10376 |
| Activate fragment scheduler metadata | CPU updates kinematic/dynamic type and wake/island bookkeeping; physical state is GPU-owned | replace | 0.498259 | 0.34253% | 2 |
| Preparation verdict observation (historical) | CPU observes GPU initialization/collision/correction verdicts; includes completion wait (A) | unknown | 0.382673 | 0.26307% | 2 |
| Submit contact loads and destruction | CPU queues GPU loads, stress, material and topology work | opt | 0.333643 | 0.22937% | 2 |
| Grow native motion address capacity | CPU grants unused indices; GPU storage allocation/upload; no spare simulated bodies | keep | 0.171420 | 0.11784% | 2 |
| GPU slots / selected-request observation | GPU compacts and assigns slots; GPU → CPU selected indices/metadata and completion dependency | replace | 0.131325 | 0.09028% | 2 |
| Other reservation bookkeeping | Uninstrumented remainder within CPU reservation scope | unknown | 0.080689 | 0.05547% | remainder |
| Submit fragment initialization | CPU dispatch/lifecycle; GPU initializes and validates without a stage-local readback | keep | 0.077845 | 0.05352% | 2 |
| Rewind and install fractured motion | CPU dispatch + GPU checkpoint restore and owner installation | keep | 0.073075 | 0.05024% | 2 |
| Prepare chunk collision ownership | CPU dispatch + GPU persistent-shape ownership preparation | keep | 0.048000 | 0.03300% | 2 |
| Prepare corrected motion states | CPU dispatch + GPU cluster/body preparation | keep | 0.032721 | 0.02249% | 2 |
| Validate compatibility registration | CPU dispatch → GPU failure merge; preserves device allocation verdict | keep | 0.014648 | 0.01007% | 2 |
| Other destruction completion bookkeeping | Remaining host scope around destruction completion | unknown | 0.014486 | 0.00996% | remainder |
| Checkpoint moving-body state | CPU submission → GPU copy; save state for possible rewind | keep | 0.008245 | 0.00567% | 1 |
| Invalidate incompatible contact caches | CPU dispatch + GPU contact/friction cache reset | keep | 0.007675 | 0.00528% | 1 |
| **TOTAL** | | | **145.463127** | **100%** | |

Percentages may round; all unrounded durations reconcile. Unknown/remainder scopes are retained, not assigned to GPU or assumed removable.

### Complete timer and native engine (same tick)

| Measurement | ms |
|---|---:|
| commands_and_pre_step_ms | 0.000270 |
| native_physics_and_destruction_ms | 132.111269 |
| game_observation_events_ms | 13.350094 |
| accepted_status_and_snapshots_ms | 0.000081 |
| complete_step_ms | 145.461714 |
| Profiler outer bookends beyond complete timer | 0.001413 |

### CUDA intervals (overlap the wall accounting)

| Stage | Trial ms | Corrected/final ms | Sum ms |
|---|---:|---:|---:|
| Convert solved contact impulses into chunk loads | 0.098304 | 0.182272 | 0.280576 |
| Iterative stress solve to convergence | 11.509760 | 19.000320 | 30.510080 |
| Evaluate material damage and fracture | 0.072704 | 0.066560 | 0.139264 |
| Connectivity, cluster mass and fragment candidates | 0.481280 | 0.476160 | 0.957440 |
| Commit changes and rebuild stress topology | 0.049152 | 0.042208 | 0.091360 |

### Selected steps from the same timing capture

| Tick | Complete ms | GPU stress ms | Correction scope ms | Fragments | Awake fragments | Normal-contact count | New broken bonds |
|---|---:|---:|---:|---:|---:|---:|---:|
| 0 | 158.558196 | 3.824640 | 0.000000 | 0 | 0 | 0 | 0 |
| 48 | 145.461714 | 30.510080 | 52.364950 | 10,449 | 10,193 | 216,220 | 28,530 |
| 49 | 106.081589 | 36.383745 | 23.437398 | 11,366 | 11,110 | 298,458 | 4,174 |
| 52 | 57.934441 | 36.333569 | 4.872102 | 11,401 | 11,145 | 291,149 | 2 |
| 76 | 95.560887 | 44.345343 | 17.804788 | 14,342 | 14,056 | 343,325 | 2,519 |
| 78 | 98.492182 | 45.728767 | 23.796347 | 15,151 | 14,850 | 366,181 | 474 |

### Newer short screens (dataset C; no detailed phase decomposition)

256 buildings / 113,664 chunks / 229,376 bonds; 96 steps / 1.6 simulated seconds per run. Destruction executes 256 shots; separate fresh idle has zero shots. Direct GPU off, sleeping on, correction <=1. Two candidate runs shown; original receipt contains two baseline runs as well.

| Regime / run | Complete mean ms | All-step maximum ms | Fracture maximum ms |
|---|---:|---:|---:|
| shots / 1 | 37.526593 | 157.510123 | 133.376325 |
| shots / 2 | 37.465117 | 158.820887 | 131.157991 |
| idle / 1 | 2.075576 | 158.075105 | none |
| idle / 2 | 2.069204 | 156.768651 | none |
