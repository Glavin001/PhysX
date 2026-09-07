#!/usr/bin/env python3
"""Regenerate the retained qualification report from exit records and full logs."""
import json
from pathlib import Path
HERE=Path(__file__).resolve().parent
record=json.loads((HERE/'validation.json').read_text())
rows=[]
for test in record['tests']:
    log=(HERE/test['log']).read_text()
    passed=test['exit_code']==0 and all(marker in log for marker in test.get('required_markers',[]))
    rows.append({**test,'passed':passed})
result={'schema':1,'tests':rows,'all_test_gates_passed':all(t['passed'] for t in rows),
        'full_plan_qualified':False,'performance_improvement_established':False}
(HERE/'results.json').write_text(json.dumps(result,indent=2)+'\n')
text='''# GPU projected stress solver — WIP qualification

**The full plan is incomplete. The current integrated runtime preserves the frozen
wall result, but the new multilevel solve is much slower and larger 3D tests
still fail zero-load convergence and supported bond-force accuracy. No 8 ms improvement is established.**

## Implemented

- GPU connectivity now retains the existing union operation's spanning-tree edges.
  GPU Euler-tour scans derive coordinates from actual bond offsets, then construct
  and validate each component's translation/rotation null space. No CPU graph or
  matrix is assembled. Cyclic offset inconsistencies retain their real moment constraints.
- Projected CG consumes that null space and one resident symmetric V-cycle, replacing
  squared-cycle CGLS. An initial projected gradient step avoids hierarchy work for
  simple loading modes; PCG restarts when the fixed preconditioner begins.
- Double accumulation of the node solution avoids losing small corrections beside
  large warm-start cancellation. Final bond recovery combines the old force and
  node correction before converting once to float. Directions/residuals remain floats.
- Free trees with exactly zero input have a certified unique zero bond-force solution.
  Their unnecessary warm-start solve is deleted. Cyclic or supported components,
  equal/opposite nonzero loads, and nonzero subnormal inputs do not get this shortcut.
- GPU motion-mode construction rejects unrepresentable exact offset sums explicitly;
  it does not silently assume six free modes. This precision-range limitation remains.

## Qualification evidence

These are numerical stress nodes/chunks and bonds, not individually moving rigid
bodies. Unit tests contain no projectile, collision, resimulation, or rendering.
Iteration counts are not simulation timings. Existing tolerances and iteration
limits were not loosened. The original analytic tests only gained failure diagnostics.

| Check | Workload / scope | Result |
|---|---|---|
'''
for t in rows:text+=f"| {t['name']} | {t['scope']} | {'✅ Pass' if t['passed'] else '❌ Fail'} |\n"
text+='''
## Integrated wall regression

The actual rebuilt PhysX destruction runtime ran the frozen 10-second audit:
444 chunks, 896 bonds, one projectile, physical timestep 1/60 s, correction limit one.
It retained 398 supported chunks, detached 46, broke 199 bonds and ended with 43 clusters.
Both wall holes, projectile clearance at step 39, the exact topology signature,
COM continuity and collision/render agreement passed. This heavy observation run
is a quality audit, not an isolated complete-step performance qualification.
See `wall-quality.json` and `wall-capture.json` for the checked quantities and executable hashes.

## Actual 256-building performance — failed

The automated report in `../projected-cg-impacts-256/report.html` contains the full
untraced complete-step timing and a separate phase capture. Workload: 256 buildings,
113,664 chunks, 229,376 bonds, 256 simultaneous projectiles, sleep disabled,
timestep 1/60 s, maximum one correction per step. Two measured runs of three seconds
retain all 180 steps each, including startup and impacts; one separate warm-up is excluded.
This short diagnostic does not satisfy five runs of 60 seconds or the endurance gate.

Complete-step mean: 147.574 / 147.645 ms; peaks: 295.421 / 294.169 ms.
198 of 360 measured steps exceeded 8 ms. The separate scoped run averaged 147.814 ms,
with 138.419 ms in the GPU stress stage. CPU waiting overlaps that work and is not an
additional GPU phase. All captured stress solves converged; peak iterations were 96.
The generated report retains all counters, peak-step context and scope limitations.

## Tried, rejected and removed

- Double directions, residuals and matvec: did not resolve the long-chain zero-load
  convergence or reloaded-force failure. Extra vector storage and arithmetic removed.
- Two symmetric smoothing steps instead of one: improved some iteration counts but
  did not fix the original quality failures. Extra smoothing removed.
- Additional relative preconditioned-energy stopping check: did not fix the reloaded
  force error. Removed; the original gradient stopping criterion remains.
- The earlier archived right-FGMRES candidate and squared-cycle CGLS are not alternate
  runtime choices. Reference-only test tools are not production execution switches.

Full failure logs are retained, including the CPU warm-start oracle's zero-load
failure. The new 3D comparison solves its independent CPU oracle from zero for each
input and exercises warm starts in the native solver. Both oracle and native failures
remain fatal to their checks; the runner reports independent fixtures after a failure.

## Remaining / next

1. Replace the expensive small-component multilevel execution with a measured,
   qualified resident CUDA implementation; retain shared equations and exact activity checks.
2. Resolve the larger cyclic zero-load convergence and supported force-accuracy failures without clearing self-stress,
   relaxing tolerances, raising the test's iteration cap, or accepting incomplete work.
3. Diagnose the race-check instrumented target exit 11; zero reported hazards before
   an incomplete run is not a pass. Memory and synchronization checks passed.
4. Remove superseded native workspace/unused squared-cycle preparation after selecting
   the qualified implementation; retain historical algorithms only in reference targets.
5. Re-run wall parity and 256-building complete-step timing after each candidate wins.
6. Finish GPU lifecycle/ownership/conditional correction scheduling, validated structural
   reuse, required fidelity audits, five-by-60-second timing and 10-minute endurance.

`validation.json` records commands, observed exit codes and artifact/source hashes.
`generate_report.py` regenerates this report and `results.json` from those records
and checks the required completion markers; it does not turn failed runs into passes.
'''
(HERE/'report.md').write_text(text)
print(HERE/'report.md')
