# stress-oracle — reference destruction stress solver and its oracles

This workspace is the ground truth for the destruction stress solver described in
the spec (rigid clusters of chunks, a small-strain elastodynamic bond network per
cluster, fracture by dynamic stress). It has three layers, validated in order:

1. **External oracles** (`oracles/`): analytic solutions plus open tools, each run
   as a separate process from the *same* scene file through an exporter. Their
   results are committed as golden observations (`golden/`).
2. **Reference solver** (`crates/stress-ref`): slow, double-precision, explicit CPU
   Rust implementation of the full model, with true or scaled stiffness. It must
   pass every benchmark; the optimized CUDA solver is later diffed against it.
3. **Engine coupling** (`crates/stress-physx`): the reference solver driven by PhysX
   (CPU), behind the engine-facing trait that a CUDA solver will also implement.

Nothing is "is this right?": every quantity is compared, by one shared metric
implementation, against an analytic value or an oracle run of the identical setup.

## Layout

| path | what |
|---|---|
| `crates/stress-ref/src/scene.rs` | scene format `stress-scene/1` (the single input every solver reads) |
| `crates/stress-ref/src/builders.rs` | the benchmark scene catalogue (single source of every scene) |
| `crates/stress-ref/src/material.rs`, `bond.rs`, `joint.rs` | materials, bond geometry/stiffness, the damageable joint |
| `crates/stress-ref/src/solver.rs`, `statics.rs`, `implicit.rs`, `refine.rs` | clusters, explicit substeps, quasi-static solve, implicit Newmark step, fracture/splitting, refinement |
| `crates/stress-ref/src/world.rs`, `contact.rs`, `blast.rs` | standalone world: impactors, ground, contact, scripted loads, blast, events, probes |
| `crates/stress-ref/src/observation.rs`, `metrics.rs` | `stress-observation/1` and the metrics computed identically for every solver |
| `crates/stress-ref/src/api.rs` | engine-facing trait (`StressSolverApi`), contact-impulse filter (pulse or velocity condition), `EngineCoupledSolver` |
| `crates/stress-ref/src/snapshot.rs` | `World::snapshot()`: world-frame chunk boxes, Love-Weber chunk stress, bond damage, for renderers and debugging |
| `crates/stress-ref/src/showcases.rs` | the spec's showcase scenes (overhang, supports, car, floor drop, arch, house) |
| `crates/stress-ref/tests/` | the test suite (analytic, conservation, failure laws, dynamics, solve modes, features, determinism, refinement, engine API, snapshots, showcases, oracle goldens) |
| `crates/stress-viz` | debug renderer: runs a scene and writes an MP4 of view panels (utilization, stress, damage, fragments, speed, deformation) and variant comparisons |
| `scripts/render_videos.sh` | renders every benchmark, showcase and feature comparison into `videos/` (not committed) |
| `crates/stress-physx` | PhysX coupling and its end-to-end tests |
| `oracles/CONTRACT.md` | what an oracle reads and writes |
| `oracles/<tool>/` | `install.sh`, `PINNED.md`, `export.py`, `run.py`, `observe.py`, `pipeline.py`, `README.md` |
| `golden/<scene>/<tool>[_seedN].json` | oracle observations, with `provenance_<tool>*.json` |
| `scenes/` | generated (not committed): `stress-ref gen-scenes scenes` |

## Quick start

```sh
cd destruction/stress-oracle
cargo test --release                         # whole reference test suite (~15 min, mostly one refinement study)
cargo run --release -- gen-scenes scenes     # write every benchmark scene (with derived bond data)
cargo run --release -- run scenes/b2_cantilever.json --out /tmp/ours.json
cargo run --release -- compare scenes/b2_cantilever.json /tmp/ours.json golden/b2_cantilever/opensees.json
cargo run --release -- check scenes golden   # run every scene, compare with analytic + every golden (~7 min)
cargo run --release -- seeds scenes/b9_panel_high_weibull.json --out /tmp/seeds --count 20

# PhysX coupling (needs a PhysX SDK build; see "PhysX" below)
PHYSX_ROOT=/path/to/physx-install cargo test --release -p stress-physx
```

