#!/usr/bin/env python3
"""Render saved warm full-step measurements; no simulation or profiling."""
import json
from pathlib import Path
import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
import numpy as np

report = Path(__file__).resolve().parent
rows = json.loads((report / 'data/scenarios.json').read_text())
by_name = {r['scenario']: r for r in rows}
plt.rcParams.update({'font.size': 11, 'axes.spines.top': False,
                     'axes.spines.right': False, 'savefig.facecolor': 'white'})
phases = ['intact-idle', 'airborne', 'initial-impact', 'post-impact',
          'cascading-fracture', 'fragmented-loaded', 'late-debris', 'ten-second-debris']
fig, axes = plt.subplots(1, 3, figsize=(18, 6.8), sharey=True, layout='constrained')
for ax, scale, color in zip(axes, [25, 64, 256], ['#197e6a', '#2867a2', '#8060a3']):
    selected = [by_name[f'city{scale}-{phase}'] for phase in phases]
    y = np.arange(len(selected))
    means = np.array([r['mean_ms'] for r in selected])
    lows = np.array([r['mean_range_ms'][0] for r in selected])
    highs = np.array([r['mean_range_ms'][1] for r in selected])
    ax.barh(y, means, color=color, alpha=.85, height=.55, label='Mean full step')
    ax.errorbar(means, y, xerr=[means-lows, highs-means], fmt='none',
                ecolor='#172b3a', capsize=3, label='Range of two process means')
    peaks = [r['peak_ms'] for r in selected]
    ax.scatter(peaks, y, marker='D', color='#172b3a', s=22, label='Observed peak')
    for i, r in enumerate(selected):
        ax.text(r['peak_ms'] + 2.5, i, f"{r['mean_ms']:.1f} / {r['peak_ms']:.1f}",
                va='center', fontsize=9)
    ax.axvline(1000/60, color='#ce6516', linestyle='--', linewidth=1.5,
               label='60 Hz: 16.667 ms')
    ax.set_xlim(0, 227)
    ax.set_yticks(y, [p.replace('-', ' ') for p in phases])
    ax.set_title(f"City {scale}: {selected[0]['chunks']:,} chunks")
    ax.set_xlabel('Complete step, ms')
    ax.grid(axis='x', alpha=.15)
axes[0].invert_yaxis()
fig.suptitle('Warm city windows: destruction remains above the real-time budget', fontsize=18)
handles, labels = axes[0].get_legend_handles_labels()
fig.legend(handles, labels, loc='outside lower center', ncol=4, fontsize=10)
fig.savefig(report/'city-warm-timings.png', dpi=160)
fig.savefig(report/'city-warm-timings.svg')
plt.close(fig)

selected = [r for r in rows if not r['scenario'].startswith('city')]
fig, ax = plt.subplots(figsize=(11, 11), layout='constrained')
y = np.arange(len(selected))
ax.barh(y, [r['mean_ms'] for r in selected], color='#197e6a', height=.6,
        label='Mean full step')
ax.scatter([r['peak_ms'] for r in selected], y, marker='D', color='#172b3a',
           s=18, label='Observed peak')
for i,r in enumerate(selected):
    ax.text(r['peak_ms']+.05, i, f"{r['mean_ms']:.2f} / {r['peak_ms']:.2f}",
            va='center', fontsize=9)
ax.set_yticks(y, [r['scenario'] for r in selected]);ax.invert_yaxis()
ax.set_xlim(0, 6);ax.set_xlabel('Complete step, ms — mean / observed peak labels')
ax.set_title('All 28 structural and ordinary-body warm windows', fontsize=16)
ax.grid(axis='x', alpha=.15);ax.legend(loc='lower right')
fig.savefig(report/'structural-warm-timings.png', dpi=150)
fig.savefig(report/'structural-warm-timings.svg')
