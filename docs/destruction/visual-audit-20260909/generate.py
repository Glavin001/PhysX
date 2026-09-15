#!/usr/bin/env python3
"""Generate the visual audit from existing captures; never runs simulation."""
import collections,csv,gzip,hashlib,importlib.util,json,math,subprocess,sys
from pathlib import Path
sys.dont_write_bytecode=True
from figures import Figure,COLORS
HERE=Path(__file__).resolve().parent;ROOT=HERE.parents[2];OUT=HERE/'figures'
P=ROOT/'qualification/rigid-additive-20260909/baseline-phases'
W=ROOT/'qualification/vibe-component-work-accepted-20260908'
NEW=ROOT/'qualification/native-iteration-limits-20260909'
def read(path):
 return json.load(gzip.open(path,'rt')) if str(path).endswith('.gz') else json.loads(Path(path).read_text())
def loadtool(name):
 spec=importlib.util.spec_from_file_location(name.replace('-','_'),ROOT/'tools/scripts'/name)
 mod=importlib.util.module_from_spec(spec);spec.loader.exec_module(mod);return mod
T=loadtool('report-destruction-timing.py');CW=loadtool('report-vibe-component-work.py')
a=read(P/'analysis.json.gz');steps=read(P/'steps.json.gz');work=read(W/'analysis.json.gz')
peak=a['peak'];s=steps[peak];p=a['wall_partition'][peak];total=sum(p.values())
raw=[r for r in csv.DictReader(gzip.open(P/'native.phases.csv.gz','rt')) if r['accepted_step']=='1']
by=collections.defaultdict(lambda:collections.defaultdict(list))
for r in raw:by[int(r['step'])][r['phase'].removeprefix('GpuDestruction.')].append((int(r['start_ns']),int(r['end_ns'])))
errors=[]
for i,frame in enumerate(steps):
 assert frame['tick']==i
 boundary=by[i]['consumerAdvance'];assert len(boundary)==1
 calc=T.partition(boundary,by[i]);prior=a['wall_partition'][i]
 # New analyzer splits this historical leaf into children + remainder; no children existed in A.
 if 'preparationCompletion' in prior:
  calc['preparationCompletion']=sum(v for k,v in calc.items() if k=='preparationCompletion.other' or k.startswith('compatibility.'))
  calc={k:v for k,v in calc.items() if k!='preparationCompletion.other' and not k.startswith('compatibility.')}
 for k in set(calc)|set(prior):assert abs(calc.get(k,0)-prior.get(k,0))<1e-8,(i,k)
 assert abs(sum(prior.values())-T.a.length(boundary)/1e6)<1e-8
 parts=sum(frame[k] for k in ['commands_and_pre_step_ms','native_physics_and_destruction_ms','game_observation_events_ms','accepted_status_and_snapshots_ms'])
 assert abs(parts-frame['complete_step_ms'])<1e-8
 errors.append(sum(prior.values())-frame['complete_step_ms'])
assert len(steps)==600 and s['native_corrections']==1
# Audit selected individual records against the original census oracle.
selected=collections.defaultdict(list);selected_totals={}
selected_solves={q['total']['solve'] for q in work['solves'] if q['tick'] in [48,52]}
with gzip.open(W/'selected-components.jsonl.gz','rt') as stream:
 for line in stream:
  r=json.loads(line)
  if r['solve'] not in selected_solves:continue
  if r['record']=='component':selected[r['solve']].append(r)
  else:selected_totals[r['solve']]=r
for solve in selected_solves:CW.summarize(selected[solve],selected_totals[solve])
solves=[q for q in work['solves'] if q['tick']==peak]
assert len(solves)==2
counts={k:sum(q['total'][k] for q in solves) for k in ['components','component_updates','operator_live_visits','polynomial_live_visits','fine_inverse_applications']}
cycles=[sum(q['total']['phase_cycles'][i] for q in solves) for i in range(9)]
assert sum(cycles[:8])==cycles[8]
latest={regime:[read(NEW/regime/f'candidate-{i}.json.gz') for i in [1,2]] for regime in ['shots','idle']}
# Colors denote disposition of responsibility, not CPU versus GPU.
def status(k):
 if k in ['correctedCollisionSolve','submit']:return 'opt'
 if k=='finishDetail.waitForGpu':return 'gpu'
 if k.endswith('.other') or k=='preparationCompletion':return 'unknown'
 if k.startswith(('migrateDetail.','applyDetail.','finishDetail.allocate','finishDetail.request')):return 'replace'
 return 'keep'
