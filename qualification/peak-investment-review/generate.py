#!/usr/bin/env python3
"""Generate an evidence-linked review; estimates are explicit scenarios, not measurements."""
import csv, gzip, hashlib, importlib.util, json, statistics, subprocess
from pathlib import Path
from sensitivity import build as build_sensitivity
ROOT = Path(__file__).resolve().parents[2]
OUT = Path(__file__).resolve().parent
BASE = ROOT / 'qualification/polynomial-shared-baseline-control/report.json.gz'
SAMPLES = ROOT / 'qualification/polynomial-shared-scaled-fresh/samples/baseline'
def sha(p): return hashlib.sha256(p.read_bytes()).hexdigest()
def read_frames(p):
    with gzip.open(p, 'rt') as f: return list(csv.DictReader(f))
spec=importlib.util.spec_from_file_location('peak', ROOT/'tools/scripts/destruction-peak-opportunities.py')
peak=importlib.util.module_from_spec(spec); spec.loader.exec_module(peak)
r=json.loads(gzip.decompress(BASE.read_bytes())); assert r['manifest']['status']=='complete'
REVIEW_COMMIT=r['manifest']['revision']
RUNTIME_HASH=r['manifest']['artifacts'][str(ROOT/'physx/bin/linux.x86_64/release/libPhysXDestructionGpuRuntime_64.so')]
p=r['phase_captures'][0]['profile']
plain=[]; provenance={str(BASE.relative_to(ROOT)):sha(BASE)}
for path in sorted(SAMPLES.glob('*plain*/native.frames.csv.gz')):
    summary=path.with_name('native.summary.json'); rows=read_frames(path)
    peak.complete(dict(summary=json.loads(summary.read_text()),frames=rows))
    plain.append(rows); provenance[str(path.relative_to(ROOT))]=sha(path)
assert len(plain)==2 and all(len(x)==180 for x in plain)
phase_path=SAMPLES/'impacts-256-phases-0/native.frames.csv.gz'
phase_frames=read_frames(phase_path)
phase_summary=json.loads(phase_path.with_name('native.summary.json').read_text())
for path in (phase_path,phase_path.with_name('native.summary.json')): provenance[str(path.relative_to(ROOT))]=sha(path)
peak.rank(dict(summary=phase_summary,frames=phase_frames,profile=p)) # validates disjoint timer closure
assert (phase_summary['buildings'],phase_summary['chunks'],phase_summary['bonds'],phase_summary['projectiles'])==(256,113664,229376,256)
assert phase_summary['correction_limit']==1 and not phase_summary['sleeping']
assert (phase_summary['projectile_mass_kg'],phase_summary['material_strength_scale'],phase_summary['frame_strength_scale'],phase_summary['layout'],phase_summary['shot_path'])==(18000,24,40,'grid','aerial')
STEPS=(82,102,103)
facts={}
for i in STEPS:
    assert int(phase_frames[i]['step'])==i
    parts=p['wall_partition'][i]; grouped={k:0. for k in peak.GROUPS}
    for key,value in parts.items(): grouped[peak.group(key)]+=value
    parallel=max(p['detail'][k]['observed_wall_ms'][i] for k in ('detail.islandInsertion','detail.registerInteractions','detail.registerSceneInteractions','detail.registerContactManagers'))
    # Preallocation precedes postBroadPhaseStage2's registration fork. Do not sum parallel registration tasks.
    contact_proxy=p['detail']['detail.preallocateContactManagers']['observed_wall_ms'][i]+parallel
    handoff=sum(parts[k] for k in ('finishDetail.requestReadback','preparationCompletion','finishDetail.publishReservation'))
    facts[i]=dict(groups=grouped,cuda=p['cuda_stages'][i],parts=parts,contact_proxy=contact_proxy,handoff_proxy=handoff,
        work={k:phase_frames[i][k] for k in peak.COUNTERS},
        plain_ms=[float(run[i]['complete_step_ms']) for run in plain])
