"""Fail-closed suite admission and physical equivalence properties; no GPU."""
import importlib.util
import json
from pathlib import Path
import tempfile
import unittest

def load(name):
    spec=importlib.util.spec_from_file_location(name,Path(__file__).with_name(name+'.py'))
    module=importlib.util.module_from_spec(spec);spec.loader.exec_module(module);return module
runner=load('run-destruction-regression');physics=load('destruction_physics_contract')

class Admission(unittest.TestCase):
    def test_missing_consumer_is_not_a_pass(self):
        with tempfile.TemporaryDirectory() as tmp:
            root=Path(tmp);(root/'build.json').write_text(json.dumps(dict(status='built_not_gpu_qualified',outputs={})))
            with self.assertRaisesRegex(ValueError,'Missing attested'):runner.validate_build(root)
    def test_changed_artifact_is_rejected(self):
        with tempfile.TemporaryDirectory() as tmp:
            root=Path(tmp);p=root/'consumer';p.write_text('changed')
            (root/'build.json').write_text(json.dumps(dict(status='built_not_gpu_qualified',outputs={str(p):'old'})))
            with self.assertRaisesRegex(ValueError,'changed'):runner.validate_build(root)
    def test_small_suite_cannot_claim_final(self):
        with tempfile.TemporaryDirectory() as tmp:
            path=Path(tmp)/'manifest.json';path.write_text(json.dumps(dict(scenarios=[])))
            with self.assertRaisesRegex(ValueError,'all 52'):runner.validate_full_manifest(path)
    def test_manifest_cannot_attest_a_different_replay(self):
        with tempfile.TemporaryDirectory() as tmp:
            prefix=Path(tmp)/'state'
            files=[Path(str(prefix)+suffix) for suffix in ('.pxbin','.destruction')]
            for p in files:p.write_bytes(b'input')
            case=dict(prefix=str(prefix),input_sha256={str(p):runner.sha(p) for p in files})
            runner.validate_snapshot_inputs(case)
            case['prefix']=str(Path(tmp)/'unattested')
            with self.assertRaisesRegex(ValueError,'actual replay'):runner.validate_snapshot_inputs(case)
    def test_canonical_partition_retains_membership_and_removed_chunks(self):
        self.assertEqual(physics.canonical_partition([12,12,5,0xffffffff]),[0,0,2,0xffffffff])
        self.assertNotEqual(physics.canonical_partition([1,1,2]),physics.canonical_partition([1,2,2]))
    def test_quaternion_sign_and_invalid_norm(self):
        self.assertEqual(physics.quaternion_error([0,0,0,1],[0,0,0,-1]),0)
        with self.assertRaises(ValueError):physics.quaternion_error([0,0,0,0],[0,0,0,1])
    def test_missing_velocity_is_not_historical_qualification(self):
        with self.assertRaisesRegex(ValueError,'Missing full motion'):physics.full_motion_error({}, {})

if __name__=='__main__':unittest.main()
