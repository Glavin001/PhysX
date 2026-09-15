#!/usr/bin/env python3
"""Read existing archives only; verify samples and build this comparison package.

Run with matplotlib available. No simulation, compilation, services or network.
"""
from pathlib import Path
import csv
import gzip
import hashlib
import json
import math
import statistics as st
import subprocess
import sys

HERE = Path(__file__).resolve().parent
ROOT = HERE.parents[1]
VIBE = ROOT.parent / 'vibe-land-4'
BLAST = ROOT.parent / 'blast-stress-solver-2'
BASE = ROOT / 'reports/destruction-baseline-20260913'
SOURCES = {}


def read(path):
    path = Path(path)
    raw = path.read_bytes()
    SOURCES[str(path)] = hashlib.sha256(raw).hexdigest()
    return raw


def js(path):
    return json.loads(read(path))


def rows(path):
    return list(csv.DictReader(read(path).decode().splitlines()))


def stats(values):
    return dict(n=len(values), mean_ms=st.mean(values), max_ms=max(values),
                sd_ms=st.stdev(values), misses_60hz=sum(x > 1000/60 for x in values))


def compare_stats(a, b):
    for k in ['n', 'mean_ms', 'max_ms', 'sd_ms', 'misses_60hz']:
        assert math.isclose(a[k], b[k], rel_tol=1e-9, abs_tol=1e-8), (k,a[k],b[k])


def union_ms(intervals):
    end = None
    total = 0
    for a,b in sorted(intervals):
        if end is None or a > end:
            total += b-a
        elif b > end:
            total += b-end
        end = b if end is None else max(end,b)
    return total / 1e6


