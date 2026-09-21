#!/usr/bin/env python3
"""Negative tests of the prefix verifier; synthetic data is not a physics oracle."""
import copy
import csv
import importlib.util
import json
from pathlib import Path
import struct
import tempfile
import unittest

spec=importlib.util.spec_from_file_location('prefix',Path(__file__).with_name('verify-native-prefix.py'))
prefix=importlib.util.module_from_spec(spec);spec.loader.exec_module(prefix)


def write_json(path,data):path.write_text(json.dumps(data))


def fixture(path):
    path.mkdir()
    summary={name:False for name in prefix.PHYSICAL_FIELDS}
    summary.update(status='completed',frames=32,chunks=444,bonds=896,projectiles=1,
                   record_fps=60,correction_limit=1,direct_gpu_mode=True,
                   motion_audit_enabled=True,motion_trace_enabled=True,
                   max_motion_position_error=0,max_cluster_com_error=0)
    write_json(path/'native.summary.json',summary)
    write_json(path/'quality.json',dict(all_stress_steps_converged=True,max_cluster_com_error=0,frozen_identity_gate_passed=True))
    write_json(path/'capture.json',dict(config_sha256='synthetic',command=['synthetic','--stress-iterations','8192'],exit_code=0,artifacts={'synthetic':'not-a-real-binary'}))
    fields=['step','resim_passes','stress_converged','stress_passes','bonds_broken','post_correction_bonds_broken']
    with (path/'native.frames.csv').open('w') as f:
        writer=csv.DictWriter(f,fieldnames=fields);writer.writeheader()
        for step in range(32):writer.writerow(dict(step=step,resim_passes=0,stress_converged=1,stress_passes=1,bonds_broken=0,post_correction_bonds_broken=0))
    fields=list(prefix.IDENTITY_FIELDS)+[p+a for p in ['render_','physics_','com_'] for a in 'xyz']
    with (path/'native.motion.csv').open('w') as f:
        writer=csv.DictWriter(f,fieldnames=fields);writer.writeheader()
        for step in range(32):
            for chunk in range(444):
                row={k:0 for k in fields};row.update(step=step,chunk=chunk,root=0,cluster_chunks=444,supported=1);writer.writerow(row)
    with (path/'native.twstate').open('wb') as f:
        f.write(b'TWSTATE1'+struct.pack('<7I2f',2,60,32,960,540,1,0,32/60,0))
        for step in range(32):f.write(struct.pack('<B3I7fB',2,step,1,444,0,0,0,0,0,0,1,0))
        f.write(b'\xff')


def mutate_row(path,index,field,value):
    with path.open() as f:rows=list(csv.DictReader(f));fields=list(rows[0])
    rows[index][field]=str(value)
    with path.open('w') as f:
        writer=csv.DictWriter(f,fieldnames=fields);writer.writeheader();writer.writerows(rows)


class PrefixTests(unittest.TestCase):
    def setUp(self):
        self.temp=tempfile.TemporaryDirectory();root=Path(self.temp.name)
        self.actual=root/'actual';self.reference=root/'reference';fixture(self.actual);fixture(self.reference)
    def tearDown(self):self.temp.cleanup()
    def verify(self):return prefix.verify(self.actual,self.reference,32)
    def test_unchanged(self):self.assertEqual(self.verify()['status'],'passed')
    def test_version_three_render_groups(self):
        # The current writer adds a group after every pose. Compare against
        # the v2 reference to catch stream misalignment across many frames.
        with (self.actual/'native.twstate').open('wb') as f:
            f.write(b'TWSTATE1'+struct.pack('<7I2f',3,60,32,960,540,1,0,32/60,0))
            for step in range(32):
                f.write(struct.pack('<B3I7fBI',2,step,1,444,0,0,0,0,0,0,1,0,step))
            f.write(b'\xff')
        self.assertEqual(self.verify()['status'],'passed')
    def test_exact_identity(self):
        mutate_row(self.actual/'native.motion.csv',29*444+12,'root',12)
        self.assertEqual(self.verify()['first_difference'],dict(step=29,chunk=12,kind='topology_identity'))
    def test_motion_tolerance(self):
        mutate_row(self.actual/'native.motion.csv',17*444+9,'physics_x',.002)
        mutate_row(self.actual/'native.motion.csv',17*444+9,'render_x',.002)
        self.assertEqual(self.verify()['first_difference']['step'],17)
    def test_nonfinite(self):
        mutate_row(self.actual/'native.motion.csv',10,'com_x','nan')
        with self.assertRaisesRegex(ValueError,'Non-finite'):self.verify()
    def test_missing_identity(self):
        mutate_row(self.actual/'native.motion.csv',10,'chunk',11)
        with self.assertRaisesRegex(ValueError,'Missing/duplicate'):self.verify()
    def test_unconverged(self):
        mutate_row(self.actual/'native.frames.csv',5,'stress_converged',0)
        with self.assertRaisesRegex(ValueError,'Unconverged'):self.verify()
    def test_mode_mismatch(self):
        path=self.reference/'native.summary.json';data=json.loads(path.read_text());data['sleeping']=True;write_json(path,data)
        with self.assertRaisesRegex(ValueError,'physical setting'):self.verify()
    def test_changed_solver_settings(self):
        path=self.reference/'capture.json';data=json.loads(path.read_text());data['command'][-1]='4096';write_json(path,data)
        with self.assertRaisesRegex(ValueError,'command settings'):self.verify()
    def test_stress_observation_keeps_physical_gate(self):
        path=self.actual/'capture.json';data=json.loads(path.read_text())
        data['command']+=['--trace-stress','1'];write_json(path,data)
        self.assertEqual(self.verify()['status'],'passed')
        mutate_row(self.actual/'native.frames.csv',5,'bonds_broken',1)
        self.assertEqual(self.verify()['first_difference']['kind'],'bonds_broken')
    def test_unqualified_reference(self):
        path=self.reference/'quality.json';data=json.loads(path.read_text());data['frozen_identity_gate_passed']=False;write_json(path,data)
        with self.assertRaisesRegex(ValueError,'frozen identity'):self.verify()


if __name__=='__main__':unittest.main()
