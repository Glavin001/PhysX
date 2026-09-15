# Destruction removal: initial implementation results

2026-09-13. Stopped at the user’s request. No candidate has replaced the selected runtime. The complete five-part plan is not implemented: the batch ownership transaction, native prepared solving still require native implementation and qualification. Producer-owned load detection now has a built native candidate; material validity remains separate and unfinished.

The two native topology candidates pass the nine-case physical screen, continuous work histories, selected Systems/Compute comparisons, and focused CUDA topology/memory checks. Neither establishes a substantial sustained-destruction speedup. Retain them as isolated, unpromoted architectural work. Do not combine them or infer additive savings from these separate comparisons.

Source policy: baseline `13b11af2e0aeabf4e0070931fbd8a060f383dfaf`, runtime `d5770a80c2f4686b0ad311edcbfc8e128d14baee64653bf5e032305c12cf9354`. Experimental source is local and uncommitted per the user’s commit policy; each native candidate has a complete isolated source tree, patch SHA256, compiler commands and dependency hashes. Raw reports and captures below require the local ignored `out/` archive.

## Prepared parent-factor experiment

Implemented a private RAII cuDSS operator and a native CUDA PCG replay with current loads, surviving bonds and recovered FP32-force verification. The preconditioner is `R A_parent^-1 R^T`; it supplies no cached physical answer. Free components are excluded. Independent CPU Cholesky, restriction/symmetry checks and all 300 saved GPU output systems pass the captured squared-gradient acceptance check. This does not qualify material behavior or physical trajectories. The fractured approximate force field differs from the strong reference by up to 0.00819 in the recorded scaled coordinate diagnostic, so do not call all numerical gates passed.

| Captured city25 stress pass | Dynamic nodes per structure / loads | FP64 block-Jacobi updates | Parent-factor updates | First GPU batch, ms | Subsequent GPU batches, ms | GPU context/input/factor setup, ms |
|---|---:|---:|---:|---:|---:|---:|
| First impact | 380 / 25 | 184–184 | 2–2 | 6.434 | 0.626–0.659 | 243.314 |
| Fractured correction | 356 / 25 | 281–300 | 60–65 | 36.864 | 30.676–30.793 | 231.420 |

These are mathematical batch timings, not complete simulation ticks. All first-use results remain visible. CPU work comparisons use the 8,192-update limit; the earlier 256-limit and arbitrary restart pilots are preserved under `inputs/` and `inputs-v2/` and are not production convergence failures. The GPU runs completed below 256 updates, so correcting that diagnostic cap does not alter those outputs.

The new Systems capture places about 26.3 ms in GPU kernels per fractured batch; approximately 23.0 ms is forward/back substitution. The ordinary unprofiled batch costs 30.7–30.8 ms after first use. Host polling is therefore not the sole cause. Hold the full-factor-per-iteration route out of runtime integration; a CUDA Graph alone cannot remove the triangular arithmetic.

Evidence: `out/prepared-remnant-20260913/{inputs-v3,gpu,profile}`. GPU source matching its recorded hashes is retained in `gpu/probe-source/`.

A subsequent independent Galerkin screen reuses immutable asset modes and forms the **current** coarse operator. On three loads per pass, 32 modes take 46 first-impact and 101–112 correction updates; 128 modes take 21 and 79–80. All twelve captured-gradient checks pass. This is a new work hypothesis, not an application win. Native preparation, memory, material and trajectory qualification remain required. See `out/prepared-remnant-20260913/coarse-v2/`.

The 32-mode GPU replay passes all 300 captured residual checks. First-impact batches cost 5.107 ms first use and 4.277–4.303 ms subsequently; fractured batches cost 10.495 ms first use and 9.627–9.752 ms subsequently. GPU context/input setup costs 169.372/147.779 ms, excluding the separately recorded host mode preparation. Systems attributes approximately 7.85 ms to GPU kernels per fractured batch, including sparse products and dense coarse expansion. This is cheaper than the full-parent replay but is not a demonstrated improvement over the native component solver. Evidence: `coarse-gpu32/`, `coarse-profile32/`.

