#!/usr/bin/env python3
"""Generate a population-aware scaling report from verified complete-step captures.

Keeps failed campaigns visible. No GPU work or new timing is performed here.
"""
import argparse
import gzip
import importlib.util
import json
from pathlib import Path

spec=importlib.util.spec_from_file_location('timing',Path(__file__).with_name('report-destruction-timing.py'))
t=importlib.util.module_from_spec(spec);spec.loader.exec_module(t)


def collect(capture):
    manifest_path=capture/'campaign.json'
    manifest=json.loads(manifest_path.read_text())
    result={'capture':str(capture.resolve()),'manifest_sha256':t.sha(manifest_path),
            'status':manifest['status'],'cases':[],'error':manifest.get('error')}
    if manifest['status']!='complete':
        result['attempts']=[{k:r.get(k) for k in ['name','case','mode','exit_code']} for r in manifest['runs']]
        return result
    for case in manifest['config']['cases']:
        records=[r for r in manifest['runs'] if r['case']==case['id'] and r['mode']=='plain']
        t.require(len(records)==manifest['trials'],'Missing measured repetition')
        runs=[t.load_run(capture/r['name'],r) for r in records]
        for run in runs:
            t.validate_duration(manifest,run['frames']);t.complete_step_metrics(run)
        frames=[f for run in runs for f in run['frames']]
        metrics=t.stats([float(f['complete_step_ms']) for f in frames])
        peak=max(((ri,fi,f) for ri,run in enumerate(runs) for fi,f in enumerate(run['frames'])),
                 key=lambda x:float(x[2]['complete_step_ms']))
        summary=runs[0]['summary']
        same=all(run['signature_rows']==runs[0]['signature_rows'] for run in runs)
        expected=None
        if summary['shot_path']=='through-wall':
            expected=all(run['summary']['broken_bonds']==199 and run['summary']['corrections']==3
                         and run['summary']['peak_clusters']==run['summary']['buildings']+42 for run in runs)
        sampled_memory=[]
        for record in records:
            for sample in record['samples']:
                for device in sample['devices']:
                    text=device.get('memory_used','') or ''
                    if text.endswith(' MiB'):sampled_memory.append(float(text.split()[0]))
        population={k:max(int(f[k]) for f in frames) for k in [
            'bodies','active_dynamic_bodies','active_kinematic_bodies','logical_clusters',
            'contacts_frame','contact_pairs','stress_active_nodes','stress_active_bonds','stress_islands','stress_iterations']}
        result['cases'].append({'id':case['id'],'label':case['label'],
            'buildings':summary['buildings'],'chunks':summary['chunks'],'bonds':summary['bonds'],
            'projectiles':summary['projectiles'],'layout':summary.get('layout','grid'),
            'shot_path':summary['shot_path'],'projectile_mass_kg':summary['projectile_mass_kg'],
            'material_strength_scale':summary['material_strength_scale'],
            'frame_strength_scale':summary['frame_strength_scale'],'sleeping':summary['sleeping'],
            'trials':len(runs),'seconds':manifest['seconds'],'metrics':metrics,
            'missed_8ms':sum(float(f['complete_step_ms'])>8 for f in frames),
            'missed_60hz':sum(float(f['complete_step_ms'])>1000/60 for f in frames),
            'population_peaks':population,'sampled_gpu_memory_mib':max(sampled_memory,default=None),
            'broken_bonds_range':[min(r['summary']['broken_bonds'] for r in runs),max(r['summary']['broken_bonds'] for r in runs)],
            'corrected_steps_range':[min(r['summary']['corrections'] for r in runs),max(r['summary']['corrections'] for r in runs)],
            'maximum_corrections_per_step':max(int(f['resim_passes']) for f in frames),
            'repeated_counter_history_matches':same,'frozen_wall_counters_match':expected,
            'full_physical_quality_qualified':False,
            'peak':{'repeat':peak[0]+1,'step':peak[1],'frame':peak[2]},
            'initialization_ms_range':[min(r['summary']['initialization_ms'] for r in runs),max(r['summary']['initialization_ms'] for r in runs)]})
    return result


