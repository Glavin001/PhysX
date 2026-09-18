#!/usr/bin/env python3
"""Account for component work at measured reference peaks, without hardware-counter claims."""
import argparse
import collections
import gzip
import hashlib
import importlib.util
import json
from pathlib import Path
spec=importlib.util.spec_from_file_location('peak',Path(__file__).with_name('destruction-peak-opportunities.py'))
peak=importlib.util.module_from_spec(spec);spec.loader.exec_module(peak)

def require(ok,message):
    if not ok:raise ValueError(message)

def visits(r,field='live_refs_per_sweep'):
    return r[field]*(r['residual_sweeps']+r['verification_sweeps']+r['direction_sweeps'])

def audit(records,frames):
    groups=collections.defaultdict(list);totals={}
    for r in records:
        if r['record']=='component':groups[r['solve']].append(r)
        elif r['record']=='total':
            require(r['solve'] not in totals,'Duplicate solve total');totals[r['solve']]=r
        else:raise ValueError('Unknown record type')
    require(set(totals)==set(range(frames)),'Missing solve totals')
    require(set(groups)<=set(totals),'Components without solve total')
    for step,t in totals.items():
        rows=groups[step];require(len({r['id'] for r in rows})==len(rows),'Duplicate component ID')
        require(t['unmeasured_components']==0,'Large-component work unmeasured')
        require(len(rows)==t['components'],'Missing component records')
        require(all(r['path']==1 and r['converged'] for r in rows),'Unmeasured or unconverged component')
        for r in rows:
            require(all(isinstance(r[k],int) and r[k]>=0 for k in ['nodes','dynamic_nodes','csr_refs_per_sweep','live_refs_per_sweep','residual_sweeps','verification_sweeps','direction_sweeps','iterations','cta_cycles']),'Invalid work count')
            require(r['dynamic_nodes']<=r['nodes'] and r['live_refs_per_sweep']<=r['csr_refs_per_sweep'],'Invalid graph census')
        require(sum(visits(r) for r in rows)==t['operator_live_visits'],'Live visits do not sum')
        require(sum(visits(r,'csr_refs_per_sweep') for r in rows)==t['operator_csr_visits'],'CSR visits do not sum')
        require(sum(visits(r,'dynamic_nodes') for r in rows)==t['operator_node_visits'],'Node visits do not sum')
        require(sum(r['direction_sweeps'] for r in rows)==t['component_updates'],'Updates do not sum')
        require(len(t['phase_cycles'])==9 and all(isinstance(x,int) and x>=0 for x in t['phase_cycles']),'Invalid phase cycle count')
        require(sum(t['phase_cycles'][:8])==t['phase_cycles'][8],'Phase cycles do not close')
    return groups,totals

