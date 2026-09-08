#!/usr/bin/env python3
"""Ensure generic comparisons cannot manufacture workload or quality claims."""
import copy
import importlib.util
import json
from pathlib import Path
import tempfile
import unittest

spec=importlib.util.spec_from_file_location('comparison',Path(__file__).with_name('compare-vibe-consumer-bench.py'))
m=importlib.util.module_from_spec(spec);spec.loader.exec_module(m)

class Comparison(unittest.TestCase):
    def setUp(self):
        self.tmp=tempfile.TemporaryDirectory();self.addCleanup(self.tmp.cleanup)
        self.root=Path(self.tmp.name)

    def capture(self,name,peak=20):
        path=self.root/name;path.mkdir()
        rows=[]
        for tick,ms in enumerate([peak,peak/2]):
            rows.append(dict(tick=tick,complete_step_ms=ms,commands_and_pre_step_ms=0,
                native_physics_and_destruction_ms=ms,game_observation_events_ms=0,
                accepted_status_and_snapshots_ms=0,native_corrections=tick,
                native_counts={'native_stress_passes':1+tick},broken_bonds=tick,
                normal_contacts=tick,fragment_bodies=tick,awake_fragment_bodies=tick))
        report=dict(status='complete',instrumented=False,buildings=1,chunks=4,bonds=3,
            steps=2,seconds=2/60,waves=1,projectiles=1,direct_gpu_api=False,sleeping=True,
            max_correction=1,max_stress_passes=2,timestep_seconds=1/60,iterations_max=8192,
            tolerance=1e-5,timing_scope='complete',peak_step=rows[0],unique_broken_bonds=1,
            phases_ms={'complete_step_ms':{'mean':peak*.75}})
        (path/'steps.json').write_text(json.dumps(rows));(path/'report.json').write_text(json.dumps(report))
        (path/'commands.json').write_text('[{"tick":1}]')
        return path

    def test_repeated_controls_preserve_first_step_and_avoid_invented_claims(self):
        controls=[self.capture('a',20),self.capture('b',30)]
        m.generate(controls,[self.capture('c',24)],self.root/'report',title='Scheduling test')
        text=(self.root/'report/report.md').read_text()
        self.assertIn('20.0%',text);self.assertIn('30.000 (0)',text)
        self.assertIn('baseline-2',text);self.assertIn('# Scheduling test',text)
        self.assertNotIn('tests pass',text);self.assertNotIn('Startup becomes',text)
        self.assertNotIn('contact-report repair',text)

    def test_changed_commands_fail_before_report_publication(self):
        a=self.capture('a');b=self.capture('b');(b/'commands.json').write_text('[]')
        with self.assertRaisesRegex(AssertionError,'commands changed'):m.generate([a],[b],self.root/'report')
        self.assertFalse((self.root/'report').exists())

    def test_instrumented_or_malformed_capture_fails(self):
        a=self.capture('a');report=json.loads((a/'report.json').read_text())
        report['instrumented']=True;(a/'report.json').write_text(json.dumps(report))
        with self.assertRaises(AssertionError):m.load(a)
        report['instrumented']=False;(a/'report.json').write_text(json.dumps(report))
        original=json.loads((a/'steps.json').read_text())
        for field,value in [('native_physics_and_destruction_ms',99),('complete_step_ms',float('inf')),
                            ('complete_step_ms',-1),('native_corrections',2)]:
            rows=copy.deepcopy(original);rows[1][field]=value;(a/'steps.json').write_text(json.dumps(rows))
            with self.assertRaises(AssertionError):m.load(a)

if __name__=='__main__':unittest.main()
