# Measurement and optimization reasoning contract

Use with the [playbook](PERFORMANCE_PLAYBOOK.md). This records lessons from the
native RTX 4090 campaign, not general PhysX performance guarantees.

## The thing being optimized

Maximize verified physical destruction per **complete simulation advance**.
Keep physical timestep 1/60 second, actual impulse-driven fracture and at most
one correction per step. Primary target: every step <=8.0 ms; separately report
real-time at <=1000/60 ms. Neither an average nor p99 can substitute for the peak.
The whole game's tick, rendering and networking are a different budget.

The authoritative bracket begins **before recorded command application** and
ends when accepted motion/destruction state, mandatory status and committed
output are ready. Include projectile insertion/clearance, physics, stress,
material/topology, correction, synchronization and runtime capacity growth.
Exclude initial asset preparation/context creation, rendering, encoding and
report generation. Record initialization separately. Keep the first measured
step, first fracture and all allocation/scheduling spikes.

`complete_step_ms = command_ms + physics_step_ms + completion_ms` within recorded
timestamp tolerance. Inspect timestamp containment as well as that identity.
Profiler CSV flushing happens after the complete bracket, with explicit output
timestamps. Intrusive profiling can still perturb execution; use separate
untraced trials for the deadline.

## What a metric means

| Metric | Meaning / limitation |
|---|---|
| `complete_step_ms` | Authoritative wall elapsed for the whole advance |
| `physics_step_ms` | Narrower `simulate` through blocking `fetchResults`; excludes commands and mandatory post-fetch completion |
| `stress_solve_ms` | Historical compatibility field; zero does not mean free stress |
| CUDA `stress` interval | Destruction-stream elapsed interval, not CPU elapsed or a hardware utilization counter |
| Host `waitForGpu` / dependency scope | Includes preceding necessary GPU work; not all deletable waiting overhead |
| Process/thread CPU ms | Core-time accounting, not interchangeable with elapsed wall time |
| `bodies`, `awake_bodies` | Recorded registered/active runtime body observations, not authored chunks; inspect exact producer for a new use |
| `logical_clusters` | Connected shared-motion ownership groups, including supported groups |
| `stress_active_nodes/bonds/islands` | Committed stress topology membership, not total visits or unconverged work each iteration |
| `stress_iterations` | Maximum component iteration count, not sum across components |
| `contacts_frame` / normal contact loads | Recorded contact-load count, not unique broad-phase pairs or solver rows |
| `contact_pairs`, `solver_rows` | Legacy public counters can be incomplete for the direct GPU path; validate before use |
| `pre_solve_pairs` | GPU pre-solve contact-manager processing across trial/correction; not a substitute for every contact metric |
| `bonds_broken` | Actual per-step broken bonds in this demo; sum must match summary |
| Net new clusters | Fragmentation count, **not** detached chunks; useful alongside bond breakage |
| Launches/s | Input intensity, not measured destruction throughput |

Three partitions have distinct meanings: bond-connected **stress components**,
shared-motion **rigid clusters**, and contact/constraint **correction work sets**.
Do not substitute one partition's count or connectivity for another's.

## Explain every phase without double counting

| Responsibility | Current owner / interpretation |
|---|---|
| Commands | CPU submission and current actor creation/clearance observation; GPU physical execution |
| Checkpoint | CPU orchestration, device checkpoint storage/copies |
| Trial collision/rigid solve | Existing PhysX CPU tasks and GPU foundation |
| Contact-to-load, stress, materials | Integrated CUDA pipeline; host submission/completion spans include this device work |
| Connectivity/mass/motion | Device computation; ownership/compatibility lifecycle still has CPU dependencies |
| Fragment reservation/shape migration | Our CPU compatibility bridge plus GPU ownership updates; major burst exposure |
| Correction | Restore and repeated collision/solve plus CPU scheduling/contact lifecycle; one extra pass, not another simulated timestep |
| Acceptance | Device state/topology publication plus remaining host lifecycle completion |
| CPU observations/rendering | Explicit consumers; mandatory status belongs in complete time, optional recording/render output does not |

Use the analyzer's **disjoint** wall partition as the accounting basis. Its
parent spans and nested CUDA stages cannot be added again. Within correction,
island insertion and contact/interaction registrations execute in parallel;
summing their durations exaggerates elapsed cost. Even taking the longest task
is only a proxy without start offsets and dependency-critical-path analysis.
Likewise, sum of kernel durations across streams is not GPU wall elapsed; union
intervals and dependencies matter.

