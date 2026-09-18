#!/usr/bin/env python3
import importlib.util
import json
from pathlib import Path
import shutil
import struct
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
        sample = dict.fromkeys(counters,0); sample['stress_passes'] = 1
        self.write(self.a, 'replay.json', dict(passed=True, steps_per_restore=1, samples=[sample]))
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

    def test_generation_change_is_diagnostic(self):
        for p,generation in ((self.a,1),(self.b,19)):
            path=p/'observation-0.json';data=json.loads(path.read_text());data['topology_generation']=generation
            self.write(p,path.name,data)
        self.assertEqual(module.compare(self.a,self.b)['status'],'passed')
        with self.assertRaisesRegex(ValueError,'generations'):
            module.compare(self.a,self.b,strict_implementation=True)

    def test_labels_are_canonical_but_connectivity_is_not_waived(self):
        for p in (self.a,self.b):
            path=p/'observation-0.json';data=json.loads(path.read_text())
            next(a for a in data['arrays'] if a['name']=='chunk-clusters')['count']=3
            self.write(p,path.name,data)
        (self.a/'observation-0-chunk-clusters.bin').write_bytes(struct.pack('<3I',0,0,2))
        (self.b/'observation-0-chunk-clusters.bin').write_bytes(struct.pack('<3I',2,2,1))
        self.assertEqual(module.compare(self.a,self.b)['status'],'passed')
        with self.assertRaisesRegex(ValueError,'output bytes'):
            module.compare(self.a,self.b,strict_implementation=True)
        (self.b/'observation-0-chunk-clusters.bin').write_bytes(struct.pack('<3I',2,1,1))
        with self.assertRaisesRegex(ValueError,'connectivity'):module.compare(self.a,self.b)

    def test_nonfinite_health_rejected_even_when_equal(self):
        for p in (self.a,self.b):(p/'observation-0-health.bin').write_bytes(struct.pack('<f',float('nan')))
        with self.assertRaisesRegex(ValueError,'nonfinite'):module.compare(self.a,self.b)

    def test_work_counters_are_diagnostic_but_fracture_is_physical(self):
        path=self.b/'replay.json';data=json.loads(path.read_text());data['samples'][0]['normal_contacts']=2
        self.write(self.b,path.name,data)
        self.assertEqual(module.compare(self.a,self.b)['status'],'passed')
        with self.assertRaisesRegex(ValueError,'normal_contacts'):module.compare(self.a,self.b,strict_implementation=True)
        data['samples'][0]['broken_bonds']=1;self.write(self.b,path.name,data)
        with self.assertRaisesRegex(ValueError,'broken_bonds'):module.compare(self.a,self.b)

    def test_invalid_quaternion_rejected(self):
        self.object_data['objects'][0][7]=[0,0,0,0]
        self.write(self.b,'observation-0-objects.json',self.object_data)
        with self.assertRaisesRegex(ValueError,'quaternion'):module.compare(self.a,self.b)

    def test_quaternion_sign_equivalence(self):
        self.object_data['objects'][0][7]=[0,0,0,-1]
        self.write(self.b,'observation-0-objects.json',self.object_data)
        self.assertEqual(module.compare(self.a,self.b)['status'],'passed')

    def test_derived_force_roundoff_reported(self):
        (self.b / 'observation-0-bond-forces.bin').write_bytes(struct.pack('<f', 1e-5))
        result = module.compare(self.a, self.b)
        self.assertEqual(result['numerical_arrays']['bond-forces']['changed_scalars'], 1)
        self.assertGreater(result['numerical_arrays']['bond-forces']['maximum_scaled'], 0)

    def test_force_outside_existing_bound_rejected(self):
        (self.b / 'observation-0-bond-forces.bin').write_bytes(struct.pack('<f', 1e-3))
        with self.assertRaisesRegex(ValueError, 'numerical bound'):
            module.compare(self.a, self.b)

    def test_nonfinite_force_rejected(self):
        (self.b / 'observation-0-bond-forces.bin').write_bytes(struct.pack('<f', float('nan')))
        with self.assertRaisesRegex(ValueError, 'Nonfinite bond force'):
            module.compare(self.a, self.b)

    def test_collect_failures_preserves_all_quality_gates(self):
        (self.b / 'observation-0-bond-forces.bin').write_bytes(struct.pack('<f', 1e-3))
        (self.b / 'observation-0-health.bin').write_bytes(struct.pack('<f', 1e-6))
        self.object_data['objects'][0][6][0] = .001
        self.write(self.b, 'observation-0-objects.json', self.object_data)
        result = module.compare(self.a, self.b, collect_failures=True)
        self.assertEqual(result['status'], 'failed')
        self.assertEqual(len(result['failures']), 3)
        for name in ('bond-forces', 'health', 'position_m'):
            self.assertTrue(any(name in message for message in result['failures']))
        self.assertNotIn('health', result['exact_array_sha256'])
        self.assertEqual(result['changed_arrays']['health']['changed_scalars'], 1)
        self.assertGreater(result['changed_arrays']['health']['maximum_absolute'], 0)
        self.assertGreater(result['maximum_errors']['position_m'], 1e-4)
        with self.assertRaisesRegex(ValueError, 'numerical bound'):
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

    def test_static_pose_regression_is_not_skipped(self):
        self.object_data['objects'][0][2] = 0
        self.write(self.a, 'observation-0-objects.json', self.object_data)
        self.object_data['objects'][0][6][0] = .001
        self.write(self.b, 'observation-0-objects.json', self.object_data)
        with self.assertRaisesRegex(ValueError, 'position_m'):
            module.compare(self.a, self.b)

    def test_invalid_identical_mass_is_rejected(self):
        self.object_data['objects'][0][5] = float('inf')
        for p in (self.a,self.b):self.write(p, 'observation-0-objects.json', self.object_data)
        with self.assertRaisesRegex(ValueError, 'Invalid object mass'):
            module.compare(self.a, self.b)

    def test_com_quaternion_sign_equivalence(self):
        self.object_data['objects'][0][9] = [0,0,0,-1]
        self.write(self.b, 'observation-0-objects.json', self.object_data)
        self.assertEqual(module.compare(self.a,self.b)['status'], 'passed')

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
