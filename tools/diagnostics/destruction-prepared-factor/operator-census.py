#!/usr/bin/env python3
"""Exact operator-only sharing census, joined to already saved native work.

Positive health magnitude, current loads and warm solutions are not matrix
coefficients. Membership, liveness, weights, lever arms, scales and boundaries
are. Full byte equality resolves hashes; no physics or fresh GPU collection.
"""
import argparse
from collections import defaultdict
import hashlib
import json
from pathlib import Path
import struct


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('manifest', type=Path)
    parser.add_argument('output', type=Path)
    args = parser.parse_args()
    assert not args.output.exists()
    record = dict(scope=__doc__, cases=[], source_sha256=hashlib.sha256(Path(__file__).read_bytes()).hexdigest())
    for case in json.loads(args.manifest.read_text())['cases']:
        prefix = case['prefix']
        meta = json.loads(Path(prefix+'.json').read_text())
        node_bytes = Path(prefix+'.nodes.bin').read_bytes()
        bond_bytes = Path(prefix+'.bonds.bin').read_bytes()
        nodes = list(struct.iter_unpack('<15fI', node_bytes))
        bonds = list(struct.iter_unpack('<II14f', bond_bytes))
        members, edges = defaultdict(list), defaultdict(list)
        for i, node in enumerate(nodes):
            if node[-1] != 2**32-1:
                members[node[-1]].append(i)
        for i, bond in enumerate(bonds):
            if bond[8] <= 0 or bond[9] == 0:
                continue
            ids = {nodes[bond[0]][-1], nodes[bond[1]][-1]}-{2**32-1}
            assert len(ids) <= 1
            for identity in ids:
                edges[identity].append(i)
        work = {}
        for line in Path(case['work_jsonl']).read_text().splitlines():
            row = json.loads(line)
            if row.get('record') == 'component' and row['solve'] == meta['solve']:
                work[row['id']] = row
        assert set(work) == set(members)
        groups = defaultdict(list)
        for identity, indices in members.items():
            local = {index:i for i,index in enumerate(indices)}
            key = bytearray(struct.pack('<II', len(indices), len(edges[identity])))
            for index in indices:
                key.extend(node_bytes[index*64:index*64+8])
            for edge in edges[identity]:
                bond = bonds[edge]
                key.extend(struct.pack('<ii', local.get(bond[0], -1), local.get(bond[1], -1)))
                key.extend(bond_bytes[edge*64+8:edge*64+32])  # six lever-arm coordinates
                key.extend(bond_bytes[edge*64+36:edge*64+40]) # coupling, not health
            groups[bytes(key)].append(identity)
        result = dict(scenario=case['scenario'], solve=meta['solve'], groups=[])
        for key, ids in groups.items():
            ws = [work[identity] for identity in ids]
            assert all(w['anchored'] == ws[0]['anchored'] for w in ws)
            result['groups'].append(dict(members=ids, anchored=ws[0]['anchored'], nodes=ws[0]['nodes'],
                                         iteration_nodes=sum(w['nodes']*w['iterations'] for w in ws),
                                         coefficient_sha256=hashlib.sha256(key).hexdigest()))
        anchored = [g for g in result['groups'] if g['anchored']]
        result['anchored_components'] = sum(len(g['members']) for g in anchored)
        result['unique_anchored_operators'] = len(anchored)
        result['anchored_iteration_nodes'] = sum(g['iteration_nodes'] for g in anchored)
        result['largest_share'] = max((len(g['members']) for g in anchored), default=0)
        result['work_in_shared_anchored_operators'] = sum(g['iteration_nodes'] for g in anchored if len(g['members']) > 1)
        result['provenance'] = {str(p):hashlib.sha256(p.read_bytes()).hexdigest() for p in
                                [Path(prefix+'.nodes.bin'), Path(prefix+'.bonds.bin'), Path(case['work_jsonl'])]}
        record['cases'].append(result)
        args.output.write_text(json.dumps(record, indent=2)+'\n')
        print(json.dumps({k:v for k,v in result.items() if k not in ['groups','provenance']}), flush=True)
    record['status'] = 'complete_census_not_runtime_qualification'
    args.output.write_text(json.dumps(record, indent=2)+'\n')


if __name__ == '__main__':
    main()
