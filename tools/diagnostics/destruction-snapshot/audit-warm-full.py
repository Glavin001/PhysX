#!/usr/bin/env python3
"""Audit saved full52 warm coverage and produce an evidence index; never rerun GPU work."""
import argparse,hashlib,importlib.util,json,math,statistics
from pathlib import Path
ROOT=Path(__file__).resolve().parents[3];HERE=Path(__file__).resolve().parent
p=argparse.ArgumentParser(description=__doc__);p.add_argument('campaign',type=Path);p.add_argument('report',type=Path);a=p.parse_args();base=a.campaign.resolve();out=a.report.resolve();out.mkdir(parents=True,exist_ok=True)
manifest=json.load(open(base/'manifest.json'));timings=json.load(open(base/'timing-audit.json'));cpu=json.load(open(base/'cpu-v2/campaign.json'));counters=json.load(open(base/'counters/campaign.json'))
expected={c['scenario'] for c in manifest['scenarios']};assert len(expected)==52
assert timings['status']=='passed' and {r['scenario'] for r in timings['rows']}==expected
cpus={r['scenario']:r for r in cpu['scenarios']};counts={r['scenario']:r for r in counters['scenarios']};rows=[];anomalies=[]
sha=lambda p:hashlib.sha256(Path(p).read_bytes()).hexdigest()
assert cpu['manifest_sha256']==counters['manifest_sha256']==sha(base/'manifest.json')
profile_sha=sha(manifest['profile_binary'])
plain_sha=sha(manifest['binary'])
references={r['scenario']:r for r in timings['rows']}
first_receipt=json.load(open(Path(timings['rows'][0]['paths'][0])/'receipt.json'))
modules=first_receipt['modules']
assert {Path(k).name:v for k,v in modules.items()}=={
 'libPhysXDestructionGpuRuntime_64.so':'d5770a80c2f4686b0ad311edcbfc8e128d14baee64653bf5e032305c12cf9354',
 'libPhysXGpuActivity_64.so':'4c82a91759eae6fb7fa06714a04552ba18ec23eb5332d52875f74a59284894e5'}
