#!/usr/bin/env python3
"""Synthetic checker challenges, not physical simulation or production mutation testing."""
import importlib.util
import json
import math
from pathlib import Path
import struct
import tempfile

ROOT = Path(__file__).resolve().parents[2]
HERE = Path(__file__).resolve().parent


def load(name, relative):
    spec = importlib.util.spec_from_file_location(name, ROOT / relative)
    module = importlib.util.module_from_spec(spec)
    spec.loader.exec_module(module)
    return module


def main():
    obs = load('observation_tests', 'tools/diagnostics/destruction-snapshot/test-compare-observations.py')
    prefix = load('prefix_tests', 'tools/scripts/test-native-prefix.py')
    results = []
    for name in ('identical', 'generation_only', 'load_one_ulp', 'force_small', 'force_large', 'position_large'):
        case = obs.ObservationComparison()
        case.setUp()
        try:
            if name == 'generation_only':
                for folder, generation in ((case.a, 1), (case.b, 2)):
                    p = folder / 'observation-0.json'
                    data = json.loads(p.read_text()); data['topology_generation'] = generation
                    p.write_text(json.dumps(data))
            elif name == 'load_one_ulp':
                (case.a / 'observation-0-surface-loads.bin').write_bytes(struct.pack('<f', 1.0))
                (case.b / 'observation-0-surface-loads.bin').write_bytes(struct.pack('<I', 0x3f800001))
            elif name in ('force_small', 'force_large'):
                (case.b / 'observation-0-bond-forces.bin').write_bytes(struct.pack('<f', 1e-5 if name == 'force_small' else 1e-3))
            elif name == 'position_large':
                case.object_data['objects'][0][6][0] = .001
                case.write(case.b, 'observation-0-objects.json', case.object_data)
            try:
                result = obs.module.compare(case.a, case.b)
                results.append(dict(challenge=name, checker='snapshot', result=result['status']))
            except ValueError as error:
                results.append(dict(challenge=name, checker='snapshot', result='rejected', reason=str(error)))
        finally:
            case.doCleanups()
    with tempfile.TemporaryDirectory() as tmp:
        a, b = Path(tmp) / 'actual', Path(tmp) / 'reference'
        prefix.fixture(a, ordinary=True); prefix.fixture(b, ordinary=True)
        path = a / 'native.twstate'
        raw = bytearray(path.read_bytes())
        # First record: 44-byte header, tag + frame/count/id (13), then xyz (12).
        # Change identity quaternion to a unit 90-degree rotation; positions unchanged.
        struct.pack_into('<4f', raw, 44 + 13 + 12, 0, 0, math.sqrt(.5), math.sqrt(.5))
        path.write_bytes(raw)
        result = prefix.prefix.verify(a, b, 32)
        results.append(dict(challenge='projectile_orientation_90_degrees', checker='continuous-prefix-32',
                            result=result['status'], max_position_error_m=result['max_position_error_m'],
                            limitation='Synthetic projectile receipt; proves quaternion is ignored, not an actual dynamics failure.'))
    expected = ['passed', 'rejected', 'rejected', 'passed', 'rejected', 'rejected', 'passed']
    if [row['result'] for row in results] != expected:
        raise RuntimeError('Checker behavior changed; review results before refreshing audit')
    output = dict(schema=1, status='audit_expectations_confirmed', synthetic=True,
                  runtime_physics_qualified=False, challenges=results)
    (HERE / 'checker-challenges.json').write_text(json.dumps(output, indent=2) + '\n')
    print(json.dumps(output, indent=2))


if __name__ == '__main__':
    main()
