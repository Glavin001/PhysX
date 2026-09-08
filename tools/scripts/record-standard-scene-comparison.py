#!/usr/bin/env python3
"""Record separate GPU-rendered load-analogue videos; never changes services."""
import argparse
import hashlib
import importlib.util
import json
from pathlib import Path
import subprocess
import sys

ROOT=Path(__file__).resolve().parents[2]
spec=importlib.util.spec_from_file_location('capture',ROOT/'tools/scripts/run-destruction-timing.py')
capture=importlib.util.module_from_spec(spec);spec.loader.exec_module(capture)


def main():
    p=argparse.ArgumentParser(description=__doc__)
    p.add_argument('output',type=Path)
    p.add_argument('--config',type=Path,default=ROOT/'tools/profiles/standard-scene-bombardment-comparison.json')
    p.add_argument('--case',action='append',required=True)
    p.add_argument('--seconds',type=int,default=30)
    args=p.parse_args(); args.output=args.output.resolve()
    args.output.mkdir(parents=True,exist_ok=False)
    config=json.loads(args.config.read_text());binary=ROOT/'out/destruction-sdk/reference/native_destruction_demo'
    selected=[c for c in config['cases'] if c['id'] in args.case]
    assert len(selected)==len(set(args.case))
    artifacts=[binary,ROOT/'physx/bin/linux.x86_64/release/libPhysXGpuActivity_64.so',ROOT/'physx/bin/linux.x86_64/release/libPhysXDestructionGpuRuntime_64.so']
    hashes={str(p):capture.sha(p) for p in artifacts}
    for case in selected:
        before=capture.gpu()
        if any(g['processes'] for g in before['devices']):
            raise RuntimeError('Another GPU process is running; no services were stopped')
        out=args.output/case['id'];common=config['common'].copy()
        common[common.index('--gpu-render')+1]='1'
        cmd=[str(binary),*common,*case['args'],'--seconds',str(args.seconds),'--output',str(out),
             '--record-fps','30','--gpu-camera','overview','--color-by-cluster','1',
             '--gpu-video',str(out/'native.mp4')]
        record=dict(command=cmd,artifacts=hashes,environment_before=before,
                    source_revision=subprocess.check_output(['git','rev-parse','HEAD'],cwd=ROOT,text=True).strip(),
                    isolated_performance_qualification=False,
                    scope='Separate video run; use unrendered campaign for primary timings.')
        manifest=args.output/(case['id']+'.capture.json')
        manifest.write_text(json.dumps(record,indent=2)+'\n')
        print('VIDEO',case['id'],flush=True)
        with (args.output/(case['id']+'.log')).open('x') as log:
            result=subprocess.run(cmd,cwd=ROOT,stdout=log,stderr=subprocess.STDOUT)
        record.update(exit_code=result.returncode,environment_after=capture.gpu())
        manifest.write_text(json.dumps(record,indent=2)+'\n')
        if result.returncode:
            raise RuntimeError(f'Video simulation failed: {case["id"]}; preserve log and partial output')
        assert all(capture.sha(Path(p))==h for p,h in hashes.items())
        summary=json.loads((out/'native.summary.json').read_text())
        assert summary['status']=='completed' and not summary['direct_gpu_mode'] and summary['sleeping']
        subprocess.run([sys.executable,str(ROOT/'tools/scripts/annotate-native-cluster-video.py'),str(out),str(out/'native.mp4'),str(out/'native-captioned.mp4')],check=True)
        record['files']={p.name:capture.sha(p) for p in out.iterdir() if p.is_file()}
        manifest.write_text(json.dumps(record,indent=2)+'\n')
        print('VIDEO COMPLETE',out/'native-captioned.mp4',flush=True)


if __name__=='__main__':main()
