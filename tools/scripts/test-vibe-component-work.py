#!/usr/bin/env python3
import copy
import importlib.util
import json
from pathlib import Path
import tempfile
import subprocess
import unittest
spec=importlib.util.spec_from_file_location('vibe_work',Path(__file__).with_name('report-vibe-component-work.py'))
m=importlib.util.module_from_spec(spec);spec.loader.exec_module(m)


def sample(solve=0):
    r=dict(record='component',solve=solve,id=7,path=1,nodes=2,dynamic_nodes=2,
        csr_refs_per_sweep=3,live_refs_per_sweep=2,residual_sweeps=3,verification_sweeps=1,
        direction_sweeps=2,iterations=2,converged=1,cta_cycles=9,anchored=1,
        polynomial_refs_per_sweep=1,precondition_sweeps=1)
    t=dict(record='total',solve=solve,components=1,unmeasured_components=0,operator_node_visits=12,
        operator_csr_visits=18,operator_live_visits=12,component_updates=2,polynomial_live_visits=1,
        fine_inverse_applications=4,phase_cycles=[1,1,1,5,1,1,1,1,12],precondition_cycles=[1]*4)
    return [r,t]


class Work(unittest.TestCase):
    def test_actual_probe_macros_publish_and_accumulate(self):
        # Execute the real thread-zero publication macros on the host. This
        # checks counter lifetime, not GPU concurrency or measured durations.
        header=Path(__file__).resolve().parents[2]/'blast/source/sdk/extensions/stressgpu/detail/StressComponentPhaseProbe.cuh'
        source=r"""
#define BLAST_GPU_COMPONENT_PHASE_PROBE
#define __device__
#define __shared__
struct { unsigned x=0; } threadIdx;
unsigned long long clock64(){static unsigned long long n=0;return ++n;}
void atomicAdd(unsigned long long* dst,unsigned long long value){*dst+=value;}
#include HEADER
void cta(unsigned long long amount){
 COMPONENT_PROBE_BEGIN
 probeSubCycles[0]+=amount;probeSubCycles[3]+=2*amount;
 COMPONENT_PROBE_END(0)
 COMPONENT_PROBE_PUBLISH
}
int main(){cta(3);cta(5);return !(componentPreconditionClocks[0]==8 && componentPreconditionClocks[3]==16 && componentPhaseClocks[8]>0);}
""".replace('HEADER','"'+str(header)+'"')
        with tempfile.TemporaryDirectory() as d:
            p=Path(d)/'probe.cpp';p.write_text(source);exe=Path(d)/'probe'
            subprocess.run(['g++','-std=c++17',str(p),'-o',str(exe)],check=True,capture_output=True)
            subprocess.run([str(exe)],check=True)

    def test_two_evaluations_belong_to_one_tick(self):
        frames=[dict(tick=i,native_corrections=c,native_counts={'native_stress_passes':1+c}) for i,c in enumerate([0,1,0])]
        mapping=m.solve_mapping(frames)
        self.assertEqual(mapping,[(0,0),(1,0),(1,1),(2,0)])
        with tempfile.TemporaryDirectory() as d:
            p=Path(d)/'work.jsonl';p.write_text('\n'.join(json.dumps(r) for i in range(4) for r in sample(i)))
            result=m.read_solves(p,mapping)
            self.assertEqual([(r['tick'],r['evaluation']) for r in result],mapping)
            self.assertEqual(result[2]['cohorts']['anchored']['inverse_applications'],4)

    def test_omitted_correction_solve_fails(self):
        with tempfile.TemporaryDirectory() as d:
            p=Path(d)/'work.jsonl';p.write_text('\n'.join(json.dumps(r) for r in sample()))
            with self.assertRaisesRegex(ValueError,'Incomplete solve'):m.read_solves(p,[(0,0),(0,1)])
            with self.assertRaisesRegex(ValueError,'Extra solve'):m.read_solves(p,[])

    def test_bad_polynomial_counts_fail(self):
        for field in ['polynomial_live_visits','fine_inverse_applications']:
            r,t=sample();t[field]+=1
            with self.assertRaises(ValueError):m.summarize([r],t)
        r,t=sample();r['precondition_sweeps']=3
        with self.assertRaisesRegex(ValueError,'exceed updates'):m.summarize([r],t)
        r,t=sample();r['polynomial_refs_per_sweep']=3
        with self.assertRaisesRegex(ValueError,'graph census'):m.summarize([r],t)

    def test_missing_or_impossible_subphase_cycles_fail(self):
        for sub in [[0]*4,[100]*4,[-1,1,1,1],[1,1,1]]:
            r,t=sample();t['precondition_cycles']=sub
            with self.assertRaises(ValueError):m.summarize([r],t)

    def test_invalid_evaluation_counts_fail(self):
        for correction,passes in [(0,2),(1,1),(2,3)]:
            with self.assertRaises(ValueError):m.solve_mapping([dict(tick=0,native_corrections=correction,native_counts={'native_stress_passes':passes})])

    def test_duplicate_and_partial_records_fail(self):
        with tempfile.TemporaryDirectory() as d:
            p=Path(d)/'work.jsonl'
            for rows in [sample()+sample(),sample()+[sample(1)[0]]]:
                p.write_text('\n'.join(json.dumps(r) for r in rows))
                with self.assertRaises(ValueError):m.read_solves(p,[(0,0),(0,1)])

if __name__=='__main__':unittest.main()
