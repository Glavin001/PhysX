#!/usr/bin/env python3
"""Capture native city states or replay the frozen large-scene catalog sequentially."""
import argparse,json,os,subprocess,sys
from pathlib import Path
root=Path(__file__).resolve().parents[3]
p=argparse.ArgumentParser(description=__doc__)
p.add_argument('mode',choices=['capture','replay'])
p.add_argument('output',type=Path)
p.add_argument('--binary',type=Path,required=True)
p.add_argument('--artifacts',type=Path,required=True)
p.add_argument('--repetitions',type=int,default=20)
p.add_argument('--sanitizer',choices=['memcheck','initcheck','synccheck'])
p.add_argument('--allow-existing-graphics',action='store_true')
p.add_argument('--allow-compute-pid',type=int,action='append',default=[])
p.add_argument('--run-prefix',default='file')
p.add_argument('--case',help='Exact catalog case, for replay')
a=p.parse_args();out=a.output.resolve();out.mkdir(parents=True,exist_ok=True)
profile=json.loads((root/'tools/profiles/destruction-snapshot-large.json').read_text())
wrapper=[sys.executable,str(Path(__file__).with_name('run-probe.py'))]
common=['--binary',str(a.binary.resolve()),'--artifacts',str(a.artifacts.resolve()),'--watchdog-seconds','600']
if a.sanitizer:common+=['--sanitizer',a.sanitizer]
if a.allow_existing_graphics:common+=['--allow-existing-graphics']
for pid in a.allow_compute_pid:common+=['--allow-compute-pid',str(pid)]
results=[]
if a.mode=='capture':
    config=out/'config';config.mkdir(exist_ok=True)
    native=json.loads((root/'tools/profiles/destruction-ordinary-ab.json').read_text())['common']
    for grid in profile['grids']:
        for regime in ['idle','bombardment']:
            target=out/f'capture-{grid}-{regime}'
            args=native+['--grid',str(grid),'--workload',regime,'--shot-path','aerial','--seconds','10','--steps','41' if regime=='idle' else '600']
            path=config/f'{grid}-{regime}.json';path.write_text(json.dumps(args,indent=2)+'\n')
            env=dict(os.environ,PHYSX_SNAPSHOT_STEPS=','.join(str(x['step']) for x in profile['states'] if x['regime']==regime))
            subprocess.run(wrapper+[str(target),*common,'--native-args-json',str(path)],env=env,check=True)
else:
    for grid in profile['grids']:
        for state in profile['states']:
            name=f"city{grid*grid}-{state['id']}"
            if a.case and a.case!=name:continue
            prefix=out/f"capture-{grid}-{state['regime']}"/'native'/f"snapshot-{state['step']}"
            target=out/f'{a.run_prefix}-{name}'
            command=wrapper+[str(target),*common,'--replay-prefix',str(prefix),'--repetitions',str(a.repetitions)]
            print(name,flush=True)
            result=subprocess.run(command)
            results.append(dict(scenario=name,exit_code=result.returncode,command=command))
            (out/f'{a.run_prefix}-campaign.json').write_text(json.dumps(results,indent=2)+'\n')
    if not results:raise SystemExit('No matching scenario')
    if any(x['exit_code'] for x in results):raise SystemExit(1)
