#!/usr/bin/env python3
"""Report qualified CPU attribution alongside all 52 unprofiled scenario baselines."""
import argparse,collections,hashlib,json,math
from pathlib import Path

def main():
    p=argparse.ArgumentParser(description=__doc__);p.add_argument('campaign',type=Path);p.add_argument('output',type=Path)
    p.add_argument('--baseline',type=Path,default=Path('qualification/optimization-next20-20260910/snapshot-reset-20260911/report.json'))
    p.add_argument('--counter-status',default='Prior 52-scenario selected/stress captures remain available. See the accompanying qualification report for expanded inventory status.')
    p.add_argument('--warm-status',default='See the separate continuous attribution campaign; snapshot coverage does not establish warm coverage.')
    p.add_argument('--recovery-note',default='Historical failed captures remain preserved; qualified rows refer only to successful, physically checked captures.')
    a=p.parse_args();a.output.mkdir(parents=True,exist_ok=True)
    campaign=json.loads((a.campaign/'campaign.json').read_text());base=json.loads(a.baseline.read_text())['scenarios'];runs={r['scenario']:r for r in campaign['scenarios']}
    rows=[];physical=[];total_samples=total_scopes=total_kernels=0
    for b in base:
        r=runs.get(b['scenario']);row=dict(scenario=b['scenario'],baseline=b,cpu_status=r['status'] if r else 'not_captured')
        if r and r['status']=='complete':
            path=Path(r['path']);d=json.loads((path/'attribution.json').read_text());c=d['cpu_attribution'];receipt=json.loads((path/'receipt.json').read_text())
            assert hashlib.sha256((path/'trace.nsys-rep').read_bytes()).hexdigest()==r['trace_sha256']
            assert receipt['status']=='complete' and receipt['binary_sha256']==campaign['identity']['binary_sha256']
            assert {Path(k).name:v for k,v in receipt['modules'].items()}==campaign['identity']['modules']
            assert receipt['snapshot_inputs']==r['input_sha256'] and d['physical_comparison']['status']=='passed'
            assert all(math.isfinite(v) and v>=-1e-6 for v in c['disjoint_wall'].values())
            assert abs(sum(c['disjoint_wall'].values())-d['tick_ms'])<1e-6
            assert c['samples']>0 and any(t['is_main'] for t in c['threads'])
            physical.append(d['physical_comparison']);total_samples+=c['samples'];total_scopes+=c['nvtx_scope_count'];total_kernels+=d['kernel_count']
            # Keep full stacks, call/stream correlations, and interval records in
            # raw JSON/SQLite. This table is a navigable index, not a replacement.
            row['cpu']=dict(raw=str(path),trace_sha256=r['trace_sha256'],profiled_tick_ms=d['tick_ms'],samples=c['samples'],unresolved_leaf_samples=c['unresolved_leaf_samples'],
                disjoint_wall=c['disjoint_wall'],threads=[{k:t[k] for k in ['thread','is_main','samples','state_ms']} for t in c['threads']],
                top_leaf=c['leaf'][:15],top_inclusive=c['inclusive'][:15],scopes=sorted(c['scopes'],key=lambda x:-(x['exclusive_thread_cpu_ms'] or 0)),device_phase_events=d['device_phase_events'],
                cuda_calls=len(c['cuda_calls']),os_and_cuda_waits=len(c['waits']),kernel_launches=d['kernel_count'],engine_scopes=c['nvtx_scope_count'],
                gpu_launches_with_correlated_api=c['gpu_launches_with_correlated_api'],gpu_launches_with_engine_scope=c['gpu_launches_with_engine_scope'],
                top_waits=c['waits'][:15],physical_comparison=str(path/'physical-comparison.json'),diagnostics=d['diagnostics'])
        elif r:row['attempt']=r
        rows.append(row)
    qualified=sum(r['cpu_status']=='complete' for r in rows)
    result=dict(status='complete' if qualified==len(rows) else 'incomplete',scenarios=len(rows),qualified_cpu_scenarios=qualified,remaining_cpu_scenarios=len(rows)-qualified,
        checked_qualified_ticks=2*qualified,cpu_samples=total_samples,engine_scopes=total_scopes,kernel_launches=total_kernels,
        maximum_motion_errors={k:max(x['maximum_errors'][k] for x in physical) for k in physical[0]['maximum_errors']} if physical else {},
        identity=campaign['identity'],scenarios_data=rows,
        counter_status=a.counter_status,
        warm_status=a.warm_status,
        scope='Diagnostic CPU sampling, scheduling, engine phases, CUDA/OS calls and GPU activity. No application optimization or speedup. Baseline times are separate unprofiled 20-sample restored full ticks, excluding restore and validation.')
    (a.output/'report.json').write_text(json.dumps(result,indent=2)+'\n')
    lines=['# End-to-end attribution coverage','',result['scope'],'',f'CPU attribution: **{qualified}/{len(rows)}** qualified scenarios, **{2*qualified}** checked restored ticks, **{total_samples:,}** CPU samples, **{total_scopes:,}** engine phase scopes and **{total_kernels:,}** GPU launches. Incomplete scenarios remain visible.','',
        a.recovery_note,'',
        '| Scenario | Unprofiled mean / peak ms | Command / simulate-fetch / completion means ms | 60 / 120 Hz misses (20 samples) | CPU attribution | CPU samples |',
        '|---|---:|---:|---:|---|---:|']
    for r in rows:
        b=r['baseline'];s=b['stages_ms'];c=r.get('cpu',{})
        lines.append(f"| {r['scenario']} | {b['tick_mean_ms']:.3f} / {b['tick_max_ms']:.3f} | {s['command_ms']:.3f} / {s['simulate_fetch_ms']:.3f} / {s['completion_ms']:.3f} | {b['misses_60hz']} / {b['misses_120hz']} | {r['cpu_status']} | {c.get('samples','—')} |")
    lines+=['','## Same-trace wall accounting','','These instrumented durations include profiler overhead and are not benchmark results. The four columns form a disjoint partition of each tick; they must not be added to kernel/API sums or compared by subtraction with the unprofiled times above. Scheduled CPU includes observed profiler/driver threads. Neither is an observation gap, not proof of removable idle time.','',
        '| Scenario | GPU + scheduled CPU ms | GPU only ms | Scheduled CPU only ms | Neither ms | Unresolved leaf samples / total |','|---|---:|---:|---:|---:|---:|']
    for r in rows:
        if 'cpu' not in r:continue
        c=r['cpu'];v=c['disjoint_wall'];lines.append('| '+r['scenario']+' | '+' | '.join(f'{x:.3f}' for x in v.values())+f" | {c['unresolved_leaf_samples']} / {c['samples']} |")
    lines+=['','## Reading the raw evidence','','Each qualified scenario directory contains the native Systems report and SQLite database, `attribution.json`, exact command and module/input hashes, physical comparison, and the reused native host/CPU/device-phase CSVs. The JSON links kernels and copies to streams, launch APIs, CPU callers and engine scopes where present. All recorded CPU stack frames and thread scheduling events remain in SQLite; unresolved driver/kernel symbols are explicitly counted.','',
        'The native phase recorder provides thread CPU clocks and nested scope accounting. Detached cross-thread durations are wall intervals; unmeasured leaf CPU time is never invented. Samples are statistical counts. A low-count function needs additional samples before a fine-grained CPU performance claim. CUDA API waits can overlap useful GPU execution. Device phase event durations include dependencies and submission gaps, not just kernel execution.','',
        'The expanded kernel collector selects at least 99% of aggregate GPU kernel duration, every family costing at least 0.1ms and stress, then requests every invocation of those families, preserving trial/correction and launch configurations. Both thresholds are adjustable, including 100% coverage. An inventory audit rejects silently skipped kernels. This collector is implemented but its broad GPU qualification remains pending; conditional-graph support is a known gap in the pinned 2025 collector.','',
        'GPU allocation/all-API tracing is a separate opt-in diagnostic. Exact capture options remain in each receipt; mixed tracing options are not a matched timing comparison. Reduced tracing is not a proven firmware-fault fix.', '', result['counter_status'], '', result['warm_status'],'']
    (a.output/'report.md').write_text('\n'.join(lines))
    print(json.dumps({k:v for k,v in result.items() if k not in ['scenarios_data','identity']},indent=2))
if __name__=='__main__':main()
