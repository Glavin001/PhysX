#!/usr/bin/env python3
"""Separate partitions of selected profiled scopes, not production budgets."""
import json
from pathlib import Path
import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt

HERE = Path(__file__).resolve().parent
rows = {r['scenario']: r for r in json.loads((HERE/'data/audit.json').read_text())['rows']}
names = ['city25-initial-impact', 'city64-initial-impact', 'city256-initial-impact',
         'city256-cascading-fracture', 'city256-late-debris', 'city256-ten-second-debris']
plt.rcParams.update({'font.family':'DejaVu Sans','font.size':10,'svg.fonttype':'none'})
fig, axes = plt.subplots(1, 2, figsize=(14, 5.6))
for y,n in enumerate(names):
    r=rows[n]; a,m=r['ownership_scopes']; launches=r['topology_launches']
    axes[0].barh(y,a['no_recorded_gpu_ms'],color='#507f99',label='Body allocation' if y==0 else None)
    axes[0].barh(y,m['no_recorded_gpu_ms'],left=a['no_recorded_gpu_ms'],color='#bf6155',label='Shape migration' if y==0 else None)
    total=a['no_recorded_gpu_ms']+m['no_recorded_gpu_ms']
    axes[0].text(total+.7,y,f'{total:.2f}',va='center')
    wall=sum(x['api_ms'] for x in launches); idle=sum(x['no_recorded_gpu_ms'] for x in launches)
    axes[1].barh(y,wall-idle,color='#238b79',label='Recorded GPU activity' if y==0 else None)
    axes[1].barh(y,idle,left=wall-idle,color='#bd643b',label='No recorded GPU activity' if y==0 else None)
    axes[1].text(wall+.7,y,f'{wall:.2f} / {idle:.2f}',va='center')
axes[0].set_yticks(range(len(names)),[n.replace('city','City').replace('-',' ') for n in names])
axes[1].set_yticks(range(len(names)),[])
for ax in axes:
    ax.invert_yaxis();ax.grid(axis='x',alpha=.15);ax.set_xlim(0,86)
    ax.spines[['top','right']].set_visible(False);ax.legend(loc='lower right',fontsize=9)
    ax.set_xlabel('Instrumented milliseconds; distinct scopes in each panel')
axes[0].set_title('CPU ownership work gates GPU progress\nNo recorded GPU activity during these scopes',loc='left')
axes[1].set_title('Long topology launch calls overlap GPU work\nLabels: API duration / time without GPU activity',loc='left')
fig.suptitle('A long CPU call is not necessarily a GPU stall',x=.02,ha='left',fontsize=15)
fig.text(.02,.02,'Selected first measured ticks from fixed warm histories. These are profiler observations, not production savings.\nEach panel partitions its own intervals. Do not add the panels or subtract their durations from normal tick time. Boundary warnings remain.',fontsize=9)
fig.tight_layout(rect=(0,.09,1,.93))
for ext in ['png','svg']:fig.savefig(HERE/f'wait-vs-starvation.{ext}',dpi=160)
