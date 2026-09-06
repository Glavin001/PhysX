# Native GPU destruction MVP

The immediate deliverable is a working native impact simulation and recorded demo.
A reusable public library, game integration and maximum-scale qualification follow
this proof. The native split/correction path is not complete yet.

## End-to-end acceptance

The demo advances physics only through the normal PhysX scene simulate/fetch
lifecycle. Inside that lifecycle the engine must:

1. Checkpoint the supported scene state on the GPU and solve the intact trial.
2. Route actual solved normal/friction impulses to the existing CUDA stress and
   material model, then apply its fracture verdict through GPU connectivity,
   cluster mass/inertia and motion preparation.
3. Apply persistent collision ownership, restore the checkpoint for all affected
   participants (initially the complete supported scene), rebuild collision and
   solver work, and execute **at most one correction/resimulation**. This means
   one trial plus one corrected solve on a fracturing step. Stress iterations are
   independent of this limit. No predicted breakage or substitute breakable joints.
4. Accept the corrected state and publish once. The corrected pass must not apply
   the first verdict's damage, commands or gameplay callbacks a second time.

Supported-state restrictions must be explicit errors, not silent omissions from
rollback. Begin with a supported rigid-body impact fixture; expand supported
interactions only with end-to-end evidence. Native task scheduling, allocation
and PhysX collision/island metadata still involve CPU code. Contact-load assembly,
stress/material evaluation, connectivity, mass/inertia, motion preparation and
rigid-state checkpoint copies are CUDA work. Eliminating all host bookkeeping is
not a prerequisite for the native proof and is not a claim of this MVP.

## Required proof

- An intact-wall control and a destructible-wall impact demonstrate different
  projectile responses caused by the actual impulse-driven fracture verdict.
- Stable chunk collision identities resolve to accepted new cluster owners; the
  fragments continue colliding and simulating over subsequent steps.
- Verify pre-step motion restoration, momentum/point-velocity transfer, normal and
  friction loads, one-correction maximum, and no duplicate damage/events.
- A standalone demo in this repository uses the native path, with a 30–60 second
  multi-structure bombardment recording after the impact fixture passes. Identify
  the backend and record chunk/bond counts, correction counts and timing. The
  earlier reference-adapter videos do not satisfy this gate.
- Keep simulation correctness and measured speed separate. A recording is not
  evidence of strict 60 Hz or of 100,000-chunk performance.

## Work order

1. Finish native ownership application and persistent fragment lifecycle.
2. Connect the full supported-state rewind and one internal corrected solve.
3. Commit topology/material/motion and expose accepted observations once.
4. Pass the impact proof, then record the native demonstration.

Existing CUDA contact/stress/material, topology, mass/motion, allocation,
checkpoint and collision-preparation tests establish components, not this complete
path. Trial callback suppression now passes synchronous and split-fetch tests,
including withholding a provisional joint-break verdict.

Defer public API/package polish, Rust/WASM/game migration, selective correction,
additional correction passes, the five-trial scaling campaign and broad engine
feature coverage until this vertical path works. Preserve the full-plan backlog
and its known fidelity failures; do not weaken assertions to declare MVP success.
