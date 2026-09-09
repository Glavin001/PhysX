#!/usr/bin/env python3
"""Separate phase attribution; no service changes, no deadline qualification."""
import hashlib,json,os,subprocess,time
from pathlib import Path
sdk=Path(__file__).resolve().parents[2]
root=sdk/'out/native-address-ownership-20260909'
out=root/'profile';out.mkdir(exist_ok=True)
live=sdk/'physx/bin/linux.x86_64/release'
binary=root/'profiled-bench'
def sha(p):
    with p.open('rb') as f:return hashlib.file_digest(f,'sha256').hexdigest()
receipt={'instrumented':True,'service_changes':False,'binary_sha256':sha(binary),'runs':[]}
previous=json.loads((out/'receipt.json').read_text()) if (out/'receipt.json').exists() else None
if previous and previous['binary_sha256']!=receipt['binary_sha256']:raise RuntimeError('Resume executable mismatch')
for arm,runtime in [('baseline',sdk/'out/native-defined-state-20260909/candidate/libPhysXDestructionGpuRuntime_64.so'),
                    ('candidate',root/'candidate/libPhysXDestructionGpuRuntime_64.so')]:
    apps=subprocess.check_output(['nvidia-smi','--query-compute-apps=pid,process_name','--format=csv,noheader'],text=True).strip()
    if apps:raise RuntimeError('GPU not isolated: '+apps)
    expected={p.name:{'path':str(p.resolve()),'sha256':sha(p)} for p in [runtime,runtime.parent/'libPhysXGpuActivity_64.so']}
    env=os.environ.copy();env['LD_LIBRARY_PATH']=str(runtime.parent)+':'+str(root/'candidate')+':'+str(live)+':/usr/local/cuda/lib64'
    env.pop('VIBE_EMBEDDED_AUDIT_EVERY_TICK',None)
    cmd=[str(binary),str(out/arm),'8','96','1'];mapped={}
    old=next((r for r in previous['runs'] if r['arm']==arm),None) if previous else None
    if old:
        if old['command']!=cmd or old['exit'] or old['mapped']!=expected:
            raise RuntimeError('Existing capture does not match the corrected artifact declaration')
        mapped=old['mapped'];exit_code=old['exit']
        print('VERIFIED EXISTING',arm,flush=True)
    else:
        print('START',arm,flush=True)
        with (out/(arm+'.log')).open('x') as log:
            process=subprocess.Popen(cmd,cwd=sdk.parent/'vibe-land-2',env=env,stdout=log,stderr=subprocess.STDOUT)
            while process.poll() is None:
                try:maps=Path(f'/proc/{process.pid}/maps').read_text()
                except FileNotFoundError:maps=''
                for line in maps.splitlines():
                    fields=line.split(maxsplit=5)
                    if len(fields)!=6:continue
                    p=Path(fields[5])
                    if p.name in expected and p.name not in mapped:mapped[p.name]={'path':str(p.resolve()),'sha256':sha(p)}
                time.sleep(.02)
        exit_code=process.returncode
    receipt['runs'].append({'arm':arm,'command':cmd,'expected':expected,'mapped':mapped,'exit':exit_code})
    (out/'receipt.json').write_text(json.dumps(receipt,indent=2)+'\n')
    if exit_code or mapped!=expected:raise RuntimeError('Failed diagnostic/attestation: '+arm)
    for name,entry in expected.items():
        if sha(Path(entry['path']))!=entry['sha256']:raise RuntimeError('Module changed during diagnostic')
    if sha(binary)!=receipt['binary_sha256']:raise RuntimeError('Executable changed during diagnostic')
    subprocess.run(['python3',str(sdk/'tools/scripts/report-vibe-consumer-phases.py'),str(out/arm),str(Path(__file__).parent/(arm+'-phases')),'--fracture-peak'],check=True)
    print('PASS',arm,flush=True)
