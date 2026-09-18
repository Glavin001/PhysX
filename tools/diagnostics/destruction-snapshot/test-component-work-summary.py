#!/usr/bin/env python3
"""Reject incomplete or contradictory intrusive work accounting."""
import copy
import json
from pathlib import Path
import subprocess
import sys
import tempfile
import unittest

SCRIPT = Path(__file__).with_name('summarize-component-work.py')


class WorkSummaryTests(unittest.TestCase):
    def fixture(self):
        component = dict(record='component',solve=0,id=7,path=1,nodes=2,dynamic_nodes=2,
                         iterations=3,converged=1,settled_skipped=0,anchored=0,cta_cycles=100,
                         direction_sweeps=3,residual_sweeps=4,verification_sweeps=1,
                         csr_refs_per_sweep=2,live_refs_per_sweep=2)
        total = dict(record='total',solve=0,components=1,unmeasured_components=0,
                     component_updates=3,operator_node_visits=16,operator_csr_visits=16,
                     phase_cycles=[1]*8+[8])
        return [component,total]

    def run_summary(self, records, passes=1):
        with tempfile.TemporaryDirectory() as folder:
            base = Path(folder)
            (base/'work').write_text(''.join(json.dumps(r)+'\n' for r in records))
            (base/'frames').write_text('step,stress_passes\n0,'+str(passes)+'\n')
            result = subprocess.run([sys.executable,str(SCRIPT),str(base/'work'),str(base/'frames'),str(base/'out')],capture_output=True,text=True)
            return result, json.loads((base/'out').read_text()) if (base/'out').exists() else None

    def test_closed_work_and_tree_counts(self):
        result, summary = self.run_summary(self.fixture())
        self.assertEqual(result.returncode,0,result.stderr)
        group=summary['solves'][0]['groups']['free/1-32']
        self.assertEqual(group['tree_node_updates'],6)
        self.assertEqual(group['csr_visits'],16)

    def test_missing_correction_pass_rejected(self):
        result, _ = self.run_summary(self.fixture(),passes=2)
        self.assertNotEqual(result.returncode,0)
        self.assertIn('Missing solve',result.stderr)

    def test_settled_with_executed_sweeps_rejected(self):
        records=self.fixture();records[0]['settled_skipped']=1
        result,_=self.run_summary(records)
        self.assertNotEqual(result.returncode,0)

    def test_bad_aggregate_rejected(self):
        records=self.fixture();records[-1]['operator_node_visits']=15
        result,_=self.run_summary(records)
        self.assertNotEqual(result.returncode,0)

    def test_large_components_remain_explicitly_unmeasured(self):
        records=self.fixture()
        large=copy.deepcopy(records[0]);large.update(id=20,path=2,nodes=2304,anchored=1)
        records.insert(1,large);records[-1]['unmeasured_components']=1
        result,summary=self.run_summary(records)
        self.assertEqual(result.returncode,0,result.stderr)
        group=summary['solves'][0]['groups']['anchored/large-unmeasured']
        self.assertEqual(group['nodes'],2304)
        self.assertNotIn('node_updates',group)
        self.assertEqual(summary['solves'][0]['unmeasured_components'],1)


if __name__=='__main__':
    unittest.main()
