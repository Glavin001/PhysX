#!/usr/bin/env python3
"""CPU-only negative controls for A/B provenance and admission."""
import importlib.util
import fcntl
import json
from pathlib import Path
import tempfile
import unittest
from unittest.mock import patch

spec = importlib.util.spec_from_file_location('ab', Path(__file__).with_name('run-destruction-ab.py'))
ab = importlib.util.module_from_spec(spec)
spec.loader.exec_module(ab)


class Evidence(unittest.TestCase):
    def setUp(self):
        self.temp = tempfile.TemporaryDirectory(dir=ab.ROOT/'out')
        self.addCleanup(self.temp.cleanup)
        self.root = Path(self.temp.name)
        (self.root/'out').mkdir()
        self.config = ab.ROOT/'tools/profiles/destruction-ordinary-ab.json'
        self.arm = self.root/'A'
        self.arm.mkdir()
        for name in ('native_destruction_demo', *ab.MODULES):
            (self.arm/name).write_text(name)
        self.hashes = ab.artifacts(self.arm)
        self.campaign = {'status': 'complete', 'runs': [
            {'name': 'idle-256-plain-0', 'exit_code': 0, 'loaded_modules': dict(self.hashes)}]}

    def test_wrong_runtime_rejected_even_when_capture_succeeded(self):
        self.campaign['runs'][0]['loaded_modules'][str(self.arm/ab.MODULES[0])] = 'wrong'
        with self.assertRaisesRegex(ValueError, 'mapped module'):
            ab.verify_campaign(self.campaign, self.arm, self.hashes)

    def test_missing_maps_rejected(self):
        self.campaign['runs'][0].pop('loaded_modules')
        with self.assertRaisesRegex(ValueError, 'mapped module'):
            ab.verify_campaign(self.campaign, self.arm, self.hashes)

    def test_interrupted_capture_not_a_deadline_failure(self):
        self.campaign['status'] = 'failed'
        with self.assertRaisesRegex(ValueError, 'Incomplete campaign'):
            ab.verify_campaign(self.campaign, self.arm, self.hashes)

    def test_post_capture_artifact_change_rejected(self):
        (self.arm/ab.MODULES[0]).write_text('replacement')
        with self.assertRaisesRegex(ValueError, 'changed during capture'):
            ab.verify_campaign(self.campaign, self.arm, self.hashes)

    def test_foreign_compute_never_launches_child(self):
        output = self.root/'blocked'
        gpu = {'devices': [{'processes': [{'pid': 123, 'name': 'foreign', 'type': 'C'}]}]}
        with patch.object(ab, 'ROOT', self.root), \
             patch('sys.argv', ['ab', str(output), '--baseline', str(self.arm), '--config', str(self.config)]), \
             patch.object(ab.runner, 'gpu', return_value=gpu), \
             patch.object(ab.subprocess, 'check_output', side_effect=['test-commit', b'', b'']), \
             patch.object(ab.subprocess, 'run') as launch:
            self.assertEqual(ab.main(), 3)
            launch.assert_not_called()
        receipt = json.loads((output/'experiment.json').read_text())
        self.assertEqual(receipt['status'], 'blocked_gpu')
        self.assertEqual(receipt['experiments_completed'], 0)

    def test_busy_lock_never_launches_or_checks_gpu(self):
        output = self.root/'locked'
        with (self.root/'out/destruction-ab.lock').open('a') as owned:
            fcntl.flock(owned, fcntl.LOCK_EX | fcntl.LOCK_NB)
            with patch.object(ab, 'ROOT', self.root), \
                 patch('sys.argv', ['ab', str(output), '--baseline', str(self.arm), '--config', str(self.config)]), \
                 patch.object(ab.runner, 'gpu') as gpu, patch.object(ab.subprocess, 'run') as launch:
                with self.assertRaises(BlockingIOError):
                    ab.main()
                gpu.assert_not_called()
                launch.assert_not_called()
        receipt = json.loads((output/'experiment.json').read_text())
        self.assertEqual(receipt['status'], 'failed')
        self.assertEqual(receipt['experiments_completed'], 0)


if __name__ == '__main__':
    unittest.main()