A sparse rigid-aggregate alternative passes twelve independent current-gradient checks, including explicit internal-bond rigid-mode cancellation. Eight aggregates require 78 impact / 145–148 correction updates; 32 aggregates require 59 / 105. These CPU work screens have no GPU or application timing qualification. Evidence: `aggregate-screen/`. The rigid-mode design was checked against [PETSc aggregation guidance](https://petsc.org/main/manual/ksp/).

## Reuse symbolic structure through fractures

Implemented a prepared symbolic envelope and serialized numeric-factor epochs. The pattern includes all per-bond structural products, including entries which cancel numerically before a cut. Removed or unsupported coordinates become independent identity rows with zero loads. The active block is checked against the exact current operator. Free components remain excluded. This is a native C++/CUDA library probe, not integrated simulation behavior.

Alternating the actual city25 impact/correction operators reuses symbolic analysis while replacing current coefficients and current loads. All 300 outputs pass recovered-force residual checks and the existing strong reference; worst scaled reference error is 5.725e-11 and worst residual threshold ratio is 0.008280.

| Captured operator / 25 loads | First numeric factor / solve, ms | Subsequent factor, ms | Subsequent solve, ms |
|---|---:|---:|---:|
| Impact | 31.799 / 6.028 | 0.976–1.000 | 0.421–0.441 |
| Fractured correction | 1.015 / 0.432 | 0.960–0.991 | 0.428–0.441 |

Context/input/handle setup is 173.670 ms; one symbolic analysis costs 53.643 ms. No preparation cost is hidden in a full-tick claim. The measured factor-update-plus-solve is about 1.39–1.45 ms after library first use. For this default cuDSS ordering, `REFACTORIZATION` performs numerical factorization again; the removed work is repeated symbolic analysis, not an incremental Cholesky downdate. [NVIDIA phase definitions](https://docs.nvidia.com/cuda/cudss/types.html). Evidence: `refactor-inputs/`, `refactor-gpu/`.

## Large debris changes the sharing strategy

An exact operator-only census excludes positive health magnitude, loads and warm guesses from coefficient identity. It retains complete node/edge ordering, weights, lever arms, boundary identity and bond liveness. This uses saved native captures, with no new GPU census.

| Scenario / pass | Anchored components | Distinct anchored operators | Largest sharing group | Iterative node work in shared operators |
|---|---:|---:|---:|---:|
| city256-initial-impact / 0 | 256 | 1 | 256 | 100.00% |
| city256-initial-impact / 1 | 256 | 1 | 256 | 100.00% |
| city256-intact-idle / 0 | 256 | 1 | 256 | 100.00% |
| city256-late-debris / 0 | 255 | 242 | 3 | 9.16% |
| city256-late-debris / 1 | 262 | 252 | 3 | 2.83% |
| city64-initial-impact / 0 | 64 | 1 | 64 | 100.00% |
| city64-initial-impact / 1 | 64 | 1 | 64 | 100.00% |
| city25-initial-impact / 0 | 25 | 1 | 25 | 100.00% |
| city25-initial-impact / 1 | 25 | 1 | 25 | 100.00% |

Consequently, sharing one numeric factor principally addresses intact/initial-impact cases. Late debris needs many different numeric factors, shared symbolic structure and validity that avoids rebuilding unchanged factors. Operator sharing is not answer sharing.

Implemented the uniform-batch feasibility path for all 256 original assets, preserving 255/262 anchored components in the two captured debris passes. Unsupported/free rows are identities and their output is verified zero. All 3,102 recovered-force checks pass. The initial supplementary 1e-7 reference check failed six repeated outputs for one component: an 80-digit refinement showed that the FP64 CPU reference caused that discrepancy. The GPU error against the refined reference is 5.508e-8. The original failure and refined qualification remain separately saved; no acceptance threshold was loosened.

| Debris pass / 256 distinct matrix slots | First numeric factor / solve, ms | Subsequent all-factor rebuild, ms | Subsequent solve, ms |
|---|---:|---:|---:|
| 0 | 75.366 / 10.267 | 47.526–48.173 | 5.541–5.547 |
| 1 | 47.380 / 5.536 | 47.507–47.996 | 5.534–5.550 |

Batch setup is 277.408 ms, symbolic analysis 73.822 ms. Counted live/peak cuDSS allocations are 289,250,388 bytes; this excludes application input/output buffers, driver/context memory and CPU storage. There is no application speedup claim. Rebuilding all factors every pass is not attractive; reuse or a cheaper factorization is required. Evidence: `batch-inputs/`, `batch-gpu/quality.json` (original supplementary failure), `batch-gpu/quality-strong.json`, `batch-reference-62231/`.

The FP32-factor/FP64-correction experiment passes all 3,102 unchanged residual/reference checks, but its fixed ten corrections make it slower than the FP64 replay. This changes internal factor precision, not the accepted quality budget. Native integration, recovery, per-operator invalidation and material/trajectory qualification remain outstanding.

| FP32-factor debris pass | First factor / ten corrections, ms | Subsequent factor, ms | Subsequent ten corrections, ms |
|---|---:|---:|---:|
| 0 | 733.473 / 184.939 | 32.424–32.720 | 48.720–48.760 |
| 1 | 32.756 / 48.724 | 32.599–32.752 | 48.708–48.744 |

Context/input setup is 292.159 ms; analysis 72.127 ms. First-use costs are retained, including 733.473 ms for the first numeric factor. Counted library peak storage is 148,556,980 bytes, excluding application buffers/context/host. The predeclared sub-20 ms complete batch hypothesis is refuted by factor cost alone. Do not pursue correction-count tuning as the primary route. Reuse current factors and update only changed operators instead. Evidence: `refinement-gpu-v2/`. The original `refinement-gpu/` admission failed safely because another thread owned the GPU lease.

## GPU-owned current coefficients

Implemented an immutable per-bond contribution plan and a GPU coefficient producer. It reads current bond liveness and anchored membership; producer-owned dirty flags gate each asset. Unchanged coefficients persist. Unsupported coordinates become identity rows, preserving the fixed symbolic envelope. Loads do not invalidate factors. Dirty flags are cleared only by a successful factor consumer, not by this producer.

The full 256-asset captures pass five transition checks: all first-state operators, unchanged products despite new inputs, only even assets changed, remaining odd assets changed, then restoration of the first state. Each state contains 5,326,848 coefficients; every coefficient exactly matches independent assembly. FP32 projection also matches. Normal execution plus asynchronous memcheck, initcheck and synccheck pass.

| Coefficient producer epoch | Dirty assets | Producer host elapsed including stream wait, ms |
|---|---:|---:|
| 0 | 256 | 0.747 |
| 1 | 0 | 0.051 |
| 2 | 128 | 0.235 |
| 3 | 128 | 0.234 |
| 4 | 256 | 0.438 |

Context/host-plan/input setup is 257.775 ms. These five samples validate mechanism and bounds, not a statistically qualified speedup. The producer is not yet connected to native factor execution. Evidence: `coefficient-producer/`, including frozen source and all memory-check outputs.

## Lifecycle exposure without collector injection

A bounded new measurement runs the identical frozen phase-enabled executable without Nsight injection, bracketed by plain controls. Both scenarios pass full physical comparison. Only the first tick records phases; two stress/correction passes are summed within that tick. The phase callback still allocates, takes timestamps and records rows. These are instrumented scopes, not an overhead-corrected production decomposition. No estimated overhead is subtracted.

| Scenario / arm | Full-step mean / maximum, ms | 60 Hz misses | Integrated / completion, ms | Restore mean, ms |
|---|---:|---:|---:|---:|
| city25-initial-impact / plain-before | 43.848 / 47.935 | 2/2 | 43.680 / 0.169 | 213.578 |
| city25-initial-impact / phase-only | 46.227 / 53.086 | 2/2 | 45.988 / 0.239 | 219.394 |
| city25-initial-impact / plain-after | 43.726 / 48.377 | 2/2 | 43.547 / 0.179 | 218.551 |
| city256-late-debris / plain-before | 416.263 / 425.825 | 2/2 | 415.968 / 0.294 | 1183.895 |
| city256-late-debris / phase-only | 412.962 / 457.489 | 2/2 | 412.761 / 0.201 | 1215.994 |
| city256-late-debris / plain-after | 412.939 / 430.647 | 2/2 | 412.673 / 0.266 | 1163.913 |

These two-sample process means are diagnostic context, not replacements for the repeated production baseline. Every first-use sample remains included.

| Scenario | Migration calls | Shape migration thread CPU, ms | Refilter wall, ms | Contact retirement wall, ms | Owner registration wall, ms | Actor links wall, ms |
|---|---:|---:|---:|---:|---:|---:|
| city25-initial-impact | 620 | 2.980 | 0.159 | 0.320 | 0.196 | 0.188 |
| city256-late-debris | 6705 | 28.144 | 0.810 | 10.234 | 2.106 | 1.290 |

For large debris, historical collector-enabled migration was about 81.47 ms thread CPU; the new phase-only scope is 28.144 ms. Historical refilter/register/actor-link scopes were roughly 13–15 ms each; phase-only values are 0.810/2.106/1.290 ms. Contact retirement still costs 10.234 ms instrumented wall time. These different diagnostic processes do not provide a calibrated profiler-overhead subtraction, but they refute treating the previous tiny-operation scopes as production exposure. Re-rank lifecycle work toward actual contact retirement and required body/manager registration. N26/N27 lookup-only results remain closed. Evidence: `lifecycle-phase-only/`; historical `out/destruction-baseline-20260913/cpu-full/`.

## Selective numeric refactoring: rejected

Only 127 of the 256 original-asset operators change between the captured debris passes. A GPU equality census identifies that subset; all current right-hand sides are still supplied. The cuDSS mask prototype completes but **fails 1,402 of 3,102 numerical output checks**. Every failing component belongs to an unchanged operator slot. After the masked update, all 129 unselected slots produce zero solutions; 128/127 contain anchored components in the two passes. The exact internal cause has not been established. Do not call this a library bug or reuse those outputs in simulation.

Even its unqualified timings are unattractive: selective factor updates cost 43.48–43.76 ms, with 5.51–5.55 ms current solves and 0.24–0.42 ms detection/readback. The first factor/solve costs 74.43/10.52 ms; setup 312.05 ms and analysis 71.19 ms. No selective-factor speedup is claimed because correctness failed.

Original API failures are preserved. The installed library requires an integer array of `batch * sizeof(int)` bytes, matching its shipped header; current [online docs](https://docs.nvidia.com/cuda/cudss/types.html) describe an int64 bitmask. The installed library also requires mask allocation to be requested before analysis. Its diagnostic log identified those requirements. This is not evidence that a newer cuDSS version behaves the same. The native runtime remains unchanged. Evidence: `selective-gpu/`, `selective-gpu-v2/`, `selective-gpu-v3/`, `selective-api-diagnostic/`, `selective-gpu-v4/`, `selective-gpu-v5/quality-strong.json`.

## Dense prepared inverse-factor application

Implemented replacement of repeated parent triangular solves with two dense products using a fixed rounded inverse Cholesky factor. Its SPD form is `R_parent^T R_parent`, restricted to current anchored coordinates. Current operators, loads, FP64 outer iteration and recovered FP32-force acceptance remain unchanged. This follows the observed triangular-solve bottleneck; it is not a parameter sweep. The initial implementation uses prescribed FP32 arithmetic with [cuBLAS pedantic math](https://docs.nvidia.com/cuda/cublas/), with no reduced-mantissa Tensor Core mode. All 300 captured residual checks pass (worst accepted threshold ratio 0.931762); native material and physical qualification remain pending.

| Captured city25 pass / 25 current loads | Updates | First batch, ms | Later batches, ms | GPU setup, ms |
|---|---:|---:|---:|---:|
| Initial impact | 3 | 160.494 | 0.556–0.569 | 196.641 |
| Fractured correction | 60–65 | 171.819 | 12.474–12.910 | 174.727 |

Host factor preparation separately costs 631.718 ms and creates a 20,793,600-byte immutable FP32 inverse Cholesky factor. It is not free cold-restore state. Systems and four pinned NCU launches pass their own 150 captured residual checks. Across six correction batches, the two dense products consume 15.027/25.909 ms summed GPU duration: about 6.823 ms per batch. Sparse products add about 1.603 ms per batch. These are summed kernel durations from a separate diagnostic replay, not normal full-step costs.

The transposed product executes 337.2 million FP32 FMA instructions per captured launch versus 170.2 million for the non-transposed product. Source names show 128×64 versus 128×32 output tiles for only 25 load columns. This is evidence of padded arithmetic, not a generic occupancy diagnosis. Its measured launch duration is 70.2–70.6 us versus 41.0–41.2 us. A separately stored transpose can test removing that padding without changing the mathematical preconditioner; it adds another 20.8 MB of prepared data. Evidence: `dense-parent/`, `dense-parent-gpu/`, `dense-parent-profile/`, `dense-parent-counters/`. No application gain is established.

The installed CUDA 13.4 header exposes BF16x9 emulation, but the [cuBLAS support table](https://docs.nvidia.com/cuda/cublas/#floating-point-emulation) limits FP32 BF16x9 to compute capabilities 10.0/10.3. This GPU is 12.0; merely selecting that enum is not a supported acceleration experiment here.

### Layout experiment and final force-compatibility gate

The prepared-transpose implementation passes 300 residual checks and 150 selected-counter checks, but is not retained. Impact replay costs 154.761 ms first use and 0.569–0.609 ms later; correction costs 167.052 ms first use and 13.382–13.843 ms later. Setup is 253.159/239.650 ms, including the extra layout/upload but excluding the original host factor preparation. It adds 20,793,600 device bytes. The prior one-layout correction was 12.474–12.910 ms. These separate short replay cohorts establish no application benefit.

Counters confirm the proposed arithmetic removal: the second product drops from 337.2 to 170.2 million FFMA instructions, and selected launch duration drops from 70.2–70.6 to 55.3–56.1 us. However, its measured DRAM traffic rises from 7.4–7.6 MB to 21.1 MB. Reduced instructions therefore do not imply lower complete replay cost. The extra layout was removed from the working prototype; its frozen source and outputs remain under `dense-transpose-gpu/` and `dense-transpose-counters/`.

A final offline check compares the original dense-parent outputs with the saved native normalized force outputs using the exact, revalidated physical export mapping and unchanged 2e-4 force-compatibility bound. **None of the 300 output systems passes that compatibility gate**, despite passing equilibrium-residual acceptance. Worst scaled differences are 0.588 for impact and 1.481 for correction. The native approximation is not thereby proven a stronger mathematical reference; this is evidence that residual convergence alone cannot qualify a drop-in replacement. No material or trajectory gate has been waived. Evidence: `dense-parent-gpu/native-force-compatibility.json`; checker `tools/diagnostics/destruction-prepared-factor/compare-native-forces.py`.

## Local connectivity

Preserves union/find parents and spanning-tree flags for unchanged old components. Changed components still rebuild; global scheduling/compaction and other derived structures remain.

Source patch SHA256: `405bbe00cad9f791a4b62b078614faf3ae501543598c03fc307976d4a3814f38`. Full representative turnaround: 284.281 s; desktop restored. Each comparison uses unchanged frozen inputs/checker, one GPU job at a time, and includes the first full tick in every process. Restore/checks/profiling remain outside tick latency.

| Scenario | A full-step mean range, ms | B full-step mean range, ms | A / B observed maximum, ms | A / B 60 Hz misses / ticks | Descriptive A−B, ms |
|---|---:|---:|---:|---:|---:|
| bridge64-cold | 8.958–8.986 | 8.850 | 11.764 / 11.678 | 0/16 / 0/8 | +0.122 |
| chain256-cold | 7.169–7.430 | 7.317 | 9.870 / 9.879 | 0/16 / 0/8 | -0.017 |
| dense12-cold | 30.898–31.282 | 31.104 | 33.767 / 31.500 | 12/12 / 6/6 | -0.014 |
| tower64-cold | 108.770–108.869 | 108.861 | 110.941 / 111.000 | 8/8 / 4/4 | -0.041 |
| city25-initial-impact | 38.777–41.836 | 38.151–40.625 | 48.259 / 48.267 | 12/12 / 12/12 | +0.919 |
| city256-intact-idle | 70.478–75.076 | 66.650 | 87.648 / 72.284 | 8/8 / 4/4 | +6.127 |
| city256-late-debris | 369.854–381.202 | 352.307–381.408 | 426.855 / 408.492 | 8/8 / 8/8 | +8.670 |
| idle-256 | 1.682–1.693 | 1.652–1.671 | 14.166 / 14.050 | 0/360 / 0/360 | +0.026 |
| impacts-256 | 54.566–54.835 | 54.585–54.760 | 170.652 / 181.072 | 198/360 / 198/360 | +0.028 |

A is the frozen baseline; B is this candidate. Means span independently started processes. A−B is descriptive, not a confidence-qualified speedup. The two continuous cases are 180-tick trajectories; the other seven are independent restored ticks. Their means are not pooled.

| Scenario | A / B command, ms | A / B integrated physics/stress, ms | A / B completion, ms | A / B mean restore, ms |
|---|---:|---:|---:|---:|
| bridge64-cold | 0.000 / 0.000 | 8.755 / 8.674 | 0.217 / 0.176 | 37.454 / 36.536 |
| chain256-cold | 0.000 / 0.000 | 7.117 / 7.139 | 0.182 / 0.178 | 33.441 / 34.506 |
| dense12-cold | 0.000 / 0.000 | 30.885 / 30.890 | 0.205 / 0.214 | 55.607 / 62.416 |
| tower64-cold | 0.000 / 0.000 | 108.620 / 108.652 | 0.199 / 0.209 | 74.489 / 78.317 |
| city25-initial-impact | 0.000 / 0.000 | 40.093 / 39.198 | 0.213 / 0.189 | 101.059 / 97.443 |
| city256-intact-idle | 0.000 / 0.000 | 72.540 / 66.438 | 0.237 / 0.211 | 727.260 / 727.032 |
| city256-late-debris | 0.000 / 0.000 | 375.240 / 366.583 | 0.287 / 0.274 | 800.149 / 802.643 |
| idle-256 | 0.000 / 0.000 | 1.470 / 1.471 | 0.217 / 0.190 | — / — |
| impacts-256 | 0.188 / 0.179 | 54.291 / 54.265 | 0.221 / 0.228 | — / — |

Integrated physics/stress includes transfers, synchronization, material evaluation, required correction and second stress. GPU stress durations are overlapping attribution, not another additive stage. The legacy zero stress field is not used. Per-process initialization, first-use, stage, spread and peak-state records remain in `representative/screen.json`.

Evidence root: `out/local-topology-20260913/`. See `build/`, `representative/screen.json`, `representative/systems/city256-late-debris/`, `representative/ncu/`.

CUDA kernel checks cover 80 topology transactions on chains, shared-support cycles, small islands and a 100,000-node sparse-damage world; memcheck, initcheck and synccheck pass. These focused tests do not substitute for full52 finalist qualification.

The large sparse-damage test verifies 1,478,853 unchanged node-transactions and 1,966,470 unchanged live-edge-transactions across its updates. These are predicate exposures and preserved-state checks, not GPU instruction counters or milliseconds saved. The full-step continuous destruction difference is only +0.028 ms. No substantial win established.

## Topology-owned operator adjacency

Removes cacheNativeOperatorNeighbors from every active component solve. A topology producer refreshes those entries only on initial setup or changes to their old component. All other solve mathematics is unchanged.

Source patch SHA256: `96dd2029cc8723361375f0100fe501372c2a799ad3f627f169601a66761d24d5`. Full representative turnaround: 286.480 s; desktop restored. Each comparison uses unchanged frozen inputs/checker, one GPU job at a time, and includes the first full tick in every process. Restore/checks/profiling remain outside tick latency.

| Scenario | A full-step mean range, ms | B full-step mean range, ms | A / B observed maximum, ms | A / B 60 Hz misses / ticks | Descriptive A−B, ms |
|---|---:|---:|---:|---:|---:|
| bridge64-cold | 8.730–8.994 | 8.947 | 11.614 / 11.659 | 0/16 / 0/8 | -0.085 |
| chain256-cold | 6.714–7.043 | 7.420 | 8.970 / 10.331 | 0/16 / 0/8 | -0.541 |
| dense12-cold | 31.562–32.305 | 31.560 | 38.043 / 33.719 | 12/12 / 6/6 | +0.373 |
| tower64-cold | 108.988–109.137 | 108.818 | 111.335 / 111.075 | 8/8 / 4/4 | +0.244 |
| city25-initial-impact | 39.374–40.186 | 38.389–40.066 | 48.380 / 47.796 | 12/12 / 12/12 | +0.552 |
| city256-intact-idle | 62.007–79.908 | 67.545 | 95.865 / 88.631 | 8/8 / 4/4 | +3.412 |
| city256-late-debris | 375.226–377.289 | 355.528–375.368 | 414.568 / 434.167 | 8/8 / 8/8 | +10.810 |
| idle-256 | 1.720–1.730 | 1.436–1.623 | 13.934 / 14.148 | 0/360 / 0/360 | +0.195 |
| impacts-256 | 54.678–54.706 | 54.401–54.903 | 187.375 / 176.807 | 198/360 / 198/360 | +0.040 |

A is the frozen baseline; B is this candidate. Means span independently started processes. A−B is descriptive, not a confidence-qualified speedup. The two continuous cases are 180-tick trajectories; the other seven are independent restored ticks. Their means are not pooled.

| Scenario | A / B command, ms | A / B integrated physics/stress, ms | A / B completion, ms | A / B mean restore, ms |
|---|---:|---:|---:|---:|
| bridge64-cold | 0.000 / 0.000 | 8.679 / 8.738 | 0.182 / 0.209 | 35.741 / 36.749 |
| chain256-cold | 0.000 / 0.000 | 6.695 / 7.222 | 0.183 / 0.198 | 31.900 / 31.639 |
| dense12-cold | 0.000 / 0.000 | 31.738 / 31.351 | 0.196 / 0.209 | 56.712 / 55.077 |
| tower64-cold | 0.000 / 0.000 | 108.878 / 108.605 | 0.184 / 0.213 | 77.537 / 76.330 |
| city25-initial-impact | 0.000 / 0.000 | 39.587 / 39.041 | 0.192 / 0.187 | 97.400 / 102.231 |
| city256-intact-idle | 0.000 / 0.000 | 70.669 / 67.327 | 0.288 / 0.218 | 726.974 / 725.860 |
| city256-late-debris | 0.000 / 0.000 | 375.991 / 365.203 | 0.267 / 0.244 | 812.593 / 797.730 |
| idle-256 | 0.000 / 0.000 | 1.536 / 1.319 | 0.189 / 0.210 | — / — |
| impacts-256 | 0.180 / 0.177 | 54.280 / 54.253 | 0.232 / 0.222 | — / — |

Integrated physics/stress includes transfers, synchronization, material evaluation, required correction and second stress. GPU stress durations are overlapping attribution, not another additive stage. The legacy zero stress field is not used. Per-process initialization, first-use, stage, spread and peak-state records remain in `representative/screen.json`.

Evidence root: `out/prepared-neighbors-20260913/`. See `build/`, `representative/screen.json`, `representative/systems/city256-late-debris/`, `representative/ncu/`.

CUDA kernel checks cover 80 topology transactions on chains, shared-support cycles, small islands and a 100,000-node sparse-damage world; memcheck, initcheck and synccheck pass. These focused tests do not substitute for full52 finalist qualification.

The initial chain signal is 0.541 ms slower descriptively. A subsequent independent 20/20/20 confirmation does not reproduce it: A means 7.157/7.382 ms, B 7.249 ms; maxima A 9.636/10.125 ms, B 8.118 ms; zero 60 Hz misses in all 60 ticks. Integrated stages average 7.069/7.058 ms and completion 0.200/0.191 ms for A/B. Physical checks and 492-iteration histories agree. This is not proof of a speedup or tight equivalence. Evidence: `chain-confirm/`. Full52 now passes all 3,120 physical tick comparisons, in 1,453.370 seconds including setup/restores/checks. Mixed performance and several regression signals prevent promotion. Continuous destruction differs by only +0.040 ms. The apparently larger cold-idle/debris differences are not yet confirmed; first-use/control variation is substantial. Initial adjacency preparation now belongs to topology creation, so initialization/restore cost must remain visible in any cold-start claim.

### Full52 adjacency qualification

All first-use ticks are included. Each row is 20 A-before, 20 B and 20 A-after ticks. These descriptive intervals are not simultaneous causal confidence bounds. Chain32-warm, stimulus, flying, city25-airborne and city25-late-debris have negative intervals; preserve these signals. No sustained-destruction speedup is established. Full52 asynchronous memory and extended trajectory checks are still outstanding.

| Scenario | A mean range / B mean, ms | A / B maximum, ms | A / B 60 Hz misses | Descriptive A−B interval, ms |
|---|---:|---:|---:|---:|
| bridge64-cold | 8.629–9.104 / 8.740 | 12.113 / 11.457 | 0/40 / 0/20 | [-0.285, +0.471] |
| bridge64-warm | 8.664–8.961 / 8.962 | 11.524 / 11.758 | 0/40 / 0/20 | [-0.517, +0.169] |
| building-cold | 4.624–4.764 / 4.640 | 7.717 / 7.394 | 0/40 / 0/20 | [-0.338, +0.452] |
| building-fragmented | 8.595–9.153 / 8.763 | 15.464 / 14.987 | 0/40 / 0/20 | [-0.773, +0.862] |
| building-warm | 4.255–4.762 / 4.649 | 7.820 / 7.627 | 0/40 / 0/20 | [-0.595, +0.255] |
| cantilever64-cold | 7.028–7.293 / 7.341 | 9.988 / 10.201 | 0/40 / 0/20 | [-0.566, +0.142] |
| cantilever64-warm | 7.300–7.338 / 7.067 | 10.316 / 8.543 | 0/40 / 0/20 | [-0.006, +0.536] |
| chain256-cold | 6.625–7.602 / 7.271 | 9.901 / 9.908 | 0/40 / 0/20 | [-0.597, +0.229] |
| chain256-warm | 6.814–7.199 / 6.933 | 10.115 / 9.760 | 0/40 / 0/20 | [-0.324, +0.444] |
| chain32-cold | 3.131–3.144 / 2.544 | 6.719 / 6.098 | 0/40 / 0/20 | [+0.104, +1.042] |
| chain32-warm | 2.503–2.756 / 3.098 | 6.622 / 6.674 | 0/40 / 0/20 | [-0.955, -0.056] |
| dense12-cold | 31.449–31.773 / 31.520 | 34.089 / 34.052 | 40/40 / 20/20 | [-0.300, +0.465] |
| dense12-warm | 31.035–31.463 / 31.252 | 34.183 / 32.096 | 40/40 / 20/20 | [-0.322, +0.335] |
| destruction-cold | 3.068–3.307 / 3.290 | 7.239 / 7.800 | 0/40 / 0/20 | [-0.676, +0.380] |
| destruction-damaged | 2.788–3.388 / 3.361 | 7.311 / 7.294 | 0/40 / 0/20 | [-0.829, +0.216] |
| destruction-fractured | 4.971–5.052 / 4.865 | 8.803 / 8.568 | 0/40 / 0/20 | [-0.420, +0.652] |
| destruction-intact | 3.185–3.285 / 3.325 | 7.245 / 6.811 | 0/40 / 0/20 | [-0.583, +0.365] |
| destruction-onset | 3.541–4.119 / 3.297 | 7.714 / 7.740 | 0/40 / 0/20 | [-0.082, +1.070] |
| destruction-stimulus | 3.261–3.409 / 4.190 | 6.931 / 8.232 | 0/40 / 0/20 | [-1.401, -0.437] |
| flying | 1.358–1.754 / 2.005 | 2.690 / 2.769 | 0/40 / 0/20 | [-0.613, -0.281] |
| ladder128-cold | 5.676–5.700 / 5.080 | 8.248 / 8.395 | 0/40 / 0/20 | [+0.159, +0.986] |
| ladder128-warm | 4.863–5.637 / 5.569 | 8.525 / 11.328 | 0/40 / 0/20 | [-1.114, +0.336] |
| panel32-cold | 20.808–21.171 / 21.338 | 23.782 / 24.746 | 40/40 / 20/20 | [-0.834, +0.039] |
| panel32-warm | 20.829–20.971 / 20.958 | 23.768 / 24.195 | 40/40 / 20/20 | [-0.491, +0.279] |
| resting | 1.394–1.519 / 1.565 | 3.223 / 2.750 | 0/40 / 0/20 | [-0.350, +0.112] |
| sliding | 2.651–2.718 / 2.763 | 4.478 / 3.864 | 0/40 / 0/20 | [-0.311, +0.153] |
| tower64-cold | 107.983–108.210 / 107.944 | 111.612 / 109.416 | 40/40 / 20/20 | [-0.228, +0.567] |
| tower64-warm | 108.055–108.113 / 108.090 | 110.997 / 109.482 | 40/40 / 20/20 | [-0.341, +0.317] |
| city25-intact-idle | 9.930–9.978 / 9.838 | 13.208 / 12.931 | 0/40 / 0/20 | [-0.419, +0.616] |
| city25-airborne | 11.255–11.286 / 12.178 | 14.624 / 15.920 | 0/40 / 0/20 | [-1.567, -0.291] |
| city25-initial-impact | 38.367–39.768 / 37.691 | 49.622 / 44.158 | 40/40 / 20/20 | [+0.055, +2.755] |
| city25-post-impact | 22.050–22.100 / 21.975 | 29.808 / 27.255 | 40/40 / 20/20 | [-0.732, +0.865] |
| city25-cascading-fracture | 38.046–39.236 / 37.077 | 48.851 / 39.900 | 40/40 / 20/20 | [+0.628, +2.523] |
| city25-fragmented-loaded | 51.425–52.001 / 52.194 | 67.758 / 62.603 | 40/40 / 20/20 | [-2.263, +1.226] |
| city25-late-debris | 64.441–66.881 / 67.779 | 80.709 / 85.766 | 40/40 / 20/20 | [-4.594, -0.145] |
| city25-ten-second-debris | 65.379–68.376 / 69.056 | 78.471 / 86.893 | 40/40 / 20/20 | [-4.862, +0.195] |
| city64-intact-idle | 16.148–16.290 / 16.430 | 21.296 / 25.184 | 8/40 / 4/20 | [-1.520, +0.831] |
| city64-airborne | 17.472–17.996 / 18.033 | 22.936 / 22.402 | 36/40 / 20/20 | [-1.047, +0.388] |
| city64-initial-impact | 57.695–65.662 / 60.351 | 75.922 / 77.035 | 40/40 / 20/20 | [-1.224, +3.855] |
| city64-post-impact | 36.511–36.815 / 37.196 | 50.752 / 47.605 | 40/40 / 20/20 | [-2.331, +1.228] |
| city64-cascading-fracture | 54.904–55.289 / 55.089 | 73.834 / 72.069 | 40/40 / 20/20 | [-2.480, +2.101] |
| city64-fragmented-loaded | 85.212–91.772 / 91.039 | 107.914 / 110.013 | 40/40 / 20/20 | [-5.773, +0.374] |
| city64-late-debris | 115.894–123.987 / 125.322 | 154.803 / 159.514 | 40/40 / 20/20 | [-11.678, +0.471] |
| city64-ten-second-debris | 94.402–98.911 / 94.775 | 138.462 / 125.102 | 40/40 / 20/20 | [-3.707, +6.641] |
| city256-intact-idle | 61.355–61.713 / 59.612 | 77.904 / 70.084 | 40/40 / 20/20 | [-0.770, +4.577] |
| city256-airborne | 70.478–75.549 / 65.361 | 100.698 / 92.098 | 40/40 / 20/20 | [+3.025, +11.843] |
| city256-initial-impact | 215.527–218.716 / 216.217 | 268.318 / 280.668 | 40/40 / 20/20 | [-9.120, +10.011] |
| city256-post-impact | 132.390–134.887 / 131.347 | 189.710 / 154.354 | 40/40 / 20/20 | [-4.175, +9.328] |
| city256-cascading-fracture | 190.277–196.657 / 188.070 | 238.160 / 217.771 | 40/40 / 20/20 | [-1.071, +12.541] |
| city256-fragmented-loaded | 272.782–274.426 / 279.807 | 316.712 / 306.924 | 40/40 / 20/20 | [-15.109, +2.140] |
| city256-late-debris | 339.906–343.954 / 340.008 | 404.306 / 397.389 | 40/40 / 20/20 | [-9.028, +13.149] |
| city256-ten-second-debris | 249.402–254.654 / 256.225 | 361.740 / 320.202 | 40/40 / 20/20 | [-19.180, +10.334] |

| Scenario | A / B command, ms | A / B integrated physics/stress, ms | A / B completion, ms | A / B mean restore, ms |
|---|---:|---:|---:|---:|
| bridge64-cold | 0.000 / 0.000 | 8.687 / 8.564 | 0.180 / 0.176 | 22.373 / 21.332 |
| bridge64-warm | 0.000 / 0.000 | 8.632 / 8.767 | 0.181 / 0.196 | 20.748 / 22.376 |
| building-cold | 0.000 / 0.000 | 4.522 / 4.474 | 0.171 / 0.167 | 19.775 / 19.576 |
| building-fragmented | 0.000 / 0.000 | 8.687 / 8.569 | 0.186 / 0.193 | 22.338 / 21.833 |
| building-warm | 0.000 / 0.000 | 4.296 / 4.449 | 0.213 / 0.200 | 19.896 / 19.570 |
| cantilever64-cold | 0.000 / 0.000 | 6.984 / 7.139 | 0.176 / 0.202 | 17.435 / 17.081 |
| cantilever64-warm | 0.000 / 0.000 | 7.148 / 6.887 | 0.171 / 0.180 | 15.883 / 17.045 |
| chain256-cold | 0.000 / 0.000 | 6.932 / 7.065 | 0.182 / 0.206 | 18.073 / 17.730 |
| chain256-warm | 0.000 / 0.000 | 6.824 / 6.747 | 0.182 / 0.186 | 16.935 / 17.913 |
| chain32-cold | 0.000 / 0.000 | 2.950 / 2.330 | 0.188 / 0.214 | 16.408 / 16.496 |
| chain32-warm | 0.000 / 0.000 | 2.454 / 2.946 | 0.176 / 0.152 | 16.347 / 15.861 |
| dense12-cold | 0.000 / 0.000 | 31.403 / 31.318 | 0.208 / 0.201 | 35.863 / 36.794 |
| dense12-warm | 0.000 / 0.000 | 31.053 / 31.045 | 0.195 / 0.207 | 35.087 / 36.713 |
| destruction-cold | 0.000 / 0.000 | 3.010 / 3.122 | 0.178 / 0.167 | 15.336 / 15.778 |
| destruction-damaged | 0.000 / 0.000 | 2.908 / 3.226 | 0.180 / 0.135 | 15.904 / 15.491 |
| destruction-fractured | 0.000 / 0.000 | 4.842 / 4.703 | 0.169 / 0.162 | 15.996 / 15.690 |
| destruction-intact | 0.000 / 0.000 | 3.068 / 3.177 | 0.167 / 0.147 | 16.071 / 16.384 |
| destruction-onset | 0.000 / 0.000 | 3.639 / 3.142 | 0.191 / 0.155 | 17.152 / 16.775 |
| destruction-stimulus | 0.003 / 0.002 | 3.135 / 3.994 | 0.197 / 0.195 | 16.463 / 15.841 |
| flying | 0.000 / 0.001 | 1.555 / 2.004 | 0.000 / 0.000 | 6.698 / 7.074 |
| ladder128-cold | 0.000 / 0.000 | 5.515 / 4.908 | 0.173 / 0.172 | 19.930 / 19.016 |
| ladder128-warm | 0.000 / 0.000 | 5.031 / 5.250 | 0.218 / 0.319 | 19.540 / 19.921 |
| panel32-cold | 0.000 / 0.000 | 20.750 / 21.118 | 0.239 / 0.220 | 26.139 / 26.163 |
| panel32-warm | 0.000 / 0.000 | 20.678 / 20.759 | 0.222 / 0.199 | 26.134 / 25.270 |
| resting | 0.000 / 0.000 | 1.455 / 1.564 | 0.001 / 0.001 | 6.882 / 6.972 |
| sliding | 0.000 / 0.000 | 2.684 / 2.763 | 0.000 / 0.000 | 7.010 / 7.145 |
| tower64-cold | 0.000 / 0.000 | 107.905 / 107.751 | 0.192 / 0.193 | 41.212 / 40.813 |
| tower64-warm | 0.000 / 0.000 | 107.910 / 107.910 | 0.174 / 0.180 | 40.263 / 40.586 |
| city25-intact-idle | 0.000 / 0.000 | 9.759 / 9.642 | 0.195 / 0.196 | 60.628 / 63.267 |
| city25-airborne | 0.000 / 0.000 | 11.067 / 11.983 | 0.203 / 0.195 | 61.521 / 60.536 |
| city25-initial-impact | 0.000 / 0.000 | 38.884 / 37.502 | 0.184 / 0.189 | 64.014 / 62.771 |
| city25-post-impact | 0.000 / 0.000 | 21.885 / 21.794 | 0.190 / 0.181 | 62.515 / 63.849 |
| city25-cascading-fracture | 0.000 / 0.000 | 38.434 / 36.873 | 0.207 / 0.204 | 64.312 / 63.528 |
| city25-fragmented-loaded | 0.000 / 0.000 | 51.527 / 52.019 | 0.186 / 0.175 | 68.313 / 65.738 |
| city25-late-debris | 0.000 / 0.000 | 65.439 / 67.547 | 0.222 / 0.231 | 69.495 / 71.271 |
| city25-ten-second-debris | 0.000 / 0.000 | 66.666 / 68.850 | 0.212 / 0.206 | 71.780 / 65.793 |
| city64-intact-idle | 0.000 / 0.000 | 16.013 / 16.237 | 0.206 / 0.193 | 154.599 / 152.893 |
| city64-airborne | 0.000 / 0.000 | 17.549 / 17.834 | 0.185 / 0.199 | 149.749 / 150.098 |
| city64-initial-impact | 0.000 / 0.000 | 61.489 / 60.142 | 0.189 / 0.209 | 151.117 / 157.035 |
| city64-post-impact | 0.000 / 0.000 | 36.457 / 36.993 | 0.206 / 0.203 | 151.450 / 153.375 |
| city64-cascading-fracture | 0.000 / 0.000 | 54.907 / 54.903 | 0.189 / 0.186 | 153.433 / 153.114 |
| city64-fragmented-loaded | 0.000 / 0.000 | 88.271 / 90.812 | 0.221 / 0.226 | 159.280 / 160.917 |
| city64-late-debris | 0.000 / 0.000 | 119.733 / 125.115 | 0.207 / 0.207 | 159.642 / 161.155 |
| city64-ten-second-debris | 0.000 / 0.000 | 96.426 / 94.585 | 0.230 / 0.190 | 167.187 / 161.625 |
| city256-intact-idle | 0.000 / 0.000 | 61.278 / 59.402 | 0.256 / 0.210 | 435.735 / 435.533 |
| city256-airborne | 0.000 / 0.000 | 72.779 / 65.118 | 0.235 / 0.243 | 440.074 / 442.018 |
| city256-initial-impact | 0.000 / 0.000 | 216.890 / 216.007 | 0.231 / 0.209 | 437.396 / 432.331 |
| city256-post-impact | 0.000 / 0.000 | 133.393 / 131.145 | 0.245 / 0.202 | 476.296 / 476.677 |
| city256-cascading-fracture | 0.000 / 0.000 | 193.220 / 187.816 | 0.247 / 0.254 | 474.356 / 475.844 |
| city256-fragmented-loaded | 0.000 / 0.000 | 273.380 / 279.582 | 0.223 / 0.225 | 485.260 / 495.175 |
| city256-late-debris | 0.000 / 0.000 | 341.695 / 339.737 | 0.235 / 0.271 | 497.305 / 495.131 |
| city256-ten-second-debris | 0.000 / 0.000 | 251.798 / 255.995 | 0.230 / 0.229 | 501.092 / 498.088 |

Evidence: `out/prepared-neighbors-20260913/full52/{campaign.json,matched/report.json}`. The report includes per-process setup and first-use samples; raw tick records remain local.

## Producer-owned exact load changes

Moves the exact six-float input comparison to each node’s final load writer and removes the consumer’s second full input scan. Contact removal receives fresh base loads. Existing topology, settings and accepted-equilibrium validity gates remain. Stable per-chunk contact order is unchanged; rates are cleared before contact routing because contacts can write both endpoints. Material evaluation remains active, including constant-stress damage.

Source patch SHA256: `0ef04997c3b87c69f7fbe1c734d17e985cec3072597e869a552d693857252a61`. Full representative turnaround: 286.173 s; desktop restored. Each comparison uses unchanged frozen inputs/checker, one GPU job at a time, and includes the first full tick in every process. Restore/checks/profiling remain outside tick latency.

| Scenario | A full-step mean range, ms | B full-step mean range, ms | A / B observed maximum, ms | A / B 60 Hz misses / ticks | Descriptive A−B, ms |
|---|---:|---:|---:|---:|---:|
| bridge64-cold | 8.911–9.056 | 9.020 | 11.918 / 11.475 | 0/16 / 0/8 | -0.037 |
| chain256-cold | 7.588–7.627 | 7.751 | 10.769 / 10.552 | 0/16 / 0/8 | -0.144 |
| dense12-cold | 31.526–31.553 | 31.245 | 33.978 / 33.162 | 12/12 / 6/6 | +0.294 |
| tower64-cold | 108.433–108.844 | 108.786 | 110.816 / 110.745 | 8/8 / 4/4 | -0.148 |
| city25-initial-impact | 39.205–39.976 | 39.829–40.981 | 47.882 / 48.651 | 12/12 / 12/12 | -0.814 |
| city256-intact-idle | 64.358–64.736 | 63.777 | 73.121 / 66.307 | 8/8 / 4/4 | +0.770 |
| city256-late-debris | 353.548–354.846 | 367.553–373.595 | 406.925 / 419.145 | 8/8 / 8/8 | -16.377 |
| idle-256 | 1.661–1.676 | 1.673–1.731 | 14.023 / 14.162 | 0/360 / 0/360 | -0.034 |
| impacts-256 | 54.463–54.781 | 54.505–55.106 | 184.784 / 179.930 | 198/360 / 198/360 | -0.183 |

A is the frozen baseline; B is this candidate. Means span independently started processes. A−B is descriptive, not a confidence-qualified speedup. The two continuous cases are 180-tick trajectories; the other seven are independent restored ticks. Their means are not pooled.

| Scenario | A / B command, ms | A / B integrated physics/stress, ms | A / B completion, ms | A / B mean restore, ms |
|---|---:|---:|---:|---:|
| bridge64-cold | 0.000 / 0.000 | 8.808 / 8.844 | 0.176 / 0.176 | 36.083 / 37.342 |
| chain256-cold | 0.000 / 0.000 | 7.428 / 7.590 | 0.179 / 0.161 | 31.634 / 32.332 |
| dense12-cold | 0.000 / 0.000 | 31.344 / 31.062 | 0.195 / 0.183 | 57.857 / 58.471 |
| tower64-cold | 0.000 / 0.000 | 108.452 / 108.601 | 0.187 / 0.185 | 76.285 / 79.142 |
| city25-initial-impact | 0.000 / 0.000 | 39.419 / 40.226 | 0.172 / 0.179 | 100.214 / 100.250 |
| city256-intact-idle | 0.000 / 0.000 | 64.289 / 63.474 | 0.258 / 0.303 | 735.722 / 742.724 |
| city256-late-debris | 0.000 / 0.000 | 353.959 / 370.294 | 0.238 / 0.280 | 807.492 / 807.632 |
| idle-256 | 0.000 / 0.000 | 1.467 / 1.493 | 0.201 / 0.209 | — / — |
| impacts-256 | 0.176 / 0.167 | 54.212 / 54.412 | 0.234 / 0.226 | — / — |

Integrated physics/stress includes transfers, synchronization, material evaluation, required correction and second stress. GPU stress durations are overlapping attribution, not another additive stage. The legacy zero stress field is not used. Per-process initialization, first-use, stage, spread and peak-state records remain in `representative/screen.json`.

Evidence root: `out/input-producer-20260913-v2/`. See `build/`, `representative/screen.json`, `representative/systems/city256-late-debris/`, `representative/ncu/`.

Before timing, bridge64, city25 impact and city256 debris pass 18 matched full ticks (2/2/2 per case). City25 impact and city256 debris also pass four asynchronous memcheck ticks and their full physical comparisons; recovered bond forces are bit-identical in these checks. This does not cover all snapshot edge cases or extended trajectories. The private bridge allocates two uint32 arrays per node (909,312 bytes at 113,664 chunks), and adds touched-node marking and dirty-array clearing. Its second input scan is removed, not all input preparation. No constant-stress material work is skipped. It remains unpromoted; see `mechanism/campaign.json` and the per-scenario measurements above.

## Remaining ranked work

| Rank | Hypothesis and evidence | Affected scenarios | Planning full-tick saving | Confidence / cost | Support or refutation |
|---|---|---|---|---|---|
| 1 | Retained independent current factors; 5.54 ms current debris solves, but 48 ms full factor rebuild and rejected mask retention. GPU coefficient producer is qualified separately | Loaded anchored remnants, city destruction | 0–30 ms; unverified | Strong work concentration, low integrated confidence / high cost | Use an explicit retained-factor lifetime instead of retrying the failed mask path; charge real invalidations, setup, memory and complete ticks |
| 2 | Complete ownership transaction retaining only dependency-valid records; phase-only debris exposes 10.23 ms contact retirement and 26.50 ms first-pass contact preparation | Fracture onset, cascades, large debris | 0–20 ms on fracture ticks, 0–5 ms heavy mean; revised low-confidence range | Medium diagnosis / high cost | Prove which records depend on body identity and which only on persistent geometry; preserve wake/contact order. Do not repeat lookup-only or collector-inflated tiny operations |
| 3 | Exact shared current-load direct solve with prepared operators; existing 25-load feasibility passes | Repeated intact assets and early impact | 0–7 ms; tower 20–80 ms remains exploratory | Strong sharing evidence, low application confidence / high cost | Charge setup, memory and invalidation; no fresh synchronous analysis on every fracture or hidden cache priming |
| 4 | Complete localized derived-structure maintenance; connectivity and adjacency candidates now exist separately | Local damage, mixed intact/damaged worlds | 0–5 ms; unverified | Medium / medium–high cost | Confirm regressions first; preserve unaffected scheduling ranges and preparation only with complete validity |
| 5 | Native producer-owned load detection passes its screen with a debris regression signal and no sustained win; complete material validity remains distinct | Idle, sparse stimuli, mixed activity | 0–0.2 ms idle, 0–3 ms mixed; unverified | Strong architecture, modest exposure / medium cost | Require full-tick guardrails and exact invalidation; skip material only with a proven zero increment |

Planning ranges overlap and must not be added. No scope change permits stale physics, Direct GPU API, disabled sleeping, an extra correction, unqualified reduced quality, or omitted setup. Known unequal-mass model failures remain separate. The selected implementation is unchanged; full52 and physical trajectory qualification remain mandatory for finalists. No new experiments are queued. Resume only on a new user instruction. Shutdown receipt: `out/prepared-remnant-20260913/stopped.json`.
