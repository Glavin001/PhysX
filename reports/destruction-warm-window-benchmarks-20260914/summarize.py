#!/usr/bin/env python3
"""Recreate timing tables from immutable raw warm-window receipts. No pooled profiler timings."""
import argparse,csv,hashlib,json,statistics as st
from pathlib import Path
root=Path(__file__).resolve().parents[2]
p=argparse.ArgumentParser();p.add_argument('campaign',type=Path);p.add_argument('output',type=Path);a=p.parse_args()
plan=json.loads((a.campaign/'campaign.json').read_text());suite=json.loads((root/'tools/profiles/destruction-warm-suite.json').read_text());out=a.output;out.mkdir(parents=True,exist_ok=True)
def stats(v):
    ts=[x['complete_step_ms'] for x in v]
    return dict(n=len(v),mean_ms=st.mean(ts),peak_ms=max(ts),sd_ms=st.stdev(ts) if len(ts)>1 else 0,misses=sum(t>1000/60 for t in ts),stages_ms={k:st.mean(x[k] for x in v) for k in ('command_ms','simulate_fetch_ms','completion_ms')},iterations_mean=st.mean(x['stress_iterations'] for x in v),breaks=sum(x['broken_bonds'] for x in v),corrections=sum(x['correction_passes'] for x in v))
records=[]
for case in suite['cases']:
    processes=[]
    for arm in ('A0','A1'):
        path=a.campaign/(case['name']+'-'+arm)/'replay.json'
        if not path.exists():continue
        r=json.loads(path.read_text());tra=r['trajectories'];v=r['samples'];entry=stats(v)
        entry.update(arm=arm,passed=r['passed'],raw=str(path),restore_ms=st.mean(x['restore_ms'] for x in tra),setup_ms=r['context_setup_ms'],warmup_ms=st.mean(sum(t['complete_step_ms'] for t in x['ticks'][:r['warmup_ticks']]) for x in tra),first_restored_tick_ms=[x['ticks'][0]['complete_step_ms'] for x in tra],warmup_ticks=r['warmup_ticks'],measure_ticks=r['measure_ticks'],trajectories=len(tra))
        processes.append(entry)
    if len(processes)!=2:continue
    physical=json.loads((a.campaign/(case['name']+'-A1-physical.json')).read_text())
    records.append(dict(case=case['name'],trait=case['trait'],physical_status=physical['status'],processes=processes))
summary=dict(campaign_status=plan['status'],elapsed_seconds=plan.get('elapsed_seconds'),records=records,independent_processes_per_case=2,scope='Descriptive same-build calibration; ticks within trajectories are correlated. No candidate or runtime speedup.')
(out/'summary.json').write_text(json.dumps(summary,indent=2)+'\n')
lines=['# Measured warm-window calibration','', 'Two independent plain processes per case, two restores per process. Mean range spans process means; peak includes every measured tick. Warmup remains separately recorded. This is not an optimization A/B result.','', '| Scenario | W / M per restore | Measured ticks | Mean range ms | Peak ms | 60 Hz misses | Command / integrated / completion ms, pooled | Physical |','|---|---:|---:|---:|---:|---:|---:|---|']
for x in records:
    ps=x['processes'];ms=[p['mean_ms'] for p in ps];stages=[st.mean(p['stages_ms'][k] for p in ps) for k in ('command_ms','simulate_fetch_ms','completion_ms')]
    lines.append(f"| {x['case']} | {ps[0]['warmup_ticks']} / {ps[0]['measure_ticks']} | {sum(p['n'] for p in ps)} | {min(ms):.3f}–{max(ms):.3f} | {max(p['peak_ms'] for p in ps):.3f} | {sum(p['misses'] for p in ps)}/{sum(p['n'] for p in ps)} | {' / '.join(f'{s:.3f}' for s in stages)} | {x['physical_status']} |")
lines+=['','| Scenario | Context setup range ms/process | Restore range ms/trajectory | Total warmup range ms/trajectory | First restored tick range ms | Measured iteration mean | Fractures / corrections in measured ticks |','|---|---:|---:|---:|---:|---:|---:|']
for x in records:
    ps=x['processes']
    def span(k):v=[p[k] for p in ps];return f'{min(v):.3f}–{max(v):.3f}'
    first=[t for p in ps for t in p['first_restored_tick_ms']]
    lines.append(f"| {x['case']} | {span('setup_ms')} | {span('restore_ms')} | {span('warmup_ms')} | {min(first):.3f}–{max(first):.3f} | {span('iterations_mean')} | {sum(p['breaks'] for p in ps)} / {sum(p['corrections'] for p in ps)} |")
lines+=['',f"Campaign status: **{plan['status']}**. Total wall time: **{plan.get('elapsed_seconds',0):.3f}s**, including GPU admission, desktop handling, validation and selected captures; builds separate.",'','Stress iteration count is a solver status count, not total GPU instructions. Integrated simulation time contains overlapping CPU/GPU work and both stress passes when required. The three timer partitions are additive; internal profiler scope/thread totals are not.']
(out/'measurements.md').write_text('\n'.join(lines)+'\n')
# Preserve exact input/tool/build locators and hashes beside the derived summaries.
paths=[a.campaign/'campaign.json',root/'out/warm-replay-20260914/plain/build.json',root/'out/warm-replay-20260914/profile/build.json',root/'tools/profiles/destruction-warm-suite.json']
paths+=list((root/'tools/diagnostics/destruction-snapshot').glob('*warm*'))
(out/'provenance.json').write_text(json.dumps({str(p):hashlib.sha256(p.read_bytes()).hexdigest() for p in paths if p.is_file()},indent=2)+'\n')
