#!/usr/bin/env python3
"""Finish bounded regression validation after explicitly named attribution jobs.

Never pauses another job. Does not install, promote, benchmark, or commit code.
Each native/sanitizer tier owns the repository exclusion lock. Fresh output only.
"""
import argparse
import fcntl
import hashlib
import json
import os
from pathlib import Path
import subprocess
import sys
import time
ROOT=Path(__file__).resolve().parents[2]
p=argparse.ArgumentParser(description=__doc__)
p.add_argument('output',type=Path)
p.add_argument('--artifacts',type=Path,required=True)
p.add_argument('--wait-for',type=Path,action='append',default=[])
p.add_argument('--wait-hours',type=float,default=12)
a=p.parse_args();out=a.output.resolve();out.mkdir(parents=True,exist_ok=False)
def sha(path):return hashlib.sha256(path.read_bytes()).hexdigest()
paths=[ROOT/'tools/scripts/run-destruction-regression.py',ROOT/'tools/scripts/destruction_physics_contract.py',
       ROOT/'tools/scripts/verify-native-prefix.py',ROOT/'tools/diagnostics/destruction-snapshot/compare-observations.py',
       ROOT/'demos/blast-stress-demo/CMakeLists.txt',ROOT/'physx/source/gpudestruction/CMakeLists.txt',Path(__file__)]
r=dict(status='waiting_attribution',pid=os.getpid(),runs=[],sources={str(x):sha(x) for x in paths},
       wait_for=[str(x.resolve()) for x in a.wait_for],performance_qualification=False,
       scope='Fresh CPU/native/sanitizer validation and separate physical-model audit; no full52 rerun or runtime promotion')
def save():
    tmp=out/'validation.tmp';tmp.write_text(json.dumps(r,indent=2)+'\n');tmp.replace(out/'validation.json')
def unchanged():
    for path,digest in r['sources'].items():
        if sha(Path(path))!=digest:raise ValueError('Validation source changed while queued: '+path)
def run(name,cmd):
    unchanged();row=dict(name=name,command=[str(x) for x in cmd]);r['runs'].append(row);r.update(status='running',phase=name);save()
    start=time.monotonic()
    with (out/(name+'.log')).open('x') as log:
        result=subprocess.run(row['command'],cwd=ROOT,env=dict(os.environ,PYTHONDONTWRITEBYTECODE='1'),stdout=log,stderr=subprocess.STDOUT,timeout=2400)
    row.update(exit_code=result.returncode,wall_seconds=time.monotonic()-start);save();unchanged()
    return result.returncode
try:
    save();deadline=time.monotonic()+a.wait_hours*3600
    while True:
        states=[json.loads(path.read_text()) for path in a.wait_for]
        r['attribution_status']=[{k:s.get(k) for k in ('status','pid','phase','error')} for s in states];save()
        # A failed collector may be reviewed and resumed by its owning task.
        # Failure is not successful completion and never grants GPU admission.
        r['status']='waiting_attribution_recovery' if any(s['status'] in ('failed','primary_failed') for s in states) else 'waiting_attribution'
        save()
        if all(s['status']=='complete' for s in states):break
        if time.monotonic()>=deadline:raise TimeoutError('Attribution still owns priority; no job interrupted')
        time.sleep(10)
    unchanged()
    # Configure only; no production binaries or installed libraries are built.
    with (ROOT/'out/destruction-ab.lock').open('a') as lock:
        fcntl.flock(lock,fcntl.LOCK_EX)
        config=out/'ctest-config'
        cmd=[ROOT/'.toolchains/build-env/bin/cmake','-S',ROOT/'destruction','-B',config,
             '-DCMAKE_BUILD_TYPE=Release','-DCMAKE_CXX_COMPILER=/usr/bin/clang++',
             '-DCMAKE_CUDA_COMPILER=/usr/local/cuda-13.4/bin/nvcc','-DCMAKE_CUDA_ARCHITECTURES=120',
             '-DBUILD_TESTING=ON','-DBLAST_ENABLE_CUDA_STRESS=ON']
        if run('configure',cmd):raise RuntimeError('Fresh CMake configuration failed')
        data=json.loads(subprocess.check_output([str(ROOT/'.toolchains/build-env/bin/ctest'),'--test-dir',str(config),'--show-only=json-v1'],text=True))
        (out/'ctest-registration.json').write_text(json.dumps(data,indent=2)+'\n')
        tests=data['tests'];props={t['name']:{p['name']:p['value'] for p in t['properties']} for t in tests}
        if 'physx_native_physics_contract' not in props:raise ValueError('New native fixture missing from CTest')
        if any(not x.get('RUN_SERIAL') or 'destruction' not in x.get('LABELS',[]) for x in props.values()):
            raise ValueError('A destruction CTest lacks serialization or its label')
        r['ctest_count']=len(tests);save()
    runner=ROOT/'tools/scripts/run-destruction-regression.py'
    for tier in ('cpu','native','sanitizer','model-accuracy'):
        cmd=[sys.executable,runner,out/tier,'--tier',tier]
        if tier!='cpu':cmd+=['--artifacts',a.artifacts.resolve()]
        code=run(tier,cmd)
        if tier=='model-accuracy':
            if code:
                log=out/tier/'unequal-chunk-mass.log'
                if not log.exists() or 'native physical contract failed: independent axial equilibrium' not in log.read_text():
                    raise RuntimeError('Model audit did not reach its physical assertion; infrastructure failure is not the known model limitation')
            r['model_accuracy_status']='passed' if code==0 else 'failed'
            r['model_accuracy_receipt']=str(out/tier/'results.json')
        elif code:raise RuntimeError(tier+' regression tier failed; inspect preserved logs')
    r['regression_status']='passed'
    r['status']='passed_with_model_accuracy_failure' if r['model_accuracy_status']=='failed' else 'passed'
except BaseException as error:r.update(status='failed',error=repr(error));raise
finally:save()