def collect():
    continuous = js(BASE/'data/continuous-controls.json')['runs']
    frames = rows(BASE/'data/continuous-control-frames.csv')
    assert len(frames) == 4800
    for run in continuous:
        selected = [r for r in frames if r['run'] == run['name']]
        assert len(selected) == 600
        values = [float(r['complete_step_ms']) for r in selected]
        compare_stats(stats(values), run)
        for r in selected:
            assert math.isclose(float(r['complete_step_ms']), sum(float(r[k]) for k in
                                ['command_ms','physics_step_ms','completion_ms']), abs_tol=1e-6)
        run['frames'] = [{k:float(r[k]) for k in ['step','complete_step_ms','bonds_broken',
                              'contacts_frame','stress_iterations','resim_passes']} for r in selected]
    restored = js(BASE/'data/unprofiled-baseline.json')
    samples = rows(BASE/'data/unprofiled-samples.csv')
    assert len(samples) == 2080
    for s in restored['scenarios']:
        for arm in ['A0','A1']:
            selected = [r for r in samples if r['scenario']==s['scenario'] and r['arm']==arm]
            compare_stats(stats([float(r['complete_step_ms']) for r in selected]),s[arm])
    report_path = VIBE/'bench-results/simulation-frontier/player-reports-2026-09-06-live/reports.json'
    reports = js(report_path)['reports']
    live_reports = [{k:r[k] for k in ['captured_at','shots_fired','awake_bodies','broken_bonds',
        'pending_input_frames','server_rolling_180_ticks_ms','first_physics_pass_point_sample',
        'client_frame_point_sample']} for r in reports]
    live_root = VIBE/'bench-results/simulation-frontier/live-0813-2026-09-06'
    live_summary = js(live_root/'summary.json')
    ticks = {}
    for name,digest in sorted(live_summary['sample_sha256'].items()):
        raw = read(live_root/name)
        assert hashlib.sha256(raw).hexdigest() == digest
        for r in json.loads(gzip.decompress(raw))['tick_ring']:
            assert r['t'] not in ticks or ticks[r['t']] == r
            ticks[r['t']] = r
    values = sorted(r['total'] for r in ticks.values())
    assert len(ticks) == 600
    ring = live_summary['deduplicated_ring']
    assert math.isclose(st.mean(values),ring['total_ms']['mean'],abs_tol=1e-9)
    assert max(values) == ring['total_ms']['max']
    assert values[int((len(values)-1)*.95+.5)] == ring['total_ms']['p95']
    live_summary['recomputed_misses_60hz'] = sum(v>1000/60 for v in values)
    live_summary['recomputed_sd_ms'] = st.stdev(values)
    live_summary['frames'] = sorted(ticks.values(),key=lambda r:r['t'])
    profiles = []
    for name in ['dense12-cold','tower64-cold','city256-late-debris']:
        path = ROOT/'out/destruction-baseline-20260913/cpu-full'/name/'attribution.json'
        d = js(path)
        wall = d['cpu_attribution']['disjoint_wall']
        assert math.isclose(sum(wall.values()),d['tick_ms'],abs_tol=1e-6)
        assert math.isclose(wall['gpu_and_scheduled_cpu_ms']+wall['gpu_without_scheduled_cpu_ms'],
                            d['gpu_activity_union_ms'],abs_tol=1e-6)
        copies=[]
        for kind,label in [(1,'CPU → GPU'),(2,'GPU → CPU'),(8,'GPU → GPU')]:
            selected = [r for r in d['transfers'] if r['kind']==kind]
            copies.append(dict(direction=label,count=len(selected),MB=sum(r['bytes'] for r in selected)/1e6,
                               active_ms=union_ms([(r['start_ns'],r['end_ns']) for r in selected])))
        scopes = sorted(d['cpu_attribution']['scopes'],key=lambda r:r['exclusive_thread_cpu_ms'] if r['exclusive_thread_cpu_ms'] is not None else -1,reverse=True)
        profiles.append(dict(name=name,tick_ms=d['tick_ms'],gpu_ms=d['gpu_activity_union_ms'],
            wall=wall,kernels=d['ranked_kernels'][:8],copies=copies,kernel_count=d['kernel_count'],
            copy_count=d['copy_count'],cpu_scopes=scopes[:12],physical=d['physical_sample'],
            diagnostics=d['diagnostics'],source=str(path),status=d['physical_status']))
    p4 = read(VIBE/'docs/p4-iteration-budget-videos-2026-09-04.md').decode()
    p4_rows=[]
    for line in p4.splitlines():
        if line.startswith('| ') and ' / ' in line and any(s in line for s in ['prod-it32','it256-']):
            cols=[c.strip() for c in line.strip('|').split('|')]
            p50,p95=map(float,cols[4].split(' / '))
            p4_rows.append(dict(arm=cols[0],broken=int(cols[1].replace(',','')),
                awake=int(cols[2].replace(',','')),bodies=int(cols[3].replace(',','')),p50_ms=p50,p95_ms=p95))
    assert len(p4_rows)==4
    # Human-readable provenance is deliberately separate from the local raw dataset.
    source_files = {
      VIBE: ['scripts/physics-env.sh','destruction/src/city_config.rs','destruction/src/runtime.rs',
             'physx-bridge/src/destruction.cc','physx-bridge/src/physx_bridge.cc',
             'server/src/bin/record_city_trace.rs','client/src/city/cityClient.ts',
             'docs/perf-suite-results-2026-08-29.md','docs/city-live-analysis-2026-09-06-0813.md',
             'docs/city-player-reports-2026-09-06-live.md','docs/contact-wrench-fidelity-2026-09-05.md',
             'docs/physical-graph-integration-2026-09-06.md','docs/compact-contacts-2026-09-06.md'],
      BLAST: ['blast/source/sdk/extensions/stressgpu/NvBlastExtStressGpu.cu',
              'blast/source/sdk/extensions/stress/NvBlastExtStressSolver.cpp','demos/blast-stress-demo/GPU_PIPELINE.md'],
      ROOT: ['physx/source/gpudestruction/src/PxgDestructionRuntime.cu',
             'physx/source/gpusimulationcontroller/src/PxgSimulationController.cpp',
             'blast/source/sdk/extensions/stressgpu/detail/StressComponentIteration.cuh',
             'blast/source/sdk/extensions/stressgpu/detail/StressNativePreconditioner.cuh',
             'blast/source/sdk/extensions/stressgpu/detail/StressNativeSettled.cuh',
             'qualification/vibe-coarse-assembly-20260908/external-reference/README.md',
             'reports/destruction-regression-suite/README.md']}
    for root,files in source_files.items():
        for file in files:read(root/file)
    read(ROOT/'out/destruction-baseline-20260913/environment-1789264041890825272.txt')
    provenance=dict(published='2026-09-13',method='Offline reanalysis; no new simulation or benchmark.',
        source_roots={str(root):subprocess.check_output(['git','-C',str(root),'rev-parse','HEAD'],text=True).strip()
                      for root in source_files},
        native_measured_commit='13b11af2e0aeabf4e0070931fbd8a060f383dfaf',
        native_runtime_sha256='d5770a80c2f4686b0ad311edcbfc8e128d14baee64653bf5e032305c12cf9354',
        vibe_live_release=reports[0]['release_artifact'],
        caveat='Working trees contain WIP and are not the measured or deployed artifact identities.',
        source_sha256=SOURCES,verification='Recomputed 4800 continuous native ticks, 2080 restored native ticks, 600 deduplicated Vibe ticks; checked source sample hashes and profile wall partitions.',
        archive_policy='data/ is local and ignored. Readable report, figures and standalone HTML preserve the comparison without the heavy archives.')
    native_files=[f for f in source_files[ROOT] if f.startswith(('physx/source/','blast/source/'))]
    native_files += ['blast/source/sdk/extensions/stressgpu/detail/StressIterationDispatch.inl',
                     'blast/source/sdk/extensions/stressgpu/NvBlastExtStressGpuTopology.cuh']
    provenance['selected_source_blobs']={f:hashlib.sha256(subprocess.check_output(
        ['git','-C',str(ROOT),'show','13b11af2:'+f])).hexdigest() for f in native_files}
    provenance['selected_source_comparison']={f:subprocess.check_output(
        ['git','-C',str(ROOT),'diff','13b11af2','--numstat','--',f],text=True).strip()
        or 'Identical working file' for f in native_files}
    (HERE/'provenance.json').write_text(json.dumps(provenance,indent=2)+'\n')
    result=dict(continuous=continuous,restored=restored,live_reports=live_reports,live=live_summary,
                profiles=profiles,p4=p4_rows)
    (HERE/'data/observations.json').write_text(json.dumps(result,indent=2)+'\n')
    return result


