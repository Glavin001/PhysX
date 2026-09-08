# Ordinary PhysX API + embedded CUDA destruction: WIP report

**Working native prototype. Full migration parity is not qualified.**

✅ 15 selected tests pass ([log](final-tests.log)).
✅ Memcheck: zero reported errors in the two-chunk, one-bond sleep-boundary control/correction comparison ([log](memcheck.log)).
✅ Ordinary actor access, raycast/overlap/sweep, public event-ordered GPU observations, one correction per step, supported/fragment mass, sleep and command/collision wake tests.
✅ Original Direct GPU wall passes the unchanged frozen gate ([result](reference-quality.json)).
⚠️ Ordinary sleeping wall passes functional checks but **fails frozen topology parity** ([result](sleeping-functional-quality.json)).

## Building demonstration

One building, **444 chunks / 896 bonds / one projectile**, 600 steps (10 simulated seconds), timestep 1/60, correction limit one per step. Direct GPU mode is off; sleeping is on. Rendering and heavy observations are offline.

| Physical result | Original frozen reference | Ordinary sleeping demo |
|---|---:|---:|
| Supported chunks | 398 | 400 |
| Detached chunks | 46 | 44 |
| Broken bonds | 199 | 197 |
| Final clusters | 43 | 41 |

The ordinary demo has real entry/exit holes, projectile rear-wall clearance at 0.683 simulated seconds, converged stress and zero measured render/collision position disagreement. **Those functional checks do not turn its failed exact topology gate into a pass.**

The audited capture's **complete simulation advance**, including commands, physics, destruction and required completion, measured **0.611 / 3.887 / 10.916 ms min / mean / max**. Rendering, encoding and report work are excluded. This is one heavy-audit capture, **not isolated performance qualification or proof of whole-game 60 Hz**. No outliers were removed.

[Video](../../out/standard-scene-sleeping-wall-v4/native-captioned.mp4) · [API/architecture and commands](../../docs/destruction/STANDARD_GPU_SCENE.md) · [Machine-readable report](report.json)

## Remaining

Resolve the cross-mode fracture difference before claiming frozen migration parity. GPU state matches before impact; small first-correction motion differences and later legacy allocation-default damping were observed. They do not prove the complete cause. The original golden is unchanged.

Native sleeping still consumes GPU-repaired CPU membership; ordinary queries still require CPU observations. Moving kinematic/controller and joint/CCD correction remain excluded. Full GPU lifecycle, game/Rust integration and large-scene performance qualification are not complete.
