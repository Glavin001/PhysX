#!/usr/bin/env python3
"""Capture repeatable inputs and trace provenance; never stops another GPU process.

One discarded warm-up run per case, interleaved untraced trials, then one host-scope
and repeated full-duration CUPTI captures per case. No per-frame warm-up exclusion can hide an impact.
"""
import argparse,gzip,shutil,hashlib,importlib.util,json,re,subprocess,sys,time,xml.etree.ElementTree as ET
from pathlib import Path
ROOT=Path(__file__).resolve().parents[2]

def sha(path):
    h=hashlib.sha256()
    with path.open('rb') as f:
        for b in iter(lambda:f.read(1024*1024),b''):h.update(b)
    return h.hexdigest()

def compress_csv(directory):
    """Lossless, deterministic storage after capture; never inside timed simulation."""
    for source in sorted(directory.glob('*.csv')):
        destination=source.with_suffix('.csv.gz')
        if destination.exists():raise RuntimeError(f'Conflicting raw/compressed capture: {source}')
        temporary=destination.with_suffix('.gz.tmp')
        with source.open('rb') as incoming,temporary.open('wb') as raw:
            with gzip.GzipFile(filename='',mode='wb',fileobj=raw,mtime=0,compresslevel=1) as outgoing:
                shutil.copyfileobj(incoming,outgoing)
        temporary.rename(destination)
        source.unlink()

def gpu():
    xml=subprocess.check_output(['nvidia-smi','-q','-x'],text=True)
    devices=[]
    for g in ET.fromstring(xml).findall('gpu'):
        devices.append({'name':g.findtext('product_name'),'uuid':g.findtext('uuid'),
          'temperature':g.findtext('temperature/gpu_temp'),'clock':g.findtext('clocks/graphics_clock'),
          'utilization':g.findtext('utilization/gpu_util'),'memory_used':g.findtext('fb_memory_usage/used'),
          'processes':[{'pid':int(p.findtext('pid')),'name':p.findtext('process_name'),'type':p.findtext('type')}
                       for p in g.findall('processes/process_info')]})
    if len(devices)!=1:raise RuntimeError('This campaign requires exactly one visible physical GPU; select/adapt the device explicitly')
    return {'unix_seconds':time.time(),'driver':ET.fromstring(xml).findtext('driver_version'),'devices':devices}

