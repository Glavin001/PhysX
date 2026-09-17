#!/usr/bin/env python3
"""Before/after and day-by-day plots of the destruction real-time work (plan of 2026-09-14).

Sources: qualification/baseline-rtx5060ti-20260910/stats.json (09-10 baseline, same continuous
cases), out/direct-continuous-ab-*/comparisons/A-before/*/comparison.json (fixed 09-15 baseline
arm vs each day's candidate), /tmp/warm-screens.json or the warm-screen result directories.
"""
import json,glob,os,sys,csv,statistics
import matplotlib; matplotlib.use('Agg')
import matplotlib.pyplot as plt
root=os.path.dirname(os.path.abspath(__file__))+'/../..'
out=os.path.join(root,'reports/destruction-realtime-ranking-20260915/plots'); os.makedirs(out,exist_ok=True)
# ---- continuous campaigns (600 ticks, city256) ----
camps=[('20260915','09-15 R1 direct factors'),('elastic-20260915','09-15 +elastic reuse'),('final-20260915','09-15 +island repair'),
       ('pool-20260915','09-15 +body pool'),('20260916b','09-16 +Woodbury, narrow levels'),('20260916c','09-16 +speculative topology'),
       ('20260917','09-17 +R2 slots, residency'),('20260917b','09-17 +yield-thread demo')]
rows=[]
def camp(name):
    d=os.path.join(root,'out','direct-continuous-ab-'+name)
    res={}
    for f in glob.glob(d+'/comparisons/A-before/*/comparison.json'):
        c=json.load(open(f)); case=f.split('/')[-2]
        for r in c['rows']:
            res.setdefault((case,r['arm']),[]).append((r['mean_ms'],r['peak_ms'],r['misses_60hz']))
    return res
q=json.load(open(os.path.join(root,'qualification/baseline-rtx5060ti-20260910/stats.json')))
q0={}
for r in q['records']: q0.setdefault(r['case'],[]).append((r['metrics']['mean'],r['metrics']['max'],r['misses_60hz']))
def agg(v): return (statistics.mean(x[0] for x in v),statistics.mean(x[1] for x in v),statistics.mean(x[2] for x in v))
series=[('09-10 baseline (rev 1155b7ff)',None,agg(q0['impacts-256']),agg(q0['idle-256']))]
for name,label in camps:
    r=camp(name)
    if ('impacts-256','candidate') not in r: continue
    series.append((label,agg(r[('impacts-256','baseline')]),agg(r[('impacts-256','candidate')]),agg(r[('idle-256','candidate')])))
with open(os.path.join(out,'continuous-progress.csv'),'w') as f:
    w=csv.writer(f); w.writerow(['stage','baseline_heavy_mean_ms','heavy_mean_ms','heavy_peak_ms','heavy_misses_60hz_of_600','idle_mean_ms'])
    for label,b,c,i in series: w.writerow([label,round(b[0],2) if b else '',round(c[0],2),round(c[1],1),round(c[2]),round(i[0],2)])