def label(k):return T.LABELS.get(k,(k,''))[0]
# Figure 1: the three distinct kinds of grouping.
f=Figure('1. Geometry, motion and three different graphs','Conceptual current model; counts below refer to dataset A, tick 48.',720)
f.box(40,115,425,180,'Persistent chunks + bonds',['113,664 authored chunks','229,376 authored bonds','Geometry identity survives splitting','Chunks are not independent motions'])
f.box(505,115,425,180,'Rigid motion clusters',['Initially 256 building clusters','Tick 48: 10,705 logical clusters','10,449 reported fragment bodies','10,193 awake fragment bodies'])
f.box(970,115,425,180,'Stress components',['Connected unknowns in equations','Fixed supports are boundaries','Different partition from motion','B: 1,030 trial / 1,793 corrected'])
f.arrow([(465,195),(505,195)]);f.arrow([(930,195),(970,195)])
f.box(40,365,650,155,'Contact / constraint dependencies',['Projectile <-> wall <-> debris <-> ordinary actor / joint','Can connect several separate stress components','Needed for a correct selective rewind and replay'],'opt')
f.box(730,365,665,155,'Why the distinction matters',['Sleeping is a motion state, not proof of unchanged stress','One shared floor must not merge the entire stress world','Current full correction remains; selective closure is TODO'],'replace')
f.text(40,570,'A body count does not measure sparse stress work. A bond count does not measure collision work.',22,bold=True)
f.text(40,625,'Colors: green retain | amber optimize | red replace/migrate | gray unresolved scope | blue GPU timing',17)
f.save(OUT,'01-model')
# Figure 2: current tick and target ownership.
f=Figure('2. One tick: trial, fracture, one correction, final acceptance','Conceptual order, not time-scaled. Timings are from A; current publication placement is identified explicitly.',1090)
items=[('CPU + GPU','Commands once; checkpoint','Keep commands and save required mutable state','keep'),('PhysX CPU + GPU','Trial collision and rigid-body solve','Actual contacts/impulses from the intact interaction','keep'),('GPU','Loads -> stress -> materials -> topology','Stress 11.510 ms; topology/mass 0.481 ms','opt'),('GPU -> CPU dependency','Fragment registration / ownership bridge','Current CPU BodySim, activity and contact prerequisites','replace'),('PhysX CPU + GPU','If fractured: rewind and ONE corrected solve','52.365 ms mixed scope; rewind-copy itself 0.0104 ms','opt'),('GPU','Corrected loads -> stress -> fracture again','Stress 19.000 ms; final split does not trigger a third solve','opt'),('GPU -> CPU + consumer','Accept once; publish final properties and events','Current public properties/shape owners publish after both verdicts','keep')]
for i,(owner,title,note,c) in enumerate(items):
 y=110+i*115;f.text(40,y+23,owner,17,color=COLORS[c]);f.box(355,y,1040,94,title,[note],c)
 if i<6:f.arrow([(875,y+94),(875,y+112)])
f.text(40,945,'No fracture after trial: skip ownership mutation / correction; still complete required material and acceptance work.',18)
f.text(40,987,'Target: GPU allocation + registration + contacts -> device condition -> correction -> one CPU accepted observation.',18,color=COLORS['replace'])
f.text(40,1023,'GPU preparation already precedes CPU construction; CPU registration is still required before corrected physics.',18)
f.save(OUT,'02-tick-flow')
# Figure 3: exhaustive disjoint partition, no time silently removed.
nonzero=sorted([(k,v) for k,v in p.items() if v],key=lambda kv:-kv[1])
f=Figure('3. Where 100% of the selected fracture step goes','A: 256 buildings / 113,664 chunks / 229,376 bonds / 256 shots present; 768-shot, 600-step run.',210+36*len(nonzero))
f.text(36,103,f'Profiler bracket {total:.6f} ms = complete timer {s["complete_step_ms"]:.6f} ms + {total-s["complete_step_ms"]:.6f} ms bookends',19,bold=True)
short={'trial.other':'Trial + commands + observations / uncovered tasks','applyDetail.migrateShapes.other':'Shape migration remainder (unresolved)','finishDetail.waitForGpu':'Host dependency containing GPU destruction','finishDetail.requestReadback':'GPU slots / selected-request observation','preparationCompletion':'Preparation verdict observation (historical)'}
for i,(k,v) in enumerate(nonzero):
 y=155+i*36;f.text(36,y,short.get(k,label(k))[:68],15)
 f.rect(715,y+2,max(1,v/55*410),22,COLORS[status(k)]);f.text(1140,y,f'{v:9.6f} ms',15);f.text(1300,y,f'{v/total*100:5.2f}%',15)
