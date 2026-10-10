# Improvements under proof

Every change to a method of the reference solver goes behind a switch whose default is
the established method, and is adopted (its default flipped) only when its A/B diff over
the scene catalogue and the test suite meets the bar of its class. This file is the
ledger: what each switch replaces, why, the evidence, and its status.

## Protocol

1. **A switch.** A field of `sim.methods` (`scene.rs`, `Methods`), off until proven. It
   is set like a model switch: `--feature NAME=on|off`, `--set sim.methods.NAME=true`,
   or for a whole run of the test suite or the catalogue `STRESS_METHODS` (`NAME` or
   `NAME=on` on, `-NAME` or `NAME=off` off, `established` for every established method;
   it adjusts the default of every scene that does not set `sim.methods` itself; written
   scenes omit `sim.methods` while it is at the built-in default). **Proven switches
   are on by default** (`Methods::proven`): `layer_contact`, `scaled_step_bound`,
   `exact_frame_transfer`, `contact_crushing` (DECISIONS.md 41).
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

**Every elastic layer force is the exact gradient of its energy.** Found by the
per-kind ledger (`ContactLedger::kinds`: the force law's own tally against the work
done, which must converge together with the substep for a conservative law):

* *Pairs* (chunk on chunk): the area-weighted normal tilts by `delta L / A` where a
  face overhangs the other's edge, a tangential force `k delta^2 L` where the energy
  `k delta^2 A_overlap / 2` has gradient `k delta^2 L / 2`. It created 1.8e3 J on the
  40 m/s impact, whatever the substep. Now (`pair_elastic`, `polytope::field_cells`)
  the energy is `(E_a + E_b) / 2`, each `E_x = sum_f k''_f int s dV` over the overlap's
  cells nearest each face `f` of body `x` (`s` the depth below it). By the divergence
  theorem its exact gradient is `k''_f V_f n_f` per cell at the cell's centroid, plus
  the interface integrals where neighbouring cells differ in stiffness, plus the torque
  of the stiffness turning with the bodies. The half-thickness along a direction is
  the smooth `sqrt(sum (n . e_k)^2 half_k^2)`, not the support function, whose kink at
  alignment makes a face-to-face torque jump as it passes through alignment.
* *Balls* (sphere impactors): the same, with the chunk's nearest-face cells cut from
  the ball exactly (`polytope::ball_cells`); interface integrals from the closed-form
  moments of a polygon cut by a disc.
* *Ground*: the torque of the chunk's thickness turning with it.
* *Indentation* (crushed material from a split joint) stays while the pair overlaps
  and is forgotten when they part; lowering it while they touched created energy.

Tests: finite differences of the energy against the force and moment
(`world::tests`), in face, edge and corner configurations of cubes, a non-cubic chunk
and a ball, and over 500 random relative poses (worst 3.5e-6, the differences' own
error). A frictionless, perfectly elastic collision of two free cubes conserves energy
(`an_elastic_collision_of_two_cubes_conserves_energy`): `|dE/E|` 1.4e-3 / 2.2e-5 (face
overhanging an edge), 9e-10 / 2e-12 (tilted onto an edge), 1.1e-3 / 3.0e-4 (edge on
edge) at Courant 0.5 / 0.125.

**Robust polytope clipping.** The planes the cells are cut by are structurally
degenerate: a bisector passes through the edge of the two faces it bisects, and
neighbouring chunks of a grid have coplanar faces. Three fixes, each found by a failing
gradient test:
* a crossing point is interpolated from the inside end, so the two faces sharing an
  edge make it bit for bit and the result stays watertight (one ulp apart, a later
  clip through that edge lost a face: 2/3 of the volume);
* the new face is the convex hull of the crossing points in its plane, not a chain of
  segments (round-off dropped or duplicated a segment; a duplicated vertex then gave
  the disc integrals a zero-length basis edge and an energy jump of 4e4 J on a 1 J
  contact);
* the in-plane basis of a face comes from its normal alone.

