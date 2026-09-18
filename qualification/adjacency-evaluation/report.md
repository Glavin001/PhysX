# Stable GPU adjacency experiment — reverted

Correctness checks passed and dead-reference traversal was removed. A complete-step peak improvement was not established. The candidate is archived as a patch; production source and runtime were returned to the baseline implementation. No compatibility switch or alternate production path remains.

## Workload and timing boundary

256 buildings; 113,664 chunks; 229,376 bonds; 256 simultaneous aerial projectiles; fixed 1/60 s timestep; maximum one correction per step; sleeping disabled. Each short run measures all 180 complete advances across 3 simulated seconds, including first steps and allocation spikes. Commands through mandatory completion are included; initialization, rendering, encoding and report generation are excluded.

Initial order: baseline two repeats, candidate two repeats, with a separate phase capture for each. Follow-up order: candidate five repeats, rebuilt baseline five repeats. Runs were GPU-isolated, with warm-up per campaign. This reversal checks gross batch-order drift but is not individual-run randomized interleaving. These short experiments are not five 60-second acceptance runs or endurance qualification.

## Every untraced run

| Batch | Repeat | Mean complete ms | Peak complete ms | Peak step | Steps >8 ms | Steps >16.67 ms |
|---|---|---|---|---|---|---|
| before-impacts-256 | 1 | 18.571 | 61.630 | 103 | 99 | 99 |
| before-impacts-256 | 2 | 18.585 | 62.456 | 103 | 99 | 99 |
| after-impacts-256 | 1 | 18.456 | 62.227 | 103 | 99 | 99 |
| after-impacts-256 | 2 | 18.460 | 63.167 | 103 | 99 | 99 |
| candidate-repeat | 1 | 18.464 | 62.608 | 103 | 99 | 99 |
| candidate-repeat | 2 | 18.494 | 61.600 | 103 | 99 | 99 |
| candidate-repeat | 3 | 18.492 | 64.557 | 103 | 99 | 99 |
| candidate-repeat | 4 | 18.432 | 62.528 | 103 | 99 | 99 |
| candidate-repeat | 5 | 18.533 | 61.435 | 103 | 99 | 99 |
| baseline-repeat | 1 | 18.596 | 63.372 | 103 | 99 | 99 |
| baseline-repeat | 2 | 18.554 | 62.515 | 103 | 99 | 99 |
| baseline-repeat | 3 | 18.764 | 61.904 | 103 | 99 | 99 |
| baseline-repeat | 4 | 18.539 | 61.667 | 103 | 99 | 99 |
| baseline-repeat | 5 | 18.613 | 62.821 | 103 | 99 | 99 |

## Separate instrumented phase capture

The following CUDA-event times describe their own phase captures. They overlap host scopes and are not a decomposition of the untraced maximum.

| Phase | Before mean ms | Candidate mean ms | Before at step 103 ms | Candidate at step 103 ms |
|---|---|---|---|---|
| GPU: prepare and solve structural stress | 11.341 | 11.127 | 19.781 | 20.811 |
| GPU: commit health and update stress topology | 0.145 | 0.145 | 0.039 | 0.039 |
| GPU: convert solved contacts into chunk loads | 0.093 | 0.093 | 0.135 | 0.135 |
| GPU: evaluate damage and material verdicts | 0.070 | 0.070 | 0.068 | 0.065 |
| GPU: evaluate connectivity and fracture candidates | 0.240 | 0.239 | 0.484 | 0.488 |

## Work removed, and what that tells us

At step 103, the earlier isolated work probe recorded 240,282,085 CSR visits, including 37,514,488 dead visits. The candidate recorded 202,764,507 CSR visits and zero dead visits. Both describe 1,606 stress components before fracture. These are stress components, not independently moving rigid bodies.

The probes recorded 94,421 versus 94,420 component updates. Iteration counts can vary by one across diagnostic replays; eliminating dead adjacency does not eliminate the live arithmetic. These intrusive work captures are not performance measurements.

The candidate reduces average observed stress time slightly, but does not establish a complete-step peak improvement. The repeated peak ranges overlap; the candidate also retains the larger observed worst step. This does not prove a statistically significant regression or a hardware compute/bandwidth limit. It does show that the fraction of dead adjacency visits was not a defensible estimate of available time savings.

Next priority: reduce repeated live work in the retained building components through stronger preconditioning, with setup cost and unchanged physical acceptance included. Ownership and correction remain separate peak opportunities. Do not spend further iterations polishing the rejected compaction in isolation.

## Correctness and preservation

- Native analytical and 3D oracle suites passed; the stable-filter test covered empty/high-degree rows, tombstones, all-bond removal, restoration and repeated captured-graph execution.
- New compaction kernel passed CUDA memcheck, initcheck, synccheck and racecheck. These checks cover the tested kernels, not a claim that the whole engine is race-free.
- Frozen penetration: one building, 444 chunks, 896 bonds, one projectile, 10 simulated seconds. Passed both-wall clearance, exact topology signature, 398 retained supported chunks, 46 detached chunks, 199 broken bonds, and correction maximum one.
- Across the 14 untraced runs, the archived comparison records 9 differences in the listed physical/convergence/iteration counters against the first baseline. All observed differences were single-update stress iteration counts, occurring in both versions; body/contact/fracture/convergence counters matched. Counter agreement alone is not trajectory equivalence; the independent frozen audit remains necessary.
- Production mathematics, tolerances and physical settings were unchanged by the candidate. Compaction preserved the original order of live references, keeping immutable authored CSR for reconstruction.
- Rebuild work ran inside a generation-guarded device topology transaction, without host counts. It used additional persistent offsets/counts/reference storage; no runtime allocation was required for this fixed asset.

## Reproduce

Run python3 qualification/adjacency-evaluation/generate_report.py. The generator checks raw complete-step samples against each timing report, checks workload identity and physical counters, and regenerates Markdown, HTML and JSON. candidate.patch preserves the tested change against source revision 2690b048; it is not applied to production. validation/ retains numerical, sanitizer, penetration and raw timing evidence.