f.text(36,f.h-36,'Blue wait already contains GPU execution. Do not add the separate CUDA chart to these rows.',17)
f.save(OUT,'03-full-accounting')
# Figure 4: genuine timestamp lanes, not fake flamegraph stacks.
f=Figure('4. Recorded elapsed-time lanes at tick 48','A: real host timestamps, aligned to the same 145.463127 ms bracket. Parent/child rows overlap.',790)
start,end=by[peak]['consumerAdvance'][0];x0=440;scale=930/total
lanes=[('consumerAdvance','Whole consumer advance','unknown'),('finishAndReserve','Destruction completion + reservation','gpu'),('finishDetail.waitForGpu','Waiting for destruction result','gpu'),('finishDetail.allocateNativeBodies','CPU fragment compatibility','replace'),('applyBindings','Ownership/lifecycle bridge','replace'),('correctedCollisionSolve','Corrected physics parent','opt'),('detail.preallocateContactManagers','  Contact manager allocation','replace'),('detail.registerSceneInteractions','  Interaction registration','replace'),('detail.islandInsertion','  Island insertion','replace'),('detail.updateDynamics','  Dynamics submission','keep'),('acceptCorrection','Accept corrected state','keep')]
for i,(key,name,c) in enumerate(lanes):
 y=130+46*i;f.text(36,y,name,16)
 for lo,hi in T.a.union(by[peak].get(key,[])):f.rect(x0+(lo-start)/1e6*scale,y,max(.7,(hi-lo)/1e6*scale),24,COLORS[c])
for value in range(0,141,20):
 x=x0+value*scale;f.line([(x,115),(x,650)],'#DAE1E9',1);f.text(x-8,660,str(value),15)
f.text(770,693,'Milliseconds since outer bracket began',17)
f.text(36,736,'Blank space on a subphase lane means uninstrumented/other work, not proof the GPU is idle.',18)
f.save(OUT,'04-timeline')
# Figure 5: CUDA per-evaluation costs and independently captured iteration work.
f=Figure('5. Two stress evaluations, many internal numerical iterations','A gives milliseconds; B is a separate intrusive work census. Never divide B work by A milliseconds as a measured rate.',840)
dev=collections.defaultdict(list)
for r in csv.DictReader(gzip.open(P/'native.phases.csv.device.csv.gz','rt')):
 if r['step']==str(peak) and r['accepted_step']=='1':dev[r['phase'].split('.')[-1]].append(float(r['cuda_elapsed_ms']))
for j,side in enumerate(['TRIAL','AFTER CORRECTION']):
 x=40+j*700;q=solves[j]['total'];f.box(x,120,655,260,side,[f'Stress: {dev["stress"][j]:.6f} ms (A)',f'Component evaluations: {q["components"]:,} (B)',f'Summed updates: {q["component_updates"]:,} (B)',f'Outer live visits: {q["operator_live_visits"]:,} (B)',f'Polynomial visits: {q["polynomial_live_visits"]:,} (B)',f'6x6 inverse applications: {q["fine_inverse_applications"]:,} (B)'],'opt')
f.text(40,417,'Both evaluations: 107,090 updates; 361,587,089 live adjacency visits; 69,385,024 inverse applications.',20,bold=True)
phase_names=['Residual preparation / projection','Residual operator + verification','Convergence decision','Preconditioning + reductions','Direction update','Direction operator','Solution update','Dispatch / other']
for i,(name,val) in enumerate(zip(phase_names,cycles)):
 y=465+i*34;share=100*val/cycles[8];f.text(40,y,name,17);f.rect(465,y+2,max(1,share*10),23,COLORS['opt'] if i==3 else COLORS['gpu']);f.text(1160,y,f'{share:.3f}%',17)