A final application completion wait is legitimate. Removing an intermediate
host branch may eliminate a handoff but cannot eliminate the preceding physical
calculation. A scope labeled `broadPhaseWait` is not proof that NVIDIA broad
phase is the optimization target.

## Ranking opportunities honestly

For each candidate record:

1. Code mechanism and work quantity it changes: new motion records, migrated
   shapes, created/retired contacts, component visits, copies or synchronization.
2. Measured parent/subphase exposure at **all relevant peaks**, with owner and
   overlap. Distinguish instrumented replay from the actual untraced step.
3. Necessary replacement cost and invalidation/lifecycle obligations.
4. Conditional removable fraction, explicitly an assumption until measured.
5. Effect on the *maximum over the whole run* after the next-slowest step takes
   over. Avoid ranking only by a local kernel percentage.
6. A falsifiable test, required physical oracle, effort and rejection condition.

A parent duration is a loose opportunity ceiling, not automatically removable
work. “15–30% of stress” is a scenario, not a calibrated confidence interval or
positive lower bound; the actual result can be zero or negative. Correlated
ideas share one budget. Do not add ownership handoffs to ownership savings,
selective-correction savings to all contact-lifecycle savings, or competing
preconditioners to each other.

The [ranked snapshot](../../qualification/peak-investment-review/report.md)
recalculates peak movement and tests the same assumptions against two controls.
Ownership leads both, but stress/contact rankings change. Do not copy its
millisecond estimates into a new workload without remeasurement.

## What can be learned without hardware counters

Available: complete wall time, CPU task timestamps, CUDA events, CUPTI
kernel/copy/API activity, compiler resource usage and optional intrusive
component work/cycle probes. Not established here: measured memory bandwidth,
cache hit rates, executed instruction throughput or actual occupancy counters.

A useful work model is approximately:

- stress: sum over components of iterations × executed sparse references,
  plus preconditioner, verification, local factor and reduction work;
- ownership: new/reused motion slots, migrated shapes and compatibility records;
- collision lifecycle: created/lost/reused pairs and required filtering;
- correction: affected contact/constraint closure, new candidates, rows rebuilt
  and restored participants;
- setup: changed components/nodes/bonds, hierarchy levels and copied bytes.

Measure these quantities rather than multiplying the total bond count by the
maximum iteration count. Count all traversals: historical outer-operator probes
omit the later polynomial-preconditioner traversal/inverse applications.

An optimistic hardware lower bound is `max(required_bytes / sustainable_Bps,
required_operations / sustainable_ops_per_s)` for independent streaming work.
It is **not an achieved floor**: dependencies, gathers, reductions, cache reuse,
precision and concurrency change both terms. Advertising peak bandwidth/FLOPS
cannot establish a useful floor for this solver. A task graph's longest
necessary dependency chain imposes another limit.

Use controlled experiments to distinguish hypotheses: vary independent
component count at fixed component size; vary component size at fixed total
work; measure sparse visits/iterations separately from topology and ownership;
compare required copies and device gaps. Microbenchmarks diagnose a mechanism;
retain an optimization only after complete-step and physical validation.

## Quality, schedule and capacity

Native within-solve convergence retirement is implemented. General
across-timestep settled-island reuse is not fully implemented. Zero new fracture
is not a reuse certificate: contact loads, supports, transforms, material/damage
state and convergence can still change. Rigid sleeping and structural activity
require different invalidation rules. Current frozen bombardment disables
sleeping and crushing; never present it as a sleep-qualified general workload.

Preserve geometry/ownership identity, mass/COM/full inertia, force couples,
point velocity and projectile causality. One correction is an intact trial,
actual-impulse stress verdict, ownership update, restore/recompute and one
accepted publication. More broken bonds is not itself better fidelity. Exact
controlled fixtures and analytic oracles matter; chaotic count agreement does
not establish identical trajectories.

For capacity, report input rate **and** actual broken bonds/new clusters per
simulated second, contacts, awake bodies, stress work and complete-step misses.
Include post-impact rubble, all launches and flight time. A staggered schedule
can reduce the burst but increase sustained work or total breakage. The latest
256-building experiment demonstrates exactly that. Full long-run qualification
and lifecycle endurance remain separate gates.

Every user-facing number should carry: scene size, chunks/bonds/projectiles,
duration/repeats, physical settings that matter, timer scope, and quality/
isolation limits. Prefer the generated report to hand-transcribed tables.
