# N28 preparation and removal evidence

No native simulation change or application gain. The isolated native coefficient
planner/CSR assembler is committed at `2b1d762645a4728e8ac48fa3369eee1274156927`
but is not connected to the solver. Release, ASan/UBSan, analytic/negative cases
and 200 independent native component-matrix comparisons pass. Host one-off plan
times are 6.83/6.17 ms and anchored assembly 7.05/5.70 ms; these are diagnostics,
not repeated application timings. Full raw checks/commands:
`out/n28-native-factor-20260912/qualification/report.json`.

## Fresh factor setup result

Frozen city25 impact input: 11,100 chunks, 22,400 authored bonds; each pass has
25 anchored loads. Ten new operators per pass on an initialized context/handle,
plus 20 reused all-load solves. All 100 first/final solution checks pass in each
variant against the independent strong reference and original gradient threshold,
including FP32 recovered-force rounding. This does not qualify native material
or complete-tick behavior. Both cases use exactly the same matrices/25 loads.

| Stress stage | Default fresh setup + 25 solves mean ms | Hybrid fresh setup + 25 solves mean ms | Default reused 25 solves mean ms | Hybrid reused 25 solves mean ms |
|---|---:|---:|---:|---:|
| Initial contact | 26.812 | 32.488 | 0.423 | 10.756 |
| Correction | 24.683 | 26.075 | 0.348 | 7.402 |

Fresh analysis alone costs 25.02/23.32 ms. It is not mostly a one-time startup
cost. Default first-pipeline costs 404.24/410.41 ms include context setup
319.87/325.95 ms; these startup scopes are separate from fresh-operator repeats.
The naive two-pass path costs over 51 ms before native assembly/other step work,
already more than recent city25 whole-step controls (~36–38 ms, separate cohort).
No equal-work application A/B or speedup is claimed.

Nsight Systems shows 63/52 small device-to-host copies and 141/119 GPU launches
per fresh analysis. CPU API and GPU times overlap. CPU stack attribution remains
incomplete, so the gaps cannot be assigned to a removable CPU algorithm.
Reports: `out/native-shared-factor-setup-20260912/profile/run/solve-{0,1}-trace.nsys-rep`.

The supported hybrid single-RHS API still solves all25 inputs, and passes quality,
but is slower overall: reject it. Original unsupported batched/API attempts are
preserved in the JSON record; invalid mode25 is not a usable configuration.
Do not continue blind library parameter tuning. Reassess reuse/removal first.

## Exact duplicate work

In the city25 correction pass, 14 anchored components have identical captured
coefficients, RHS, residual, warm forces and threshold; all14 captured normalized
force arrays are bit-identical. Each has356 nodes and284 iterations. Thirteen
duplicates expose 1,314,352 of2,566,192 iteration-node updates (51.2%) in that
pass. First-pass work has zero exact duplicate updates. Another35 identical
free components already take zero iterations: grouping them would remove no
iterative work. Counts are not saved wall milliseconds, and captured equality
does not prove all private numerical caches are interchangeable.

Next: reuse existing diagnostic modules on city64 impact and city256 intact idle,
impact and late debris; compare every diagnostic against the matching plain
physical reference. Then rank GPU complete-input deduplication against other
reuse. Every current component must still receive its own material verdict;
damage, contacts, correction and convergence remain unchanged.

## Reproduction and retention

All exact compiler/runner/profile commands and raw samples are preserved in the
[structured record](n28-results.json) and its referenced manifests. Scripts:
`out/native-shared-factor-setup-20260912/{build.py,run.py,check-quality.py}`,
`out/native-shared-factor-setup-20260912/profile/{build.py,run.py,analyze.py}`,
`out/native-shared-factor-hybrid-serial-20260912/{build.py,run.py,check-quality.py}`,
`out/n28-native-factor-20260912/qualify.py`. Check-quality requires the frozen
Python dependencies and `OPENBLAS_NUM_THREADS=1`, as recorded by coordinators.
Do not overwrite existing run folders. No setup/hybrid variant is promoted.
Selected N13/isolated N20 and installed SDK remain unchanged.
