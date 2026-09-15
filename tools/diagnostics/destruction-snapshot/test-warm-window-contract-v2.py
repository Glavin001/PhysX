#!/usr/bin/env python3
import copy,importlib.util,json,unittest
from pathlib import Path
s=importlib.util.spec_from_file_location('contract',Path(__file__).with_name('warm-window-contract-v2.py'));c=importlib.util.module_from_spec(s);s.loader.exec_module(c)
root=Path(__file__).resolve().parents[3]
class OrdinaryAdmission(unittest.TestCase):
 def fixture(self):return json.loads((root/'out/warm-full52-20260914/timings/flying-A0/replay.json').read_text())
 def test_inactive_clock_is_valid(self):self.assertEqual(c.schedule(self.fixture()),(8,8,False))
 def test_inactive_clock_cannot_hide_work(self):
  for field in ('frame',*c.WORK):
   with self.subTest(field=field):
    r=self.fixture();r['trajectories'][0]['ticks'][1][field]=1
    with self.assertRaises(ValueError):c.validate(r)
 def test_missing_step_rejected(self):
  r=self.fixture();r['trajectories'][0]['ticks'].pop(1)
  with self.assertRaises(ValueError):c.validate(r)
 def test_clock_cannot_change_mode(self):
  r=self.fixture();r['trajectories'][0]['ticks'][1]['stress_passes']=1
  with self.assertRaises(ValueError):c.validate(r)
if __name__=='__main__':unittest.main()
