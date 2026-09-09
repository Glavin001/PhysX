# GPU-owned exact settled-stress reuse — implementation receipt

**Status: superseded by the [component-local revision](../native-settled-local-20260909/README.md).** The paired short screen improves idle; peak ranges overlap. No qualified destruction-peak improvement.
This implements part of S2/O1 in the 63-responsibility campaign, not C1–C6 or the full plan.

## Mechanism and physical contract

A GPU component owns its input snapshot and validity certificate. It compares all six
physical load components bit-for-bit. Reuse requires the same accepted topology
generation, tolerance, iteration limit, warm-start policy, and a previously converged
**zero-update warm solve** verifying the actual stored FP32 bond forces. Convergence
before conversion from the higher-precision internal solution is insufficient.
Changed or uncertified components execute the existing solver. No iteration budget,
material law, contact threshold, sleeping rule, or physics command changes.

Certificates currently invalidate on any topology generation change, conservatively
including unrelated fractures. Component-local invalidation, dirty producer lists,
preparation fusion and GPU lifecycle ownership remain unfinished. This version adds
two graph nodes and persistent per-node storage; the complete-step screen includes
these costs. Material and crushing evaluation still run on every required pass.

## Validation and failures retained

- Three numerical suites pass: analytic, 3D and motion/null-space modes.
- New 64-node / 62-bond, two-supported-column fixture checks actual reuse masks,
  repeated byte-identical forces, one-ULP load invalidation, independent components,
  tighter tolerance, cold starts, topology changes and unconverged-result rejection.
- Extended 1,040-node / 1,039-bond fixture covers cooperative-to-block transitions,
  permuted authored identities, splitting into 2/4 components and exact stored-force reuse.
- Full analytic suite passes CUDA memcheck and initcheck with zero errors.
- Nine ordinary-API/correction/sleep/wake regressions pass.
- Material evolution/reference parity passes after rebuilding its stale executable.
  The old executable crashed with BOTH runtime arms in GPU island bitmap copying;
  the preserved baseline/candidate failure and backtrace are under the capture root.
- Historical frozen penetration passes its unchanged exact hash: 444 chunks,
  896 bonds, one projectile, 600 steps, 398 supported, 46 detached, 199 broken bonds,
  43 clusters. This historical fixture uses Direct GPU mode.
- The same 600-step fixture with Direct GPU OFF and sleeping ON passes motion,
  hole, convergence and correction invariants. Baseline/candidate topology hashes,
  fracture steps and correction steps match exactly. BOTH fail the historical
  Direct-GPU hash: ordinary mode retains 400 chunks in 41 clusters. The historical
  golden/assertions remain unchanged; this pre-existing mode difference is unresolved.

Raw logs, original failed captures, binary hashes and observations:
`out/native-settled-20260909/`. `standard-wall-comparison.json` records mode-matched
identity equivalence; `wall-frozen/quality.json` records the historical gate.

## Paired performance screen

`run-screen.py` runs baseline/candidate/candidate/baseline, each with a fresh idle
scene then bombardment, sequentially on an otherwise unused GPU. It never controls
services. Every run records actual mapped runtime/module paths and SHA-256 hashes.
It uses the existing report generator, unchanged benchmark and command tape.

Each run: **256 buildings, 113,664 chunks, 229,376 bonds, 600 steps / 10 simulated
seconds**, either zero projectiles (idle) or 768 projectiles (bombardment). Direct GPU
OFF, sleeping ON, dt=1/60, at most one correction and two stress evaluations.
Complete-step timing includes commands, physics, stress, topology, correction and
accepted game observation. Rendering/networking excluded. Initialization and first
steps are not discarded. Two runs per arm/regime are a screen, not five-run or
10-minute endurance qualification.
