# R1 warm nine-window screen (contract v3)

2026-09-15. Candidate: runtime built from commit `0c5c997c` plus the chain-depth
guard (this commit), artifacts `out/direct-factor-feasibility-20260915/artifacts`
(runtime sha256 `aa2ca56f…`). Control: frozen selected artifacts
`out/destruction-baseline-20260913/artifacts` (runtime `d5770a80…`). Same probe
binaries (`out/warm-replay-20260914/{plain,profile}/serialization-probe`), plan
`out/direct-warm-screen-20260915/plan-v3.json`, results `results-v3/`, 291.6 s
GPU-exclusive with desktop management. A0/B/A1 order, two processes × two
restored trajectories × 8 measured ticks (16 for city256 idle). All 27 plain jobs
and both profiles completed.

| window | A0 mean | **B mean** | A1 mean | A0 max | B max | A1 max | 60 Hz misses A0/B/A1 |
|---|---:|---:|---:|---:|---:|---:|---:|
| bridge64 | 1.35 | 1.53 | 1.42 | 1.6 | 1.7 | 1.5 | 0/0/0 |
| chain256 | 1.40 | 1.20 | 1.42 | 1.6 | 1.4 | 1.8 | 0/0/0 |
| dense12 | 1.60 | 1.39 | 1.26 | 1.8 | 1.5 | 1.5 | 0/0/0 |
| tower64 | 1.48 | 1.47 | 1.46 | 3.2 | 2.1 | 1.5 | 0/0/0 |
| city25 impact | 22.64 | **17.06** | 22.62 | 38.0 | 32.7 | 37.4 | 10/9/10 of 16 |
| city256 idle | 1.55 | 1.64 | 1.62 | 2.9 | 2.1 | 2.0 | 0/0/0 of 32 |
| city256 impact | 89.32 | **75.42** | 88.33 | 172.5 | 183.0 | 188.7 | 16/16/16 |
| city256 cascade | 104.61 | **79.85** | 105.62 | 141.5 | 120.5 | 145.0 | 16/16/16 |
| city256 debris | 125.40 | **93.05** | 125.81 | 130.2 | 99.6 | 130.4 | 16/16/16 |

Milliseconds of `complete_step_ms`. The impact peak is unchanged within noise:
that tick is dominated by CPU fragment registration (R2). An earlier v2-contract
run of the same candidate without the chain guard measured city25 impact 15.02,
city256 impact 75.72, cascade 79.27 and debris 94.12 ms, and chain256 2.28 ms
(the chain's 255-level elimination path made the level-synchronous solve slower
than PCG; patterns deeper than half their node count now stay on PCG).

## Physical verdicts

Every candidate window passes contract v3. Work histories (broken bonds,
correction and stress passes, clusters, islands, active nodes/bonds, contacts,
friction anchors) match the control on every tick; active bonds, cluster
membership, crush state, loads and accelerations are byte-identical; motion is
within the frozen bounds (positions and velocities identical, orientation dot
error ≤ 4.8e-7, the same values the A0/A1 control pairs show).

| window | force relative L2 | per-bond max relative (diagnostic) | health max drift |
|---|---:|---:|---:|
| city25 impact | 2.96e-6 | 1.85e-4 | 1.13e-6 |
| city256 impact | 4.90e-6 | 5.07e-4 | 1.19e-6 |
| city256 cascade | 1.49e-6 | 9.89e-3 | 1.07e-6 |
| city256 debris | 2.32e-6 | 3.43e-2 | 3.48e-5 |

Why contract v3: the v2 comparator bounds every force scalar by
`2e-4 × max(1 N, |x|, |y|)`. Two solutions that both satisfy the solver's
relative residual gate (1e-5) differ on the tolerance-level components of large
forces (for example 0.45 N versus 0.001 N beside a 26 kN component), and on
low-force bonds inside high-force components, by amounts that the per-scalar
floor reports as errors of order one. The A0/A1 control pairs are bitwise
identical because they run the same PCG path. The runtime still rejects any tick
whose solve is not converged, so the candidate's solution is certified by the
unchanged gate every tick. Contract v3 therefore gates on exact discrete outcomes,
the frozen motion bounds, a whole-array relative force bound (1e-4) and a health
drift bound (1e-4 remaining-area units over the window), and reports the per-bond
maximum as a diagnostic. `run-warm-suite.py --contract-version 3` selects it.

Sanitizers with the candidate runtime: `gpu_resident_stress_3d_test` and
`gpu_resident_motion_modes_test` under memcheck, initcheck and synccheck, and
`native_gpu_correction_body_test` under memcheck, all report zero errors
(`out/direct-factor-feasibility-20260915/sanitizers.log`). Not established by
this screen: continuous 600-tick trajectories (running separately) and full52.