def figures(d):
    import matplotlib
    matplotlib.use('Agg')
    import matplotlib.pyplot as plt
    from matplotlib.patches import FancyBboxPatch, FancyArrowPatch
    plt.rcParams.update({'font.size':11,'font.family':'DejaVu Sans','axes.spines.top':False,
        'axes.spines.right':False,'svg.fonttype':'none','figure.facecolor':'#fafbfc',
        'axes.facecolor':'#fafbfc','text.color':'#172b3a','axes.labelcolor':'#172b3a'})
    blue,green,orange,purple='#2563a6','#19836e','#c26720','#8062aa'
    def save(fig,name):
        fig.savefig(HERE/'figures'/f'{name}.svg',bbox_inches='tight')
        fig.savefig(HERE/'figures'/f'{name}.png',dpi=160,bbox_inches='tight')
        plt.close(fig)
    fig,axes=plt.subplots(1,2,figsize=(14,5.2),gridspec_kw={'wspace':.3})
    rs=d['live_reports']
    axes[0].plot([r['awake_bodies'] for r in rs],[r['server_rolling_180_ticks_ms']['total_ms']['avg'] for r in rs],
                  'o-',color=blue,label='Rolling 180-tick mean')
    axes[0].plot([r['awake_bodies'] for r in rs],[r['server_rolling_180_ticks_ms']['total_ms']['p95'] for r in rs],
                  'x--',color=blue,alpha=.6,label='Rolling p95')
    for r in rs:
        y=r['server_rolling_180_ticks_ms']['total_ms']['avg']
        axes[0].annotate(f'{y:.1f}',(r['awake_bodies'],y),xytext=(0,8),textcoords='offset points',fontsize=9)
    axes[0].set(title='Vibe: one evolving live city, Sep 6',xlabel='Awake rigid bodies',ylabel='Server tick, ms',ylim=(0,490))
    for r in d['continuous']:
        if r['name'].startswith('impacts'):
            axes[1].plot([x['step']/60 for x in r['frames']],[x['complete_step_ms'] for x in r['frames']],color=green,lw=.7,alpha=.55)
    axes[1].set(title='Native: four continuous 256-building runs, Sep 13',xlabel='Simulation time, seconds',ylabel='Complete physics tick, ms',ylim=(0,210))
    axes[1].text(.98,.94,'Mean 51.0–51.7 ms\n519 / 600 misses in every run',ha='right',va='top',transform=axes[1].transAxes,fontsize=11)
    for ax in axes:
        ax.axhline(1000/60,color=orange,ls='--',lw=1,label='60 Hz budget: 16.667 ms');ax.grid(alpha=.15)
    axes[0].legend(fontsize=9,loc='upper left')
    fig.suptitle('Both systems miss real time under heavy destruction',fontsize=18,fontweight='bold',y=1.02)
    fig.text(.5,-.06,'Separate workloads, hardware and timer scopes. Different vertical scales. No cross-engine speed ratio.\nVibe: live server, 32-iteration budget, freeze on. Native: headless accepted physics, convergence required, ordinary sleep.',ha='center',fontsize=10)
    save(fig,'performance-context')

    fig,axes=plt.subplots(1,2,figsize=(13.5,4.8),gridspec_kw={'wspace':.38})
    idle=[r for r in d['continuous'] if r['name'].startswith('idle')]
    restored=next(s for s in d['restored']['scenarios'] if s['scenario']=='city256-intact-idle')
    vals=[[r['mean_ms'] for r in idle],[restored[a]['mean_ms'] for a in ['A0','A1']]]
    for i,v in enumerate(vals):
        axes[0].barh(i,st.mean(v),color=green if i==0 else purple,height=.55)
        axes[0].text(max(v)+1,i,f'{min(v):.2f}–{max(v):.2f} ms',va='center',bbox=dict(facecolor='#fafbfc',edgecolor='none',pad=1))
    axes[0].set(yticks=[0,1],yticklabels=['Continuous idle\n4 × 600 ticks','Restored idle\n2 × 20 ticks'],xlabel='Mean complete physics tick, ms',xlim=(0,84))
    axes[0].invert_yaxis();axes[0].axvline(1000/60,color=orange,ls='--');axes[0].set_title('Same native build; different cache history')
    p=d['p4'];x=range(4)
    axes[1].bar(x,[r['p50_ms'] for r in p],color=[blue,purple,purple,purple],width=.6)
    for i,r in enumerate(p):axes[1].text(i,r['p50_ms']+1,f"{r['p50_ms']:.1f} ms\n{r['broken']:,} bonds",ha='center',va='bottom',fontsize=9,bbox=dict(facecolor='#fafbfc',edgecolor='none',pad=1))
    axes[1].set(xticks=list(x),xticklabels=['32 / 0.45','256 / 0.80','256 / 0.60','256 / 0.45'],ylim=(0,58),
        xlabel='Iteration cap / material strength scale',ylabel='Median simulation tick, ms',title='Vibe P4: more solving changed the destruction')
    axes[1].axhline(1000/60,color=orange,ls='--')
    for ax in axes:ax.grid(axis='x' if ax==axes[0] else 'y',alpha=.15)
    fig.suptitle('Two comparisons that can mislead',fontsize=18,fontweight='bold',y=1.04)
    fig.text(.5,-.12,'Orange dashed line: 60 Hz budget (16.667 ms). Left labels give the range of process means.\nLeft: restore itself is excluded, but the next solve rebuilds disposable state; first ticks retained.\nRight: Sep 4 single runs, 45 simulated seconds, 26 shots; 256 arms also use incremental topology. Not an isolated iteration test.\nP4 command requests 30 settle ticks; setup/warmup is not covered by this chart. Raw P4 traces were not available locally.',ha='center',fontsize=10)
    save(fig,'comparison-traps')

    fig,axes=plt.subplots(1,2,figsize=(14,5),gridspec_kw={'width_ratios':[1,1.35],'wspace':.55})
    live=d['live']; labels=['Ownership','Validation','Sorting','Reduction','Routing']
    values=[live['contact_phases_ms'][k]['mean'] for k in ['ownership','validate','sort','reduce','route']]
    axes[0].barh(labels,values,color=blue);axes[0].invert_yaxis()
    for i,v in enumerate(values):axes[0].text(v+.3,i,f'{v:.2f}',va='center',fontsize=10)
    axes[0].set(xlabel='Host contact work, ms',xlim=(0,26),title='Vibe: 65.20 ms just preparing contacts')
    axes[0].text(0,-.22,'08:13 live capture: 10 point samples, six distinct updates.\nContact copy: another 2.17 ms. GPU stress field: 2.49 ms.\nThese values are not a full-tick partition.',transform=axes[0].transAxes,fontsize=9)
    ps=[d['profiles'][1],d['profiles'][2]]
    colors=[purple,green,'#73b4a4','#d3dce2']
    keys=['scheduled_cpu_without_gpu_ms','gpu_and_scheduled_cpu_ms','gpu_without_scheduled_cpu_ms','neither_traced_gpu_nor_scheduled_cpu_ms']
    labels=['CPU scheduled; GPU inactive','CPU + GPU active','GPU active; CPU not scheduled','Neither observed']
    left=[0,0]
    for key,label,color in zip(keys,labels,colors):
        vs=[p['wall'][key]/p['tick_ms']*100 for p in ps]
        axes[1].barh(range(2),vs,left=left,color=color,label=label,height=.5)
        left=[a+b for a,b in zip(left,vs)]
    axes[1].set(yticks=[0,1],yticklabels=['Tower\n142.25 ms trace','Large debris\n651.26 ms trace'],xlim=(0,100),xlabel='Share of each instrumented tick, %',title='Native: the limiting resource changes by scene')
    axes[1].invert_yaxis();axes[1].legend(loc='lower left',bbox_to_anchor=(0,-.36),ncol=2,fontsize=9)
    fig.suptitle('GPU integration removes a route; it does not remove all CPU work',fontsize=17,fontweight='bold',y=1.02)
    fig.text(.5,-.27,'Native: Sep 13 selected-build profiles, one first restored tick each. Instrumentation increases latency; CPU includes collector/driver work.\nNo profile fraction is converted to production milliseconds. A scheduled CPU interval is not automatically removable overhead.',ha='center',fontsize=10)
    save(fig,'bottlenecks')

    # Ownership diagram, conceptual dependencies rather than a timed trace.
    fig,ax=plt.subplots(figsize=(14,9));ax.set(xlim=(0,14),ylim=(0,9));ax.axis('off')
    def box(x,y,w,title,body,color):
        ax.add_patch(FancyBboxPatch((x,y),w,.91,boxstyle='round,pad=0.10',facecolor=color,edgecolor='none',alpha=.12))
        ax.text(x+.13,y+.67,title,fontsize=12,fontweight='bold',color=color)
        ax.text(x+.13,y+.29,body,fontsize=10,va='center',linespacing=1.35)
    def arrow(x,y,label=''):
        ax.add_patch(FancyArrowPatch((x,y),(x,y-.14),arrowstyle='-|>',mutation_scale=10,color='#536777'))
        if label:ax.text(x+.18,y-.22,label,fontsize=9,va='center')
    ax.text(.3,8.65,'Vibe + external CUDA stress',fontsize=18,fontweight='bold',color=blue)
    ax.text(7.3,8.65,'Native PhysX destruction',fontsize=18,fontweight='bold',color=green)
    stages=[
      ('GPU · rigid-body physics','PhysX solves this tick’s motion and contacts',green),
      ('CPU · contact and load preparation','Download contacts / motion; route, sort, reduce',blue),
      ('GPU · separate stress library','Upload loads; bounded iterative solve; material walk',green),
      ('CPU · fracture and body lifecycle','Read results; split bodies; update mappings / shapes',blue),
      ('CPU + GPU · optional replay','Restore motion; repeat physics and destruction',purple),
      ('CPU · accepted game state','Freeze / support bookkeeping; encode for clients',blue)]
    native=[
      ('GPU · rigid-body physics','PhysX solves this tick’s motion and contacts',green),
      ('GPU · loads and stress','Borrow engine buffers; solve to convergence',green),
      ('GPU · material and topology','Damage verdict; connectivity; fragment mass / motion',green),
      ('CPU · native lifecycle is still required','Register bodies, shape owners, contacts and queries',blue),
      ('GPU + CPU · optional correction','Restore affected state; physics; second stress pass',purple),
      ('GPU + CPU · accepted publication','Committed state, required host metadata and APIs',blue)]
    for col,items in [(0,stages),(7,native)]:
        for i,(title,body,color) in enumerate(items):
            y=7.35-i*1.25;box(col+.3,y,6.2,title,body,color)
            if i<5:arrow(col+3.4,y-.10)
    ax.text(.3,.18,'Both already share a CUDA context and run iteration control on the GPU.\nArrows show dependencies, not measured time or a CPU/GPU transfer at every stage.',fontsize=11)
    save(fig,'ownership')


if __name__=='__main__':
    data=collect()
    figures(data)
    print('PASS: verified 7,480 archived ticks; generated four SVG/PNG figures and hashed provenance.')
