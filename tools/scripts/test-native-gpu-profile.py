#!/usr/bin/env python3
import importlib.util,unittest
from pathlib import Path
spec=importlib.util.spec_from_file_location('profile_analysis',Path(__file__).with_name('analyze-native-gpu-profile.py'));m=importlib.util.module_from_spec(spec);spec.loader.exec_module(m)
class Accounting(unittest.TestCase):
    def test_union_overlapping_streams(self):
        self.assertEqual(m.length([(0,5),(3,8),(8,10),(20,22)]),12)
    def test_intersection_and_frame_boundaries(self):
        self.assertEqual(m.intersect([(5,15),(13,20)],[(0,10),(16,30)]),[(5,10),(16,20)])
    def test_gpu_wall_partition(self):
        kernels=[(1,7),(3,9)];copies=[(0,4),(12,14)];busy=m.length(kernels+copies);kernel=m.length(kernels)
        self.assertEqual(kernel+(busy-kernel)+(20-busy),20)
    def row(self,name,start,end,cpu,thread='1',detached='0'):
        return dict(phase=name,start_ns=start,end_ns=end,thread_cpu_ms=cpu,thread=thread,end_thread=thread,detached=detached)
    def test_nested_and_parallel_cpu_are_core_time(self):
        rows=[self.row('parent',0,20,10),self.row('child',2,10,4),self.row('grandchild',3,8,2),self.row('other-thread',1,12,9,'2'),self.row('detached',0,25,18,detached='1')]
        self.assertEqual(m.exclusive_cpu(rows),{'parent':6,'child':2,'grandchild':2,'other-thread':9})
    def test_crossing_scopes_rejected(self):
        with self.assertRaises(ValueError):m.exclusive_cpu([self.row('a',0,5,1),self.row('b',3,8,1)])
    def test_kernel_parameters_do_not_determine_phase(self):
        name='_ZN5physx57_GLOBAL__N__2d3fc3ea_24_PxgDestructionRuntime_cu_021480ce13routeContactsEPKNS_21PxDestructionMaterialE'
        self.assertEqual(m.classify(name,{})[0],'destruction load gathering')
    def test_identical_counters_not_fake_correlation(self):
        self.assertIsNone(m.pearson([3]*5,[1,2,3,4,5]))
if __name__=='__main__':unittest.main()