assert all(sha(path)==digest for path,digest in modules.items())
s=importlib.util.spec_from_file_location('config',HERE/'profile-config-suite.py');config=importlib.util.module_from_spec(s);s.loader.exec_module(config)
for c in manifest['scenarios']:
 name=c['scenario'];cr=cpus.get(name,{});nr=counts.get(name,{});row=dict(scenario=name,cpu_status=cr.get('status','missing'),counter_status=nr.get('status','missing'))
 assert json.load(open(references[name]['physical_comparison']))['status']=='passed'
 for path in references[name]['paths']:
  receipt=json.load(open(Path(path)/'receipt.json'))
  assert receipt['status']=='complete' and receipt['binary_sha256']==plain_sha and receipt['modules']==modules and receipt['snapshot_inputs']==c['input_sha256']
 if cr.get('status')=='complete':
  path=Path(cr['path']);d=json.load(open(path/('attribution-normalized.json' if (path/'attribution-normalized.json').exists() else 'attribution.json')));receipt=json.load(open(path/'receipt.json'))
  assert receipt['status']=='complete' and receipt['snapshot_inputs']==c['input_sha256'] and receipt['binary_sha256']==profile_sha
  assert receipt['modules']==modules
  assert d['physical_comparison']['status']=='passed' and d['cpu_attribution']['samples']>0
  assert sha(path/'trace.nsys-rep')==cr['trace_sha256']
  assert abs(sum(d['cpu_attribution']['disjoint_wall'].values())-d['tick_ms'])<1e-6
  row.update(cpu_path=str(path),profiled_tick_ms=d['tick_ms'],gpu_activity_union_ms=d['gpu_activity_union_ms'],cpu_disjoint_wall=d['cpu_attribution']['disjoint_wall'],cpu_samples=d['cpu_attribution']['samples'],kernel_launches=d['kernel_count'],copy_count=d['copy_count'],copy_bytes=d['copy_bytes'],native_scopes=d['cpu_attribution']['nvtx_scope_count'],cuda_api_calls=len(d['cpu_attribution']['cuda_calls']),removed_api_aliases=d.get('cuda_api_normalization',{}).get('removed_alias_records',0),warnings=d['diagnostics'])
  row.update(unresolved_leaf_samples=d['cpu_attribution']['unresolved_leaf_samples'],ranked_kernels=d['ranked_kernels'],cpu_scopes=d['cpu_attribution']['scopes'])
 if nr.get('status')=='complete':
  row.update(graph_invocations=nr['graph']['launches'],ordinary_representatives=nr['ordinary']['launches'],ordinary_configurations=nr['ordinary_selection']['expected_configs'],observed_kernel_coverage=nr['ordinary_selection']['coverage_fraction'],counter_paths={k:nr[k].get('path') for k in ['graph','ordinary']})
  assert row['observed_kernel_coverage']>=.99-1e-12
  for kind in ['graph','ordinary']:
   n=nr[kind]
   if not n['launches']:continue
   path=Path(n['path']);receipt=json.load(open(path/'receipt.json'));physical=json.load(open(path/'physical-comparison.json'));data=json.load(open(path/'analysis.json'))
   assert receipt['status']=='complete' and physical['status']=='passed' and receipt['snapshot_inputs']==c['input_sha256'] and receipt['binary_sha256']==profile_sha
   assert receipt['modules']==modules
   assert sha(path/'counters.ncu-rep')==n['report_sha256'] and len(data)==n['launches']
   assert receipt['profiler']['explicit_metrics'] and receipt['profiler']['replay_mode']=='kernel'
   if kind=='graph':assert len(data)==len(nr['graph_inventory']) and all(d['name']=='graph' for d in data)
   else:
    import collections
    target=nr['ordinary_selection'];want=collections.Counter((t['name'],tuple(k['grid']),tuple(k['block']),k['shared_bytes']) for t in target['targets'] for k in t['configs'] for _ in k['selected_ordinals']);actual=collections.Counter(config.observed_key(d) for d in data);assert actual==want
   for launch in data:
    for metric in receipt['profiler']['explicit_metrics'].split(','):
     value=launch['metrics'][metric]['value'];assert isinstance(value,(int,float)) and math.isfinite(value)
     if '.pct_' in metric and not 0<=value<=100:anomalies.append(dict(scenario=name,kind=kind,launch=launch['launch']['ID'],metric=metric,value=value))
 rows.append(row)
summary=dict(status='complete' if len(rows)==52 and all(r['cpu_status']==r['counter_status']=='complete' for r in rows) else 'incomplete',timing_scenarios=timings['scenarios'],measured_ticks=timings['measured_ticks'],warmup_ticks=timings['warmup_ticks'],cpu_scenarios=sum(r['cpu_status']=='complete' for r in rows),counter_scenarios=sum(r['counter_status']=='complete' for r in rows),cpu_samples=sum(r.get('cpu_samples',0) for r in rows),kernel_launches=sum(r.get('kernel_launches',0) for r in rows),native_scopes=sum(r.get('native_scopes',0) for r in rows),graph_invocations=sum(r.get('graph_invocations',0) for r in rows),ordinary_representatives=sum(r.get('ordinary_representatives',0) for r in rows),ordinary_configurations=sum(r.get('ordinary_configurations',0) for r in rows),removed_api_aliases=sum(r.get('removed_api_aliases',0) for r in rows),counter_ratio_anomalies=anomalies,core_metrics=counters['metrics'],scope='Matched warm windows; observed timeline coverage and core hardware counters, not all metrics/invocations or conditional-node source counters. Boundary warnings remain explicit.',rows=rows)
summary['provenance']=dict(manifest_sha256=sha(base/'manifest.json'),plain_binary_sha256=plain_sha,profile_binary_sha256=profile_sha,modules=modules)
(out/'data').mkdir(exist_ok=True);(out/'data/coverage.json').write_text(json.dumps(summary,indent=2)+'\n')
lines=['# Warm CPU/GPU attribution and core-counter coverage','',f"CPU/GPU traces: **{summary['cpu_scenarios']}/52**; core counters: **{summary['counter_scenarios']}/52**. This is diagnostic coverage, not a speedup or exhaustive metric/source-counter claim.",'',f"{summary['cpu_samples']:,} CPU samples, {summary['native_scopes']:,} native phase scopes and {summary['kernel_launches']:,} recorded kernel launches. Counter inventories cover {summary['graph_invocations']:,} graph invocations and {summary['ordinary_representatives']:,} ordinary launch representatives at {summary['ordinary_configurations']:,} configurations.",'','Instrumented milliseconds below must not replace the unprofiled full-step timings. GPU activity is interval union; scheduled CPU may overlap it. Coverage fractions refer to observed kernel time in the matched timeline.','', '| Scenario | Profiled tick ms | GPU activity ms | CPU samples | Kernel launches | Copies / MB | Graph / ordinary counter launches | Observed kernel coverage | Warnings |','|---|---:|---:|---:|---:|---:|---:|---:|---|']
for r in rows:
 if r['cpu_status']!='complete':lines.append(f"| {r['scenario']} | {r['cpu_status']} | — | — | — | — | — | — | — |");continue
 warnings=r['warnings'];kinds=[]
 for token,label in [('NVTX','NVTX boundary'),('CUDA events','CUDA boundary'),('OS runtime','OS boundary'),('throttled','sampling throttled')]:
  if any(token in w['text'] for w in warnings):kinds.append(label)
 counters_text=f"{r.get('graph_invocations','—')} / {r.get('ordinary_representatives','—')}";coverage=f"{100*r['observed_kernel_coverage']:.3f}%" if 'observed_kernel_coverage' in r else r['counter_status']
 lines.append(f"| {r['scenario']} | {r['profiled_tick_ms']:.3f} | {r['gpu_activity_union_ms']:.3f} | {r['cpu_samples']} | {r['kernel_launches']} | {r['copy_count']} / {r['copy_bytes']/1e6:.2f} | {counters_text} | {coverage} | {', '.join(kinds) or 'none'} |")
