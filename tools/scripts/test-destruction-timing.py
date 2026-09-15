#!/usr/bin/env python3
"""Accounting regressions: dropped/overlapping evidence must never look faster."""
import gzip,importlib.util,tempfile,unittest
from pathlib import Path
spec=importlib.util.spec_from_file_location('report',Path(__file__).with_name('report-destruction-timing.py'))
r=importlib.util.module_from_spec(spec);spec.loader.exec_module(r)
runner_spec=importlib.util.spec_from_file_location('runner',Path(__file__).with_name('run-destruction-timing.py'))
runner=importlib.util.module_from_spec(runner_spec);runner_spec.loader.exec_module(runner)

class TimingAccounting(unittest.TestCase):
    def test_compute_sharing_requires_exact_explicit_identity(self):
        allowed={'pid':20,'name':'authorized-server','type':'C'}
        changed=dict(allowed,name='replacement')
        other={'pid':21,'name':'unlisted','type':'C'}
        sample={'devices':[{'processes':[allowed,changed,other]}]}
        self.assertEqual(runner.competing_processes(sample,[],[allowed]),[changed,other])
        self.assertEqual(runner.competing_processes(sample,[]),[allowed,changed,other])

    def test_diagnostic_graphics_policy_keeps_compute_and_new_identities_visible(self):
        desktop={'pid':10,'name':'desktop','type':'G'}
        compute={'pid':20,'name':'simulation','type':'C'}
        new_desktop={'pid':11,'name':'desktop','type':'G'}
        changed_type=dict(desktop,type='C+G')
        sample={'devices':[{'processes':[desktop,compute,new_desktop,changed_type]}]}
        self.assertEqual(runner.competing_processes(sample,[desktop]),[compute,new_desktop,changed_type])
        self.assertEqual(runner.competing_processes(sample,[]),sample['devices'][0]['processes'])

    def test_full_profile_focus_accepts_bombardment(self):
        scene={'id':'impacts-256','label':'256-building bombardment'}
        captures={'plain':[object()],'phases':[object()],'gpu':[object()]}
        case,data=r.focused_case({'config':{'cases':[scene]}},{'impacts-256':captures})
        self.assertEqual(case,scene)
        self.assertIs(data,captures)
        with self.assertRaisesRegex(ValueError,'No configured scene'):
            r.focused_case({'config':{'cases':[]}}, {})
        with self.assertRaisesRegex(ValueError,'no captures'):
            r.focused_case({'config':{'cases':[scene]}}, {})

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
        self.assertAlmostEqual(p['preparationCompletion.other'],.00005)
        self.assertAlmostEqual(p['trial.other'],.00001)
        with self.assertRaisesRegex(ValueError,'Overlapping'):
            r.partition([(0,100)],dict(by,preparationCompletion=[(19,70)]))

    def test_validation_install_and_construction_are_disjoint(self):
        by={'validatePreparation':[(0,10)],'restoreInstall':[(10,30)],
            'preparationCompletion':[(30,80)],'compatibility.allocateNativeBodies':[(40,70)]}
        p=r.partition([(0,100)],by)
        self.assertAlmostEqual(sum(p.values()),.0001)
        self.assertAlmostEqual(p['validatePreparation'],.00001)
        self.assertAlmostEqual(p['compatibility.allocateNativeBodies'],.00003)
        with self.assertRaisesRegex(ValueError,'Overlapping'):
            r.partition([(0,100)],dict(by,restoreInstall=[(9,30)]))

    def test_repeated_shape_lifecycle_scopes_replace_parent(self):
        by={'applyBindings':[(0,100)],'applyDetail.validateOwners':[(0,10)],
            'applyDetail.scheduleOwners':[(10,20)],'applyDetail.migrateShapes':[(20,90)],
            'migrateDetail.retireContacts':[(21,25),(45,50)],
            'migrateDetail.queryMirror':[(26,30),(51,55)]}
        p=r.partition([(0,100)],by)
        self.assertAlmostEqual(sum(p.values()),.0001)
        self.assertAlmostEqual(p['migrateDetail.retireContacts'],.000009)
        self.assertAlmostEqual(p['migrateDetail.queryMirror'],.000008)
        self.assertAlmostEqual(p['applyDetail.migrateShapes.other'],.000053)
        self.assertAlmostEqual(p['applyBindings.other'],.00001)
        self.assertTrue(set(p)<=set(r.LABELS))
        with self.assertRaisesRegex(ValueError,'Overlapping'):
            r.partition([(0,100)],dict(by,**{'migrateDetail.queryMirror':[(24,30)]}))
        with self.assertRaisesRegex(ValueError,'escapes'):
            r.partition([(0,100)],dict(by,**{'migrateDetail.queryMirror':[(89,95)]}))

    def test_compatibility_follows_gpu_preparation(self):
        by={'finishAndReserve':[(0,20)],'collisionBindings':[(20,30)],
            'correctionBodies':[(30,40)],'preparationCompletion':[(40,90)],
            'compatibility.requestReadback':[(55,60)],
            'compatibility.allocateNativeBodies':[(60,80)],
            'compatibility.publishReservation':[(80,85)]}
        p=r.partition([(0,100)],by)
        self.assertAlmostEqual(sum(p.values()),.0001)
        self.assertAlmostEqual(p['compatibility.allocateNativeBodies'],.00002)
        self.assertAlmostEqual(p['preparationCompletion.other'],.00002)
        self.assertTrue(set(p)<=set(r.LABELS))
        with self.assertRaisesRegex(ValueError,'escapes'):
            r.partition([(0,100)],dict(by,**{'compatibility.allocateNativeBodies':[(30,50)]}))

    def test_final_publication_is_not_trial_or_double_counted(self):
        by={'acceptCorrection':[(0,20)],'submit':[(20,40)],'finalPublication':[(40,90)]}
        p=r.partition([(0,100)],by)
        self.assertAlmostEqual(p['finalPublication.other'],.00005)
        self.assertAlmostEqual(p['trial.other'],.00001)
        self.assertAlmostEqual(sum(p.values()),.0001)
        self.assertIn('finalPublication',r.LABELS)
        p=r.partition([(0,100)],dict(by,finalShapePublication=[(60,80)]))
        self.assertAlmostEqual(p['finalShapePublication'],.00002)
        self.assertAlmostEqual(p['finalPublication.other'],.00003)
        self.assertAlmostEqual(sum(p.values()),.0001)
        with self.assertRaisesRegex(ValueError,'escapes'):
            r.partition([(0,100)],dict(by,finalShapePublication=[(20,50)]))
        with self.assertRaisesRegex(ValueError,'Overlapping'):
            r.partition([(0,100)],dict(by,finalPublication=[(30,90)]))

    def test_overlapping_siblings_rejected(self):
        with self.assertRaisesRegex(ValueError,'Overlapping'):
            r.partition([(0,100)],{'submit':[(0,20)],'finishAndReserve':[(10,40)]})
    def test_wall_only_leaf_does_not_erase_parent_cpu_time(self):
        def row(name,start,end,cpu):
            return dict(phase=name,start_ns=start,end_ns=end,thread='7',end_thread='7',detached='0',thread_cpu_ms=cpu)
        rows=[row('parent',0,100,10),row('wall-only',10,60,-1),row('measured-child',20,40,2)]
        self.assertEqual(r.a.exclusive_cpu(rows),{'parent':8,'measured-child':2})

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
    def test_workload_peak_includes_later_repeats(self):
        manifest,runs=self.gate_runs(chaotic=True)
        runs['fixture']['plain'][3]['summary']['peak_clusters']=57
        with tempfile.TemporaryDirectory() as d:
            out=Path(d)
            r.render_complete_gate(manifest,runs,out)
            self.assertIn('| fixture | 444 | 896 | 1 | 57 |', (out/'report.md').read_text())

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
    def test_frame_budget_exceedances_use_exact_thresholds(self):
        run=self.complete_run([8.1,1000/120,1000/120+1e-6,1000/60,1000/60+1e-6])
        metric=r.complete_step_metrics(run)
        self.assertEqual(run['summary']['missed_8ms'],5)
        self.assertEqual(metric['misses_120hz'],3)
        self.assertEqual(metric['misses_60hz'],1)
    def test_profiler_serialization_must_be_outside_complete_steps(self):
        run=self.complete_run([1,1]);run['summary']['phase_output_timing_schema']=1
        run['frames'][0].update(phase_output_start_ns=4,phase_output_end_ns=5)
        run['frames'][1].update(complete_start_ns=6,simulation_start_ns=7,simulation_end_ns=8,complete_end_ns=9,phase_output_start_ns=9,phase_output_end_ns=10)
        r.complete_step_metrics(run)
        run['frames'][0]['phase_output_start_ns']=3
        with self.assertRaisesRegex(ValueError,'overlaps complete-step'):
            r.complete_step_metrics(run)
        run['frames'][0].update(phase_output_start_ns=4,phase_output_end_ns=7)
        with self.assertRaisesRegex(ValueError,'overlaps next'):
            r.complete_step_metrics(run)
        run['frames'][0].pop('phase_output_start_ns')
        with self.assertRaisesRegex(ValueError,'Missing profiler'):
            r.complete_step_metrics(run)

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
    def test_broadphase_wait_is_nested_not_extra_simulation_work(self):
        spans={'correctedCollisionSolve':[(10,90)],'detail.postBroadPhase':[(10,80)],
               'detail.broadPhaseWait':[(15,75)]}
        base=r.partition([(0,100)],{'correctedCollisionSolve':[(10,90)]})
        self.assertEqual(r.partition([(0,100)],spans),base)
        doc=r.Document()
        r.render_physics_task_details(doc,{'detail':{
            'detail.postBroadPhase':{'observed_wall_ms':[7,9]},
            'detail.broadPhaseWait':{'observed_wall_ms':[6,8]}}},1)
        with tempfile.TemporaryDirectory() as d:
            doc.save(Path(d));text=(Path(d)/'report.md').read_text()
            self.assertIn('CPU spin/block awaiting GPU completion',text)
            self.assertIn('do not sum',text)

    def test_gpu_overlap_identity(self):
        gpu=[(1,7),(3,8),(9,10)];kernel=[(1,7),(3,8)]
        active=r.a.length(gpu);kernels=r.a.length(kernel)
        self.assertEqual(kernels+(active-kernels)+(12-active),12)

if __name__=='__main__':unittest.main()
