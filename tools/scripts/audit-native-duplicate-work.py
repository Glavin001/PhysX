"""Exact captured-input/output equality joined to native work, not speedup evidence.

Manifest entries supply scenario, prefix (without extension), and work_jsonl.
The capture does not include all private preconditioner/certificate state; passing
this census is evidence for an implementation investigation, not permission to
alias production solves.
"""
import argparse
import collections
import hashlib
import json
import math
from pathlib import Path
import struct

parser = argparse.ArgumentParser(description=__doc__)
parser.add_argument('manifest', type=Path)
parser.add_argument('output', type=Path)
args = parser.parse_args()
assert not args.output.exists(), 'Preserve previous audits'
record = {'status': 'running', 'scope': __doc__, 'cases': [],
          'manifest_sha256': hashlib.sha256(args.manifest.read_bytes()).hexdigest(),
          'script_sha256': hashlib.sha256(Path(__file__).read_bytes()).hexdigest()}
sentinel = 2**32-1
work_fields = ['path', 'nodes', 'dynamic_nodes', 'csr_refs_per_sweep', 'live_refs_per_sweep',
               'residual_sweeps', 'verification_sweeps', 'direction_sweeps', 'iterations',
               'converged', 'anchored', 'polynomial_refs_per_sweep', 'precondition_sweeps']
for entry in json.loads(args.manifest.read_text())['cases']:
    prefix = Path(entry['prefix'])
    paths = {ext: Path(str(prefix)+ext) for ext in ['.json', '.nodes.bin', '.bonds.bin', '.solution.bin']}
    meta = json.loads(paths['.json'].read_text())
    assert meta['version'] == 1 and meta['record_bytes'] == 64 and meta['endian'] == 'little'
    node_bytes = paths['.nodes.bin'].read_bytes()
    bond_bytes = paths['.bonds.bin'].read_bytes()
    solution = paths['.solution.bin'].read_bytes()
    assert len(node_bytes) == meta['node_count']*64
    assert len(bond_bytes) == meta['bond_count']*64
    assert len(solution) == meta['bond_count']*24
    nodes = list(struct.iter_unpack('<15fI', node_bytes))
    bonds = list(struct.iter_unpack('<II14f', bond_bytes))
    assert all(math.isfinite(v) for n in nodes for v in n[:15])
    assert all(math.isfinite(v) for e in bonds for v in e[2:])
    assert all(math.isfinite(v[0]) for v in struct.iter_unpack('<f', solution))
    members = collections.defaultdict(list)
    edges = collections.defaultdict(list)
    anchored = collections.defaultdict(bool)
    for i, n in enumerate(nodes):
        if n[-1] != sentinel: members[n[-1]].append(i)
    for i, e in enumerate(bonds):
        a, z = e[:2]
        assert a < len(nodes) and z < len(nodes)
        if e[8] <= 0 or e[9] == 0: continue
        labels = {nodes[a][-1], nodes[z][-1]}-{sentinel}
        assert len(labels) <= 1, 'Live bond spans different captured components'
        for identity in labels:
            edges[identity].append(i)
            anchored[identity] |= nodes[a][-1] == sentinel or nodes[z][-1] == sentinel
    work_path = Path(entry['work_jsonl'])
    work = {}
    for line in work_path.read_text().splitlines():
        w = json.loads(line)
        if w.get('record') == 'component' and w['solve'] == meta['solve']:
            assert w['id'] not in work
            work[w['id']] = w
    assert set(work) == set(members), 'Capture/work component coverage differs'
    groups = collections.defaultdict(list)
    coefficients = set()
    outputs = {}
    for identity, ns in members.items():
        local = {n:i for i,n in enumerate(ns)}
        coeff = bytearray(struct.pack('<II?', len(ns), len(edges[identity]), anchored[identity]))
        loads = bytearray()
        for n in ns:
            coeff.extend(node_bytes[n*64:n*64+8])
            loads.extend(node_bytes[n*64+8:n*64+60])
        output = bytearray()
        for edge in edges[identity]:
            a, z = bonds[edge][:2]
            coeff.extend(struct.pack('<ii', local.get(a,-1), local.get(z,-1)))
            # Deliberately conservative: positive health magnitude is included,
            # although resident stiffness only depends on health liveness.
            coeff.extend(bond_bytes[edge*64+8:edge*64+40])
            loads.extend(bond_bytes[edge*64+40:edge*64+64])
            output.extend(solution[edge*24:edge*24+24])
        coefficients.add(bytes(coeff))
        # Python dictionaries use full key equality after hashing. Never alias
        # based only on the report's digest.
        groups[(bytes(coeff), bytes(loads))].append(identity)
        outputs[identity] = bytes(output)
    case = dict(entry, solve=meta['solve'], node_count=len(nodes), bond_count=len(bonds),
                components=len(members), unique_coefficient_groups=len(coefficients),
                unique_captured_problem_groups=len(groups), groups=[])
    case['sources_sha256'] = {str(p): hashlib.sha256(p.read_bytes()).hexdigest() for p in [*paths.values(), work_path]}
    for key, ids in groups.items():
        ws = [work[i] for i in ids]
        same_work = all(tuple(w.get(f) for f in work_fields) == tuple(ws[0].get(f) for f in work_fields) for w in ws)
        same_output = all(outputs[i] == outputs[ids[0]] for i in ids)
        updates = [w['iterations']*w['nodes'] for w in ws]
        g = {'members': ids, 'anchored': anchored[ids[0]], 'nodes': len(members[ids[0]]),
             'iterations': [w['iterations'] for w in ws], 'same_work_fields': same_work,
             'captured_outputs_bit_identical': same_output, 'all_converged': all(w['converged'] for w in ws),
             'total_iteration_node_updates': sum(updates),
             'duplicate_iteration_node_updates': sum(updates[1:]) if same_work and same_output else 0,
             'identity_sha256': hashlib.sha256(key[0]+key[1]).hexdigest()}
        case['groups'].append(g)
    case['total_iteration_node_updates'] = sum(g['total_iteration_node_updates'] for g in case['groups'])
    case['duplicate_iteration_node_updates'] = sum(g['duplicate_iteration_node_updates'] for g in case['groups'])
    case['duplicate_update_fraction'] = case['duplicate_iteration_node_updates']/case['total_iteration_node_updates'] if case['total_iteration_node_updates'] else 0
    record['cases'].append(case)
    print(json.dumps({k:v for k,v in case.items() if k not in ['groups','sources_sha256']}), flush=True)
record['status'] = 'exact_captured_identity_and_work_census_complete_not_runtime_qualification'
args.output.write_text(json.dumps(record, indent=2)+'\n')
