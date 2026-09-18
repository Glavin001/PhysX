# Native PhysX GPU wall penetration — 2026-09-06

## Result

One projectile passes through both walls of a 444-chunk, 896-bond building. At 0.6833 seconds its entire sphere clears the rear wall (center z=4.9400 m, radius 0.75 m, wall outer face z=3.98 m). The final supported cluster contains **398 chunks (89.64%)**; 46 chunks detach into 42 groups. **199 bonds break**, leaving 697 intact.

The accepted GPU trace verifies that four central collision chunks on each face detach and move more than one meter by 2 seconds. Rendered chunk positions match collision positions exactly in this capture; maximum cluster COM reconciliation error is 3.85e-6 m. All recorded stress solves report convergence. This demonstrates a passage through displaced wall geometry, rather than a visual-only hole or a projectile passing through unchanged wall chunks.

## What changed

Only explicit demo authoring and recording/verification tools changed. Engine stress, fracture, collision and correction algorithms are unchanged. Existing aerial launch, mass and material defaults remain available.

- Direct wall shot: initial center (0, 6.5, -16) m, velocity (0, 3, 40) m/s, radius 0.75 m, mass 18,000 kg, matching solid-sphere inertia. It starts fully outside the building and crosses between floor slabs. No steering after insertion.
- Authored wall strengths are 24 times the earlier weak-material fixture: compression elastic/fatal 6/12 MPa, tension 0.72/1.44 MPa, shear 1.92/3.84 MPa.
- Floors and corner columns use a second material with strengths 40 times the wall material. Bonds between two frame chunks use that material; frame-to-wall bonds use the wall material. These are explicit illustrative material inputs, not a calibrated engineering model of a particular real building.
- Geometry, chunk masses, bond areas, compliance scaling, initial bond health, support rules, timestep and stress tolerance remain unchanged. All bonds start intact. No prescribed hole, special impact weakening or fracture-count cap.

Aiming the previous shot near a slab spread damage unnecessarily. The new launch has an analytic floor-clearance check. We explored projectile/material combinations before selecting this reproducible demonstration; outputs are under `out/penetration-demo-20260906/`. Runs that stopped the projectile or caused widespread breakup were not selected. Some strong-wall trials exited with the existing demo's “did not demonstrate destruction” assertion.

## Correction evidence

At a fixed 60 Hz, steps 17, 32 and 33 each execute **one correction**. Their accepted end times are 0.3000, 0.5500 and 0.5667 seconds. No step executes more than one. The encounter spans multiple simulation steps, so the total is three corrections, not three iterations inside one step. Step 30 breaks one additional bond without splitting a connected component and reports no correction.

The engine first solves the contact interaction, evaluates its impulses with GPU stress, commits the fracture verdict and corrects the affected motion. GPU physics, stress, connectivity, cluster motion and color ownership are used. CPU trace readbacks are explicitly enabled for verification; video pixel export and annotation are offline observations.

## Recording and timing

Video: `out/penetration-demo-20260906/wall-penetration.mp4` (14.5 seconds). It contains 10 seconds of simulation: the first 1.5 simulation seconds play at quarter speed, then playback is 1x. Labels distinguish simulation time and playback speed. Same color means the same accepted rigid cluster; white is the projectile.

Measured complete physics/destruction step time in this instrumented recording:

| Minimum | Mean | p50 | p95 | p99 | Maximum |
|---:|---:|---:|---:|---:|---:|
| 0.521 ms | 4.788 ms | 4.567 ms | 6.563 ms | 8.106 ms | 9.117 ms |

All 600 measured simulation steps are below 16.67 ms. CPU observation, rendering and encoding are excluded from these simulation timings. This is not an isolated performance qualification or a whole-game frame-rate claim. Sleeping remains disabled in this fixture.

## Reproduce and verify

Build `native_destruction_demo` and `native_bombardment_test` in `out/destruction-sdk`, then run the following from the repository root, substituting fresh output/video paths because the recorder refuses to overwrite recordings:

```sh
/root/workspace/physx-2/out/destruction-sdk/reference/native_destruction_demo --grid 1 --waves 1 --workload single-impact --seconds 10 --launch-seconds 0 --stress-iterations 8192 --preserve-contact-pairs 1 --gpu-island-repair 1 --gpu-pre-solve-islands 1 --gpu-pre-solve-contacts 1 --gpu-pre-solve-support 1 --gpu-connectivity-owner 1 --color-by-cluster 1 --output /root/workspace/physx-2/out/penetration-demo-20260906/final --shot-path through-wall --projectile-mass 18000 --material-strength 24 --frame-strength 40 --record-state 1 --gpu-render 1 --gpu-camera penetration --gpu-video /root/workspace/physx-2/out/penetration-demo-20260906/penetration-raw.mp4 --audit-motion 1 --trace-motion 1
python3 tools/scripts/verify-native-penetration.py out/penetration-demo-20260906/final
python3 tools/scripts/annotate-native-cluster-video.py out/penetration-demo-20260906/final out/penetration-demo-20260906/penetration-raw.mp4 out/penetration-demo-20260906/wall-penetration.mp4 --group-observations out/penetration-demo-20260906/final/native.motion.csv --label-fps 60 --slow-impact 1.5
```

Machine-readable validation: `qualification/wall-penetration-20260906.json`. Input command and raw frame/state/motion observations are retained in the output directory.

Passed: native projectile launch regression, GPU visual consumer, native GPU consumer, native GPU resimulation (4/4), plus the recorded penetration verifier and the recorder's per-frame motion/COM audits. No test tolerances were weakened.