def link(path,needle):
    f=ROOT/path; data=subprocess.check_output(['git','show',f'{REVIEW_COMMIT}:{path}'],cwd=ROOT)
    text=data.decode(); assert needle in text, (path,needle)
    line=text[:text.index(needle)].count('\n')+1; provenance[path]=hashlib.sha256(data).hexdigest()
    return f'[{f.name}]({f}:{line})'
allocator=link('physx/source/physx/src/NpDestructionBodyAllocator.h','bool prepare(')
rebind=link('physx/source/simulationcontroller/src/ScShapeSimBase.cpp','bool ShapeSimBase::rebindRigidOwner')
shape=link('physx/source/physx/src/NpShapeManager.cpp','bool NpShapeManager::rebindShapeInternal')
contact=link('physx/source/gpunarrowphase/src/PxgNarrowphaseCore.cpp','void PxgGpuNarrowphaseCore::registerContactManagerInternal')
fork=link('physx/source/simulationcontroller/src/ScPipeline.cpp','void Sc::Scene::postBroadPhaseStage2')
correction=link('physx/source/simulationcontroller/src/ScPipeline.cpp','bool canCorrect=')
iteration=link('blast/source/sdk/extensions/stressgpu/detail/StressComponentIteration.cuh','__global__ void componentStressSolve')
precondition=link('blast/source/sdk/extensions/stressgpu/detail/StressNativePreconditioner.cuh','void prepareNativeResidualComponent')
polynomial=link('blast/source/sdk/extensions/stressgpu/detail/StressNativePolynomial.cuh','preconditionNativePolynomial(')
topology=link('blast/source/sdk/extensions/stressgpu/NvBlastExtStressGpuTopology.cuh','beginDeviceStressRebuild<<<')
modes=link('blast/source/sdk/extensions/stressgpu/detail/StressMotionModes.cuh','__global__ void constructMotionModes')
transaction=link('physx/source/gpudestruction/src/PxgDestructionTransaction.cuh','bool buildCommit()')
runtime=link('physx/source/gpudestruction/src/PxgDestructionRuntime.cu','bool completeCorrectionPreparation()')
loads=link('physx/source/gpudestruction/src/PxgDestructionRuntime.cu','bool advance(PxReal dt')
api=link('blast/source/sdk/extensions/stressgpu/detail/StressResidentAPI.inl','bool solveDeviceAsync(')
ideas=[
 dict(id='A',title='🚚 GPU-native fragment motion and shape ownership',basis='ownership',fraction=[.35,.60],confidence='Low for savings; strong evidence of CPU work',effort='Large; requires contact-lifecycle integration',
 change='Replace per-fragment NpRigidDynamic/BodySim construction and per-shape host rebinding with GPU motion slots, generation-bearing ownership transactions and explicit query observations. Keep immutable collision geometry and identities.',
 why='The disjoint ownership group is 16.072 ms at step 82 and 8.650 ms at step 103. Body reservation alone is 6.079 / 3.355 ms; shape-migration remainder is 4.690 / 1.659 ms. These are concrete host lifecycle operations, not the physical stress solve.',
 assumption='Scenario removes 35–60% of the measured ownership group NET of replacement GPU work. This is a planning assumption, not measured CUDA throughput. It deliberately leaves 40–65% for necessary allocation, validation, ownership, filtering and observation costs.',
 adversarial='Cannot delete CPU records independently: existing contact managers, actor interaction lists, teardown and query ownership refer to them. A partial change that keeps the same CPU bridge may save almost nothing. GPU slot exhaustion, ordinary-body interaction and handle reuse must remain correct.',
 test='Qualify one GPU-owned fragment lifecycle through collision, correction, query observation, removal and reuse; then measure removed CPU records/rebindings and complete-step peaks. No preallocated independently simulated body per intact chunk.',sources=[allocator,rebind,shape],overlap='Owns all ownership savings, including query deferral and relevant handoffs. Do not add those sub-ideas separately.'),
 dict(id='B',title='⚡ Reduce full resident stress iteration cost',basis='stress_cuda',fraction=[.15,.30],confidence='Low',effort='Medium–large; first isolate current per-iteration costs',
 change='Investigate a component-local layout for the ENTIRE hot recurrence, with persistent local node mapping and shared/register scratch across residual, preconditioner, direction and solution stages. Alternatively qualify a mathematically stronger component preconditioner; these are competing experiments, not additive benefits.',
 why='Current componentStressSolve already runs iterations inside one CTA and retires components independently. Its hot vectors still live in global arrays and the polynomial adds a sparse traversal. Current stress intervals are 7.606 / 18.270 / 18.668 ms at steps 82 / 102 / 103.',
 assumption='Scenario achieves 15–30% net reduction in the stress stream interval with unchanged equations, tolerances and required physical work. No present experiment proves this reduction. The percentage includes all replacement costs and may be unattainable.',
 adversarial='Two limited shared caches and a four-stage polynomial already failed complete-peak screens. More shared memory/registers can reduce concurrency; stronger preconditioning can increase time despite fewer iterations. Historical component-cycle shares predate the current runtime and are not current millisecond attribution. Refresh diagnostics before another variant.',
 test='Capture current component work and phase cycles; prove the proposed layout eliminates a measured repeated cost. Run an independent operator/residual oracle, then matched complete bombardment. Reject isolated-kernel wins that do not reduce peaks.',sources=[iteration,precondition,polynomial],overlap='Layout, preconditioning, batching and mixed precision compete for the same stress interval. Never sum their estimates.'),
 dict(id='C',title='🚚 GPU admission and lifecycle for new contact pairs',basis='contact_proxy',fraction=[.25,.50],confidence='Low',effort='Large; coupled to A',
 change='Consume PhysX GPU broad-phase pair output directly into GPU contact-manager slots and descriptors. Preserve NVIDIA narrow-phase and solver kernels; remove our native path’s need to reconstruct CPU ShapeInteraction/contact-manager/edge records for every new fragment pair.',
 why='Correction currently runs CPU contact preallocation followed by parallel registration/island tasks. We use preallocation plus the LONGEST registration task as a limited exposure proxy, not the sum of all tasks or the whole correction duration.',
 assumption='Scenario removes 25–50% of that limited proxy, net of GPU pool/filter/descriptor work. The proxy is not an exact critical-path measurement: worker start offsets and other dependencies can change realizable savings. No credit is assigned to broad-phase wait.',
 adversarial='GPU contact inputs exist already, but CPU contact records still carry lifetimes, reports and edge references. New fragment/ordinary-body pairs, filtering, friction caches, lost touch and capacity growth must survive. Moving only descriptor construction leaves most of this cost.',
 test='Count newly allocated/retired/reused pairs and measure the actual registration critical path. Qualify native pair lifetime, newly eligible pairs and ordinary participants before deleting CPU lifecycle consumers.',sources=[contact,fork],overlap='Correction portion only; excludes A’s shape retirement/ownership time. A and C share implementation prerequisites, so joint savings still require measurement.'),
 dict(id='D',title='🗑️ Rebuild only changed stress setup; omit unused motion-mode work',basis='commit',fraction=[.15,.35],confidence='Low',effort='Medium',
 change='Retain valid fine topology/motion-mode state per component, rebuild affected ranges, and avoid constructing null-motion data that anchored components do not consume. Preserve all graph validation and support-transition correctness.',
 why='Unchanged generations and unused recursive hierarchy tails are already skipped. Changed stress generations still rebuild global labels/order and run motion forest/tour construction; anchored factors return early only later. Accepted-state scope is about 2.3 ms at these peaks.',
 assumption='Scenario saves 15–35% of the accepted-state scope (roughly 0.35–0.83 ms). That entire scope is only a loose ceiling: it also contains mandatory commit/publication and waits. The setup-only share is not separately measured in this control.',
 adversarial='Simultaneous impacts may dirty most main components, limiting caching. Anchoring cannot justify omitting topology validation or free-body nullspace work after support loss. Existing unchanged local inverse retention and hierarchy-tail skips must not be counted again.',
 test='Measure setup subphases and changed-component fractions first. Test support removal, free/anchored transitions, invalid incidence, stable ordering and unchanged-component certificates.',sources=[topology,modes,transaction],overlap='Shares accepted-state exposure with buffer swapping or copy elimination; those are alternatives within this budget.'),
 dict(id='E',title='🗑️ Remove intermediate host decisions and resubmission',basis='handoff_proxy',fraction=[.25,.50],confidence='Low',effort='Coupled to A/C',
 change='GPU dependencies select fracture/no-fracture, allocate within resident capacity, install ownership and publish completion. Keep the final application completion boundary and exceptional growth/retry.',
 why='The current code still reads preparation verdicts and waits before the CPU ownership bridge. The model counts only request-readback, preparation-completion and reservation-publication scopes, not the 8–19 ms wait containing necessary stress computation.',
 assumption='Scenario removes 25–50% of the small observed handoff proxy. It is a dependency of final architecture, not a separate multi-millisecond win.',
 adversarial='Deleting a wait does not delete its preceding kernels. Critical dependencies remain, and ordinary PhysX host task scheduling cannot simply be captured into a CUDA graph. A/C may already absorb all benefit.',
 test='Show no host verdict between these stages and retain exactly-once commands, damage and events. Compare task/event dependencies, not just the count of synchronization calls.',sources=[runtime],overlap='Fully nested within A’s ownership estimate. Do not add to A.'),
 dict(id='F',title='⚡ Fuse contact-load and material preparation where inputs permit',basis='loads_materials',fraction=[.15,.30],confidence='Low',effort='Small–medium',
 change='Fuse compatible producer/consumer stages or compact known active work, retaining normal/friction impulses, torque, support evidence and once-only damage.',
 why='Contact-load plus material CUDA intervals total only about 0.13–0.21 ms at these peaks. Stress equations and verdicts remain necessary.',
 assumption='Scenario saves 15–30% of these two intervals. Their full combined duration is the absolute local ceiling before dependency effects.',
 adversarial='Contact accumulation and bond material evaluation have different ownership/reduction patterns. Fusion may increase contention or registers and lose performance. This is not the route from 53 ms to real time.',
 test='Prove complete work/energy equivalence and a repeatable peak change larger than run noise before retaining extra complexity.',sources=[loads],overlap='Nested within destruction submission/completion, but separate from B’s measured stress interval.'),
 dict(id='G',title='🎯 Selective correction with exact dependency closure',basis='correction',fraction=[0,.05],confidence='Very low for this workload',effort='Very large',
 change='Build GPU affected sets through contacts/constraints, preserve accepted independent work and rediscover newly eligible pairs. Recompute the complete interaction whenever reuse cannot be proven.',
 why='Correction spans 26.473 / 15.112 / 19.870 ms, but these include necessary collision and response. All 256 buildings receive impacts together; many interactions are actually affected. Existing unchanged-pair reuse is already enabled.',
 assumption='Credit only 0–5% of correction for this simultaneous-impact screen until affected-participant and reusable-pair counts prove more. No assumption that one correction can be removed.',
 adversarial='A single-step dependency component is not automatically a safe replay partition. New contacts and moved ordinary participants expand closure. Could cost more than complete replay here; likely more valuable for localized impacts in a larger idle city.',
 test='Record affected body/shape/contact counts, closure expansion and valid-reuse fraction. Differential tests must include incoming new contacts, ordinary bodies and supported joints. Current correction excludes joints/sleep/CCD, so these remain explicit architecture gaps.',sources=[correction],overlap='Contains C’s contact work. Do not add full correction savings to C; jointly measure.'),
]
def exposure(idea,step):
    f=facts[step]; b=idea['basis']
    if b in f['groups']: return f['groups'][b]
    if b=='stress_cuda': return f['cuda']['stress']
    if b=='loads_materials': return f['cuda']['contactLoads']+f['cuda']['materials']
    return f[b]
