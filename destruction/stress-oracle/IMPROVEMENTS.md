# Improvements under proof

Every change to a method of the reference solver goes behind a switch whose default is
the established method, and is adopted (its default flipped) only when its A/B diff over
the scene catalogue and the test suite meets the bar of its class. This file is the
ledger: what each switch replaces, why, the evidence, and its status.

## Protocol

1. **A switch.** A field of `sim.methods` (`scene.rs`, `Methods`), default off. It is
   set like a model switch: `--feature NAME=on`, `--set sim.methods.NAME=true`, or for a
   whole run of the test suite or the catalogue `STRESS_METHODS=NAME,NAME` (the default
   of every scene that does not set `sim.methods` itself; written scenes omit
   `sim.methods` while it is at the established default).
2. **The principles** (`tests/principles.rs`): laws every faithful simulation obeys
   whatever its internals, which a cap, a regularisation or a hand-picked constant
   fails even when every benchmark gate passes: bit-exact reproduction under a change of
   units, invariance under uniform velocity and rotation, Coulomb friction (sticking
   without creep, the sliding acceleration, the stopping distance, all independent of
   mass and substep), a box resting flat with only its elastic compression, and
   convergence with the substep and the frame step.
3. **An A/B run.** `stress-ref ab scenes golden --feature NAME=on [--json out]` runs
   every benchmark scene both ways and prints, per scene, every gated metric against
   its oracles for A and B (a metric passing in A and failing in B is a regression and
   fails the command), every recorded value's change, and wall time and substeps. And
   `cargo test --release -p stress-ref --no-fail-fast` with and without
   `STRESS_METHODS`.
4. **Determinism.** `repeated_runs_are_bit_identical` passes with the switch on.
5. **Shadow mode** for anything that skips work: compute the decision, log it, check the
   full simulation never contradicts it, before acting on it.

| Class | Meaning | Bar |
|---|---|---|
| A, bit-exact | skipped work would have produced identical state | observations byte-identical |
| B, closed form | history advanced by formula | same events (kind, bond); times within one frame; continuous metrics within 1e-6 |
| C, outcome-exact | a proven bound shows no threshold is reached | same events, fragments, momentum; energy ledger closes |
| Step change | a different stable substep | within the refinement study (< 1 % on waves, < 10 % on fracture metrics); every oracle gate passes |
| Model change | the physics differs | every oracle gate passes; the diff report reviewed by a person before adoption |
| Fix | the established method violates a principle | the principle tests pass; every oracle gate passes or the change is explained |

## Ledger

### `layer_contact` (fix + model change)

**Replaces** sample-point penalty contact (`world.rs`, `penalty_force`, `pair_contact`):
box corners pulled in 10 % on all three axes plus face centres; stiffness shared per
point by hand-picked counts (`k / max(n, 10)` between chunks, `k / max(n, 5)` on the
ground, `k / min(n, 5)` for an impactor on the ground); a contact first sampled deeper
than `2 |v_n| dt + 1e-9` m turned into a zero-force offset; friction viscous below
1e-3 m/s and capped with the dashpots at `m_red / (max(n, 10) dt)`.

**Why** (`tests/principles.rs`, established method):

* A box set down flat rests on its single face-centre point (the pulled-in corners sit
  10 % of the half-height above the face): under a 5-degree sideways load it tips 6.7
  degrees, rocks at 1.4 rad/s and sinks 6e-4 m, 20,000 times its elastic compression.
* A block below the friction angle creeps forever (7e-4 m/s, `1e-3 m/s * tan t / mu`).
* A sliding block stops at half the Coulomb distance (it tips onto its leading edge).
* Results depend on the unit of velocity (`FRICTION_REGULARIZATION`).