def render(captures,output,phase_captures=()):
    results=[collect(p) for p in captures]
    cases=[c for result in results for c in result['cases']]
    doc=t.Document();doc.title('🏙️ Integrated PhysX GPU destruction — scaling measurements',1)
    doc.text('All measured advances include recorded commands, projectile insertion, ordinary physics, CUDA stress/material/topology work, up to one correction and mandatory completion. Timestep is 1/60 second. Rendering, video encoding, asset preparation and initial CUDA setup are excluded; initialization is reported separately. Every measured step is retained.')
    doc.text('Run count and duration are reported per scenario. Five × 60-second runs with every complete step at or below 8 ms satisfy the timing gate; shorter captures are diagnostic. Timing alone does not establish full physical or ten-minute lifecycle qualification. A mean below a deadline does not pass the peak requirement. Sleeping is disabled in these fixtures.')
    doc.table(['Scenario','Buildings','Chunks','Bonds','Projectiles','Launch','Runs × seconds','Peak clusters'],[
        [c['label'],c['buildings'],c['chunks'],c['bonds'],c['projectiles'],c['shot_path'],f"{c['trials']} × {c['seconds']}",c['population_peaks']['logical_clusters']] for c in cases])
    doc.text('World-size cases keep the original target and wall projectile unchanged; extra buildings sit beside its flight corridor. Concurrent-impact cases use the existing aerial launch. Aerial and wall trajectories are different workloads; compare scaling within each family.')
    doc.text('Recorded settings: projectile masses (kg) '+str(sorted({c['projectile_mass_kg'] for c in cases}))+', material-strength scales '+str(sorted({c['material_strength_scale'] for c in cases}))+', frame-strength scales '+str(sorted({c['frame_strength_scale'] for c in cases}))+'.')
    doc.title('⏱️ Complete advance — all repeats pooled')
    doc.table(['Scenario','Min ms','Mean ms','p50 ms','p95 ms','p99 ms','Worst ms','>8 ms / steps','>16.67 ms / steps','Mean simulation / realtime'],[
        [c['label'],*[t.fmt(c['metrics'][k]) for k in ['min','mean','p50','p95','p99','max']],
         f"{c['missed_8ms']} / {c['metrics']['n']}",f"{c['missed_60hz']} / {c['metrics']['n']}",
         f"{(1000/60)/c['metrics']['mean']:.2f}×"] for c in cases])
    doc.text('The realtime ratio divides 16.667 ms of simulated time by mean complete-advance cost. It describes physics/destruction throughput, not rendering or a complete game tick. The 60 Hz miss counter uses the exact 1000/60 ms threshold.')
    doc.title('💥 Actual work and memory')
    doc.table(['Scenario','Peak registered bodies','Peak active dynamic bodies','Peak active kinematic bodies','Peak contact reports/step','Peak retained stress nodes','Peak retained stress bonds','Broken bonds','Corrected steps','Sampled GPU MiB'],[
        [c['label'],*[c['population_peaks'][k] for k in ['bodies','active_dynamic_bodies','active_kinematic_bodies','contacts_frame','stress_active_nodes','stress_active_bonds']],
         str(c['broken_bonds_range']),str(c['corrected_steps_range']),t.fmt(c['sampled_gpu_memory_mib'])] for c in cases])
    doc.text('Chunks are persistent geometry/connectivity units; intact chunks share cluster motion. Active-body counts are PhysX scheduler observations, not chunk counts. Retained stress rows/bonds are not proof every row executed every solver iteration. GPU memory is sampled roughly every 250 ms and can miss brief allocation peaks; it includes the CUDA context and PhysX storage. Corrected steps count the whole run, while each step permits at most one correction.')
    doc.title('🔍 What happened during each worst complete step')
    doc.table(['Scenario','Repeat / step','Total ms','Commands ms','Physics + destruction ms','Completion ms','Active dynamic bodies','Contact reports','Stress iterations','Corrections'],[
        [c['label'],f"{c['peak']['repeat']} / {c['peak']['step']}",
         *[t.fmt(float(c['peak']['frame'][k])) for k in ['complete_step_ms','command_ms','physics_step_ms','completion_ms']],
         *[c['peak']['frame'][k] for k in ['active_dynamic_bodies','contacts_frame','stress_iterations','resim_passes']]] for c in cases])
    doc.text('These three subintervals add to the complete timer. Untraced captures do not separately measure stress, collision or host waits: the zero stress_solve_ms placeholder is not a zero-cost measurement. Further attribution requires a separate scoped capture; it cannot be inferred from counts or another run’s maximum.')
    doc.title('🛡️ Quality observations and initialization')
    doc.table(['Scenario','All frames converged / correction ≤1','Repeated counter history','Original wall counters','Initialization ms range'],[
        [c['label'],'Passed','Match' if c['repeated_counter_history_matches'] else 'Differ — review',
         'Match' if c['frozen_wall_counters_match'] else ('FAIL' if c['frozen_wall_counters_match'] is False else 'Different aerial workload'),
         '–'.join(t.fmt(v) for v in c['initialization_ms_range'])] for c in cases])
    doc.text('Wall counters require 199 broken bonds, three corrected steps and exactly 42 additional clusters. This does not replace the full trajectory, exact bond-identity or chunk-membership audit at each new size. Counter agreement is reported separately from physical qualification; no new large workload is declared fully qualified here.')
    incomplete=[r for r in results if r['status']!='complete']
    if incomplete:
        doc.title('❌ Incomplete campaigns — retained, not discarded')
        doc.table(['Capture','Status','Reason'],[[r['capture'],r['status'],r['error']] for r in incomplete])
    profiles=[]
    for capture in phase_captures:
        manifest=json.loads((capture/'campaign.json').read_text())
        t.require(manifest['status']=='complete','Incomplete phase capture')
        for record in manifest['runs']:
            if record['mode']!='phases':continue
            run=t.load_run(capture/record['name'],record);t.validate_duration(manifest,run['frames'])
            data=t.profile(capture/record['name'],run,{})
            peak=max(range(len(run['frames'])),key=lambda i:float(run['frames'][i]['complete_step_ms']))
            first=next(r for r in manifest['runs'] if r['case']==record['case'] and r['mode']=='plain')
            reference=t.load_run(capture/first['name'],first)
            summary=run['summary'];prefix=run['signature_rows'][:peak+1]==reference['signature_rows'][:peak+1]
            doc.title('🧭 Separate phase attribution: '+record['case'])
            doc.text(f"One scoped {summary['seconds']}-second run: {summary['chunks']} chunks, {summary['bonds']} bonds, {summary['projectiles']} projectiles. Scoped peak step {peak}: {float(run['frames'][peak]['complete_step_ms']):.3f} ms. This is not the same measured peak as the untraced table. CPU elapsed regions below form a partition; GPU stream timings overlap them and must not be added.")
            doc.table(['Operation','CPU / GPU responsibility','Mean ms','At scoped peak ms'],[
                [t.LABELS[k][0],t.LABELS[k][1],t.fmt(t.mean([v[k] for v in data['wall_partition']])),t.fmt(data['wall_partition'][peak][k])]
                for k in data['wall_partition'][0]])
            doc.table(['GPU stream stage','Mean ms','At scoped peak ms'],[
                [label,t.fmt(t.mean([v.get(k,0) for v in data['cuda_stages']])),t.fmt(data['cuda_stages'][peak].get(k,0))]
                for k,label in t.STAGES.items()])
            full=run['signature_rows']==reference['signature_rows']
            doc.text(f"Scoped versus first untraced counter history: full run {'matches' if full else 'differs'}; through this peak {'matches' if prefix else 'differs'}. Broken bonds: scoped {summary['broken_bonds']}, first untraced {reference['summary']['broken_bonds']}. CUDA events include stream gaps; these data do not identify a hardware bandwidth or SM-utilization limit.")
            profiles.append({'capture':str(capture.resolve()),'manifest_sha256':t.sha(capture/'campaign.json'),'case':record['case'],'peak_step':peak,'profile':data,'counter_history_matches':full,'counter_prefix_through_peak_matches':prefix})
    doc.title('Reproduce and inspect')
    doc.text('Inputs: tools/profiles/destruction-scaling.json. Capture one case with run-destruction-timing.py NEW_OUTPUT --config tools/profiles/destruction-scaling.json --case CASE_ID --gate-only --trials 2 --seconds 10. Regenerate this document with report-destruction-scaling.py CAPTURE... --output REPORT. Each capture retains exact commands, binary hashes, GPU isolation observations and lossless per-step CSVs.')
    doc.save(output)
    with (output/'report.json.gz').open('wb') as raw:
        with gzip.GzipFile(filename='',mode='wb',fileobj=raw,mtime=0) as out:
            out.write((json.dumps({'schema':1,'reporter_sha256':t.sha(Path(__file__)),'captures':results,'phase_captures':profiles},indent=2,sort_keys=True)+'\n').encode())
    return cases


def main():
    parser=argparse.ArgumentParser(description=__doc__)
    parser.add_argument('captures',nargs='+',type=Path);parser.add_argument('--output',required=True,type=Path)
    parser.add_argument('--phase-capture',action='append',type=Path,default=[])
    args=parser.parse_args();render(args.captures,args.output,args.phase_capture);print(args.output/'report.html')

if __name__=='__main__':main()
