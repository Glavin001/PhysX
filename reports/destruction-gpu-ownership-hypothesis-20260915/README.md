# Test the removal of CPU fragment registration from corrected physics

Execution progress: [implementation plan and live checklist](PLAN.md).

2026-09-15. Experiment contract, based on saved measurements and source
inspection. Implementation has begun in isolation; see [current changes and
validation](IMPLEMENTATION.md). No application performance result is established. Selected
source `13b11af2` / runtime `d5770a80` remains unchanged. E1/E2/E3 are separate,
unpromoted prototypes. This document does not classify them as the completed
ownership migration. The user subsequently authorized a WIP branch checkpoint for handoff; source
patches and documentation are archived, while raw evidence remains local and ignored.

## Main hypothesis

**After fracture, GPU-produced body/shape ownership can directly supply collision
and rigid-body solver registration, removing CPU body construction and per-shape
registration as prerequisites for corrected physics. Eliminating redundant
registration, and overlapping any genuinely independent CPU observation work,
will materially shorten complete first-impact ticks.**

The central experiment is a complete fracture-to-corrected-physics path, with
sleeping enabled. Another reduction in readback calls or lookup visits is not a
test of this hypothesis. Moving the same CPU work to the end of a serial tick
is also insufficient: final publication remains inside the timed tick.

Confidence is high that the present CPU dependency exists. Confidence is lower
that enough of its cost is removable to produce the substantial application
benefit targeted below. Neither a GPU implementation nor the current profiles
prove that benefit in advance.

## Evidence and where a gain should appear

The [boundary audit](../destruction-cpu-gpu-boundaries-20260914/README.md) finds
that GPU fracture processing already computes motion slots, body mass/motion and
shape assignments. CPU `BodySim` creation and owner rebinding still gate corrected
physics. Rebinding includes filtering, contact retirement, narrowphase ownership
and actor links. Shape identity and geometry already persist.

In the September 14 instrumented City256 impact tick, CPU allocation and migration
occupy 15.605 and 51.995 ms with no recorded overlapping GPU activity. This exposure
scales with impact size. These are instrumentation-affected intervals in a
264.442 ms profiled tick, **not 67.6 ms of predicted production savings**. Its
ordinary impact window is about 90 ms per tick. Boundary warnings also preclude
claiming exhaustive hardware idleness. Compatibility copies themselves are tiny;
work required after the copies is the target.

Contemporary September 15 **control arms only**, from E3 confirmation and
uninterrupted checks, establish the following context. These are historical
reference values for this proposal, not a future candidate's performance control.
Means span independently started processes; peaks are observed maxima, not bounds.

| Scenario | Full-step mean range, ms | Observed peak, ms | 60 Hz misses | Role in this hypothesis |
|---|---:|---:|---:|---|
| City25 warm impact | 22.724–24.087 | 51.016 | 20/32 | Smaller-scale corroboration |
| City256 warm impact | 89.606–89.858 | 189.953 | 32/32 | Primary benefit target |
| City256 warm cascade, W55 | 104.271–105.282 | 144.856 | 32/32 | Repeated ownership / correctness guardrail |
| City256 warm late debris | 124.454–125.069 | 130.163 | 32/32 | Stress-dominated guardrail; large gain not assumed |
| City256 continuous idle | 1.430–1.712 | 14.156 | 0/1,200 | Sleeping / overhead guardrail |
| City256 continuous heavy | 50.808–51.011 | 184.139 | 1,038/1,200 | Real gameplay confirmation; peaks and mean reported separately |

City25 has 11,100 chunks / 22,400 original bonds; City256 has 113,664 / 229,376.
Continuous heavy launches 256 projectiles, idle none. Snapshot restore and the
fixed physical warmup are excluded; every measured full step includes commands,
CPU/GPU execution, transfers, synchronization, correction and final publication.
Continuous first-use ticks are retained. Setup and warmup costs remain recorded.

