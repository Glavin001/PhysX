#!/usr/bin/env python3
"""Publish compact, reproducible results; keep all raw evidence in ignored out/."""
import hashlib
import json
from pathlib import Path
import statistics as st

ROOT=Path(__file__).resolve().parents[3]
OUT=ROOT/'reports/destruction-removal-implementation-20260913'


def span(values):
    values=list(values)
    return f'{min(values):.3f}' if len(values)==1 else f'{min(values):.3f}–{max(values):.3f}'


def main():
    OUT.mkdir(parents=True,exist_ok=True)
    lines=['# Destruction removal: initial implementation results','',
           '2026-09-13. Stopped at the user’s request. No candidate has replaced the selected runtime. '
           'The complete five-part plan is not implemented: the batch ownership transaction, native prepared solving '
           'still require native implementation and qualification. Producer-owned load detection now has '
           'a built native candidate; material validity remains separate and unfinished.','',
           'The two native topology candidates pass the nine-case physical screen, continuous work histories, '
           'selected Systems/Compute comparisons, and focused CUDA topology/memory checks. Neither establishes '
           'a substantial sustained-destruction speedup. Retain them as isolated, unpromoted architectural work. '
           'Do not combine them or infer additive savings from these separate comparisons.','',
           'Source policy: baseline `13b11af2e0aeabf4e0070931fbd8a060f383dfaf`, runtime '
           '`d5770a80c2f4686b0ad311edcbfc8e128d14baee64653bf5e032305c12cf9354`. '
           'Experimental source is local and uncommitted per the user’s commit policy; each native candidate '
           'has a complete isolated source tree, patch SHA256, compiler commands and dependency hashes. '
           'Raw reports and captures below require the local ignored `out/` archive.','',
           '## Prepared parent-factor experiment','',
           'Implemented a private RAII cuDSS operator and a native CUDA PCG replay with current loads, surviving '
           'bonds and recovered FP32-force verification. The preconditioner is '
           '`R A_parent^-1 R^T`; it supplies no cached physical answer. Free components are excluded. '
           'Independent CPU Cholesky, restriction/symmetry checks and all 300 saved GPU output systems '
           'pass the captured squared-gradient acceptance check. This does not qualify material behavior '
           'or physical trajectories. The fractured approximate force field differs from the strong reference '
           'by up to 0.00819 in the recorded scaled coordinate diagnostic, so do not call all numerical gates passed.','',
           '| Captured city25 stress pass | Dynamic nodes per structure / loads | FP64 block-Jacobi updates | Parent-factor updates | First GPU batch, ms | Subsequent GPU batches, ms | GPU context/input/factor setup, ms |','|---|---:|---:|---:|---:|---:|---:|']
    parent=ROOT/'out/prepared-remnant-20260913'
    oracle=json.loads((parent/'inputs-v3/report.json').read_text())
    for case in oracle['cases']:
        step=case['solve'];gpu=json.loads((parent/f'gpu/solve-{step}.json').read_text())
        counts=lambda method: f"{min(r['methods'][method]['updates'] for r in case['components'])}–{max(r['methods'][method]['updates'] for r in case['components'])}"
        lines.append(f"| {'First impact' if step==0 else 'Fractured correction'} | {case['matrices']['A']['rows']//6} / 25 | {counts('block_jacobi')} | {counts('restricted_parent')} | {gpu['solve_ms'][0]:.3f} | {span(gpu['solve_ms'][1:])} | {gpu['setup_ms']:.3f} |")
    lines += ['', 'These are mathematical batch timings, not complete simulation ticks. All first-use results remain '
              'visible. CPU work comparisons use the 8,192-update limit; the earlier 256-limit and arbitrary '
              'restart pilots are preserved under `inputs/` and `inputs-v2/` and are not production convergence failures. '
              'The GPU runs completed below 256 updates, so correcting that diagnostic cap does not alter those outputs.','',
              'The new Systems capture places about 26.3 ms in GPU kernels per fractured batch; approximately '
              '23.0 ms is forward/back substitution. The ordinary unprofiled batch costs 30.7–30.8 ms after first use. '
              'Host polling is therefore not the sole cause. Hold the full-factor-per-iteration route out of runtime '
              'integration; a CUDA Graph alone cannot remove the triangular arithmetic.','',
              'Evidence: `out/prepared-remnant-20260913/{inputs-v3,gpu,profile}`. '
              'GPU source matching its recorded hashes is retained in `gpu/probe-source/`.','',
              'A subsequent independent Galerkin screen reuses immutable asset modes and forms the **current** '
              'coarse operator. On three loads per pass, 32 modes take 46 first-impact and 101–112 correction '
              'updates; 128 modes take 21 and 79–80. All twelve captured-gradient checks pass. This is a '
              'new work hypothesis, not an application win. Native preparation, memory, material and trajectory '
              'qualification remain required. See `out/prepared-remnant-20260913/coarse-v2/`.']
    lines += ['', 'The 32-mode GPU replay passes all 300 captured residual checks. First-impact batches cost '
              '5.107 ms first use and 4.277–4.303 ms subsequently; fractured batches cost 10.495 ms first use '
              'and 9.627–9.752 ms subsequently. GPU context/input setup costs 169.372/147.779 ms, excluding '
              'the separately recorded host mode preparation. Systems attributes approximately 7.85 ms to '
              'GPU kernels per fractured batch, including sparse products and dense coarse expansion. '
              'This is cheaper than the full-parent replay but is not a demonstrated improvement over the '
              'native component solver. Evidence: `coarse-gpu32/`, `coarse-profile32/`.','',
              'A sparse rigid-aggregate alternative passes twelve independent current-gradient checks, '
              'including explicit internal-bond rigid-mode cancellation. Eight aggregates require '
              '78 impact / 145–148 correction updates; 32 aggregates require 59 / 105. These CPU work '
              'screens have no GPU or application timing qualification. Evidence: `aggregate-screen/`. '
              'The rigid-mode design was checked against [PETSc aggregation guidance](https://petsc.org/main/manual/ksp/).']
    lines += ['', '## Reuse symbolic structure through fractures','',
              'Implemented a prepared symbolic envelope and serialized numeric-factor epochs. The pattern '
              'includes all per-bond structural products, including entries which cancel numerically before '
              'a cut. Removed or unsupported coordinates become independent identity rows with zero loads. '
              'The active block is checked against the exact current operator. Free components remain excluded. '
              'This is a native C++/CUDA library probe, not integrated simulation behavior.','',
              'Alternating the actual city25 impact/correction operators reuses symbolic analysis while '
              'replacing current coefficients and current loads. All 300 outputs pass recovered-force '
              'residual checks and the existing strong reference; worst scaled reference error is '
              '5.725e-11 and worst residual threshold ratio is 0.008280.','',
              '| Captured operator / 25 loads | First numeric factor / solve, ms | Subsequent factor, ms | Subsequent solve, ms |',
              '|---|---:|---:|---:|']
    refactor=json.loads((parent/'refactor-gpu/metrics.json').read_text())
    for step in [0,1]:
        rows=[r for r in refactor['numeric_epochs'] if r['solve']==step]
        lines.append(f"| {'Impact' if step==0 else 'Fractured correction'} | {rows[0]['factor_ms']:.3f} / {rows[0]['solve_ms']:.3f} | {span(r['factor_ms'] for r in rows[1:])} | {span(r['solve_ms'] for r in rows[1:])} |")
    lines += ['', f"Context/input/handle setup is {refactor['setup_ms']:.3f} ms; one symbolic analysis costs {refactor['analysis_ms']:.3f} ms. "
              'No preparation cost is hidden in a full-tick claim. The measured factor-update-plus-solve '
              'is about 1.39–1.45 ms after library first use. For this default cuDSS ordering, '
              '`REFACTORIZATION` performs numerical factorization again; the removed work is repeated '
              'symbolic analysis, not an incremental Cholesky downdate. '
              '[NVIDIA phase definitions](https://docs.nvidia.com/cuda/cudss/types.html). '
              'Evidence: `refactor-inputs/`, `refactor-gpu/`.','',
              '## Large debris changes the sharing strategy','',
              'An exact operator-only census excludes positive health magnitude, loads and warm guesses '
              'from coefficient identity. It retains complete node/edge ordering, weights, lever arms, '
              'boundary identity and bond liveness. This uses saved native captures, with no new GPU census.','',
              '| Scenario / pass | Anchored components | Distinct anchored operators | Largest sharing group | Iterative node work in shared operators |',
              '|---|---:|---:|---:|---:|']
    census=json.loads((parent/'operator-census.json').read_text());seen=set()
    for case in census['cases']:
        key=case['scenario'],case['solve']
        if key in seen:continue
        seen.add(key)
        fraction=100*case['work_in_shared_anchored_operators']/case['anchored_iteration_nodes'] if case['anchored_iteration_nodes'] else 0
        lines.append(f"| {key[0]} / {key[1]} | {case['anchored_components']} | {case['unique_anchored_operators']} | {case['largest_share']} | {fraction:.2f}% |")
    lines += ['', 'Consequently, sharing one numeric factor principally addresses intact/initial-impact '
              'cases. Late debris needs many different numeric factors, shared symbolic structure and '
              'validity that avoids rebuilding unchanged factors. Operator sharing is not answer sharing.','',
              'Implemented the uniform-batch feasibility path for all 256 original assets, preserving '
              '255/262 anchored components in the two captured debris passes. Unsupported/free rows are '
              'identities and their output is verified zero. All 3,102 recovered-force checks pass. '
              'The initial supplementary 1e-7 reference check failed six repeated outputs for one component: '
              'an 80-digit refinement showed that the FP64 CPU reference caused that discrepancy. The '
              'GPU error against the refined reference is 5.508e-8. The original failure and refined '
              'qualification remain separately saved; no acceptance threshold was loosened.','',
              '| Debris pass / 256 distinct matrix slots | First numeric factor / solve, ms | Subsequent all-factor rebuild, ms | Subsequent solve, ms |',
              '|---|---:|---:|---:|']
    batch=json.loads((parent/'batch-gpu/metrics.json').read_text())
    for step in [0,1]:
        rows=[r for r in batch['numeric_epochs'] if r['solve']==step]
        lines.append(f"| {step} | {rows[0]['factor_ms']:.3f} / {rows[0]['solve_ms']:.3f} | {span(r['factor_ms'] for r in rows[1:])} | {span(r['solve_ms'] for r in rows[1:])} |")
    lines += ['', f"Batch setup is {batch['setup_ms']:.3f} ms, symbolic analysis {batch['analysis_ms']:.3f} ms. "
              'Counted live/peak cuDSS allocations are 289,250,388 bytes; this excludes application '
              'input/output buffers, driver/context memory and CPU storage. There is no application '
              'speedup claim. Rebuilding all factors every pass is not attractive; reuse or a cheaper '
              'factorization is required. Evidence: `batch-inputs/`, `batch-gpu/quality.json` (original '
              'supplementary failure), `batch-gpu/quality-strong.json`, `batch-reference-62231/`.','',
              'The FP32-factor/FP64-correction experiment passes all 3,102 unchanged residual/reference '
              'checks, but its fixed ten corrections make it slower than the FP64 replay. This changes '
              'internal factor precision, not the accepted quality budget. Native integration, recovery, '
              'per-operator invalidation and material/trajectory qualification remain outstanding.','',
              '| FP32-factor debris pass | First factor / ten corrections, ms | Subsequent factor, ms | Subsequent ten corrections, ms |',
              '|---|---:|---:|---:|']
    refinement=json.loads((parent/'refinement-gpu-v2/metrics.json').read_text())
    for step in [0,1]:
        rows=[r for r in refinement['numeric_epochs'] if r['solve']==step]
        lines.append(f"| {step} | {rows[0]['factor_ms']:.3f} / {rows[0]['solve_ms']:.3f} | {span(r['factor_ms'] for r in rows[1:])} | {span(r['solve_ms'] for r in rows[1:])} |")
    lines += ['', f"Context/input setup is {refinement['setup_ms']:.3f} ms; analysis {refinement['analysis_ms']:.3f} ms. "
              'First-use costs are retained, including 733.473 ms for the first numeric factor. Counted '
              'library peak storage is 148,556,980 bytes, excluding application buffers/context/host. '
              'The predeclared sub-20 ms complete batch hypothesis is refuted by factor cost alone. '
              'Do not pursue correction-count tuning as the primary route. Reuse current factors and '
              'update only changed operators instead. Evidence: `refinement-gpu-v2/`. The original '
              '`refinement-gpu/` admission failed safely because another thread owned the GPU lease.','',
              '## GPU-owned current coefficients','',
              'Implemented an immutable per-bond contribution plan and a GPU coefficient producer. '
              'It reads current bond liveness and anchored membership; producer-owned dirty flags '
              'gate each asset. Unchanged coefficients persist. Unsupported coordinates become '
              'identity rows, preserving the fixed symbolic envelope. Loads do not invalidate factors. '
              'Dirty flags are cleared only by a successful factor consumer, not by this producer.','',
              'The full 256-asset captures pass five transition checks: all first-state operators, '
              'unchanged products despite new inputs, only even assets changed, remaining odd assets '
              'changed, then restoration of the first state. Each state contains 5,326,848 coefficients; '
              'every coefficient exactly matches independent assembly. FP32 projection also matches. '
              'Normal execution plus asynchronous memcheck, initcheck and synccheck pass.','',
              '| Coefficient producer epoch | Dirty assets | Producer host elapsed including stream wait, ms |',
              '|---|---:|---:|']
    producer=json.loads((parent/'coefficient-producer/plain/metrics.json').read_text())
    for row in producer['epochs']:lines.append(f"| {row['epoch']} | {row['dirty_assets']} | {row['producer_ms']:.3f} |")
    lines += ['', f"Context/host-plan/input setup is {producer['setup_ms']:.3f} ms. "
              'These five samples validate mechanism and bounds, not a statistically qualified speedup. '
              'The producer is not yet connected to native factor execution. '
              'Evidence: `coefficient-producer/`, including frozen source and all memory-check outputs.']
    lifecycle=json.loads((parent/'lifecycle-phase-only/campaign.json').read_text())
    assert lifecycle['status']=='complete'
    lines += ['', '## Lifecycle exposure without collector injection','',
              'A bounded new measurement runs the identical frozen phase-enabled executable without '
              'Nsight injection, bracketed by plain controls. Both scenarios pass full physical comparison. '
              'Only the first tick records phases; two stress/correction passes are summed within that tick. '
              'The phase callback still allocates, takes timestamps and records rows. These are instrumented '
              'scopes, not an overhead-corrected production decomposition. No estimated overhead is subtracted.','',
              '| Scenario / arm | Full-step mean / maximum, ms | 60 Hz misses | Integrated / completion, ms | Restore mean, ms |',
              '|---|---:|---:|---:|---:|']
    for case in lifecycle['cases']:
        for arm,row in case['runs'].items():
            lines.append(f"| {case['scenario']} / {arm} | {row['mean_ms']:.3f} / {row['max_ms']:.3f} | {row['over_60hz']}/{row['n']} | {row['stages_ms']['simulate_fetch_ms']:.3f} / {row['stages_ms']['completion_ms']:.3f} | {row['restore_ms']:.3f} |")
    lines += ['', 'These two-sample process means are diagnostic context, not replacements for the repeated '
              'production baseline. Every first-use sample remains included.','',
              '| Scenario | Migration calls | Shape migration thread CPU, ms | Refilter wall, ms | Contact retirement wall, ms | Owner registration wall, ms | Actor links wall, ms |',
              '|---|---:|---:|---:|---:|---:|---:|']
    for case in lifecycle['cases']:
        p=case['phases'];values=[p['GpuDestruction.migrateDetail.'+name]['wall_ms'] for name in ['refilter','retireContacts','registerOwner','actorLinks']]
        lines.append(f"| {case['scenario']} | {p['GpuDestruction.migrateDetail.refilter']['count']} | {p['GpuDestruction.applyDetail.migrateShapes']['thread_cpu_ms']:.3f} | "+' | '.join(f'{v:.3f}' for v in values)+' |')
    lines += ['', 'For large debris, historical collector-enabled migration was about 81.47 ms thread CPU; '
              'the new phase-only scope is 28.144 ms. Historical refilter/register/actor-link scopes '
              'were roughly 13–15 ms each; phase-only values are 0.810/2.106/1.290 ms. Contact retirement '
              'still costs 10.234 ms instrumented wall time. These different diagnostic processes do not '
              'provide a calibrated profiler-overhead subtraction, but they refute treating the previous '
              'tiny-operation scopes as production exposure. Re-rank lifecycle work toward actual contact '
              'retirement and required body/manager registration. N26/N27 lookup-only results remain closed. '
              'Evidence: `lifecycle-phase-only/`; historical `out/destruction-baseline-20260913/cpu-full/`.']
    lines += ['', '## Selective numeric refactoring: rejected','',
              'Only 127 of the 256 original-asset operators change between the captured debris passes. '
              'A GPU equality census identifies that subset; all current right-hand sides are still supplied. '
              'The cuDSS mask prototype completes but **fails 1,402 of 3,102 numerical output checks**. '
              'Every failing component belongs to an unchanged operator slot. After the masked update, '
              'all 129 unselected slots produce zero solutions; 128/127 contain anchored components in '
              'the two passes. The exact internal cause has not been established. Do not call this a '
              'library bug or reuse those outputs in simulation.','',
              'Even its unqualified timings are unattractive: selective factor updates cost '
              '43.48–43.76 ms, with 5.51–5.55 ms current solves and 0.24–0.42 ms detection/readback. '
              'The first factor/solve costs 74.43/10.52 ms; setup 312.05 ms and analysis 71.19 ms. '
              'No selective-factor speedup is claimed because correctness failed.','',
              'Original API failures are preserved. The installed library requires an integer array '
              'of `batch * sizeof(int)` bytes, matching its shipped header; current '
              '[online docs](https://docs.nvidia.com/cuda/cudss/types.html) describe an int64 bitmask. '
              'The installed library also requires mask allocation to be requested before analysis. '
              'Its diagnostic log identified those requirements. This is not evidence that a newer '
              'cuDSS version behaves the same. The native runtime remains unchanged. '
              'Evidence: `selective-gpu/`, `selective-gpu-v2/`, `selective-gpu-v3/`, '
              '`selective-api-diagnostic/`, `selective-gpu-v4/`, `selective-gpu-v5/quality-strong.json`.','',
              '## Dense prepared inverse-factor application','',
              'Implemented replacement of repeated parent triangular solves with '
              'two dense products using a fixed rounded inverse Cholesky factor. Its SPD form is '
              '`R_parent^T R_parent`, restricted to current anchored coordinates. Current operators, '
              'loads, FP64 outer iteration and recovered FP32-force acceptance remain unchanged. '
              'This follows the observed triangular-solve bottleneck; it is not a parameter sweep. '
              'The initial implementation uses prescribed FP32 arithmetic with '
              '[cuBLAS pedantic math](https://docs.nvidia.com/cuda/cublas/), with no reduced-mantissa '
              'Tensor Core mode. All 300 captured residual checks pass (worst accepted threshold ratio '
              '0.931762); native material and physical qualification remain pending.','',
              '| Captured city25 pass / 25 current loads | Updates | First batch, ms | Later batches, ms | GPU setup, ms |',
              '|---|---:|---:|---:|---:|',
              '| Initial impact | 3 | 160.494 | 0.556–0.569 | 196.641 |',
              '| Fractured correction | 60–65 | 171.819 | 12.474–12.910 | 174.727 |','',
              'Host factor preparation separately costs 631.718 ms and creates a 20,793,600-byte immutable '
              'FP32 inverse Cholesky factor. It is not free cold-restore state. Systems and four pinned '
              'NCU launches pass their own 150 captured residual checks. Across six correction batches, '
              'the two dense products consume 15.027/25.909 ms summed GPU duration: about 6.823 ms per '
              'batch. Sparse products add about 1.603 ms per batch. These are summed kernel durations '
              'from a separate diagnostic replay, not normal full-step costs.','',
              'The transposed product executes 337.2 million FP32 FMA instructions per captured launch '
              'versus 170.2 million for the non-transposed product. Source names show 128×64 versus '
              '128×32 output tiles for only 25 load columns. This is evidence of padded arithmetic, '
              'not a generic occupancy diagnosis. Its measured launch duration is 70.2–70.6 us versus '
              '41.0–41.2 us. A separately stored transpose can test removing that padding without '
              'changing the mathematical preconditioner; it adds another 20.8 MB of prepared data. '
              'Evidence: `dense-parent/`, `dense-parent-gpu/`, `dense-parent-profile/`, '
              '`dense-parent-counters/`. No application gain is established.','',
              'The installed CUDA 13.4 header exposes BF16x9 emulation, but the '
              '[cuBLAS support table](https://docs.nvidia.com/cuda/cublas/#floating-point-emulation) '
              'limits FP32 BF16x9 to compute capabilities 10.0/10.3. This GPU is 12.0; merely selecting '
              'that enum is not a supported acceleration experiment here.']
    lines += ['', '### Layout experiment and final force-compatibility gate','',
              'The prepared-transpose implementation passes 300 residual checks and 150 selected-counter '
              'checks, but is not retained. Impact replay costs 154.761 ms first use and 0.569–0.609 ms '
              'later; correction costs 167.052 ms first use and 13.382–13.843 ms later. Setup is '
              '253.159/239.650 ms, including the extra layout/upload but excluding the original host factor '
              'preparation. It adds 20,793,600 device bytes. The prior one-layout correction was '
              '12.474–12.910 ms. These separate short replay cohorts establish no application benefit.','',
              'Counters confirm the proposed arithmetic removal: the second product drops from '
              '337.2 to 170.2 million FFMA instructions, and selected launch duration drops from '
              '70.2–70.6 to 55.3–56.1 us. However, its measured DRAM traffic rises from 7.4–7.6 MB '
              'to 21.1 MB. Reduced instructions therefore do not imply lower complete replay cost. '
              'The extra layout was removed from the working prototype; its frozen source and outputs '
              'remain under `dense-transpose-gpu/` and `dense-transpose-counters/`.','',
              'A final offline check compares the original dense-parent outputs with the saved native '
              'normalized force outputs using the exact, revalidated physical export mapping and unchanged '
              '2e-4 force-compatibility bound. **None of the 300 output systems passes that compatibility '
              'gate**, despite passing equilibrium-residual acceptance. Worst scaled differences are '
              '0.588 for impact and 1.481 for correction. The native approximation is not thereby proven '
              'a stronger mathematical reference; this is evidence that residual convergence alone cannot '
              'qualify a drop-in replacement. No material or trajectory gate has been waived. '
              'Evidence: `dense-parent-gpu/native-force-compatibility.json`; checker '
              '`tools/diagnostics/destruction-prepared-factor/compare-native-forces.py`.']
    native_cases=[
        ('local-topology','Local connectivity','Preserves union/find parents and spanning-tree flags for unchanged old components. Changed components still rebuild; global scheduling/compaction and other derived structures remain.'),
        ('prepared-neighbors','Topology-owned operator adjacency','Removes cacheNativeOperatorNeighbors from every active component solve. A topology producer refreshes those entries only on initial setup or changes to their old component. All other solve mathematics is unchanged.')]
    producer_base=ROOT/'out/input-producer-20260913-v2'
    producer_screen=producer_base/'representative/screen.json'
    if producer_screen.exists() and json.loads(producer_screen.read_text())['status']=='complete':
        native_cases.append(('input-producer-v2','Producer-owned exact load changes',
            'Moves the exact six-float input comparison to each node’s final load writer and removes the '
            'consumer’s second full input scan. Contact removal receives fresh base loads. Existing topology, '
            'settings and accepted-equilibrium validity gates remain. Stable per-chunk contact order is unchanged; '
            'rates are cleared before contact routing because contacts can write both endpoints. '
            'Material evaluation remains active, including constant-stress damage.'))
    for folder,title,mechanism in native_cases:
        base=producer_base if folder=='input-producer-v2' else ROOT/f'out/{folder}-20260913'
        screen=json.loads((base/'representative/screen.json').read_text());build=json.loads((base/'build/build.json').read_text())
        assert screen['status']=='complete'
        lines += ['',f'## {title}','',mechanism,'',
                  f"Source patch SHA256: `{build['candidate_patch_sha256']}`. Full representative turnaround: "
                  f"{screen['wall_seconds_excluding_lock_queue']:.3f} s; desktop restored. "
                  'Each comparison uses unchanged frozen inputs/checker, one GPU job at a time, and includes '
                  'the first full tick in every process. Restore/checks/profiling remain outside tick latency.','',
                  '| Scenario | A full-step mean range, ms | B full-step mean range, ms | A / B observed maximum, ms | A / B 60 Hz misses / ticks | Descriptive A−B, ms |',
                  '|---|---:|---:|---:|---:|---:|']
        for case in screen['scenarios']:
            arms={arm:[v for key,v in case['runs'].items() if key.startswith(arm)] for arm in 'AB'}
            a,b=arms['A'],arms['B']
            misses=lambda rows:f"{sum(r['over_60hz'] for r in rows)}/{sum(r['n'] for r in rows)}"
            lines.append(f"| {case['scenario']} | {span(v['mean_ms'] for v in a)} | {span(v['mean_ms'] for v in b)} | {max(v['max_ms'] for v in a):.3f} / {max(v['max_ms'] for v in b):.3f} | {misses(a)} / {misses(b)} | {case['saved_ms']:+.3f} |")
        lines += ['', 'A is the frozen baseline; B is this candidate. Means span independently started processes. '
                  'A−B is descriptive, not a confidence-qualified speedup. The two continuous cases are 180-tick '
                  'trajectories; the other seven are independent restored ticks. Their means are not pooled.','',
                  '| Scenario | A / B command, ms | A / B integrated physics/stress, ms | A / B completion, ms | A / B mean restore, ms |',
                  '|---|---:|---:|---:|---:|']
        for case in screen['scenarios']:
            arms={arm:[v for key,v in case['runs'].items() if key.startswith(arm)] for arm in 'AB'}
            fields=[]
            for key in ['command_ms','integrated','completion_ms']:
                fields.append(' / '.join(f"{st.mean(r['stages_ms'].get('simulate_fetch_ms',r['stages_ms'].get('physics_step_ms')) if key=='integrated' else r['stages_ms'][key] for r in arms[arm]):.3f}" for arm in 'AB'))
            restore=' / '.join('—' if arms[arm][0]['restore_mean_ms'] is None else f"{st.mean(r['restore_mean_ms'] for r in arms[arm]):.3f}" for arm in 'AB')
            lines.append(f"| {case['scenario']} | {' | '.join(fields)} | {restore} |")
        lines += ['', 'Integrated physics/stress includes transfers, synchronization, material evaluation, required '
                  'correction and second stress. GPU stress durations are overlapping attribution, not another '
                  'additive stage. The legacy zero stress field is not used. Per-process initialization, first-use, '
                  'stage, spread and peak-state records remain in `representative/screen.json`.','',
                  f'Evidence root: `{base.relative_to(ROOT)}/`. See `build/`, '
                  '`representative/screen.json`, `representative/systems/city256-late-debris/`, '
                  '`representative/ncu/`.']
        if folder!='input-producer-v2':
            lines += ['','CUDA kernel checks cover 80 topology transactions on chains, shared-support '
                  'cycles, small islands and a 100,000-node sparse-damage world; memcheck, initcheck and synccheck pass. '
                  'These focused tests do not substitute for full52 finalist qualification.']
        if folder=='local-topology':
            lines += ['', 'The large sparse-damage test verifies 1,478,853 unchanged node-transactions and '
                      '1,966,470 unchanged live-edge-transactions across its updates. These are predicate exposures '
                      'and preserved-state checks, not GPU instruction counters or milliseconds saved. '
                      'The full-step continuous destruction difference is only +0.028 ms. No substantial win established.']
        elif folder=='prepared-neighbors':
            lines += ['', 'The initial chain signal is 0.541 ms slower descriptively. A subsequent independent '
                      '20/20/20 confirmation does not reproduce it: A means 7.157/7.382 ms, B 7.249 ms; '
                      'maxima A 9.636/10.125 ms, B 8.118 ms; zero 60 Hz misses in all 60 ticks. '
                      'Integrated stages average 7.069/7.058 ms and completion 0.200/0.191 ms for A/B. '
                      'Physical checks and 492-iteration histories agree. This is not proof of a speedup '
                      'or tight equivalence. Evidence: `chain-confirm/`. Full52 now passes all 3,120 '
                      'physical tick comparisons, in 1,453.370 seconds including setup/restores/checks. '
                      'Mixed performance and several regression signals prevent promotion. '
                      'Continuous destruction differs by only +0.040 ms. The apparently larger cold-idle/debris '
                      'differences are not yet confirmed; first-use/control variation is substantial. '
                      'Initial adjacency preparation now belongs to topology creation, so initialization/restore '
                      'cost must remain visible in any cold-start claim.']
            full=json.loads((base/'full52/matched/report.json').read_text())
            assert full['status']=='complete' and len(full['scenarios'])==52
            lines += ['', '### Full52 adjacency qualification','',
                      'All first-use ticks are included. Each row is 20 A-before, 20 B and 20 A-after '
                      'ticks. These descriptive intervals are not simultaneous causal confidence bounds. '
                      'Chain32-warm, stimulus, flying, city25-airborne and city25-late-debris have negative '
                      'intervals; preserve these signals. No sustained-destruction speedup is established. '
                      'Full52 asynchronous memory and extended trajectory checks are still outstanding.','',
                      '| Scenario | A mean range / B mean, ms | A / B maximum, ms | A / B 60 Hz misses | Descriptive A−B interval, ms |',
                      '|---|---:|---:|---:|---:|']
            for c in full['scenarios']:
                a,b=c['A'],c['B'];lo,hi=c['descriptive_saved_ms_95']
                lines.append(f"| {c['scenario']} | {span(c[k]['mean_ms'] for k in ['A0','A1'])} / {b['mean_ms']:.3f} | {a['max_ms']:.3f} / {b['max_ms']:.3f} | {a['over_60hz']}/40 / {b['over_60hz']}/20 | [{lo:+.3f}, {hi:+.3f}] |")
            lines += ['', '| Scenario | A / B command, ms | A / B integrated physics/stress, ms | A / B completion, ms | A / B mean restore, ms |',
                      '|---|---:|---:|---:|---:|']
            for c in full['scenarios']:
                fields=[' / '.join(f"{c[a]['stages_ms'][k]:.3f}" for a in 'AB') for k in ['command_ms','simulate_fetch_ms','completion_ms']]
                restore=' / '.join(f"{c[a]['restore_mean_ms']:.3f}" for a in 'AB')
                lines.append(f"| {c['scenario']} | {' | '.join(fields)} | {restore} |")
            lines += ['', 'Evidence: `out/prepared-neighbors-20260913/full52/{campaign.json,matched/report.json}`. '
                      'The report includes per-process setup and first-use samples; raw tick records remain local.']
        else:
            checks=json.loads((base/'mechanism/campaign.json').read_text())
            assert checks['status']=='complete' and all(r['exit_code']==0 and r['physical']['status']=='passed' for r in checks['memory'])
            lines += ['', 'Before timing, bridge64, city25 impact and city256 debris pass 18 matched '
                      'full ticks (2/2/2 per case). City25 impact and city256 debris also pass four '
                      'asynchronous memcheck ticks and their full physical comparisons; recovered bond forces '
                      'are bit-identical in these checks. This does not cover all snapshot edge cases or '
                      'extended trajectories. The private bridge allocates two uint32 arrays per node '
                      '(909,312 bytes at 113,664 chunks), and adds touched-node marking and dirty-array '
                      'clearing. Its second input scan is removed, not all input preparation. '
                      'No constant-stress material work is skipped. It remains unpromoted; see '
                      '`mechanism/campaign.json` and the per-scenario measurements above.']
    lines += ['', '## Remaining ranked work','',
              '| Rank | Hypothesis and evidence | Affected scenarios | Planning full-tick saving | Confidence / cost | Support or refutation |',
              '|---|---|---|---|---|---|',
              '| 1 | Retained independent current factors; 5.54 ms current debris solves, but 48 ms full factor rebuild and rejected mask retention. GPU coefficient producer is qualified separately | Loaded anchored remnants, city destruction | 0–30 ms; unverified | Strong work concentration, low integrated confidence / high cost | Use an explicit retained-factor lifetime instead of retrying the failed mask path; charge real invalidations, setup, memory and complete ticks |',
              '| 2 | Complete ownership transaction retaining only dependency-valid records; phase-only debris exposes 10.23 ms contact retirement and 26.50 ms first-pass contact preparation | Fracture onset, cascades, large debris | 0–20 ms on fracture ticks, 0–5 ms heavy mean; revised low-confidence range | Medium diagnosis / high cost | Prove which records depend on body identity and which only on persistent geometry; preserve wake/contact order. Do not repeat lookup-only or collector-inflated tiny operations |',
              '| 3 | Exact shared current-load direct solve with prepared operators; existing 25-load feasibility passes | Repeated intact assets and early impact | 0–7 ms; tower 20–80 ms remains exploratory | Strong sharing evidence, low application confidence / high cost | Charge setup, memory and invalidation; no fresh synchronous analysis on every fracture or hidden cache priming |',
              '| 4 | Complete localized derived-structure maintenance; connectivity and adjacency candidates now exist separately | Local damage, mixed intact/damaged worlds | 0–5 ms; unverified | Medium / medium–high cost | Confirm regressions first; preserve unaffected scheduling ranges and preparation only with complete validity |',
              '| 5 | Native producer-owned load detection passes its screen with a debris regression signal and no sustained win; complete material validity remains distinct | Idle, sparse stimuli, mixed activity | 0–0.2 ms idle, 0–3 ms mixed; unverified | Strong architecture, modest exposure / medium cost | Require full-tick guardrails and exact invalidation; skip material only with a proven zero increment |',
              '', 'Planning ranges overlap and must not be added. No scope change permits stale physics, Direct GPU API, '
              'disabled sleeping, an extra correction, unqualified reduced quality, or omitted setup. Known unequal-mass model '
              'failures remain separate. The selected implementation is unchanged; full52 and physical trajectory '
              'qualification remain mandatory for finalists. No new experiments are queued. Resume only '
              'on a new user instruction. Shutdown receipt: `out/prepared-remnant-20260913/stopped.json`.']
    (OUT/'README.md').write_text('\n'.join(lines)+'\n')
    print(OUT/'README.md')


if __name__=='__main__':main()
