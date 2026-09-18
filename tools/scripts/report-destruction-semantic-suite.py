#!/usr/bin/env python3
"""Report independent-run semantic timings, noise and paired A/B uncertainty.

Bootstrap intervals are descriptive. Paired randomized-order comparisons also
report sign-randomization p-values with Holm correction over the entire suite.
No timing statistic certifies physical equivalence or snapshot restoration.
"""
import argparse
import csv
import gzip
import hashlib
import importlib.util
import io
import itertools
import json
import math
from pathlib import Path
import random
import statistics as st

BUDGETS = {'8ms':8., '120Hz':1000/120, '60Hz':1000/60}
PHYSICAL = ('bodies','awake_bodies','splits_total','contacts_total','resim_passes',
            'correction_status','contacts_frame','projectiles_active','bonds_broken',
            'stress_converged','logical_clusters','native_dynamic_bodies',
            'native_kinematic_bodies','active_dynamic_bodies','active_kinematic_bodies',
            'contact_pairs','contact_pairs_with_contacts','solver_rows','stress_active_nodes',
            'stress_active_bonds','stress_islands','stress_passes','post_correction_bonds_broken')


def quantile(values, p):
    values=sorted(values)
    x=(len(values)-1)*p
    lo=int(x)
    return values[lo]+(values[min(lo+1,len(values)-1)]-values[lo])*(x-lo)


def interval(values, seed=1109, samples=10000):
    if len(values)<10:
        return None
    rng=random.Random(seed)
    means=[st.mean(rng.choices(values,k=len(values))) for _ in range(samples)]
    return [quantile(means,.025),quantile(means,.975)]


def distribution(values):
    mean=st.mean(values)
    return dict(n=len(values),mean_ms=mean,median_ms=st.median(values),min_ms=min(values),max_ms=max(values),
                sample_sd_ms=st.stdev(values) if len(values)>1 else None,
                cv_percent=100*st.stdev(values)/mean if len(values)>1 and mean else None,
                mean_bootstrap95_ms=interval(values),
                p95_ms=quantile(values,.95) if len(values)>=20 else None,
                p99_ms=quantile(values,.99) if len(values)>=100 else None,
                budget_misses={k:dict(count=sum(v>b for v in values),denominator=len(values),
                                      percent=100*sum(v>b for v in values)/len(values)) for k,b in BUDGETS.items()},
                samples_ms=values)


def permutation_p(deltas, order_signs=None):
    n=len(deltas)
    observed=abs(sum(deltas))
    if order_signs is not None:
        # Condition on the runner's balanced AB/BA allocation. Under the sharp
        # no-effect null, first-minus-second observations remain fixed while
        # labels vary over exactly the assignments used by this design.
        positional=[d*s for d,s in zip(deltas,order_signs)]
        positive=sum(s==1 for s in order_signs)
        total=sum(positional)
        combinations=math.comb(n,positive)
        if combinations<=20000:
            sums=(2*sum(positional[i] for i in indices)-total
                  for indices in itertools.combinations(range(n),positive))
            return sum(abs(v)>=observed-1e-12 for v in sums)/combinations
        rng=random.Random(9011)
        sums=(2*sum(positional[i] for i in rng.sample(range(n),positive))-total for _ in range(100000))
        return (1+sum(abs(v)>=observed-1e-12 for v in sums))/100001
    if n<=16:
        totals=(sum(d if mask&(1<<i) else -d for i,d in enumerate(deltas)) for mask in range(1<<n))
        return sum(abs(v)>=observed-1e-12 for v in totals)/(1<<n)
    rng=random.Random(9011)
    totals=[sum(d if rng.getrandbits(1) else -d for d in deltas) for _ in range(100000)]
    return (1+sum(abs(v)>=observed-1e-12 for v in totals))/(len(totals)+1)


