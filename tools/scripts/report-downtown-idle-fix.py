#!/usr/bin/env python3
"""Generate paired complete-advance evidence, retaining startup and impact peaks."""
import argparse, gzip, hashlib, json, statistics
from pathlib import Path

def generate(root, output):
    output.mkdir(parents=True, exist_ok=True)
    rows, evidence = [], {}
    for label in ['final-baseline-idle','final-candidate-idle','final-baseline-impact','final-candidate-impact']:
        path = root/label
        report = json.loads((path/'report.json').read_text())
        frames = json.loads((path/'steps.json').read_text())
        commands = json.loads((path/'commands.json').read_text())
        assert report['status']=='complete' and not report['instrumented']
        assert len(frames)==report['steps'] and [r['tick'] for r in frames]==list(range(len(frames)))
        assert report['chunks']==24105 and report['bonds']==74543
        assert all(r['native_corrections']<=1 for r in frames)
        if label.endswith('idle'):
            assert not commands and all(r['broken_bonds']==0 and r['fragment_bodies']==0 for r in frames)
        else:
            assert commands and frames[-1]['broken_bonds']>0
        values=[r['complete_step_ms'] for r in frames]
        fractures=[r for i,r in enumerate(frames) if r['broken_bonds']>(frames[i-1]['broken_bonds'] if i else 0)]
        loaded=[r for r in frames if commands and r['tick']>=commands[0]['tick']]
        stats=dict(min=min(values),mean=statistics.mean(values),median=statistics.median(values),maximum=max(values),
                   first=values[0],after_first_max=max(values[1:]),missed_60hz=sum(v>1000/60 for v in values),
                   impact_peak=max((r['complete_step_ms'] for r in loaded),default=None),
                   fracture_peak=max((r['complete_step_ms'] for r in fractures),default=None))
        evidence[label]=dict(report=report,stats=stats,last=frames[-1],commands=commands)
        for name in ['report.json','steps.json','commands.json']:
            data=(path/name).read_bytes()
            archive=output/(label+'-'+name+'.gz')
            if archive.exists():assert gzip.decompress(archive.read_bytes())==data, 'refusing to overwrite different evidence'
            else:archive.write_bytes(gzip.compress(data,mtime=0))
        def ms(v):return '—' if v is None else f'{v:.3f}'
        rows.append(f"| {label.removeprefix('final-')} | {len(frames)} | {report['projectiles']} | {ms(stats['min'])} | {ms(stats['mean'])} | {ms(stats['median'])} | {ms(stats['maximum'])} | {ms(stats['impact_peak'])} | {ms(stats['fracture_peak'])} | {stats['missed_60hz']} |")
    for regime in ['idle','impact']:
        a,b=[evidence['final-'+arm+'-'+regime] for arm in ['baseline','candidate']]
        assert a['commands']==b['commands']
        for key in ['source_asset','manifest_hash','chunks','bonds','steps','projectiles']:
            assert a['report'].get(key)==b['report'].get(key),key
    a,b=[json.loads((root/('final-'+arm+'-impact')/'steps.json').read_text()) for arm in ['baseline','candidate']]
    work_keys=['broken_bonds','fragment_bodies','awake_fragment_bodies','native_corrections']
    differences={k:[i for i,(x,y) in enumerate(zip(a,b)) if x[k]!=y[k]] for k in work_keys}
    evidence['physical_counter_differences']=differences
    (output/'analysis.json').write_text(json.dumps(evidence,indent=2))
    runtime=root/'coarse-v2-lib/libPhysXDestructionGpuRuntime_64.so'
    text=['# Downtown idle scheduling fix','',
      '27 buildings, **24,105 chunks / 74,543 bonds** on RTX 4090. Each arm runs 600 steps / 10 simulated seconds. Direct GPU off, native sleeping on, dt 1/60, at most one correction and two stress evaluations per tick.', '',
      'Timer: physical commands through accepted physics, stress, fracture/correction, mandatory events and game snapshot staging. Excludes initial asset preparation, rendering, network encoding and report generation. Every step, including step zero, is retained.', '',
      '| Run | Steps | Projectiles | Min ms | Mean ms | Median ms | All-step max ms | Impact/aftermath max ms | New-fracture max ms | >16.67 ms steps |',
      '|---|---:|---:|---:|---:|---:|---:|---:|---:|---:|']+rows+['',
      'Impact/aftermath starts at the first recorded command and includes settling. New-fracture peaks select steps that actually increase broken-bond count. Neither replaces the all-step deadline gate. Idle has no destruction or fragment bodies.', '',
      '## What changed','',
      'The coarse hierarchy retained tens of thousands of bond contributions while reducing node count. Eight-lane row processing serialized that work. Long coarse rows now use full CUDA blocks, FP64 accumulation and a shared reduction schedule for cooperative and block-local execution. No bonds, stress iterations, convergence requirements or material evaluations are suppressed.', '',
      'The isolated baseline phase replay measured about 38.4 ms in CUDA stress per steady idle advance. A separate kernel trace identified persistentStressSolve; temporary internal probes identified coarse residual/restriction/correction reductions. These diagnostic timings are separate from the untraced table.', '',
      '## Validation and limits','',
      'Resident analytic/3D/motion suites, the independent dense V-cycle oracle, a new 24-node / 1,472-bond parallel-column fixture, synchronization checks, ordinary-scene tests and the frozen 444-chunk / 896-bond / one-projectile penetration audit are recorded alongside the capture. The frozen wall retains 398 chunks and detaches 46 with 199 broken bonds.', '',
      'Downtown impact runs end with the same broken-bond/fragment totals, but are not bit-identical trajectories. Per-step counter differences are retained in analysis.json: '+str(differences)+'. These differences do not replace the unchanged exact frozen-wall gate.', '',
      'The separate 256-building bombardment screen uses 113,664 chunks, 229,376 bonds and 768 projectiles for 600 steps. It still fails real-time peaks; this is a downtown idle fix, not large-destruction completion. One paired run per regime is a short screen, not five-trial or endurance qualification. Startup peaks remain failures.', '',
      f'Qualified runtime SHA-256: `{hashlib.sha256(runtime.read_bytes()).hexdigest()}`.', '',
      '[Machine-readable report and accepted-work counts](analysis.json). All paired raw samples and input tapes are archived as compressed JSON alongside this file.', '']
    (output/'report.md').write_text('\n'.join(text))
    print(output/'report.md')
if __name__=='__main__':
    p=argparse.ArgumentParser(description=__doc__);p.add_argument('capture',type=Path);p.add_argument('output',type=Path)
    args=p.parse_args();generate(args.capture,args.output)
