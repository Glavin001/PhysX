# N30 medium connected-component algorithm — preparation, 2026-09-13

Isolated commit `8634c43c975029148b7117bd5cbff6eb763f8fda`, parent/control `13b11af2e0aeabf4e0070931fbd8a060f383dfaf`. Source is prepared and committed, **not built, executed or promoted**. It is independent of unpromoted N29b. Main source, index and installed SDK remain untouched.

The hypothesis removes cooperative multilevel traversal and grid-wide synchronization for components with1025–4096 active nodes, selecting the existing local mixed-block PCG implementation. The single shared boundary also controls hierarchy-tail construction and final result merging. Components above4096 retain the old grid path. The empty cooperative launch remains as a small status publication; there is no new host observation or synchronization.

Evidence: qualified N20 tower64-cold108.434ms mean/111.349ms max; dense12-cold31.329/33.495ms. These have2304 and1584 active nodes. The earlier labeled tower profile has115.335ms in persistent stress solving, of150.776ms total. The recorded full city256 idle/impact/debris means65.998/240.893/382.883ms are separate controls; original380-node city components do not change dispatch. These dated cohorts suggest the target, not a new speedup.

All component vectors use global node-capacity storage; block-local reductions have fixed thread-count scratch. Classification, component iteration, hierarchy selection and result merging use the same constant. The existing level-zero fine-solver marker bypasses recursive hierarchy levels when all components qualify. Current inputs, actual gradient/force/material gates and iteration caps remain unchanged. Preconditioner and reduction order change: equivalent iteration history is not assumed, physical fidelity remains required.

Independent additional tests extend existing analytic path-eigenmode force oracles to12/4096/4100-node contiguous and permuted components, including merged iteration-cap rejection and subnormal convergence. A4112-node component splits into2056 and1028-node components across quiet/load transitions and verifies exact settled reuse. Original tests remain unchanged. These new tests have not run.

Planning hypothesis:40–90ms saved per tower tick,10–20ms per dense tick; zero expected for original380-node city components. Confidence low-to-medium; no measured saving. More iterations, cap failure, physical mismatch or lost parallelism would refute it. A single bounded size policy is tested, not a tuning sweep.

Execution after the existing N29b exclusive timing job is terminal:

```sh
python3 out/n30-medium-components-20260913/build.py
python3 out/n30-medium-components-20260913/build-oracles.py
# Use the existing exclusive wrapper pattern; verify empty GPU and preserve restoration.
python3 out/n30-medium-components-20260913/run-screen.py
```

Screen requires original numerical tests, both-arm medium boundary memory/init/sync tests, targeted restored memory/physical checks, then the fixed seven-case light suite plus both tower states and dense-warm. Scripts refuse output overwrite and preserve module hashes. Finalists still need confirmation/full52/warm/trajectory gates. Build is now queued in `out/n30-medium-components-20260913/coordinator.json` after the N29b full52 and flagged-regression repeat finish and restore desktop. The coordinator holds the benchmark lock during CPU builds. GPU screening is not scheduled; no competing work may overlap timing.