lines+=['','## CPU/GPU overlap per scenario','','These four mutually exclusive wall intervals sum to the profiled tick. Scheduled CPU is not proof of useful engine computation; it can include collector or driver work. No recorded activity is not proof that the interval is removable. Unresolved samples remain visible.','', '| Scenario | CPU + GPU ms | GPU without scheduled CPU ms | CPU without recorded GPU ms | Neither recorded ms | Unresolved CPU samples |', '|---|---:|---:|---:|---:|---:|']
for r in rows:
 if r['cpu_status']!='complete':continue
 w=r['cpu_disjoint_wall'];lines.append(f"| {r['scenario']} | {w['gpu_and_scheduled_cpu_ms']:.3f} | {w['gpu_without_scheduled_cpu_ms']:.3f} | {w['scheduled_cpu_without_gpu_ms']:.3f} | {w['neither_traced_gpu_nor_scheduled_cpu_ms']:.3f} | {r['unresolved_leaf_samples']}/{r['cpu_samples']} |")
lines+=['','## Use the saved data','','[Structured coverage index](data/coverage.json) links each capture directory and includes ranked kernel families and native CPU scopes. Read `attribution-normalized.json` for physical CUDA call counts, stacks, waits, thread CPU phases and disjoint wall accounting. Raw `attribution.json`/SQLite preserve original API aliases. `native.phases.csv` retains the detailed engine scopes. Each counter directory holds the native `.ncu-rep`, CSV and structured metrics. Each capture includes its exact command, binary/module/input hashes and physical comparison.','',f"API normalization removed {summary['removed_api_aliases']:,} verified nested/versioned alias records from physical call counts; raw evidence is unchanged. {len(anomalies)} out-of-range percentage ratios are retained and flagged in the coverage JSON, not silently interpreted.",'','Core metrics include duration, achieved occupancy, issue activity, DRAM throughput and kernel launch resources. Detailed cache/eligible-warp/FP64/stall metrics were not collected across all52. Conditional graph node/source counters remain unsupported; graph aggregates are separate. CPU sample counts can be low for short ticks; use native phase clocks and repeated targeted sampling before fine-grained CPU claims. The selected NVTX ranges and native scope inventories match, but range-boundary warnings preclude an unconditional exhaustive-event claim.']
(out/'attribution.md').write_text('\n'.join(lines)+'\n');print({k:v for k,v in summary.items() if k not in ['rows','counter_ratio_anomalies','core_metrics']})