def render(manifest,reference,records,differences):
    run=reference['runs'][manifest['case']]['plain'][0];frames=run['frames'];s=run['summary']
    groups,totals=audit(records,len(frames))
    worst=max(range(len(frames)),key=lambda i:float(frames[i]['complete_step_ms']))
    most=max(totals,key=lambda i:totals[i]['operator_live_visits'])
    steps=list(dict.fromkeys([worst,most]));selection=[]
    physical=[d for d in differences if d['field']!='stress_iterations']
    text=['# 🔬 Component work during actual bombardment','',
        f"{s['buildings']} buildings, {s['chunks']:,} chunks, {s['bonds']:,} bonds, {s['projectiles']} projectiles; "
        f"{s['seconds']} simulated seconds, {len(frames)} steps, correction maximum {s['correction_limit']}. Sleeping: {s['sleeping']}.",'',
        'This is an intrusive diagnostic replay of the recorded inputs. Its wall times are not performance results. '
        'Step selection uses the first untraced reference run; counts and cycles come from the separate diagnostic replay. '
        'CPU observation and output exist only in the excluded diagnostic runtime. NVIDIA collision and rigid-body kernels are unchanged.','',
        f'All {len(frames)} solve totals reconcile with their complete component records. No large components are unmeasured. '
        f'Compared counter differences: {len(physical)} in physical/convergence counters, {len(differences)-len(physical)} in reported iteration count. '
        'Counter agreement is not proof of identical trajectories or a replacement for physical quality gates.','']
    labels=['Residual projection + component preparation','Residual operator + convergence verification','Convergence decision',
            'Preconditioner and associated reductions','Direction update','Direction operator','Solution update','Dispatch/remaining']
    for step in steps:
        rows=groups[step];t=totals[step];cycles=sum(r['cta_cycles'] for r in rows)
        main=[r for r in rows if r['iterations']>256];main_visits=sum(visits(r) for r in main)
        live=t['operator_live_visits'];csr=t['operator_csr_visits'];ratio=lambda x,total:100*x/total if total else 0
        text += [f'## Step {step}'+(' — reference complete-step peak' if step==worst else ' — maximum measured operator work'),'',
            f"Reference complete advance: {float(frames[step]['complete_step_ms']):.3f} ms. "
            f"Diagnostic stress components: {len(rows):,}; component updates: {t['component_updates']:,}; "
            f"operator node visits: {t['operator_node_visits']:,}; CSR visits: {csr:,}; live directed visits: {live:,}.",'',
            f"{len(main)} components exceed 256 iterations: they account for {ratio(main_visits,live):.4f}% of live operator visits "
            f"and {ratio(sum(r['cta_cycles'] for r in main),cycles):.2f}% of recorded component cycles. "
            f"{ratio(csr-live,csr):.2f}% of CSR visits encounter entries excluded from live bond arithmetic.",'',
            '| Component iteration range | Components | Nodes | Updates | Live operator visits | Share of component cycles |',
            '|---|---:|---:|---:|---:|---:|']
        for lo,hi in [(0,0),(1,25),(26,100),(101,256),(257,1000000000)]:
            cohort=[r for r in rows if lo<=r['iterations']<=hi]
            label='>256' if lo==257 else str(lo) if lo==hi else f'{lo}–{hi}'
            text.append(f"| {label} | {len(cohort)} | {sum(r['nodes'] for r in cohort):,} | {sum(r['direction_sweeps'] for r in cohort):,} | {sum(visits(r) for r in cohort):,} | {ratio(sum(r['cta_cycles'] for r in cohort),cycles):.2f}% |")
        text += ['', '| Diagnostic phase | Share of summed CTA phase cycles |','|---|---:|']
        text += [f'| {label} | {ratio(t["phase_cycles"][i],t["phase_cycles"][8]):.2f}% |' for i,label in enumerate(labels)]
        text += ['', 'Cycles include probe overhead and overlap across GPU multiprocessors. These percentages are work-location evidence, not additive milliseconds, SM utilization or a hardware roofline. '
            'Component records describe the stress solve before this step’s fracture; end-of-step scene topology counters may differ.','']
        selection.append(dict(step=step,total=t,over_256_components=len(main),over_256_live_share=ratio(main_visits,live),excluded_csr_share=ratio(csr-live,csr)))
    dominant=selection[0]['over_256_live_share']>90
    text += ['## Decision supported by this capture','',
        ('The main repeated work is solving retained structural components, not processing tiny rubble components. '
        'The next behavior-preserving stress experiment should reduce iterations for these retained components through stronger preconditioning, or reduce their repeated sparse-operator work. '
        'Avoid prioritizing tiny-component scheduling merely because there are many fragments.' if dominant else
         'This capture does not establish dominance by components exceeding 256 iterations. Use the measured cohorts above; do not infer the same priority as the large bombardment.'),'',
        'Stable compaction of broken-bond adjacency is a separate candidate: it can eliminate excluded CSR visits while retaining live arithmetic order. '
        'The fraction of excluded entries is not the fraction of total time that can be saved; measure the resulting complete-step change.','',
        'The original solver’s bounded cross-frame policy remains a separate behavior comparison. It must not be presented as a same-fidelity implementation speedup against mandatory within-step convergence. '
        'Correction and ownership remain major independent peak costs; this capture does not measure their work or eliminate the need to optimize our integration.','',
        '## Reproduce','',
        'Build `PhysXDestructionGpuWorkDiagnostic`, then run `run-destruction-component-capture.py REFERENCE_REPORT_JSON_GZ NEW_CAPTURE_DIRECTORY`. '
        'Generate this report with `report-destruction-component-work.py CAPTURE_DIRECTORY REFERENCE_REPORT_JSON_GZ --output REPORT_DIRECTORY`.', '']
    return '\n'.join(text),dict(schema=1,steps=selection,physical_counter_differences=physical,iteration_counter_differences=[d for d in differences if d['field']=='stress_iterations'])

def main():
    p=argparse.ArgumentParser(description=__doc__);p.add_argument('capture',type=Path);p.add_argument('reference',type=Path);p.add_argument('--output',required=True,type=Path);args=p.parse_args()
    m=json.loads((args.capture/'capture.json').read_text());require(m['status']=='complete','Capture incomplete')
    require(hashlib.sha256(args.reference.read_bytes()).hexdigest()==m['source_report_sha256'],'Reference changed')
    for name,digest in m['files'].items():require(hashlib.sha256((args.capture/name).read_bytes()).hexdigest()==digest,'Capture changed: '+name)
    ref=json.loads(gzip.decompress(args.reference.read_bytes()))
    records=[json.loads(line) for line in gzip.open(args.capture/'components.jsonl.gz','rt')]
    changes=json.loads((args.capture/'counter-differences.json').read_text())
    text,result=render(m,ref,records,changes);args.output.mkdir(parents=True,exist_ok=True)
    (args.output/'report.md').write_text(text);(args.output/'report.html').write_text(peak.render_html(text))
    result['source_capture_sha256']=hashlib.sha256((args.capture/'capture.json').read_bytes()).hexdigest()
    (args.output/'report.json').write_text(json.dumps(result,indent=2,sort_keys=True)+'\n');print(args.output/'report.html')

if __name__=='__main__':main()
