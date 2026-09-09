#!/usr/bin/env python3
"""Isolated ABBA screen; never starts, stops or modifies a service."""
import argparse,hashlib,json,os,subprocess,time
from pathlib import Path
SDK=Path(__file__).resolve().parents[2]
ROOT=SDK/'out/native-settled-20260909'
OUT=ROOT/'screen'
LIVE=SDK/'physx/bin/linux.x86_64/release'
CANDIDATE=ROOT/'candidate'
BINARY=SDK/'out/vibe-native/release/examples/embedded_city_bench'
def sha(path):
    h=hashlib.sha256()
    with path.open('rb') as f:
        for block in iter(lambda:f.read(1024*1024),b''):h.update(block)
    return h.hexdigest()
def main():
    global ROOT,OUT,CANDIDATE,BINARY
    parser=argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--capture',type=Path,default=ROOT)
    parser.add_argument('--reports',type=Path,default=SDK/'qualification/native-settled-20260909')
    parser.add_argument('--scene',help='Existing consumer scene filename')
    parser.add_argument('--commands',type=Path,help='Existing recorded command tape for an explicit scene')
    parser.add_argument('--baseline-runtime',type=Path,default=LIVE/'libPhysXDestructionGpuRuntime_64.so',help='Immutable baseline runtime; defaults to the recorded live baseline')
    parser.add_argument('--title',default='Exact settled stress reuse',help='Mechanism named in the generated reports')
    parser.add_argument('--steps',type=int,default=600,help='Recorded-command prefix length; default is the full 600-step screen')
    parser.add_argument('--gpu-module',type=Path,default=LIVE/'libPhysXGpuActivity_64.so',help='Matching immutable GPU module')
    parser.add_argument('--benchmark',type=Path,default=BINARY,help='Matching immutable consumer binary')
    args=parser.parse_args()
    if not 31<=args.steps<=36000:parser.error('--steps must be 31..36000')
    gpu_module=args.gpu_module.resolve();BINARY=args.benchmark.resolve()
    if gpu_module.name!='libPhysXGpuActivity_64.so' or not gpu_module.is_file():parser.error('invalid --gpu-module')
    if not BINARY.is_file():parser.error('invalid --benchmark')
    if bool(args.scene)!=bool(args.commands):parser.error('--scene and --commands must be supplied together')
    baseline=args.baseline_runtime.resolve()
    if baseline.name!='libPhysXDestructionGpuRuntime_64.so' or not baseline.is_file():parser.error('--baseline-runtime must name an existing native runtime library')
    ROOT=args.capture.resolve();OUT=ROOT/'screen';CANDIDATE=ROOT/'candidate'
    OUT.mkdir(parents=True,exist_ok=False)
    receipt={'schema':1,'sequence':[],'benchmark_sha256':sha(BINARY),'service_changes':False,'steps':args.steps,'prefix_of_600_step_tape':args.steps<600}
    for ordinal,arm in enumerate(['baseline','candidate','candidate','baseline']):
        runtime=baseline if arm=='baseline' else CANDIDATE/'libPhysXDestructionGpuRuntime_64.so'
        expected={runtime.name:runtime.resolve(),'libPhysXGpuActivity_64.so':gpu_module}
        env=os.environ.copy();env['LD_LIBRARY_PATH']=str(runtime.parent)+':'+str(gpu_module.parent)+':'+str(LIVE)+':/usr/local/cuda/lib64'
        env.pop('VIBE_EMBEDDED_AUDIT_EVERY_TICK',None)
        for regime,waves in [('idle','0'),('shots',str(min(3,1+(args.steps-31)//150)))]:
            apps=subprocess.check_output(['nvidia-smi','--query-compute-apps=pid,process_name','--format=csv,noheader'],text=True).strip()
            if apps:raise RuntimeError('GPU not isolated: '+apps)
            name=f'{ordinal+1}-{arm}-{regime}'
            cmd=[str(BINARY),str(OUT/name),'1' if args.scene else '8',str(args.steps),'0' if args.scene else waves]
            if args.scene:
                cmd.append(args.scene)
                if regime=='shots':cmd.append(str(args.commands.resolve()))
            entry={'name':name,'command':cmd,'expected':{k:{'path':str(v),'sha256':sha(v)} for k,v in expected.items()},'mapped':{}}
            print('START',name,flush=True)
            with (OUT/(name+'.log')).open('x') as log:
                process=subprocess.Popen(cmd,cwd=SDK.parent/'vibe-land-2',env=env,stdout=log,stderr=subprocess.STDOUT)
                while process.poll() is None:
                    try:maps=Path(f'/proc/{process.pid}/maps').read_text()
                    except FileNotFoundError:maps=''
                    for line in maps.splitlines():
                        fields=line.split(maxsplit=5)
                        if len(fields)!=6:continue
                        p=Path(fields[5]);key=p.name
                        if key in expected and key not in entry['mapped']:
                            entry['mapped'][key]={'path':str(p.resolve()),'sha256':sha(p)}
                    time.sleep(.02)
            entry['exit']=process.returncode;receipt['sequence'].append(entry)
            (OUT/'receipt.json').write_text(json.dumps(receipt,indent=2)+'\n')
            if process.returncode:raise RuntimeError('Benchmark failed: '+name)
            if entry['mapped']!=entry['expected']:raise RuntimeError('Loaded artifact mismatch: '+name)
            if sha(BINARY)!=receipt['benchmark_sha256']:raise RuntimeError('Benchmark changed during campaign')
            for p in expected.values():
                if sha(p)!=entry['expected'][p.name]['sha256']:raise RuntimeError('Runtime changed during capture')
            print('PASS',name,flush=True)
    for regime in ['idle','shots']:
        base=[OUT/f'{i}-baseline-{regime}' for i in [1,4]]
        candidate=[OUT/f'{i}-candidate-{regime}' for i in [2,3]]
        subprocess.run(['python3',str(SDK/'tools/scripts/compare-vibe-consumer-bench.py'),'--baseline',*map(str,base),'--candidates',*map(str,candidate),'--output',str(args.reports.resolve()/regime),'--title',args.title+' — '+regime],check=True)
if __name__=='__main__':main()
