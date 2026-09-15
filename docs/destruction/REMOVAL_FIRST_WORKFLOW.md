# Removal-first destruction optimization

Agreed with the user on 2026-09-13. This is the current development policy;
dated experiment and calibration reports remain unchanged. Follow
[OPTIMIZATION.md](../../OPTIMIZATION.md) for commands, GPU isolation and the
existing numerical, physical and final qualification gates.

## Objective and order of work

Deliver a complete accepted simulation tick within 1000/60 ms while preserving
the required destruction fidelity. Optimize CPU preparation, GPU execution,
communication, synchronization, ownership updates and required setup together.
The pipeline remains current physics/contact results → stress/fracture → at
most one correction → second stress → accepted publication. Use ordinary PhysX
APIs with sleeping enabled. Never substitute stale contacts or defer required
equilibrium to a later tick.

Prioritize substantial application savings. The measured baseline includes
continuous heavy means around 55 ms, a tower around 109 ms and large restored
debris around 362–383 ms. These require qualitatively different improvements;
there is no evidence that a chain of tiny arithmetic changes can close the gap.
[Exact scenarios, sample schedules, maxima, stages and limitations](../../reports/destruction-baseline-20260913/measured-experiment-protocol.md).

Investigate, in order:

1. Unnecessary or duplicated work, and work whose complete inputs have not changed.
2. Data ownership and avoidable CPU/GPU round trips.
3. Algorithms and reusable asset/operator preparation.
4. Parallel decomposition, component scheduling and data layout.
5. Instruction, register, block-size and compiler tuning of necessary work.

This is a priority order, not proof that any proposed change helps. Read the
[existing removal/algorithm queue and failed experiments](../../reports/destruction-baseline-20260913/analysis-plan.md)
before repeating an idea. Existing GPU iteration loops, some exact settled reuse,
dynamic component scheduling and compact correction publication are already
implemented. N29 matching, N26/N27 lookup work and N24/N25/N30 numerical changes
have important negative results. Identify a different remaining cost before
reintroducing them.

## Count work to develop a hypothesis

Use existing profiles to identify the critical path. Then collect the smallest
set of counters that can prove or refute the proposed mechanism. Do not require
a statistically resolved 1% full-step improvement before accepting that an
intermediate implementation removed a scan, transfer or dependency.

| Work category | Useful accounting | Interpretation constraint |
|---|---|---|
| Stress solving | Components solved/skipped, iterations per component, node/bond visits, operator evaluations | Existing maximum-iteration fields are not total work; kernel launches can contain many iterations |
| CPU preparation | Actor/contact visits, records produced, sorts, ownership/topology rebuilds | Count actual executed visits and identify the producer/consumer; theoretical opportunities are not measured counts |
| Communication | Transfer count and bytes in each direction, readbacks, synchronization points | Logical bytes, memory transactions and elapsed transfer time are different; overlap matters |
| Lifecycle/setup | Allocation, registration, graph/factor construction and reuse | Charge necessary setup where the real application pays it; report amortization assumptions |
| Physical work | Contacts, active nodes/bonds/islands, fractures, corrections, convergence and damage | Equal counts alone do not prove equal trajectories, forces or material fidelity |

For every counter record its definition, scope, collection method, input and
binary identity, and whether it is observed, inferred or unavailable. This table
is an instrumentation contract, not a claim that every counter already exists.
Prefer existing cheap counters; add targeted instrumentation where needed and
keep expensive auditing outside production timing.

Many application counts are reproducible under fixed inputs and execution.
Hardware instructions/transactions can still depend on scheduling, cache state
and numerical execution. There is no universal scalar “compute operations” score:
fewer launches can reduce parallelism, and more GPU work can remove a costly host
round trip. Work reduction is mechanism evidence; it is not automatically a
complete-tick speedup.

An unchanged equilibrium input is not permission to skip accumulated damage.
Record separate validity/invalidation rules for load preparation, equilibrium,
material state, topology and API publication. Reused results must depend on the
complete current state required by that product.