[Each snapshot arm's stages, preparation and work](../destruction-ownership-implementation-20260915/e3-confirmation.md)
and [each continuous arm's stages and histories](../destruction-ownership-implementation-20260915/e3-continuous.md)
remain the detailed sources. The nine-window cascade above uses W55; the September
14 full52 cascade uses W47. Do not interchange them. September 14 City64 impact
(28,416 chunks / 57,344 bonds) provides an additional scaling companion, with
28.301–28.641 ms means, 57.795 ms peak and 22/32 misses in that separate cohort.

The substantial opportunities are **removing repeated ownership reconstruction,
avoiding retirement/recreation caused solely by the registry representation, and
removing the associated CPU scheduling barrier**. These overlap; their potential
savings must not be added. Required physical contact changes remain mandatory.

## In scope

- One private ownership transaction carrying current body/shape IDs, generations,
  motion/mass and changed ownership to collision and solver consumers. GPU-generated
  assignments remain authoritative for this internal simulation path.
- Change every pre-correction consumer of those assignments needed by the supported
  rigid-body destruction scenes: filtering, pair lifetimes, narrowphase/solver
  registration, affected island membership and activity/readiness/wake information.
  Do not submit corrected physics while any such consumer still sees an old owner.
- Remove API-induced duplicate rebuilding. Retain a contact record only after
  proving its dependencies remain valid; changed mass/ownership still requires
  current response constraints and impulses. Stable IDs alone do not prove validity.
- Separate internal simulation registration from ordinary CPU actor/query
  observations. Preserve existing public API visibility boundaries, callbacks,
  sleeping, wake commands and interactions with ordinary rigid bodies. Finish
  all required CPU publication before the accepted tick returns.
- Capacity reservation/growth, slot reuse, generation validation, object lifetimes,
  stream ordering, teardown and failure handling for the new transaction. Include
  runtime growth and any added CPU or GPU work in timing and memory accounting.

Required affected-body sleep/wake consumers are part of correctness. A global
migration of every contact island is not a prerequisite milestone for this
experiment. Keep unrelated legacy consumers and their eligibility restrictions
until they are replaced and independently qualified. If an unavoidable shared
consumer prevents the bounded path, identify that blocker explicitly before
expanding scope; do not claim a smaller handoff test implemented this mechanism.

## Out of scope

- Changing stress algorithms, convergence tolerances, precision, material strength,
  fracture criteria or integration order to obtain the timing result.
- Disabling sleeping, requiring Direct GPU API, processing stale contacts, skipping
  required correction, or exceeding the one-correction-per-tick limit.
- General PhysX collision/solver mathematics changes, new joints/articulation
  support, or a universal replacement of CPU scene management.
- Global contact-island/sleep ownership migration beyond the affected path above.
  In particular, simply deleting the sleeping eligibility guard is not this fix.
- More lookup, copy-count or setter micro-optimizations as substitutes for migration;
  broad kernel tuning, Tile/Tensor Core rewrites, stress-factor work and unrelated
  topology optimization belong to separate hypotheses.
- Renderer/frame presentation, faster snapshot restore, artificial priming, or
  moving recurring work into unmeasured setup or a later tick.

## Acceptance contract

The following numeric thresholds are **chosen engineering acceptance targets**,
not measured savings forecasts or an already calibrated guarantee of precision.

1. **Mechanism:** instrument the complete transaction and its consumers. Corrected
   physics must consume current fractured ownership without waiting for the legacy
   per-fragment CPU body/contact-registration chain. Show which actual allocations,
   visits and rebuilds disappeared, and account for every replacement operation.
   A CPU task renamed, deferred, or hidden in publication does not satisfy this gate.
2. **Physics:** preserve current physics → stress/material → optional corrected
   physics → second stress/material → publication, with at most one correction.
   Pass unchanged physical tolerances and discrete fracture/membership checks,
   ordinary-body contact/filter/callback behavior, sleep/wake, queries and snapshot
   round trips. Compare canonical membership rather than arbitrary internal IDs.
   Check contact creation/removal, simultaneous cuts, second-pass ownership,
   slot reuse and capacity growth. No changed physical workload is accepted as
   evidence of a scheduling speedup.
3. **Substantial performance:** reduce the mean complete-step time in the existing
   City256 impact window by **at least 10 ms**, approximately 90 → 80 ms or better
   at the present scale. The window is snapshot40 + W42/M8, nominal ticks82..89;
   use every scheduled tick, including its first measured tick. Require independent
   matched confirmation whose 95% interval for the mean saving lies at or above
   10 ms. Neither faster kernels nor a favorable single peak satisfy this criterion.
   Report all observed peaks and deadline misses, even if unchanged. A reduction
   below this threshold may be useful, but does not establish this substantial-win
   hypothesis and must not silently replace its primary outcome.
4. **Real-time guardrails:** run the nine fixed warm cases plus uninterrupted
   City256 idle/heavy. Use a per-scenario mean regression margin of
   `max(0.2 ms, 2% of its matched control mean)`. Require confirmation that the
   candidate's regression is within the margin, using simultaneous 95% intervals
   across these guardrails and independent process/trajectory replicates. Failure
   to establish that is inconclusive, not equivalence. Investigate any repeated
   peak or deadline-miss increase at the same physical tick; no unresolved
   systematic regression is eligible for promotion. Report City25 and City64
   scaling, even when they show no gain. Historical timings cannot serve as the
   contemporaneous control arms.
5. **Final qualification:** all52 warm physical cases and relevant cold companions,
   plus uninterrupted physical-trajectory comparison under the existing regression
   contract. Add full per-tick physical-state comparison in separate untimed
   correctness runs for the affected ownership paths; existing continuous work
   counts alone are insufficient. Audit full52 timings for additional regressions
   and independently resolve flagged cases against the same margin before promotion.
   Validate memory accesses, initialization, synchronization, lifetimes and bounded
   storage. The existing baseline initialization failures remain an open defect;
   matching their counts does not waive them. Diagnose/fix failures affecting the
   ownership path before promotion and explicitly report remaining unrelated gaps.

A full 60 Hz result is not claimed as the expected outcome of this single change.
Sustained stress solving remains a separate major bottleneck. An impact-specific
win may lower fracture peaks without substantially changing the 600-tick average.

## Bounded execution and stop rules

First implement and validate one complete transaction through corrected physics
on a supported fracture fixture, including sleep/wake. Use correctness and work
counts during intermediate edits. Do not repeat full52 qualification for another
readback-only foundation. CPU compatibility work may remain only where its actual
consumer requires it; profile whether it overlaps or still extends the full tick.

Then use the existing nine-case warm screen, choosing first-impact Systems and
targeted counters for the new path. Recent actual screens took approximately
279–307 seconds plus exports; this is a feedback budget, not a precision guarantee.
Follow the [fast measurement reference](../../.agents/skills/physx-destruction-performance/references/fast-warm-measurement.md).
Preserve the selected control; build a coherent isolated candidate. Do not stack
E1/E2/E3 automatically. Record any reused foundation explicitly in the candidate.

Before confirmation, freeze source/modules, snapshots, schedule, checker, selected
profile ticks, randomization and statistical analysis. Use a fixed six independent
paired process blocks for primary/guardrail confirmation, balanced in run order,
with equal schedules per arm and no optional stopping. The simultaneous interval
method must account for the declared guardrails and correlated ticks. Six pairs
are not a promise of a narrow interval: an inconclusive result stays inconclusive.
Any further campaign needs a separately recorded fixed design, retaining all
previous results. Full qualification and confirmation are outside the per-edit
five-minute screen.

Refute the performance mechanism if replacement GPU work plus remaining CPU
publication cancels the saving, or if mandatory CPU registration still gates the
same correction. A correct, neutral architectural change can be retained locally
with a named future use, but not reported as a substantial runtime win. After
three unsuccessful implementations in the same family, reassess the diagnosis
and change approach rather than continuing small variations.

Record all scenarios' means, observed peaks, misses, stages, preparation, work,
memory, correctness, exact identities and profile locations. Keep raw data ignored.
This contract is unchanged by the implementation work. Current builds and native
checks are recorded separately; they do not establish the main mechanism or a gain.
