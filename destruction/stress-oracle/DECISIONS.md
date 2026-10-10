# Decisions log (test targets, tolerances, model fixes)

Running record of the choices made while making every test a trustworthy target
("exact answer, or a derived bound, never a hand-picked number"). Newest last. `User`
marks a choice the user made; `Mine` one I made on my own judgement (the user asked me
to proceed without questions and record them here).

## Rule (User)

When the expected answer is known exactly, the test requires an exact match, or a match
to round-off with the bound derived, not picked. A threshold is allowed only for
genuinely approximate or chaotic results (fracture, oracle comparisons), and each one
states its source: a computed round-off bound, a measured convergence with step size, a
cited textbook factor, or the oracle's own uncertainty.

## Targets

1. **Exact model answers** (User). The expected value is the exact solution of the
   contact model (elastic layer + Coulomb), i.e. the textbook result plus its
   closed-form elastic corrections, not the rigid textbook value with the correction
   folded into a tolerance.
2. **Exact discrete answers where the integrator is the difference** (Mine). Where the
   time integrator itself changes the answer (semi-implicit Euler: a constant-force
   stop at `v^2 / 2a - v dt / 2`), the test checks the simulation against the exact
   discrete value to round-off, and the discrete value against the continuous one
   within the scheme's derived error (`v dt / 2 + a dt^2`, `dt` in time).
3. **Scenes realise the textbook premise** (Mine). Blocks start at the exact contact
   equilibrium of the motion tested (sink and tilt from an independent solution), so
   the textbook answer applies from t = 0 instead of after an unmodelled drop-in
   transient.
4. **Two-field pair target** (User). A cube resting on an anchored chunk is compared
   with the exact equilibrium of the pair law's two-field energy (rim cells, interface
   stiffness jumps, slivers, stiffness-weighted contact point), derived in the test
   (`slab_energy`, `slab_contact_height`) and checked cell by cell against an
   independent semi-analytic integral (bottom cell to 1.2e-13).
5. **Friction acts at the overlap centroid** (User), as the normal force; the targets
   are derived with that convention.

## Round-off bounds (Mine)

6. **Positions and angles at rest**: within `4 ulp` of the stored coordinate (sink), and
   `4 (ulp(z) / 2h + eps)` (tilt). Derivation: stored coordinates carry half an ulp;
   the forces the equilibrium balances come from them along a path of at most eight
   roundings at that scale (coordinate difference, clip interpolation, centroid, arm).
   Observed: 0 to 2.3 units, including the scene lifted 8 m (residuals scale with the
   coordinates, as round-off must).
7. **Settled** = the remaining motion is the contact's vibration at the amplitude of
   that rounding: velocity at most `4 w_v ulp(z)`, spin at most `w_r` times the tilt
   bound, held for a whole rocking period, sampled by frames of 1/8 bounce period (so
   an oscillation shows at least `cos(pi/8)` of its peak, folded into the thresholds).
   A single-frame test was wrong (it caught turning points).
8. **Accelerations**: per frame, the normal force's rounding (`4 ulp(z)` of the sink)
   times `mu g cos t`, plus the velocity's own (`2 ulp(v) / dt`).
9. Run lengths are not tolerances: a run is cut off at ten times the derived decay
   estimate of its slowest mode; failing to settle by then fails the test.

## Model changes made while proving the targets

10. **Rocking damping** (User). The contact dashpot is spread over the area like the
    springs (`c_n / A` per area): relative spin about in-plane axes is resisted with
    `-(c_n/A) Q w`, `Q = int (r x n)(r x n)^T dA`. Before, rocking was undamped (a
    resting heavy block never settled). Contacts now carry the area's in-plane second
    moment tensor, shifted to the force's point of action (pairs and balls act at the
    stiffness-weighted cell centroid; their polar moment had been taken about the
    geometric centroid).
