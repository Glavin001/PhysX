#!/usr/bin/env python3
"""Account for the native phase replay of Vibe-land's embedded consumer benchmark."""
import argparse, collections, csv, gzip, importlib.util, json, math
from pathlib import Path
spec = importlib.util.spec_from_file_location('native_timing', Path(__file__).with_name('report-destruction-timing.py'))
t = importlib.util.module_from_spec(spec); spec.loader.exec_module(t)


def generate(capture, output, fracture_peak=False):
    report = json.loads((capture/'report.json').read_text())
    frames = json.loads((capture/'steps.json').read_text())
    assert report['status'] == 'complete' and report['instrumented']
    assert len(frames) == report['steps']
    names = [collections.defaultdict(list) for _ in frames]
    host = [[] for _ in frames]
    device = [collections.defaultdict(float) for _ in frames]
    for row in csv.DictReader((capture/'native.phases.csv').open()):
        if row['accepted_step'] != '1': continue
        step = int(row['step']); assert 0 <= step < len(frames)
        start, end = int(row['start_ns']), int(row['end_ns']); assert start <= end
        names[step][row['phase'].removeprefix('GpuDestruction.')].append((start,end))
        host[step].append(row)
    for row in csv.DictReader((capture/'native.phases.csv.device.csv').open()):
        if row['accepted_step'] != '1': continue
        step = int(row['step']); value = float(row['cuda_elapsed_ms'])
        assert 0 <= step < len(frames) and math.isfinite(value) and value >= 0
        device[step][row['phase'].removeprefix('GpuDestruction.cuda.')] += value
    partitions = []
    for step, by in enumerate(names):
        assert len(by['consumerAdvance']) == 1
        boundary = by['consumerAdvance']
        for spans in by.values(): assert t.a.length(t.subtract(spans,boundary)) == 0
        assert 'stress' in device[step]
        partitions.append(t.partition(boundary,by))
    candidates = [i for i,r in enumerate(frames) if not fracture_peak or
                  r['broken_bonds'] > (frames[i-1]['broken_bonds'] if i else 0)]
    assert candidates, 'no fracture steps to select'
    selected = sorted(candidates,key=lambda i:-frames[i]['complete_step_ms'])[:10]
    peak = selected[0]
    data = dict(capture=report, selection='fracture' if fracture_peak else 'all', peak=peak, top_steps=selected, wall_partition=partitions, cuda_stages=device)
    output.mkdir(parents=True,exist_ok=False)
    (output/'analysis.json.gz').write_bytes(gzip.compress(json.dumps(data,separators=(',',':')).encode(),mtime=0))
    for source in ['native.phases.csv','native.phases.csv.device.csv','steps.json','commands.json']:
        (output/(source+'.gz')).write_bytes(gzip.compress((capture/source).read_bytes(),mtime=0))
    row=frames[peak]
    text=['# Native phases inside the Vibe-land consumer', '',
        f"**Diagnostic replay**, {report['buildings']} buildings, {report['chunks']:,} chunks, "
        f"{report['bonds']:,} bonds, {report['projectiles']} rounds over {len(frames)} steps / {report['seconds']:g} simulated seconds. "
        'Direct GPU API off, sleep on, correction ≤1. This instrumented replay is separate from the untraced deadline result.', '',
        f"Peak {'fracture ' if fracture_peak else ''}tick **{peak}**, complete advance **{row['complete_step_ms']:.3f} ms**: "
        f"{row['fragment_bodies']:,} fragments / {row['awake_fragment_bodies']:,} awake, "
        f"{row['projectiles']} projectiles present, {row['normal_contacts']:,} reported normal-contact count, "
        f"{row['broken_bonds']:,} cumulative broken bonds, {row['native_corrections']} correction(s).", '',
        '## Disjoint wall-time accounting', '',
        '| Responsibility | Owner / meaning | Peak ms | Mean across 10 worst steps, ms |',
        '|---|---|---:|---:|']
    for key in sorted(partitions[peak],key=lambda k:-sum(partitions[i][k] for i in selected)):
        mean=sum(partitions[i][key] for i in selected)/len(selected)
        if mean<.01 and partitions[peak][key]<.01: continue
        label, meaning=t.LABELS[key]
        if key=='trial.other': label='Other trial/game work'; meaning='Trial physics, commands, game observations and remaining task/driver gaps'
        text.append(f'| {label} | {meaning} | {partitions[peak][key]:.3f} | {mean:.3f} |')
    text += ['', 'Small rows omitted from display remain in the archived accounting. The complete partition '
        'sums to the profiler’s outer advance interval; its FFI/timestamp bookends slightly exceed the Rust timer.', '',
        '## CUDA destruction stages at this peak', '',
        'These durations overlap the wall table above. **Do not add them to it.** Each row sums the '
        'trial and corrected evaluation where present; device intervals are not hardware utilization counters.', '',
        '| Stage | CUDA ms |', '|---|---:|']
    for key,value in sorted(device[peak].items(),key=lambda kv:-kv[1]):
        text.append(f'| {t.STAGES.get(key,key)} | {value:.3f} |')
    text += ['', '## Nested correction/task exposure', '',
        'These scopes can nest or execute concurrently: **not additive**. Thread CPU time is core-time, '
        'not elapsed wall time. The refilter scope belongs to our correction orchestration; it is not ordinary PhysX workload.', '',
        '| Scope | Union wall ms | Reported thread CPU ms |', '|---|---:|---:|']
    details=[]
    for key,spans in names[peak].items():
        if key=='refilter' or key=='reportRepair' or key.startswith(('detail.','task.')):
            cpu=sum(max(0,float(r['thread_cpu_ms'])) for r in host[peak] if r['phase']=='GpuDestruction.'+key)
            details.append((key,t.a.length(spans)/1e6,cpu))
    for key,wall,cpu in sorted(details,key=lambda v:-v[1])[:20]:text.append(f'| {key} | {wall:.3f} | {cpu:.3f} |')
    text+=['','[All phase partitions and CUDA intervals](analysis.json.gz). Raw host/device phase streams, accepted '
        'step samples and recorded commands are archived alongside the report. This analysis establishes cost exposure, '
        'not a promised saving or proof that a GPU kernel is bandwidth/compute bound.','']
    (output/'report.md').write_text('\n'.join(text));print(output/'report.md')

if __name__=='__main__':
    p=argparse.ArgumentParser(description=__doc__);p.add_argument('capture',type=Path);p.add_argument('output',type=Path)
    p.add_argument('--fracture-peak',action='store_true')
    args=p.parse_args();generate(args.capture,args.output,args.fracture_peak)
