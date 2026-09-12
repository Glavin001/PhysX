#!/usr/bin/env python3
"""Join qualified scenario timelines/counters to the unprofiled full-tick baseline."""
import argparse,collections,json,math,sqlite3,statistics
from pathlib import Path
p=argparse.ArgumentParser(description=__doc__);p.add_argument('campaign',type=Path);p.add_argument('output',type=Path);p.add_argument('--baseline',type=Path,required=True);a=p.parse_args()
campaign=json.loads((a.campaign/'campaign.json').read_text());baseline={r['scenario']:r for r in json.loads(a.baseline.read_text())['scenarios']}
a.output.mkdir(parents=True,exist_ok=False);rows=[]
keys=['gpu__time_duration.sum','launch__registers_per_thread','launch__occupancy_limit_registers','launch__occupancy_limit_shared_mem',
 'sm__warps_active.avg.pct_of_peak_sustained_active','smsp__warps_eligible.avg.per_cycle_active',
 'smsp__issue_active.avg.pct_of_peak_sustained_active','sm__pipe_fp64_cycles_active.avg.pct_of_peak_sustained_elapsed',
 'dram__bytes.sum.per_second','dram__cycles_active.avg.pct_of_peak_sustained_elapsed','lts__t_sector_hit_rate.pct','l1tex__t_sector_hit_rate.pct',
 'l1tex__t_sectors_pipe_lsu_mem_local_op_ld.sum','l1tex__t_sectors_pipe_lsu_mem_local_op_st.sum']
for run in campaign['scenarios']:
 assert run['status']=='complete',run['scenario']
 t=json.loads((Path(run['timeline'])/'analysis.json').read_text());ref=baseline[run['scenario']];launches=[]
 for capture in run['counters']:
  for launch in json.loads((Path(capture['path'])/'analysis.json').read_text()):
   m=launch['metrics'];selected={k:m[k] for k in keys if k in m}
   stalls={k:v for k,v in m.items() if k.startswith('smsp__average_warps_issue_stalled_') and k.endswith('_per_issue_active.ratio')}
   warnings=[f'{k}={v["value"]}% outside [0,100]; do not use for quantitative diagnosis' for k,v in selected.items() if v['unit']=='%' and isinstance(v['value'],(float,int)) and (not math.isfinite(v['value']) or v['value']<0 or v['value']>100)]
   launches.append(dict(name=launch['name'],metrics=selected,warp_stall_ratios=stalls,raw_metric_count=len(m),warnings=warnings,raw=capture['path'],physical_comparison=capture.get('physical_comparison')))
 row=dict(scenario=run['scenario'],baseline=dict(mean_ms=ref['tick_mean_ms'],max_ms=ref['tick_max_ms'],samples=ref['n'],misses_60hz=ref['misses_60hz'],misses_120hz=ref['misses_120hz'],spread_ms=ref['tick_spread_ms'],stage_mean_ms={k:ref['stages_ms'][k] for k in ['command_ms','simulate_fetch_ms','completion_ms']},raw=ref['raw']),
   profiled_tick_ms=t['tick_ms'],gpu_activity_union_ms=t['gpu_activity_union_ms'],no_traced_gpu_activity_ms=t['no_traced_gpu_activity_ms'],
   kernel_count=t['kernel_count'],copy_count=t['copy_count'],copy_bytes=t['copy_bytes'],stage_ms=t['stage_ms'],
   top_kernels=t['ranked_kernels'][:8],top_cuda_apis=t['cuda_apis'][:12],counter_launches=launches,physical_sample=t['physical_sample'],timeline=run['timeline'])
 row['timeline_diagnostics']=t.get('diagnostics',[])
 db=sqlite3.connect(f'file:{Path(run["timeline"]) / "trace.sqlite"}?mode=ro',uri=True)
 labels={r[0]:r[2] for r in db.execute('select * from ENUM_CUDA_MEMCPY_OPER')};db.close()
 transfers=collections.defaultdict(lambda:dict(calls=0,bytes=0,aggregate_ms=0))
 for copy in t['transfers']:
  v=transfers[labels.get(copy['kind'],str(copy['kind']))];v['calls']+=1;v['bytes']+=copy['bytes'];v['aggregate_ms']+=copy['ms']
 row['transfer_directions']=dict(transfers)
 if 'pm' in t:
  row['pm']={k:v for k,v in t['pm'].items() if k!='kernels'}
  row['pm']['longest_kernel_interiors']=sorted(t['pm']['kernels'],key=lambda k:-k['ms'])[:20]
 rows.append(row)
