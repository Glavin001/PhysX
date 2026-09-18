#!/usr/bin/env python3
import argparse,csv,gzip,json,collections,statistics,importlib.util
from pathlib import Path
root=Path(__file__).resolve().parents[2]
parser=argparse.ArgumentParser(description='Report first-impact native timings from phases/gpu/plain1/plain2 captures')
parser.add_argument('capture',type=Path);parser.add_argument('--output',type=Path,required=True);args=parser.parse_args()
base=args.capture
spec=importlib.util.spec_from_file_location('a',root/'tools/scripts/analyze-native-gpu-profile.py');a=importlib.util.module_from_spec(spec);spec.loader.exec_module(a)
frames={n:list(csv.DictReader((base/n/'native.frames.csv').open())) for n in ['phases','gpu','plain1','plain2']}
phases={n:list(csv.DictReader((base/n/'native.phases.csv').open())) for n in ['phases','gpu']}
independent=['submit','finishAndReserve','initializeReserved','publishReservedMetadata','collisionBindings','correctionBodies','validatePreparation','preparationCompletion','applyBindings','restoreInstall','resetContactCaches','correctedCollisionSolve','acceptCorrection','finalPublication']
result={}
for n in frames:
 r=frames[n];result[n]={'timings':a.stats([float(x['physics_step_ms']) for x in r]),'first_impact':r[82], 'windows':{label:a.stats([float(x['physics_step_ms']) for x in r if predicate(x)]) for label,predicate in [('preimpact',lambda x:1<=int(x['step'])<82),('corrected',lambda x:int(x['resim_passes'])==1),('late_rubble',lambda x:int(x['step'])>=480)]}}
for n in phases:
 by=collections.defaultdict(lambda:collections.defaultdict(float))
 for x in phases[n]:
  if x['accepted_step']=='1':by[int(x['step'])][x['phase'].removeprefix('GpuDestruction.')]+=float(x['host_wall_ms'])
 stage={k:{'impact_ms':by[82][k], 'mean_ms':sum(by[i][k] for i in range(600))/600} for k in independent+['checkpoint']}
 stage['trial_and_remaining']={'impact_ms':float(frames[n][82]['physics_step_ms'])-sum(stage[k]['impact_ms'] for k in independent+['checkpoint']), 'mean_ms':statistics.mean(float(x['physics_step_ms']) for x in frames[n])-sum(stage[k]['mean_ms'] for k in independent+['checkpoint'])}
 result[n]['partition']=stage
 result[n]['phase_82']=dict(by[82])
# Exact GPU activity intersections for the profiled first impact.
p=base/'gpu';f=frames['gpu'][82];lo,hi=int(f['simulation_start_ns']),int(f['simulation_end_ns'])
names={int(x):y.strip() for x,y in (s.split('\t',1) for s in (p/'native.activity.names.tsv').open())}
records=[];calls=collections.defaultdict(lambda:{'calls':0,'sum_ms':0})
for row in a.read_csv(p/'native.activity.csv'):
 start,end=max(lo,int(row['start_ns'])),min(hi,int(row['end_ns']))
 if end<=start:continue
 row=dict(row,start=start,end=end,name=names[int(row['name_id'])]);records.append(row)
 if row['kind']=='K':
  q=calls[row['name']];q['calls']+=1;q['sum_ms']+=(end-start)/1e6
busy=[(x['start'],x['end']) for x in records if x['kind']!='A']
regions={}
for phase in ['finishDetail.waitForGpu','correctedCollisionSolve','checkpoint']:
 scope=[(int(x['start_ns']),int(x['end_ns'])) for x in phases['gpu'] if x['step']=='82' and x['phase']=='GpuDestruction.'+phase]
 union_ms=a.length(scope)/1e6;gpu_ms=a.length(a.intersect(scope,busy))/1e6
 regions[phase]={'wall_ms':union_ms,'gpu_active_ms':gpu_ms,'no_gpu_activity_ms':union_ms-gpu_ms}
cat=a.source_catalog();categories=collections.defaultdict(lambda:{'calls':0,'sum_ms':0})
for name,m in calls.items():
 c=a.classify(name,cat)[0];categories[c]['calls']+=m['calls'];categories[c]['sum_ms']+=m['sum_ms']
result['gpu']['first_impact_regions']=regions;result['gpu']['first_impact_kernel_categories']=dict(categories)
result['gpu']['first_impact_kernels']=[dict(name=k,**v) for k,v in sorted(calls.items(),key=lambda kv:-kv[1]['sum_ms'])]
for mode in ['trialDetail.','detail.']:
 scope=[x for x in phases['phases'] if x['step']=='82' and x['phase'].startswith('GpuDestruction.'+mode)]
 result['phases'][mode+'observed_host_union_ms']=a.length([(int(x['start_ns']),int(x['end_ns'])) for x in scope])/1e6
result['campaign']=json.loads((base/'campaign.json').read_text())
args.output.write_text(json.dumps(result,indent=2)+'\n')
print('PARTITION',json.dumps(result['phases']['partition'],indent=2))
print('REGIONS',json.dumps(regions,indent=2))
print('CATEGORIES',json.dumps(dict(categories),indent=2))
print('WINDOWS',json.dumps({n:result[n]['windows'] for n in frames},indent=2))