## Evaluate one coherent bet

Each ranked hypothesis must state the existing evidence, mechanism, affected
scenarios, estimated application milliseconds saved, confidence, experiment
cost, and measurements that would support or refute it. Distinguish confidence
that work can be removed from confidence in the predicted elapsed-time saving.
Account for overlap and the untouched remainder of the critical path; do not
promise a 10× result from accelerating a small fraction of the step.

Develop the coherent change across C++ and CUDA as needed. Intermediate commits
can advance on correctness and proven work removal. An architectural change
with neutral timing can be retained with an explicit simplification or named
follow-up consumer, provided its qualification and remaining risks are clear.
Neither an enabling commit nor a counter reduction is an application-speedup
claim. Preserve the best verified implementation independently of experimental
branches and checkpoints.

For a completed mechanism:

1. Run the relevant unchanged correctness gates and compare mechanism counters.
2. Run a short matched full-step comparison and selected profiling. Reuse matching
   baseline profiles; collect new Systems/Compute data only to answer the current
   hypothesis. Do not restart exhaustive all-counter collection by default.
3. Report every measured scenario, including full-step mean/max, stage costs,
   deadline misses, work changes, setup and first-use behavior. Keep restored
   scenarios and continuous idle/heavy trajectories separate.
4. Spend additional timing repetitions on promising candidates whose application
   benefit remains uncertain. Freeze affected outcomes, practical millisecond
   margins, independent process-pair counts and statistical rules before the
   confirmation. Consecutive ticks are not independent trials. Do not rerun until
   a favorable result appears or label a nonsignificant difference equivalent.
5. Run full52 plus required numerical, memory and continuous trajectory gates
   for finalists. A light screen does not qualify the complete implementation.

The [nine-scenario profiled procedure](../../reports/destruction-baseline-20260913/measured-experiment-protocol.md)
has a measured 284.09-second GPU-exclusive pipeline, plus separately measured
1.30–1.40-second preflight. It is a representative completed-bet screen, not a
mandatory cost for every edit and not a guarantee of resolving tiny effects.
The six-pair calibration exposes noise limits and an idle false signed signal.
Use confidence/equivalence gates where needed; counters can establish removed
work without a timing significance test. Restore/validation/export stay outside
tick latency while their cost remains in harness-turnaround reporting.

Record every experiment's commit, hypothesis, correctness, repeated controls and
candidate results, profile locations and conclusion. After three unsuccessful
experiments in a family, reassess the diagnosis, research implementations and
change approach or target. Do not silently relax a failed gate. A deliberate
precision compromise requires a documented physical-quality budget and separate
qualification, as authorized by the user; it is not an equal-quality speedup by
default.

## Durable reporting and resumption

Follow the [performance skill](../../.agents/skills/physx-destruction-performance/SKILL.md)
and [reporting skill](../../.agents/skills/insight-reporting/SKILL.md). Store report
packages under `reports/<headline>/`, including compact data, commands, plots,
source identities and locators for large raw captures. Update the report index.
The user explicitly excludes raw experimental evidence from Git: keep raw
measurements, captures, logs and generated datasets in ignored local paths.
Commit readable reports/plots, reproduction code and concise provenance. Do not
force-add ignored evidence; distinguish locally available data from clone contents.
Preserve failed attempts and mark unbuilt, unqualified, rejected and promoted
states distinctly. A save/checkpoint request does not authorize restarting a
paused experiment or promote the main workspace to the selected baseline.

The supplied CUDA guides are archived in
[the baseline report](../../reports/destruction-baseline-20260913/evidence/guides/).
Their recommendations and fixed profiling thresholds are hypotheses, subordinate
to the user's fidelity and application objectives. NVIDIA's
[CUDA Best Practices](https://docs.nvidia.com/cuda/cuda-c-best-practices-guide/)
and [Nsight Compute profiling guide](https://docs.nvidia.com/nsight-compute/ProfilingGuide/)
explain the complementary roles of counters, memory behavior and elapsed timing.