f.text(40,768,'Bars: share of summed instrumented block cycles (B), NOT wall-time shares or SM utilization.',18)
f.text(40,802,'Anchored structures account for 99.990% of counted live adjacency work at this census tick.',18)
f.save(OUT,'05-stress-work')
# Figure 6: algorithm and locality.
f=Figure('6. What one stress iteration does','Current source: resident component solver <=1,024 nodes; cooperative large-component path above that threshold.',900)
boxes=[(40,120,'1. Build / project residual',['How far are stored forces from equilibrium?','Remove free-body rigid-motion modes.'],'keep'),(740,120,'2. Apply sparse operator + test',['Walk incident bonds; combine force + torque.','Actual-equation verification guards acceptance.'],'keep'),(740,345,'3. Precondition',['Cached local 6x6 inverse + two-step polynomial.','Extra neighbor traversal; improve correction direction.'],'opt'),(40,345,'4. Update search direction',['Use the previous direction and new correction.','Apply operator again to obtain step size.'],'opt'),(40,570,'5. Update solution',['Update accumulated forces / residual.','Loop only while this component is unconverged.'],'keep'),(740,570,'Converged component retires',['A block claims another component from GPU queue.','Other components may still need many iterations.'],'keep')]
for x,y,title,lines,c in boxes:f.box(x,y,655,155,title,lines,c)
f.arrow([(695,195),(740,195)]);f.arrow([(1060,275),(1060,345)]);f.arrow([(740,420),(695,420)]);f.arrow([(360,500),(360,570)]);f.arrow([(695,645),(740,645)])
f.arrow([(40,645),(20,645),(20,195),(40,195)],COLORS['opt'])
f.text(40,777,'The loop is inside a running CUDA kernel. An iteration is not a kernel launch, a resimulation, or another tick.',19,bold=True)
f.text(40,819,'Next solver candidate: factor local interiors, solve only interfaces, recover all bond forces and verify originals.',18)
f.text(40,852,'That replacement is not implemented/qualified. Setup, changed factors and interface iterations still cost time.',18,color=COLORS['muted'])
f.save(OUT,'06-stress-algorithm')
# Figure 7: exact reuse and work still present.
f=Figure('7. Can an unchanged stress component skip work?','Current source at 471ea8a5. Historical dataset A predates these exact component-local certificates.',830)
f.box(40,115,640,195,'GPU reuse eligibility',['Warm start + valid stored-output certificate?','Same operator generation / no affected bond removals?','Same tolerance and maximum-iteration settings?','All six input-load components bit-identical?'],'keep')
f.box(750,115,640,195,'How a certificate becomes valid',['Stored bond forces passed a zero-update warm solve.','Converged high-precision internal state alone is insufficient.','New split roots do not inherit the old certificate.','Unrelated old components can retain certificates.'],'keep')
f.arrow([(360,310),(360,370)]);f.arrow([(680,235),(715,235),(715,440),(750,440)])
f.box(40,370,640,150,'YES: skip iterative solve',['Reuse stored forces; still run material/damage logic.','Still pay eligibility input scan and graph dispatch.','Eligible nodes bypass supported preparation/recovery.'],'keep')
f.box(750,370,640,150,'NO: recompute and verify',['No contact is not sufficient proof of unchanged input.','Support, gravity/centrifugal load or settings can change.','Unconverged state must not be frozen for speed.'],'opt')
f.box(40,600,1350,145,'Remaining replacement: producer-maintained dirty components',['Current certificate check still visits candidate component inputs; storage remains capacity-sized.','Maintain dirtiness where loads/topology change, then schedule only required components.','Preserve all invalidation sources and ongoing material evolution; sleeping alone never grants reuse.'],'replace')
f.save(OUT,'07-reuse')
# Figure 8: all steps preserved; summarize stacked disjoint responsibilities.
f=Figure('8. All 600 recorded steps: peaks move between responsibilities','A: 10 simulated seconds; commands launch 256 projectiles at ticks 30, 180 and 330. First step is retained.',850)
keys=[('correctedCollisionSolve','Correction','opt'),('finishDetail.waitForGpu','GPU-result dependency','gpu'),('applyBindings','Ownership','replace'),('reservation','Reservation','replace'),('rest','Everything else','unknown')]
x0,y0,w,h=80,135,1310,420;maxms=170
for i,row in enumerate(a['wall_partition']):
 vals=[row['correctedCollisionSolve'],row['finishDetail.waitForGpu'],sum(v for k,v in row.items() if k.startswith(('apply','migrate'))),sum(v for k,v in row.items() if k.startswith('finishDetail.') and k!='finishDetail.waitForGpu')]
 vals.append(sum(row.values())-sum(vals));base=0
 for v,(_,_,c) in zip(vals,keys):
  f.rect(x0+i*w/600,y0+h-(base+v)/maxms*h,w/600+.2,v/maxms*h,COLORS[c]);base+=v