labels=[s[0] for s in series]; heavy=[s[2][0] for s in series]; peak=[s[2][1] for s in series]; miss=[s[2][2] for s in series]; idle=[s[3][0] for s in series]
base=[s[1][0] if s[1] else None for s in series]
fig,ax=plt.subplots(3,1,figsize=(11,11),sharex=True)
x=list(range(len(series)))
ax[0].plot(x,heavy,'o-',label='candidate of the day (shipped defaults)',color='C0')
bx=[i for i,b in enumerate(base) if b]; ax[0].plot(bx,[base[i] for i in bx],'s--',label='fixed 09-15 baseline arm, re-measured each day',color='C3')
ax[0].scatter([0],[heavy[0]],color='C3',marker='s',zorder=3)
ax[0].axhline(8,color='gray',ls=':',label='plan target 8 ms'); ax[0].axhline(16.67,color='gray',ls='-.',label='60 Hz budget')
ax[0].set_ylabel('city256 heavy mean tick (ms)'); ax[0].set_ylim(0,70); ax[0].legend(loc='lower left',fontsize=8); ax[0].grid(alpha=.3)
for i,v in enumerate(heavy): ax[0].annotate(f'{v:.1f}',(i,v),textcoords='offset points',xytext=(0,7),ha='center',fontsize=8)
ax[1].bar(x,miss,color='C1'); ax[1].set_ylabel('60 Hz misses of 600 ticks'); ax[1].set_ylim(0,600); ax[1].grid(alpha=.3,axis='y')
for i,v in enumerate(miss): ax[1].annotate(f'{v:.0f}',(i,v),textcoords='offset points',xytext=(0,3),ha='center',fontsize=8)
ax[2].plot(x,peak,'^-',color='C2',label='heavy peak tick (ms)'); ax[2].plot(x,[v*20 for v in idle],'v-',color='C4',label='idle mean tick (ms) x20')
ax[2].set_ylabel('ms'); ax[2].legend(); ax[2].grid(alpha=.3)
for i,v in enumerate(idle): ax[2].annotate(f'{v:.2f}',(i,v*20),textcoords='offset points',xytext=(0,-12),ha='center',fontsize=8,color='C4')
plt.xticks(x,labels,rotation=25,ha='right',fontsize=8)
fig.suptitle('City256 continuous 600-tick runs: 09-10 baseline -> 09-17 shipped defaults (identical physics counters on every A/B)')
fig.tight_layout(); fig.savefig(os.path.join(out,'continuous-progress.png'),dpi=130); plt.close(fig)
# ---- before/after bars ----
first=series[0]; last=series[-1]
metrics=[('heavy mean (ms)',first[2][0],last[2][0]),('heavy peak (ms)',first[2][1],last[2][1]),('60 Hz misses /600',first[2][2],last[2][2]),('idle mean (ms)',first[3][0],last[3][0])]
warm=json.load(open('/tmp/warm-screens.json'))
w_before=warm['results-v3']; w_after=warm['results-17d-v4']
for win,lab in [('city256-impact','warm impact window (ms)'),('city256-cascade','warm cascade window (ms)'),('city256-debris','warm debris window (ms)'),('city25-impact','warm city25 impact (ms)')]:
    metrics.append((lab,(w_before[win]['A0']+w_before[win]['A1'])/2,w_after[win]['B']))
fig,axs=plt.subplots(2,4,figsize=(14,7))
for a,(lab,b,c) in zip(axs.flat,metrics):
    bars=a.bar(['before','after'],[b,c],color=['C3','C0']); a.set_title(lab,fontsize=10)
    for bar,v in zip(bars,[b,c]): a.annotate(f'{v:.2f}' if v<10 else f'{v:.0f}',(bar.get_x()+bar.get_width()/2,v),textcoords='offset points',xytext=(0,3),ha='center',fontsize=9)
    a.set_ylim(0,max(b,c)*1.25); a.grid(alpha=.3,axis='y')
    if b>0: a.text(0.5,0.92,f'x{b/c:.2f}' if c>0 else '',transform=a.transAxes,ha='center',fontsize=11,color='C2')
fig.suptitle('Before (09-10 baseline / 09-14 warm controls) vs after (09-17 shipped defaults)'); fig.tight_layout(); fig.savefig(os.path.join(out,'before-after.png'),dpi=130); plt.close(fig)
# ---- warm screen progression ----
order=['results-v3','results-final','results-final-v4','results-16d-v4','results-r2s3-v4','results-solve2-v4','results-occ-v4','results-thr128-v4','results-17d-v4']
wl=['09-15 v3','09-15 final','09-16 final-v4','09-16d','09-16 R2 s1-3','09-16 solve','09-17 occupancy','09-17 128-thr','09-17d']
fig,ax=plt.subplots(figsize=(11,5.5))
for win,c in [('city256-debris','C0'),('city256-cascade','C1'),('city256-impact','C2'),('city25-impact','C4')]:
    ys=[warm[r][win]['B'] for r in order]; cs=[(warm[r][win]['A0']+warm[r][win]['A1'])/2 for r in order]
    ax.plot(range(len(order)),ys,'o-',color=c,label=win+' candidate'); ax.plot(range(len(order)),cs,'s:',color=c,alpha=.5,label=win+' paired controls (09-14 runtime)')
ax.set_ylabel('window mean tick (ms)'); ax.grid(alpha=.3); ax.legend(fontsize=7,ncol=2); plt.xticks(range(len(order)),wl,rotation=25,ha='right',fontsize=8)
ax.set_title('Warm nine-window screen: candidate vs paired controls per qualification run'); fig.tight_layout(); fig.savefig(os.path.join(out,'warm-screen-progress.png'),dpi=130); plt.close(fig)
for s in series: print(f"{s[0]:40s} baseline {s[1][0] if s[1] else float('nan'):6.2f} heavy {s[2][0]:6.2f} peak {s[2][1]:6.1f} misses {s[2][2]:5.0f} idle {s[3][0]:5.2f}")
print('wrote',os.listdir(out))
