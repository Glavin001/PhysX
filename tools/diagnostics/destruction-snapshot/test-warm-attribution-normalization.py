#!/usr/bin/env python3
import copy,importlib.util,unittest
from pathlib import Path
s=importlib.util.spec_from_file_location('normalizer',Path(__file__).with_name('normalize-warm-attribution.py'));n=importlib.util.module_from_spec(s);s.loader.exec_module(n)
def fixture():
 a=dict(correlation_id=7,thread=1,name='cudaGraphLaunch',start_ns=10,end_ns=90,ms=.00008,stack=[{}],scope='GpuDestruction.solve',kind='cuda')
 b=dict(a,name='cudaGraphLaunch_v10000',start_ns=11,end_ns=89,ms=.000078,stack=[])
 return dict(cpu_attribution=dict(cuda_calls=[a,b],waits=[]),kernels=[],transfers=[],memsets=[])
class AliasTest(unittest.TestCase):
 def test_one_physical_launch(self):
  r=n.normalize(fixture());self.assertEqual(r['cuda_api_normalization']['physical_calls'],1);self.assertEqual(r['cuda_apis'][0]['calls'],1)
 def test_independent_launches_preserved(self):
  r=fixture();r['cpu_attribution']['cuda_calls'][1]['correlation_id']=8
  self.assertEqual(n.normalize(r)['cuda_api_normalization']['physical_calls'],2)
 def test_ambiguous_correlations_rejected(self):
  r=fixture();r['cpu_attribution']['cuda_calls'][1].update(start_ns=100,end_ns=180)
  with self.assertRaises(ValueError):n.normalize(r)
 def test_different_api_layers_preserved(self):
  r=fixture();r['cpu_attribution']['cuda_calls'][1]['name']='cuGraphLaunch'
  self.assertEqual(n.normalize(r)['cuda_api_normalization']['physical_calls'],2)
if __name__=='__main__':unittest.main()
