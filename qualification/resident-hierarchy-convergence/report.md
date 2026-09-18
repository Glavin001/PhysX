# Resident stress convergence investigation — qualification failed

**No new native performance improvement or 8 ms result is established.**
The retained production benchmark remains the 256-building bombardment: 113,664 chunks,
229,376 bonds, 256 simultaneous projectiles, timestep 1/60 s, correction limit one.
None of the numerical tests below runs rigid-body physics, destruction, contacts,
projectiles, rendering, or that benchmark. Their iteration counts are not timings.

## What changed

- The native topology transaction now constructs the resident hierarchy from borrowed
  operator/connectivity buffers and exposes it to the resident solver. This WIP builds,
  but its squared-cycle CGLS integration fails the existing mixed-component test:
  **2,064 nodes, 2,061 bonds**, component sizes 12 / 1,024 / 1,028, iteration limit 128,
  tolerance 1e-5. The original assertions and limits remain unchanged.
- An independent scalar experiment reproduces weak convergence without native GPU
  scheduling or float arithmetic. Simply adding smoothed interpolation did not fix
  that squared-cycle formulation. This is evidence against treating interpolation
  smoothing alone as the next fix; it is not a proof that every native bug is excluded.
- Projected CG is promising in the scalar experiment, but its correctness requires
  an exact component null space. The scalar experiment only projects translation;
  it does not qualify three-dimensional, inconsistent, or frustrated components.
- A right-preconditioned flexible GMRES candidate uses the actual GPU hierarchy,
  one resident kernel, a 32-vector restart, two-pass orthogonalization, and explicit
  residual verification before acceptance. It does not project the supplied loads.
  Its first residual direction is inexpensive; subsequent directions use the hierarchy.
  Both block-local and cooperative schedules were exercised.
- **That candidate is rejected.** Simple axial cases pass; coupled force/moment cases
  miss the independent force check, and components with net loads fail convergence.
  It is archived here and absent from the native SDK/runtime build. No slower alternate
  backend was added to production.

## Complete GPU observations

All candidate solves use the same 128-iteration cap, relative gradient tolerance 1e-5,
and independent bond-response limit 2e-4. The test continues after failures to retain
all observations, then exits nonzero if any check fails. There is no assertion waiver.

“Net loads” means that exact rigid-motion components were added to the load vector.
The closed-loop case has a deliberately inconsistent bond offset; only exact translation
was added there. These are numerical stress nodes, not separately moving rigid bodies.

| Nodes / bonds | Supported | Load | Schedule | Iterations | Gradient² / limit | Bond error / 2e-4 | Result |
|---|---|---|---|---:|---:|---:|---|
| 12 / 11 | No | Axial | Block | 1 | 0 | 0 | ✅ |
| 12 / 11 | No | Axial | Cooperative | 1 | 0 | 0 | ✅ |
| 1,024 / 1,023 | No | Axial | Block | 1 | 0 | 0 | ✅ |
| 1,024 / 1,023 | No | Axial | Cooperative | 1 | 0 | 0 | ✅ |
| 1,028 / 1,027 | No | Axial | Block | 1 | 0 | 0 | ✅ |
| 1,028 / 1,027 | No | Axial | Cooperative | 1 | 0 | 0 | ✅ |
| 24 / 23 | Yes | Coupled forces/moments | Block | 17 | 0.657115 | 1.55365 | ❌ |
| 24 / 23 | Yes | Coupled forces/moments | Cooperative | 17 | 0.657115 | 1.55365 | ❌ |
| 24 / 23 | No | Coupled forces/moments | Block | 17 | 0.424534 | 1.89828 | ❌ |
| 24 / 23 | No | Coupled forces/moments | Cooperative | 17 | 0.424534 | 1.89828 | ❌ |
| 24 / 23 | No | Coupled + net loads | Block | 128 | 3.63988e+08 | 9807.07 | ❌ |
| 24 / 23 | No | Coupled + net loads | Cooperative | 128 | 3.63988e+08 | 9807.07 | ❌ |
| 24 / 24 | No | Net loads + frustrated loop | Block | 128 | 1432.2 | 271827 | ❌ |
| 24 / 24 | No | Net loads + frustrated loop | Cooperative | 128 | 1432.2 | 271827 | ❌ |
| 128 / 127 | No | Coupled + net loads | Block | 128 | 4.14819e+08 | 8393.58 | ❌ |
| 128 / 127 | No | Coupled + net loads | Cooperative | 128 | 4.14819e+08 | 8393.58 | ❌ |

## Decision and next required work

1. Keep the original native quality gate failed until the actual integrated solver passes.
2. Build/qualify GPU component null modes from live bond equations. Authored positions
   alone are insufficient: inconsistent offset loops can constrain rotational motion.
   Do not silently discard those moments or assume every free component has six null modes.
3. Reuse the native connectivity union's successful edge witnesses to obtain a spanning
   forest; derive component motion modes and validate them against every live bond.
   This avoids a second CPU partition or matrix assembly. The witness/potential/projector
   work is **not implemented yet**.
4. Qualify projected CG against original bond-space answers and analytic forces,
   including incompatible loads, support removal, split components and retained moments.
5. Only then adopt the winning formulation, remove superseded native WIP, run the
   frozen wall regression, and return to the complete 256-building benchmark.

## Reproduce

Native failure (current native WIP; not the archived candidate):

```sh
cmake --build /root/workspace/physx-2/out/destruction-sdk --target gpu_resident_stress_test -j 4
/root/workspace/physx-2/out/destruction-sdk/reference/gpu_resident_stress_test mixed
```

Archived rejected candidate (expected nonzero result):

```sh
cmake -S /root/workspace/physx-2/qualification/resident-hierarchy-convergence -B /root/workspace/physx-2/out/rejected-resident-krylov -DCMAKE_CUDA_COMPILER=/usr/local/cuda/bin/nvcc -DCMAKE_BUILD_TYPE=Release
cmake --build /root/workspace/physx-2/out/rejected-resident-krylov -j 4
/root/workspace/physx-2/out/rejected-resident-krylov/gpu_resident_krylov_test
```

The standalone scalar scripts in `scalar-reference/` require NumPy/SciPy and perform
CPU-only mathematical diagnostics. They are never imported by the SDK.
`generate_report.py` rebuilds this report and `results.json` from all retained logs.
The archived candidate did not proceed to performance or sanitizer qualification after
failing physical checks. The native frozen-wall and bombardment benchmarks were not rerun
on these unqualified changes.