result=dict(scope='Unprofiled tick baseline is separate from diagnostic instrumented timeline/counter launches. NCU replays kernels with cache flushing, clocks unlocked; shared graphics/server contexts remain. No optimization gain established.',cases=len(rows),status='complete' if campaign.get('status')=='complete' else 'partial',scenarios=rows,identity=campaign['identity'],ncu_collector=campaign.get('ncu'))
result['counter_coverage']=dict(scenarios=sum(bool(r['counter_launches']) for r in rows),launches=sum(len(r['counter_launches']) for r in rows))
(a.output/'report.json').write_text(json.dumps(result,indent=2)+'\n')
lines=['# Scenario hardware-counter atlas','',result['scope'],'','All rows include Systems GPU kernels, memory transfers, CUDA API calls and disjoint full-tick host ranges. Non-replaying PM hardware counters cover the complete tick and sufficiently long kernel interiors. Detailed NCU data supplements cases where profiling completed correctly. Failed NCU captures are excluded. Two independent restores verify each capture; only the first tick is analyzed. The process trace drains at normal exit; all four declared tick ranges must be present and closed. CUDA event-completeness warnings reject the capture; generic NVTX warnings are retained in JSON.','','| Scenario | Unprofiled tick mean / peak ms | Traced GPU active ms | Kernel / copy calls | Copy bytes | Dominant kernel |','|---|---:|---:|---:|---:|---|']
for r in rows:lines.append(f"| {r['scenario']} | {r['baseline']['mean_ms']:.3f} / {r['baseline']['max_ms']:.3f} | {r['gpu_activity_union_ms']:.3f} | {r['kernel_count']} / {r['copy_count']} | {r['copy_bytes']:,} | {r['top_kernels'][0]['name'].split('(')[0]} |")
lines+=['','## Unprofiled full-step stages','','These baseline means partition the full tick; simulate/fetch includes integrated physics, stress and any correction. They are not profiler durations. Restore/validation are excluded.','','| Scenario | Commands ms | Simulate/fetch ms | Completion ms | 60 Hz misses | 120 Hz misses |','|---|---:|---:|---:|---:|---:|']
for r in rows:
 b=r['baseline'];s=b['stage_mean_ms'];lines.append(f"| {r['scenario']} | {s['command_ms']:.3f} | {s['simulate_fetch_ms']:.3f} | {s['completion_ms']:.3f} | {b['misses_60hz']}/{b['samples']} | {b['misses_120hz']}/{b['samples']} |")
lines+=['','## Whole-tick hardware sampling','','These are device-wide samples inside the traced tick, including CPU gaps and other GPU contexts. Elapsed resident-warps percentage is distinct from NCU active occupancy. Do not attribute all sampled DRAM traffic to this application. Short kernels may lack interior samples; JSON retains coverage and exclusions.','','| Scenario | Samples | Interior coverage | Resident warps / elapsed % | Instructions / SM cycle | DRAM GB/s |','|---|---:|---:|---:|---:|---:|']
for r in rows:
 if 'pm' in r:
  v=r['pm']['tick'];lines.append(f"| {r['scenario']} | {v['samples']} | {100*v['interior_coverage']:.1f}% | {v['resident_warps_elapsed_pct']:.3f} | {v['instructions_per_sm_cycle']:.3f} | {v['dram_gb_s']:.3f} |")
lines+=['','## Selected detailed NCU counters','',f"Coverage: {result['counter_coverage']['scenarios']}/{len(rows)} scenarios, {result['counter_coverage']['launches']} selected launches.",'','Rows correspond to selected kernel launches, not the entire tick. Occupancy is achieved active warps; eligible warps measure readiness to issue. DRAM rates retain the profiler\'s explicit units. Stall ratios and cache/local-memory metrics are in JSON and full raw CSV.','','| Scenario / launch | Registers | Occupancy % | Eligible warps | Issue active % | FP64 active % | DRAM rate |','|---|---:|---:|---:|---:|---:|---:|']
for r in rows:
 for i,l in enumerate(r['counter_launches']):
  def f(k,unit=False):
   v=l['metrics'].get(k)
   return 'unavailable' if not v else str(round(v['value'],3) if isinstance(v['value'],float) else v['value'])+(' '+v['unit'] if unit else '')
  lines.append('| '+r['scenario']+' / '+str(i)+' | '+' | '.join(f(k,k=='dram__bytes.sum.per_second') for k in ['launch__registers_per_thread','sm__warps_active.avg.pct_of_peak_sustained_active','smsp__warps_eligible.avg.per_cycle_active','smsp__issue_active.avg.pct_of_peak_sustained_active','sm__pipe_fp64_cycles_active.avg.pct_of_peak_sustained_elapsed','dram__bytes.sum.per_second'])+' |')
lines+=['','## Interpretation limits','','Profiler launch replay and tracing overhead are excluded from speedup claims. GPU activity is the union of intervals; kernel/API aggregate durations can overlap. Time without traced GPU activity includes CPU work, submission gaps and instrumentation; it is not a proven removable CPU cost. Some shared-device, cross-pass metrics can be out of bounds; flagged percentages are preserved but excluded from quantitative diagnosis. No fixed occupancy/throughput threshold or predicted speedup is treated as proof.','','Full `.nsys-rep`, SQLite, `.ncu-repz`, raw CSV, per-launch JSON, exact commands, tool versions, input/module hashes and physical receipts remain in the raw paths listed in report.json. The baseline rows retain all20 unprofiled samples per case; the current timing cohort is from the prior qualified full suite.','','See [NVIDIA\'s profiling guide](https://docs.nvidia.com/nsight-compute/ProfilingGuide/index.html) for replay, scheduler metric definitions, and out-of-range metrics.','']
(a.output/'report.md').write_text('\n'.join(lines));print(len(rows),'scenarios reported')
