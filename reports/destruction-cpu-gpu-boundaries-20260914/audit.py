#!/usr/bin/env python3
"""Read saved warm52 timelines and audit host/device boundaries; no GPU work."""
import collections
import hashlib
import json
import sqlite3
from pathlib import Path

ROOT = Path(__file__).resolve().parents[2]
HERE = Path(__file__).resolve().parent
(HERE / 'data').mkdir(exist_ok=True)
hashes = {}


def read(p):
    p = Path(p)
    raw = p.read_bytes()
    hashes[str(p.relative_to(ROOT))] = hashlib.sha256(raw).hexdigest()
    return json.loads(raw)


def union(intervals):
    result = []
    for a, b in sorted(intervals):
        if result and a <= result[-1][1]:
            result[-1][1] = max(result[-1][1], b)
        else:
            result.append([a, b])
    return result


def overlap(lo, hi, intervals):
    return sum(max(0, min(hi, b) - max(lo, a)) for a, b in intervals) / 1e6


def event_audit(db, calls, lo, hi):
    """Recover record instances by correlation; CUDA_EVENT timestamps can be zero.

    The graph covers observed record/stream-wait commands only. It does not
    represent implicit synchronization, graph-internal events or host locks.
    """
    def dictionaries(table, clause='', args=()):
        cur = db.execute('SELECT * FROM ' + table + ' ' + clause, args)
        columns = [x[0] for x in cur.description]
        return [dict(zip(columns, row)) for row in cur]

    events = dictionaries('CUPTI_ACTIVITY_KIND_CUDA_EVENT')
    waits = dictionaries('CUPTI_ACTIVITY_KIND_SYNCHRONIZATION',
                         'WHERE start>=? AND end<=? AND syncType=2', (lo, hi))
    key = lambda e: (e['contextId'], e['globalPid'], e['eventId'], e['eventSyncId'])
    index = collections.defaultdict(list)
    for e in events:
        index[key(e)].append(e)
    by_correlation = {c['correlation_id']: c for c in calls}
    selected = [e for e in events if e['correlationId'] in by_correlation]
    nodes = {}
    for e in selected:
        c = by_correlation[e['correlationId']]
        assert 'EventRecord' in c['name'], c['name']
        nodes[('record', e['correlationId'])] = dict(e, start_ns=c['start_ns'], end_ns=c['end_ns'])
    edges = set()
    details = []
    for w in waits:
        c = by_correlation.get(w['correlationId'])
        if c:
            assert 'StreamWaitEvent' in c['name'], c['name']
            nodes[('wait', w['correlationId'])] = dict(w, start_ns=c['start_ns'], end_ns=c['end_ns'])
        matches = index[key(w)]
        detail = {'wait_correlation': w['correlationId'], 'event_id': w['eventId'],
                  'event_sync_id': w['eventSyncId'], 'wait_stream': w['streamId'],
                  'matching_records': len(matches), 'wait_api_found': bool(c)}
        if len(matches) == 1:
            e = matches[0]
            producer = by_correlation.get(e['correlationId'])
            location = 'selected_tick'
            if not producer:
                rows = db.execute('SELECT start,end FROM CUPTI_ACTIVITY_KIND_RUNTIME WHERE correlationId=?',
                                  (e['correlationId'],)).fetchall()
                if len(rows) == 1:
                    producer = dict(start_ns=rows[0][0], end_ns=rows[0][1])
                    location = 'before_tick' if rows[0][1] <= lo else 'outside_selected_api_inventory'
                else:
                    location = 'api_unavailable'
            detail.update(record_correlation=e['correlationId'], record_stream=e['streamId'],
                          record_location=location,
                          record_api_before_wait=producer['end_ns'] <= (c['start_ns'] if c else w['start']) if producer else None)
            if location == 'selected_tick' and c:
                edges.add((('record', e['correlationId']), ('wait', w['correlationId'])))
        details.append(detail)
    streams = collections.defaultdict(list)
    for node, event in nodes.items():
        streams[(event['contextId'], event['globalPid'], event['streamId'])].append((event['start_ns'], event['end_ns'], node))
    ambiguous_order = 0
    for commands in streams.values():
        commands.sort()
        for previous, current in zip(commands, commands[1:]):
            if previous[1] <= current[0]:
                edges.add((previous[2], current[2]))
            else:
                ambiguous_order += 1
    indegree = {node: 0 for node in nodes}
    followers = collections.defaultdict(list)
    for a, b in edges:
        indegree[b] += 1
        followers[a].append(b)
    ready = collections.deque(node for node in nodes if indegree[node] == 0)
    visited = 0
    while ready:
        node = ready.popleft()
        visited += 1
        for child in followers[node]:
            indegree[child] -= 1
            if not indegree[child]:
                ready.append(child)
    return {'selected_records_by_correlation': len(selected),
            'selected_record_zero_timestamps': sum(e['timestamp'] == 0 for e in selected),
            'stream_waits': len(waits), 'matched_once': sum(d['matching_records'] == 1 for d in details),
            'producer_locations': dict(collections.Counter(d.get('record_location', 'unmatched') for d in details)),
            'producer_api_before_wait': sum(d.get('record_api_before_wait') is True for d in details),
            'producer_api_order_unavailable': sum(d.get('record_api_before_wait') is None for d in details),
            'producer_api_order_overlaps_or_reversed': sum(d.get('record_api_before_wait') is False for d in details),
            'observed_handoff_graph_nodes': len(nodes), 'observed_handoff_graph_edges': len(edges),
            'ambiguous_same_stream_api_order': ambiguous_order, 'observed_handoff_subgraph_acyclic': visited == len(nodes),
            'waits': details}


