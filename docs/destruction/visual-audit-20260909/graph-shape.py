#!/usr/bin/env python3
"""Offline authored graph census. Reads assets; never runs or changes physics."""
from collections import Counter, deque
from pathlib import Path
import hashlib, json, math, subprocess, sys
sys.dont_write_bytecode = True
from figures import Figure, COLORS
HERE = Path(__file__).resolve().parent
ROOT = HERE.parents[2]
SOURCES = {
 'frame': ROOT/'blast/blast-stress-solver/assets/reference/reference-building.json',
 'downtown': ROOT/'tests/destruction/game-reference/destruction/assets/scenes/fractured-downtown.json',
 'game_demo': ROOT.parent/'vibe-land-2/destruction/assets/scenes/embedded-penetration.json',
 'game_tile': ROOT.parent/'vibe-land-2/destruction/assets/scenes/embedded-four-buildings.json',
 'native_generator': ROOT/'demos/blast-stress-demo/native_destruction_main.cpp',
}
def grid(height):
    ids, nodes, bonds = {}, [], []
    for y in range(height):
        for z in range(8):
            for x in range(8):
                if x not in (0,7) and z not in (0,7) and y % 4: continue
                i = len(nodes); ids[x,y,z] = i
                nodes.append({'centroid':dict(x=x,y=y,z=z), 'mass':int(y != 0)})
                for dx,dy,dz in ((-1,0,0),(0,-1,0),(0,0,-1)):
                    other = ids.get((x+dx,y+dy,z+dz))
                    if other is not None: bonds.append({'node0':other,'node1':i})
    return {'nodes':nodes,'bonds':bonds}, ids

def histogram(values): return dict(sorted(Counter(values).items()))
def distribution(values):
    values=sorted(values)
    return {'min':values[0], 'mean':sum(values)/len(values), 'p50':values[math.ceil(.5*len(values))-1],
            'p95':values[math.ceil(.95*len(values))-1], 'max':values[-1], 'histogram':histogram(values)} if values else None

def census(scene):
    nodes, bonds = scene['nodes'], scene['bonds']; n=len(nodes)
    adj=[[] for _ in nodes]; pairs=set()
    for b in bonds:
        a,z=b['node0'],b['node1']; assert 0<=a<n and 0<=z<n and a!=z
        pair=tuple(sorted((a,z))); assert pair not in pairs, 'Parallel bonds need separate degree/neighbor reporting'
        pairs.add(pair); adj[a].append(z);adj[z].append(a)
    for row in adj: row.sort()
    support={i for i,v in enumerate(nodes) if v['mass']==0}; dynamic=set(range(n))-support
    distances=[None]*n; q=deque(sorted(support))
    for i in support: distances[i]=0
    while q:
        i=q.popleft()
        for j in adj[i]:
            if distances[j] is None: distances[j]=distances[i]+1; q.append(j)
    def components(allowed):
        visited=set(); out=[]
        for i in sorted(allowed):
            if i in visited:continue
            visited.add(i); todo=[i]; group=[]
            while todo:
                v=todo.pop();group.append(v)
                for j in adj[v]:
                    if j in allowed and j not in visited:visited.add(j);todo.append(j)
            out.append(sorted(group))
        return sorted(out,key=lambda a:(-len(a),a[0]))
    full=components(set(range(n))); dyn=components(dynamic)
    boundary=sum((b['node0'] in support)!=(b['node1'] in support) for b in bonds)
    static=sum(b['node0'] in support and b['node1'] in support for b in bonds)
    dd=len(bonds)-boundary-static
    assert sum(map(len,adj))==2*len(bonds)
    assert sum(len(adj[i]) for i in dynamic)==2*dd+boundary
    for i in dynamic:
        if distances[i] is not None:assert any(distances[j]==distances[i]-1 for j in adj[i])
    result={'chunks':n,'bonds':len(bonds),'supports':len(support),'dynamic_nodes':len(dynamic),
        'components':len(full),'dynamic_components':len(dyn),'full_component_sizes':histogram(map(len,full)),
        'dynamic_component_sizes':histogram(map(len,dyn)), 'degree_all':distribution(map(len,adj)),
        'degree_dynamic':distribution(len(adj[i]) for i in dynamic),
        'support_hops_dynamic':distribution(distances[i] for i in dynamic if distances[i] is not None),
        'unreachable_dynamic':sum(distances[i] is None for i in dynamic),
        'support_support_bonds':static,'boundary_bonds':boundary,'dynamic_dynamic_bonds':dd,
        'dynamic_adjacency_entries':2*dd+boundary, 'independent_cycles_full':len(bonds)-n+len(full),
        'independent_cycles_dynamic':dd-len(dynamic)+len(dyn),
        'block_components':sum(len(c)<=1024 for c in dyn),'cooperative_components':sum(len(c)>1024 for c in dyn),
        'component_details':[]}
    for c in full:
        dc=[i for i in c if i in dynamic]
        result['component_details'].append({'root':c[0],'chunks':len(c),'dynamic_nodes':len(dc),
          'bonds':sum(len(adj[i]) for i in c)//2,'supports':len(c)-len(dc),
          'y_min':min(nodes[i]['centroid']['y'] for i in c),'y_max':max(nodes[i]['centroid']['y'] for i in c),
          'degree':distribution(len(adj[i]) for i in c),
          'support_hops_dynamic':distribution(distances[i] for i in dc if distances[i] is not None)})
    if 'nodeTypes' in scene:
        result['degree_by_role']={t:dict(count=scene['nodeTypes'].count(t),**distribution(len(adj[i]) for i,q in enumerate(scene['nodeTypes']) if q==t)) for t in sorted(set(scene['nodeTypes']))}
    return result, adj, distances

