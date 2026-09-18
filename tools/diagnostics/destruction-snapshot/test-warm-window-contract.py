#!/usr/bin/env python3
"""Challenge admission: reject hidden warmup, skipped ticks, bad timing and mixed histories."""
import copy, importlib.util, unittest
from pathlib import Path
s=importlib.util.spec_from_file_location('contract',Path(__file__).with_name('warm-window-contract.py'));c=importlib.util.module_from_spec(s);s.loader.exec_module(c)
def fixture():
    r=dict(contract='physical-warm-window-v1',warmup_ticks=2,measure_ticks=3,repetitions=2,steps_per_restore=5,warmup_advances_physics=True,profile_tick_offset=2,projectile_impulse=False,impulse_tick_offset=-1,passed=True,gpu_healthy=True,repeatability_passed=True,trajectories=[],samples=[])
    for i in range(2):
        ticks=[dict(repeat=i,tick_offset=j,measured=j>=2,frame=101+j,command_ms=.1,simulate_fetch_ms=2,completion_ms=.2,complete_step_ms=2.3) for j in range(5)]
        r['trajectories'].append(dict(repeat=i,repeatability_passed=True,ticks=ticks));r['samples']+=ticks[2:]
    return r
class ContractTest(unittest.TestCase):
    def test_valid(self):self.assertEqual(c.validate(fixture()),(2,3,False))
    def test_rejects_invalid_selection(self):
        for key,value in [('steps_per_restore',1),('warmup_advances_physics',False),('profile_tick_offset',0),('impulse_tick_offset',0),('passed',False),('measure_ticks',0)]:
            with self.subTest(key=key):
                r=fixture();r[key]=value
                with self.assertRaises(ValueError):c.validate(r)
    def test_missing_and_misaccounted_ticks(self):
        for mutate in [lambda r:r['samples'].pop(),lambda r:r['trajectories'][0]['ticks'].pop(),lambda r:r['samples'][0].update(tick_offset=1),lambda r:r['samples'][0].update(frame=999),lambda r:r['samples'][0].update(complete_step_ms=1),lambda r:r['samples'][0].update(complete_step_ms=float('nan'))]:
            r=fixture();mutate(r)
            with self.assertRaises(ValueError):c.validate(r)
    def test_correlated_ticks_are_not_repeats(self):
        r=fixture();r['repetitions']=6
        with self.assertRaises(ValueError):c.validate(r)
    def test_incomplete_replay_not_admitted(self):
        r=fixture();r['trajectories'][1]['repeatability_passed']=False
        with self.assertRaises(ValueError):c.schedule(r)
if __name__=='__main__':unittest.main()
