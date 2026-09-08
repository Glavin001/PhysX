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

    def idle_capture(self,name):
        path=self.capture(name)
        rows=json.loads((path/'steps.json').read_text())
        for row in rows:
            row.update(native_corrections=0,native_counts={'native_stress_passes':1},
                broken_bonds=0,fragment_bodies=0,awake_fragment_bodies=0,normal_contacts=0)
        report=json.loads((path/'report.json').read_text())
        report.update(waves=0,projectiles=0,unique_broken_bonds=0,peak_step=rows[0])
        (path/'steps.json').write_text(json.dumps(rows));(path/'report.json').write_text(json.dumps(report))
        (path/'commands.json').write_text('[]')
        return path

    def test_intact_idle_has_distribution_without_invented_fracture_peak(self):
        a=self.idle_capture('a');b=self.idle_capture('b')
        run=m.load(a)
        self.assertTrue(run['intact_idle']);self.assertIsNone(run['fracture_peak'])
        self.assertIsNone(run['loaded_peak'])
        m.generate([a],[b],self.root/'report')
        text=(self.root/'report/report.md').read_text()
        self.assertIn('10.000 / 15.000 / 10.000 / 20.000 / 20.000 / 20.000',text)
        self.assertIn('fracture-step peak reduction is not measured',text)
        self.assertIn('qualification is incomplete',text)

    def test_sleeping_aftermath_is_not_intact_idle(self):
        a=self.idle_capture('a');rows=json.loads((a/'steps.json').read_text())
        rows[1]['broken_bonds']=1;rows[1]['fragment_bodies']=1
        (a/'steps.json').write_text(json.dumps(rows))
        run=m.load(a)
        self.assertFalse(run['intact_idle']);self.assertIsNotNone(run['fracture_peak'])

    def test_impact_interval_excludes_pre_command_startup_but_keeps_it_in_all_peak(self):
        run=m.load(self.capture('a',20))
        self.assertEqual(run['loaded_peak']['tick'],1)
        self.assertEqual(run['peak']['tick'],0)
        self.assertFalse(run['intact_idle'])

    def test_changed_commands_fail_before_report_publication(self):
        a=self.capture('a');b=self.capture('b');(b/'commands.json').write_text('[]')
        with self.assertRaisesRegex(AssertionError,'commands changed'):m.generate([a],[b],self.root/'report')
        self.assertFalse((self.root/'report').exists())

    def test_same_counts_with_different_scene_identity_rejected(self):
        a=self.capture('a');b=self.capture('b')
        for path,value in [(a,'asset-a'),(b,'asset-b')]:
            report=json.loads((path/'report.json').read_text());report['manifest_hash']=value
            (path/'report.json').write_text(json.dumps(report))
        with self.assertRaisesRegex(AssertionError,'scene identity changed'):
            m.generate([a],[b],self.root/'report')
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
