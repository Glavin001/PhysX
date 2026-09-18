#!/usr/bin/env python3
"""Inspect zero-iteration compatibility checks without rerunning capped solves."""
import argparse
import json
from pathlib import Path
import numpy as np
from analyze import CHUNK, BODY, read
from check_fine import RECEIPT
from check_replay import check as check_loads

def inspect(directory,prefix):
    meta=json.loads((directory/'manifest.json').read_text())
    profile=json.loads(Path(str(prefix)+'.profile.json').read_text())
    assert profile['initial_check_only'] and profile['max_iterations']==0
    chunks=read(directory,meta,'chunks',CHUNK)
    bodies=read(directory,meta,'bodies',BODY)
    surface=read(directory,meta,'surface',('<f4',(12,)))
    receipts=np.fromfile(str(prefix)+'.fine-receipts.bin',dtype=RECEIPT)
    starts=np.fromfile(str(prefix)+'.starts.bin',dtype='<u4')
    nodes=np.fromfile(str(prefix)+'.nodes.bin',dtype='<u4')
    rhs=np.fromfile(str(prefix)+'.rhs.bin',dtype='<f8').reshape(-1,6)
    assert len(starts)==len(receipts)+1 and starts[-1]==len(nodes)
    assert not np.any(receipts['iterations'])
    rejected=[]
    for i in np.flatnonzero(receipts['status']==4):
        ids=nodes[starts[i]:starts[i+1]];groups=np.unique(chunks['cluster'][ids])
        assert len(groups)==1
        rejected.append(dict(component=int(i),nodes=len(ids),group=int(groups[0]),
                             surface_max=float(np.max(np.abs(surface[ids,:6]))),
                             spin_max=float(np.max(np.abs(bodies['angular'][groups[0]]))),
                             rhs_max=float(np.max(np.abs(rhs[ids]))),
                             compatibility=float(receipts[i]['compatibility'])))
    load_check=check_loads(directory,prefix)
    result=dict(scope='frozen contact-plus-gravity input; zero-iteration numerical check, not a completed solve',
                ordinal=meta['ordinal'],chunks=len(chunks),bonds=meta['bond_endpoints']['count'],
                components=len(receipts),unknowns=len(nodes),iterations=0,
                status_counts={str(int(s)):int(np.count_nonzero(receipts['status']==s)) for s in np.unique(receipts['status'])},
                incompatible=len(rejected),
                incompatible_without_contact=sum(r['surface_max']==0 for r in rejected),
                incompatible_without_contact_or_spin=sum(r['surface_max']==0 and r['spin_max']==0 for r in rejected),
                load_check=load_check,rejected_components=rejected)
    Path(str(prefix)+'.compatibility.json').write_text(json.dumps(result,indent=2)+'\n')
    return result

if __name__=='__main__':
    p=argparse.ArgumentParser(description=__doc__);p.add_argument('capture',type=Path);p.add_argument('prefix',type=Path)
    a=p.parse_args();r=inspect(a.capture,a.prefix)
    print(json.dumps({k:v for k,v in r.items() if k!='rejected_components'},indent=2))
    raise SystemExit(0 if r['load_check']['passed'] else 1)
