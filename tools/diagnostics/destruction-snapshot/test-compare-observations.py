#!/usr/bin/env python3
import importlib.util
import json
from pathlib import Path
import shutil
import tempfile
import unittest

spec = importlib.util.spec_from_file_location('observations', Path(__file__).with_name('compare-observations.py'))
module = importlib.util.module_from_spec(spec)
spec.loader.exec_module(module)


class ObservationComparison(unittest.TestCase):
    def setUp(self):
        self.temp = tempfile.TemporaryDirectory()
        self.addCleanup(self.temp.cleanup)
        self.a, self.b = (Path(self.temp.name) / x for x in ('a', 'b'))
        self.a.mkdir()
        self.write(self.a, 'receipt.json', dict(status='complete', snapshot_inputs={'state.destruction': 'fixed'}))
        counters = ['broken_bonds', 'correction_passes', 'stress_passes', 'output_clusters',
                    'stress_islands', 'stress_active_nodes', 'stress_active_bonds',
                    'normal_contacts', 'friction_anchors']
        self.write(self.a, 'replay.json', dict(passed=True, steps_per_restore=1, samples=[dict.fromkeys(counters, 0)]))
        names = ['node-accelerations', 'surface-loads', 'bond-forces', 'health',
                 'active-bonds', 'chunk-clusters', 'crush']
        self.write(self.a, 'observation-0.json', dict(destructive=True,
            arrays=[dict(name=n, count=1, stride=4) for n in names]))
        for name in names:
            (self.a / f'observation-0-{name}.bin').write_bytes(bytes(4))
        fields = ['id', 'type', 'moving', 'shape_dynamic', 'flags', 'mass', 'pose_xyz',
                  'pose_xyzw', 'com_xyz', 'com_xyzw', 'inertia_xyz', 'linear_xyz', 'angular_xyz']
        self.object_data = dict(schema=1, fields=fields, objects=[
            [1, 2, 1, 0, 0, 1, [0, 0, 0], [0, 0, 0, 1], [0, 0, 0],
             [0, 0, 0, 1], [1, 1, 1], [0, 0, 0], [0, 0, 0]]])
        self.write(self.a, 'observation-0-objects.json', self.object_data)
        shutil.copytree(self.a, self.b)

    @staticmethod
    def write(directory, name, data):
        (directory / name).write_text(json.dumps(data))

    def test_equal_outputs(self):
        self.assertEqual(module.compare(self.a, self.b)['status'], 'passed')

    def test_changed_health_rejected(self):
        (self.b / 'observation-0-health.bin').write_bytes(b'\1\0\0\0')
        with self.assertRaisesRegex(ValueError, 'health'):
            module.compare(self.a, self.b)

    def test_changed_position_rejected(self):
        self.object_data['objects'][0][6][0] = .001
        self.write(self.b, 'observation-0-objects.json', self.object_data)
        with self.assertRaisesRegex(ValueError, 'position_m'):
            module.compare(self.a, self.b)

    def test_changed_mass_rejected(self):
        self.object_data['objects'][0][5] = 2
        self.write(self.b, 'observation-0-objects.json', self.object_data)
        with self.assertRaisesRegex(ValueError, 'mass'):
            module.compare(self.a, self.b)

    def test_missing_objects_rejected(self):
        (self.b / 'observation-0-objects.json').unlink()
        with self.assertRaises(FileNotFoundError):
            module.compare(self.a, self.b)

    def test_rigid_only_requires_empty_destruction_input(self):
        for p in (self.a, self.b):
            self.write(p, 'observation-0.json', dict(destructive=False, arrays=[]))
        with self.assertRaisesRegex(ValueError, 'destructive input'):
            module.compare(self.a, self.b)
        import hashlib
        for p in (self.a, self.b):
            self.write(p, 'receipt.json', dict(status='complete',
                snapshot_inputs={'state.destruction': hashlib.sha256(b'').hexdigest()}))
        self.assertEqual(module.compare(self.a, self.b)['status'], 'passed')


if __name__ == '__main__':
    unittest.main()
