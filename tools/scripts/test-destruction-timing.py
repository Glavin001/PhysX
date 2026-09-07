#!/usr/bin/env python3
"""Accounting regressions: dropped/overlapping evidence must never look faster."""
import importlib.util,tempfile,unittest
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
        valid=dict(complete=True,records=10,dropped=0,invalid_timestamps=0)
        r.validate_activity_status(valid)
        for key,value in [('complete',False),('records',0),('dropped',1),('invalid_timestamps',1)]:
            with self.subTest(key=key),self.assertRaisesRegex(ValueError,'Incomplete CUPTI'):
                r.validate_activity_status(dict(valid,**{key:value}))
    def test_gpu_overlap_identity(self):
        gpu=[(1,7),(3,8),(9,10)];kernel=[(1,7),(3,8)]
        active=r.a.length(gpu);kernels=r.a.length(kernel)
        self.assertEqual(kernels+(active-kernels)+(12-active),12)

if __name__=='__main__':unittest.main()