11. **Exact LIFO shear layer** (User). The friction layer is a stack of entry cohorts
    (stiffness, displacement at entry); force `sum k_i (d - d_i)`; growth pushes,
    shrink pops the newest first, slip collapses to one cohort; turned with the contact
    plane by the minimal rotation. Fixes a creep of 8e-14 m/s at a partly lifted
    (near-grazing) contact edge, where round-off makes the area flicker 1e-10 and the
    uniform-strain rule ratcheted the stored force down. Memory grows only while a
    sticking contact's area grows monotonically (accepted, unbounded, User).
12. A contact forming takes all its material as one cohort (it enters together).

## Test scene choices (Mine)

13. **Sticking**: exact settled offset `e = m g sin t / (k_t A)` asserted at 10 degrees
    (cone 2.8 times the load: the start-up step response stays inside, no slip) for
    every mass; no creep (`4 ulp(h)` over the second half of the run) asserted at 10
    and 20 degrees. At 20 degrees (cone 1.37 times the load) the unloaded layer slips
    briefly at the start: a path-dependent offset, not asserted.
14. **Stopping**: one substep per frame; velocities, the stop substep and the stop
    position checked against the exact discrete scheme; the elastic release after the
    stop is not asserted (the friction spring holds exactly `mu N` at the stop, so the
    release can slip a path-dependent amount), only that the block then holds still.

## Workflow (Mine)

15. `scripts/test_fast.sh`: the suite without the panel, hull-pack and showcase runs
    (about 2 min instead of about 25 with `layer_contact`); the full suite gates commits.
16. `.gitignore` (stress-oracle): generated scenes, videos and stray media/log output
    ignored; `golden/` and `golden_mesh/` stay committed (oracle evidence).

## Frame changes (Mine)

17. **Half turns are bit-exact targets** (User asked for bit-exact 180 degrees). A half
    turn about a coordinate axis flips the signs of two vector components (exact) and
    permutes a quaternion's components with signs. Floating point rounds `-a` as `-(a)`
    and pairs commute, so only sums of three or more terms in an order the turn
    changes, and choices made in an arbitrary basis, break it. Fixed (round-off-level
    changes, all runs): quaternion normalisation sums `(w^2 + x^2) + (y^2 + z^2)`; the
    rotation is the explicit matrix with entries grouped `(ww + xx) - (yy + zz)`,
    `2 (xy - wz)`, ... (each maps to an exact sign flip of `D R`); the Hamilton product
    sums each component's terms in pairs (the sequential form reversed its order under a
    right multiplication by a body-frame increment, as the floating frame's drift removal
    does; checked exhaustively on random factors, left and right); a clip's new face
    starts at the hull vertex met first among the segments instead of the extreme of an
    arbitrary in-plane basis. Found by a differential run (both scenes stepped substep
    by substep, every state compared after mapping). **Status:** without fracture, all
    three half turns bit for bit (was 2e-14 m); with fracture, exact until the ball first
    meets a chunk edge (substep 457), where `with_ball` (in-plane basis from
    `any_perpendicular`, absolute angles, the `r^3`/`r^4` cancellation of item 29) gives
    a 4e-9 relative difference in the contact force; the run then differs by 3e-12 to
    1.2e-11 m. Remaining fix: basis-free, cancellation-free ball-cap moments (sector
    moments from the unit vectors of the arc's ends, relative angles only). A covariant
    in-plane basis cannot exist (a half turn about the normal itself would have to fix
    it), so every such computation must be basis-free.
18. **Galilean and generic rotations: a rounding envelope, not a tolerance.** Floating
    point cannot make them exact (`(v_a + d) - (v_b + d)` rounds). The transformed run
    is compared with 19 runs of the original into which, after every substep, each
    stored coordinate of the moving state receives +-1 ulp (fixed pseudo-random signs)
    at the scale the transformed run computes it (positions at the largest coordinate
    reached, linear velocities at the largest speed, other vectors at their own length,
    quaternions at 1): two half-ulp roundings per coordinate per substep. The
    transformed run must deviate no more than the largest of them (if it were just
    rounding, a 1/20 chance of exceeding; seeds fixed, deterministic). Perturbing only
    the initial state was tried and is wrong: a frame change re-rounds every substep
    (it underestimated 25 times). Measured: without fracture 7.6e-14 m against
    2.4e-13; with fracture 2e-10 m against 8e-7 (rounding can flip a damage event at
    substep resolution, so the fracturing envelope is wide; the no-fracture case is the
    sensitive check). Runs pin the substep, which the partition test proves changes
    nothing.
19. **Convergence and frame partition**: monotone decrease of differences over Courant
    safety 0.5, 0.25, 0.125, 0.0625 (no tolerance); frames of 16, 4 and 1 substeps give
    bit-identical states every 16 substeps.
20. **Settled is judged on positions, not velocities**: a velocity whose step `v dt` is
    below half an ulp of the position is rounded away and moves nothing, so a
    "phantom" velocity can persist forever in a block that is exactly still.

## Conservation (Mine)

21. **Linear momentum**: the 1e-9 relative allowance became a derived round-off bound:
    every substep each body's velocity rounds along at most eight half-ulp roundings at
    the largest speed, `4 ulp(speed)` per unit mass, accumulated linearly, plus the
    rounding of measuring the sum (`2 (N + 8) eps sum m |v|`, twice). Measured drift:
    4e-5 to 3.4e-4 of it (the bound is a worst case; rounding walks randomly).
22. **Splits** (fragments inherit `v + w x r`): the 1e-12 became Higham's
    `gamma_{N+10}` of the sums of the terms' magnitudes (three passes: measure, split,
    measure). Measured: 9e-16 against 4.6e-13.
