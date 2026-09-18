# 🔬 Component work during actual bombardment

256 buildings, 113,664 chunks, 229,376 bonds, 256 projectiles; 3 simulated seconds, 180 steps, correction maximum 1. Sleeping: False.

This is an intrusive diagnostic replay of the recorded inputs. Its wall times are not performance results. Step selection uses the first untraced reference run; counts and cycles come from the separate diagnostic replay. CPU observation and output exist only in the excluded diagnostic runtime. NVIDIA collision and rigid-body kernels are unchanged.

All 180 solve totals reconcile with their complete component records. No large components are unmeasured. Compared counter differences: 0 in physical/convergence counters, 0 in reported iteration count. Counter agreement is not proof of identical trajectories or a replacement for physical quality gates.

## Step 103 — reference complete-step peak

Reference complete advance: 62.035 ms. Diagnostic stress components: 1,606; component updates: 94,420; operator node visits: 58,552,259; CSR visits: 202,764,507; live directed visits: 202,764,507.

256 components exceed 256 iterations: they account for 99.9594% of live operator visits and 93.35% of recorded component cycles. 0.00% of CSR visits encounter entries excluded from live bond arithmetic.

| Component iteration range | Components | Nodes | Updates | Live operator visits | Share of component cycles |
|---|---:|---:|---:|---:|---:|
| 0 | 337 | 1,827 | 0 | 6,928 | 0.66% |
| 1–25 | 1009 | 3,181 | 4,440 | 64,528 | 5.84% |
| 26–100 | 4 | 54 | 148 | 10,824 | 0.14% |
| 101–256 | 0 | 0 | 0 | 0 | 0.00% |
| >256 | 256 | 83,559 | 89,832 | 202,682,227 | 93.35% |

| Diagnostic phase | Share of summed CTA phase cycles |
|---|---:|
| Residual projection + component preparation | 17.30% |
| Residual operator + convergence verification | 20.04% |
| Convergence decision | 0.80% |
| Preconditioner and associated reductions | 28.36% |
| Direction update | 3.87% |
| Direction operator | 20.54% |
| Solution update | 9.08% |
| Dispatch/remaining | 0.01% |

Cycles include probe overhead and overlap across GPU multiprocessors. These percentages are work-location evidence, not additive milliseconds, SM utilization or a hardware roofline. Component records describe the stress solve before this step’s fracture; end-of-step scene topology counters may differ.

## Step 87 — maximum measured operator work

Reference complete advance: 20.013 ms. Diagnostic stress components: 732; component updates: 80,249; operator node visits: 56,374,908; CSR visits: 208,684,874; live directed visits: 208,684,874.

256 components exceed 256 iterations: they account for 99.9952% of live operator visits and 98.44% of recorded component cycles. 0.00% of CSR visits encounter entries excluded from live bond arithmetic.

| Component iteration range | Components | Nodes | Updates | Live operator visits | Share of component cycles |
|---|---:|---:|---:|---:|---:|
| 0 | 220 | 692 | 0 | 1,888 | 0.41% |
| 1–25 | 256 | 768 | 768 | 8,192 | 1.15% |
| 26–100 | 0 | 0 | 0 | 0 | 0.00% |
| 101–256 | 0 | 0 | 0 | 0 | 0.00% |
| >256 | 256 | 90,478 | 79,481 | 208,674,794 | 98.44% |

| Diagnostic phase | Share of summed CTA phase cycles |
|---|---:|
| Residual projection + component preparation | 16.13% |
| Residual operator + convergence verification | 20.38% |
| Convergence decision | 0.80% |
| Preconditioner and associated reductions | 28.08% |
| Direction update | 4.13% |
| Direction operator | 21.28% |
| Solution update | 9.18% |
| Dispatch/remaining | 0.01% |

Cycles include probe overhead and overlap across GPU multiprocessors. These percentages are work-location evidence, not additive milliseconds, SM utilization or a hardware roofline. Component records describe the stress solve before this step’s fracture; end-of-step scene topology counters may differ.

## Decision supported by this capture

The main repeated work is solving retained structural components, not processing tiny rubble components. The next behavior-preserving stress experiment should reduce iterations for these retained components through stronger preconditioning, or reduce their repeated sparse-operator work. Avoid prioritizing tiny-component scheduling merely because there are many fragments.

Stable compaction of broken-bond adjacency is a separate candidate: it can eliminate excluded CSR visits while retaining live arithmetic order. The fraction of excluded entries is not the fraction of total time that can be saved; measure the resulting complete-step change.

The original solver’s bounded cross-frame policy remains a separate behavior comparison. It must not be presented as a same-fidelity implementation speedup against mandatory within-step convergence. Correction and ownership remain major independent peak costs; this capture does not measure their work or eliminate the need to optimize our integration.

## Reproduce

Build `PhysXDestructionGpuWorkDiagnostic`, then run `run-destruction-component-capture.py REFERENCE_REPORT_JSON_GZ NEW_CAPTURE_DIRECTORY`. Generate this report with `report-destruction-component-work.py CAPTURE_DIRECTORY REFERENCE_REPORT_JSON_GZ --output REPORT_DIRECTORY`.
