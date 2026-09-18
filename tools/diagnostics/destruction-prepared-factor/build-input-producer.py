#!/usr/bin/env python3
"""Build both changed CUDA owners from an isolated, hashed preparation."""
import argparse
import fcntl
import hashlib
import json
from pathlib import Path
import shlex
import shutil
import subprocess
import time
ROOT=Path(__file__).resolve().parents[3]
STRESS='blast/source/sdk/extensions/stressgpu'
RUNTIME='physx/source/gpudestruction'
def sha(path):return hashlib.sha256(Path(path).read_bytes()).hexdigest()

def main():
    p=argparse.ArgumentParser(description=__doc__);p.add_argument('preparation',type=Path);args=p.parse_args()
    prep=args.preparation.resolve();manifest=json.loads((prep/'preparation.json').read_text());tree=prep/'source'
    assert manifest['status']=='prepared_not_built'
    for name,digest in manifest['files'].items():assert sha(tree/name)==digest
    out=prep/'build';out.mkdir(exist_ok=False)
    old=ROOT/'out/n24-component-multilevel-20260912';prior=json.loads((old/'build/build.json').read_text())
    record=dict(status='waiting',baseline_commit=manifest['baseline_commit'],candidate_patch_sha256=manifest['candidate_patch_sha256'],commands=[],outputs={},dependencies={})
    def save():(out/'build.json').write_text(json.dumps(record,indent=2)+'\n')
    def run(command,cwd,name):
        row=dict(argv=command,cwd=str(cwd),name=name);record['commands'].append(row);save();start=time.monotonic()
        with (out/(name+'.log')).open('x') as log:subprocess.run(command,cwd=cwd,stdout=log,stderr=subprocess.STDOUT,check=True,timeout=240)
        row['seconds']=time.monotonic()-start;save()
    def deps(path,cwd):
        for token in shlex.split(path.read_text().replace('\\\n',' ').split(':',1)[1]):
            source=Path(token);source=source if source.is_absolute() else Path(cwd)/source
            record['dependencies'][str(source)]=sha(source)
    with (ROOT/'out/destruction-ab.lock').open('a') as lease:
        fcntl.flock(lease,fcntl.LOCK_EX|fcntl.LOCK_NB)
        try:
            record['status']='building';save()
            # Preserve every frozen external stress-header dependency. Our
            # private source changes are separately covered by preparation hashes.
            for name,digest in prior['dependencies']['A'].items():
                path=Path(name)
                if not path.is_relative_to(old/'build/A/stressgpu'):assert sha(path)==digest
            for item in prior['inputs'].values():assert sha(item['copy'])==item['sha256']
            stress=out/'stress.o';dep=out/'stress.d';command=prior['commands'][0]['argv'].copy()
            command[command.index('-c')+1]=str(tree/STRESS/'NvBlastExtStressGpu.cu');command[command.index('-o')+1]=str(stress);command[command.index('-MF')+1]=str(dep)
            run(command,prior['commands'][0]['cwd'],'stress-build');deps(dep,prior['commands'][0]['cwd'])
            commands=json.loads((ROOT/'out/sdk-release/compile_commands.json').read_text())
            runtime_source=ROOT/RUNTIME/'src/PxgDestructionRuntime.cu'
            candidates=[c for c in commands if c['file']==str(runtime_source) and '-DBLAST_GPU_COMPONENT' not in c['command']]
            assert len(candidates)==1
            c=candidates[0];command=shlex.split(c['command']);runtime=out/'runtime.o';dep=out/'runtime.d'
            command[command.index('-c')+1]=str(tree/RUNTIME/'src/PxgDestructionRuntime.cu');command[command.index('-o')+1]=str(runtime)
            command=[token.replace(str(ROOT/RUNTIME),str(tree/RUNTIME)) for token in command]
            command+=['-I'+str(tree/STRESS),'-MD','-MF',str(dep)]
            run(command,c['directory'],'runtime-build');deps(dep,c['directory'])
            link=prior['commands'][1]['argv'].copy();link[link.index('-o')+1]=str(out/'libPhysXDestructionGpuRuntime_64.so')
            link=[str(stress) if x==str(old/'build/A/stress.o') else str(runtime) if Path(x).name=='PxgDestructionRuntime.cu.o' else x for x in link]
            record['reused_link_inputs']={x:sha(x) for x in link if Path(x).is_file() and x not in [str(stress),str(runtime)]}
            run(link,prior['commands'][1]['cwd'],'link')
            activity=ROOT/'out/destruction-baseline-20260913/artifacts/libPhysXGpuActivity_64.so';shutil.copy2(activity,out/activity.name)
            for name in ['libPhysXDestructionGpuRuntime_64.so',activity.name]:record['outputs'][str(out/name)]=sha(out/name)
            for name,digest in manifest['files'].items():assert sha(tree/name)==digest
            record['status']='built_not_gpu_qualified'
        except BaseException as error:record.update(status='failed',error=repr(error));raise
        finally:save()
    print(record['status'])
if __name__=='__main__':main()
