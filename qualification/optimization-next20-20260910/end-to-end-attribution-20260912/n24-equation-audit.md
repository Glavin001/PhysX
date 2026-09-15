# N24 independent equation audit

**The reference audit is complete for one city25 initial-impact input; N24 remains unqualified.** Four restored full ticks (two per arm) capture eight native problems. Each diagnostic arm passes the original physical comparison against its own frozen, uninstrumented runtime. This does not mean A and B pass against each other.

The 80-digit independent reference covers all25 anchored components in both first and correction stress passes:50 systems with identical captured A/B operators, warm forces and loads. Decimal residual refinement falls below1e-35, and independent bond-form versus assembled residual discrepancies remain below1e-50. Captured warm forces are zero: unexplained carried self-stress is not the cause in this input. The separate small free-component SVD audit covers50 free components per correction pass; A/B are identical there, with maximum absolute normalized force error4.56336e-7. No large free-component generalization is claimed.

| Stress pass | Arm | Worst component physical force relative L2 error | Worst existing per-coordinate scaled error | Coordinates failing existing2e-4 gate |
|---|---|---:|---:|---:|
| First | A | 1.29692e-6 | 0.587520 | 3174 |
| First | B | 1.46286e-6 | 0.299572 | 1495 |
| Correction | A | 1.27459e-6 | 0.658605 | 3407 |
| Correction | B | 6.73886e-7 | 0.531559 | 2006 |

Both approximate solutions fail the old coordinate comparison against the independent reference. Thus A/B disagreement alone does not establish that B is less accurate. Global norm errors also cannot justify accepting weak-bond/material errors. The old gate and exact health comparison remain failures; no threshold, golden or material policy changes. Native residual checks and an independently recomputed gradient are retained separately, including slightly above-one gradient/threshold ratios that need interpretation before a new precision contract.

Physical output conversion is checked, not assumed: one FP32 angular scale221.1840057373047 and linear scale442.3680114746094, using the frozen export multiplication order, exactly reproduce all134400 published force scalars in each arm. These are verified output-unit multipliers, not an independently decoded material model.

[Structured results](n24-equation-results.json) link raw `out/n24-native-equation-worlds-20260912/strong-suite/` and `equation-audit-with-free.json`. These are intrusive diagnostics and CPU reference solves; none are application speed measurements. Existing whole-step scenario means, peaks, stages and misses remain in [the work census](removal-work-census.md).

## Empty hierarchy follow-up

The test-only live-range read fix d350ecd447c9c45fec3ed03e49284333c6f0cafc removed oracle reads of unused table capacity but left405504 initialization findings. The remaining `CycleWork<true>::childCount` read is real runtime work: local traversal can continue after a component has no child operator. Empty demand publishes counts without sparse range entries.

Isolated correction3e1e39c262149d35ddb66ab05c3ea1b313f41c20 stops at the last populated level, checking global child count before sparse component ranges. Both numerical arms have the same correction. No buffers are blanket-initialized and no CPU wait or tolerance change is added. Main runtime and installed SDK remain untouched.

A new98-node regression combines a free33-node star with a separate65-node chain. The old control reproduced the uninitialized reads and was stopped after more than ten minutes; its interruption is preserved, not counted as a completed expected-failure test. The corrected regression passes all scalar basis columns, independent dense-cycle comparison, symmetry, linearity, repeatability and initcheck with zero errors. The full cycle suite and full initcheck also pass, including100000 nodes/199997 bonds through six topology transitions, with zero errors. Rebuilt native checks and12 integrated memory ticks pass. The120-tick A/B/A screen rejects the candidate by large runtime regressions; [all results and profiling diagnosis](n24-equation-screen.md).

## Reproduction

The original capture coordinator is terminal: capture and physical/reference stages passed, its separate old hierarchy auxiliary failed. Do not rerun it against existing output directories. The ordinary collector390717 resumed after47/52 cases when this experiment block became terminal; restoration watcher338813 remains live. Re-establish a completed pause boundary before any new GPU experiment.

```bash
PYTHONPATH=out/elastic-precision-reference-20260910/python OPENBLAS_NUM_THREADS=1 \
  python3 tools/scripts/test-native-stress-solution-audit.py
python3 tools/diagnostics/destruction-snapshot/test-compare-observations.py
# Use a fresh output path and frozen captured prefixes:
PYTHONPATH=out/elastic-precision-reference-20260910/python OPENBLAS_NUM_THREADS=1 \
  python3 tools/scripts/reference-native-stress-solution.py \
  out/n24-native-equation-worlds-20260912/A-problem.world-0.solve-0 \
  out/n24-native-equation-worlds-20260912/B-problem.world-0.solve-0 \
  64 /tmp/NEW-native-reference-64
```

Four independent-audit unit tests and ten observation-checker tests pass. Optional `compare-observations.py --all-errors` collects compatible-layout failures rather than stopping at the first; it still exits failed on every original failed gate. This enables diagnosis without concealing simultaneous force, health or motion failures.

Exact build/run recipes and manifests: `out/n24-live-cycle-tail-20260912/{build-runtimes.py,build-oracles.py,build-native-oracles.py,run-fixed-oracle-screen.py,run-native-screen.py}`. Each requires a fresh destination and exclusive GPU for execution. No application speedup or N24 promotion is claimed.
