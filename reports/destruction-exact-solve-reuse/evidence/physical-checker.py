#!/usr/bin/env python3
"""Compare exported post-tick observations from two identical physical inputs."""
import argparse
import hashlib
import json
import math
from pathlib import Path
import struct

REQUIRED = {'node-accelerations', 'surface-loads', 'bond-forces', 'health',
            'active-bonds', 'chunk-clusters', 'crush'}
# Existing analytic force gate in gpu_resident_stress_test.cu::unevenComponents.
# Derived floating-point responses are not serialized physical state. Even the
# unchanged baseline varies in reduction order; material state remains exact.
FORCE_SCALED_BOUND = 2e-4


def require(condition, message):
    if not condition:
        raise ValueError(message)


def compare(reference, candidate, collect_failures=False):
    failures = []
    def expect(condition, message):
        if not condition:
            if not collect_failures:
                raise ValueError(message)
            failures.append(message)
    receipts = [json.loads((p / 'receipt.json').read_text()) for p in (reference, candidate)]
    replays = [json.loads((p / 'replay.json').read_text()) for p in (reference, candidate)]
    require(all(r['status'] == 'complete' for r in receipts), 'Incomplete capture')
    require(all(r['passed'] and r['steps_per_restore'] == 1 for r in replays), 'Unqualified replay')
    require(receipts[0]['snapshot_inputs'] == receipts[1]['snapshot_inputs'], 'Physical inputs differ')
    manifests = [json.loads((p / 'observation-0.json').read_text()) for p in (reference, candidate)]
    require(manifests[0] == manifests[1], 'Observation layouts or generations differ')
    arrays = manifests[0]['arrays']
    require({a['name'] for a in arrays} == (REQUIRED if manifests[0]['destructive'] else set()), 'Missing physical observation array')
    if not manifests[0]['destructive']:
        require(any(name.endswith('.destruction') and digest == hashlib.sha256(b'').hexdigest()
                    for name, digest in receipts[0]['snapshot_inputs'].items()), 'Missing destruction observations for a destructive input')
    hashes, numerical, changed_arrays = {}, {}, {}
    for array in arrays:
        name = array['name']
        data = [(p / f'observation-0-{name}.bin').read_bytes() for p in (reference, candidate)]
        require(all(len(b) == array['count'] * array['stride'] for b in data), f'{name}: size mismatch')
        if name == 'bond-forces':
            require(len(data[0]) % 4 == 0, 'Malformed float force data')
            maximum_absolute = maximum_scaled = difference_squared = reference_squared = 0.0
            changed = 0
            for (x,), (y,) in zip(struct.iter_unpack('<f', data[0]), struct.iter_unpack('<f', data[1])):
                require(math.isfinite(x) and math.isfinite(y), 'Nonfinite bond force')
                difference = abs(x - y)
                changed += x != y
                maximum_absolute = max(maximum_absolute, difference)
                maximum_scaled = max(maximum_scaled, difference / max(1.0, abs(x), abs(y)))
                difference_squared += difference * difference
                reference_squared += x * x
            expect(maximum_scaled < FORCE_SCALED_BOUND, 'bond-forces: existing numerical bound exceeded')
            numerical[name] = dict(changed_scalars=changed, maximum_absolute=maximum_absolute,
                maximum_scaled=maximum_scaled, scaled_bound=FORCE_SCALED_BOUND,
                relative_l2=math.sqrt(difference_squared / max(reference_squared, 1e-300)),
                reference_sha256=hashlib.sha256(data[0]).hexdigest(),
                candidate_sha256=hashlib.sha256(data[1]).hexdigest())
        else:
            expect(data[0] == data[1], f'{name}: output bytes differ')
            if data[0] == data[1]:
                hashes[name] = hashlib.sha256(data[0]).hexdigest()
            else:
                changed_arrays[name] = dict(reference_sha256=hashlib.sha256(data[0]).hexdigest(),
                                           candidate_sha256=hashlib.sha256(data[1]).hexdigest())
                if name == 'health':
                    pairs = list(zip(struct.iter_unpack('<f', data[0]), struct.iter_unpack('<f', data[1])))
                    require(all(math.isfinite(x[0]) and math.isfinite(y[0]) for x, y in pairs), 'Nonfinite health')
                    changed_arrays[name].update(changed_scalars=sum(x != y for x, y in pairs),
                        maximum_absolute=max((abs(x[0] - y[0]) for x, y in pairs), default=0))
    objects = [json.loads((p / 'observation-0-objects.json').read_text()) for p in (reference, candidate)]
    require(all(o['schema'] == 1 for o in objects), 'Unsupported object schema')
    fields = ['id', 'type', 'moving', 'shape_dynamic', 'flags', 'mass', 'pose_xyz',
              'pose_xyzw', 'com_xyz', 'com_xyzw', 'inertia_xyz', 'linear_xyz', 'angular_xyz']
    require(all(o['fields'] == fields for o in objects), 'Object fields differ')
    a, b = (o['objects'] for o in objects)
    require(len(a) == len(b), 'Object count differs')
    maxima = dict(position_m=0.0, orientation_dot_error=0.0, linear_m_s=0.0, angular_rad_s=0.0)
    for x, y in zip(a, b):
        require(len(x) == len(y) == len(fields), 'Malformed object record')
        expect(x[:6] == y[:6], f'Object {x[0]} identity/role/mass differs')
        expect(x[8:11] == y[8:11], f'Object {x[0]} COM/inertia differs')
        if not x[2]:
            continue
        for key, index in [('position_m', 6), ('linear_m_s', 11), ('angular_rad_s', 12)]:
            require(len(x[index]) == len(y[index]) == 3, 'Malformed vector')
            error = math.dist(x[index], y[index])
            expect(math.isfinite(error) and error < 1e-4, f'Object {x[0]} {key} exceeds frozen bound')
            maxima[key] = max(maxima[key], error)
        require(len(x[7]) == len(y[7]) == 4, 'Malformed quaternion')
        error = abs(1 - abs(sum(u * v for u, v in zip(x[7], y[7]))))
        expect(math.isfinite(error) and error < 1e-5, f'Object {x[0]} orientation exceeds frozen bound')
        maxima['orientation_dot_error'] = max(maxima['orientation_dot_error'], error)
    for key in ['broken_bonds', 'correction_passes', 'stress_passes', 'output_clusters',
                'stress_islands', 'stress_active_nodes', 'stress_active_bonds',
                'normal_contacts', 'friction_anchors']:
        expect(replays[0]['samples'][0][key] == replays[1]['samples'][0][key], f'{key} differs')
    return dict(status='failed' if failures else 'passed', failures=failures,
                changed_arrays=changed_arrays, objects=len(a), maximum_errors=maxima, exact_array_sha256=hashes,
                numerical_arrays=numerical,
                reference=str(reference), candidate=str(candidate),
                scope='Post-tick physical observations; exact persistent state/loads, existing force and motion bounds; no timing claim')


if __name__ == '__main__':
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('reference', type=Path)
    parser.add_argument('candidate', type=Path)
    parser.add_argument('output', type=Path)
    parser.add_argument('--all-errors', action='store_true', help='Collect compatible-layout quality failures; every original gate still applies')
    args = parser.parse_args()
    require(not args.output.exists(), 'Output already exists')
    try:
        result = compare(args.reference, args.candidate, args.all_errors)
    except (ValueError, KeyError, OSError) as error:
        result = dict(status='failed', error=str(error), reference=str(args.reference), candidate=str(args.candidate))
    args.output.parent.mkdir(parents=True, exist_ok=True)
    args.output.write_text(json.dumps(result, indent=2) + '\n')
    print(result['status'], args.output)
    raise SystemExit(0 if result['status'] == 'passed' else 1)
