#!/usr/bin/env python3
"""Keep raw attribution; normalize verified nested/versioned CUDA API aliases in a sidecar."""
import argparse,collections,copy,importlib.util,json,re
from pathlib import Path
s=importlib.util.spec_from_file_location('analysis',Path(__file__).with_name('analyze-profile.py'));m=importlib.util.module_from_spec(s);s.loader.exec_module(m)
def normalize(d):
    c=d['cpu_attribution'];raw=c['cuda_calls'];groups=collections.defaultdict(list)
    for a in raw:
        key=(a['correlation_id'],a['thread'],re.sub(r'_v[0-9]+$','',a['name']))
        if key[0] is None:key=(*key,a['start_ns'],a['end_ns'])
        groups[key].append(a)
    selected=[];aliases=[]
    for key,items in groups.items():
        if len(items)==1:selected+=items;continue
        outer=min(items,key=lambda a:(a['start_ns'],-a['end_ns']))
        if not all(outer['start_ns']<=a['start_ns']<=a['end_ns']<=outer['end_ns'] for a in items):
            raise ValueError('Non-nested shared correlation: '+str(key))
        representative=max(items,key=lambda a:(bool(a['stack']),a['end_ns']-a['start_ns']))
        canonical=dict(representative,name=key[2],start_ns=outer['start_ns'],end_ns=outer['end_ns'],ms=outer['ms'])
        selected.append(canonical);aliases.append(dict(correlation_id=key[0],thread=key[1],canonical=key[2],records=[dict(name=a['name'],start_ns=a['start_ns'],end_ns=a['end_ns'],stack_frames=len(a['stack'])) for a in items]))
    selected.sort(key=lambda a:a['start_ns']);c['cuda_calls']=selected
    # Raw waits keep their individual identity in attribution.json; the sidecar
    # reports one canonical wait per verified API call and preserves OS records.
    waits=[a for a in c['waits'] if a['kind']!='cuda']
    gpu=m.accounting.union((k['start_ns'],k['end_ns']) for k in d['kernels']+d['transfers']+d['memsets'])
    for a in selected:
        if 'Synchronize' in a['name'] or ('Memcpy' in a['name'] and 'Async' not in a['name']):
            a=copy.deepcopy(a)
            a['gpu_overlap_ms']=m.accounting.length(m.accounting.intersect([(a['start_ns'],a['end_ns'])],gpu))/1e6;waits.append(a)
    c['waits']=sorted(waits,key=lambda a:-a['ms']);grouped=collections.defaultdict(list)
    for a in selected:grouped[a['name']].append((a['start_ns'],a['end_ns']))
    d['cuda_apis']=sorted([dict(name=n,calls=len(v),aggregate_ms=sum(b-a for a,b in v)/1e6,union_ms=m.accounting.length(v)/1e6) for n,v in grouped.items()],key=lambda a:-a['aggregate_ms'])
    correlations={}
    for a in selected:
        old=correlations.get(a['correlation_id'])
        if old is None or (bool(a['scope']),len(a['stack']))>(bool(old['scope']),len(old['stack'])):correlations[a['correlation_id']]=a
    for k in d['kernels']:
        a=correlations.get(k['correlation_id'])
        if a:k.update(launch_api=a['name'],launch_scope=a['scope'],launch_thread=a['thread'])
    c['gpu_launches_with_correlated_api']=sum(k['launch_api'] is not None for k in d['kernels']);c['gpu_launches_with_engine_scope']=sum(k['launch_scope'] is not None for k in d['kernels'])
    d['cuda_api_normalization']=dict(raw_records=len(raw),physical_calls=len(selected),removed_alias_records=len(raw)-len(selected),aliases=aliases,rule='Same correlation, thread and version-stripped API name; intervals must be nested. Raw SQLite and attribution.json unchanged.')
    return d
if __name__=='__main__':
    p=argparse.ArgumentParser(description=__doc__);p.add_argument('capture',type=Path);a=p.parse_args();out=a.capture/'attribution-normalized.json'
    if out.exists():raise RuntimeError('Output exists')
    d=normalize(json.loads((a.capture/'attribution.json').read_text()));out.write_text(json.dumps(d,indent=2)+'\n');print(d['cuda_api_normalization']['raw_records'],d['cuda_api_normalization']['physical_calls'])