for val in [0,40,80,120,160]:
 y=y0+h-val/maxms*h;f.line([(x0,y),(x0+w,y)],'#D8DFE9',1);f.text(30,y-12,str(val),16)
for tick in [0,100,200,300,400,500,599]:f.text(x0+tick*w/600-8,y0+h+8,str(tick),16)
f.text(25,102,'ms',17);f.text(620,590,'Accepted tick index',17)
for j,(_,name,c) in enumerate(keys):f.rect(45+j*277,650,15,15,COLORS[c]);f.text(66+j*277,645,name,15)
f.text(40,707,'Tick 0: 158.558 ms complete. Tick 48: 145.462 ms complete / 132.111 ms native engine.',20,bold=True)
f.text(40,751,'Dataset A misses 8 ms on 565/600 steps and 16.667 ms on 561/600 steps; diagnostic only.',18)
f.text(40,792,'This is not a new measurement of current HEAD and not a whole-game rendering/network tick.',18)
f.save(OUT,'08-all-steps')
# Figure 9: newer screens, their own outer timings rather than transplanted old percentages.
f=Figure('9. Newer 131-133 ms peaks: what is actually measured','C: 256 buildings / 113,664 chunks / 229,376 bonds / 256 shots; two 96-step runs, Direct GPU off, sleep on.',535)
fields=['native_physics_and_destruction_ms','game_observation_events_ms','commands_and_pre_step_ms','accepted_status_and_snapshots_ms']
for i,d in enumerate(latest['shots']):
 r=d['fracture_peak'];values=[r[k] for k in fields];assert abs(sum(values)-r['complete_step_ms'])<1e-8
 y=135+i*150;f.text(40,y,f'Run {i+1}, tick {r["tick"]}: {r["complete_step_ms"]:.6f} ms',22,bold=True)
 x=40
 for value,c in zip(values,['unknown','replace','keep','keep']):
  width=value/140*1320;f.rect(x,y+42,width,40,COLORS[c]);x+=width
 f.text(40,y+90,f'Native engine: {values[0]:.6f} ms | accepted consumer: {values[1]:.6f} ms',18)
 f.text(40,y+117,f'Commands: {values[2]:.6f} ms | final status: {values[3]:.6f} ms',16)
f.text(40,455,'Same peak counts: 10,449 fragments / 10,193 awake / 216,220 normal-contact count / 28,530 new broken bonds.',17)
f.text(40,494,'Gray native bars have NO current detailed decomposition. Dataset A cannot fill them without a new capture.',18)
f.save(OUT,'09-newer-peaks')
# Generated exact tables + provenance + assertions for the Markdown narrative.
lines=['## Exact accounting appendix (generated)', '',f'Dataset A, tick {peak}; all nonzero disjoint scopes. Denominator: **{total:.6f} ms** profiler bracket.', '', '| Responsibility | Owner / interpretation | Disposition | ms | % of bracket | Calls |','|---|---|---|---:|---:|---:|']
for k,v in nonzero:
 name=short.get(k,label(k));calls=len(by[peak].get(k,[]));meaning={'preparationCompletion':'CPU observes GPU initialization/collision/correction verdicts; includes completion wait (A)', 'trial.other':'Trial physics, commands, accepted consumer observations and unclassified task/driver gaps (A)'}.get(k,T.LABELS.get(k,('', 'Unresolved parent remainder'))[1]);lines.append(f'| {name} | {meaning} | {status(k)} | {v:.6f} | {100*v/total:.5f}% | {calls if not k.endswith(".other") else "remainder"} |')
lines += [f'| **TOTAL** | | | **{total:.6f}** | **100%** | |','','Percentages may round; all unrounded durations reconcile. Unknown/remainder scopes are retained, not assigned to GPU or assumed removable.','','### Complete timer and native engine (same tick)','', '| Measurement | ms |','|---|---:|']
for k in ['commands_and_pre_step_ms','native_physics_and_destruction_ms','game_observation_events_ms','accepted_status_and_snapshots_ms','complete_step_ms']:lines.append(f'| {k} | {s[k]:.6f} |')
lines += [f'| Profiler outer bookends beyond complete timer | {total-s["complete_step_ms"]:.6f} |','','### CUDA intervals (overlap the wall accounting)','', '| Stage | Trial ms | Corrected/final ms | Sum ms |','|---|---:|---:|---:|']
for key in ['contactLoads','stress','materials','topologyAndCandidates','commitAndStressTopology']:
 v=dev[key];assert len(v)==2;lines.append(f'| {T.STAGES[key]} | {v[0]:.6f} | {v[1]:.6f} | {sum(v):.6f} |')