**Frame invariance with fracture** (`a_rigid_rotation_of_the_scene_rotates_the_result`)
now holds to round-off: 6.5e-11 m against an envelope of 3.4e-9 m (1.3e-4 m before;
4e-2 m at the start of this work). Found by tracing where the rotated run first
departed: (1) the contact area and normal came from which body owns a face of the
overlap, which round-off decides where the bodies' faces are coplanar; it now comes
from the overlap alone (its shadow along the normal). (2) The torsional lever arm's
quadrature fanned each face from its first vertex, so its error depended on the
orientation; it now fans from the face's centroid.

**Split handover.** A joint broken by a split hands its elastic compression to the
contact (the indentation at which the contact's force equals it), and now also its
shear and torsion to the contact's friction (same stiffness, `k''_t A` and `k''_t J`
being the joint's `G A / L` and `G J / L`). Coulomb's cap applies at the contact's
next step, where any excess slips. It is never more than the joint stored; the rest is
`split_release`. The elastic force (no dashpot) is what is handed over. On the 40 m/s
impact the energy released at splits halves (87 J to 46 J of about 350 J handed over).

**Cost.** Chunk-pair contacts are evaluated in parallel from 16 pairs on
(`par::map_into_heavy`, item order kept: bit-identical for any thread count), and cell
cuts a convex region's vertices show to be idle are skipped (exact). The breaching
pressure panel is still ~12x slower than with the established contact: ~870 pairs per
substep after it breaks, ~45 us of CPU each, mostly allocation in polytope clipping (a
flat-arena polytope is the next lever).

**Suite** (`cargo test --release -p stress-ref --no-fail-fast`; `scripts/test_fast.sh`
skips the panel, hull-pack and showcase runs: ~2 min instead of ~25 with the switch):
default methods pass everything but the principles (by design). With `layer_contact`
alone, unit rescaling also needs `scaled_step_bound` (each fixes a unit dependence), and
the implicit free-vibration test needs `frame_contact_step`: energy is conserved to 7
digits, but the global contact step (with the dashpot factor, though nothing can touch)
shortens the substep and the sampled peaks fall 1.5 % lower. With both switches:
principles 8/8, showcases 7/7; open: elastic impact at the larger step (1.07 %),
convergence, engine-coupled, mass scaling, and the b9 panel (below).

**Open, b9 panel (over-strong arching):** the breaching panel breaks 300 bonds into 16
fragments and barely moves (established: 60 bonds, 4 fragments, matching OpenCourant).
The contact has the joint's stiffness but not its compressive strength: hinges between
fragments never crush. Planned: the joint's crushing criterion on the contact, in closed
form (peak layer pressure `max_f k''_f d_f`, the indentation ratcheted to
`max_f (d_f - f_c / k''_f)`).

**Rocking damping and the exact shear layer** (this round, DECISIONS.md 10-12): the
dashpot spreads over the area like the springs, so relative spin about in-plane axes is
resisted (`-(c_n / A) Q w`); before, a resting heavy block rocked forever. The friction
layer is an exact last-in-first-out stack of entry cohorts; the uniform-strain rule it
replaces made a near-grazing contact edge creep (8e-14 m/s) as round-off flickered its
area. Both are proven by exact targets (`tests/principles.rs`: rest at the exact
two-field equilibrium, sticking at the exact elastic offset with no creep, the exact
discrete Coulomb stop).

**Sliver contacts (bug, fixed):** the contact area's second moment was formed about the
world origin and shifted to the contact point; for a thin sliver the shift cancelled to
the size of the value, the polar moment came out negative and the torsional dashpot's
`sqrt` gave NaN (40 m/s fracture at Courant safety 1/64). Moments are now integrated
about the point and the parallel-axis shift only adds a positive term (DECISIONS.md 28).

**Open, energy closure with fracture:** the balance converges at first order to about
-1.3e-3 e0, not zero; the loss accrues at a fixed rate while contacts push loose cracked
chunks, the signature of the small-strain floating-frame coupling that also keeps
angular momentum from being conserved (DECISIONS.md 26-27). Both are exact targets now
and fail until that coupling is made exact.

**Status:** default on. Catalogue A/B against the established methods: 87/91 gated
metrics both ways, the same four known b5 gaps failing (DECISIONS.md 42).

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
metres).

