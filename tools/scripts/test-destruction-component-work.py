#!/usr/bin/env python3
import copy
import importlib.util
from pathlib import Path
import unittest
spec=importlib.util.spec_from_file_location('work',Path(__file__).with_name('report-destruction-component-work.py'))
w=importlib.util.module_from_spec(spec);spec.loader.exec_module(w)

def records():
    return [dict(record='component',solve=0,id=7,path=1,nodes=2,dynamic_nodes=2,
                 csr_refs_per_sweep=3,live_refs_per_sweep=2,residual_sweeps=2,
                 verification_sweeps=1,direction_sweeps=1,iterations=1,converged=1,cta_cycles=9),
            dict(record='total',solve=0,components=1,unmeasured_components=0,
                 operator_node_visits=8,operator_csr_visits=12,operator_live_visits=8,
                 component_updates=1,phase_cycles=[1,1,1,1,1,1,1,1,8])]

class Accounting(unittest.TestCase):
    def test_counts_include_verification_and_dead_references(self):
        rows,totals=w.audit(records(),1)
        self.assertEqual(w.visits(rows[0][0]),8)
        self.assertEqual(w.visits(rows[0][0],'csr_refs_per_sweep'),12)

    def test_duplicate_and_missing_components_fail(self):
        r=records();r.insert(0,copy.deepcopy(r[0]))
        with self.assertRaisesRegex(ValueError,'Duplicate component'):w.audit(r,1)
        with self.assertRaisesRegex(ValueError,'Missing component'):w.audit(records()[1:],1)

    def test_missing_or_duplicate_solve_fails(self):
        with self.assertRaisesRegex(ValueError,'Missing solve'):w.audit(records(),2)
        r=records();r.append(copy.deepcopy(r[-1]))
        with self.assertRaisesRegex(ValueError,'Duplicate solve'):w.audit(r,1)

    def test_unmeasured_path_cannot_look_like_zero_work(self):
        r=records();r[-1]['unmeasured_components']=1
        with self.assertRaisesRegex(ValueError,'unmeasured'):w.audit(r,1)

    def test_counts_and_cycles_must_close(self):
        for field in ['operator_node_visits','operator_csr_visits','operator_live_visits','component_updates']:
            r=records();r[-1][field]+=1
            with self.assertRaises(ValueError):w.audit(r,1)
        r=records();r[-1]['phase_cycles'][0]+=1
        with self.assertRaisesRegex(ValueError,'cycles do not close'):w.audit(r,1)

    def test_unconverged_and_negative_records_fail(self):
        r=records();r[0]['converged']=0
        with self.assertRaisesRegex(ValueError,'unconverged'):w.audit(r,1)
        r=records();r[0]['residual_sweeps']=-1
        with self.assertRaisesRegex(ValueError,'Invalid work'):w.audit(r,1)

if __name__=='__main__':unittest.main()