lines += ['','### Selected steps from the same timing capture','','| Tick | Complete ms | GPU stress ms | Correction scope ms | Fragments | Awake fragments | Normal-contact count | New broken bonds |','|---|---:|---:|---:|---:|---:|---:|---:|']
for i in [0,48,49,52,76,78]:
 r=steps[i];lines.append(f'| {i} | {r["complete_step_ms"]:.6f} | {a["cuda_stages"][i]["stress"]:.6f} | {a["wall_partition"][i]["correctedCollisionSolve"]:.6f} | {r["fragment_bodies"]:,} | {r["awake_fragment_bodies"]:,} | {r["normal_contacts"]:,} | {r["broken_bonds"]-(steps[i-1]["broken_bonds"] if i else 0):,} |')
lines += ['','### Newer short screens (dataset C; no detailed phase decomposition)','', '256 buildings / 113,664 chunks / 229,376 bonds; 96 steps / 1.6 simulated seconds per run. Destruction executes 256 shots; separate fresh idle has zero shots. Direct GPU off, sleeping on, correction <=1. Two candidate runs shown; original receipt contains two baseline runs as well.','','| Regime / run | Complete mean ms | All-step maximum ms | Fracture maximum ms |','|---|---:|---:|---:|']
for regime,runs in latest.items():
 for i,d in enumerate(runs):lines.append(f'| {regime} / {i+1} | {d["report"]["phases_ms"]["complete_step_ms"]["mean"]:.6f} | {d["peak"]["complete_step_ms"]:.6f} | {str(round(d["fracture_peak"]["complete_step_ms"],6)) if d["fracture_peak"] else "none"} |')
(HERE/'accounting.md').write_text('\n'.join(lines)+'\n')
inputs=[P/'analysis.json.gz',P/'steps.json.gz',P/'native.phases.csv.gz',P/'native.phases.csv.device.csv.gz',P/'commands.json.gz',W/'analysis.json.gz',W/'selected-components.jsonl.gz',W/'source-hashes.json']
inputs += [NEW/regime/f'candidate-{i}.json.gz' for regime in ['shots','idle'] for i in [1,2]]
source=['blast/source/sdk/extensions/stressgpu/detail/'+x for x in ['StressNativeSettled.cuh','StressSolveSubmission.inl','StressComponentIteration.cuh','StressNativePolynomial.cuh','StressNativePreconditioner.cuh','StressResidentAPI.inl']]
source += ['blast/source/sdk/extensions/stressgpu/NvBlastExtStressGpuTopology.cuh','physx/source/gpudestruction/src/PxgDestructionTransaction.cuh','docs/destruction/PERFORMANCE_HANDOFF.md','docs/destruction/REPLACEMENT_PLAN.md']
inputs += [ROOT/x for x in source]
receipt={'source_revision':subprocess.check_output(['git','rev-parse','HEAD'],cwd=ROOT,text=True).strip(),'new_simulation_runs':0,'timing_steps_verified':len(steps),'partition_recomputed_with_existing_analyzer':True,'historical_scope_alias':'preparationCompletion.other -> preparationCompletion; absent compatibility children are zero','census_selected_solves_verified':len(selected_solves),'peak_tick':peak,'peak_profiler_ms':total,'peak_complete_ms':s['complete_step_ms'],'peak_bookend_difference_ms':total-s['complete_step_ms'],'all_steps_max_abs_bookend_difference_ms':max(map(abs,errors)),'counts_dataset_B':counts,'input_sha256':{str(x.relative_to(ROOT)):hashlib.sha256(x.read_bytes()).hexdigest() for x in inputs}}
(HERE/'audit-data.json').write_text(json.dumps({'receipt':receipt,'peak_wall_partition':p,'peak_complete':s,'peak_cuda_stages':a['cuda_stages'][peak],'peak_work_solves':solves},indent=2)+'\n')
(HERE/'report.md').write_text((HERE/'narrative.md').read_text()+'\n'+(HERE/'accounting.md').read_text())
print(json.dumps(receipt,indent=2)[:1300]);print('Wrote',HERE/'report.md')
