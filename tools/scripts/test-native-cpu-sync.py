#!/usr/bin/env python3
"""Check overlap accounting and incomplete-capture rejection for CPU sync reports."""
import csv
import hashlib
import json
from pathlib import Path
import runpy
import tempfile
import unittest

API = runpy.run_path(str(Path(__file__).with_name('report-native-cpu-sync.py')))


class CpuSyncReport(unittest.TestCase):
    def test_interval_union(self):
        self.assertEqual(API['union_ms']([]), 0)
        self.assertEqual(API['union_ms']([(0, 2000000), (1000000, 3000000)]), 3)
        self.assertEqual(API['union_ms']([(2000000, 3000000), (0, 1000000)]), 2)
        self.assertEqual(API['union_ms']([(0, 4000000), (1000000, 2000000)]), 4)
        with self.assertRaises(AssertionError):
            API['union_ms']([(2, 1)])

    def capture(self, root, missing_wait=False, bad_cpu=False):
        d = root / 'simulation'; d.mkdir()
        (d / 'native.summary.json').write_text(json.dumps(dict(status='completed', frames=1, seconds=1/60,
            chunks=4, bonds=2, projectiles=1)))
        with (d / 'native.frames.csv').open('w') as f:
            writer = csv.DictWriter(f, fieldnames=['stress_passes', 'resim_passes', 'stress_converged',
                'correction_status', 'complete_step_ms', 'bodies', 'awake_bodies'])
            writer.writeheader(); writer.writerow(dict(stress_passes=2, resim_passes=1, stress_converged=1,
                correction_status=0, complete_step_ms=10, bodies=3, awake_bodies=2))
        rows = [('correctedCollisionSolve', 3000000, 9000000, -1),
                ('task.bodyDmaWait', 0, 1000000, .9),
                ('task.bodyDmaWait', 4000000, 5000000, .9),
                ('task.bodyStatusWork', 6000000, 8000000, -1 if bad_cpu else 2),
                ('task.bodyStatusWork', 7000000, 9000000, 2),
                ('task.sleepCommit', 9500000, 9600000, .1)]
        if missing_wait: rows.pop(2)
        with (d / 'native.phases.csv').open('w') as f:
            writer = csv.writer(f)
            writer.writerow(['step', 'phase', 'start_ns', 'end_ns', 'thread_cpu_ms', 'accepted_step'])
            for name, a, b, cpu in rows:
                writer.writerow([0, 'GpuDestruction.' + name, a, b, cpu, 1])
        (root / 'capture.json').write_text(json.dumps(dict(status='complete', files={
            f.name: hashlib.sha256(f.read_bytes()).hexdigest() for f in d.iterdir()})))

    def test_complete_overlapping_workers_and_cross_thread_replay(self):
        with tempfile.TemporaryDirectory() as t:
            root = Path(t); self.capture(root); API['report'](root)
            report = json.loads((root / 'cpu-sync.json').read_text())
            measurements = report['selections']['Largest replay']['measurements']
            body = next(m for m in measurements if m['scope'] == 'bodyStatusWork')
            self.assertEqual(body['replay_ms'], 3)
            self.assertEqual(body['cpu_ms'], 4)
            self.assertEqual(body['before_ms'], 0)
            sleep = next(m for m in measurements if m['scope'] == 'sleepCommit')
            self.assertEqual(sleep['after_ms'], .1)

    def test_missing_wait_or_cpu_clock_rejected(self):
        for kwargs in [dict(missing_wait=True), dict(bad_cpu=True)]:
            with tempfile.TemporaryDirectory() as t:
                root = Path(t); self.capture(root, **kwargs)
                with self.assertRaises(AssertionError): API['report'](root)

    def test_modified_evidence_rejected(self):
        with tempfile.TemporaryDirectory() as t:
            root = Path(t); self.capture(root)
            with (root / 'simulation/native.phases.csv').open('a') as f: f.write('\n')
            with self.assertRaises(AssertionError): API['report'](root)


if __name__ == '__main__':
    unittest.main()
