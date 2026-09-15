"""Map diagnostic solve work to complete ticks, retaining both correction passes."""
import collections
import csv
import json
from pathlib import Path
import sys

raw, frames_path, output = map(Path, sys.argv[1:])
frames = list(csv.DictReader(frames_path.open()))
mapping = []
for frame in frames:
    for p in range(int(frame['stress_passes'])):
        mapping.append((int(frame['step']),p))
solves = []
components = []
with raw.open() as stream:
    for line in stream:
        r = json.loads(line)
        assert r['solve'] == len(solves)
        if r['record'] == 'component':
            components.append(r)
            continue
        assert r['record'] == 'total'
        assert r['solve'] < len(mapping), 'Unmapped solve outside tick accounting'
        measured = [c for c in components if c['path']==1]
        unmeasured = [c for c in components if c['path']==2]
        assert len(measured)==r['components'] and len(unmeasured)==r['unmeasured_components']
        assert all(c['converged']==1 for c in measured)
        assert all(c['direction_sweeps']==0 and c['residual_sweeps']==0 and c['verification_sweeps']==0
                   for c in measured if c['settled_skipped'])
        assert sum(c['direction_sweeps'] for c in measured)==r['component_updates']
        assert sum(c['dynamic_nodes']*(c['residual_sweeps']+c['verification_sweeps']+c['direction_sweeps']) for c in measured)==r['operator_node_visits']
        assert sum(c['csr_refs_per_sweep']*(c['residual_sweeps']+c['verification_sweeps']+c['direction_sweeps']) for c in measured)==r['operator_csr_visits']
        assert sum(r['phase_cycles'][:8])==r['phase_cycles'][8]
        groups = collections.defaultdict(lambda: collections.Counter())
        for c in components:
            size = '1-32' if c['nodes']<=32 else '33-128' if c['nodes']<=128 else '129-512' if c['nodes']<=512 else '513-1024' if c['nodes']<=1024 else 'large-unmeasured'
            group = groups[('anchored' if c['anchored'] else 'free')+'/'+size]
            group.update(components=1,nodes=c['nodes'],settled_components=c['settled_skipped'],
                         settled_nodes=c['nodes']*c['settled_skipped'])
            if c['path']==1:
                group.update(updates=c['direction_sweeps'],node_updates=c['dynamic_nodes']*c['direction_sweeps'],
                             csr_visits=c['csr_refs_per_sweep']*(c['residual_sweeps']+c['verification_sweeps']+c['direction_sweeps']),
                             diagnostic_cta_cycles=c['cta_cycles'])
                tree = not c['anchored'] and c['dynamic_nodes']==c['nodes'] and c['live_refs_per_sweep']==2*(c['nodes']-1)
                if tree:
                    group.update(tree_components=1,tree_node_updates=c['dynamic_nodes']*c['direction_sweeps'])
        step,p = mapping[r['solve']]
        solves.append(dict(step=step, stress_pass=p, totals=r, groups=dict(groups),
                           measured_components=len(measured),unmeasured_components=len(unmeasured),
                           settled_components=sum(c['settled_skipped'] for c in components),
                           top_node_update_components=sorted(measured,key=lambda c:c['dynamic_nodes']*c['direction_sweeps'],reverse=True)[:10]))
        components=[]
assert not components and len(solves)==len(mapping), 'Missing solve/component records'
output.write_text(json.dumps(dict(scope='Work counts only; intrusive CTA cycles include diagnostics and cannot be summed into GPU milliseconds. '
                                     'Large cooperative components are explicitly unmeasured. Tree classification uses connected component/reference counts, '
                                     'not an independent geometry/material direct-solve certificate.',source=str(raw),frames=str(frames_path),solves=solves),indent=2)+'\n')
print(len(solves),'mapped first/correction solves; all measured work totals close')
