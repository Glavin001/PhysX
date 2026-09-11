#!/usr/bin/env python3
"""Build only the isolated serialization diagnostic with existing native flags."""
from pathlib import Path
import argparse
import hashlib
import json
import shlex
import subprocess

root=Path(__file__).resolve().parents[3]
parser=argparse.ArgumentParser(description=__doc__)
parser.add_argument('output',type=Path)
args=parser.parse_args()
out=args.output.resolve();out.mkdir(parents=True,exist_ok=False)
build=root/'out/destruction-sdk/reference'
flags={line.split(' = ',1)[0]:shlex.split(line.split(' = ',1)[1])
       for line in (build/'CMakeFiles/native_destruction_demo.dir/flags.make').read_text().splitlines() if ' = ' in line}
source=Path(__file__).with_name('serialization-probe.cpp')
obj=out/'serialization-probe.o'
compile=['/usr/bin/clang++',*flags['CXX_DEFINES'],*flags['CXX_INCLUDES'],*flags['CXX_FLAGS'],
         '-I'+str(root/'demos/blast-stress-demo'),'-c',str(source),'-o',str(obj)]
link=shlex.split((build/'CMakeFiles/native_destruction_demo.dir/link.txt').read_text())
link[link.index('CMakeFiles/native_destruction_demo.dir/native_destruction_main.cpp.o')]=str(obj)
link[link.index('-o')+1]=str(out/'serialization-probe')
receipt={'source':str(source),'source_sha256':hashlib.sha256(source.read_bytes()).hexdigest(),'commands':[compile,link]}
receipt['probe_source_sha256']={str(p):hashlib.sha256(p.read_bytes()).hexdigest()
    for p in [source,*sorted(source.parent.glob('*.inl'))]}
(out/'build.json').write_text(json.dumps(receipt,indent=2)+'\n')
for command in (compile,link):subprocess.run(command,cwd=build,check=True)
for name,digest in receipt['probe_source_sha256'].items():
    if hashlib.sha256(Path(name).read_bytes()).hexdigest()!=digest:
        raise RuntimeError(f'Probe source changed during build: {name}')
receipt['binary_sha256']=hashlib.sha256((out/'serialization-probe').read_bytes()).hexdigest()
(out/'build.json').write_text(json.dumps(receipt,indent=2)+'\n')
