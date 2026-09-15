# Semantic scenarios and fixed-input replay

The2026-09-11 user direction refines the measurement objective: evaluate named physical events and structural traits, with fixed inputs, rather than deciding from idle/heavy averages alone. Existing full trajectories remain application and fidelity checks. This document specifies the next harness; it does not claim that complete tick restoration is implemented.

## State-transition contract

Conceptually, `(next world, accepted events) = step(world state, current commands, dt, settings)`. The current engine is stateful. Poses/chunks/bonds alone are not a complete state: velocities, sleeping/wake state, contacts and persistent solver state, topology/material damage, queued commands, original-input/correction bookkeeping and ownership/lifetime mappings can affect the next result. Warm starts, valid caches and allocated capacity also affect cost. Implementation-defined addresses and layouts are not a portable scenario contract.

A complete snapshot must close over every input read before accepted publication, restore or validly rebuild all mutable dependencies, establish stream readiness, and prevent changes from one repetition leaking into the next. Parallel floating-point execution may still vary; conceptual purity does not promise bitwise determinism.

Maintain two clearly named replay levels:

1. **Complete tick:** begin at an accepted tick boundary before that tick's command application. Run ordinary physics/current contacts, stress/material/fracture, at most one correction, second stress and accepted publication. A first-impact tick starts BEFORE physics discovers the contact. Timing includes all required CPU work, transfers, waits and GPU work.
2. **Stage replay:** capture actual native inputs immediately before a specific trial/correction stress evaluation. Replay the integrated numerical/material stage being tested and its required preparation. This isolates numerical/topology traits; it cannot establish complete-tick speedup or reproduce correction/contact discovery by itself. Use the current integrated backend, not the disconnected six-channel prototype.

The existing `captureRigidState` checkpoint preserves body/previous/acceleration arrays and destruction input ownership for same-tick correction. It is not a demonstrated full-scene restore of all contact/broadphase caches, host registration and destruction/material state. Existing `tools/diagnostics/destruction-load-capture` records real post-contact inputs but its replay explicitly omits complete native commands/material publication. Reuse its provenance and capture boundaries, not an unsupported claim of complete replay.

## Event vocabulary and initial suite

| Scenario | Defining event/state | What it teaches |
|---|---|---|
| Intact cold equilibrium | First gravity solve with required caches unbuilt | Initial solve and preparation cost |
| Intact quiescence | Equilibrated intact structure; no new commands/contact changes | Correct settled reuse and unavoidable per-tick overhead |
| First impact, no fracture | New projectile contact below failure threshold | Contact/load transfer and equilibrium without topology work |
| Fracture onset | First actual material failure under current contacts | Transition into topology/ownership work |
| Same-tick correction cascade | Fracture, corrected collision against fragments, second verdict | Full required dependency chain; additional second-verdict breakage |
| Continued penetration / secondary impact | Projectile meets new material or fragments meet new objects | Repeated contact discovery and changing loads; identify participants to distinguish the two |
| Loaded fractured structure, no new breakage | Existing fractured topology still requires equilibrium | Sustained numerical cost separate from topology changes |
| Fragment contact burst | Many independently moving pieces in contact | Fragment count, coordination, contact and publication cost |
| Post-fracture quiescence | Damaged topology has equilibrated, no new stimuli and a sustained stable/sleeping window | Reuse after fragmentation; it is not synonymous with late simulation time |
| Reawakening / support loss | Previously quiet damaged structure receives a new command or loses support | Invalidation, load redistribution and exactly-once handling |

Do not equate “first contact” with “first fracture”: retain both outcomes, even if the current bombardment fixture combines them. Keep snapshots at trial and corrected stress boundaries for a cascade, alongside its complete tick. Fracture is a discrete event: a small continuous-state error alone does not justify a different failure decision.

For each case record: authored and active chunks/bonds; stress-component count and size distribution; supported/free classification; live unknown-to-unknown and boundary bonds; graph degree and cycle rank; mass/stiffness/length-scale variation; moving/sleeping bodies; contact pairs and participants; broken bonds at each verdict; correction count; original-equation residual/quality settings; warm-start/cache/capacity policy. Define cycle rank on the unknown subgraph as `E_unknown - V_unknown + C_unknown`, with support-boundary edges counted separately. Degree/cycle count is not by itself a condition-number estimate.

Use a sparse coverage matrix, not every combination: small fragments, one existing444-chunk building, a moderate multi-building case, and the existing256-building city. Include many independent small components versus a large connected component, tree-like versus redundant/cyclic connectivity, supported versus free components, and difficult geometry/material scaling. Reuse existing analytic/3D/cap/topology tests as physical oracles; new authored fixtures need their own independent expected behavior. Do not silently change established fixture materials, tolerances or workloads.

## Selection and comparison rules

- Select semantic events from a frozen reference trajectory by physical predicates, then freeze their input/state hashes and selection rule BEFORE candidate timing. Candidate output or candidate timing must not select an easier tick. Use stable authored identities when comparing layouts with different internal IDs.
- Record snapshot schema, code/toolchain/modules, fixture/settings/commands and timestep, input hash, source trajectory/tick/evaluation, state inventory, restoration verification, and expected output/quality evidence. Invalidate incompatible internal caches instead of interpreting old pointer/layout bytes as a new implementation's state.
- Compare repeated A/A output variability with A/B variability, alongside independent physical bounds. Report residual/force/moment/response/energy and pose errors where meaningful; compare topology, fracture decisions, contacts and command/event multiplicity explicitly. Do not automatically widen tolerances to baseline noise or average away a wrong discrete event.
- Benchmark one GPU candidate at a time. Restore the same case before each repetition. Report warm and required-rebuild cases separately. Benchmark-only restoration is outside the tick timer and reported separately; mandatory application preparation/cache construction stays charged. A warm-start optimization must receive a documented common input history, with its construction/amortization measured. Do not erase its history or give it free precomputation.
- Each semantic case reports repeated complete-tick median/mean/tail/max with sample count; stage intervals, transfers/bytes and waits; physical-quality results; and structural metadata. Show improvements AND regressions. GPU intervals nested in CPU waits are not additive. A maximum remains sample-count dependent; a single frozen frame does not represent all frames sharing a label.
- Keep complete multi-tick idle/heavy runs, setup-plus-trajectory totals, exact budget counts and trajectory fidelity checks. Snapshot tests diagnose mechanisms and reduce input drift; they do not replace cold setup, repeated invalidation, sustained throughput or accumulated-trajectory validation.

## Evidence available now

`semantic-frame-manifest.json` identifies useful existing reference frames. `semantic-frame-report.json` compares the SAME frame indices in N14's existing A/B runs. These are **trajectory-frame measurements, not identical-input snapshot replays**. Matching physical counters do not prove identical complete input state. The manifest's predicates validate coarse labels; projectile-specific contact identity and actual penetration need richer capture.

N13's600-step heavy run still has1117 awake bodies,12484 reported contacts and532 stress iterations at step599. No post-first-impact frame has zero awake bodies. The current suite therefore has no demonstrated post-fracture quiescent snapshot; waiting a fixed600 steps is not a valid substitute for detecting that state.

Next implementation order: native state-read inventory and manifest/semantic event tags; integrated stress-stage replay with complete operator/load/warm/material inputs; validated complete-tick restoration where feasible; otherwise an explicitly labelled replay of a fixed prefix to each selected tick as a transitional full-tick measurement. Verify restoration by continuing both an untouched control and a restored world through the selected tick and subsequent ticks. Then add missing event/scale cells and use the suite to rank the remaining experiments. No new optimization candidate is promoted on the new labels alone.