23. **Energy balances converge to zero, judged by the data** (no tolerance): errors at
    Courant safety 0.5, 0.25, 0.125, 0.0625 (two cubes: down to 1/32) must fall in
    magnitude at every halving, and Aitken's extrapolated limit from the last three
    must lie within its own uncertainty (its change from the previous three) of zero.
    A single Aitken estimate was not enough: the two-cube "face" error alternates in sign
    as it converges (1.4e-3, 8.9e-5, -2.2e-5, 1.1e-7, -5.7e-8). A rounding floor
    (`substeps * 4 eps`, decision 6) ends the trend. Replaces 0.01, 0.05, 0.025, 1.001,
    3e-3, 1e-3 and the 0.6 ratio.
24. **Second law of the contact ledger**: exact, no allowance (the 1e-9 e0 is gone).
    With the penalty contact the booked dissipation is a sum of non-negative terms
    (dashpot `c vn^2`, unloading `k depth max(vn, 0)`, friction `|f_t| |v_t|`, crush),
    which floating point keeps exactly monotone. With the elastic layer it is the work
    the contacts took out of the motion net of what they store; not monotone by
    construction (the elastic integration term `-1/2 dx K dx` per substep can be
    negative) but measured never to fall frame to frame at any safety; kept exact.
25. **The penalty contact's energy closure is not tested** (as for the two cubes): it
    books its own dashpot quadrature, which is not the work its non-gradient force does
    (0.33 e0 booked against 0.34 e0 taken out of the motion at safety 1/16; the
    imbalance grows from 0.4% to 2.3% as the substep shrinks). Its ledger monotonicity
    is still tested.
