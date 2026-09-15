#!/usr/bin/env python3
"""Report transfer exposure without treating overlapping time as removable cost."""
import argparse,collections,importlib.util,json,sqlite3
from pathlib import Path
spec=importlib.util.spec_from_file_location('profile',Path(__file__).with_name('analyze-profile.py'))
profile=importlib.util.module_from_spec(spec);spec.loader.exec_module(profile)
accounting=profile.accounting

def census(copies,kernels):
    spans=lambda rows:[(r['start_ns'],r['end_ns']) for r in rows]
    copy_spans=spans(copies);kernel_spans=spans(kernels)
    total=accounting.length(copy_spans)/1e6
    overlap=accounting.length(accounting.intersect(copy_spans,kernel_spans))/1e6
    directions={}
    for kind in sorted({r['kind'] for r in copies}):
        selected=[r for r in copies if r['kind']==kind]
        directions[kind]=dict(count=len(selected),bytes=sum(r['bytes'] for r in selected),aggregate_ms=sum(r['ms'] for r in selected),union_ms=accounting.length(spans(selected))/1e6)
    scopes=collections.defaultdict(list)
    for r in copies:scopes[r.get('launch_scope') or 'unattributed'].append(r)
    return dict(count=len(copies),bytes=sum(r['bytes'] for r in copies),boundary_crossing_copies=sum(r.get('boundary_clipped',False) for r in copies),copy_union_ms=total,copy_kernel_overlap_ms=overlap,copy_without_kernel_ms=total-overlap,directions=directions,
        launch_scopes=[dict(scope=n,count=len(rs),bytes=sum(r['bytes'] for r in rs),aggregate_ms=sum(r['ms'] for r in rs)) for n,rs in sorted(scopes.items(),key=lambda item:-sum(r['bytes'] for r in item[1]))])

def main():
    p=argparse.ArgumentParser(description=__doc__);p.add_argument('root',type=Path);p.add_argument('output',type=Path);a=p.parse_args()
    cpu=json.loads((a.root/'cpu-full/campaign.json').read_text());baselines=json.loads((a.output/'report.json').read_text())['scenarios_data'];rows=[]
    for c in cpu['scenarios']:
        assert c['status']=='complete';path=Path(c['path']);d=json.loads((path/'attribution.json').read_text());b=next(r['baseline'] for r in baselines if r['scenario']==c['scenario'])
        rows.append(dict(scenario=c['scenario'],source=str(path),unprofiled_mean_ms=b['tick_mean_ms'],unprofiled_peak_ms=b['tick_max_ms'],samples=b['n'],transfers=census(d['transfers'],d['kernels'])))
    warm=json.loads((a.root/'warm-reduced-sampling/campaign.json').read_text());warm_rows=[]
    for c in warm['cases']:
        path=Path(c['profile']);d=json.loads((path/'warm-attribution.json').read_text());db=sqlite3.connect(f'file:{path/"trace.sqlite"}?mode=ro',uri=True);db.row_factory=sqlite3.Row
        anchor=db.execute('select systemClockNs from TARGET_INFO_SESSION_START_TIME').fetchone()[0]
        frames=d['frames'];peak=max(frames,key=lambda f:f['profiled_complete_ms'])['step']
        for i in sorted({0,81,82,179,peak}):
            f=frames[i]['frame'];lo=int(f['complete_start_ns'])-anchor;hi=int(f['complete_end_ns'])-anchor
            def get(table):
                return [dict(r,start_ns=max(lo,r['start']),end_ns=min(hi,r['end']),boundary_clipped=r['start']<lo or r['end']>hi,ms=(min(hi,r['end'])-max(lo,r['start']))/1e6) for r in db.execute(f'select * from {table} where end>? and start<?',(lo,hi))]
            copies=get('CUPTI_ACTIVITY_KIND_MEMCPY')
            assert not any(r['boundary_clipped'] for r in copies),'Boundary copy bytes require separate upper-bound accounting'
            for r in copies:r['kind']=r['copyKind']
            warm_rows.append(dict(case=c['case'],step=i,profiled_peak_step=i==peak,profiled_complete_ms=frames[i]['profiled_complete_ms'],unlocated_timer_boundary_ms=frames[i]['unlocated_timer_boundary_ms'],transfers=census(copies,get('CUPTI_ACTIVITY_KIND_KERNEL'))))
    result=dict(scope='Transfers within complete-tick trace anchors only. Diagnostic durations overlap CPU/other GPU work and are not removable application time. Native clock-boundary residuals remain unlocated. Baselines exclude restore and validation.',directions={1:'Host-to-Device',2:'Device-to-Host',8:'Device-to-Device'},snapshots=rows,warm=warm_rows)
    (a.output/'dataflow.json').write_text(json.dumps(result,indent=2)+'\n')
    lines=['# Current transfer exposure','','The dependency order is correct. Contacts and stress inputs already stay on GPU. Fragment collision registration must finish before corrected physics; ordinary activity/sleep processing consumes trial body mirrors before final acceptance. The first structural opportunity remains batching fragment lifecycle work. Changed-state export is a separate, smaller hypothesis.','','The tables exclude restore, validation and observation exports. Copy-only time means no overlapping **kernel**, not idle CPU or removable critical-path time. These are diagnostic traces; only the separately identified unprofiled full-step columns are application measurements. Transfer sums must not be added to full-step times.','','| Snapshot | Unprofiled full step mean / peak ms (20) | H2D / D2H / D2D MB | Copy union / overlap with kernels / without kernels ms |','|---|---:|---:|---:|']
    def columns(r):
        t=r['transfers'];return ' / '.join(f'{t["directions"].get(k,{}).get("bytes",0)/1e6:.3f}' for k in [1,2,8])+' | '+' / '.join(f'{t[k]:.3f}' for k in ['copy_union_ms','copy_kernel_overlap_ms','copy_without_kernel_ms'])
    for r in rows:lines.append(f'| {r["scenario"]} | {r["unprofiled_mean_ms"]:.3f} / {r["unprofiled_peak_ms"]:.3f} | {columns(r)} |')
    lines+=['','## Continuous trace checkpoints','','Each workload has180 ordinary/sleeping ticks and113,664 chunks /229,376 bonds. Heavy uses256 projectiles. Steps0/81/82/179 cover initialization, pre-impact, first fracture and later debris; each traced full-step peak is included too. [Unprofiled continuous mean/peak, stages and deadline counts](coverage-tiers.md) are separate.','','| Workload / step | Profiled full step ms | H2D / D2H / D2D MB | Copy union / overlap with kernels / without kernels ms |','|---|---:|---:|---:|']
    for r in warm_rows:lines.append(f'| {r["case"]} / {r["step"]}{" (trace peak)" if r["profiled_peak_step"] else ""} | {r["profiled_complete_ms"]:.3f} | {columns(r)} |')
    lines+=['','[Structured transfer directions and launch-scope attribution](dataflow.json). Every raw transfer, CUDA caller, stream and available engine scope remains in the corresponding `attribution.json`/Systems database. Missing scope attribution is explicit. No transfer removal or application speedup is established by this census.','']
    (a.output/'dataflow.md').write_text('\n'.join(lines));print(len(rows),'snapshot rows;',len(warm_rows),'continuous checkpoints')

if __name__=='__main__':main()
