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
| `crates/stress-ref/src/solver.rs`, `statics.rs`, `refine.rs` | clusters, explicit substeps, quasi-static solve, fracture/splitting, refinement |
| `crates/stress-ref/src/world.rs`, `contact.rs`, `blast.rs` | standalone world: impactors, ground, contact, scripted loads, blast, events, probes |
| `crates/stress-ref/src/observation.rs`, `metrics.rs` | `stress-observation/1` and the metrics computed identically for every solver |
| `crates/stress-ref/src/api.rs` | engine-facing trait (`StressSolverApi`), contact-impulse filter, `EngineCoupledSolver` |
| `crates/stress-ref/tests/` | the test suite (analytic, conservation, failure laws, dynamics, refinement, engine API) |
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

`stress-ref run` options: `--seed N`, `--mode explicit|adaptive|quasi_static`,
`--stiffness-scale S`, `--max-substep DT`, `--frame-dt DT`, `--no-fracture`.

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
  (`c + mu sigma_c`, capped), crushing, Euler buckling cap for slender members, DIF
  (CEB-FIP power law), Weibull strength factor per bond, sustained-load strength loss.
  Damage `D` (tension/shear) and `Dc` (crushing) soften with the fracture energy so a
  bond dissipates exactly `G_f A` (resolution independent); brittle = linear
  softening, ductile (steel) = plateau then snap. The cracked share of a joint becomes a
  no-tension multi-spring patch with Coulomb friction (rocking about the compressed
  edge, arching), so a cracked joint still carries compression inside its cluster.
  Rebar acts in parallel until its plastic work reaches its rupture energy.
* **Clusters** (`solver.rs`): connected components of intact bonds, one rigid body
  each. Chunks carry hidden 6-DOF displacements in the cluster's floating frame;
  chunk loads subtract the rigid motion (linear, angular, centrifugal, Coriolis and
  gyroscopic terms). Explicit central differences with stiffness-proportional dashpots;
  the substep is a safety fraction of the Gershgorin bound. Splits give each child the
  exact momentum of its chunks (`v + w x r` plus hidden velocities).
* **Statics** (`statics.rs`): modified Newton with block-Jacobi PCG, inertia relief
  for free clusters, gravity prestress, same-step cascade.
* **Activity** (`SolveMode::Adaptive`): explicit while recently loaded, quasi-static
  once quiet, no work while loads are steady; `Explicit` everywhere is the ground truth.
* **Two scales** (`refine.rs`): coarse chunks with pre-fractured children refine where
  a bond's utilization passes `sim.refine_utilization` or a contact hits them; the
  children are relaxed to equilibrium and inherit crack history.
* **Loads** (`world.rs`, `blast.rs`, `api.rs`): gravity, supports with reactions,
  substep penalty contact (impactors, ground, debris landing on structures),
  crush-capped impactors (force cap + energy budget), Friedlander face pressures,
  Kinney-Graham blasts with angle of incidence, shadowing and clearing/venting, member
  and support removal by force replacement (sudden or gradual). Engine contact impulses
  become a filtered resting load plus impact pulses of Hertz (or crush-plateau)
  duration — never `impulse / dt`.
* **Outputs**: per-bond damage/utilization/mode (`api::BondReport`), events
  (`Cracked`, `Creaked`, `Broken` with position and normal, `Split`, `Refined`), an
  energy ledger (fracture, friction, dashpots, contact, softening overshoot, energy
  left in split bonds).

## Swapping implementations

`api::StressSolverApi` is the contract a stress solver (this reference, the CUDA one)
implements: `step(FrameInput{dt, motion, contacts}) -> FrameOutput{fractures, events}`,
`clusters()`, `bond_reports(structure)`. Applying fractures to the engine
(`stress-physx`) is shared code on the other side of that trait.

## Status

STATUS_PLACEHOLDER
