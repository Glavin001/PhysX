#!/usr/bin/env python3
"""Exercise matched orchestration without a GPU, including first-use costs."""
import hashlib,importlib.util,json,subprocess,sys,tempfile,unittest
from pathlib import Path
from unittest.mock import patch
spec=importlib.util.spec_from_file_location('matched',Path(__file__).with_name('run-matched.py'));matched=importlib.util.module_from_spec(spec);spec.loader.exec_module(matched)
class MatchedTests(unittest.TestCase):
    def test_distinct_cpu_candidate_and_equal_first_use_weight(self):
        with tempfile.TemporaryDirectory() as folder:
            root=Path(folder);modules={}
            for name in ['libPhysXGpuActivity_64.so','libPhysXDestructionGpuRuntime_64.so']:
                p=root/name;p.write_bytes(name.encode());modules[str(p)]=hashlib.sha256(p.read_bytes()).hexdigest()
            a=root/'control';b=root/'candidate';a.write_bytes(b'A');b.write_bytes(b'B')
            source=root/'input.pxbin';source.write_bytes(b'fixed physical input')
            manifest=root/'manifest.json';manifest.write_text(json.dumps(dict(scenarios=[dict(scenario='odd-count',prefix=str(source),repetitions=3,input_sha256={str(source):hashlib.sha256(source.read_bytes()).hexdigest()})])))
            argv=['matched',str(root/'output'),'--manifest',str(manifest),'--binary',str(a),'--candidate-binary',str(b),'--baseline-artifacts',str(root),'--candidate-artifacts',str(root),'--candidate-commit','test','--use-case-repetitions']
            launches=[]
            def run(command,**kwargs):
                binary=Path(command[command.index('--binary')+1]);n=int(command[command.index('--repetitions')+1]);launches.append((binary,n));out=Path(command[2]);out.mkdir()
                samples=[dict(complete_step_ms=10 if i==0 else 1,restore_ms=20,stress_iterations=5,command_ms=0,simulate_fetch_ms=10 if i==0 else 1,completion_ms=0) for i in range(n)]
                (out/'replay.json').write_text(json.dumps(dict(samples=samples,context_setup_ms=30)))
                (out/'receipt.json').write_text(json.dumps(dict(binary_sha256=hashlib.sha256(binary.read_bytes()).hexdigest(),modules=modules)))
                return subprocess.CompletedProcess(command,0)
            with patch.object(sys,'argv',argv),patch.object(matched.subprocess,'run',side_effect=run),patch.object(matched.observations,'compare',return_value={'status':'passed'}):matched.main()
            self.assertEqual(launches,[(a,3),(b,3),(a,3)])
            report=json.loads((root/'output/report.json').read_text());row=report['scenarios'][0]
            self.assertEqual((row['A']['n'],row['B']['n']),(6,3))
            self.assertEqual((row['A']['mean_ms'],row['B']['mean_ms'],row['saved_ms']),(4,4,0))
            self.assertEqual(row['first_tick_ms'],dict(A0=10,B=10,A1=10))
if __name__=='__main__':unittest.main()