def main():
    p=argparse.ArgumentParser(description=__doc__);p.add_argument('output',type=Path)
    p.add_argument('--config',type=Path,default=ROOT/'tools/profiles/wall-penetration-timing.json')
    p.add_argument('--binary',type=Path,default=ROOT/'out/destruction-sdk/reference/native_destruction_demo')
    p.add_argument('--resume',action='store_true');p.add_argument('--trials',type=int,default=5);p.add_argument('--seconds',type=int,default=10);p.add_argument('--gpu-trials',type=int,default=3);p.add_argument('--gpu-trace-buffer-mb',type=int,default=512)
    p.add_argument('--report-output',type=Path,help='Generated report directory (default: CAPTURE/report)')
    p.add_argument('--failure-campaign',type=Path,help='Retain failed earlier capture attempts as explicit report evidence')
    args=p.parse_args()
    if args.trials<2 or args.seconds<3 or args.gpu_trials<1 or not 16<=args.gpu_trace_buffer_mb<=4096:raise ValueError('At least two trials and three seconds required')
    args.output=args.output.resolve();args.output.mkdir(parents=True,exist_ok=args.resume)
    config=json.loads(args.config.read_text());binary=args.binary.resolve()
    linked=subprocess.check_output(['ldd',str(binary)],text=True)
    libs=[Path(line.split('=>',1)[1].strip().split()[0]) for line in linked.splitlines() if '=>' in line and line.split('=>',1)[1].strip().startswith('/')]
    artifacts=sorted(set([binary,*libs,*list((ROOT/'physx/bin/linux.x86_64/release').glob('*.so'))]))
    manifest={'schema':1,'config':config,'config_sha256':sha(args.config),'seconds':args.seconds,'gpu_seconds':args.seconds,'gpu_trials':args.gpu_trials,'gpu_trace_buffer_mb':args.gpu_trace_buffer_mb,'trials':args.trials,
      'revision':subprocess.check_output(['git','rev-parse','HEAD'],cwd=ROOT,text=True).strip(),
      'git_status':subprocess.check_output(['git','status','--porcelain'],cwd=ROOT,text=True),
      'binary':str(binary),'artifacts':{str(f):sha(f) for f in artifacts},'ldd':linked,
      'runner_sha256':sha(Path(__file__)),'runs':[],'status':'running',
      'warmup':'One separate process per case is discarded. All measured frames, including first impact and first allocation, are retained.',
      'monitor':'Require no GPU process before/after and at most one stable GPU PID during each run. GPU PIDs are in the host namespace; ownership is inferred from this lifecycle, not a container PID comparison. Clocks are observed, not locked.'}
    if args.failure_campaign:
        previous=json.loads(args.failure_campaign.read_text())
        manifest['prior_failure_evidence']={'manifest':str(args.failure_campaign.resolve()),'sha256':sha(args.failure_campaign),
            'attempts':previous.get('failed_attempts',[])+[r for r in previous['runs'] if r.get('exit_code')!=0]}
    manifest_path=args.output/'campaign.json'
    if args.resume:
        previous=json.loads(manifest_path.read_text())
        if any(previous[k]!=manifest[k] for k in ['config','seconds','gpu_seconds','gpu_trials','gpu_trace_buffer_mb','trials','artifacts']):raise RuntimeError('Resume inputs or executable artifacts changed')
        previous.setdefault('runner_revisions',[]).append(manifest['runner_sha256'])
        failed=[r for r in previous['runs'] if r.get('exit_code')!=0]
        for r in failed:
            r['campaign_error']=previous.get('error')
            directory=args.output/r['name']
            if directory.exists():r['files']={str(f.relative_to(directory)):sha(f) for f in sorted(directory.iterdir()) if f.is_file()}
        previous.setdefault('failed_attempts',[]).extend(failed)
        previous['runs']=[r for r in previous['runs'] if r.get('exit_code')==0]
        for r in previous['runs']:
            for f,h in r['files'].items():
                if sha(args.output/r['name']/f)!=h:raise RuntimeError('Completed capture changed before resume')
        previous['status']='running';previous.pop('error',None);manifest=previous
    def save():manifest_path.write_text(json.dumps(manifest,indent=2)+'\n')
    modes=[('warmup',0,c) for c in config['cases']]
    modes += [('plain',i,c) for i in range(args.trials) for c in config['cases']]
    modes += [('phases',0,c) for c in config['cases']]
    modes += [('gpu',i,c) for i in range(args.gpu_trials) for c in config['cases']]
    save()
    try:
        for mode,trial,case in modes:
            if any(r['case']==case['id'] and r['mode']==mode and r['trial']==trial for r in manifest['runs']):continue
            name=f"{case['id']}-{mode}-{trial}"
            attempt=sum(r['case']==case['id'] and r['mode']==mode and r['trial']==trial for r in manifest.get('failed_attempts',[]))
            if attempt:name+=f'-retry{attempt}'
            out=args.output/name
            cmd=[str(binary),*config['common'],*case['args'],'--seconds',str(args.seconds),'--output',str(out),
                 '--gpu-trace-buffer-mb',str(args.gpu_trace_buffer_mb),'--profile-phases','0' if mode in ('plain','warmup') else '1','--profile-gpu','1' if mode=='gpu' else '0']
            record={'name':name,'case':case['id'],'mode':mode,'trial':trial,'command':cmd,'samples':[]};manifest['runs'].append(record);save()
            print('RUN',name,flush=True)
            before=gpu();record['samples'].append(before)
            if any(g['processes'] for g in before['devices']):raise RuntimeError('GPU has another process; no services were stopped')
            with (args.output/(name+'.log')).open('w') as log:
                process=subprocess.Popen(cmd,cwd=ROOT,stdout=log,stderr=subprocess.STDOUT)
                record['pid']=process.pid
                try:
                    while process.poll() is None:
                        sample=gpu();record['samples'].append(sample)
                        observed=[v for g in sample['devices'] for v in g['processes']]
                        if len(observed)>1:raise RuntimeError(f'Multiple GPU processes appeared: {observed}')
                        if observed:
                            pid=observed[0]['pid']
                            if 'gpu_pid' in record and record['gpu_pid']!=pid:raise RuntimeError('GPU process identity changed during run')
                            record['gpu_pid']=pid
                        if len(record['samples'])>1200:raise RuntimeError('Capture exceeded watchdog')
                        time.sleep(.25)
                    record['exit_code']=process.returncode
                except BaseException:
                    if process.poll() is None:process.terminate();process.wait(timeout=30)
                    raise
            record['samples'].append(gpu());save()
            if record['exit_code']:raise RuntimeError(f'Capture failed: {name}; inspect its log')
            if any(g['processes'] for g in record['samples'][-1]['devices']):raise RuntimeError('Foreign GPU process observed at capture end')
            compress_csv(out)
            record['csv_storage']='lossless gzip, mtime=0, after simulation'
            record['files']={str(f.relative_to(out)):sha(f) for f in sorted(out.iterdir()) if f.is_file()}
            record['log_sha256']=sha(args.output/(name+'.log'));save()
        if any(sha(Path(f))!=v for f,v in manifest['artifacts'].items()):raise RuntimeError('Binary or linked library changed during campaign')
        # Freeze kernel classification so report-only regeneration does not depend
        # on the current checkout's source files or symbol-catalog traversal.
        spec=importlib.util.spec_from_file_location('native_accounting',ROOT/'tools/scripts/analyze-native-gpu-profile.py')
        accounting=importlib.util.module_from_spec(spec);spec.loader.exec_module(accounting)
        source_catalog=accounting.source_catalog();names=set()
        for r in manifest['runs']:
            if r['mode']=='gpu':
                for line in (args.output/r['name']/'native.activity.names.tsv').read_text().splitlines():names.add(line.split('\t',1)[1])
        classification={name:accounting.classify(name,source_catalog) for name in sorted(names)}
        catalog_path=args.output/'kernel-classification.json';catalog_path.write_text(json.dumps(classification,indent=2,sort_keys=True)+'\n')
        manifest['kernel_classification']={'file':catalog_path.name,'sha256':sha(catalog_path)}
        prior=manifest.get('prior_failure_evidence')
        if prior:
            source=Path(prior['manifest'])
            if sha(source)!=prior['sha256']:raise RuntimeError('Prior failure manifest changed')
            for r in prior['attempts']:
                log=source.parent/(r['name']+'.log');text=log.read_text();r['log_sha256']=sha(log);r['log_path']=str(log)
                match=re.search(r'INCOMPLETE native step (\d+):.*',text)
                r['failure_step']=int(match.group(1)) if match else None
                r['error_line']=match.group(0) if match else next((line for line in text.splitlines() if 'error' in line.lower() or 'failed' in line.lower()),'See log')
                status_path=source.parent/r['name']/'native.activity.status.json'
                if status_path.exists():r['activity_status']=json.loads(status_path.read_text())
        manifest['status']='complete';save()
    except BaseException as e:
        manifest['status']='failed';manifest['error']=str(e);save();raise
    print('CAPTURE COMPLETE',manifest_path,flush=True)
    subprocess.run([sys.executable,str(ROOT/'tools/scripts/report-destruction-timing.py'),str(args.output),'--output',str(args.report_output or args.output/'report')],check=True)

if __name__=='__main__':main()
