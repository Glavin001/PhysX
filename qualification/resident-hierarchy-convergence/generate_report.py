#!/usr/bin/env python3
"""Generate the numerical failure report from retained, unfiltered observations."""
import ast
import json
from pathlib import Path

root = Path(__file__).resolve().parent
rows = []
for line in (root / 'logs/right-fgmres-rejected.log').read_text().splitlines():
    if not line.startswith('resident right-FGMRES candidate '):
        continue
    fields = dict(item.split('=', 1) for item in line.split()[3:])
    row = {k: float(v) if k in {'gradient2', 'threshold2', 'bond_error'} else int(v) for k, v in fields.items()}
    row['physical_pass'] = row['bond_error'] < 2e-4
    row['convergence_pass'] = bool(row['converged'] and not row['error'] and row['iterations'] <= 128 and row['gradient2'] <= row['threshold2'])
    row['qualified'] = row['physical_pass'] and row['convergence_pass']
    rows.append(row)
if len(rows) != 16:
    raise SystemExit(f'Expected every one of 16 candidate observations; got {len(rows)}')
scalar = {}
for name in ['scalar-comparison', 'projected-cg-comparison', 'right-gmres-comparison']:
    scalar[name] = [ast.literal_eval(line) for line in (root / 'logs' / f'{name}.log').read_text().splitlines()]
    if len(scalar[name]) != 8:
        raise SystemExit(f'Missing scalar observations: {name}')
(root / 'results.json').write_text(json.dumps({'native_integration_qualified': False, 'candidate_qualified': all(r['qualified'] for r in rows), 'gpu_observations': rows, 'scalar_diagnostics': scalar}, indent=2) + '\n')
text = '''# Resident stress convergence investigation — qualification failed

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
'''
for r in rows:
    load = 'Axial' if r['axial'] else ('Net loads + frustrated loop' if r['closed'] else ('Coupled + net loads' if r['incompatible'] else 'Coupled forces/moments'))
    text += f"| {r['nodes']:,} / {r['bonds']:,} | {'Yes' if r['anchored'] else 'No'} | {load} | {'Block' if r['local'] else 'Cooperative'} | {r['iterations']} | {r['gradient2'] / r['threshold2']:.6g} | {r['bond_error'] / 2e-4:.6g} | {'✅' if r['qualified'] else '❌'} |\n"
text += '''
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
'''
(root / 'report.md').write_text(text)
print(root / 'report.md')
