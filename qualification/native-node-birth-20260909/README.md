# GPU fragment node births and default roster consumption

Ranked replacement 1 is still incomplete. This increment moves fragment node
birth records into the existing CUDA allocation transaction and removes their
redundant CPU-to-GPU birth updates. The current solver consumes the GPU registry;
CPU BodySim construction, active-list scheduling, iteration maxima and contact
registration/rebinding still precede corrected physics. Ranked replacements 2–7
remain pending. This is architectural progress, not a demonstrated speedup.

## Final ownership and lifetime

- GPU allocation writes lifetime, dynamic membership and initial support metadata
  alongside the canonical fragment body, before CPU compatibility construction.
  All selected addresses and lifetime overflow are checked before any assignment.
- A device transaction receipt prevents allocation retries from incrementing
  lifetimes twice. Capacity storage alone never becomes a simulated body.
- Pre-solve GPU contact/island work consumes these records. Newly materialized
  CPU nodes no longer enqueue the same birth payload for upload; ordinary actor
  edits and retained-owner type changes still use their required update path.
- The mutable registration array and completed solver-phase snapshot have
  independent allocations/lifetimes. Fragment growth cannot invalidate the
  completed phase view borrowed by contact and observation consumers.
- Destruction configuration now defaults GPU island repair on. Requesting the
  destruction API activates its GPU pre-solve tracking defaults. Unrelated scenes
  do not start tracking merely by creating a GPU scene. Explicit diagnostic
  controls and required unsupported-interaction handling remain.
- Ordinary actor mode and sleeping remain enabled. Full device union-find
  ownership has a different contract and is not silently enabled for sleeping.
- Private runtime factory V9 replaces V8; public ABI15 is unchanged. GPU module,
  native consumers and Rust benchmark were rebuilt together. Immutable matching
  artifacts are under `out/native-node-birth-20260909/candidate`.

This replaces a producer dependency, not the whole lifecycle. CPU address grants
remain exceptional resource management; CPU actor/node/contact registration is
still an intermediate dependency that the next increment must remove. Spare
registry memory and growth are accounted for; the existing registry is split
from phase storage, not supplemented with a second alternative simulation.

## Failures found and fixed

The initial pre-compatibility boundary probe failed against predecessor 19619764
because no GPU birth registry existed. Its log is preserved; the current V9 test
cannot be loaded against the incompatible V8 interface.

The first ordinary-mode omission check failed because its predicate required full
GPU connectivity ownership, which excludes sleeping. It now checks the actual
pre-solve roster producer contract. The initial shared allocation also failed the
large contact audit: growth freed a still-borrowed completed-phase pointer.
Separating mutable registry storage from phase storage fixed that failure. Both
failed logs and the later passing results remain in `evidence/`.

## Verification

- 53 selected native/timing/allocation tests pass on the final source and default
  settings. The added ordinary-mode bombardment test also passes: 54 unique
  selected tests across the suite and targeted extension, not a claimed full SDK
  or Rust/WASM test run.
- The new six-chunk/three-bond fixture plus one ordinary body checks GPU births
  before CPU construction, growth then no-growth splitting, suppressed redundant
  CPU birth payloads, GPU consumer use with defaults, one correction and two
  stress evaluations. Independent pre-solve metadata verification passes.
- Allocation tests cover retries, holes, source/target aliasing, supported nodes,
  lifetime exhaustion and valid work counts through 113,664 request slots. These
  are allocation fixtures, not a matching rigid-body/stress workload.
- Allocation memcheck/synccheck/racecheck pass the address fixture; full allocation
  initcheck and the ordinary node-birth integration initcheck pass. These scoped
  sanitizer results do not assert engine-wide sanitizer coverage.
- Frozen wall: one building, 444 chunks, 896 bonds, one projectile, 600 steps;
  original exact signature passes with 398 supported chunks, 46 detached,
  199 broken bonds and actual clearance through both walls. Historical mode:
  Direct GPU enabled, sleeping disabled.
- Ordinary wall: same authored asset, 128 steps, Direct GPU disabled, sleeping
  enabled. Matches the established ordinary reference: 400 supported chunks,
  44 detached, 199 broken bonds, zero maximum compared position error.
- Both large demo audit modes pass: 256 buildings, 113,664 chunks, 229,376 bonds,
  256 projectiles, 180 steps each. Independent contact uniqueness, ownership,
  island boundary, solver metadata and motion/publication checks are enabled.
- Exact Rust consumer tape additionally passes every-tick GPU/CPU ownership and
  bond-publication auditing for 96 steps. Diagnostic runs are not performance
  measurements. No source sibling, deployed module or service was changed.

## Matched complete-step screen

[Destruction](shots/report.md) and [fresh intact idle](idle/report.md) are paired.
256 buildings, 113,664 chunks, 229,376 bonds; 256 simultaneous projectiles or an
independent empty command tape. ABBA, two runs per arm/regime, 96 steps / 1.6
simulated seconds each; Direct GPU off, sleeping on, dt1/60, maximum one correction
and two stress evaluations. Complete timing includes commands, physics, stress,
topology, correction, growth and accepted observations. Rendering/networking are
excluded. No first-step or allocation peaks are discarded.

Fracture peaks: baseline 140.867/144.771 ms; candidate 144.715/134.571 ms.
All-step maxima: baseline 156.590/158.678 ms; candidate 161.764/156.946 ms,
all at startup. Intact-idle medians: baseline 0.464/0.446 ms versus candidate
0.437/0.415 ms; startup remains approximately 158–160 ms. These short results
establish neither a robust speedup nor absence of regression. No 60 Hz,
five-60-second, endurance or historical external-backend parity claim.

Physical counters match at major fracture tick48 and until tick76. First counted
difference is two normal contacts at tick77. Both candidate repetitions finish
with 71,118 broken bonds and 15,756 fragments; both baselines finish with 71,096
and 15,738. All have 42 corrected steps. The stronger ordinary large-scene and
exact-tape ownership audits pass, but the cause of this repeatable trajectory
divergence is not isolated. Do not describe these as identical trajectories or
credit their final work difference as a performance improvement.

## Next required replacement

Consume GPU-created registration in the active solver schedule, including type,
activation ordering and iteration settings, without requiring CPU BodySim
objects. Then move contact registration/ownership prerequisites off the host and
make CPU compatibility creation accepted-state publication. Do not advance to
rank2 or optimize a second independent roster while these dependencies remain.
