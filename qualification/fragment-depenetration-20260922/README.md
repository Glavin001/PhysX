# Free-fragment depenetration clamp

A damaged Bayline house that never settles is a debris stack the PGS solver
cannot resolve, not a sleep or activity bug. This adds one stage setting that
bounds the push-out of free fragments and leaves everything else in place.
This is qualified on the eight isolated house cases below; it is **not** a
full-town or performance qualification and is not deployed.

## Defect

After a meteor penetrates a `residential-v2` roof, debris at ~70 m/s (1.2 m per
60 Hz step) tunnels the 18 cm floor deck and lands inside the ground box and
inside other pieces. A light fragment (a 2.7 kg fence rail) then sits 7 cm
inside the static ground with a 52 kg piece 10 cm inside it from above, itself
under a heavier slab. Its own contacts (from the audit below): ground, normal
up, separations −0.071/−0.035/+0.038/+0.002 m, impulses 7–17 N·s per step;
the piece above, normal down, separations −0.10/−0.07/−0.06/−0.02 m, impulses
up to 27 N·s. With PhysX's unbounded depenetration clamp (`maxPenBias =
−1e32`) the opposing position biases are several metres per second each, and
eight Gauss–Seidel iterations across the mass ratio 2.7 : 52 : ~200 kg end in a
stationary fixed point: the integration kernel returns the body unchanged every
step (traced: Δp ≈ 1e-6 m, Δv ≈ 3e-5 m/s after gravity had been applied), so
its pose never moves while its reported velocity stays at 0.3 m/s, 12 rad/s.
Heavier neighbours fall into a period-2 cycle instead, teleporting 7 cm
between two poses every step; those keep the island's wake counters reset, so
hundreds of bodies never sleep. Everything about the bodies is otherwise
correct: island node active and listed, `PxgBodySim` sane and identical to the
CPU mirror, solver body record at the expected slot, not kinematic, not frozen.
Lifting a stuck body by 1 m makes it fall at exactly *g* and land normally.

Ruled out on the way, each by measurement: CPU/island activity desync (an
audit found seven fragments stranded "activating" for a few steps at impact,
all resolved by step 20); stale GPU slots; kinematic remnants carrying phantom
velocities (all zero on the GPU); stabilization as the cause (zombies persist
with it off); TGS (dissolves the stacks but changes the impulses the stage
reads as bond load: 1,616 → 6,834 breaks on the porch cannonball, 3 escapes on
the bungalow meteor); more position iterations (16 dissolves this arrangement,
32 produces another with 10 stuck bodies); a whole-body cap via
`setMaxDepenetrationVelocity` on the cluster parents (fixes settling but halves
the projectile's trial impulse against the anchored remnant: the cannonball
bounces off the wall with 242 breaks instead of 1,799).

## Change

`PxDestructionStressDesc::fragmentMaxDepenetrationVelocity` (v18; zero, the
default, inherits the parent's clamp as before). At fragment creation on the
GPU (`nativeCandidateState`, all three creation paths) an unsupported fragment
gets `maxPenBias = max(inherited, −value)`. Supported remnants keep the parent's
value. Because a pair uses the tighter of its two clamps, debris–ground,
debris–debris and debris–remnant push-out is bounded while a projectile's trial
contact with the anchored remnant — the load that decides fracture — is
unchanged. No material, gravity, damping, sleep, freeze or iteration change.

Also: `physx_native_fragment_resting_on_static` has passed since `d80f5948`
(verified on the unmodified shared build too); its `WILL_FAIL` marker was stale
and is removed.

Diagnostics kept, all off unless an environment variable is set:
`PX_DESTRUCTION_ACTIVITY_AUDIT=1` (per-step CPU-vs-island activity check, the
ten-step "moves under a tenth of its own velocity" zombie detector with the
body's GPU record, solver slot and contact pairs) and
`PX_DESTRUCTION_TRACE_NODE=<n>[,<n>…]` (a body's GPU record before the solve,
after integration and at end of step).

## Evidence

Harness: vibe-land `house-impact-review` (private build against this
worktree), correction limit 1, 8/2 contact iterations, 90 s after impact,
1,800-tick intact rest gate before every shot. Stabilization off unless noted.
`evidence.json` carries every run's hashes and settings.

| Case | Production (stab on, uncapped) | Stab off + fragment cap 0.5 m/s |
| --- | --- | --- |
| Deployed bungalow, cannonball | 1,799 breaks, **147 awake at 90 s**, never converged, 4.5 ms/tick | 732 breaks, asleep 287 ticks after impact, 0.50 ms/tick |
| Deployed bungalow, meteor | 1,381, asleep +245 | 1,382, asleep +226 |
| Deployed porch house, cannonball | 1,616, asleep +260 | 1,616, asleep +156 |
| Deployed porch house, meteor | 809, asleep +369 | 809, asleep +203 |
| v2 bungalow, cannonball | 1,113, **149 awake** | 1,117, asleep +852 |
| v2 bungalow, meteor | 1,938, **451 awake** | 1,992, asleep +2,847 (stress solve still iterating at 90 s) |
| v2 porch, cannonball | 1,362, asleep +693 | 1,044, asleep +662 |
| v2 porch, meteor | 3,232, **823 awake** | 3,204, asleep +2,028 |

Zero escaped bodies in every run. The bungalow-cannonball difference is siding
torn along the whole length of both side walls and floor bonds while the ball
flew through the interior at 59 m/s — impulse from the unbounded push-out, not
from the ball hitting those walls; the front breach and far-wall exit are the
same in both, and the trial-pass breaks are 474 vs 486. Cap sweep on the v2
bungalow meteor: 3 m/s still deadlocks (18 stuck bodies), 1 m/s and 0.5 m/s
dissolve every stack. With stabilization left on plus the cap, two of three
failing cases pass; the third keeps one 22 kg piece on the roof in a
freeze/thaw slide cycle, so the qualified pair is stabilization off + cap.

Engine checks: 19 selected native tests (`ctest-selected.log`), all pass
including the retired known fault.

## Reproduce

```sh
python3 tools/scripts/build-destruction-sdk.py --jobs 12 --cuda /usr/local/cuda-12.8/bin/nvcc
LD_LIBRARY_PATH="$PWD/physx/bin/linux.x86_64/release" \
  ctest --test-dir out/destruction-sdk -j1 --output-on-failure \
  -R 'post_correction|chained_fracture|native_gpu_collision_preparation|native_standard_(reuse|reported_reuse|sleep|awake)|native_gpu_contact_response|native_gpu_accepted_properties|native_gpu_body_allocation|native_gpu_body_state|native_gpu_motion_slots|native_gpu_correction_bodies|native_gpu_node_births|native_fragment_resting'
```

Then, in vibe-land, build `house-impact-review` with
`PHYSX_DESTRUCTION_SDK=<this worktree>` and run
`structures/town-kit/repros/house-cannonball/run.py` with
`VIBE_PHYSX_STABILIZATION=0 VIBE_CITY_NATIVE_FRAGMENT_DEPEN_VELOCITY=0.5`
on the case directories named in `evidence.json`.

## Not claimed

- The stress solver's slow convergence on a fully asleep damaged remnant
  (16 iterations per tick for up to a minute) is untouched.
- No 36-building or continuous-play measurement.
- Fragments still tunnel thin decks at meteor speeds; this bounds what happens
  after they land, it does not stop them landing inside things.
