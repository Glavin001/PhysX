#!/usr/bin/env python3
"""Build only the replay consumer against hash-verified frozen selected host libraries."""
import argparse, fcntl, hashlib, json, shlex, subprocess
from pathlib import Path
root=Path(__file__).resolve().parents[3]
p=argparse.ArgumentParser(description=__doc__);p.add_argument('output',type=Path);p.add_argument('--profile',action='store_true');a=p.parse_args()
sha=lambda p:hashlib.sha256(Path(p).read_bytes()).hexdigest()
with (root/'out/destruction-ab.lock').open('a') as lock:
    fcntl.flock(lock,fcntl.LOCK_EX|fcntl.LOCK_NB)
    out=a.output.resolve();out.mkdir(parents=True,exist_ok=False)
    frozen=root/'out/n20-requalification-20260912/build/build.json';r=json.loads(frozen.read_text())
    recipe=next(c for c in r['commands'] if c['argv'][-1:] and '-o' in c['argv'] and c['argv'][c['argv'].index('-o')+1].endswith('/B/serialization-probe'))
    link=recipe['argv'].copy();obj=out/'serialization-probe.o'
    hashes={v['copy']:v['sha256'] for v in r['inputs'].values()};hashes.update(r['outputs'])
    inputs={x:hashes[x] for x in link if x in hashes and not x.endswith('/serialization-probe') and not x.endswith('/serialization-probe.o')}
    for name,h in inputs.items():assert sha(name)==h,name
    link[next(i for i,x in enumerate(link) if x.endswith('/serialization-probe.o'))]=str(obj)
    link[link.index('-o')+1]=str(out/'serialization-probe')
    build=root/'out/destruction-sdk/reference'
    flags={line.split(' = ',1)[0]:shlex.split(line.split(' = ',1)[1]) for line in (build/'CMakeFiles/native_destruction_demo.dir/flags.make').read_text().splitlines() if ' = ' in line}
    source=Path(__file__).with_name('serialization-probe.cpp')
    command=['/usr/bin/clang++',*flags['CXX_DEFINES'],*flags['CXX_INCLUDES'],*flags['CXX_FLAGS'],'-I'+str(root/'demos/blast-stress-demo'),'-MD','-MF',str(out/'dependencies.d'),'-c',str(source),'-o',str(obj)]
    if a.profile:command.insert(1,'-DPHYSX_SNAPSHOT_PROFILE')
    sources={str(f):sha(f) for f in [source,*source.parent.glob('*.inl'),*source.parent.glob('*.h')]}
    receipt=dict(status='building',profiling_only=a.profile,commands=[command,link],frozen_recipe=str(frozen),frozen_recipe_sha256=sha(frozen),inputs_sha256=inputs,source_sha256=sources)
    def save():(out/'build.json').write_text(json.dumps(receipt,indent=2)+'\n')
    save()
    try:
        for cmd in (command,link):subprocess.run(cmd,cwd=build,check=True)
        for name,h in {**inputs,**sources}.items():assert sha(name)==h,name
        deps=shlex.split((out/'dependencies.d').read_text().replace('\\\n',' ').split(':',1)[1])
        receipt['dependencies_sha256']={str(Path(d).resolve()):sha(d) for d in deps}
        receipt.update(status='complete',binary_sha256=sha(out/'serialization-probe'))
    except Exception as e:receipt.update(status='failed',error=str(e));raise
    finally:save()
