# Native shared-factor GPU feasibility — 2026-09-12

Captured-equation diagnostic only. Both stress passes from one 25-building, 11,100-chunk snapshot pass all 50 anchored strong-reference systems, first and final outputs (100 checks). Maximum normalized scaled coordinate error is 4.321e-11; all captured squared-gradient thresholds pass, including FP32 force rounding. No full physical/material, native tick or speedup qualification.

| Captured pass | Equations / loads | Context + handle setup ms | Analysis ms | First factor ms | First batch solve ms | Re-factor mean ms (5) | Reused batch solve mean/max ms (20) |
|---|---:|---:|---:|---:|---:|---:|---:|
| Initial impact | 2280 / 25 | 324.187 | 49.514 | 29.487 | 192.160 | 1.026 | 0.421 / 0.445 |
| Correction | 2136 / 25 | 326.275 | 46.973 | 28.273 | 5.181 | 0.698 | 0.343 / 0.368 |

Each case ran in a separate fresh process. First-use costs are preserved; the cause of the unusually expensive first impact solve has not been attributed. Phase wall times include stream synchronization and solver status retrieval. The first pipeline totals are 595.602/406.924 ms, excluding input file loading and output download. These are not full simulation steps. Twenty reused solves share one factor and are not independent process repetitions.

The original deterministic multi-RHS attempt returned `CUDSS_STATUS_NOT_SUPPORTED`; the diagnostic repeat located it at `cudssExecute`. NVIDIA documents deterministic mode as single-RHS only. The successful multi-RHS probe explicitly disables that mode. First/final solution arrays are not bit-identical (maximum absolute differences 3.32e-9/1.02e-9), but each passes the independent normalized reference and residual checks. This does not waive simulation repeatability, converted forces, bond health or fracture gates. [Vendor restriction](https://docs.nvidia.com/cuda/cudss/types.html#c.CUDSS_CONFIG_DETERMINISTIC_MODE).

cuDSS 0.8.0.10 remains an isolated local dependency; loaded library hashes, raw samples, input hashes and both failed attempts are preserved. Native runtime, installed SDK and selected implementation are unchanged. No Nsight capture was made for this library probe. The counter collector stayed paused, and GPU process checks before/after were empty.

Next: measure grouping/assembly plus synchronous analysis and numeric factor lifetime inside the current-tick engine path; compare against the selected solver, recover material forces, and run unchanged light/full/warm gates. Establish an exact coefficient-invalidity contract and a safe method for matrix shapes discovered on GPU. Reuse of a topology ordering does not imply reuse of numeric factors. No setup may be hidden outside a cold restored tick. A warmed execution cache needs a separate continuous workload.

Tile can implement selected batched operations; it neither supplies sparse factorization nor determines coefficient validity. See [Tile documentation assessment](n27-tile-ir-followup.md).

Commands run:
```bash
python3 out/native-shared-factor-gpu-20260912/build.py
python3 out/native-shared-factor-gpu-20260912/run.py
PYTHONPATH=out/elastic-precision-reference-20260910/python OPENBLAS_NUM_THREADS=1 \
  python3 out/native-shared-factor-gpu-20260912/check-quality.py
```

These scripts require fresh output paths; preserve existing attempts before a changed-source rerun. All samples and checks: [structured report](n27-shared-factor-gpu.json). Last seven-scenario application measurements remain [N27 confirmation](n27-confirmation.md); no new application timings exist for factor sharing.

Convergence-accounting correction: the initial node-residual comparison used the wrong metric for the captured threshold. The corrected squared-gradient check passes all100 solutions, including rounded forces (worst threshold ratio0.008280). This changes no tolerance; original diagnostics are preserved. See [native integration contract](n28-native-factor-integration.md).
