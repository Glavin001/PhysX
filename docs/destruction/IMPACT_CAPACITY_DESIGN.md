# Impacts on anchored structures: joint capacity, inertia and impact-pressure crush

Status: design for review. Nothing here is implemented yet. E and Ci are to be
implemented in the native GPU destruction stage only; there is no CPU runtime
path, now or planned. Every number below comes from the Python study / oracle,
vibe-land `structures/town-kit/scripts/impact-study.py` (commits 3176e80c,
009f5bec). Like `scripts/stress/oracle.py`, it is a research tool and a test
oracle, never a runtime path.

## The problem

When anything hits an anchored structure, two errors in the stage compound.

1. **The trial treats the anchored building as immovable.** Its clusters are
   kinematic, so the trial solve stops the impactor in one tick. The contact
   impulse is `M v`, applied as a force of `M v / dt`. That is 6.5 MN for the
   5 t monster truck at 21.7 m/s and 38 MN for the 10.65 t cannonball at 60 m/s.
   EN 1991-1-7 Annex C puts the truck's real frontal force at
   `F = v sqrt(k m) = 0.84 MN`, with k = 300 kN/m.
2. **The stress solve has no capacity and no inertia.** It is the min-norm
   elastic solution: every chunk is in static equilibrium, and the load goes to
   the anchors through every joint at once. Nothing limits what a joint
   transmits. The anchored cluster does not accelerate, so `prepareLoads` gives
   its chunks no d'Alembert term. A joint past its fatal limit breaks in the
   same verdict as the joints in front of it, which had already failed and
   could not have passed the load on.

The brick-veneer timber-frame bungalow (vibe-land
`structures/town-kit/src/veneer-houses.mjs`) is built with real joints:
nails, bolts, ties and mortar. Its stud-plate joints are rated about 1 kN. In
the GPU lab, with today's engine:

| hit | bonds broken | frame bonds broken | roof drop |
|---|---|---|---|
| monster truck, 78 km/h, into the front wall | 94% | 864 of 892 | 2.7 m |
| truck into the corner | 94% | 849 | 2.5 m |
| cannonball | 97% | 874 | 2.6 m |
| meteor | 99% | 875 | 2.5 m |
| three 100 kg balls between the studs | 67% | 690 | 2.0 m |

These rows are from `scripts/vehicle-testbed.sh`, label `house-A`. A repeat
run agrees to within 0.1%.

## What the Python study / oracle shows

The oracle runs four models on the same graph:
- **A** reproduces the native verdict. It uses stress-share.py's solve, which
  matches the GPU at rest to about 0.9x.
