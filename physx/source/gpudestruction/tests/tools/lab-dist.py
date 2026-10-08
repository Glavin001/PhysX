#!/usr/bin/env python3
"""lab-dist.py parse NAME < replay log  -> one JSON line;  lab-dist.py summary A.jsonl [B.jsonl]: the distribution."""
import json, re, statistics as st, sys

def parse(name):
    # Every run's times; the first run (pipeline build) is dropped where there are more, and the
    # fastest of the rest kept (min: what the step costs once its pipelines exist).
    r = dict(name=name, patches=[], ms=None, window=None, build=None, launches=None, longest=None, hash=None)
    runs, evals, seen = [], [], 0
    for l in sys.stdin:
        m = re.search(r'explicit: \d+ patches; build ([\d.]+) ms, window ([\d.]+) ms in (\d+) launches', l)
        if m: runs.append((float(m[2]), float(m[1]), int(m[3]))); seen += 1
        m = None if seen > 1 else re.search(r'explicit patch (\d+): island \d+, (\d+) nodes .*?, (\d+) joints, (\d+) contact rows, (\d+) impactors; (\d+) substeps of ([\d.]+) us.*?broke (\d+), yielded (\d+)', l)
        if m: r['patches'].append(dict(nodes=int(m[2]), joints=int(m[3]), rows=int(m[4]), impactors=int(m[5]), substeps=int(m[6]), h_us=float(m[7]), broke=int(m[8]), yielded=int(m[9])))
        m = re.search(r'explicit patch (\d+): (\d+) breaks; by(.*)', l)
        if m:
            p = int(m[1]); by = [(float(a), int(b)) for a, b in re.findall(r'([\d.]+) ms (\d+)', m[3])]
            if p < len(r['patches']): r['patches'][p]['by'] = by
        m = re.search(r'error \d+; ([\d.]+) ms in \d+ dispatches \(longest ([\d.]+) ms\)', l)
        if m: evals.append((float(m[1]), float(m[2])))
        m = re.search(r'run 0 hash (\w+)', l)
        if m: r['hash'] = m[1]
    if runs:
        w = min(runs[1:] or runs); r.update(window=w[0], build=w[1], launches=w[2], runs=len(runs))
    if evals:
        e = min(evals[1:] or evals); r.update(ms=e[0], longest=e[1])
    print(json.dumps(r))

def q(x, p): x = sorted(x); return x[min(len(x) - 1, int(p * len(x)))]

def summary(paths):
    for path in paths:
        R = [json.loads(l) for l in open(path) if l.strip()]
        E = [r for r in R if r['window'] is not None]
        ms = [r['ms'] for r in E if r['ms'] is not None]; win = [r['window'] for r in E]
        sub = [max(p['substeps'] for p in r['patches']) for r in E if r['patches']]
        last = []
        for r in E:
            t = 0.0
            for p in r['patches']:
                by = p.get('by', []); n = by[-1][1] if by else 0
                for a, b in by:
                    if b == n and n: t = max(t, a); break
            last.append(t)
        f = lambda x: 'min %.2f med %.2f mean %.2f p90 %.2f p95 %.2f max %.2f' % (min(x), st.median(x), st.mean(x), q(x, 0.9), q(x, 0.95), max(x)) if x else '-'
        print(f'{path}: {len(R)} captures, {len(E)} explicit evaluations')
        print('  evaluation ms', f(ms)); print('  window ms    ', f(win)); print('  longest dispatch ms', f([r['longest'] for r in E if r['longest']]))
        print('  substeps (largest patch)', f(sub))
        print('  breaks: evaluations with any %d; last break by (ms bucket): %s' % (sum(1 for t in last if t > 0),
              ', '.join('%g: %d' % (b, sum(1 for t in last if 0 < t <= b)) for b in (0.1, 0.25, 0.5, 1, 2, 4, 8, 17))))

if __name__ == '__main__':
    parse(sys.argv[2]) if sys.argv[1] == 'parse' else summary(sys.argv[2:])
