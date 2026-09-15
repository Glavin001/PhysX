# Shared native full factor: host feasibility results

**All50 anchored solutions agree with the existing80-digit reference to worst normalized scaled coordinate error1.42e-10 or better. No GPU or application result.** The two exact matrix groups serve25 separate loads each; first and correction matrices differ.

| Stress pass | Ordering | Matrix rows / nonzeros | L+U nonzeros | Factor storage MB | Host factor mean ms | Host25-RHS solve mean ms | Worst normalized scaled force error |
|---|---|---:|---:|---:|---:|---:|---:|
| 0 | COLAMD | 2280 / 15032 | 584912 | 7.055 | 59.944 | 11.848 | 4e-11 |
| 0 | MMD_AT_PLUS_A | 2280 / 15032 | 389661 | 4.712 | 144.828 | 14.186 | 5.22e-11 |
| 1 | COLAMD | 2136 / 12888 | 308976 | 3.742 | 26.388 | 7.195 | 1.4e-10 |
| 1 | MMD_AT_PLUS_A | 2136 / 12888 | 262083 | 3.179 | 59.279 | 8.230 | 1.41e-10 |

Five factor and20 batch-solve samples per row are preserved. **These CPU timings overlapped the isolated N27 CPU build** after the counter capture paused; they are not isolated CPU benchmarks, GPU forecasts or application gains. The assessment finished before N27 native GPU qualification started. Use fill/storage and force accuracy to choose the next native GPU experiment.

The factor representation grows substantially beyond the original sparse matrix (roughly20–39x combined L+U entry count). Sharing across25 equal operators keeps the retained factor small; storing a separate copy for every building would multiply it. This is SuperLU storage, not a bound on GPU workspace or a Cholesky factor count. The ordering with fewer entries was slower in this host cohort, so fill alone cannot choose the fastest implementation.

Source hashes are checked before assembly, coefficient byte equality is checked after hash grouping, and bond IDs match each saved independent reference. Both orderings pass the normalized2e-4 diagnostic comparison by a wide margin. The result does **not** establish current force/material equivalence to the old approximate runtime, native GPU convergence, graph correctness, or full-tick performance. Physical conversion and all unchanged integrated quality checks remain required.

Next substantial hypothesis: shared sparse direct factor/solve on GPU, with current matrix-value validity, different right-hand sides and unchanged force recovery/material work. Charge grouping/packing, symbolic setup, factorization, transfers, graph coordination and refinement. Investigate a device-controlled path before adding synchronous per-component CPU analysis. [Available and documented CUDA math options](n27-cuda-math-options.md).

[Every sample and numerical result](n27-shared-factor-assessment.json). [Identity audit and exact reproduction command](n27-shared-operator-exposure.md). Existing application means/peaks/stages remain in [N26 confirmation](n26-confirmation.md).
