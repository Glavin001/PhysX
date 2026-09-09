from pathlib import Path
import json,subprocess,importlib.util,argparse
root=Path(__file__).resolve().parents[2];out=root/'out/contact-response-20260909/phases'
parser=argparse.ArgumentParser();parser.add_argument('--existing',action='store_true');args=parser.parse_args()
if out.exists() and not args.existing:raise RuntimeError('Capture already exists; pass --existing to validate it')
c=json.loads((root/'tools/profiles/wall-penetration-timing.json').read_text());case=c['cases'][0]
cmd=[str(root/'out/destruction-sdk/reference/native_destruction_demo'),*c['common'],*case['args'],'--steps','64','--seconds','10','--profile-phases','1','--standard-scene','1','--sleeping','1','--output',str(out)]
cmd[cmd.index('--gpu-connectivity-owner')+1]='0'
if not args.existing:
    with out.with_suffix('.log').open('x') as log:subprocess.run(cmd,stdout=log,stderr=subprocess.STDOUT,check=True)
spec=importlib.util.spec_from_file_location('report',root/'tools/scripts/report-destruction-timing.py');r=importlib.util.module_from_spec(spec);spec.loader.exec_module(r)
run=r.load_run(out,{'files':{}});profile=r.profile(out,run,{})
assert any(v['compatibility.allocateNativeBodies']>0 for v in profile['wall_partition'])
assert all(v['finishDetail.allocateNativeBodies']==0 for v in profile['wall_partition'])
spec=importlib.util.spec_from_file_location('phases',root/'tools/scripts/analyze-native-destruction-phases.py');a=importlib.util.module_from_spec(spec);spec.loader.exec_module(a)
analysis=a.analyze(out)
assert analysis['cuda_stages']['device_controlled_preparation']
assert all(v['collisionBindings']==0 and v['correctionBodies']==0 for v in profile['wall_partition'])
assert sum((v['finalPublication.other']+v['finalShapePublication'])>0 for v in profile['wall_partition'])==sum(int(f['resim_passes']) for f in run['frames'])
assert any((v['finalPublication.other']+v['finalShapePublication'])>0 for v in profile['wall_partition'])
assert any(v['finalShapePublication']>0 for v in profile['wall_partition'])
(out/'analysis.json').write_text(json.dumps(analysis,indent=2)+'\n')
(out/'accounting.json').write_text(json.dumps({'steps':len(run['frames']),'chunks':run['summary']['chunks'],'bonds':run['summary']['bonds'],'projectiles':run['summary']['projectiles'],'physical_signature':run['signature'],'complete_partition_valid':True,'compatibility_after_gpu_preparation':True,'final_publication_explicit_and_disjoint':True,'final_shape_publication_exercised':True,'performance_qualification':False},indent=2)+'\n')
print(out/'accounting.json')
