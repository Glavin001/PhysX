#!/usr/bin/env python3
"""Join device-wide PM samples to stress kernels from the same Nsight Systems run."""
import argparse,bisect,csv,json,math,sqlite3
from pathlib import Path


def analyze(capture):
    counters=capture/'counters'
    result=json.loads((counters/'result.json').read_text())
    if result['child_exit_code'] or result['overflow'] or not result['final_drain_complete']:
        raise ValueError('incomplete sampling run')
    frames=list(csv.DictReader((capture/'scene/native.frames.csv').open()))
    if not all(int(f['stress_converged'])==1 and int(f['correction_status'])==0
               and int(f['resim_passes'])<=1 and int(f['stress_passes'])==1+int(f['resim_passes']) for f in frames):
        raise ValueError('incomplete physical step')
    db=sqlite3.connect(f'file:{capture / "trace.sqlite"}?mode=ro',uri=True)
    epoch,_,_,steady=db.execute('select * from TARGET_INFO_SESSION_START_TIME').fetchone()
    rows=db.execute('select k.start,k.end,s.value from CUPTI_ACTIVITY_KIND_KERNEL k join StringIds s on s.id=k.shortName order by k.start').fetchall()
    kernels=[r for r in rows if 'componentStressSolve' in r[2]]
    if any(a[1]>b[0] for a,b in zip(kernels,kernels[1:])):
        raise ValueError('overlapping stress kernels make attribution ambiguous')
    expected=[(f,evaluation) for f in frames for evaluation in range(int(f['stress_passes']))]
    if len(kernels)!=len(expected):raise ValueError('stress evaluation/kernel count mismatch')
    clock=list(csv.DictReader((counters/'clock.csv').open()))
    offsets=[int(c['cupti_ns'])-(int(c['steady_before_ns'])+int(c['steady_after_ns']))//2 for c in clock]
    mismatch=max(abs(epoch-steady-o) for o in offsets)
    # Retain every raw record. Exclude flagged records and boundary samples from
    # attribution; the margin covers one sampling period plus anchor discrepancy.
    margin=100000+mismatch
    samples=[];flagged=[]
    with (counters/'samples.csv').open() as source:
        for s in csv.DictReader(source):
            if s['timestamp_valid']!='1':flagged.append({k:s[k] for k in ['sample','start_ns','end_ns','overlap_ns']});continue
            samples.append((int(s['start_ns']),int(s['end_ns']),
                float(s['sm__warps_active_realtime.avg.pct_of_peak_sustained_elapsed']),
                float(s['sm__inst_executed_realtime.avg.per_cycle_elapsed']),float(s['dram__bytes.sum'])))
            if not all(math.isfinite(v) for v in samples[-1]):raise ValueError('nonfinite counter sample')
    starts=[s[0] for s in samples];records=[]
    for ordinal,((begin,end,name),(f,evaluation)) in enumerate(zip(kernels,expected)):
        if begin+steady<int(f['simulation_start_ns'])-margin or end+steady>int(f['simulation_end_ns'])+margin:
            raise ValueError('kernel does not belong to expected physical step')
        lo,hi=begin+epoch+margin,end+epoch-margin
        first=bisect.bisect_left(starts,lo);last=bisect.bisect_right(starts,hi)
        selected=[s for s in samples[first:last] if s[1]<=hi]
        duration=sum(s[1]-s[0] for s in selected)
        other=sum(max(0,min(end,y)-max(begin,x)) for x,y,n in rows if n!=name and x<end and y>begin)
        records.append(dict(ordinal=ordinal,step=int(f['step']),evaluation='trial' if not evaluation else 'correction',
            kernel_ms=(end-begin)/1e6,sample_count=len(selected),sampled_ms=duration/1e6,
            interior_coverage=duration/(hi-lo) if hi>lo else None,other_kernel_overlap_ms=other/1e6,
            resident_warps_pct=sum((s[1]-s[0])*s[2] for s in selected)/duration if duration else None,
            instructions_per_sm_cycle=sum((s[1]-s[0])*s[3] for s in selected)/duration if duration else None,
            dram_gb_per_second=sum(s[4] for s in selected)/duration if duration else None))
    return dict(schema=1,scope='device-wide samples during kernel interiors; desktop contexts included',
                steps=len(frames),kernels=len(kernels),sampling=result,excluded_samples=flagged,
                boundary_margin_ns=margin,clock_anchor_discrepancy_ns=mismatch,
                nsys_warnings=[r[0] for r in db.execute('select text from DIAGNOSTIC_EVENT where severity>=2')],
                records=records)


def main():
    p=argparse.ArgumentParser(description=__doc__);p.add_argument('capture',type=Path);p.add_argument('--output',type=Path,required=True)
    args=p.parse_args();data=analyze(args.capture.resolve());args.output.write_text(json.dumps(data,indent=2)+'\n')
    print('step phase kernel_ms samples coverage resident_warps_pct inst_per_sm_cycle dram_GB_s')
    for r in data['records']:
        if r['step'] in (82,87,108):
            print(r['step'],r['evaluation'],*[round(r[k],3) if isinstance(r[k],float) else r[k] for k in
                ['kernel_ms','sample_count','interior_coverage','resident_warps_pct','instructions_per_sm_cycle','dram_gb_per_second']])


if __name__=='__main__':main()