coverage = read(ROOT / 'reports/destruction-warm-full52-20260914/data/coverage.json')
timings = {r['scenario']: r for r in read(ROOT / 'reports/destruction-warm-full52-20260914/data/scenarios.json')}
scope_names = ['GpuDestruction.task.prepareIslandRepair', 'GpuDestruction.compatibility.requestReadback',
               'GpuDestruction.applyBindings', 'GpuDestruction.finalPublication', 'GpuDestruction.task.sleepCommit']
ownership_names = ['GpuDestruction.compatibility.allocateNativeBodies', 'GpuDestruction.applyDetail.migrateShapes']
rows = []
for r in coverage['rows']:
    name = r['scenario']
    a = read(Path(r['cpu_path']) / 'attribution-normalized.json')
    gpu = union([(k['start_ns'], k['end_ns']) for kind in ['kernels', 'transfers', 'memsets'] for k in a[kind]])
    stress = union([(k['start_ns'], k['end_ns']) for k in a['kernels'] if 'componentStressSolve' in k['name']])
    calls = a['cpu_attribution']['cuda_calls']
    db = sqlite3.connect('file:' + r['cpu_path'] + '/trace.sqlite?mode=ro', uri=True)
    lo, hi = db.execute("SELECT start,end FROM NVTX_EVENTS WHERE text='snapshot/full_tick'").fetchone()
    assert abs((hi-lo)/1e6 - r['profiled_tick_ms']) < 1e-6
    launches = []
    for c in calls:
        if c['name'].startswith('cudaGraphLaunch') and any('Transaction::prepare' in s['symbol'] for s in c['stack']):
            launches.append({'api_ms': c['ms'], 'stress_overlap_ms': overlap(c['start_ns'], c['end_ns'], stress),
                             'no_recorded_gpu_ms': max(0, c['ms'] - overlap(c['start_ns'], c['end_ns'], gpu)),
                             'correlation': c['correlation_id'], 'start_ms': (c['start_ns']-lo)/1e6,
                             'thread': c['thread']})
    scopes = []
    for s in scope_names:
        copies = [x for x in a['transfers'] if x.get('launch_scope') == s]
        api = [x for x in calls if x.get('scope') == s]
        scopes.append({'name': s, 'cuda_calls': len(api),
                       'host_sync_calls': sum('Synchronize' in x['name'] for x in api),
                       'host_sync_api_ms': sum(x['ms'] for x in api if 'Synchronize' in x['name']),
                       'copies': {kind: {'count': sum(x['kind'] == code for x in copies),
                                        'bytes': sum(x['bytes'] for x in copies if x['kind'] == code),
                                        'summed_ms': sum(x['ms'] for x in copies if x['kind'] == code)}
                                  for kind, code in [('HtoD', 1), ('DtoH', 2), ('DtoD', 8)]}})
    owners = []
    for s in ownership_names:
        intervals = db.execute('SELECT n.start,n.end FROM NVTX_EVENTS n LEFT JOIN StringIds s ON n.textId=s.id '
                               'WHERE coalesce(n.text,s.value)=? AND n.start>=? AND n.end<=?', (s, lo, hi)).fetchall()
        owners.append({'name': s, 'calls': len(intervals),
                       'nvtx_wall_ms': sum(b-a for a, b in intervals)/1e6,
                       'no_recorded_gpu_ms': sum((b-a)/1e6-overlap(a, b, gpu) for a, b in intervals)})
    stream_columns = [x[1] for x in db.execute('PRAGMA table_info(TARGET_INFO_CUDA_STREAM)')]
    streams = [dict(zip(stream_columns, x)) for x in db.execute('SELECT * FROM TARGET_INFO_CUDA_STREAM')]
    # CUPTI stream IDs are not CUDA stream handles; ID 7, for example, can be the null stream.
    sync_columns = [x[1] for x in db.execute('PRAGMA table_info(ENUM_CUPTI_SYNC_TYPE)')]
    sync_enums = [dict(zip(sync_columns, x)) for x in db.execute('SELECT * FROM ENUM_CUPTI_SYNC_TYPE')]
    synctype_counts = db.execute('SELECT syncType,count(*),sum(end-start)/1e6 FROM CUPTI_ACTIVITY_KIND_SYNCHRONIZATION '
                                'WHERE start>=? AND end<=? GROUP BY syncType', (lo, hi)).fetchall()
    event_records = event_audit(db, calls, lo, hi)
    db.close()
    t = timings[name]
    rows.append({'scenario': name, 'mean_range_ms': t['mean_range_ms'], 'peak_ms': t['peak_ms'],
                 'n': t['n'], 'misses_60hz': t['misses_60hz'], 'profile_tick_ms': r['profiled_tick_ms'],
                 'topology_launches': launches, 'boundary_scopes': scopes, 'ownership_scopes': owners,
                 'cuda_sync_calls': sum('Synchronize' in x['name'] for x in calls),
                 'cuda_device_sync_calls': sum('DeviceSynchronize' in x['name'] or 'CtxSynchronize' in x['name'] for x in calls),
                 'cuda_sync_api_sum_ms': sum(x['ms'] for x in calls if 'Synchronize' in x['name']),
                 'sync_activity_by_type': synctype_counts, 'sync_enums': sync_enums,
                 'event_audit': event_records, 'streams': streams,
                 'profile_path': r['cpu_path'], 'warnings': r['warnings']})

