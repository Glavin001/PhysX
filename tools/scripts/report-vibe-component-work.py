#!/usr/bin/env python3
"""Map intrusive component work to both evaluations of the native game consumer."""
import argparse
import collections
import gzip
import hashlib
import importlib.util
import json
from pathlib import Path

spec=importlib.util.spec_from_file_location('component_work',Path(__file__).with_name('report-destruction-component-work.py'))
w=importlib.util.module_from_spec(spec);spec.loader.exec_module(w)
require=w.require
FIELDS=['normal_contacts','broken_bonds','fragment_bodies','awake_fragment_bodies','native_corrections']
PHASES=['Residual preparation/projection','Residual operator and verification','Convergence decision',
        'Preconditioning and reductions','Direction update','Direction operator','Solution update','Dispatch/other']


def solve_mapping(frames):
    mapping=[]
    for tick,row in enumerate(frames):
        require(row['tick']==tick,'Noncontiguous ticks')
        corrections=row['native_corrections'];passes=row['native_counts']['native_stress_passes']
        require(corrections in (0,1) and passes==1+corrections,'Invalid evaluation count')
        mapping.extend((tick,evaluation) for evaluation in range(int(passes)))
    return mapping


def summarize(records,total):
    # Reuse the existing complete component/outer-operator accounting oracle.
    normalized=[dict(r,solve=0) for r in records]+[dict(total,solve=0)]
    w.audit(normalized,1)
    for r in records:
        require(r['anchored'] in (0,1),'Invalid anchor certificate')
        for key in ['polynomial_refs_per_sweep','precondition_sweeps']:
            require(isinstance(r[key],int) and r[key]>=0,'Invalid polynomial work')
        require(r['polynomial_refs_per_sweep']<=r['live_refs_per_sweep'],'Invalid polynomial graph census')
        require(r['precondition_sweeps']<=r['direction_sweeps'],'Polynomial sweeps exceed updates')
    sub=total['precondition_cycles']
    require(len(sub)==4 and all(isinstance(x,int) and x>=0 for x in sub),'Invalid precondition phase cycles')
    require(not total['component_updates'] or sum(sub)>0,'Missing precondition phase cycles')
    require(sum(sub)<=total['phase_cycles'][3],'Precondition subphases exceed parent')
    polynomial=sum(r['polynomial_refs_per_sweep']*r['precondition_sweeps'] for r in records)
    inverse=sum(2*r['nodes']*r['precondition_sweeps'] for r in records)
    require(polynomial==total['polynomial_live_visits'],'Polynomial visits do not sum')
    require(inverse==total['fine_inverse_applications'],'Inverse applications do not sum')
    def cohort(rows):
        return dict(components=len(rows),nodes=sum(r['nodes'] for r in rows),updates=sum(r['direction_sweeps'] for r in rows),
            outer_live_visits=sum(w.visits(r) for r in rows),
            polynomial_live_visits=sum(r['polynomial_refs_per_sweep']*r['precondition_sweeps'] for r in rows),
            inverse_applications=sum(2*r['nodes']*r['precondition_sweeps'] for r in rows),
            cta_cycles=sum(r['cta_cycles'] for r in rows),max_iterations=max((r['iterations'] for r in rows),default=0))
    groups={label:cohort([r for r in records if predicate(r)]) for label,predicate in [
        ('anchored',lambda r:r['anchored']),('free',lambda r:not r['anchored']),
        ('over_256_updates',lambda r:r['direction_sweeps']>256),('at_most_256_updates',lambda r:r['direction_sweeps']<=256)]}
    return dict(total=total,cohorts=groups)


