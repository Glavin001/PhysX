#!/usr/bin/env python3
"""Check that timing reports reject incomplete/mislabelled measurements."""
import csv
import gzip
import json
from pathlib import Path
import runpy
import tempfile
import unittest

API = runpy.run_path(str(Path(__file__).with_name('analyze-native-destruction-phases.py')))


class PhaseAnalysis(unittest.TestCase):
    def setUp(self):
        self.temp = tempfile.TemporaryDirectory()
        self.root = Path(self.temp.name)
        (self.root / 'native.summary.json').write_text(json.dumps(dict(status='completed', frames=2, seconds=2/60, corrections=1)))
        self.write('native.frames.csv', ['step', 'stress_converged', 'correction_status', 'resim_passes', 'physics_step_ms', 'frame_host_ms'],
                   [[0, 1, 0, 0, 10, 11], [1, 1, 0, 1, 10, 11]])
        host = []
        for step in range(2):
            for name in sorted(API['ALWAYS'] | (API['CORRECTION'] if step else set())):
                host.append([step, API['PREFIX'] + name, .1, 1])
        self.write('native.phases.csv', ['step', 'phase', 'host_wall_ms', 'accepted_step'], host)
        self.rows = [[step, API['PREFIX'] + 'cuda.' + name, .02, 1]
                     for step in range(2) for name in sorted(API['CUDA_STAGES'])]
        self.save_device()

    def tearDown(self):
        self.temp.cleanup()

    def write(self, name, header, rows):
        with (self.root / name).open('w') as stream:
            writer = csv.writer(stream)
            writer.writerow(header)
            writer.writerows(rows)

    def save_device(self):
        self.write('native.phases.csv.device.csv', ['step', 'phase', 'cuda_elapsed_ms', 'accepted_step'], self.rows)

    def test_complete(self):
        result = API['analyze'](self.root)
        self.assertAlmostEqual(result['cuda_stages']['total']['mean_ms'], .1)
        self.assertEqual(result['cuda_stages']['total']['samples'], 2)
        self.assertEqual(result['frames'], 2)

    def test_optional_allocation_is_separate_and_retries_validated(self):
        self.rows += [[0, API['PREFIX'] + 'cuda.motionAllocation', .03, 1],
                      [1, API['PREFIX'] + 'cuda.motionAllocation', .04, 1],
                      [1, API['PREFIX'] + 'cuda.motionAllocationRetry', .06, 1]]
        self.save_device()
        stages = API['analyze'](self.root)['cuda_stages']
        self.assertAlmostEqual(stages['total']['mean_ms'], .1)
        self.assertAlmostEqual(stages['optional_phases']['motionAllocation']['mean_ms'], .035)
        self.assertAlmostEqual(stages['optional_phases']['motionAllocationRetry']['mean_ms'], .03)
        self.rows.append(self.rows[-1][:])
        self.save_device()
        with self.assertRaisesRegex(ValueError, 'duplicate CUDA'):
            API['analyze'](self.root)

    def test_combined_preparation_wait_is_attributed(self):
        before = API['analyze'](self.root)['unmeasured_interval_mean_ms']
        with (self.root / 'native.phases.csv').open('a') as stream:
            csv.writer(stream).writerow([1, 'GpuDestruction.preparationCompletion', 2.0, 1])
        after = API['analyze'](self.root)['unmeasured_interval_mean_ms']
        self.assertAlmostEqual(before - after, 1.0)

    def test_compressed_capture(self):
        for name in ['native.frames.csv', 'native.phases.csv', 'native.phases.csv.device.csv']:
            p = self.root / name
            with gzip.open(str(p) + '.gz', 'wb') as target:
                target.write(p.read_bytes())
            p.unlink()
        self.assertEqual(API['analyze'](self.root)['frames'], 2)

    def test_legacy_host_only(self):
        (self.root / 'native.phases.csv.device.csv').unlink()
        self.assertIsNone(API['analyze'](self.root)['cuda_stages'])

    def test_missing_duplicate_and_invalid_gpu_records(self):
        original = [row[:] for row in self.rows]
        bad = [original[:-1], original + [original[0]], []]
        for column, value in [(0, 2), (1, 'GpuDestruction.cuda.unknown'), (2, -1), (2, 'nan'), (3, 0)]:
            altered = [row[:] for row in original]
            altered[0][column] = value
            bad.append(altered)
        for rows in bad:
            with self.subTest(rows=rows):
                self.rows = rows
                self.save_device()
                with self.assertRaises(ValueError):
                    API['analyze'](self.root)

    def test_two_stress_evaluations(self):
        self.write('native.frames.csv', ['step', 'stress_converged', 'correction_status', 'resim_passes', 'physics_step_ms', 'frame_host_ms', 'stress_passes'],
                   [[0, 1, 0, 0, 10, 11, 1], [1, 1, 0, 1, 10, 11, 2]])
        self.rows += [row[:] for row in self.rows if row[0] == 1]
        self.save_device()
        with (self.root / 'native.phases.csv').open('a') as stream:
            for name in sorted(API['ALWAYS']):
                csv.writer(stream).writerow([1, API['PREFIX'] + name, .1, 1])
        result = API['analyze'](self.root)
        self.assertAlmostEqual(result['cuda_stages']['total']['mean_ms'], .15)
        self.rows.append(self.rows[-1][:])
        self.save_device()
        with self.assertRaisesRegex(ValueError, 'duplicate CUDA'):
            API['analyze'](self.root)
        self.rows = self.rows[:-2]
        self.save_device()
        with self.assertRaisesRegex(ValueError, 'missing stress evaluation'):
            API['analyze'](self.root)

    def test_host_child_cannot_exceed_parent(self):
        with (self.root / 'native.phases.csv').open('a') as stream:
            writer = csv.writer(stream)
            writer.writerow([0, 'GpuDestruction.finishDetail.waitForGpu', .09, 1])
            writer.writerow([0, 'GpuDestruction.finishDetail.reserveBodies', .1, 1])
        with self.assertRaisesRegex(ValueError, 'exceeds its parent'):
            API['analyze'](self.root)


if __name__ == '__main__':
    unittest.main()