source = {}
for directory in ['out/cpu-gpu-boundaries-20260914/source', 'out/warm-bottleneck-analysis-20260914/source']:
    for p in sorted((ROOT / directory).glob('*')):
        if p.is_file():
            source[str(p.relative_to(ROOT))] = hashlib.sha256(p.read_bytes()).hexdigest()
(HERE / 'data/audit.json').write_text(json.dumps({'source_commit': '13b11af2e0aeabf4e0070931fbd8a060f383dfaf',
    'scope': 'Saved warm52 first-measured-tick boundary audit; no new simulation',
    'rows': rows, 'input_sha256': hashes, 'source_sha256': source}, indent=2)+'\n')

lines = ['# All52 CPU/GPU boundary measurements', '',
         'Complete-step timings are unprofiled warm-window process means and observed peaks. '
         'Every other column comes from the one selected, instrumented first tick. '
         'Ownership gaps are the union of recorded-GPU inactivity intersecting named CPU scopes, '
         'not a production saving estimate. Topology launch API time overlaps stress execution. '
         'Host sync API counts exclude device stream-wait calls and are not counts of redundant waits.', '',
         '[Full stages, physical work and preparation](../destruction-warm-full52-20260914/all-scenarios.md). '
         '[Structured scopes, streams and raw locators](data/audit.json).', '',
         '| Scenario | Mean range / peak ms | Misses / n | Profile tick ms | Allocation / migration GPU-inactive ms | Topology-launch API / stress-overlap / GPU-inactive ms | Island D→H MB | Host sync calls / summed API ms |',
         '|---|---:|---:|---:|---:|---:|---:|---:|']
for r in rows:
    launch=r['topology_launches'];own=r['ownership_scopes'];repair=r['boundary_scopes'][0]
    lines.append(f"| {r['scenario']} | {r['mean_range_ms'][0]:.3f}–{r['mean_range_ms'][1]:.3f} / {r['peak_ms']:.3f} | "
                 f"{r['misses_60hz']}/{r['n']} | {r['profile_tick_ms']:.3f} | "
                 f"{own[0]['no_recorded_gpu_ms']:.3f} / {own[1]['no_recorded_gpu_ms']:.3f} | "
                 f"{sum(x['api_ms'] for x in launch):.3f} / {sum(x['stress_overlap_ms'] for x in launch):.3f} / {sum(x['no_recorded_gpu_ms'] for x in launch):.3f} | "
                 f"{repair['copies']['DtoH']['bytes']/1e6:.6f} | {r['cuda_sync_calls']} / {r['cuda_sync_api_sum_ms']:.3f} |")
(HERE/'all-scenarios.md').write_text('\n'.join(lines)+'\n')
print(json.dumps({'status':'passed','scenarios':len(rows),'input_hashes':len(hashes),
                  'observed_device_wide_sync_calls':sum(r['cuda_device_sync_calls'] for r in rows),
                  'selected_event_records_recovered':sum(r['event_audit']['selected_records_by_correlation'] for r in rows),
                  'stream_waits':sum(r['event_audit']['stream_waits'] for r in rows),
                  'matched_stream_waits':sum(r['event_audit']['matched_once'] for r in rows),
                  'acyclic_handoff_subgraphs':sum(r['event_audit']['observed_handoff_subgraph_acyclic'] for r in rows)}))
