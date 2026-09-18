#!/usr/bin/env python3
import importlib.util
from pathlib import Path
import unittest

spec=importlib.util.spec_from_file_location('exposure',Path(__file__).with_name('report-removal-exposure.py'))
module=importlib.util.module_from_spec(spec)
spec.loader.exec_module(module)


class ExposureTests(unittest.TestCase):
    def test_templated_cooperative_solver_is_iteration_work(self):
        rows=[dict(name='void Nv::Blast::persistentStressSolve<(bool)1>(Args)',aggregate_ms=115.3),
              dict(name='Nv::Blast::componentStressSolve(Args,View)',aggregate_ms=.001)]
        self.assertAlmostEqual(module.summarize(rows,{})['kernel_aggregate_ms']['iteration'],115.301)

    def test_parent_cpu_scope_does_not_get_added_to_children(self):
        scopes={'GpuDestruction.applyDetail.validateOwners':1.5,
                'GpuDestruction.compatibility.allocateNativeBodies':17,
                'GpuDestruction.applyDetail.migrateShapes':14,
                'GpuDestruction.parent':50}
        summary=module.summarize([],scopes)['exclusive_thread_cpu_ms']
        self.assertEqual(summary['validateOwners'],1.5)
        self.assertEqual(summary['allocateNativeBodies'],17)
        self.assertEqual(summary['migrateShapes'],14)


if __name__=='__main__':
    unittest.main()
