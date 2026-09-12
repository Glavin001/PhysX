#!/usr/bin/env python3
"""Index measured attribution coverage without conflating collection tiers."""
import argparse,hashlib,json
from pathlib import Path

def main():
    p=argparse.ArgumentParser(description=__doc__);p.add_argument('root',type=Path);p.add_argument('output',type=Path);a=p.parse_args();a.output.mkdir(parents=True,exist_ok=True)
    sha=lambda f:hashlib.sha256(f.read_bytes()).hexdigest()
    cpu=json.loads((a.output/'report.json').read_text());graphs=json.loads((a.root/'graphs-full/campaign.json').read_text()) if (a.root/'graphs-full/campaign.json').exists() else dict(status='not_run',scenarios=[])
    configs=json.loads((a.root/'configs-full/campaign.json').read_text()) if (a.root/'configs-full/campaign.json').exists() else dict(status='not_run',scenarios=[])
    warm=json.loads((a.root/'warm-reduced-sampling/campaign.json').read_text());rows=[];graph_files=config_files=graph_launches=config_launches=0
    physical=[];minimum_metrics={};counter_diagnostics=[]
    for c in cpu['scenarios_data']:
        name=c['scenario'];row=dict(scenario=name,cpu_status=c['cpu_status'],baseline=c['baseline'])
        for tier,campaign in [('graph',graphs),('ordinary_configs',configs)]:
            r=next((r for r in campaign['scenarios'] if r['scenario']==name),None);row[tier]=r or dict(status='not_captured')
            if r and r['status']=='complete' and r.get('path'):
                path=Path(r['path']);assert sha(path/'counters.ncu-rep')==r['report_sha256']
                receipt=json.loads((path/'receipt.json').read_text());assert receipt['status']=='complete' and receipt['snapshot_inputs']==r['input_sha256']
                assert receipt['binary_sha256']==campaign['identity']['binary_sha256']
                assert {Path(k).name:v for k,v in receipt['modules'].items()}==campaign['identity']['modules']
                comp=json.loads(Path(r['physical_comparison']).read_text());assert comp['status']=='passed';physical.append(comp)
                data=json.loads((path/'analysis.json').read_text());minimum_metrics[tier]=min([len(d['metrics']) for d in data]+[minimum_metrics.get(tier,100000)])
                for i,d in enumerate(data):
                    for k in ['l1tex__t_sector_hit_rate.pct','lts__t_sector_hit_rate.pct','sm__warps_active.avg.pct_of_peak_sustained_active']:
                        v=d['metrics'].get(k,{}).get('value')
                        if isinstance(v,(int,float)) and not 0<=v<=100:counter_diagnostics.append(dict(scenario=name,tier=tier,record=i,metric=k,value=v,note='Out-of-range ratio; not valid quantitative evidence. Raw metric preserved.'))
                if tier=='graph':graph_files+=1;graph_launches+=len(data)
                else:config_files+=1;config_launches+=len(data)
        rows.append(row)
    graph_cases=sum(r['graph']['status']=='complete' for r in rows);config_cases=sum(r['ordinary_configs']['status']=='complete' for r in rows)
    result=dict(cpu_cases=cpu['qualified_cpu_scenarios'],cpu_samples=cpu['cpu_samples'],engine_scopes=cpu['engine_scopes'],timeline_kernel_launches=cpu['kernel_launches'],
        graph_cases=graph_cases,graph_files=graph_files,graph_launches=graph_launches,ordinary_config_cases=config_cases,ordinary_config_files=config_files,ordinary_counter_launches=config_launches,
        checked_counter_ticks=2*(graph_files+config_files),minimum_metric_fields=minimum_metrics,counter_diagnostics=counter_diagnostics,warm=warm,scenarios=rows,
        limits=['Graph counters aggregate nodes. Individual conditional-node and instruction-source counters remain unavailable with the stable collector.',
            'Ordinary kernel families use the explicit 0.1ms cumulative family threshold; first and slowest observed launches per configuration are included. Other invocations remain in complete timelines. Set threshold to zero or use the all-invocation collector for further investigations.',
            'CPU samples are statistical; unresolved driver/kernel frames and any capture warnings are preserved. Native thread-clock phases and OS/CUDA calls supplement sampling.',
            'Cold restored ticks rebuild disposable caches; warm continuous gameplay is a separate workload. Neither includes restore/validation in the full-step timer.',
            'No runtime optimization or speedup is claimed.'])
    (a.output/'coverage-tiers.json').write_text(json.dumps(result,indent=2)+'\n')
    lines=['# Attribution tiers and remaining limits','',f'CPU **{result["cpu_cases"]}/52**; graph tier **{graph_cases}/52** ({graph_launches} graph invocations); significant ordinary-kernel configuration tier **{config_cases}/52** ({config_launches} representative invocations). Zero-work cases are explicit coverage rows, not additional measured ticks.','',
        'All CPU and GPU timings in profiler artifacts are diagnostic. [All52 unprofiled full-step baselines and CPU/stage data](report.md) remain separate.','',
        '| Scenario | CPU | Graph invocations: captured / expected | Ordinary configurations | Ordinary counter invocations |','|---|---|---:|---:|---:|']
    for r in rows:
        g=r['graph'];c=r['ordinary_configs'];lines.append(f'| {r["scenario"]} | {r["cpu_status"]} | {g.get("captured_graph_launches","—")} / {g.get("expected_graph_launches","—")} ({g["status"]}) | {c.get("captured_configs","—")} ({c["status"]}) | {c.get("captured_launches",0) if c["status"]=="complete" else "—"} |')
    lines+=['','## Continuous ordinary/sleeping controls','','Each unprofiled row contains180 complete ticks, including startup. A corresponding CPU/Systems trace passes the same per-tick work/convergence/correction counters. These controls are not candidate speedup experiments.','',
        '| Workload | Full-step mean / peak ms | 8ms / 120Hz / 60Hz misses | Initialization ms | Command / integrated physics / completion mean ms |','|---|---:|---:|---:|---:|']
    for r in warm['cases']:
        assert r['status']=='complete' and not r['counter_differences'];u=r['unprofiled'];lines.append(f'| {r["case"]} | {u["mean_ms"]:.3f} / {u["peak_ms"]:.3f} | {u["misses_8ms"]} / {u["misses_120hz"]} / {u["misses_60hz"]} of180 | {u["summary"]["initialization_ms"]:.3f} | '+ ' / '.join(f'{v:.3f}' for v in u['stages_ms'].values())+' |')
    lines+=['','The lower-rate warm traces contain no sampling-throttle warning. The original higher-rate traces and warnings are retained in `warm/`; the qualified lower-rate set is `warm-reduced-sampling/`. The generic NVTX warning remains; continuous bounds are taken from the complete native frame CSV, and native phases are recorded separately. CUDA-event completeness warnings are rejected. Monotonic frame anchors sit inside the authoritative timer; any unlocated clock-boundary time is explicitly recorded rather than assigned to GPU or CPU work.','',
        '## Limits','',*['- '+x for x in result['limits']],'',f'Out-of-range counter ratios preserved and flagged: {len(counter_diagnostics)}. See the structured report before using any such ratio quantitatively.','']
    (a.output/'coverage-tiers.md').write_text('\n'.join(lines));print(json.dumps({k:v for k,v in result.items() if k not in ['scenarios','warm','counter_diagnostics','limits']},indent=2))

if __name__=='__main__':main()