**Method** (`polytope.rs`, `world.rs` `apply_layer_contacts`, `layer_force`): two bodies
in contact are rigid with an elastic layer between them (the elastic-foundation model).
The normal force is `k'' V` (overlap volume `V` of the two convex shapes, exact by
polytope clipping) at the overlap's centroid, `k'' = 1 / (h_a / E'_a + h_b / E'_b)`:
between two faces this is the stiffness of the joint they shared (`E A / L`, `E I / L`),
so a cracked joint and a contact behave alike. Friction is the shear layer
(`1 / (h_a / G_a + h_b / G_b)` per area) anchored to the contact, with Coulomb's cap by
return mapping (tangential and torsional), so a stuck contact holds with no slip rate.
Dashpots from the coefficient of restitution, uncapped: the contact substep resolves the
damped oscillator. The contact normal is the area-weighted outward normal of the other
body's surface inside the overlap (continuous in the geometry); the overlap's new faces
are chained from the clipped faces' edges (no sorting, tolerance or reference axis).

Found and fixed while proving it: a least-penetration (SAT) normal flips between axes
on round-off where aligned edges overlap (a 90-degree jump in force direction); a
polygon built by sorting in an axis-dependent basis with a 1e-12 tolerance made results
depend on the orientation of the world axes at 1e-8.

**Evidence** (principles, with `scaled_step_bound` also on): all 8 pass. Coulomb
acceleration exact (0.00 %) at three masses and two substeps; sticking creep 1e-20 to
1e-12 m/s; stopping distance 0.1019 m in 0.204 s (Coulomb 0.1019 m, 0.204 s); resting
sink 3.00e-8 m (elastic 3.01e-8); rescaling every unit bit-exact with fracture; uniform
velocity and rotation within round-off with fracture.

**Energy ledger** (fixed while proving it). The contact dissipation is booked from the
work the contact forces actually did on the motion the integrator produced (force at
the start of the substep, velocity at its end) less the change of what the contacts
store, plus the energy joints hand to contacts at a split (`ContactLedger::work`,
`received`). The force law's own first-order tally is kept as a diagnostic
(`modelled`, and per kind of contact in `kinds`). `conservation.rs` checks the second
law for contacts: their net dissipation never falls frame to frame.

Bugs found by the ledger and fixed:

* Friction state stored as a slip that the current stiffness multiplies: when the
  contact area shrank (stiffness to near zero) the slip held the dashpot's share divided
  by that stiffness, so the torsional "twist" reached 160 rad and the booked
  dissipation 6.8e8 J on a 4e4 J impact. The shear layer now stores its elastic force
  (Mindlin-Deresiewicz incremental form). New contact area enters unstrained, and area
  leaving takes its share of the force, so `F^2 / 2k` never grows without work. While
  sliding, Coulomb's slider is in series with the layer (spring and dashpot in
  parallel): `k e + c de/dt = mu F_n`, by backward Euler. This is continuous with
  sticking at the threshold; setting the spring to the capped total was not, and let
  round-off decide which side a contact landed on.
* Sphere impactors: every chunk the ball touched got a full spherical cap against the
  plane at its nearest point, so caps double-counted across chunk edges and the force
  was not the gradient of any energy. It put about 2.1e3 J (5 % of the initial energy)
  into a 40 m/s impact. Replaced by the exact ball-polytope overlap in closed form
  (`LayerContact::with_ball`, divergence theorem over the faces cut by the ball's
  discs). It is cancellation-free for shallow caps: a cap of depth `1e-6 r` is exact to
  round-off. A centre on a face, edge or corner takes the principal value plus the
  singular point's solid-angle share. An empty or full disc region is decided exactly:
  round-off "ghost" contacts with arbitrary normals once gave a 7e7 N kick.
  Tests: equal to the cap on a face; half, quarter and eighth ball at a face, edge and
  corner; additive over a split box; brute-force column integration to 3e-7.

Evidence (free wall hit by a 50 kg ball, both switches as stated; residual =
(mechanical + dissipated - initial) / initial at the end; Courant safety 0.5 / 0.25 /
0.125):

| case | `layer_contact` | `+ scaled_step_bound` | established |
|---|---|---|---|
| 5 m/s, elastic | -4.8e-3 / -2.4e-3 / -1.2e-3 | -8.4e-3 / -4.2e-3 / -2.1e-3 | +6.6e-4 / +3.3e-4 / +1.6e-4 |
| 40 m/s, fracture | -8.1e-3 / -3.4e-3 / -1.3e-3 | -1.6e-2 / -6.9e-3 / -2.8e-3 | -3.5e-3 / -1.3e-2 / -2.2e-2 |