26. **Angular momentum is an exact target** (separate test, derived round-off bound with
    lever arms to the scene's extent). **Known failing**: the small-strain bond model
    balances moments about the undeformed chunk centres and the floating frame couples
    hidden and rigid motion to first order; the drift does not shrink with the
    substep (5.9e-4 of |L0| without fracture, 1.2e-3 to 1.6e-3 with it).
27. **Fracture energy closure (layer contact) is an exact target. Known failing**: the
    residual converges at first order (ratios 0.48) to about -1.3e-3 e0 (Aitken limits
    -1.31e-3, -1.38e-3, -1.37e-3, -1.26e-3 down to safety 1/128). Located: none of it
    in substeps without contact (2.5e-9), none at splits or bond breaks (those parts
    converge), none without fracture (40 m/s elastic: exactly first order to zero), not
    friction, not the joint-law switches; the bond law alone closes (work = stored +
    dissipated + overshoot, converging, on tension, mixed, cyclic and compression-shear
    paths). After removing the symplectic quadrature term `sum 1/2 m |dv|^2` (first
    order, 3.7e-3 then 0.91e-3) a negative part of -1.82e-3 e0 is the same at safety
    1/8 and 1/32: a loss at a fixed rate while contacts push loose cracked chunks, the
    signature of the same floating-frame coupling as item 26. Fix (future, behind a
    switch): exact rigid/hidden coupling (moments about deformed centres, frame
    accelerations in the hidden dynamics).

## Bugs found by the audit (fixed)

28. **NaN from a sliver contact** (layer contact, safety 1/64, 40 m/s fracture): the
    contact area's second moment was formed about the world origin and shifted to the
    contact point; for a sliver with large, nearly edge-on faces the shift cancelled to
    the size of the true value (polar moment -1.1e-21), the torsional stiffness went
    negative and `sqrt` gave NaN. Fixed: each face's moments are integrated with its
    vertices already shifted to the point and projected (a sum of outer products with
    positive weights), and `LayerContact::about` separates the central moment so the
    shift only adds `a e e^T` (the central polar moment, analytically `>= 0`, is clamped
    at zero against round-off). Regression test
    `a_sliver_contact_has_a_positive_area_moment` (fails on the old formulas: -1.8e-35).
29. **Open (round-off)**: `with_ball` forms a shallow cap's volume and first moment from
    sector formulas of size `r^3`, `r^4` (cancellation): on a 1e-16 m^3 cap the centroid
    is off by about 1e-4 m and the stored energy can come out -2e-9 J. Negligible in
    energy (1e-13 of an impact's), but unphysical; a cap-height formulation would fix it.

## Gradient and geometry checks (Mine)

30. **Force = -grad(energy), without a chosen step or tolerance** (`world.rs` tests,
    replacing 1e-5, 1e-4, the 0.1 torque scale and the fixed steps 1e-6, 1e-9, 1e-10).
    Five-point central differences of the energy over a ladder of steps
    `d = size 2^-k`, each with the classical error bound: rounding
    `N(d) = 1.5 sigma_E / d` (the stencil's weights on energies each off by at most
    `sigma_E`) and truncation `T(d) = (|D(2d) - D(d)| + N(d) + N(2d)) / 15` (error
    `c d^4`); the step minimising `T + N` is used. `sigma_E` and the analytic force's
    own rounding are measured by moving the whole scene rigidly (19 fixed shifts;
    nothing physical changes), each vector's rounding at its own length. Pass: the
    analytic value within `T + N` plus its rounding. A first version took the spread of
    neighbouring differences as the uncertainty and chose the step with the smallest
    spread; that biased it low (one random case in 3000 at 1.01, where the ladder shows
    analytic and differences agreeing to 1e-11). Measured misfits: 0.54 at most on the
    fixed cases, 0.88 the worst of 3000 random checks; a force wrong by 1e-7 relative
    fails at 47 times the uncertainty (old tolerance 1e-5).
31. **Ball-box overlap against an independent integration** (`polytope.rs`, replacing
    the 3000^2 midpoint brute force and its 2e-6): nested Gauss-Legendre over exact
    slices with the rim square roots substituted away and every kink split out (a
    signed-distance slip that missed the kink where a chord enters the box was found by
    the convergence check and fixed). Uncertainty: 64 against 128 points per piece plus
    the worst-case rounding of nested sums, `(N_inner + N_outer + 16) eps` of their
    scale; plus `with_ball`'s rounding by rigid shifts. Agreement 1e-15 to 1e-13
    relative; uncertainty 1e-12 to 1e-9 (was 2e-6).
32. Removed a leftover scratch test in `world.rs` (`zz_slab_energy`, which always
    panicked).
