#!/usr/bin/env python3
"""Sequential, reproducible native profiling matrix; never stops other GPU processes."""
import argparse, gzip, hashlib, json, os, shutil, subprocess, time
from pathlib import Path
ROOT=Path(__file__).resolve().parents[2]
def sha(path):
    h=hashlib.sha256()
    with path.open('rb') as f:
        for data in iter(lambda:f.read(1024*1024),b''):h.update(data)
    return h.hexdigest()
def gpu():
    return subprocess.run(['nvidia-smi','--query-gpu=timestamp,name,utilization.gpu,memory.used,power.draw,clocks.current.sm','--format=csv,noheader'],capture_output=True,text=True).stdout.strip()
def main():
    p=argparse.ArgumentParser(description=__doc__);p.add_argument('output',type=Path);p.add_argument('--seconds',type=int,default=12);p.add_argument('--trials',type=int,default=3);p.add_argument('--resume',action='store_true');p.add_argument('--controls',action='store_true');a=p.parse_args()
    a.output.mkdir(parents=True,exist_ok=a.resume)
    binary=ROOT/'out/destruction-sdk/reference/native_destruction_demo'
    files=[binary,*sorted((ROOT/'physx/bin/linux.x86_64/release').glob('*.so'))]
    changed=subprocess.check_output(['git','ls-files','--modified','--others','--exclude-standard','-z'],cwd=ROOT).decode().split('\0')
    manifest={'revision':subprocess.check_output(['git','rev-parse','HEAD'],cwd=ROOT,text=True).strip(),'artifacts':{str(f.relative_to(ROOT)):sha(f) for f in files},'modified_sources':{f:sha(ROOT/f) for f in changed if f and (ROOT/f).is_file()},'sleeping':False,'isolated':False,'conditions':gpu(),'processes':subprocess.run(['nvidia-smi','--query-compute-apps=pid,process_name,used_memory','--format=csv'],capture_output=True,text=True).stdout,'warmup_steps_excluded_in_analysis':60,'runs':[]}
    if a.resume:
        manifest=json.loads((a.output/'campaign.json').read_text())
        assert manifest['artifacts'][str(binary.relative_to(ROOT))]==sha(binary), 'binary changed during campaign'
    cases=[*(('idle',g,0) for g in (1,4,8,16)),('single-impact',16,0),*(('burst',g,1) for g in (1,4,8,16)),('sustained',16,7)]
    if a.controls:cases=[('free-6000',1,0),('free-24000',1,0),('free-96000',1,0),('idle',16,0),('single-impact',16,0),('burst',1,1),('burst',4,1),('burst',8,1)]
    for trial in range(a.trials):
        for case,grid,window in cases:
            trace=trial==0
            name=f'{case}-g{grid}-t{trial}'
            if any(r['name']==name for r in manifest['runs']):continue
            out=a.output/name
            command=[str(binary),'--output',str(out),'--grid',str(grid),'--waves','2','--seconds',str(a.seconds),'--workload','idle' if case.startswith('free-') else case if case in ('idle','single-impact') else 'bombardment','--launch-seconds',str(window),'--stress-iterations','8192','--profile-phases','1' if trace else '0','--profile-gpu','1' if trace else '0','--preserve-contact-pairs','1','--gpu-island-repair','1','--gpu-pre-solve-islands','1','--gpu-pre-solve-contacts','1','--gpu-pre-solve-support','1']
            if case.startswith('free-'):command+=['--free-bodies',case.split('-')[1]]
            record={'name':name,'case':case,'grid':grid,'trial':trial,'trace':trace,'command':command,'before':gpu(),'start_unix':time.time()}
            print('RUN',name,flush=True)
            with (a.output/(name+'.log')).open('w') as log:
                process=subprocess.Popen(command,cwd=ROOT,stdout=log,stderr=subprocess.STDOUT)
                samples=[]
                while process.poll() is None:
                    samples.append(gpu());time.sleep(1)
                record['exit_code']=process.returncode
            record.update(end_unix=time.time(),after=gpu(),gpu_samples=samples)
            manifest['runs'].append(record)
            if out.exists():
                for f in out.glob('*.csv'):
                    with f.open('rb') as src,gzip.open(str(f)+'.gz','wb',compresslevel=1) as dst:shutil.copyfileobj(src,dst)
                    f.unlink()
            (a.output/'campaign.json').write_text(json.dumps(manifest,indent=2)+'\n')
            print('DONE',name,'exit',record['exit_code'],flush=True)
            # Preserve incomplete runs as failures and continue independent cases.
if __name__=='__main__':main()
