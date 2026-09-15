#!/usr/bin/env python3
"""Archive and verify the seven continuous 200-tick baselines without a GPU."""
import csv
import hashlib
import json
import statistics
from pathlib import Path

HERE=Path(__file__).resolve().parent
BASE=HERE.parents[1]/'out/destruction-baseline-20260913/continuous200'
sha=lambda p:hashlib.sha256(p.read_bytes()).hexdigest()


def main():
    campaign=json.loads((BASE/'campaign.json').read_text());assert campaign['status']=='complete'
    plan=json.loads((BASE/'plan.json').read_text());assert len(campaign['cases'])==35
    data=HERE/'data';data.mkdir(exist_ok=True)
    all_frames=[];summaries=[]
    lines=['# Continuous simulation: seven fixtures, 200 ticks each', '',
        'Three independent unprofiled processes per fixture, 4,200 timed ticks in total. Every tick advances physics by 1/60 second with current-contact stress and at most one correction. No restore occurs. First-use ticks remain included; initialization is reported separately. Two additional 200-tick diagnostic trajectories per fixture collect native phase timings and Systems CPU/GPU activity; their durations are not pooled into the baseline.', '',
        'All five trajectories per fixture must match the first unprofiled run in per-tick physical-work, convergence and correction counters. This is not a full pose/force/energy equivalence proof. Consecutive ticks are correlated and the three process runs are the independent repetitions; observed peaks are not worst-case bounds.', '',
        '| Scenario | Chunks / bonds | Mean ms, runs 1 / 2 / 3 | Peak ms, runs 1 / 2 / 3 | 60 Hz misses / 200, each run | Initialization ms, each run |',
        '|---|---:|---:|---:|---:|---:|']
    for case in plan['scenarios']:
        name=case['scenario'];entries=[e for e in campaign['cases'] if e['scenario']==name]
        assert len(entries)==5 and all(e['status']=='complete' and not e['counter_differences'] for e in entries)
        row=dict(scenario=name,why=case['why'],runs=[],diagnostics=[])
        for entry in entries:
            for path,h in entry['native_files'].items():assert sha(Path(path))==h
            dest=Path(entry['path']);frames=list(csv.DictReader((dest/'native/native.frames.csv').open()))
            times=[float(f['complete_step_ms']) for f in frames];m=entry['metrics']
            assert len(times)==200 and abs(statistics.mean(times)-m['mean_ms'])<1e-9 and max(times)==m['peak_ms']
            assert sum(t>1000/60 for t in times)==m['misses_60hz']
            events={};damaged=False
            for f in frames:
                i=int(f['step']);broken=int(f['bonds_broken']);contacts=int(f['contacts_frame']);resim=int(f['resim_passes'])
                if i==0:event='first_tick'
                elif broken and not damaged:event='first_fracture'
                elif broken:event='further_fracture'
                elif resim:event='correction_without_new_bonds'
                elif contacts:event='contact_without_fracture'
                elif damaged:event='post_damage_no_contact'
                else:event='intact_no_contact'
                damaged=damaged or broken>0
                events.setdefault(event,[]).append(float(f['complete_step_ms']))
                all_frames.append(dict(scenario=name,mode=entry['mode'],event=event,**f))
            saved=dict(mode=entry['mode'],**m,events={k:dict(ticks=len(v),mean_ms=statistics.mean(v),max_ms=max(v),misses_60hz=sum(t>1000/60 for t in v)) for k,v in events.items()},path=entry['path'])
            row['runs' if entry['mode'].startswith('plain') else 'diagnostics'].append(saved)
        runs=row['runs'];assert len(runs)==3
        vals=lambda k:' / '.join(f'{r[k]:.3f}' for r in runs)
        scale=runs[0]['scale'];row['scale']=scale;summaries.append(row)
        lines.append(f"| {name} | {scale['chunks']:,} / {scale['bonds']:,} | {vals('mean_ms')} | {vals('peak_ms')} | {' / '.join(str(r['misses_60hz']) for r in runs)} | {vals('initialization_ms')} |")
    lines+=['', 'The event labels in the raw table form a disjoint descriptive partition, based on the recorded contact/fracture/correction flags. “Post damage, no contact” does not mean the rubble is settled. The native `stress_solve_ms` field is a legacy zero placeholder; detailed stress timing is in the diagnostic phase and Systems data.', '',
        '[All frames, including separately labelled diagnostics](data/continuous200-frames.csv), [structured per-run metrics and event breakdowns](data/continuous200.json), [frozen fixture plan](evidence/campaign/continuous200-plan.json).', '',
        '## Purpose of each fixture', '']
    lines += [f"- **{r['scenario']}**: {r['why']}." for r in summaries]
    (HERE/'continuous200.md').write_text('\n'.join(lines)+'\n')
    (data/'continuous200.json').write_text(json.dumps(dict(scope=plan['scope'],physical_scope=campaign['physical_scope'],scenarios=summaries),indent=2)+'\n')
    with (data/'continuous200-frames.csv').open('w') as f:
        w=csv.DictWriter(f,fieldnames=list(all_frames[0]));w.writeheader();w.writerows(all_frames)
    evidence=HERE/'evidence/campaign';evidence.mkdir(parents=True,exist_ok=True)
    for name in ['plan','campaign']:(evidence/('continuous200-'+name+'.json')).write_bytes((BASE/(name+'.json')).read_bytes())
    print('Verified and archived',len(all_frames),'continuous ticks; 4200 unprofiled, 2800 diagnostic')


if __name__=='__main__':main()