scenes={k:json.loads(SOURCES[k].read_text())['scenario'] for k in ('frame','downtown','game_demo','game_tile')}
scenes['native'],ids=grid(12)
scenes['height8'],_=grid(8);scenes['height40'],_=grid(40)
# Match actual playable geometry topology, not just matching chunk/bond counts.
assert scenes['native']['bonds']==[{k:b[k] for k in ('node0','node1')} for b in scenes['game_demo']['bonds']]
assert len(scenes['game_demo']['nodes'])==444
for a,b in zip(scenes['native']['nodes'],scenes['game_demo']['nodes']):
    assert (a['mass']==0)==(b['mass']==0)
    assert all(abs(a['centroid'][k]+offset-b['centroid'][k])<1e-7 for k,offset in [('x',-3.5),('y',.5),('z',-3.5)])
results={}; details={}
for k,scene in scenes.items():results[k],adj,dist=census(scene);details[k]=(adj,dist)
assert (results['native']['chunks'],results['native']['bonds'])==(444,896)
assert results['game_tile']['dynamic_component_sizes']=={380:4}
# Pure graph illustration: pinch off a four-chunk wall square, never a fracture verdict.
patch={ids[0,y,z] for y in (5,6) for z in (2,3)}
boundary=[i for i,b in enumerate(scenes['native']['bonds']) if (b['node0'] in patch)!=(b['node1'] in patch)]
for name,removed in [('almost_split',set(boundary[1:])),('split',set(boundary))]:
    scene={'nodes':scenes['native']['nodes'],'bonds':[b for i,b in enumerate(scenes['native']['bonds']) if i not in removed]}
    results[name],_,_=census(scene);results[name]['removed_bonds']=len(removed)
assert results['almost_split']['components']==1 and results['split']['full_component_sizes']=={4:1,440:1}
assert results['split']['unreachable_dynamic']==4
payload={'source_revision':subprocess.check_output(['git','-C',str(ROOT),'rev-parse','HEAD'],text=True).strip(),
 'method':'Undirected unweighted authored graph; supports are mass==0; multi-source BFS; nearest-rank percentiles over reachable dynamic chunks; no simulation.',
 'sources':{k:{'path':str(p),'sha256':hashlib.sha256(p.read_bytes()).hexdigest()} for k,p in SOURCES.items()},'graphs':results}