worst=max(float(row['complete_step_ms']) for run in plain for row in run)
for idea in ideas:
    idea['exposure_ms']={i:exposure(idea,i) for i in STEPS}
    idea['conditional_step_savings_ms']={i:[exposure(idea,i)*x for x in idea['fraction']] for i in STEPS}
    savings=[]
    for end in range(2):
        projected=max(float(row['complete_step_ms'])-(idea['conditional_step_savings_ms'][int(row['step'])][end] if int(row['step']) in STEPS else 0) for run in plain for row in run)
        savings.append(worst-projected)
    idea['conditional_observed_peak_savings_ms']=savings
ideas.sort(key=lambda x:(-x['conditional_observed_peak_savings_ms'][0],-x['conditional_observed_peak_savings_ms'][1],x['id']))
for rank,idea in enumerate(ideas,1): idea['rank']=rank
sensitivity, sensitivity_lines=build_sensitivity(ROOT,r,ideas,peak,STEPS)
commit=REVIEW_COMMIT
result=dict(schema=1,review_date='2026-09-08',source_commit=commit,baseline_sha256=sha(BASE),
    runtime_sha256=RUNTIME_HASH,
    assumptions_are_not_predictions=True,hardware_counters_available=False,scenario_steps=STEPS,
    sensitivity=sensitivity,workload={k:phase_summary[k] for k in ('buildings','chunks','bonds','projectiles','seconds','correction_limit','sleeping','crushing_material_enabled','projectile_mass_kg','material_strength_scale','frame_strength_scale','layout','shot_path')},facts=facts,ideas=ideas,provenance=provenance)