- **C** adds the native crush law (`extStressCrushStep` on each chunk's virial).
- **E** is the model below.
- **Ci** is the impact-pressure crush trigger, also below.

First contact tick, then gravity settling:

| hit | model | bonds broken | frame bonds broken | roof held |
|---|---|---|---|---|
| truck | A | 46% | 560 | 0% |
| truck | C | 46% | 560 | 0% |
| truck | E | 7.4% | 21 | 100% |
| truck | E, coupled contact | 9.7% | 1 | 100% |
| truck, corner | A | 58% | 625 | 5% |
| truck, corner | E | 12% | 25 | 100% |
| cannonball | A | 91% | 820 | 0% |
| cannonball | C | 91% (54 chunks crushed) | 820 | 0% |
| cannonball | E | 8.1% | 23 | 100% |
| cannonball | Ci + E, coupled | 3.9% (13 crushed) | 19 | 100% |
| meteor | A | 97.5% | 875 | 0% |
| meteor | C | 97.5% (305 crushed) | 875 | 0% |
| meteor | E | 19% | 126 | 79% |
| meteor | Ci + E, coupled | 11% (44 crushed) | 56 | 88% |
| 100 kg ball between studs | A | 4.4-5.0%, stopped in the veneer | 5-6 | 100% |
| 100 kg ball between studs | E | 0.4-3.3%, goes through | 0 | 100% |
| 100 kg ball between studs | Ci + E | 0.3-0.5% (2 crushed), goes through | 0 | 100% |

Force sweep on the truck's contact tick. Each cell is bonds broken, with the
number more than 4 m from the impact in brackets:

| contact force | A | E |
|---|---|---|
| 0.25 MN | 22 (0) | 85 (3) |
| 0.84 MN, the EN 1991-1-7 truck force | 190 (39) | 143 (5) |
| 2 MN | 322 (124) | 184 (5) |
| 6.5 MN, the trial's `M v / dt` | 719 (421) | 227 (8) |

What this shows:
- A's far damage grows without bound with the contact force. E's saturates,
  because nothing past the failing joints sees more than they can carry.
- The infinite-mass contact accounts for most of A's damage. At the realistic
  truck force A still breaks 190 bonds, 19 of them frame bonds.
- E is the decisive change.
- Crush as built (C) changes no bond verdict. It removes chunks, and with
  trial-solve loads it removes them far from the hit (305 across the house
  for the meteor).

## E: one tick as an impact of rigid chunks joined by joints of finite capacity

### Formulation (Moreau / Gauss)

Chunks are rigid, with mass and inertia `M`, and anchors have zero inverse
mass. Joints carry impulses `j_b` (6 components, linear and angular, about
the bond centroid). For the tick:

```
minimise   1/2 (p + B j)^T M^-1 (p + B j)       post-tick kinetic energy
subject to j_b in C_b  for every live bond b     capacity cones
```

- `p` is the tick's external impulse on each chunk: gravity `m g dt` plus the
  contact impulses.
- `B` is the bond-to-chunk map. It is the stress solver's operator without
  its column weights.
- `C_b = { j : u_b(j / dt) <= 1 }`, where `u_b` is the solver's own fatal
  utilisation:
  - compression `bend - normal <= cF`
  - tension `normal + bend <= tF`
  - shear `|lin_t|/a + g_t |ang_n|/a <= sF`
  - with the section-modulus gains as today.

  Each constraint is a second-order cone in `j`, so `C_b` is convex.

This is the dual of maximum plastic dissipation:
- **A joint below capacity holds.** At the optimum its two chunks have equal
  velocity.
- **A joint at capacity carries exactly its capacity.** It lets its chunks
  separate along the cone's normal (associated flow).
- **Whatever the joints cannot carry accelerates the chunks.** That is the
  d'Alembert term the static solve lacks.

Among the impulses that give the optimal motion, take the elastic one:
`min sum |j_lin|^2 / w^2 + |j_ang|^2 / (w Ls)^2` at the same kinetic energy.
When no bond reaches capacity this is exactly today's min-norm solution, so
the change is invisible at rest. Past capacity it is the
elastic-perfectly-plastic field (Haar-Karman).

Verified in the oracle at rest: the bungalow under gravity breaks nothing and
yields nothing.

### Brittle and ductile joints

- **Brittle** (mortar, glass, wall ties pulling out, timber within a member):
  a joint at capacity fractures. It is removed and the tick is solved again.
- **Ductile** (nailed, screwed and bolted timber connections, including gypsum
  screws in shear): a joint at capacity yields and keeps carrying its
  capacity. It breaks when its slip over the tick passes its ultimate slip.
  The slip is `1/2 |v_rel| dt` at the bond, from the solved post-tick
  velocities.
  - The oracle uses 15 mm. EN 12512 high ductility, D >= 6, at
    `v_y = F / K_ser` gives about 6.4 mm for a nail. Tests reach peak load at
    10-15 mm.
  - At impact speeds a yielded joint slips 0.1-0.4 m in one tick, so the value
    only matters for slow loads.

### Failure order

The impulse a contact delivers over a tick grows from zero to its full value.
The ramp `p(lambda) = p_gravity + lambda p_contact`, for lambda from 0 to 1,
follows that history. A brittle joint fractures at the lambda where its own
capacity is first reached in the solved field, and the field is re-solved
without it at that lambda. No ordering is chosen: which joint fails first,
and what follows, comes from the forces.

The oracle discretises lambda geometrically, from 1/256 to 1 in factors of
2. Halving the factor to sqrt 2 changes the truck's first tick from 227 to
243 broken bonds, and the cannonball's from 246 to 249. Twelve levels instead
of nine change nothing.

Ductile joints need no ramp: the plastic field is path-independent under
proportional load.

### What replaces the infinite-mass contact

The oracle runs two ways:
- **Uncoupled:** E takes the trial's contact impulse as given. This is what a
  stress-side change can do on its own.
- **Coupled:** the impactor is a body in the same problem, with its momentum.
  The contact is a unilateral impulse `c >= 0` along the normal, with the
  impactor's inverse mass. The struck region's real mass and capacity then
  limit what the contact delivers. Delivered impulse per tick falls to 0.17-0.22
  of `M v` for the truck and 0.02 for the cannonball.

The verdicts differ little. On the first tick, coupled versus uncoupled:

| hit | uncoupled | coupled |
|---|---|---|
| truck | 7.4% | 9.7% |
| cannonball | 8.1% | 10.1% |
| meteor | 19% | 22% |

Once joints have capacity, the over-large trial impulse only gives the freed
chunks too much velocity. The correction pass recomputes that velocity anyway.

So step 1 keeps the trial and the correction exactly as they are.
- **Trial:** the anchored clusters stay kinematic. The trial's solved contact
  impulses are E's `p`.
- **Verdict:** E replaces the stress solve and material evaluation. It
  produces bond breaks and crushes, which feed the same topology edits.
- **Correction:** unchanged. One corrected pass,
  `internalCorrectionLimit = 1`. The freed chunks are now the struck region
  only, and the corrected pass meets them as dynamic bodies with real mass.
- **The anchored kinematic cluster:** E needs no new rigid state. Anchors are
  simply chunks with zero inverse mass in `M^-1`.

The coupled contact is step 2. It needs the impactor's inverse mass and
velocity per destructible contact pair, which `routeContacts` already reads,
and a unilateral contact row in the same solve.

### Ci: crush by impact pressure

The native crush law (`extStressCrushStep`) is sound as a material law. Its
input is the problem: the virial of the trial solve's forces.
- **Uncoupled:** with the infinite-mass trial, it crushes chunks wherever the
  quasi-static load passes. In the oracle that is 305 chunks across the house
  for the meteor.
- **Coupled:** at tick resolution, the force on a struck chunk that is free to
  move is `m dv / dt`, far too small. Crush never fires.

Real crushing happens in the first microseconds of contact. The contact stress
then is the 1-D elastic impact stress:

```
sigma = Z1 Z2 / (Z1 + Z2) * v_n,    Z = rho c = sqrt(rho E)
```

It is capped by what the impactor's own structure can deliver. A car or truck
front delivers at most its crush pressure:
`F = v sqrt(k m)` (EN 1991-1-7 Annex C) over the contact area, which is
0.16 MPa for the monster truck. A steel ball or a rock delivers the full
impedance stress.

Ci evaluates the native crush law at that stress, as a uniaxial state
(`p = sigma / 3`, `q = sigma`), for each struck crushable chunk, before E's
solve:
- A crushed chunk is destroyed, and its contact is removed from `p`.
- The impactor loses the comminution energy of the volume its section sweeps:
  `crushEnergy` times section times depth. The native stage removes the whole
  chunk either way.
- The next layer in the tick's sweep is tested in turn.

Values:
- Brick: steel ball at 60 m/s, `Z_eff = 3.3 MPa s/m`, gives about 200 MPa.
  The one-tick crush threshold is about 25 MPa. It crushes.
- Truck front: 0.16 MPa. It does not crush.

What Ci adds to E:
- A hard projectile crushes the skin instead of dragging intact panels.
  - Small balls break 15 bonds instead of 103 (E, x = 0.86).
  - The cannonball breaks 120 bonds instead of 311 (coupled).
- It absorbs energy.

What Ci does not do:
- It does not make the truck crush brick.
- It does not stand in for E. C alone does not localise anything.

## Data

Per bond (all present today):
- material, area, normal, centroid
- the stress formula's gains
- `w`, the stiffness weight
- one new flag: brittle or ductile, with an ultimate slip for ductile joints.
  This could be per material: a `ductileSlip` field in `PxDestructionMaterial`,
  0 meaning brittle.

Per chunk (present today): mass, inertia, volume, and the chunk's own material
(vibe-land now passes it; it used to be the structure's first material).

Per crushable material: the existing `PxDestructionCrushProperties`, plus an
acoustic impedance `rho c` for Ci. The cited values in vibe-land
`structures/town-kit/src/materials.mjs` CRUSH:

| material | f_c | cone | crushEnergy | viscosity |
|---|---|---|---|---|
| masonry | 6.8 MPa (EN 1996-1-1 eq. 3.1) | cohesion f_c (1 - k/3), k = 1.2, cap 2.5 f_c | 3.5 MJ/m^3 (Bond, Wi 13) | 5.9e5 Pa s (CEB-FIP MC90 DIF at 30/s) |
| gypsum | 3.5 MPa | as masonry | 1.1 MJ/m^3 | 5.1e5 Pa s |
| concrete C30/37 | 30 MPa (EN 1992-1-1) | as masonry | 3.9 MJ/m^3 | 5.6e5 Pa s |
| glass | 45 MPa (EN 572-1) | pressure-independent | 5.2 MJ/m^3 | assumed rate-insensitive |

Glass is crushed into shards: debris fraction 1, 12 pieces.

Impedances come from `c = sqrt(E / rho)`. Masonry uses `E = 1000 f_k`
(EN 1996-1-1 3.7.2).

Timber and steel members never crush; they break at their joints.

Car panels need a per-part material in the vehicle recipe, which today carries
only per-bond strengths.

## Implementation in the GPU stage

- **Operator.** `B` and `B^T` are the stress solver's existing bond/node
  gather-scatter. `M^-1` is per chunk.
- **Solver.** Accelerated projected gradient (FISTA) on the dual `j`, with a
  per-bond cone projection.
  - The projection is the Euclidean projection onto the intersection of three
    small cones. A few Dykstra iterations per bond, or radial return as a
    feasible fallback.
  - Bonds are independent given `M^-1 (p + B j)`, so each iteration is one
    gather and one scatter, the same cost as one CG iteration today.
- **Warm start.** Start from the elastic CG solution, which is exact when no
  bond is past capacity. The projected iterations run only on ticks where the
  elastic solution has a bond past capacity, and only in those stress islands.
  - At rest nothing changes and nothing extra is paid.
  - Islands use the existing island partition (`nodeIslands`).
- **Elastic tie-break.** A second, short projected solve: minimise the
  weighted norm at the found kinetic energy. Alternatively, a penalty
  continuation that adds a vanishing elastic term to the first solve.
- **Brittle ramp.** Each level re-solves from the previous level's solution.
  The oracle needs 18-30 solve rounds on an impact tick, at 9 levels plus
  the brittle cascades within a level.
- **FP32.** The dual is badly scaled: chunk masses span 1-500 kg, and joint
  capacities 1 kN to 1 MN.
  - Scale impulses per bond by the bond's capacity, so every cone is a unit
    cone.
  - Scale per chunk by `sqrt(m)`. Keep the kinetic-energy residual relative
    to `|p|_M^-1`.
  - The oracle converges in FP64 (Clarabel). The stage's FP32 behaviour has to
    be measured against it, not assumed.
  - No double precision, no extra iterations, no looser tolerance as a fix.
    The 64-iteration cap applies per elastic solve. Projected iterations need
    their own budget, measured on the oracle cases.
- **Cost.**
  - Per projected iteration: about one CG iteration over the active islands.
  - Expected: a few hundred iterations per ramp level, over at most about 10
    levels, in the islands an impact touches. That is roughly 10-50x today's
    64-iteration stress solve on an impact tick, and nothing on other ticks.
  - The oracle's cost (Clarabel, FP64, 3,000 bonds) is 1-3 s per tick. That
    is no guide to the stage's cost.

## Prerequisites in the stage

- **Removal in the corrected pass.**
  `PxgDestructionRuntime::installCollisionOwners` returns false when the
  collision preparation removed any shape (`collision.removed`). So a crush
  verdict cannot be corrected, and with `internalCorrectionLimit = 1` the step
  fails.

  Measured in the vibe-land lab with the crush pack, 2026-10-06:
  - The first crushing tick fails ("Native GPU destruction stage failed; this
    simulation step is incomplete", error bits 8).
  - Every later tick then fails too (bits 16424), for 1,186 steps over five
    trials.
  - No verdict commits, and the scene freezes: the cannonball stops dead at
    the wall.

  Ci needs crushed shapes taken out of the corrected pass:
  - drop the shape's simulation flag, or exclude it from the owner install;
  - keep it out of the checkpoint restore.

  The vibe-land test `a_crushable_wall_crushes_where_it_is_struck`
  (physx-bridge `tests/native_gameplay.rs`) is the failing-first check for it.
- **Committed changes.** A destroyed chunk is published with `active = 0`.
  vibe-land's bridge used to abort on such rows. It now turns each one into a
  crush event and a singleton island that is promoted and retired.

## Test plan

- **Oracle.** The Python study / oracle (impact-study.py): the same graph and
  the same hits.
  - Per scenario, the stage's first-tick verdict must match the oracle's broken
    set to within the ramp-discretisation spread measured above (about 10%).
  - Frame bonds broken and roof held must match exactly in kind (local or
    not).
- **Failing-first GPU tests,** in `physx/source/gpudestruction/tests`:
  - A two-chunk column with a capacity-limited joint, pushed past capacity:
    the free chunk's post-tick momentum equals the push minus the joint's
    capacity times `dt`, and the anchor joint's force equals its capacity.
    Today: the static solve, the full push in the joint.
  - A three-layer wall (skin, tie, frame): a contact that fails the skin's
    joints leaves the frame's joints below 1.0 utilisation. Today: frame
    joints past fatal.
  - At rest, bit-identical verdicts to today's solve (warm start exact).
  - Ci: a steel ball onto a masonry chunk crushes it at `sigma > ~25 MPa`.
    The same ball at 1 m/s does not. A truck-like impactor capped at 0.16 MPa
    does not.
  - Corrected pass with a crushed chunk completes (prerequisite above).
- **vibe-land lab** (`structures/vehicle-lab`, `house` metrics):
  - framed-house, framed-house-corner, cannonball-framed-house,
    meteor-framed-house and smallshots-framed-house hold the frame and roof:
    roof drop under 0.2 m, frame still anchored at 80% or more.
  - The car and projectile still get through.
  - The fleet's other trials are unchanged.
- **At rest:** `qualify-veneer-houses.mjs` and qualify_structures.py on the
  town still pass.