(HERE/'graph-shape-data.json').write_text(json.dumps(payload,indent=2)+'\n')
# Actual geometry projection + two distributions.
f=Figure('10. The actual 444-chunk building graph','444 chunks / 896 bonds. Green: 64 fixed supports. Amber: one shortest 11-bond route to a support.',925)
adj,dist=details['native'];positions={i:tuple(v['centroid'][k] for k in ('x','y','z')) for i,v in enumerate(scenes['native']['nodes'])}
def project(i):
    x,y,z=positions[i];return (282+(x-z)*30,748-y*40+(x+z-7)*9)
for b in scenes['native']['bonds']:f.line([project(b['node0']),project(b['node1'])],'#C9D2DE',1)
for i in positions:
    x,y=project(i);f.rect(x-2,y-2,4,4,COLORS['keep'] if positions[i][1]==0 else COLORS['gpu'])
i=ids[3,8,3];route=[i]
while dist[i]:i=next(j for j in adj[i] if dist[j]==dist[i]-1);route.append(i)
for a,b in zip(route,route[1:]):f.line([project(a),project(b)],COLORS['opt'],4)
x,y=project(route[0]);f.rect(x-5,y-5,10,10,COLORS['opt'])
f.text(45,125,'Loop-filled walls + three slab layers',21,bold=True)
f.text(45,169,'No interior columns in this generated example.',17)
f.text(45,199,'A floor-center chunk can travel sideways first.',17)
f.text(45,817,'380 dynamic stress nodes; one shared rigid motion.',19,bold=True)
f.text(45,852,'This is 12 chunk rows, not 12 architectural stories.',17)
f.text(650,125,'Bonds per chunk (all chunks)',21,bold=True)
for j,(degree,count) in enumerate(results['native']['degree_all']['histogram'].items()):
    y=170+j*53;f.text(650,y,f'{degree} bonds',18);f.rect(765,y, count/364*430,27,COLORS['gpu']);f.text(1215,y,f'{count} ({count/444:.1%})',17)
f.text(650,350,'Shortest support path (dynamic chunks)',21,bold=True)
for j,(hops,count) in enumerate(results['native']['support_hops_dynamic']['histogram'].items()):
    y=394+j*35;f.text(650,y,f'{hops:2} bonds',16);f.rect(765,y,count/48*430,23,COLORS['opt']);f.text(1215,y,str(count),16)
f.text(650,812,'Mean 6.29 hops; maximum 11. All are supported.',18,bold=True)
f.text(650,852,'Path length is not the numerical iteration count.',18)
f.save(HERE/'figures','10-graph-shape')
# Downtown per-component shape, with actual hop maxima (one bar per component).
f=Figure('11. Downtown: 27 independent graphs, different solve sizes','24,105 chunks / 74,543 bonds / 445 fixed supports. Each row is one authored connected structure.',1160)
f.text(45,112,'Chunks / dynamic nodes',18,bold=True);f.text(395,112,'Dynamic component size',18,bold=True);f.text(990,112,'Longest support path',18,bold=True)
for j,c in enumerate(results['downtown']['component_details']):
    y=152+j*32;large=c['dynamic_nodes']>1024
    f.text(45,y,f'{j+1:2}. {c["chunks"]:,} / {c["dynamic_nodes"]:,}',17)
    f.rect(395,y,max(2,c['dynamic_nodes']/5936*510),23,COLORS['opt'] if large else COLORS['gpu'])
    hops=c['support_hops_dynamic']['max'];f.rect(990,y,hops/60*270,23,COLORS['keep']);f.text(1280,y,str(hops),17)
x=395+1024/5936*510;f.line([(x,145),(x,1015)],COLORS['replace'],2)
f.text(395,1033,'Red line: 1,024 dynamic nodes',17,color=COLORS['replace'])
f.text(45,1080,'18 block-local components (blue) | 9 cooperative components (amber) | support hops (green)',20,bold=True)
f.text(45,1119,'GPU route inferred from current size threshold. These are offline graph counts, not a new timed simulation.',17)
f.save(HERE/'figures','11-graph-components')
# Generated tables are appended to the conceptual note.
lines=['## Exact graph census','', 'All degree counts include fixed chunks. Support-hop statistics exclude them. Paths are unweighted: one bond = one hop.','',
 '| Asset / generated variant | Chunks | Bonds | Supports | Stress components | Degree min / mean / max | Support hops mean / p95 / max |', '|---|---:|---:|---:|---:|---|---|']