Stability harness (`examples/stability.rs`: every catalogue scene, perturbed at rest,
20,000 substeps at fractions 0.9 to 2 of the bound): the scaled bound is stable at
0.9, 1, 1.1 and 1.5 on every scene, and first blows up at 2 (b2, b5, b6, b9, s_blast,
s_supports): valid and tight within 1.5-2x. The established bound never blows up, even
at 2x: it leaves more than 2x on the table. (The harness first measured nothing: the
bonds' stored energy is their last evaluation's, zero before the first step.)

**Status:** catalogue A/B and test suite running.

### `exact_frame_transfer` (fix)

**Replaces** the linearised transfer of a new fragment's hidden rigid motion into its
frame, and the split's re-expression of chunk velocities with lever arms that left out
the hidden displacement: both moved chunks or changed their velocities at every split
(a deformed beam's split: 1.0e-2 in angular momentum, 5.1e-2 J created).

**Method:** at a split, every chunk's world position, orientation, velocity and spin are
re-expressed exactly in the child's frame, which is then re-centred (hidden mean
displacement and velocity zero, the frame taking them, lever arms included). Per
substep the fold stays linear (O(dt), no cancellation).

**Evidence:** `a_split_of_a_deformed_body_keeps_its_motion` (momentum, angular momentum,
kinetic energy to rounding); angular momentum changes only by the bonds' small-strain
imbalance, converging to zero with the substep. **Status:** default on.

### `contact_crushing` (model change)

**Replaces** contacts of unlimited compressive strength: the contact that takes over a
broken joint had the joint's stiffness but not its strength, so hinges between fragments
never crushed (b9: fragments rebounding against the pulse).

**Method:** the joint's crushing law on the contact: strength `f_c (1 - c / d_u)`,
`d_u = 2 G_c / f_c` (energy-limited like the joint's own crushing; a perfectly plastic
crush dissipated 3.1 kJ of 6.7 kJ on b9), the indentation ratcheting where the layer's
peak pressure `k''_f s` exceeds it.

**Evidence:** b9 high against OpenCourant: fragment speed 2.79 vs 3.45 m/s (gate 30 %),
peak centre displacement 9 % (established 22 %). **Status:** default on.

**Joint law ledger (fix, all runs):** the dissipation booked by a bond is exactly the
drop of its stored energy caused by its internal-variable update; the law's own accounts
had booked up to twice the energy released (DECISIONS.md 33). This closed the fracture
energy balance with `layer_contact`.

## Open (from the audit and `CPU Oracle Improvements to Prove First`)

| # | Change | Class | Status |
|---|---|---|---|
| 0 | Instrumentation: work counters, binding limit of the step, adaptive decisions | - | to do |
| 1 | True stable step (power iteration on the explicit update itself) and a per-frame contact step from the contacts that can engage; stability harness (`examples/stability.rs`) | Step change | harness done (scaled bound valid, tight within 1.5-2x); power iteration to do |
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
| - | `split_release`: hand the joint's compression, shear and torsion to the contact (with `layer_contact`) | Fix | done |
| - | Test targets audited: exact answers or derived bounds, no picked tolerances (DECISIONS.md) | - | done for principles, conservation, gradients, ball overlap |
| - | Exact rigid/hidden coupling of the floating frame (angular momentum, fracture energy closure) | Model change | to do |
| - | Half turns bit for bit (covariant quaternion formulas or matrix orientation) | Fix | in progress |
| - | Shallow ball caps without cancellation (centroid off ~1e-4 m on a 1e-16 m^3 cap) | Fix | to do |
