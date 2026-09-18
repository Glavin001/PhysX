# Skip unused small-component coarse preparation

The native component solver retains its exact fine Cholesky factors and motion
projection. Components at or below its existing 1,024-node threshold no longer
select coarse aggregates or assemble terminal/coarse systems they never use.
Large components retain multilevel preparation and solving. This is numerical
work selection on the GPU, not a new runtime backend or a physics budget.

Fine-only components retain their physical labels, bonds and loads. A distinct
terminal marker retires only their coarse work; accidentally dispatching that
marker through the multilevel solver traps instead of publishing a zero result.
CSR validation previously performed during seed selection is retained in the
remaining preparation pass. No convergence tolerance or iteration cap changed.

## Verification

- A 1,034-node / 1,032-bond fixture initially has a 9-node component and a
  1,025-node component. Fine factors match the original producer bit-for-bit.
  Splitting the larger component makes every component fine-only and every
  subsequent packed level empty. Rejoining restores the required coarse work.
- Invalid bond references, endpoint incidence and CSR bounds are rejected before
  unsafe fine-factor access; corrected inputs recover. These checks are registered
  in CTest, with memcheck and synccheck variants. All three tests pass.
- Native analytic cases pass, including mixed 12/1,024/1,028-node components,
  a 13,828-node / 13,059-bond uneven partition, and topology transitions.
- The independent 3D suite passes: 18 nodes / 33 bonds and 1,058 nodes / 2,553
  bonds, supported/free cases, cold/warm/unloaded/reversed inputs. The original
  force tolerance and requested convergence criteria remain unchanged.
- The ordinary hierarchy suite passes through 100,000 nodes / 199,997 bonds.
- Native analytic memcheck reports zero errors and zero leaks.
- The frozen 10-second wall audit passes: 444 chunks / 896 bonds, 398 supported
  chunks, 46 detached, 199 broken bonds, exact original topology signature,
  and correction limit one. See wall-quality.json and wall-capture.json.

## Peak comparison

[Final generated timing report](../fine-only-validated-impacts-256/report.html).
Two untraced three-second trials each retain all 180 complete simulation steps,
with separate warm-up, host-scope and CUPTI runs. Scene: 256 buildings, 113,664
chunks, 229,376 bonds, 256 simultaneous aerial projectiles, dt=1/60, correction
limit one. No rendering or detailed observation in timing runs.

Complete-step peaks decrease from 69.971 / 67.674 ms in the preceding corrected
solver campaign to 64.738 / 64.347 ms. Means decrease from 21.783 / 21.777 ms to
20.057 / 20.292 ms. The maximum across these short trials falls about 7.5%.
This is observed short-campaign evidence, not the five-by-60-second gate.
All 198 deadline misses remain; the 8 ms and 60 Hz objectives are not achieved.

The listed physical counters in validation.json match every step of the first
baseline and candidate repeats. Numerical iterations differ at step 112 by one
(580 to 579); do not claim identical numerical execution or bit-identical GPU
trajectories. The exact wall topology and independent physical checks are
separate evidence from these counters.

The earlier fine-only-impacts-256 report is a provisional capture before the
CSR-validation dependency was identified and preserved. It is not the selected
runtime's qualification. All final evidence here uses the guarded version.

## Remaining work

Empty coarse graph nodes and capacity allocations still exist. This change
removes their populated numerical work; it does not finish graph bypass or
storage specialization. Most components still execute expensive iterative
stress solves. Fragment ownership/lifecycle and correction retain substantial
costs. GPU residence, peak scaling, full fidelity qualification, the previously
recorded native racecheck failure and endurance requirements remain open.
