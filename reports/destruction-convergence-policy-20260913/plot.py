#!/usr/bin/env python3
"""Offline figures from the policy diagnostic's saved results."""
import json
from pathlib import Path
import numpy as np
import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
from matplotlib.patches import Patch
HERE=Path(__file__).resolve().parent
j=json.loads((HERE/'results.json').read_text())
colors=['#45637f','#008878','#da9531','#bb4561'];arms=['strict','tolerance','cap32','vibe32'];labels=['Strict control','Looser tolerance','32 cap only','Loose + 32 cap']
plt.rcParams.update({'font.family':'DejaVu Sans','font.size':11,'axes.spines.top':False,'axes.spines.right':False})
fig,ax=plt.subplots(1,2,figsize=(14,5.7),gridspec_kw={'width_ratios':[1.35,1]})
for a,mode in zip(ax,['restored','continuous']):
 rows=[r for r in j['scenarios'] if r['mode']==mode];x=np.arange(len(rows));w=.19
 for i,(arm,color,label) in enumerate(zip(arms,colors,labels)):
  values=[r['runs'][arm]['mean_ms'] if mode=='restored' else r['arms'][arm]['mean_ms'] for r in rows]
  bars=a.bar(x+(i-1.5)*w,values,w,color=color,label=label)
  a.bar_label(bars,labels=[f'{v:.1f}' for v in values],padding=3,fontsize=8)
 a.axhline(1000/60,color='#808080',linestyle=':',linewidth=1)
 a.set_xticks(x,['Tower','Initial impact\n25 buildings','Late debris\n256 buildings'] if mode=='restored' else ['Idle\n256 buildings','Heavy impact\n256 buildings'])
 a.set_ylabel('Complete tick, milliseconds • lower is faster');a.set_ylim(bottom=0);a.grid(axis='y',alpha=.14);a.set_axisbelow(True)
 a.set_title('Identical saved starting states' if mode=='restored' else 'Continuous simulation',loc='left',weight='bold')
fig.suptitle('How much does native convergence policy cost?',x=.055,ha='left',weight='bold',fontsize=19)
fig.legend(handles=[Patch(facecolor=c,label=l) for c,l in zip(colors,labels)],loc='upper center',bbox_to_anchor=(.52,.94),ncol=4,frameon=False)
fig.text(.055,.015,'Snapshot bars: 3 independently restored ticks each. Continuous bars: 2 × 180 ticks. First-use spikes included. Dotted line: 60 Hz budget.\nChanged stopping policies can change fracture and future workload; these are diagnostic timings, not equal-quality speedups.',fontsize=10,color='#485562')
fig.tight_layout(rect=(0,.09,1,.85))
for ext in ['png','svg']:fig.savefig(HERE/('comparison.'+ext),dpi=180)