(OUT/'review.json').write_text(json.dumps(result,indent=2)+'\n')
fmt=lambda a:'–'.join(f'{x:.2f}' for x in a)
md=['# 🎯 Ranked destruction optimization review','',
'**Recommendation: prioritize GPU-native fragment motion/shape ownership, then the stress recurrence. Develop GPU contact lifecycle as part of completing that ownership architecture.** Selective correction has a large measured parent phase but an unproven reusable fraction in simultaneous bombardment.','',
'## Evidence and scope','',
f'Reviewed source: `{commit}`; runtime SHA-256 `{result["runtime_sha256"]}`. Read-only code review plus regeneration of existing measurements; **no new performance simulation was run for this report**. This is a frozen baseline review, not a qualification of later working-tree changes. Restored-baseline native analytic, 3D and motion suites passed. Source hashes and links refer to the recorded revision; local line positions can move as development continues.','',
'Fixture: **256 buildings, 113,664 chunks, 229,376 bonds, 256 projectiles**, two untraced runs of **180 steps / 3 simulated seconds** each, plus a separate instrumented replay. Physics timestep 1/60 s; maximum one correction per step; sleeping disabled; crushing material disabled. Grid layout, aerial launch path, projectile mass 18,000 kg, material strength scale 24 and frame strength scale 40. Complete advance includes commands, physics, destruction, correction, synchronization and runtime growth; excludes initialization, rendering and report generation. This is not long-run qualification.','',
f'Untraced mean across both runs: **{statistics.mean(float(x["complete_step_ms"]) for run in plain for x in run):.3f} ms**; worst **{worst:.3f} ms**. The peak is still about {worst/(1000/60):.1f} times the 60 Hz budget.','',
'| Step | Untraced min–max ms | Awake bodies | Contact load count | Active stress nodes / bonds | Stress islands | Max iterations | Bonds broken this step | Corrections |',
'|---|---:|---:|---:|---:|---:|---:|---:|---:|']
for i in STEPS:
    w=facts[i]['work']; md.append(f'| {i} | {min(facts[i]["plain_ms"]):.3f}–{max(facts[i]["plain_ms"]):.3f} | {int(w["awake_bodies"]):,} | {int(w["contacts_frame"]):,} | {int(w["stress_active_nodes"]):,} / {int(w["stress_active_bonds"]):,} | {w["stress_islands"]} | {w["stress_iterations"]} | {w["bonds_broken"]} | {w["resim_passes"]} |')