`stress-ref run` options: `--seed N`, `--mode explicit|implicit|adaptive|quasi_static`,
`--stiffness-scale S`, `--max-substep DT`, `--frame-dt DT`, `--no-fracture`,
`--feature NAME=on|off` (model switches, see below), `--set dotted.path=JSON` (any scene
field, e.g. `--set sim.implicit_dt=2e-4`, `--set impactors.0.velocity=[0,2,0]`).

```sh
# Videos (needs ffmpeg): one scene, a comparison, or the whole set
cargo run --release -p stress-viz -- render b5_wall_impact_v40 --views utilization,stress,damage,fragments -o v.mp4
cargo run --release -p stress-viz -- compare s_blast_two_walls \
    --variant "shadowing on:" --variant "shadowing off:feature blast_shadowing=off" -o cmp.mp4
scripts/render_videos.sh            # or a subset: scripts/render_videos.sh b5 s_house feature_
```

### Oracles

Each oracle installs into its own pinned environment and runs from the scene file:

```sh
oracles/opensees/install.sh      && python -I oracles/opensees/pipeline.py scenes/b8_frame_sudden.json
oracles/opencourant/install.sh   && python -I oracles/opencourant/pipeline.py scenes/b6_spall.json
oracles/lmgc90/install.sh        && python -I oracles/lmgc90/pipeline.py scenes/b7_masonry_v15.json
oracles/kratos/install.sh        && python -I oracles/kratos/pipeline.py scenes/b7_masonry_v15.json
```

