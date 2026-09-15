#!/usr/bin/env python3
"""Census existing accepted-output observations without running another tick."""
import argparse,collections,hashlib,json,math,sys
from array import array
from pathlib import Path
p=argparse.ArgumentParser(description=__doc__);p.add_argument('observations',type=Path);p.add_argument('report',type=Path);p.add_argument('output',type=Path);a=p.parse_args()
assert sys.byteorder=='little' and array('I').itemsize==array('f').itemsize==4
rows=[]
for case in json.loads(a.report.read_text())['scenarios_data']:
    name=case['scenario'];prefix=a.observations/('complete-'+name)/'observation-0';meta=Path(str(prefix)+'.json');desc=json.loads(meta.read_text())
    result=dict(scenario=name,source=str(prefix),scope='Accepted output of the first recorded restored tick; not its input, a solver-work census, or an operator-equivalence certificate.',baseline=case['baseline'],arrays={},destructive=desc['destructive'])
    data={}
    for name2,kind in [('chunk-clusters','I'),('health','f'),('active-bonds','I')]:
        entry=next((x for x in desc['arrays'] if x['name']==name2),None)
        if entry is None:continue
        file=Path(str(prefix)+'-'+name2+'.bin');raw=file.read_bytes();assert len(raw)==entry['count']*entry['stride'] and entry['stride']==4
        values=array(kind);values.frombytes(raw);data[name2]=values
        result['arrays'][name2]=dict(path=str(file),sha256=hashlib.sha256(raw).hexdigest(),count=len(values))
    if 'chunk-clusters' in data:
        ids=data['chunk-clusters'];counts=collections.Counter(ids);invalid=counts.pop(0xffffffff,0)
        bins={}
        for lo,hi in [(1,1),(2,4),(5,16),(17,64),(65,256),(257,1024),(1025,2**32-1)]:
            selected=[v for v in counts.values() if lo<=v<=hi];bins[f'{lo}-{hi}']=dict(clusters=len(selected),chunks=sum(selected))
        result['clusters']=dict(count=len(counts),largest=max(counts.values(),default=0),unassigned_chunks=invalid,bins=bins)
        assert sum(b['chunks'] for b in bins.values())+invalid==len(ids)
    if 'health' in data:
        h=data['health'];assert all(math.isfinite(v) and 0<=v<=1 for v in h)
        active=data['active-bonds'];assert len(h)==len(active) and all(v in (0,1) for v in active)
        result['health']=dict(bonds=len(h),active=sum(active),zero=sum(v==0 for v in h),intact=sum(v==1 for v in h),partially_damaged=sum(0<v<1 for v in h),distinct_values=len(set(h)))
        if name.startswith('city'):
            buildings=int(name[4:name.index('-')]);assert len(h)==896*buildings and len(data['chunk-clusters'])==444*buildings
            raw=h.tobytes();patterns=collections.Counter(raw[i*896*4:(i+1)*896*4] for i in range(buildings))
            result['health']['authored_buildings']=buildings
            result['health']['distinct_building_health_patterns']=len(patterns)
            result['health']['largest_identical_health_group']=max(patterns.values())
            live=active.tobytes();live_patterns=collections.Counter(live[i*896*4:(i+1)*896*4] for i in range(buildings))
            result['health']['distinct_building_active_bond_patterns']=len(live_patterns)
            result['health']['largest_identical_active_bond_group']=max(live_patterns.values())
            result['health']['pattern_limit']='Only bond-health bytes are compared. Geometry, inertia, constraints, basis, topology and operator identity are not certified.'
    rows.append(result)
result=dict(scope='Post-tick physical traits from existing observations, with unchanged full-step baselines. Cluster populations are not weighted iteration work.',scenarios=rows)
(a.output/'physical-traits.json').write_text(json.dumps(result,indent=2)+'\n')
lines=['# Observed physical traits','','These are accepted **post-tick** outputs already recorded by the baseline. Cluster counts do not measure solver work. Identical bond-health arrays do not certify identical operators. All raw array hashes are preserved in the structured file.','','| Scenario | Full step mean / peak ms | Clusters / largest chunk count | Singleton / 2–16 / 17–256 / 257–1024 / >1024 clusters | Active / partially damaged bonds | Distinct building health patterns |','|---|---:|---:|---:|---:|---:|']
for r in rows:
    b=r['baseline'];c=r.get('clusters');h=r.get('health',{});bins=c['bins'] if c else {};count=lambda key:bins.get(key,{}).get('clusters',0)
    values=[count('1-1'),count('2-4')+count('5-16'),count('17-64')+count('65-256'),count('257-1024'),count('1025-4294967295')]
    lines.append(f'| {r["scenario"]} | {b["tick_mean_ms"]:.3f} / {b["tick_max_ms"]:.3f} | '+(f'{c["count"]} / {c["largest"]}' if c else 'no destruction observation')+' | '+' / '.join(map(str,values))+f' | {h.get("active","—")} / {h.get("partially_damaged","—")} | {h.get("distinct_building_health_patterns","—")} |')
lines+=['','[Structured traits and array provenance](physical-traits.json). Sizes include chunks excluded from the dynamic stress unknowns; they are not equivalent to solver component sizes. Use a current weighted work census before choosing size-based solver changes.','']
(a.output/'physical-traits.md').write_text('\n'.join(lines));print(len(rows),'physical trait rows')
