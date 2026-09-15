#!/usr/bin/env python3
"""Render standalone baseline figures after exclusive data collection is done."""
import csv
import importlib.metadata
import json
import platform
from pathlib import Path
import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt

HERE=Path(__file__).resolve().parent
FIG=HERE/'figures'
FIG.mkdir(exist_ok=True)
plt.rcParams.update({'font.size':10,'axes.spines.top':False,'axes.spines.right':False,'svg.fonttype':'none'})


def save(fig,name):
    fig.savefig(FIG/(name+'.svg'),bbox_inches='tight')
    fig.savefig(FIG/(name+'.png'),dpi=160,bbox_inches='tight')
    plt.close(fig)


def main():
    versions={name:importlib.metadata.version(name) for name in ['matplotlib','numpy','contourpy','pillow','fonttools','kiwisolver','cycler','pyparsing','python-dateutil','packaging']}
    (HERE/'plotting-environment.json').write_text(json.dumps(dict(python=platform.python_version(),backend=matplotlib.get_backend(),versions=versions),indent=2)+'\n')
    data=json.loads((HERE/'data/unprofiled-baseline.json').read_text())
    groups=[[r for r in data['scenarios'] if r['group']=='structural'],[r for r in data['scenarios'] if r['group']=='city']]
    fig,axes=plt.subplots(1,2,figsize=(17,12),gridspec_kw={'wspace':.62})
    for ax,rows,title in zip(axes,groups,['Structural and small physical scenarios','Cities: 25 / 64 / 256 buildings']):
        for i,r in enumerate(rows):
            for arm,offset,color in [('A0',-.13,'#2166ac'),('A1',.13,'#c45a17')]:
                d=r[arm];ax.plot([d['mean_ms'],d['max_ms']],[i+offset]*2,color=color,alpha=.4,lw=1)
                ax.plot(d['mean_ms'],i+offset,'o',color=color,ms=4,label=arm+' mean' if i==0 else None)
                ax.plot(d['max_ms'],i+offset,'x',color=color,ms=4,label=arm+' observed max' if i==0 else None)
        ax.axvline(1000/60,color='#a51930',ls='--',label='60 Hz: 16.667 ms')
        ax.set_yticks(range(len(rows)),[r['scenario'] for r in rows]);ax.invert_yaxis();ax.set_xscale('log');ax.grid(axis='x',alpha=.2)
        ax.set_xlabel('Complete step, ms (log scale)');ax.set_title(title);ax.legend(fontsize=8,loc='lower right')
    fig.suptitle('Selected control: all 52 scenarios, 20 A0 + 20 A1 restored ticks each\nRestore excluded; first-use samples retained. Markers are means and observed maxima.',fontsize=14)
    save(fig,'all-scenarios')
    rows=list(csv.DictReader((HERE/'data/continuous-control-frames.csv').open()))
    fig,axes=plt.subplots(2,1,figsize=(13,8),sharex=True)
    for ax,prefix,title in zip(axes,['idle','impacts'],['Intact idle: continuous simulation','Bombardment: continuous simulation']):
        runs=sorted({r['run'] for r in rows if r['run'].startswith(prefix)})
        for run in runs:
            selected=[r for r in rows if r['run']==run];ax.plot([int(r['step']) for r in selected],[float(r['complete_step_ms']) for r in selected],lw=.8,alpha=.8,label=run.replace(prefix+'-256-',''))
        ax.axhline(1000/60,color='#a51930',ls='--',label='60 Hz');ax.set_ylabel('Complete step, ms');ax.set_title(title);ax.grid(alpha=.2);ax.legend(ncol=5,fontsize=8)
    axes[-1].set_xlabel('Tick (1/60 s simulation time)');fig.suptitle('Selected control: four 600-tick runs per workload; unprofiled',fontsize=14);fig.tight_layout();save(fig,'continuous-controls')
    path=HERE/'data/continuous200-frames.csv'
    if path.exists():
        fresh=list(csv.DictReader(path.open()))
        names=list(dict.fromkeys(r['scenario'] for r in fresh))
        fig,axes=plt.subplots(len(names),1,figsize=(13,2.5*len(names)),sharex=True)
        for ax,name in zip(axes,names):
            for mode,color in [('plain1','#2166ac'),('plain2','#c45a17'),('plain3','#25866a')]:
                selected=[r for r in fresh if r['scenario']==name and r['mode']==mode]
                ax.plot([int(r['step']) for r in selected],[float(r['complete_step_ms']) for r in selected],lw=.8,alpha=.8,color=color,label=mode)
            ax.axhline(1000/60,color='#a51930',ls='--',label='60 Hz');ax.set_ylabel('Full tick, ms');ax.set_title(name);ax.grid(alpha=.2);ax.legend(ncol=4,fontsize=8)
        axes[-1].set_xlabel('Tick (1/60 second per tick)');fig.suptitle('Seven continuous scenarios: three unprofiled 200-tick processes each\nFirst-use ticks retained; setup separate; no snapshots/restores',fontsize=14);fig.tight_layout(rect=[0,0,1,.97]);save(fig,'continuous200-timings')
        names=['impacts-16','impacts-256','wall-1','localized-256']
        fig,axes=plt.subplots(len(names),3,figsize=(16,11),sharex=True)
        for i,name in enumerate(names):
            selected=[r for r in fresh if r['scenario']==name and r['mode']=='plain1'];ticks=[int(r['step']) for r in selected]
            for j,(field,label) in enumerate([('contacts_frame','Reported contacts'),('bonds_broken','New broken bonds'),('stress_iterations','Maximum stress iterations')]):
                ax=axes[i,j];ax.plot(ticks,[int(r[field]) for r in selected],color='#2166ac',lw=1)
                for r in selected:
                    if int(r['resim_passes']):ax.axvline(int(r['step']),color='#c45a17',alpha=.07,lw=1)
                ax.set_title(name+' — '+label,fontsize=10);ax.grid(alpha=.2)
        for ax in axes[-1]:ax.set_xlabel('Tick')
        fig.suptitle('Continuous physical work: first unprofiled process per scenario\nOrange stripes indicate one correction; iteration count is a maximum, not total solver work',fontsize=14);fig.tight_layout(rect=[0,0,1,.95]);save(fig,'continuous200-work')
    ledger=HERE/'data/attribution-ledger.json'
    if ledger.exists():
        data=json.loads(ledger.read_text());wanted=['dense12-cold','tower64-cold','city25-initial-impact','city256-intact-idle','city256-initial-impact','city256-late-debris']
        rows=[r for r in data['scenarios'] if r['scenario'] in wanted and 'cpu_profile' in r]
        fig,ax=plt.subplots(figsize=(13,5));left=[0.]*len(rows)
        for key,label,color in [('gpu_and_scheduled_cpu_ms','GPU + scheduled CPU','#1b9e77'),('gpu_without_scheduled_cpu_ms','GPU, no scheduled CPU','#66c2a5'),('scheduled_cpu_without_gpu_ms','Scheduled CPU, no GPU activity','#7570b3'),('neither_traced_gpu_nor_scheduled_cpu_ms','Neither observed','#bbb')]:
            values=[r['cpu_profile']['disjoint_wall'][key] for r in rows];ax.barh(range(len(rows)),values,left=left,color=color,label=label);left=[a+b for a,b in zip(left,values)]
        ax.set_yticks(range(len(rows)),[r['scenario'] for r in rows]);ax.invert_yaxis();ax.set_xlabel('Instrumented complete tick, ms — not production latency');ax.legend(fontsize=8);ax.set_title('Mutually exclusive wall-time partition in fresh Systems traces\nScheduled CPU includes collector/driver work; these times are not removable-work estimates.');save(fig,'profile-wall-partition')
    links='\n## Exported baseline figures\n\n[All 52 unprofiled scenarios](figures/all-scenarios.svg), [continuous idle/heavy controls](figures/continuous-controls.svg), and [fresh instrumented wall partitions](figures/profile-wall-partition.svg). Each has a PNG companion; source measurements remain in data/. [Data-flow diagram source](figures/data-flow.mmd).\n'
    p=HERE/'README.md';text=p.read_text().replace('**Capture campaign in progress; this is not a completed baseline report.**','**Capture data collected; final analytical review pending. No optimization gain is claimed.**')
    if '## Exported baseline figures' not in text:text+=links
    if path.exists() and '[Seven continuous 200-tick scenarios]' not in text:
        text+='\n[Seven continuous 200-tick scenarios](continuous200.md), [all repeated full-step traces](figures/continuous200-timings.svg), and [contact/fracture/convergence histories](figures/continuous200-work.svg).\n'
    p.write_text(text)


if __name__=='__main__':main()