The new contact's residual is a loss and halves with the step (first-order integration
error, no energy created). The established method's residual with fracture grows as
the step is refined (-0.01 % at Courant 1 to -2.3 % at 1/16): its ledger is inconsistent.

**Open, pair contacts (chunk on chunk):** the force law's tally exceeds the actual
work by about 1.8e3 J in the fine-step limit on the 40 m/s impact (17 % of the pair
dissipation): the elastic force is not the gradient of its energy. Cause: the
area-weighted normal tilts by `delta L / A` where one face overhangs the other's edge,
which gives a tangential force `k delta^2 L`. The energy `k delta^2 A_overlap / 2` has
gradient `k delta^2 L / 2`. Fix in progress: the energy `k int s dV`, `s` the depth below
each body's nearest face (`polytope::field_cells`). By the divergence theorem its exact
gradient is `k V_f n_f` per nearest-face cell, averaged over both bodies' fields; the
first wiring of it is not yet right and is not in use.

**Open, frame invariance with fracture** (`a_rigid_rotation_of_the_scene_rotates_the_result`):
the rotated run departs by 1.3e-4 m against a round-off envelope of 1e-9 (4e-2 before
this session's fixes; without fracture 8e-13). Something in the fracture path amplifies
round-off beyond the envelope; to bisect.

**Status:** catalogue A/B to rerun after the pair-contact fix.

### `scaled_step_bound` (fix, step change)

**Replaces** the Gershgorin bound of `chunk_stable_dts` / `chunk_frequencies`, whose row
sums add stiffness entries in N/m and N/rad (the kinematic row's L1 norm adds a
dimensionless direction and a lever arm in metres): the critical substep changed by
1.30-1.43x when the unit of length was halved.

**Method:** Gershgorin rows of the mass-normalised `M^-1/2 K M^-1/2` (the same
eigenvalues as `M^-1 K`), each entry divided by the square roots of its degrees of
freedom's inertias: unit-consistent and still an upper bound. Rotations use the smallest
principal moment (conservative).

**Evidence:** substep ratio exactly 1 under rescaling of length, time and mass on the
small impact, the frame and the masonry wall; the "length constant at chunk removal"
(frame b8 diverging when its column is removed) was this bound, recomputed for the new
clusters. The bound is 1.8-3.4x larger on those scenes (the old one was conservative in
metres): stability to be confirmed by the stability harness (item 1 below).

**Status:** catalogue A/B and test suite running.

## Open (from the audit and `CPU Oracle Improvements to Prove First`)

| # | Change | Class | Status |
|---|---|---|---|
| 0 | Instrumentation: work counters, binding limit of the step, adaptive decisions | - | to do |
| 1 | True stable step (power iteration on the explicit update itself) and a per-frame contact step from the contacts that can engage; stability harness (`examples/stability.rs`) | Step change | to do |
| 2a | Joint contact patch only after first damage | Model change | to do |
| 2b | Cold-bond fast path (exact variant first) | A, then bounded | to do |
| 3 | Direct (sparse Cholesky) solve for intact islands | Exact | to do |
| 4 | Sleeping with closed-form fatigue | B | to do |
| 5 | Energy certificate for settling and waking, shadow first | C | to do |
| 6 | Spanning-forest split test; split, drift and rigid-acceleration cadences; per-island substeps | A to bounded | to do |
| 7 | Multigrid statics prototype | exact to tolerance | to do |
| 8 | f32 mirror of the hot kernels (not the whole crate) | bounded | to do |
| 9 | Damping study (measure first) | Model change | to do |
| - | Strain-rate filter exact (`1 - exp(-dt / tau)`) | Fix | to do |
| - | Joint contact springs at the patch edges (outer spring at 0.417 w, rocking 17 % low) | Fix | to do |
| - | Adaptive wake on per-bond utilisation, not summed force norms | Fix | to do |
| - | Settle and refinement energy booked, not discarded | Fix | to do |
| - | `split_release`: hand the joint's compression to the contact (consistent with `layer_contact`) | Fix | to do |
