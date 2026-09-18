#!/usr/bin/env python3
"""Check original input retention in the four frozen native evaluations."""
import argparse
import hashlib
import json
from pathlib import Path
import struct
import numpy as np


def check(capture, require_owners=False):
    records = []
    for ordinal, tick, evaluation in [(0, 1, 0), (82, 83, 0), (83, 83, 1), (130, 109, 0)]:
        directory = capture / f'solve-{ordinal}'
        manifest = json.loads((directory / 'manifest.json').read_text())
        assert (manifest['tick'], manifest['evaluation']) == (tick, evaluation)
        assert manifest['input_history_purpose'] == 0
        assert manifest['checkpoint_purpose'] == evaluation
        assert manifest['input_history_generation'] > 0
        if evaluation:
            assert manifest['input_history_generation'] < manifest['checkpoint_generation']
        else:
            assert manifest['input_history_generation'] == manifest['checkpoint_generation']
        arrays = {}
        for name in ['original_bodies', 'original_previous', 'original_accelerations']:
            if name not in manifest:
                assert name != 'original_bodies'
                continue
            layout = manifest[name]
            data = (directory / (name + '.bin')).read_bytes()
            assert layout['count'] == manifest['input_history_count'] > 0
            assert len(data) == layout['count'] * layout['stride']
            arrays[name] = dict(layout, bytes=len(data), sha256=hashlib.sha256(data).hexdigest())
        records.append(dict(ordinal=ordinal, tick=tick, evaluation=evaluation,
                            input_generation=manifest['input_history_generation'],
                            checkpoint_generation=manifest['checkpoint_generation'], arrays=arrays))
        if require_owners or 'original_owners' in manifest:
            owner_layout = manifest['original_owners']
            receipt_layout = manifest['original_ownership']
            assert owner_layout == dict(count=manifest['chunks']['count'], stride=24)
            assert receipt_layout == dict(count=1, stride=32)
            raw = (directory / 'original_owners.bin').read_bytes()
            receipt = (directory / 'original_ownership.bin').read_bytes()
            generation, topology, chunks, bodies, valid, error = struct.unpack('<QQIIII', receipt)
            assert valid == 1 and error == 0 and generation == manifest['input_history_generation']
            assert chunks == owner_layout['count'] and bodies == manifest['input_history_count']
            assert len(raw) == chunks * 24
            owners = np.frombuffer(raw, dtype=[('generation','<u8'),('body','<u4'),('root','<u4'),('slot','<u4'),('active','<u4')])
            active = np.fromfile(directory / 'active_chunks.bin', dtype='<u4') != 0
            original_active = owners['active'] != 0
            assert np.all(owners['active'] <= 1) and np.all(original_active[active])
            assert np.all(owners['body'][original_active] < bodies)
            assert np.all(owners['root'][original_active] < chunks)
            assert np.all(owners['body'][~original_active] == 0xffffffff)
            chunk_rows = np.fromfile(directory / 'chunks.bin', dtype='<u4').reshape(chunks, 9)
            current_groups = chunk_rows[:, 5][active]
            count = manifest['cluster_count']
            low = np.full(count, 0xffffffff, dtype='<u4')
            high = np.zeros(count, dtype='<u4')
            np.minimum.at(low, current_groups, owners['body'][active])
            np.maximum.at(high, current_groups, owners['body'][active])
            assert np.array_equal(low, high), 'One current fragment joins different original bodies'
            current = np.fromfile(directory / 'bodies.bin', dtype='<u4').reshape(count, 19)[:, 14]
            if not evaluation:
                assert topology == manifest['ownership_generation']
                assert np.array_equal(active, original_active) and np.array_equal(current, low)
                roots = np.fromfile(directory / 'chunk_root.bin', dtype='<u4')
                slots = np.fromfile(directory / 'root_slot.bin', dtype='<u4')
                generations = np.fromfile(directory / 'slot_generations.bin', dtype='<u8')
                assert np.array_equal(owners['root'][active], roots[active])
                assert np.array_equal(owners['slot'][active], slots[roots[active]])
                assert np.array_equal(owners['generation'][active], generations[owners['slot'][active]])
            records[-1]['ownership'] = dict(sha256=hashlib.sha256(raw).hexdigest(),
                receipt_sha256=hashlib.sha256(receipt).hexdigest(), chunks=chunks,
                body_count=bodies, current_groups=count, remapped_groups=int(np.count_nonzero(current != low)),
                original_ancestry_passed=True)
    trial, corrected = records[1:3]
    assert trial['input_generation'] == corrected['input_generation']
    assert trial['arrays'] == corrected['arrays'], 'Original arrays changed across correction'
    if 'ownership' in trial:
        for field in ['sha256', 'receipt_sha256']:
            assert trial['ownership'][field] == corrected['ownership'][field]
    assert records[3]['input_generation'] > corrected['checkpoint_generation']
    return dict(passed=True, evaluations=records, original_arrays_identical_across_correction=True,
                complete_command_ledger=False,
                scope='Raw original body arrays; optional arrays only when present. '
                      'Authored ancestry checked when captured; no general applied-command completeness qualification.')


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('capture', type=Path)
    parser.add_argument('--require-owners', action='store_true')
    args = parser.parse_args()
    result = check(args.capture, args.require_owners)
    (args.capture / 'input-history-check.json').write_text(json.dumps(result, indent=2) + '\n')
    print(json.dumps(result, indent=2))


if __name__ == '__main__':
    main()