md += ['', 'Contact count is the demo’s `normalContacts` load counter, not independently measured solver rows or unique broad-phase pairs. Stress topology counters are committed observations, not exact per-iteration work. Max iterations is not the sum of component iterations. Step 102 is included because improving only steps 82/103 can expose its 49 ms cost as the next peak.', '',
'| Separate instrumented elapsed scope | Step 82 ms | Step 102 ms | Step 103 ms |', '|---|---:|---:|---:|']
for key,title in [('ownership','🚚 Ownership/lifecycle'),('correction','⏪ Correction'),('stress','🧮 Stress submission/completion dependency'),('commit','📤 Accepted-state work'),('trial','🟰 Trial physics + unassigned tasks')]:
    md.append('| '+title+' | '+' | '.join(f'{facts[i]["groups"][key]:.3f}' for i in STEPS)+' |')
md += ['', 'The host scopes above are disjoint apart from recorded timestamp bookends. They include GPU waits. CUDA stress intervals are nested, and cannot be added again. Other small groups are retained in JSON. Instrumented timings are not substituted for untraced peaks.','',
'## Ranking and estimate rules','',
'**Every savings estimate below is a conditional engineering scenario, not a measured speedup, probability interval or guaranteed lower bound. Actual savings may be zero or negative.** Measured phase costs bound opportunity; the percentage of that cost removable is an explicitly stated judgment requiring an experiment. No hardware bandwidth, occupancy or compute-saturation claim is made.','',
'Rank uses the lower end of the conditional reduction in the worst observed complete advance, with the upper end breaking ties. The calculation subtracts estimated savings only at steps 82/102/103 from both untraced runs, leaves every other measured step unchanged, then takes the new maximum. This accounts for the bottleneck moving. It transfers scoped exposure to untraced runs as an approximation; it cannot predict new stalls or allocation peaks. Fractions are screening assumptions, not evidence.','',
'| Rank | Idea / action | Conditional savings at 82 / 102 / 103 (ms) | Conditional reduction of worst complete step (ms) | Confidence |', '|---|---|---|---:|---|']
for a in ideas: md.append(f'| {a["rank"]} | {a["id"]}: {a["title"]} | '+ ' / '.join(fmt(a['conditional_step_savings_ms'][i]) for i in STEPS)+f' | {fmt(a["conditional_observed_peak_savings_ms"])} | {a["confidence"]} |')
md += ['', '**Do not sum rows.** E is already inside A. G overlaps C. B’s layout and preconditioner alternatives overlap each other. A and C need coordinated integration even though their measured host scopes differ. These estimates do not establish a path to 8 ms by arithmetic alone.','']
for a in ideas:
    md += [f'## {a["rank"]}. {a["title"]}', '', '**Change:** '+a['change'], '', '**Measured/code basis:** '+a['why'], '', '**Estimate model:** '+a['assumption'], '', '**Adversarial assessment:** '+a['adversarial'], '', '**First falsifiable gate:** '+a['test'], '', '**Implementation effort:** '+a['effort']+'. **Overlap:** '+a['overlap'], '', '**Code:** '+'; '.join(a['sources'])+'.', '']
