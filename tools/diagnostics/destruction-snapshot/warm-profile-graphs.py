#!/usr/bin/env python3
"""Collect every nonempty graph launch with full counters, auditing timeline coverage.

Graph counters supplement individual-kernel timelines/selected node counters.
They do not supply individual conditional-node or instruction-source metrics.
"""
import argparse,hashlib,importlib.util,json,math,os,sqlite3,subprocess,sys,time
from pathlib import Path
ROOT=Path(__file__).resolve().parents[3]
spec=importlib.util.spec_from_file_location('profile',Path(__file__).with_name('analyze-profile.py'));profile=importlib.util.module_from_spec(spec);spec.loader.exec_module(profile)

def inventory(path):
    db=sqlite3.connect(f'file:{path/"trace.sqlite"}?mode=ro',uri=True);db.row_factory=sqlite3.Row
    lo,hi=db.execute("select start,end from NVTX_EVENTS where text='snapshot/full_tick'").fetchone()
    tables={r[0] for r in db.execute("select name from sqlite_master where type='table'")};launches=[]
    for table in ['CUPTI_ACTIVITY_KIND_RUNTIME','CUPTI_ACTIVITY_KIND_DRIVER']:
        if table not in tables:continue
        for r in db.execute(f'select a.*,s.value as name from {table} a join StringIds s on s.id=a.nameId where a.start>=? and a.end<=? and s.value like "%GraphLaunch%" order by a.start',(lo,hi)):
            nodes=[dict(k) for k in db.execute('select k.*,s.value as name from CUPTI_ACTIVITY_KIND_KERNEL k join StringIds s on k.mangledName=s.id where correlationId=? and start>=? and end<=? order by start',(r['correlationId'],lo,hi))]
            if nodes:launches.append(dict(api=r['name'],correlation_id=r['correlationId'],start_ns=r['start'],end_ns=r['end'],thread=r['globalTid'],nodes=[dict(name=k['name'],graph_id=k['graphId'],node_id=k['graphNodeId'],ms=(k['end']-k['start'])/1e6) for k in nodes]))
    # Systems can record both an API/backtrace wrapper and its versioned CUPTI
    # alias with the same correlation ID. They represent one physical graph.
    unique={}
    for item in launches:
        key=item['correlation_id'];old=unique.get(key)
        if old is None:unique[key]=item;item['api_aliases']=[item['api']];continue
        assert old['thread']==item['thread'] and old['nodes']==item['nodes'], 'Ambiguous duplicate graph correlation'
        assert (old['start_ns']<=item['start_ns']<=item['end_ns']<=old['end_ns'] or item['start_ns']<=old['start_ns']<=old['end_ns']<=item['end_ns']), 'Non-nested duplicate graph APIs'
        import re
        assert re.sub(r'_v[0-9]+$','',old['api'])==re.sub(r'_v[0-9]+$','',item['api']), 'Different graph API families share correlation'
        old['api_aliases'].append(item['api'])
        old['start_ns']=min(old['start_ns'],item['start_ns']);old['end_ns']=max(old['end_ns'],item['end_ns'])
    return sorted(unique.values(),key=lambda r:r['start_ns'])
