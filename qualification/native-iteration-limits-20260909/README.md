# GPU-owned rigid iteration settings and launch-limit reduction

Ranked replacement 1 remains incomplete. Native fragment solver iteration
settings now inherit from the canonical GPU body. The native solver computes
active rigid-body iteration maxima on GPU, removing the per-body CPU ancestor
read during fracture and the native path's CPU rigid-body maxima scan. This is
retained architectural progress with a short performance screen, not a robust
peak-speed improvement or completed GPU lifecycle.

## Production data flow

Ordinary authored setters upload packed iteration settings in the GPU body record.
CUDA fragment allocation copies those settings with the source body. The actual
active solver-node list indexes those records for an exact position/velocity max
reduction. Inactive capacity, kinematics and unrelated stored bodies are excluded.
The existing PhysX dirty-state condition retains unchanged limits; this change
neither changes iteration counts nor imposes a computational budget.

The reduction is submitted immediately after the existing active-index upload,
on its ordered solver stream. Producers overwrite all partials; no clearing pass
is needed. Up to 128 blocks of 256 threads process the active list; one block
writes the final value directly for small lists, otherwise a second reduction
combines the partials. Invalid indices and zero/out-of-range packed settings fail
explicitly. Independent position and velocity maxima are preserved.

**Remaining host dependency:** PhysX's current launch loops still consume the two
maxima on CPU. A 12-byte result includes those maxima plus validation status;
`GpuDynamics.NativeIterationLimitsCompletion` orders that observation. This is an
added small host completion dependency, not a claim to eliminate every host wait.
It replaces reads of individual CPU body properties. Active-list ordering,
dirty-state ownership, articulation/non-rigid scheduling, BodySim construction
and contact registration still require their separate replacements. Do not
present this as fully device-controlled corrected physics.

All inherited physical settings now reach ordinary CPU fragment objects at final
accepted property publication, including iteration settings. Runtime setters
update GPU state and invalidate launch-limit caching. No tolerance, force,
material, fracture or correction equations changed.

## Storage and interfaces

GPU body stride grows from 240 to 256 bytes: one aligned configuration lane with
packed counts and explicitly zeroed reserved words. Body upload handles the full
half-warp, including updates in the ordinary native mode. Checkpoints and growth
use the actual body type size. Fixed reduction scratch is 128 twelve-byte partials,
one result, one pinned observation and one event per destruction runtime.
There is no per-fracture reduction allocation.

Accepted private properties gain four bytes. Private runtime factory is V10;
public scene API remains version15. CPU/GPU SDK libraries, native tests/demo and
Rust consumer were rebuilt together. Old private producer/consumer layouts must
not be mixed. Matching immutable files and hashes are under
`out/native-iteration-limits-20260909/candidate` and `evidence/candidate-hashes.json`.

Compiler resource output reports 29 registers/thread for the producer and 28 for
the final reduction, each with 116 shared bytes, zero stack/local bytes. This is
compiler evidence, not a hardware-counter or bandwidth/occupancy diagnosis.

## Verification and preserved failures

- 54 selected native/timing/allocation tests pass, including both ordinary and
  Direct GPU large bombardment contact/island/motion audits. Each large audit
  uses 256 buildings, 113,664 chunks, 229,376 bonds, 256 projectiles and 180 steps.
- The strengthened PGS/TGS property oracle verifies that new fragment CPU
  placeholders do not contain inherited 7/3 iteration settings before correction,
  while the actual corrected launch limits are 7/3. Accepted properties agree;
  a later ordinary setter changes both GPU settings and launch limits to 11/5.
- The new independent GPU limits oracle covers 0, 1, 257, 4,099 and 113,664 active
  bodies, with no stress bonds. Inactive records deliberately contain larger
  limits; repeated submissions, offsets, invalid indices and zero settings are
  checked. Alongside the selected native suite this is 55 unique test cases.
- New reduction memcheck, initcheck, synccheck and racecheck pass. Both native
  PGS/TGS accepted-property initchecks pass. No engine-wide sanitizer claim.
- Frozen wall: 444 chunks, 896 bonds, one projectile, 600 steps, original signature
  and both-wall clearance pass: 398 supported, 46 detached, 199 broken bonds;
  Direct GPU on/sleep off, at most one correction.
- Ordinary wall: same asset, 128 steps, Direct GPU off/sleep on. Exact existing
  mode-matched reference passes with zero compared position error: 400 supported,
  44 detached and 199 broken bonds.
- The first ordinary verifier invocation used another prefix capture as its
  reference. It rejected that reference's missing full-audit certificate before
  comparison. The already-completed capture was then validated against the
  original full audited reference without rerunning simulation. Initial failed
  command and corrected-reference receipt are retained; no assertion was weakened.
- Initial combined build could not invoke a target newly introduced during its
  own CMake regeneration. Invoking the newly generated target separately succeeded.

## Paired complete-step screen

[Destruction](shots/report.md) and [fresh intact idle](idle/report.md):
256 buildings, 113,664 chunks, 229,376 bonds; 256 projectiles or an empty command
tape. ABBA, two runs per arm/regime, 96 steps / 1.6 simulated seconds each,
Direct GPU off, sleeping on, dt1/60, maximum one correction/two stress evaluations.
All commands, physics, stress, topology, correction, growth and accepted consumer
observations are timed; rendering/networking are excluded. First steps remain.

Fracture peaks baseline 133.063/135.204 ms versus candidate 133.376/131.158 ms.
All-step startup maxima baseline 159.913/157.348 ms versus candidate
157.510/158.821 ms. Idle medians baseline 0.456/0.444 ms versus candidate
0.424/0.432 ms; startup still dominates the all-step idle maximum.
These overlapping short-run results do not establish a robust speedup or prove
absence of regression. No five-60-second, endurance, real-time or external-backend
parity claim is made.

Every reported physical-work counter matches across all four destruction runs.
At major fracture tick48: 10,449 fragments, 10,193 awake, 216,220 normal contacts,
57,788 cumulative broken bonds and one correction/two stress evaluations.
All runs finish with 71,118 broken bonds, 15,756 fragments and 42 corrected steps.
This is agreement with predecessor31ebf778, not resolution of that predecessor's
recorded divergence from older default-disabled GPU-roster execution.

## Next required work

The CPU no longer supplies native fragment physical settings to corrected solving.
Next replace active scheduling/activation order and contact numerical registration
so CPU objects cease being prerequisites. The 12-byte host launch-limit receipt
must eventually be consumed by device-controlled solver orchestration as well.
Keep the current timing tradeoff explicit; do not optimize the residual CPU bridge
or advance to ranked replacement2 while the first replacement remains incomplete.
