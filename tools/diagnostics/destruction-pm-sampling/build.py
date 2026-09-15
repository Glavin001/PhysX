#!/usr/bin/env python3
"""Build the standalone CUDA 13.4 PM collector without rebuilding PhysX."""
import argparse,hashlib,json,subprocess
from pathlib import Path

p=argparse.ArgumentParser(description=__doc__)
p.add_argument('output',type=Path);p.add_argument('--cuda',type=Path,default=Path('/usr/local/cuda-13.4'))
a=p.parse_args();a.output.mkdir(parents=True,exist_ok=True)
source=Path(__file__).resolve().with_name('collect.cpp');binary=a.output.resolve()/'collect'
command=['/usr/bin/g++-12','-O2','-std=c++17','-pthread','-I'+str(a.cuda/'include'),str(source),
         '-L'+str(a.cuda/'lib64'),'-L'+str(a.cuda/'lib64/stubs'),'-Wl,-rpath,'+str(a.cuda/'lib64'),
         '-lcuda','-lcupti','-o',str(binary)]
subprocess.run(command,check=True)
sha=lambda path:hashlib.sha256(path.read_bytes()).hexdigest()
(a.output/'build.json').write_text(json.dumps(dict(command=command,source_sha256=sha(source),binary_sha256=sha(binary),
    compiler=subprocess.check_output(['/usr/bin/g++-12','--version'],text=True)),indent=2)+'\n')
print(binary)
