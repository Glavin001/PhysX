#!/usr/bin/env python3
"""Run tiered wall audits: early (32), screen (128), or frozen full (600 steps).

Motion observation streams through a FIFO to lossless gzip. This heavy audit
is intentionally not a performance qualification run.
"""
import argparse
import gzip
import hashlib
import importlib.util
import json
import os
from pathlib import Path
import shutil
import subprocess
import tempfile
import threading
import time

ROOT=Path(__file__).resolve().parents[2]


def sha(path):
    h=hashlib.sha256()
    with path.open('rb') as f:
        for block in iter(lambda:f.read(1024*1024),b''):h.update(block)
    return h.hexdigest()


def main():
    parser=argparse.ArgumentParser(description=__doc__)
    parser.add_argument('output',type=Path)
    parser.add_argument('--binary',type=Path,default=ROOT/'out/destruction-sdk/reference/native_destruction_demo')
    parser.add_argument('--standard-scene',action='store_true',help='Ordinary actor APIs, native sleeping, GPU-repaired sleep membership')
    parser.add_argument('--sleeping',type=int,choices=[0,1],default=1,help='Sleeping setting for the ordinary-API control')
    parser.add_argument('--expected-runtime',type=Path,help='Require this actual mapped destruction runtime (isolated candidate audit)')
    parser.add_argument('--tier',choices=['early','screen','full'],default='full')
    parser.add_argument('--reference',type=Path,help='Previously audited, mode-matched capture; required for prefixes')
    parser.add_argument('--video',action='store_true',help='Also encode the audited GPU-rendered penetration view')
    args=parser.parse_args();out=args.output.resolve();binary=args.binary.resolve()
    if args.tier!='full' and not args.reference:parser.error('--reference is required for prefix comparisons')
    steps={'early':32,'screen':128,'full':600}[args.tier]
    if out.exists():raise RuntimeError('Audit output already exists')
    out.parent.mkdir(parents=True,exist_ok=True)
    config_path=ROOT/'tools/profiles/wall-penetration-timing.json'
    golden=ROOT/'tools/profiles/wall-penetration-quality.json'
    config=json.loads(config_path.read_text())
    case=next(c for c in config['cases'] if c['id']=='penetration')
    cmd=[str(binary),*config['common'],*case['args'],'--seconds','10','--output',str(out)]
    if args.tier!='full':cmd+=['--steps',str(steps)]
    if args.standard_scene:
        cmd += ['--standard-scene','1','--sleeping',str(args.sleeping)]
        cmd[cmd.index('--gpu-connectivity-owner')+1]='0'
    if args.video:
        cmd += ['--gpu-video',str(out/'native.mp4'),'--gpu-camera','penetration','--color-by-cluster','1']
    for option in ['--record-state','--gpu-render','--audit-motion','--trace-motion']:
        cmd[cmd.index(option)+1]='1'
    artifacts=[binary]
    required_libraries={'libPhysXDestructionGpuRuntime_64.so','libPhysXGpuActivity_64.so'}
    record={'schema':1,'config_sha256':sha(config_path),'golden_sha256':sha(golden),
            'artifacts':{str(p):sha(p) for p in artifacts},'performance_qualification':False,'standard_scene':args.standard_scene,
            'tier':args.tier,'requested_steps':steps,'validator_sha256':sha(ROOT/'tools/scripts/verify-native-prefix.py') if args.tier!='full' else sha(ROOT/'tools/scripts/verify-native-penetration.py')}
    errors=[]
    with tempfile.TemporaryDirectory(prefix='penetration-observer-',dir=out.parent) as temp:
        fifo=Path(temp)/'motion.fifo';compressed=Path(temp)/'motion.csv.gz';os.mkfifo(fifo)
        def compress():
            try:
                with fifo.open('rb') as incoming,compressed.open('wb') as raw:
                    with gzip.GzipFile(filename='',fileobj=raw,mode='wb',mtime=0,compresslevel=1) as outgoing:
                        shutil.copyfileobj(incoming,outgoing)
            except Exception as error:errors.append(error)
        reader=threading.Thread(target=compress,daemon=True);reader.start()
        cmd+=['--motion-path',str(fifo)];record['command']=cmd
        log=out.with_suffix('.log')
        with log.open('x') as stream:
            started=time.monotonic()
            process=subprocess.Popen(cmd,stdout=stream,stderr=subprocess.STDOUT)
            deadline=time.monotonic()+300
            try:
                while process.poll() is None:
                    try:maps=Path(f'/proc/{process.pid}/maps').read_text()
                    except FileNotFoundError:maps=''
                    for line in maps.splitlines():
                        fields=line.split(maxsplit=5)
                        if len(fields)!=6:continue
                        path=Path(fields[5])
                        if path.name in required_libraries and str(path) not in record['artifacts']:
                            record['artifacts'][str(path)]=sha(path)
                    if time.monotonic()>deadline:raise TimeoutError('Audit simulation timed out')
                    time.sleep(.01)
            except BaseException:
                process.kill();process.wait();raise
        record['execution_seconds']=time.monotonic()-started
        record['exit_code']=process.returncode
        if out.exists():(out/'capture.json').write_text(json.dumps(record,indent=2)+'\n')
        if process.returncode:raise RuntimeError(f'Audit simulation failed; see {log}')
        reader.join(timeout=30)
        if reader.is_alive():raise RuntimeError('Motion compression did not finish')
        if errors:raise errors[0]
        compressed.rename(out/'native.motion.csv.gz')
    observed={Path(path).name:Path(path).resolve() for path in record['artifacts']}
    if not required_libraries.issubset(observed):raise RuntimeError('Audit did not observe all required GPU runtime modules')
    if args.expected_runtime and observed['libPhysXDestructionGpuRuntime_64.so']!=args.expected_runtime.resolve():
        raise RuntimeError('Audit loaded a different destruction runtime than requested')
    for path,digest in record['artifacts'].items():
        if sha(Path(path))!=digest:raise RuntimeError('Executable changed during audit')
    validation_started=time.monotonic()
    verifier='verify-native-penetration.py' if args.tier=='full' else 'verify-native-prefix.py'
    spec=importlib.util.spec_from_file_location('penetration',ROOT/'tools/scripts'/verifier)
    module=importlib.util.module_from_spec(spec);spec.loader.exec_module(module)
    if json.loads((out/'native.summary.json').read_text())['frames']!=steps:raise RuntimeError('Native run did not honor requested audit length')
    result=module.verify(out,golden) if args.tier=='full' else module.verify(out,args.reference.resolve(),steps)
    result['validation_seconds']=time.monotonic()-validation_started
    result['capture']=str(out);result['artifacts']=record['artifacts']
    (out/'quality.json').write_text(json.dumps(result,indent=2)+'\n')
    print(out/'quality.json')
    if result.get('status')=='failed':raise SystemExit(1)


if __name__=='__main__':main()