md += ['## Work not credited as a new peak saving','',
'| Status | Idea | Assessment |','|---|---|---|',
'| ✅ Already present | Resident component iteration, independent convergence retirement, dynamic CTA work queue | Do not propose replacing thousands of per-iteration launches: this path already loops inside the component kernel. |',
'| ✅ Already present | Direct solved-contact consumption, unchanged generation skip, unchanged local inverse/warm-start retention, unused hierarchy-tail skip, GPU connectivity through growth | Preserve these gains; they are in the measured baseline. |',
'| ❌ Tried/reverted | Four-stage polynomial, limited unscaled/scaled shared polynomial caches | No established whole-peak gain. Scaled cache passes frozen penetration but worsens worst short-screen peak; a kernel-local win is insufficient. |',
'| ❌ Previously rejected | Colored sweeps, adjacency compaction, compensated FP32 inverse, exact-zero inverse bypass | Consult recorded qualification before revisiting; require a new mechanism/evidence. |',
'| ⏸️ Other workload | General settled-stress reuse / sleep | Important for large mostly idle cities. Sleeping is disabled in this frozen control, and impacts change inputs; assign zero peak savings until valid reusable work is measured. CPU API currently rejects general settled/unconverged skip flags. |',
'| ⏸️ Unmeasured subphase | Swap committed/trial device views instead of copying capacity-sized topology arrays | Code contains those copies, but no isolated copy-duration evidence supports a material gain. Fits the final architecture; establish copy cost and pointer/event lifetime safety before prioritizing. Do not equate all 2.3 ms acceptance time with copies. |',
'| 🚫 Changes fidelity | Cap iterations to the source’s cross-frame policy; suppress contacts/debris; freeze rubble | Separate behavior changes, not equal-work performance improvements under this gate. |',
'| 🚫 Not justified | Convert the whole sparse stress operator to dense GEMM / Tensor Cores | Sparse bond coupling and independent component sizes matter. Dense work can increase operations substantially. Small dense coarse blocks may be useful, but require an operator and precision proof. |',
'| ⏸️ Small current peak exposure | Checkpoint compaction / GPU command application | Checkpoint host elapsed is 0.009 / 0.264 / 0.009 ms at the reviewed steps; CUDA copy execution can overlap other scopes. Commands are absent at these impact steps but projectile insertion remains inside the first-step timer. Final device command ownership is required, without crediting it as a current destruction-peak win. |',
'| 🟰 Keep NVIDIA foundation | Rewrite ordinary broad/narrow-phase or rigid solve | Outside optimization focus. Improve destruction ownership/work selection at their interfaces. |','',
'## The remaining deadline gap','',
'Reducing the observed 53.603 ms worst step to 16.667 ms needs about **36.94 ms (69%)** removed; reaching 8 ms needs about **45.60 ms (85%)**. None of these individual estimates closes that gap. Their overlap prevents adding them into a promised total. A more complete architecture change may eventually exceed these screening scenarios, but that is unverified.', '',
'For perspective, even making the current 7.606 ms stress interval free at the first-impact step would leave roughly **45.57 ms** in the slower untraced step-82 run, under the same scoped-to-untraced approximation. Stress-only optimization cannot meet the deadline. Conversely, moving host bookkeeping to CUDA does not remove its physical or dependency obligations. The final architecture must address both ownership/correction and stress, and be measured again.', '',
'## Concrete next sequence','',
'1. Map and test the GPU-owned fragment/contact lifecycle across allocation, ownership, pair creation, solver input, committed queries and teardown. This is A/C’s prerequisite, not a faster CPU rebind loop.',
'2. Establish A/C counters: created CPU records, migrated shapes, created/retired/reused contact managers, and registration critical-path intervals. Current broad parent timers cannot prove how much contact work is removable.',
'3. Refresh the stress component diagnostic on this exact runtime before another B experiment. Existing historical work attribution shows retained buildings dominate, but its preconditioner and iteration counts differ from today’s implementation.',
'4. Keep a short rejection screen, then physical regression, then five 60-second performance runs and 10-minute endurance for qualifying candidates. Run interleaved controls and retain all peaks.',
'5. Re-rank after every accepted implementation change. A faster second peak alone does not improve the first peak; validate the whole impact window.','',
'## Limits and reproduction','',
'No measured theoretical hardware floor is available. A valid model needs per-component node/bond iterations, actual sparse traversal/precision costs, new contact and ownership counts, and the dependency critical path. Peak GPU specifications or bytes divided by advertised bandwidth would only give optimistic lower bounds. The current trial-plus-unassigned scope also contains our integration, so it is not a clean PhysX-only floor.','',
'Generated numeric analysis and judgments are in [review.json](review.json). Regenerate with `python3 qualification/peak-investment-review/generate.py` from the repository. The script validates complete-timer closure, verifies the workload and records source/data hashes. It reads reviewed source from the captured Git revision and runtime hashes from the captured manifest, never from a newer local build. Estimates remain human judgments. It does not rerun physics.','',
'[Existing generated A/B report](/root/workspace/physx-2/qualification/polynomial-shared-scaled-fresh/comparison.md). [Full optimization inventory](/root/workspace/physx-2/docs/destruction/OPTIMIZATION_INDEX.md). [Restored native test result](/root/workspace/physx-2/qualification/polynomial-shared-scaled/restored-native-tests.log).','']
md.extend(sensitivity_lines)
(OUT/'report.md').write_text('\n'.join(md))
print('\n'.join(f'{a["rank"]}. {a["id"]} {a["title"]}: conditional complete peak saving {fmt(a["conditional_observed_peak_savings_ms"])} ms' for a in ideas))
