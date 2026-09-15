# Shared full-operator factorization: new measured exposure

**Offline coefficient audit only; no solver implementation or application gain.** One retained native city25 first-impact snapshot and its correction, using the equations already checked by the independent80-digit reference.

| Pass | Anchored components | Dynamic nodes/component | Exact operator coefficient groups | Captured load/warm/threshold groups |
|---|---:|---:|---:|---:|
| First impact |25|380|1|25|
| Correction |25|356|1|12|

The two passes have different matrices. Within each pass, all25 anchored components have byte-identical normalized inertia, canonical live endpoints, bond offsets, health and scale. This is a conservative sufficient identity for the assembled matrix under the current canonical local order. It does not prove factors can be reused across ticks. Correction also has50 free three-node components with one coefficient group; free systems require nullspace treatment and do not drive the current measured iterative cost.

Loads differ: first-impact has25 captured problem identities; correction12 with a largest shared group14. Do not copy a single answer to every building. Captured equality is mathematical-input evidence, not a complete execution-history certificate; roundoff, rounding of published forces, solver policies and free-mode projection still require qualification.

This strengthens the existing shared-factor hypothesis from individual6x6 inverse blocks to **one full sparse factorization per exact anchored operator group, then multiple right-hand sides**. It could remove hundreds of iterative applications. Existing per-node inverse caching does not perform this full factorization. Recovery of bond forces and all material evaluation remain necessary.

NVIDIA cuDSS supports reuse of analysis with changed values followed by numerical refactorization; changing values does not authorize reuse of old numeric factors. [Execution phases](https://docs.nvidia.com/cuda/cudss/functions.html). It supports uniform-pattern batches with potentially different values, as well as multiple right-hand sides; identical matrices can instead share one factor. [Batch configuration](https://docs.nvidia.com/cuda/cudss/types.html).

Integration matters: cuDSS analysis is synchronous and includes CPU reordering. Default non-hybrid factorization/solve are asynchronous and can be graph-captured with a compatible memory handler; default allocations need replacement for graph capture. Deterministic mode is available but must be measured. [Execution, graph and reproducibility contract](https://docs.nvidia.com/cuda/cudss/general.html). These facts prevent claiming a drop-in replacement for the current device-controlled component path. No cuDSS header/library was found in the inspected /usr/local, /opt and /usr/include paths; no package installed or runtime probe run.

Next bounded assessment: reuse the existing independently assembled matrix for one representative per group; measure factor fill/storage, conditioning, refinement and multiple-RHS cost. Compare distinct cold factorization and reused-factor regimes. Then a native GPU pilot must charge canonical grouping, matrix assembly, ordering, factorization/refactorization, transfers, graph coordination and recovery to complete steps. Exact coefficient equality must be checked after any hash match. No stale factors after health/topology/boundary changes.

Estimated potential0–30ms in heavily active city steps, low confidence and not additive with other estimates; actual GPU direct-solve cost is unknown. Support: much less retained solver work with unchanged recovered force/material quality and lower full-step timings including setup. Refute: fill/memory, ordering/synchronization, grouping, numerical refinement or changed topology erases savings. This targets a different algorithm from the rejected expensive multilevel cycles.

[All groups, component hashes, source hashes and audit scope](n27-shared-operator-exposure.json). Script retained at `out/sparse-factor-exposure-20260912/audit-identities.py`. No heavy matrix factorization ran concurrently with the collector.

Completed reusable host assessment ([results and limitations](n27-shared-factor-assessment.md); run outside GPU timing/capture):

```bash
PYTHONPATH=out/elastic-precision-reference-20260910/python OPENBLAS_NUM_THREADS=1 \
  python3 tools/scripts/assess-shared-native-factors.py \
  out/sparse-factor-exposure-20260912/assessment \
  --identities out/sparse-factor-exposure-20260912/identities.json \
  --capture-dir out/n24-native-equation-worlds-20260912 \
  --reference-dir out/n24-native-equation-worlds-20260912/strong-suite
```

The tool verifies source hashes and exact coefficient bytes after grouping, evaluates two orderings, records five factor and20 batch-solve host samples, and compares all50 anchored recovered force solutions to the saved80-digit references. CPU timings cannot qualify an application gain.

[Installed cuBLAS emulation APIs and documented device-math options](n27-cuda-math-options.md) are candidate implementation tools, unqualified at runtime.
