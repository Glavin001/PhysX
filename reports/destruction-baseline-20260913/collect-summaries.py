#!/usr/bin/env python3
"""Extract an honest, compact cross-tier ledger; raw profiles remain in out/."""
import collections
import csv
import hashlib
import importlib.util
import json
from pathlib import Path

HERE=Path(__file__).resolve().parent
ROOT=HERE.parents[1]
BASE=ROOT/'out/destruction-baseline-20260913'


def load(path):
    return json.loads(path.read_text())


def union_ms(intervals):
    merged=[]
    for lo,hi in sorted(intervals):
        if merged and lo<=merged[-1][1]:merged[-1][1]=max(hi,merged[-1][1])
        else:merged.append([lo,hi])
    return sum(hi-lo for lo,hi in merged)/1e6


def main():
    base=load(HERE/'data/unprofiled-baseline.json')
    campaigns={name:load(BASE/name/'campaign.json') for name in ['cpu-full','graphs-full','configs-full','phase-only','warm'] if (BASE/name/'campaign.json').exists()}
    by_tier={k:{r.get('scenario',r.get('case')):r for r in d.get('scenarios',d.get('cases',[]))} for k,d in campaigns.items()}
    rows=[];artifacts=[]
    def artifact(p, sha=None):
        if p.exists():artifacts.append(dict(path=str(p),bytes=p.stat().st_size,sha256=sha or hashlib.sha256(p.read_bytes()).hexdigest(),hash_origin='completed collector receipt' if sha else 'summary builder'))
    spec=importlib.util.spec_from_file_location('accounting',BASE/'harness/tools/scripts/analyze-native-gpu-profile.py')
    accounting=importlib.util.module_from_spec(spec);spec.loader.exec_module(accounting)
    spec=importlib.util.spec_from_file_location('counter_summary',BASE/'harness/tools/diagnostics/destruction-snapshot/summarize-counter-configs.py')
    counter_summary=importlib.util.module_from_spec(spec);spec.loader.exec_module(counter_summary)
    for b in base['scenarios']:
        name=b['scenario'];row=dict(scenario=name,baseline=b,tiers={k:rs.get(name,{}).get('status','not_captured') for k,rs in by_tier.items() if k!='warm'})
        c=by_tier.get('cpu-full',{}).get(name)
        if c and c['status']=='complete':
            path=Path(c['path']);d=load(path/'attribution.json');cpu=d['cpu_attribution'];receipt=load(path/'receipt.json')
            assert d['physical_comparison']['status']=='passed'
            assert receipt['binary_sha256']==campaigns['cpu-full']['identity']['binary_sha256']
            assert {Path(k).name:v for k,v in receipt['modules'].items()}==campaigns['cpu-full']['identity']['modules']
            assert abs(sum(cpu['disjoint_wall'].values())-d['tick_ms'])<1e-6
            transfers=[]
            grouped=collections.defaultdict(list)
            for item in d['transfers']:grouped[item['kind']].append(item)
            for kind,items in grouped.items():
                transfers.append(dict(kind=kind,direction={1:'CPU to GPU',2:'GPU to CPU',8:'GPU to GPU'}.get(kind,'other; see CUPTI kind'),calls=len(items),bytes=sum(x['bytes'] for x in items),summed_ms=sum(x['ms'] for x in items),union_ms=union_ms((x['start_ns'],x['end_ns']) for x in items)))
            row['cpu_profile']=dict(path=str(path),tick_ms=d['tick_ms'],gpu_union_ms=d['gpu_activity_union_ms'],disjoint_wall=cpu['disjoint_wall'],kernel_count=d['kernel_count'],copy_count=d['copy_count'],copy_bytes=d['copy_bytes'],transfers=transfers,
                samples=cpu['samples'],unresolved_samples=cpu['unresolved_leaf_samples'],engine_scopes=cpu['nvtx_scope_count'],kernels=d['ranked_kernels'],scopes=sorted(cpu['scopes'],key=lambda x:-(x['exclusive_thread_cpu_ms'] or 0)),leaf=cpu['leaf'][:30],device_phases=d['device_phase_events'],diagnostics=d['diagnostics'])
            for f in ['receipt.json','physical-comparison.json','native.phases.csv','native.phases.csv.device.csv']:artifact(path/f)
            artifact(path/'trace.nsys-rep',c['trace_sha256'])
        for tier in ['graphs-full','configs-full']:
            c=by_tier.get(tier,{}).get(name)
            if c and c['status']=='complete':
                row[tier]={k:v for k,v in c.items() if k not in ['graph_inventory','selection']}
                if 'selection' in c:
                    row[tier]['selection']=c['selection']
                if c.get('path'):
                    path=Path(c['path']);artifact(path/'counters.ncu-rep',c['report_sha256']);artifact(path/'analysis.json');artifact(Path(c['physical_comparison']))
                    counters=load(path/'analysis.json');families=collections.defaultdict(list)
                    for entry in counters:families[entry['name']].append(entry)
                    row[tier]['counter_ranges']=[dict(name=n,records=len(v),metrics=counter_summary.ranges(v)) for n,v in families.items()]
                    row[tier]['counter_scope']='Unweighted ranges across captured records, preserving units, missing and invalid metrics; not a duration-weighted population mean or speedup estimate.'
        c=by_tier.get('phase-only',{}).get(name)
        if c and c['status']=='complete':
            path=Path(c['path']);raw=[r for r in csv.DictReader((path/'native.phases.csv').open()) if r['accepted_step']=='1']
            assert raw, 'No accepted-tick native scopes'
            grouped=collections.defaultdict(list)
            for r in raw:grouped[r['phase']].append(r)
            exclusive=accounting.exclusive_cpu(raw) if accounting else {}
            scopes=[dict(name=n,calls=len(v),host_wall_ms=sum(float(x['host_wall_ms']) for x in v),thread_cpu_ms=sum(max(0,float(x['thread_cpu_ms'])) for x in v),exclusive_thread_cpu_ms=exclusive.get(n)) for n,v in grouped.items()]
            row['phase_only']=dict(path=str(path),diagnostic_tick_ms=c['diagnostic_tick_ms'],recorded_step_labels=sorted({int(r['step']) for r in raw}),scopes=sorted(scopes,key=lambda x:-(x['exclusive_thread_cpu_ms'] or x['thread_cpu_ms'])),scope='Accepted-tick native clock/event instrumentation, no Nsight injection; diagnostic, not ordinary benchmark timing. Scope totals describe the recorded phase file; do not average them over the two replay samples.')
            artifact(path/'native.phases.csv',c['phase_sha256'])
        rows.append(row)
    status={k:dict(status=v['status'],complete=sum(r['status']=='complete' for r in by_tier[k].values()),expected=2 if k=='warm' else 52) for k,v in campaigns.items()}
    out=dict(scope='Separate unprofiled latency, CPU/GPU timelines, graph counters, representative ordinary counters and phase-only diagnostics. Missing tiers remain explicit; no measured optimization gain.',coverage=status,scenarios=rows)
    (HERE/'data/attribution-ledger.json').write_text(json.dumps(out,indent=2)+'\n')
    (HERE/'artifact-index.json').write_text(json.dumps(artifacts,indent=2)+'\n')
    lines=['# Baseline attribution coverage','', 'Profiled durations below are diagnostic. CPU scope times and kernel sums overlap and must not be added to the complete tick. Copy direction unions can overlap each other. All supported raw counters remain in the indexed reports; individual conditional graph node/source counters remain unavailable.', '', '| Scenario | CPU | Graph | Ordinary | Phase-only | Profiled tick / GPU union ms | GPU launches / copies |', '|---|---|---|---|---|---:|---:|']
    for r in rows:
        c=r.get('cpu_profile',{}); t=r['tiers'];vals=' / '.join(f'{c[k]:.3f}' for k in ['tick_ms','gpu_union_ms']) if c else '—'
        lines.append('| '+r['scenario']+' | '+' | '.join(t.get(k,'not_captured') for k in ['cpu-full','graphs-full','configs-full','phase-only'])+f" | {vals} | {c.get('kernel_count','—')} / {c.get('copy_count','—')} |")
    (HERE/'coverage.md').write_text('\n'.join(lines)+'\n')
    print(json.dumps(status))


if __name__=='__main__':main()