for key,label in [('frame','Authored 3-floor frame'),('native','Native penetration building'),('downtown','Authored downtown'),('height8','Synthetic height: 8 chunk rows'),('height40','Synthetic height: 40 chunk rows')]:
    r=results[key];d=r['degree_all'];h=r['support_hops_dynamic']
    lines.append(f'| {label} | {r["chunks"]:,} | {r["bonds"]:,} | {r["supports"]:,} | {r["dynamic_components"]} | {d["min"]} / {d["mean"]:.3f} / {d["max"]} | {h["mean"]:.3f} / {h["p95"]} / {h["max"]} |')
lines+=['','Every intact asset above has a support path for every dynamic chunk. None has self-bonds or duplicate endpoint pairs. Synthetic height variants change only graph generation; no physics quality or timing is asserted.','', '### Complete degree histograms','', '| Bonds per chunk | Native 444-chunk building | Authored 64-chunk frame | Downtown 24,105 chunks |','|---:|---:|---:|---:|']
for d in sorted(set().union(*(results[k]['degree_all']['histogram'] for k in ('native','frame','downtown')))):
    lines.append('| '+str(d)+' | '+' | '.join(str(results[k]['degree_all']['histogram'].get(d,0)) for k in ('native','frame','downtown'))+' |')
lines+=['','### Downtown degree by authored role','','| Chunk role | Count | Degree min | Mean | Max |','|---|---:|---:|---:|---:|']
for role,d in results['downtown']['degree_by_role'].items():lines.append(f'| {role} | {d["count"]:,} | {d["min"]} | {d["mean"]:.3f} | {d["max"]} |')
lines+=['','### Intact dynamic-component sizes','','| Dynamic nodes per component | Downtown component count | Current CUDA route |','|---:|---:|---|']
for n,count in results['downtown']['dynamic_component_sizes'].items():lines.append(f'| {n:,} | {count} | {"Block-local" if n<=1024 else "Cooperative large-component"} |')
lines+=['','### Controlled graph cuts: not a simulated fracture verdict','','A 2×2 square of four wall chunks at x=0, y=5–6, z=2–3 has eight bonds to the rest of the building. Its four internal bonds form a loop.','', '| Illustrative state | Removed bonds | Remaining bonds | Connected component sizes | Unsupported dynamic chunks |','|---|---:|---:|---|---:|']
for key,label in [('native','Intact'),('almost_split','Only one external bond left'),('split','Last external bond removed')]:
    r=results[key];lines.append(f'| {label} | {r.get("removed_bonds",0)} | {r["bonds"]} | '+', '.join(f'{n} × {count}' for n,count in r['full_component_sizes'].items())+f' | {r["unreachable_dynamic"]} |')
lines+=['','### Reproduction and provenance','','Run `python3 graph-shape.py` from this directory. It reads authored assets, validates graph identities and produces this census and two figures. No physics or GPU benchmark runs. The 444-chunk graph is checked against the actual playable asset: endpoint pairs, node order, fixed-support flags and positions up to their documented translation. The four-building tile is checked to have four 380-node dynamic components.','', 'Nearest-rank percentiles; BFS starts from all fixed chunks at distance zero. Component discovery excludes fixed chunks for stress partitioning. Graph degree, component and path identities are checked internally. [Machine-readable counts and input SHA-256 hashes](graph-shape-data.json).','']
(HERE/'graph-shape-census.md').write_text('\n'.join(lines))
(HERE/'graph-shape.md').write_text((HERE/'graph-shape-narrative.md').read_text()+'\n'+(HERE/'graph-shape-census.md').read_text())
print(json.dumps({k:{n:r[n] for n in ('chunks','bonds','supports','dynamic_components','dynamic_adjacency_entries','independent_cycles_full','independent_cycles_dynamic')} for k,r in results.items()},indent=2))