| oracle | version (pinned) | licence | covers |
|---|---|---|---|
| Analytic | closed forms in `builders.rs` | — | benchmarks 1-4, b6 1-D spall estimate |
| [OpenCourant](https://opencourant.org) (OpenRadioss fork) | `latest-20261006`, commit `33e6851`, zip sha256 `9d67531d…` | AGPL v3 (run as a separate process only) | b1, b3, b5, b6, b7, b9 |
| [OpenSeesPy](https://openseespydoc.readthedocs.io/) | 3.8.0.0 (core 3.8.0), wheel hashes in `PINNED.md` | free, **not OSI**; research/internal use only | b2, b8 |
| [LMGC90](https://git-xen.lmgc.univ-montp2.fr/lmgc90/lmgc90_user) (pylmgc90) | `lmgc90_user_2026.rc1`, sha256 `a3190240…`, built locally | CeCILL v1.1 | b7 |
| [Kratos DEM](https://github.com/KratosMultiphysics/Kratos) | 10.4.4 (KratosMultiphysics + DEMApplication) | BSD-4 | b7 |

`compas_lmgc90` was evaluated and rejected (one contact law for every pair, no initial
velocity, no sphere contactor); `KratosMultiphysics-all` is not installable (missing
wheel), so the individual Kratos applications are pinned. Details per tool in
`oracles/<tool>/README.md`.

### PhysX

`stress-physx` links this repository's PhysX adapter (`blast/blast-stress-solver-rs`,
feature `physx`) against a CPU-only PhysX build. One that works:

```sh
cmake -S physx/compiler/public -B <build> -G Ninja -DCMAKE_BUILD_TYPE=release \
  -DCMAKE_C_COMPILER=clang -DCMAKE_CXX_COMPILER=clang++ \
  -DCMAKE_CXX_FLAGS=-UDISABLE_CUDA_PHYSX -DCMAKE_C_FLAGS=-UDISABLE_CUDA_PHYSX \
  -DPX_GPU_BACKEND=CUDA -DPHYSX_ROOT_DIR=$PWD/physx -DTARGET_BUILD_PLATFORM=linux \
  -DPX_OUTPUT_LIB_DIR=<build>/artifacts -DPX_OUTPUT_BIN_DIR=<build>/artifacts \
  -DNV_FORCE_64BIT_SUFFIX=TRUE -DPX_OUTPUT_ARCH=x86 -DPX_GENERATE_STATIC_LIBRARIES=TRUE \
  -DPX_BUILDSNIPPETS=FALSE -DPX_BUILDPVDRUNTIME=FALSE -DPX_GENERATE_GPU_PROJECTS=FALSE \
  -DPX_GENERATED_INCLUDE_DIR=<build>/include
cmake --build <build> --target PhysX PhysXCommon PhysXFoundation PhysXExtensions PhysXPvdSDK PhysXCooking
# install: physx/include + <build>/include/PxConfig.h -> $PHYSX_ROOT/include, the .a files -> $PHYSX_ROOT/lib
```

`-UDISABLE_CUDA_PHYSX` keeps `PxCreateCudaContextManager` linkable (the adapter calls
it unconditionally); without a GPU it returns null and the CPU scene is used.

## The model (what the reference implements)

See the module docs for the equations. In brief:

* **Bonds** (`bond.rs`): beam-type joints at the contact patch with axial `EA/L`,
  shear `GA/L`, bending `EI/L` (two axes) and torsion `GJ/L`; `L` is the chunk spacing
  along the normal. E and G may be scaled (`sim.stiffness_scale`); strengths and
  fracture energies never are.
* **Joint law** (`joint.rs`): tension cutoff on the extreme fibre, Mohr-Coulomb shear
  (`c + mu sigma_c`, capped), crushing, Euler buckling cap for slender members, dynamic
  increase factor (fib Model Code 2010 tensile law for concrete), Weibull strength
  factor per bond, and **static fatigue** (delayed failure under sustained load):
  subcritical crack growth `da/dt = A K^n` (Charles; Evans & Wiederhorn) integrated to
  a consumed life `omega' = (n + 1) s^n / t_test` and a residual strength
  `(1 - omega)^(1/(n-2))`. For concrete `n` and `t_test` follow from the same fib
  low-rate DIF exponent and reference rate (`n = 54.6`, `t_test = 100 s`): rate
  dependence and delayed failure are one mechanism. This is strength loss with time,
  not creep (no viscous deformation). Damage `D` (tension/shear) and `Dc` (crushing)
  soften with the fracture energy so a bond dissipates exactly `G_f A` (resolution
  independent); brittle = linear softening, ductile (steel) = plateau then snap. The
  cracked share of a joint becomes a no-tension multi-spring patch with Coulomb
  friction (rocking about the compressed edge, arching), so a cracked joint still
  carries compression inside its cluster. Rebar acts in parallel until its plastic
  work reaches its rupture energy.
* **Clusters** (`solver.rs`): connected components of intact bonds, one rigid body
  each. Chunks carry hidden 6-DOF displacements in the cluster's floating (mean-axis)
  frame; chunk loads subtract the rigid motion (linear, angular, centrifugal, Coriolis
  and gyroscopic terms). Splits give each child the exact momentum of its chunks
  (`v + w x r` plus hidden velocities); the energy still stored in the separating
  bonds is booked (`split_release`), not injected into the fragments.
* **Solve modes** (`sim.solve_mode`):
  * `explicit` — central differences with stiffness-proportional dashpots, the
    substep a safety fraction of the Gershgorin bound. **The ground truth.**
  * `implicit` (`implicit.rs`) — Newmark average acceleration at `sim.implicit_dt`
    (default the frame): `(K + gamma/(beta dt) C + M/(beta dt^2)) du = r`, i.e. the
    static solve plus one diagonal term; modified Newton with the joints' exact 6x6
    tangent (active contact springs, friction return map), secant fallback and line
    search; damage committed after convergence, so cascades spread over steps.
  * `quasi_static` (`statics.rs`) — equilibrium every frame (block-Jacobi PCG, inertia
    relief for free clusters) with the same-step cascade.
  * `adaptive` — explicit while recently loaded, quasi-static once quiet, no work
    while loads are steady.
* **Stiffness vs mass scaling**: `sim.stiffness_scale` lowers E (the original
  real-time compromise; strengths stay physical); `sim.mass_scaling_dt` instead adds
  deformation inertia only to chunks whose own stable step is below the target (as
  explicit FE codes do) and reports the added mass (`added_mass_fraction`).
* **Two scales** (`refine.rs`): coarse chunks with pre-fractured children refine where
  a bond's utilization passes `sim.refine_utilization` or a contact hits them; the
  children are relaxed to equilibrium and inherit crack history.
* **Loads** (`world.rs`, `blast.rs`, `api.rs`): gravity, supports with reactions,
  substep penalty contact (impactors, ground, debris landing on structures), impactor
  crush laws (the impactor's own rigid-plastic force-deformation curve, acting in its
  contact with the structure), Friedlander face pressures, Kinney-Graham blasts with
  angle of incidence, shadowing and clearing/venting, member and support removal by
  force replacement (sudden or gradual). Engine contact impulses become a filtered
  resting load plus impacts — never `impulse / dt` — either as pulses of Hertz (or
  crush-plateau) duration or, with `ImpactModel::VelocityCondition`, as an
  instantaneous velocity change of the struck chunk (momentum exact, no assumed
  duration).
* **Model switches** (`sim.features`, `Scene::with_feature`, `--feature`): every
  mechanism can be switched off to see what it contributes: `rate_effects`,
  `static_fatigue`, `weibull`, `softening` (off = threshold model), `crack_contact`,
  `crushing`, `buckling`, `rebar`, `rigid_motion_loads`, `blast_shadowing`,
  `blast_clearing`, `damping`. `tests/features.rs` checks that each removes exactly its mechanism.
* **Outputs**: per-bond damage/utilization/mode (`api::BondReport`), debug snapshots
  (`World::snapshot`: Love-Weber chunk stress, von Mises, principal stress, bond
  status), events (`Cracked`, `Creaked`, `Broken` with position and normal, `Split`,
  `Refined`), an energy ledger (fracture, friction, dashpots, contact, softening
  overshoot, energy left in split bonds).

## Review decisions (2026-10-09)

A review of the spec raised these points; how the reference resolves each:

| point | resolution |
|---|---|
| "Stored elastic energy of broken bonds released to fragments" would mean writing velocities into engine bodies | Not done. Splits are momentum exact from the chunks' actual velocities; the energy left in separating bonds is booked as `split_release`. Engine bodies only ever receive the children's exact momentum. |
| Crush caps vs PhysX contacts | The crush law is the impactor's own force-deformation curve in its contact with the structure (`CrushDesc`), never a cap on rigid-body contacts. With `ImpactModel::VelocityCondition` the engine's contact impulse is used as is. |
| Same-step cascade vs one correction per tick | Only `quasi_static` cascades within a step. `explicit` and `implicit` cascade over steps (a cascade takes time). |
| Sustained-load damage needs a cited law (and creep is out of scope) | Replaced by static fatigue from subcritical crack growth (Charles 1958; Evans & Wiederhorn 1974; Ritter 1978), with `n` and `t_test` derived from the material's fib MC2010 rate law. It is strength loss, not creep. |
| Lowering E shifts the impulsive/quasi-static boundary | Kept as an option and measured. Added implicit Newmark at true E and selective mass scaling; `scripts/render_videos.sh` renders the b5 punch-through with true E, `E x 0.01` and mass scaling side by side. |
| Impact as an initial velocity condition | `ImpactModel::VelocityCondition` (engine path), and the implicit mode's predictor delivers substep contact impulses the same way. |
| Analytic tolerances of 5% hide bugs | Benchmarks 1-4 gate at 1%; b2 also gates the exact discrete model at 1e-6; oracle-only comparisons keep the spec's 20-30%. |
| Bit-identical runs; explicit convergence criteria | `tests/determinism.rs`: repeated fracturing runs are bit-identical (explicit and implicit); static solves stop on a relative residual of 1e-10 and match the exact discrete solution in every load direction. |

## Swapping implementations

`api::StressSolverApi` is the contract a stress solver (this reference, the CUDA one)
implements: `step(FrameInput{dt, motion, contacts}) -> FrameOutput{fractures, events}`,
`clusters()`, `bond_reports(structure)`. Applying fractures to the engine
(`stress-physx`) is shared code on the other side of that trait.

## Status

All results below are from this revision (`cargo test --release`, `stress-ref check scenes golden`).

### Validation benchmarks

| # | benchmark | reference | result |
|---|---|---|---|
| 1 | single bond, tension and shear | analytic (1%), OpenCourant (5%) | failure force 0.01% / 0.00%, fracture energy 0.00%; OpenCourant 3.6% / 0.5% |
| 2 | chunked cantilever, N = 10/20/40 | Euler-Bernoulli (1%), exact discrete model (1e-6), OpenSees | tip 0.09-0.14%, root moment exact, frequency 0.07-0.15%; discrete model exact; OpenSees within 0.15% |
| 3 | bar impact, true and scaled E | analytic (1%), OpenCourant | wave speed 0.57%, reflection 0.46-0.66%, free-end doubling 0.55%; OpenCourant within 1.6% |
| 4 | sudden / gradual support loss | damped SDOF closed form (1%) | 1.9433 vs 1.9391 (0.22%); gradual 1.0014 |
| 5 | ram speed sweep 2/10/40 m/s | OpenCourant | 2 and 10 m/s: push-over as OpenCourant, speed lost within 21-29%. **40 m/s: open** — ours punches a hole; OpenCourant pushes over at every mesh but that verdict rests on unconverged far-field cracking (see gaps) |
| 6 | planar spall | 1-D analytic, OpenCourant | spall occurs in both (central back layer separates), layer speed 3.61 vs 3.02 m/s (19%), back-face peak 4.48 vs 4.83 m/s (7%; 1-D 4.94), front face intact in both |
| 7 | masonry wall, 4 and 15 m/s | LMGC90, Kratos DEM, OpenCourant (ensemble) | breach in all; ball speed lost and debris speed inside the oracles' spread. The oracles disagree among themselves (4 m/s debris speed 0.07-3.7 m/s) |
| 8 | frame column removal, sudden / gradual | OpenSees | redistribution within 0.01-0.3% (gradual), sudden elastic peaks within 2.3%; first failure matches |
| 9 | pressure pulse on a panel, low / high / 20 Weibull seeds | OpenCourant | breach matches; fragment speed 3.46 vs 3.45 m/s; 20-seed mean 3.13 vs 2.88 m/s (8%), peak displacement within 24% |
| 10 | refinement study | itself | timestep halving: < 1% on waves, < 10% on fracture metrics; two chunk sizes: same breach (fragment speed differs, see gaps) |
| 11 | optimized vs reference | — | out of scope here (no CUDA solver yet); the reference provides `StressSolverApi`, snapshots and bit-identical runs to diff against |

### Showcases (`tests/showcases.rs`)

| scenario | ours (asserted) |
|---|---|
| same car, fast vs slow | b5: 40 m/s punches a hole, 2 m/s pushes the wall over |
| overhang on a thin connection | creak 3.6 s, crack 6.8 s, snap 8.8 s, slab swings down; a thick neck holds |
| sudden vs gradual column loss | b8: sudden collapses the frame that gradual removal leaves standing |
| supports removed one by one | first removal carried; after the second: creak 4.3 s, crack 6.6 s, give way 8.9 s |
| thick-wall hit (spalling) | b6: back face separates first, front face intact |
| explosion beside building | facing wall breaches, shadowed wall behind survives; the same wall alone breaches |
| steel vs brick, same car | ductile wall dissipates ~100x more and takes more car speed |
| floor falls onto floor below | dropped slab breaks the lower slab; the same weight as a static load does not |
| masonry arch, keystone removed | stands under self-weight; collapses without its keystone |
| same wall, two chunk sizes | same breach outcome (`dynamics::same_panel_two_chunk_sizes_same_outcome`) |
| brick house | stands at 25% utilization with stress paths around the openings; car breaches it; corner settlement brings the corner down |

### Solve-mode findings (for the optimized solver)

* **Implicit Newmark at the frame step** reproduces structural redistribution (b8
  within 5% of explicit, b2 statics exact) and is unconditionally stable, but cannot
  show dynamics faster than its step: b4's amplification (period 0.89 ms) is 1.26 at
  one step per period and converges as the step resolves it (1.73 at T/4.5, 1.92 at
  T/18, 1.936 at T/45). It also needs the joint's exact tangent: with a diagonal secant
  the Newton iteration diverged on cracked joints (contact patch, friction).
* **Penalty contact must not be split across solve rates**: substep penalty contacts
  with an implicit frame step (predictor/corrector) inject energy on impact (b5 at
  10 m/s). In the engine path the contact is PhysX's and enters as an impulse
  (`ImpactModel::VelocityCondition`), which is momentum exact in both modes; the
  struck beam breaks into 3 (pulse), 4 (velocity condition, explicit) or 6 pieces
  (velocity condition, implicit at the frame step).
* **The engine's impulse is the weak link for punch-through**: a 200 kg ram at
  40 m/s into a free 528 kg concrete wall. The reference world (contact resolved at
  the substep against individual chunks, which break off during the contact) leaves
  the ram at 35 m/s (about 1000 N s transferred) and 6 fragments. Through PhysX the
  contact is resolved against the whole rigid wall and transfers several times that
  impulse; the stress solver then makes 24 bodies (Hertz pulse) or 184 (velocity
  condition, implicit). Momentum is exact in every case — what differs is how much
  of it the engine hands over. Feeding fracture back into the contact within the
  frame (or resolving impactor contact against the struck chunks' effective mass) is
  what the engine path needs for local failure; `tests/physx_integration.rs` runs
  both impact models end to end.
* **Mass scaling** keeps statics exact and cuts substeps, but on uniform chunks every
  chunk is critical: 4x the step on the 40-chunk cantilever costs 15x the mass.

### Known gaps

* **b5 at 40 m/s**: ours makes a local hole; OpenCourant pushes the wall over at 2, 3
  and 4 elements per chunk edge (a hole only at 1). The oracle mesh study
  (`golden_mesh/b5_wall_impact_v40/`) shows why this is not yet a usable verdict: the
  impact zone is fully shattered and converged at every mesh (ours detaches it too),
  but the far-field bending cracks that make it a push-over keep growing with
  refinement (9, 128, 348, 552 broken bonds) — the oracle's elastic chunks have no
  crushing or erosion, so the ram face sees ~190 MPa (concrete crushes at 30 MPa) and
  a pulse ~5x sharper than ours. The converged oracle quantity, ram speed lost
  ~6.4 m/s, is 37% above ours (4.0; 4.2 with `--feature crushing=off`), just outside
  the 30% gate. Closing this needs a crushing law in the oracle (pressure-capped
  chunks) and a contact-pulse comparison; it stays open.
* **Lateral release / Poisson coupling**: the chunk network has no Poisson effect, so
  spall breaks whole planes where the continuum keeps corner ligaments (b6), and peak
  panel displacement is 20-24% above OpenCourant (b9).
* **Fragment speed vs chunk size**: the breached panel at 0.05 m chunks throws
  fragments at 2.3 m/s vs 3.5 m/s at 0.1 m (two layers through the thickness resolve
  hinge crushing). Breach agrees; speed is reported, not gated.
* **Angular momentum** is conserved to 0.1-0.2% in a 40 m/s fracturing impact (the
  small-strain bond model's moments balance about undeformed centres); linear
  momentum to round-off.
* **Implicit mode in the standalone world** is for structural dynamics, blasts and
  debris; impactor impacts need the explicit solve or the engine path.
* **Debris management** (lifetimes, merging settled rubble) is an engine concern and
  not in the reference.

### Spec checklist → implementation → test

| spec item | where | verified by |
|---|---|---|
| Clusters with a bond graph, split into rigid bodies | `solver.rs` (`split_cluster`) | `conservation::momentum_is_conserved_through_impact_and_fracture`, `stress-physx` tests |
| Fragments inherit `v + w x r`; momentum through splits | `solver.rs` | `conservation::fragments_inherit_parent_rigid_velocity_field` |
| Bond stiffness from E, G, area, spacing | `bond.rs`, `scene.rs` (`with_derived`) | b2 (OpenSees, Euler-Bernoulli), b3 (wave speed) |
| Axial, shear, bending, torsion | `bond.rs` | `bond.rs` unit tests (torsion constant), b2, b8 |
| Per-material parameters | `material.rs` | `failure_laws` |
| Brittle, steel (ductile) and rebar bond types | `joint.rs` | `failure_laws::steel_absorbs_…`, `failure_laws::rebar_holds_…`, showcase car |
| Multi-level pre-fracture | `refine.rs`, `world.rs` | `refinement` (3 tests) |
| Gravity prestress | `statics.rs` | `dynamics::gravity_prestress_starts_structures_at_rest` |
| Anchors and supports with reactions | `world.rs` | b4, b8 (OpenSees reactions), `dynamics::debris_landing_…` |
| Rigid motion subtracted from chunk loads | `solver.rs` (`frame_loads`) | `dynamics::rigid_motion_is_subtracted_from_chunk_loads` |
| Contact: resting load + impact pulse of physical duration | `api.rs` (`ContactLoadFilter`) | `engine_api` (Hertz duration, resting load), `stress-physx` |
| Crush-capped impactors | `world.rs`, `api.rs` | `engine_api::crush_capped_…`, showcase car |
| Blast: pulse, falloff, incidence, shadowing, venting | `blast.rs`, `world.rs` | `blast.rs` unit tests, b9 (OpenCourant), showcase two walls |
| Debris landing loads structure dynamically | `world.rs` contact | `dynamics::debris_landing_…`, showcase floor drop |
| Chunk inertia in the stress solve | explicit dynamics | b3, b4, b6 |
| Wave speed `sqrt(E_eff/rho)` | | b3 (true and scaled stiffness) |
| Dynamic amplification on sudden release | | b4 (analytic 2x), b8 sudden vs gradual (OpenSees) |
| Reflection at free surfaces (spall) | | b3 reflection, b6 spall |
| Light damping | stiffness-proportional dashpots | energy ledger tests |
| Tension cutoff, Mohr-Coulomb, crushing | `joint.rs` | `failure_laws`, b1 |
| Buckling cap | `joint.rs` | `failure_laws::buckling_caps_…` |
| Dynamic increase factor | `material.rs` (fib MC2010), `joint.rs` | `failure_laws::dynamic_increase_factor_…`, `features::rate_effects_off_…` |
| Fracture-energy softening (resolution independent) | `joint.rs` (`damage_increment`) | b1 energy, `failure_laws::fracture_energy_per_area_…`, `joint.rs` unit tests |
| Time-dependent damage under sustained overload (creak, crack, give way) | static fatigue, `material.rs` / `joint.rs` | `failure_laws::sustained_overload_…` (closed-form lifetime within 1%), showcases overhang and supports |
| Weibull strengths | `material.rs` | `failure_laws::weibull_…`, b9 20-seed distribution |
| Same-step cascade | `statics.rs` | `failure_laws::same_step_cascade_…` |
| Stored energy of broken bonds released | ledger `split_release`, `softening_overshoot` | `conservation::fracture_never_gains_energy_…` |
| Per-bond damage exposed | `api.rs` (`BondReport`), `SolverEvent` | `engine_api::engine_coupled_fracture_reports_…` |
| Converges with timestep and chunk size | | `dynamics::converges_as_the_timestep_shrinks`, `dynamics::same_panel_two_chunk_sizes_…`, `refinement` |
| No energy gain; dissipation accounted | `EnergyLedger`, `ContactLedger` | `conservation` |
| Momentum through fracture | | `conservation`, `stress-physx` |
| Same outcome at different frame rates | | `dynamics::same_outcome_at_different_frame_rates` |
| Stiffness scaling compromise | `sim.stiffness_scale`, `min_stiffness_scale`, or `sim.mass_scaling_dt` | b3 scaled, `dynamics::stiffness_scaling_…`, `solve_modes::mass_scaling_…` |
| Activity-based solving | `SolveMode::Adaptive`, `SolveMode::Implicit` | `dynamics::solve_modes_agree`, `solve_modes` |
| Model switches (runtime) | `sim.features` | `features` (9 tests) |
| Two-scale structure | `refine.rs` | `refinement` |
| Debris management (lifetimes, merging rubble) | not in the reference: an engine concern | — |

### Videos

`scripts/render_videos.sh` renders every benchmark, showcase and comparison into
`videos/` (47 MP4s, ~90 MB, not committed; about 1.5 h on 2 cores). Comparisons:

| video | what it shows |
|---|---|
| `lead_fast_vs_slow` | same ram at 40 vs 2 m/s: local failure vs the wall pushed over |
| `lead_sudden_vs_gradual` | sudden column loss collapses the frame that gradual removal leaves standing |
| `feature_inertia` | explicit dynamics vs quasi-static (no inertia) on the 40 m/s ram |
| `feature_stiffness_scaling` | true E, `E x 0.01` and mass scaling to 4x the step on the 40 m/s ram: 114, 63 and 3 pieces — both compromises change the failure (mass scaling turns it into a punched plug; on uniform chunks it is not selective) |
| `feature_implicit` | explicit vs implicit at the frame step on sudden column loss |
| `feature_shadowing` | blast beside two walls: with shadowing the back wall survives, without it breaks up |
| `feature_softening` | fracture-energy softening vs a threshold model |
| `feature_crack_contact` | arch without its keystone, with and without the cracked joints' contact patch |
| `feature_weibull` | Weibull vs uniform bond strengths on the breached panel |
| `s_overhang_thin_fatigue` | overhang with and without static fatigue (snaps at ~9 s vs holds) |
| `b5_wall_impact_v10_rate`, `b7_masonry_v15_modes` | rate effects on/off; explicit vs adaptive |