def holm(pvalues, family_size):
    previous=0.
    result={}
    for rank,(key,p) in enumerate(sorted(pvalues.items(),key=lambda item:item[1])):
        previous=max(previous,min(1.,(family_size-rank)*p))
        result[key]=previous
    return result


def report(directory, practical_relative=.01, practical_ms=.05):
    campaign=json.loads((directory/'campaign.json').read_text())
    if campaign['status']!='complete':
        raise ValueError('Incomplete campaign cannot produce an acceptance report')
    results=[]
    for case in campaign['config']['scenarios']:
        runs=[r for r in campaign['runs'] if r['fixture']==case['fixture']]
        if not runs:
            continue
        item=dict(case,arms={})
        for arm in sorted({r['arm'] for r in runs}):
            chosen=[r for r in runs if r['arm']==arm]
            selected=[r['selected'][case['id']] for r in chosen]
            if any('row' not in r for r in selected):
                item['arms'][arm]={'status':'event_not_observed','details':selected}
                continue
            rows=[r['row'] for r in selected]
            times=[float(r['complete_step_ms']) for r in rows]
            predicates=all(r['predicate_pass'] for r in selected)
            counters={k:sorted({int(r[k]) for r in rows}) for k in PHYSICAL+('stress_iterations',)}
            half=len(times)//2
            drift=st.mean(times[half:])-st.mean(times[:half]) if half else None
            delta=max(practical_ms,practical_relative*st.mean(times))
            # Planning estimate only; use a new, fixed-size confirmation dataset.
            z=st.NormalDist().inv_cdf(1-.05/(2*len(campaign['config']['scenarios'])))
            estimated=math.ceil(2*(z*st.stdev(times)/delta)**2) if len(times)>1 else None
            item['arms'][arm]=dict(status='measured' if predicates else 'semantic_predicate_failed',
                **distribution(times),step=int(rows[0]['step']),counters=counters,
                descriptive_second_minus_first_half_ms=drift,
                stages={key:distribution([float(r[key]) for r in rows]) for key in ('command_ms','physics_step_ms','completion_ms')},
                practical_effect_ms=delta,estimated_independent_pairs_for_effect=estimated,
                estimate_note='Pilot normal approximation with suite correction; not a power guarantee or permission to stop on significance.')
        if all(a in item['arms'] and item['arms'][a]['status']=='measured' for a in ('A','B')):
            ar={r['repeat']:r for r in runs if r['arm']=='A'}
            br={r['repeat']:r for r in runs if r['arm']=='B'}
            if set(ar)!=set(br) or len(ar)!=campaign['repeats']:
                raise ValueError('Unmatched A/B pairs')
            deltas=[float(ar[i]['selected'][case['id']]['row']['complete_step_ms'])-
                    float(br[i]['selected'][case['id']]['row']['complete_step_ms']) for i in sorted(ar)]
            orders={o:[] for o in ('AB','BA')}
            order_signs=[]
            sequence=[(r['repeat'],r['arm']) for r in runs]
            for i,d in zip(sorted(ar),deltas):
                ab=sequence.index((i,'A'))<sequence.index((i,'B'))
                orders['AB' if ab else 'BA'].append(d)
                order_signs.append(1 if ab else -1)
            item['comparison']=dict(pairs=len(deltas),saved_ms=st.mean(deltas),saved_bootstrap95_ms=interval(deltas),
                saved_samples_ms=deltas,sign_randomization_p=permutation_p(deltas,order_signs),
                by_order_saved_ms={k:st.mean(v) if v else None for k,v in orders.items()},
                physical_counter_pairs_equal=all(all(ar[i]['selected'][case['id']]['row'][k]==br[i]['selected'][case['id']]['row'][k] for k in PHYSICAL) for i in ar),
                conclusion='Timing evidence only; no automatic promotion')
        results.append(item)
    adjusted=holm({r['id']:r['comparison']['sign_randomization_p'] for r in results if 'comparison' in r},len(campaign['config']['scenarios']))
    for item in results:
        if 'comparison' in item:
            item['comparison']['holm_family_p']=adjusted[item['id']]
    trajectories={}
    scoped=[]
    if campaign['phase_scopes']:
        def module(name):
            spec=importlib.util.spec_from_file_location(name,Path(__file__).with_name(name+'.py'))
            result=importlib.util.module_from_spec(spec);spec.loader.exec_module(result)
            return result
        accounting=module('report-destruction-timing')
        grouping=module('destruction-peak-opportunities')
    for run in campaign['runs']:
        path=directory/run['name']/'scene/native.frames.csv.gz'
        raw=gzip.decompress(path.read_bytes())
        if hashlib.sha256(raw).hexdigest()!=run['frames_sha256']:
            raise ValueError('Raw frame evidence changed')
        rows=list(csv.DictReader(io.StringIO(raw.decode())))
        if campaign['phase_scopes']:
            profile=accounting.profile(path.parent,dict(frames=rows,summary=run['summary']),{})
            for case_id,selection in run['selected'].items():
                if 'row' not in selection:
                    continue
                step=int(selection['row']['step'])
                groups={key:0. for key in grouping.GROUPS}
                for key,value in profile['wall_partition'][step].items():
                    owner=grouping.group(key)
                    if owner is None:
                        raise ValueError('Unclassified host scope '+key)
                    groups[owner]+=value
                groups['commands']=float(rows[step]['command_ms'])
                groups['completion']=float(rows[step]['completion_ms'])
                scoped.append(dict(scenario=case_id,run=run['name'],step=step,
                    complete_step_ms=float(rows[step]['complete_step_ms']),host_wall_groups_ms=groups,
                    timestamp_bookend_ms=sum(groups.values())-float(rows[step]['complete_step_ms']),
                    cuda_event_stages_ms=profile['cuda_stages'][step],
                    scope='Single instrumented diagnostic; host groups include GPU waits. CUDA intervals are nested, not additive; trial is not isolated stock PhysX.'))
        values=[float(r['complete_step_ms']) for r in rows]
        index=max(range(len(values)),key=values.__getitem__)
        summary=run['summary']
        trajectories.setdefault(run['fixture'],{}).setdefault(run['arm'],[]).append(dict(run=run['name'],
            n=len(values),mean_ms=st.mean(values),max_ms=max(values),max_step=int(rows[index]['step']),
            initialization_ms=summary['initialization_ms'],initialization_plus_steps_ms=summary['initialization_ms']+sum(values),
            budget_misses={k:dict(count=sum(v>b for v in values),denominator=len(values),percent=100*sum(v>b for v in values)/len(values)) for k,b in BUDGETS.items()},
            physical_history_sha256=hashlib.sha256(json.dumps([[r[k] for k in PHYSICAL] for r in rows]).encode()).hexdigest()))
    return dict(schema=1,scope=campaign['scope'],shared_gpu=campaign['shared_gpu'],phase_scopes=campaign['phase_scopes'],
                inference='Independent process repetitions, not adjacent ticks. Fixed-prefix inputs may vary numerically; full snapshot restore is unqualified. No result certifies fidelity.',
                confidence_method='Independent-run percentile bootstrap95, unavailable below10 samples; paired two-sided randomization conditional on balanced AB/BA order, with Holm suite correction. Preselect confirmation count; no optional stopping.',
                scenarios=results,trajectories=trajectories,diagnostic_stage_samples=scoped)


def main():
    parser=argparse.ArgumentParser(description=__doc__)
    parser.add_argument('campaign',type=Path)
    parser.add_argument('--output',type=Path,required=True)
    args=parser.parse_args()
    data=report(args.campaign)
    args.output.write_text(json.dumps(data,indent=2)+'\n')
    for row in data['scenarios']:
        print(row['id'],row['name'],{a:round(x['mean_ms'],4) if 'mean_ms' in x else x['status'] for a,x in row['arms'].items()})


if __name__=='__main__':
    main()
