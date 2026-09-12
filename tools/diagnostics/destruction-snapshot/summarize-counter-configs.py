#!/usr/bin/env python3
"""Join ordinary-kernel counter ranges to their matched timeline significance.

Representative counter records are not a duration-weighted average or a model of
application speedup. Graph-node counters belong to the separate graph tier.
"""
import argparse, collections, importlib.util, json, math
from pathlib import Path

spec=importlib.util.spec_from_file_location('tiers',Path(__file__).with_name('report-attribution-tiers.py'))
tiers=importlib.util.module_from_spec(spec);spec.loader.exec_module(tiers)
METRICS={
    'gpu__time_duration.sum':None,
    'launch__registers_per_thread':None,
    'sm__warps_active.avg.pct_of_peak_sustained_active':(0,100),
    'sm__throughput.avg.pct_of_peak_sustained_elapsed':(0,100),
    'smsp__warps_eligible.avg.per_cycle_active':None,
    'smsp__issue_active.avg.pct_of_peak_sustained_active':(0,100),
    'dram__bytes.sum.per_second':None,
    'l1tex__t_sector_hit_rate.pct':(0,100),
    'lts__t_sector_hit_rate.pct':(0,100),
    'l1tex__t_sectors_pipe_lsu_mem_local_op_ld.sum':None,
    'l1tex__t_sectors_pipe_lsu_mem_local_op_st.sum':None,
}

def ranges(records):
    result={}
    for name,bounds in METRICS.items():
        valid=collections.defaultdict(list);invalid=[];missing=0
        for i,r in enumerate(records):
            metric=r['metrics'].get(name);v=metric.get('value') if metric else None
            if v is None:missing+=1;continue
            if not isinstance(v,(int,float)) or not math.isfinite(v) or v<0 or (bounds and not bounds[0]<=v<=bounds[1]):
                invalid.append(dict(record=i,metric=metric));continue
            # Preserve units explicitly. Never compare us with ms or bytes/s
            # with Gbytes/s as though their numeric values were interchangeable.
            valid[metric.get('unit','')].append(v)
        result[name]=dict(by_unit={u:dict(min=min(v),max=max(v),count=len(v)) for u,v in valid.items()},missing=missing,invalid=invalid)
    return result

def main():
    p=argparse.ArgumentParser(description=__doc__);p.add_argument('root',type=Path);p.add_argument('output',type=Path);a=p.parse_args()
    campaign=tiers.campaign_view(a.root/'configs-full/campaign.json')
    baselines=json.loads((a.output/'report.json').read_text())['scenarios_data'];rows=[]
    for b in baselines:
        c=next((c for c in campaign['scenarios'] if c['scenario']==b['scenario']),None)
        row=dict(scenario=b['scenario'],unprofiled_baseline=b['baseline'],counter_status=c['status'] if c else 'not_captured',families=[])
        if c and c['status']=='complete' and c.get('path'):
            path=Path(c['path']);data=json.loads((path/'analysis.json').read_text());grouped=collections.defaultdict(list)
            for i,d in enumerate(data):grouped[d['name']].append(dict(d,capture_record=i))
            row.update(source=str(path),report_sha256=c['report_sha256'],selection=c['selection'])
            for t in sorted(c['selection']['targets'],key=lambda t:-t['aggregate_ms']):
                records=grouped[t['name']];assert records
                row['families'].append(dict(name=t['name'],timeline_ms=t['aggregate_ms'],timeline_invocations=t['launches'],counter_invocations=len(records),configurations=len(t['configs']),counter_records=[r['capture_record'] for r in records],metrics=ranges(records)))
        rows.append(row)
    result=dict(scope=__doc__,limits=['Per-family ranges are unweighted representative observations, not population averages.',
        'All raw metric fields and units remain in analysis.json and .ncu-rep. Missing and invalid values are explicit; invalid ratios are excluded from ranges.',
        'Timeline aggregate kernel time can overlap other work and is not removable complete-step time.',
        'Separate graph and selected-stress captures are needed for the graph tier. This report covers ordinary kernels only.'],scenarios=rows)
    (a.output/'ordinary-counter-summary.json').write_text(json.dumps(result,indent=2)+'\n')
    lines=['# Ordinary-kernel counter guide','','Ranked by matched Systems kernel duration, not replay duration. Each case includes its three largest ordinary families; the structured file contains every selected family. Register/occupancy ranges describe captured representatives across configurations and invocations. They are not weighted averages or speedup predictions. Graph work is reported separately.','','| Scenario | Unprofiled complete step mean / peak ms | Largest ordinary families: timeline aggregate ms |','|---|---:|---|']
    for r in rows:
        b=r['unprofiled_baseline'];names=[]
        for f in r['families'][:3]:
            label=f['name'].replace('|','\\|');label=label if len(label)<=85 else label[:82]+'…'
            names.append(f'{label}: {f["timeline_ms"]:.3f}')
        lines.append(f'| {r["scenario"]} | {b["tick_mean_ms"]:.3f} / {b["tick_max_ms"]:.3f} | '+('; '.join(names) or r['counter_status'])+' |')
    lines+=['','[Every selected family, configuration count and counter range](ordinary-counter-summary.json). [Graph-tier coverage and limitations](coverage-tiers.md).','']
    (a.output/'ordinary-counter-summary.md').write_text('\n'.join(lines));print(sum(r['counter_status']=='complete' for r in rows),'cases summarized')

if __name__=='__main__':main()