def read_solves(path,mapping):
    # Bound memory to one solve, not millions of Python component dictionaries.
    result=[];records=[];expected=0
    opener=gzip.open if path.suffix=='.gz' else open
    with opener(path,'rt') as stream:
        for line in stream:
            r=json.loads(line);require(r['solve']==expected,'Missing, duplicate or reordered solve')
            if r['record']=='component':records.append(r)
            elif r['record']=='total':
                require(expected<len(mapping),'Extra solve outside accepted ticks')
                summary=summarize(records,r);summary['tick'],summary['evaluation']=mapping[expected]
                result.append(summary);records=[];expected+=1
            else:raise ValueError('Unknown component record')
    require(not records and expected==len(mapping),'Incomplete solve capture')
    return result


def generate(capture,reference,components,output):
    report=json.loads((capture/'report.json').read_text());ref=json.loads((reference/'report.json').read_text())
    require(report['status']==ref['status']=='complete','Incomplete consumer run')
    require(report['instrumented'] and not ref['instrumented'],'Diagnostic/reference timing roles incorrect')
    for key in ['buildings','chunks','bonds','steps','seconds','waves','projectiles','direct_gpu_api','sleeping',
                'max_correction','max_stress_passes','timestep_seconds','iterations_max','tolerance']:
        require(report[key]==ref[key],'Workload differs: '+key)
    require((capture/'commands.json').read_bytes()==(reference/'commands.json').read_bytes(),'Command tapes differ')
    frames=json.loads((capture/'steps.json').read_text());base=json.loads((reference/'steps.json').read_text())
    require(len(frames)==len(base)==report['steps'],'Frame count mismatch')
    mapping=solve_mapping(frames);solve_mapping(base)
    solves=read_solves(components,mapping);by=collections.defaultdict(list)
    for solve in solves:by[solve['tick']].append(solve)
    changes=[dict(tick=i,field=k,reference=a[k],diagnostic=b[k]) for i,(a,b) in enumerate(zip(base,frames)) for k in FIELDS if a[k]!=b[k]]
    first=next((i for i,(a,b) in enumerate(zip(base,frames)) if any(a[k]!=b[k] for k in FIELDS)),None)
    fracture=[i for i,r in enumerate(base) if r['broken_bonds']>(base[i-1]['broken_bonds'] if i else 0)]
    require(fracture,'No reference fracture')
    work=lambda tick:sum(s['total']['operator_live_visits']+s['total']['polynomial_live_visits'] for s in by[tick])
    selected=list(dict.fromkeys([max(fracture,key=lambda i:base[i]['complete_step_ms']),max(by,key=work)]))
    percent=lambda value,total:100*value/total if total else 0
    text=['# 🔬 Native game stress work: both evaluations', '',
        f"**{report['buildings']} buildings / {report['chunks']:,} chunks / {report['bonds']:,} bonds / "
        f"{report['projectiles']} physical rounds; {report['steps']} steps / {report['seconds']:g} simulated seconds.** "
        'Direct GPU API off, sleep on, correction ≤1 and stress evaluations ≤2.', '',
        f'All **{len(solves):,} stress evaluations** map to their accepted ticks and reconcile with individual component records. '
        f'First counted-state difference from the untraced reference: tick **{first}**. '
        'Matching counts are not proof of identical trajectories.', '',
        'This intrusive runtime synchronizes and reads diagnostic records. Its times are not performance results. '
        'Reference complete-step times select a tick; component work describes the separate diagnostic replay. '
        'CTA cycles overlap across SMs and include probe overhead; they are not additive milliseconds or hardware utilization.', '',
        '**Component updates** are numerical solver iterations summed across components, not physics replays. '
        '**Fine inverse application** means one cached 6×6 matrix-vector product used by the preconditioner. '
        'All listed computational phases run on the GPU; record readback/formatting belongs only to this CPU diagnostic.', '']
    for tick in selected:
        row=frames[tick]
        text += [f'## Tick {tick}', '',
            f"Untraced reference complete step: **{base[tick]['complete_step_ms']:.3f} ms**. Diagnostic accepted state: "
            f"{row['fragment_bodies']:,} fragment bodies / {row['awake_fragment_bodies']:,} awake, "
            f"{row['normal_contacts']:,} reported normal contacts, {row['broken_bonds']:,} cumulative broken bonds. "
            'The work below occurs before each evaluation commits its fractures.', '',
            '| Evaluation | Components | Component updates | Outer live adjacency visits | Polynomial live adjacency visits | Fine inverse applications |',
            '|---|---:|---:|---:|---:|---:|']
        for s in by[tick]:
            t=s['total'];label='trial' if s['evaluation']==0 else 'after correction'
            text.append(f"| {label} | {t['components']:,} | {t['component_updates']:,} | {t['operator_live_visits']:,} | {t['polynomial_live_visits']:,} | {t['fine_inverse_applications']:,} |")
        text += ['', '| Cohort (both evaluations) | Component evaluations | Updates | Share of live adjacency visits |', '|---|---:|---:|---:|']
        for group in ['anchored','free','over_256_updates','at_most_256_updates']:
            cohort=[s['cohorts'][group] for s in by[tick]]
            text.append(f"| {dict(anchored='Anchored structures',free='Free components',over_256_updates='More than 256 updates',at_most_256_updates='At most 256 updates')[group]} | {sum(c['components'] for c in cohort):,} | {sum(c['updates'] for c in cohort):,} | "
                f"{percent(sum(c['outer_live_visits']+c['polynomial_live_visits'] for c in cohort),work(tick)):.3f}% |")
        text += ['', 'Anchored/free and update-range rows are two separate partitions; do not add all four rows together.', '',
            '| Phase | Share of summed CTA phase cycles |','|---|---:|']
        clocks=[sum(s['total']['phase_cycles'][i] for s in by[tick]) for i in range(9)]
        for i,label in enumerate(PHASES):text.append(f'| {label} | {percent(clocks[i],clocks[8]):.2f}% |')
        sub=[sum(s['total']['precondition_cycles'][i] for s in by[tick]) for i in range(4)]
        text+=['', 'Within instrumented preconditioning: '+', '.join(f'{label} {percent(sub[i],sum(sub)):.2f}%' for i,label in enumerate(['polynomial/application','null projection','normalization reduction','conversion/gamma']))+'.', '']
    text+=['## Scope', '',
        'Outer-operator counts cover residual, verification and direction sweeps. Polynomial counts cover eligible '
        'off-diagonal visits; inverse applications count the two node-block products per polynomial sweep. '
        'Neither count includes every flop, cache-line transaction, initial factor build, hierarchy/null-mode setup or reliable-residual reconstruction. '
        'This is an algorithmic work census, not a complete hardware roofline. No physical budget was reduced.', '',
        'Regenerate with `report-vibe-component-work.py CAPTURE REFERENCE COMPONENTS_JSONL_GZ OUTPUT`.', '']
    output.mkdir(parents=True,exist_ok=False)
    (output/'report.md').write_text('\n'.join(text))
    (output/'analysis.json.gz').write_bytes(gzip.compress(json.dumps(dict(workload=report,selected_ticks=selected,solves=solves,counter_differences=changes),separators=(',',':')).encode(),mtime=0))
    for directory,label in [(capture,'diagnostic'),(reference,'reference')]:
        for name in ['report.json','steps.json','commands.json']:
            (output/(label+'-'+name+'.gz')).write_bytes(gzip.compress((directory/name).read_bytes(),mtime=0))
    (output/'source-hashes.json').write_text(json.dumps({str(p):hashlib.file_digest(p.open('rb'),'sha256').hexdigest() for p in [components,capture/'steps.json',reference/'steps.json']},indent=2))
    print(output/'report.md')

if __name__=='__main__':
    p=argparse.ArgumentParser(description=__doc__)
    for name in ['capture','reference','components','output']:p.add_argument(name,type=Path)
    a=p.parse_args();generate(a.capture,a.reference,a.components,a.output)
