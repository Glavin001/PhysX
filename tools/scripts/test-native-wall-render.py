"""CPU-only validation; synthetic schema data is never rendered or presented as physics."""
import contextlib
import copy
import importlib.util
import io
import json
import math
from pathlib import Path
import sys
import tempfile
import unittest
from unittest.mock import patch

sys.dont_write_bytecode = True
from native_wall_blender import position, rotation, validate_capture

spec = importlib.util.spec_from_file_location('wall_launcher', Path(__file__).with_name('render-native-wall.py'))
launcher = importlib.util.module_from_spec(spec)
spec.loader.exec_module(launcher)


def synthetic():
    bodies = [{'id': i, 'shape': 'box', 'half_extents': [1, 2, 3], 'color': [.5, .4, .3]} for i in range(9)]
    bodies += [{'id': 9, 'shape': 'sphere', 'radius': .6, 'color': [.1, .2, .3]}]
    return {'schema': 'physx.native-wall-capture', 'version': 1, 'backend': 'cumetal',
            'status': 'completed', 'failure': '', 'timestep': 1/60,
            'metadata': {'width': 3, 'height': 3, 'requested_frames': 2, 'fps': 60, 'ground_y': 0, 'device': 'synthetic test only'},
            'summary': {'frames': 2, 'bonds': 12, 'broken_bonds': 0, 'localized_damage': False},
            'bodies': bodies, 'frames': [{'frame': f, 'time': (f+1)/60, 'fractures': [],
                                        'bodies': [{'id': b['id'], 'position': [1, 2, 3], 'rotation': [0, 0, 0, 1], 'visible': True} for b in bodies]}
                                       for f in range(2)]}


class Validation(unittest.TestCase):
    def test_accepted_diagnostic(self):
        validate_capture(synthetic(), diagnostic=True)

    def test_showcase_requires_actual_localized_damage(self):
        with self.assertRaises(ValueError): validate_capture(synthetic())

    def test_failed_capture_rejected_even_diagnostic(self):
        data = synthetic(); data['status'] = 'failed'
        with self.assertRaises(ValueError): validate_capture(data, True)

    def test_missing_duplicate_or_nonfinite_pose_rejected(self):
        for mutation in ('missing', 'duplicate', 'nan', 'quaternion'):
            data = synthetic(); poses = data['frames'][0]['bodies']
            if mutation == 'missing': poses.pop()
            if mutation == 'duplicate': poses[0]['id'] = 1
            if mutation == 'nan': poses[0]['position'][0] = float('nan')
            if mutation == 'quaternion': poses[0]['rotation'] = [0, 0, 0, 0]
            with self.subTest(mutation=mutation), self.assertRaises(ValueError): validate_capture(data, True)

    def test_no_interpolated_or_repeated_events(self):
        data = synthetic(); data['frames'][1]['time'] += .001
        with self.assertRaises(ValueError): validate_capture(data, True)
        data = synthetic(); event = {'bond_id': 1, 'chunk0': 0, 'chunk1': 1}
        for frame in data['frames']: frame['fractures'] = [copy.deepcopy(event)]
        data['summary']['broken_bonds'] = 2
        with self.assertRaises(ValueError): validate_capture(data, True)

    def test_basis_is_right_handed_and_quaternion_conjugation(self):
        self.assertEqual(position([1, 2, 3]), (1, -3, 2))
        self.assertEqual(rotation([0, 0, 0, 1]), (1, 0, 0, 0))
        # PhysX +90 degrees about Y maps +X to -Z. In Blender this
        # becomes +90 degrees about Z, mapping +X to +Y.
        w, x, y, z = rotation([0, math.sqrt(.5), 0, math.sqrt(.5)])
        transformed_x = (1-2*(y*y+z*z), 2*(x*y+w*z), 2*(x*z-w*y))
        for actual, expected in zip(transformed_x, position([0, 0, -1])):
            self.assertAlmostEqual(actual, expected)

    def test_engine_plan_is_explicit_and_gpu_is_default(self):
        root = Path(__file__).resolve().parents[2]
        base = root / 'out/tests/native-wall-render'
        base.mkdir(parents=True, exist_ok=True)
        with tempfile.TemporaryDirectory(dir=base) as directory:
            directory = Path(directory)
            capture = directory / 'synthetic.json'
            capture.write_text(json.dumps(synthetic()))
            for engine in (None, 'eevee', 'cycles-metal', 'cycles-cpu'):
                args = [str(capture), '--output', str(directory / 'unused'), '--diagnostic', '--dry-run', '--render']
                if engine:
                    args += ['--engine', engine]
                output = io.StringIO()
                with contextlib.redirect_stdout(output), patch.object(launcher, 'tool', return_value='/installed/Blender'), patch.object(launcher.subprocess, 'run', side_effect=AssertionError('dry run launched a subprocess')):
                    self.assertEqual(launcher.main(args), 0)
                plan = json.loads(output.getvalue())
                self.assertEqual(plan['engine'], engine or 'eevee')
                self.assertEqual(plan['render_device'], 'CPU' if engine == 'cycles-cpu' else 'GPU')
                self.assertEqual('--gpu-backend' in plan['commands']['render'], engine != 'cycles-cpu')
                self.assertFalse((directory / 'unused').exists())

    def test_readonly_plan_and_escape_rejection(self):
        root = Path(__file__).resolve().parents[2]
        base = root / 'out/tests/native-wall-render'
        base.mkdir(parents=True, exist_ok=True)
        with tempfile.TemporaryDirectory(dir=base) as directory:
            directory = Path(directory); capture = directory / 'synthetic.json'
            capture.write_text(json.dumps(synthetic()))
            output = directory / 'not-created'
            before = set(directory.rglob('*'))
            with patch.object(launcher.subprocess, 'run', side_effect=AssertionError('no subprocess in read-only plan')):
                with contextlib.redirect_stdout(io.StringIO()):
                    self.assertEqual(launcher.main([str(capture), '--output', str(output), '--diagnostic', '--dry-run']), 0)
                with self.assertRaises(ValueError):
                    launcher.main([str(capture), '--output', '/Applications/not-authorized', '--diagnostic'])
                redirect = directory / 'escape'; redirect.symlink_to('/Applications', target_is_directory=True)
                with self.assertRaises(ValueError):
                    launcher.main([str(capture), '--output', str(redirect / 'not-authorized'), '--diagnostic'])
                redirect.unlink()
            self.assertEqual(before, set(directory.rglob('*')))
            self.assertFalse(output.exists())


if __name__ == '__main__':
    unittest.main()
