#!/usr/bin/env python3
"""Accounting and kernel-inventory regression checks, independent of the GPU."""
import importlib.util,unittest
from pathlib import Path
def load(name,file):
    s=importlib.util.spec_from_file_location(name,Path(__file__).with_name(file));m=importlib.util.module_from_spec(s);s.loader.exec_module(m);return m
kernel=load('kernel','profile-kernel-suite.py');accounting=kernel.profile.accounting
class AttributionTests(unittest.TestCase):
    def test_overlap_is_not_added(self):
        gpu=[(0,5),(3,7)];cpu=[(2,6),(8,10)]
        both=accounting.length(accounting.intersect(gpu,cpu));g=accounting.length(gpu);c=accounting.length(cpu)
        self.assertEqual((both,g-both,c-both,10-g-c+both),(4,3,2,1))
    def test_nested_cpu_and_detached_wall(self):
        def row(name,a,b,cpu,detached=0):return dict(phase=name,start_ns=str(a),end_ns=str(b),thread_cpu_ms=str(cpu),thread='1',end_thread='1',detached=str(detached))
        result=accounting.exclusive_cpu([row('parent',0,100,10),row('child',10,50,4),row('detached',0,100,30,1),row('unmeasured',20,30,-1)])
        self.assertEqual(result,{'parent':6,'child':4})
    def test_selection_keeps_late_different_grids_and_correction(self):
        def k(name,ms,grid):return dict(name=name,mangled=name,ms=ms,grid=[grid,1,1],block=[256,1,1],shared_bytes=0)
        plan=kernel.select(dict(kernels=[k('stress',8,1),k('stress',3,64),k('stress',1,64),k('small',.005,1)]),.99,.1)
        self.assertEqual(plan['expected_launches'],3)
        self.assertEqual(len(plan['targets'][0]['configurations']),2)
        self.assertGreaterEqual(plan['coverage_fraction'],.99)
    def test_absolute_cost_survives_relative_cutoff(self):
        def k(n,ms):return dict(name=n,mangled=n,ms=ms,grid=[1,1,1],block=[1,1,1],shared_bytes=0)
        plan=kernel.select(dict(kernels=[k('huge',1000),k('material',.2),k('tail',.001)]),.99,.1)
        self.assertEqual([x['name'] for x in plan['targets']],['huge','material'])
    def test_one_hundred_percent_covers_all(self):
        def k(n,ms):return dict(name=n,mangled=n,ms=ms,grid=[1,1,1],block=[1,1,1],shared_bytes=0)
        plan=kernel.select(dict(kernels=[k('large',1000),k('tiny',.0001)]),1,.1)
        self.assertEqual(plan['expected_launches'],2)
if __name__=='__main__':unittest.main()
