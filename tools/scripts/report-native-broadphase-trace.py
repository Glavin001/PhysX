#!/usr/bin/env python3
"""Explain one broad-phase task using synchronized CPU scopes and CUDA activity.

Consumes existing diagnostics only; these durations never replace untraced
complete-advance measurements or turn a failed deadline into a passing result.
"""
import argparse
import collections
import gzip
import importlib.util
import json
from pathlib import Path

spec=importlib.util.spec_from_file_location('timing',Path(__file__).with_name('report-destruction-timing.py'))
t=importlib.util.module_from_spec(spec);spec.loader.exec_module(t)


def collect(directory,step):
    summary=json.loads((directory/'native.summary.json').read_text())
    t.require(summary['status']=='completed','Simulation incomplete')
    status=json.loads((directory/'native.activity.status.json').read_text())
    t.validate_activity_status(status)
    frames=list(t.a.read_csv(directory/'native.frames.csv'))
    t.require(len(frames)==summary['frames'] and 0<=step<len(frames),'Invalid frame population')
    frame=frames[step];t.require(int(frame['step'])==step,'Frame identity mismatch')
    scopes=[r for r in t.a.read_csv(directory/'native.phases.csv')
            if int(r['step'])==step and r['phase']=='GpuDestruction.detail.postBroadPhase' and r['accepted_step']=='1']
    t.require(len(scopes)==1,'Expected exactly one correction broad-phase task')
    scope=scopes[0];start,end=int(scope['start_ns']),int(scope['end_ns'])
    t.require(int(frame['simulation_start_ns'])<=start<end<=int(frame['simulation_end_ns']),'Scope escapes simulation')
    names={int(a):b for a,b in (line.rstrip('\n').split('\t',1) for line in (directory/'native.activity.names.tsv').open())}
    busy=[];incremental=[];kernels=collections.defaultdict(lambda:{'calls':0,'elapsed_ms':0.})
    records=0
    for row in t.a.read_csv(directory/'native.activity.csv'):
        records+=1
        if row['kind'] not in ('K','M','C'):continue
        a,b=max(start,int(row['start_ns'])),min(end,int(row['end_ns']))
        if b<=a:continue
        busy.append((a,b))
        if row['kind']=='K':
            name=names[int(row['name_id'])];kernels[name]['calls']+=1;kernels[name]['elapsed_ms']+=(b-a)/1e6
            if name=='performIncrementalSAP':incremental.append((a,b))
    t.require(records==status['records'],'Activity record count mismatch')
    t.require(incremental,'Incremental broad phase not observed')
    files={str(p.resolve()):t.sha(p) for p in directory.glob('native.*') if p.is_file()}
    return {'capture':str(directory.resolve()),'files':files,'activity_status':status,
            'workload':{key:summary[key] for key in ['buildings','chunks','bonds','projectiles','frames','correction_limit']},
            'simulated_seconds':summary['frames']/60,'step':step,
            'complete_step_ms_in_instrumented_run':float(frame['complete_step_ms']),
            'broadphase_host_wall_ms':float(scope['host_wall_ms']),
            'broadphase_thread_cpu_ms_including_spin':float(scope['thread_cpu_ms']),
            'gpu_busy_union_within_scope_ms':t.a.length(busy)/1e6,
            'incremental_kernel_ms':t.a.length(incremental)/1e6,
            'kernels':dict(sorted(kernels.items(),key=lambda kv:-kv[1]['elapsed_ms']))}


def main():
    parser=argparse.ArgumentParser(description=__doc__)
    parser.add_argument('captures',nargs='+',help='Label=directory')
    parser.add_argument('--step',type=int,default=82)
    parser.add_argument('--output',type=Path,required=True)
    args=parser.parse_args();results=[]
    for entry in args.captures:
        label,path=entry.split('=',1);results.append({'label':label,**collect(Path(path),args.step)})
    base=results[0]
    t.require(all(r['workload']==base['workload'] for r in results),'Workload mismatch')
    doc=t.Document();doc.title('🔎 Correction broad phase: GPU execution versus CPU waiting',1)
    w=base['workload']
    doc.text(f"{w['buildings']} buildings, {w['chunks']} chunks, {w['bonds']} bonds, {w['projectiles']} projectiles. "
             f"Each capture covers {base['simulated_seconds']:g} simulated seconds at 1/60 s; correction limit {w['correction_limit']}. "
             f"The table isolates correction step {args.step}, not the maximum across all frames.")
    doc.text('These are separate instrumented CUDA/CPU diagnostics. Complete-step deadline decisions use the untraced campaigns. '
             'GPU intervals are clipped to the host broad-phase scope. Busy time is their union, so concurrent kernels and copies are not added twice. '
             'CPU thread time includes the existing spin wait; it is not evidence of additional collision computation on CPU.')
    doc.table(['Capture','Host broad-phase span ms','CPU thread time incl. spin ms','GPU busy union ms','Incremental SAP kernel ms'],[
        [r['label'],t.fmt(r['broadphase_host_wall_ms']),t.fmt(r['broadphase_thread_cpu_ms_including_spin']),
         t.fmt(r['gpu_busy_union_within_scope_ms']),t.fmt(r['incremental_kernel_ms'])] for r in results])
    doc.text('The original broad-phase span was dominated by GPU execution while the CPU waited. '
             'GPU warp lookup/report aggregation improves the measured kernel, but a single diagnostic comparison does not establish a repeatable end-to-end speedup. '
             'Hardware-counter collection was separately denied (ERR_NVGPUCTRPERM), so these timings do not establish an occupancy, bandwidth or arithmetic-throughput limit.')
    for r in results:
        doc.title(r['label']+' — observed kernels')
        doc.table(['Kernel','Calls overlapping scope','Summed clipped kernel ms'],[
            [name,values['calls'],t.fmt(values['elapsed_ms'])] for name,values in list(r['kernels'].items())[:12]])
        doc.text('Kernel rows can overlap; do not add them to the host task or the union total.')
    doc.title('Evidence')
    doc.table(['Capture','Directory','Dropped activity records'],[[r['label'],r['capture'],r['activity_status']['dropped']] for r in results])
    doc.save(args.output)
    with gzip.GzipFile(filename=str(args.output/'report.json.gz'),mode='wb',mtime=0) as f:
        f.write((json.dumps({'schema':1,'reporter_sha256':t.sha(Path(__file__)),'captures':results,'performance_qualified':False},indent=2,sort_keys=True)+'\n').encode())


if __name__=='__main__':main()
