#!/usr/bin/env python3
"""Continuous idle/heavy CPU attribution with matching unprofiled controls."""
import argparse,csv,hashlib,importlib.util,json,subprocess,sys,time
from pathlib import Path
ROOT=Path(__file__).resolve().parents[3]
spec=importlib.util.spec_from_file_location('compare',ROOT/'tools/scripts/compare-destruction-candidates.py')
compare=importlib.util.module_from_spec(spec);spec.loader.exec_module(compare)

def main():
    p=argparse.ArgumentParser(description=__doc__);p.add_argument('output',type=Path)
    p.add_argument('--binary',type=Path,required=True);p.add_argument('--artifacts',type=Path,required=True)
    p.add_argument('--args-root',type=Path,required=True);p.add_argument('--allow-existing-graphics',action='store_true')
    p.add_argument('--sampling-period',type=int,default=500000)
    p.add_argument('--resume',action='store_true')
    a=p.parse_args();out=a.output.resolve();out.mkdir(parents=True,exist_ok=a.resume)
    if a.resume:(out/('campaign-before-resume-'+str(time.time_ns())+'.json')).write_bytes((out/'campaign.json').read_bytes())
    record=dict(status='running',cases=[],scope='Continuous 180-tick idle/heavy diagnostic qualification. One unprofiled control per case is not a speedup comparison.')
    sha=lambda f:hashlib.sha256(f.read_bytes()).hexdigest()
    def save():(out/'campaign.json').write_text(json.dumps(record,indent=2)+'\n')
    def run(cmd,log):
        with log.open('a') as f:subprocess.run(cmd,stdout=f,stderr=subprocess.STDOUT,check=True)
    opts=['--allow-existing-graphics'] if a.allow_existing_graphics else []
    for case in ['idle-256','impacts-256']:
        entry=dict(case=case,status='running');record['cases'].append(entry);save()
        try:
            for mode in ['plain','profile']:
                args=json.loads((a.args_root/(case+'-warm-args.json')).read_text())
                if mode=='plain':args[args.index('--profile-phases')+1]='0'
                argfile=out/(case+'-'+mode+'-args.json');argfile.write_text(json.dumps(args,indent=2)+'\n')
                dest=out/(case+'-'+mode);cmd=[sys.executable,str(ROOT/'tools/diagnostics/destruction-snapshot/run-probe.py'),str(dest),'--binary',str(a.binary.resolve()),'--artifacts',str(a.artifacts.resolve()),'--native-args-json',str(argfile),'--watchdog-seconds','600',*opts]
                if mode=='profile':cmd+=['--profiler','nsys','--nsys-cpu','--nsys-sampling-period',str(a.sampling_period)]
                print(case,mode,flush=True)
                if a.resume and (dest/'receipt.json').exists():
                    previous=json.loads((dest/'receipt.json').read_text());assert previous['status']=='complete' and previous['binary_sha256']==sha(a.binary)
                    expected=[str(a.binary.resolve()),*args,'--output',str(dest/'native')]
                    assert previous['command'][-len(expected):]==expected
                    assert bool(previous.get('profiler'))==(mode=='profile')
                    if mode=='profile':assert previous['profiler'].get('cpu_sampling_period',500000)==a.sampling_period
                    assert {Path(k).name:v for k,v in previous['modules'].items()}=={f.name:sha(f) for f in a.artifacts.glob('*.so')}
                else:run(cmd,out/(case+'-'+mode+'.log'))
                entry[mode]=str(dest);save()
            plain=Path(entry['plain']);capture=Path(entry['profile'])
            if not (capture/'trace.sqlite').exists():run(['/opt/nvidia/nsight-systems/2026.3.2/bin/nsys','export','--type','sqlite','--output',str(capture/'trace.sqlite'),str(capture/'trace.nsys-rep')],capture/'export.log')
            run([sys.executable,str(ROOT/'tools/diagnostics/destruction-snapshot/analyze-warm-attribution.py'),str(capture)],capture/'analysis.log')
            rows=lambda d:list(csv.DictReader((d/'native/native.frames.csv').open()))
            before,after=rows(plain),rows(capture);assert len(before)==len(after)==180
            differences=[]
            for old,new in zip(before,after):
                assert old['step']==new['step'] and new['stress_converged']=='1' and int(new['resim_passes'])<=1
                for k in compare.FIELDS+['stress_iterations','stress_passes','post_correction_bonds_broken']:
                    if old[k]!=new[k]:differences.append(dict(step=new['step'],field=k,plain=old[k],profile=new[k]))
            graphs=[json.loads((d/'native/native.graph-diagnostics.json').read_text()) for d in [plain,capture]]
            assert all(not g['boundary_audit_failures'] and not g['registry_mismatch_fallbacks'] for g in graphs)
            entry.update(counter_differences=differences,physical_scope='Exact per-tick work/convergence/correction counters. This is not a body-pose/force equivalence proof.',trace_sha256=sha(capture/'trace.nsys-rep'))
            times=[float(r['complete_step_ms']) for r in before];peak=max(range(len(times)),key=times.__getitem__)
            summary=json.loads((plain/'native/native.summary.json').read_text())
            entry['unprofiled']=dict(samples=len(times),mean_ms=sum(times)/len(times),peak_ms=times[peak],peak_step=peak,
                misses_8ms=sum(t>8 for t in times),misses_120hz=sum(t>1000/120 for t in times),misses_60hz=sum(t>1000/60 for t in times),
                summary=summary,peak_work={k:before[peak][k] for k in compare.FIELDS+['stress_iterations']},
                stages_ms={k:sum(float(r[k]) for r in before)/len(before) for k in ['command_ms','physics_step_ms','completion_ms']})
            assert not differences,'Profile changed physical work counters; inspect preserved differences'
            entry['status']='complete';save()
        except BaseException as e:entry.update(status='failed',error=str(e));record['status']='failed';save();raise
    record['status']='complete';save();print('complete',out)

if __name__=='__main__':main()
