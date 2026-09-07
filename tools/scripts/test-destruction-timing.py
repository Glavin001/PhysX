#!/usr/bin/env python3
"""Accounting regressions: dropped/overlapping evidence must never look faster."""
import gzip,importlib.util,tempfile,unittest
from pathlib import Path
spec=importlib.util.spec_from_file_location('report',Path(__file__).with_name('report-destruction-timing.py'))
r=importlib.util.module_from_spec(spec);spec.loader.exec_module(r)

class TimingAccounting(unittest.TestCase):
    def test_nearest_rank(self):
        self.assertEqual(r.stats(list(range(1,101)))['p95'],95)
        self.assertEqual(r.stats([1,2])['p50'],1)
        self.assertEqual(r.stats([3])['p99'],3)
        self.assertIsNone(r.stats([]))
    def test_partition_nested_no_double_count(self):
        by={'submit':[(0,10)],'finishAndReserve':[(10,90)],
            'finishDetail.waitForGpu':[(10,60)],'finishDetail.reserveBodies':[(60,80)],
            'finishDetail.allocateNativeBodies':[(65,75)]}
        p=r.partition([(0,100)],by)
        self.assertAlmostEqual(sum(p.values()),.0001)
        self.assertAlmostEqual(p['finishAndReserve.other'],.00001)
        self.assertAlmostEqual(p['finishDetail.reserveBodies.other'],.00001)
    def test_preparation_completion_is_explicit_and_disjoint(self):
        by={'collisionBindings':[(0,10)],'correctionBodies':[(10,20)],
            'preparationCompletion':[(20,70)],'applyBindings':[(70,90)]}
        p=r.partition([(0,100)],by)
        self.assertAlmostEqual(p['preparationCompletion'],.00005)
        self.assertAlmostEqual(p['trial.other'],.00001)
        with self.assertRaisesRegex(ValueError,'Overlapping'):
            r.partition([(0,100)],dict(by,preparationCompletion=[(19,70)]))

    def test_overlapping_siblings_rejected(self):
        with self.assertRaisesRegex(ValueError,'Overlapping'):
            r.partition([(0,100)],{'submit':[(0,20)],'finishAndReserve':[(10,40)]})
    def test_child_outside_parent_rejected(self):
        with self.assertRaisesRegex(ValueError,'escapes'):
            r.partition([(0,100)],{'finishAndReserve':[(10,30)],'finishDetail.waitForGpu':[(5,20)]})
    def test_missing_parent_does_not_hide_child(self):
        with self.assertRaisesRegex(ValueError,'escapes'):
            r.partition([(0,100)],{'finishDetail.waitForGpu':[(5,20)]})
    def test_negative_interval_rejected(self):
        with self.assertRaises(ValueError):r.partition([(5,0)],{})
    def test_subtraction_clips_and_merges(self):
        self.assertEqual(r.subtract([(0,10)],[(2,4),(3,5),(8,20)]),[(0,2),(5,8)])
    def test_no_impact_discarded_as_warmup(self):
        f=[dict(bonds_broken=int(i==3),resim_passes=int(i==3)) for i in range(180)]
        w=r.windows(f)
        self.assertEqual(w['preimpact'],[1,2]);self.assertEqual(w['corrected'],[3])
        self.assertIn(3,w['all']);self.assertEqual(w['after_last_fracture'][0],4)
    def test_idle_windows(self):
        f=[dict(bonds_broken=0,resim_passes=0) for _ in range(180)]
        self.assertEqual(r.windows(f)['preimpact'],list(range(1,180)))
        self.assertEqual(r.windows(f)['corrected'],[])
    def test_changed_capture_rejected_before_analysis(self):
        with tempfile.TemporaryDirectory() as d:
            p=Path(d);(p/'native.frames.csv').write_text('changed')
            with self.assertRaisesRegex(ValueError,'hash mismatch'):
                r.load_run(p,{'files':{'native.frames.csv':'incorrect'}})
    def test_incomplete_gpu_evidence_rejected(self):
        valid=dict(schema=2,cupti_header_version=130202,cupti_runtime_version=130202,device_graph_buffer_bytes=512*1024**2,complete=True,records=10,dropped=0,invalid_timestamps=0)
        r.validate_activity_status(valid)
        for key,value in [('complete',False),('records',0),('dropped',1),('invalid_timestamps',1)]:
            with self.subTest(key=key),self.assertRaisesRegex(ValueError,'Incomplete CUPTI'):
                r.validate_activity_status(dict(valid,**{key:value}))
    def test_unqualified_profiler_rejected(self):
        valid=dict(schema=2,cupti_header_version=130202,cupti_runtime_version=130202,device_graph_buffer_bytes=512*1024**2,complete=True,records=10,dropped=0,invalid_timestamps=0)
        for change in [dict(schema=1),dict(cupti_header_version=130203),dict(cupti_runtime_version=28),dict(device_graph_buffer_bytes=0)]:
            with self.subTest(change=change),self.assertRaises(ValueError):r.validate_activity_status(dict(valid,**change))
    def test_truncated_duration_rejected(self):
        r.validate_duration(dict(seconds=10,gpu_seconds=10),range(600))
        with self.assertRaisesRegex(ValueError,'Partial-duration'):r.validate_duration(dict(seconds=10,gpu_seconds=5),range(600))
        with self.assertRaisesRegex(ValueError,'duration differs'):r.validate_duration(dict(seconds=10,gpu_seconds=10),range(599))
    def test_missing_activity_rows_or_step_rejected(self):
        r.validate_activity_census(dict(records=10),10,[3,7])
        with self.assertRaisesRegex(ValueError,'row count'):r.validate_activity_census(dict(records=10),9,[3,6])
        with self.assertRaisesRegex(ValueError,'coverage'):r.validate_activity_census(dict(records=10),10,[10,0])
    def test_raw_storage_is_lossless_and_repeatable(self):
        spec=importlib.util.spec_from_file_location('runner',Path(__file__).with_name('run-destruction-timing.py'))
        runner=importlib.util.module_from_spec(spec);spec.loader.exec_module(runner)
        with tempfile.TemporaryDirectory() as d:
            directory=Path(d);source=directory/'test.csv';raw=b'a,b\n1,2\n'
            source.write_bytes(raw);runner.compress_csv(directory)
            compressed=directory/'test.csv.gz';first=compressed.read_bytes()
            self.assertFalse(source.exists());self.assertEqual(gzip.decompress(first),raw)
            compressed.unlink();source.write_bytes(raw);runner.compress_csv(directory)
            self.assertEqual(first,compressed.read_bytes())
    def complete_run(self,values):
        return dict(summary=dict(complete_timer_schema=1,missed_8ms=sum(v>8 for v in values),complete_step_ms_max=max(values)),frames=[dict(complete_step_ms=v,command_ms=.1,physics_step_ms=v-.2,completion_ms=.1,complete_start_ns=1,simulation_start_ns=2,simulation_end_ns=3,complete_end_ns=4) for v in values])
    def gate_runs(self, chaotic=False):
        runs=[]
        for _ in range(5):
            run=self.complete_run([1]*3600)
            run['summary'].update(chunks=444,bonds=896,projectiles=1,peak_clusters=43,
                seconds=60,correction_limit=1,sleeping=False,buildings=1,broken_bonds=199,
                corrections=3,shot_path='aerial' if chaotic else 'through-wall',
                workload='bombardment' if chaotic else 'single-impact')
            run['signature_rows']=[[i,0,0,1] for i in range(3600)]
            runs.append(run)
        manifest=dict(seconds=60,trials=5,config=dict(cases=[dict(id='fixture',label='fixture')]))
        return manifest,dict(fixture=dict(plain=runs,phases=[]))
    def test_controlled_wall_counter_failure_still_writes_failed_report(self):
        manifest,runs=self.gate_runs();runs['fixture']['plain'][2]['summary']['broken_bonds']=198
        with tempfile.TemporaryDirectory() as d:
            self.assertFalse(r.render_complete_gate(manifest,runs,Path(d)))
            self.assertIn('Controlled quality gate failed',(Path(d)/'report.md').read_text())
    def test_controlled_wall_history_variation_rejected(self):
        manifest,runs=self.gate_runs();runs['fixture']['plain'][1]['signature_rows'][10][1]=1
        with tempfile.TemporaryDirectory() as d:
            self.assertFalse(r.render_complete_gate(manifest,runs,Path(d)))
    def test_chaotic_variation_is_visible_and_not_full_quality_qualification(self):
        manifest,runs=self.gate_runs(True);runs['fixture']['plain'][1]['signature_rows'][10][1]=1
        with tempfile.TemporaryDirectory() as d:
            self.assertTrue(r.render_complete_gate(manifest,runs,Path(d)))
            report=(Path(d)/'report.md').read_text()
            self.assertIn('Chaotic workload variation',report)
            self.assertIn('full physical quality are not qualified',report)

    def test_complete_peak_keeps_every_spike(self):
        run=self.complete_run([1]*599+[8.00001]);metric=r.complete_step_metrics(run)
        self.assertEqual(metric['max'],8.00001);self.assertEqual(run['summary']['missed_8ms'],1)
    def test_complete_timer_rejects_old_bracket(self):
        run=self.complete_run([1]);run['summary'].pop('complete_timer_schema')
        with self.assertRaisesRegex(ValueError,'timer required'):r.complete_step_metrics(run)
    def test_complete_timer_rejects_missing_cost(self):
        run=self.complete_run([1]);run['frames'][0]['completion_ms']=0
        with self.assertRaisesRegex(ValueError,'add up'):r.complete_step_metrics(run)
    def test_complete_timer_rejects_wrong_deadline_count(self):
        run=self.complete_run([9]);run['summary']['missed_8ms']=0
        with self.assertRaisesRegex(ValueError,'counter mismatch'):r.complete_step_metrics(run)
    def test_complete_timer_rejects_escaped_work(self):
        run=self.complete_run([1]);run['frames'][0]['simulation_end_ns']=5
        with self.assertRaisesRegex(ValueError,'escaped'):r.complete_step_metrics(run)
    def test_gpu_overlap_identity(self):
        gpu=[(1,7),(3,8),(9,10)];kernel=[(1,7),(3,8)]
        active=r.a.length(gpu);kernels=r.a.length(kernel)
        self.assertEqual(kernels+(active-kernels)+(12-active),12)

if __name__=='__main__':unittest.main()
