# Four-stage resident polynomial — rejected

The candidate reduced stress iteration counts but increased actual GPU stress and whole-step cost in the short bombardment comparison. All candidate production/test source changes were reverted. The production solver retains the qualified two-stage polynomial and device-conditional recursive hierarchy from commit `1f06175a`.

## Experiment

Four fixed Chebyshev-Jacobi Richardson stages on the same spectral interval [0.1, 2.01], evaluated as two factored quadratic updates. The implementation reused the existing two resident vector buffers: three off-diagonal sparse traversals and four cached inverse applications, versus one traversal and two inverse applications in the baseline. No extra allocation, kernel launch inside iteration, host round trip, precision change, changed physical equation or relaxed residual criterion.

The independent oracle uses a long-double assembled physical operator and literal Richardson updates rather than the CUDA factored formula. Both supported and free 12-node / 20-bond fixtures pass every basis vector, symmetry and positive-definiteness checks at the existing thresholds. Native analytic and 3D tests pass. The two observed bombardment runs match the baseline body/contact/fracture/convergence histories. Iteration counts differ as intended; that alone is not performance improvement or trajectory-equivalence proof.

## Performance screen

[Generated comparison](comparison.html), [Markdown](comparison.md), [JSON](comparison.json).

Workload: 256 buildings, 113,664 chunks, 229,376 bonds, 256 projectiles; 180 steps / three simulated seconds per run, timestep 1/60, maximum one correction, sleeping disabled. Two candidate runs are compared with the preceding two recorded baseline runs. Each side includes a separate instrumented phase capture. Every complete-step sample is retained. This is a rejection screen, not randomized long-run qualification or endurance.

The first large-fracture step needs fewer iterations, but its measured stress time increases. Repeated inverse applications and sparse traversals are not free. Counts of maximum iterations do not measure total arithmetic or memory traffic across all components; no hardware saturation claim is made.

No candidate frozen penetration or endurance run was performed after it failed the performance screen. Do not infer those gates from the passing analytic or recorded bombardment histories. The saved baseline runtime was restored, and restored-source suites are recorded separately.

## Reproduce

Apply `candidate.patch` to base commit `1f06175a` only in an experimental checkout; the patch includes its independent polynomial oracle. Runtime and patch hashes are in `experiment.json`. This patch is historical evidence, not a selectable production implementation.

Regenerate the comparison without running GPU work:

```sh
python3 tools/scripts/compare-destruction-candidates.py --baseline qualification/hierarchy-tail-demand-isolated/report.json.gz --candidate qualification/polynomial-four-impacts-256/report.json.gz --output qualification/polynomial-four
```

## Consequence for the next optimization

Adding more polynomial arithmetic is not the next priority. Investigate the existing solver's hot-vector memory layout and repeated off-diagonal gathers: the resident block still exchanges iterative vectors through global arrays. A block-local storage experiment must account for shared-memory capacity, occupancy, stable-node indexing and components larger than the local storage limit. Qualify end-to-end time and unchanged physical outputs before retaining it. CPU fragment lifecycle and correction work remain separate major costs.
