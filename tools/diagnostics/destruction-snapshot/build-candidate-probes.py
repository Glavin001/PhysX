#!/usr/bin/env python3
"""Rebuild the warm probes from the recorded recipe, linking the current SDK libraries."""
import json, os, subprocess, sys
root='/root/workspace/physx-2'; src=f'{root}/out/warm-replay-20260914'; dst=f'{root}/out/warm-replay-20260915'
lib=f'{root}/physx/bin/linux.x86_64/release'
for variant in ('plain','profile'):
    os.makedirs(f'{dst}/{variant}',exist_ok=True)
    recipe=json.load(open(f'{src}/{variant}/build.json'))
    for cmd in recipe['commands']:
        out=[]
        for a in cmd:
            a=a.replace(f'{src}/{variant}',f'{dst}/{variant}')
            if '/out/n20-requalification-20260912/build/' in a:
                name=os.path.basename(a); cand=f'{lib}/{name}'
                if os.path.exists(cand): a=cand
            out.append(a)
        print(variant, out[0], '...', out[-1][-60:]); r=subprocess.run(out)
        if r.returncode: sys.exit(f'{variant} failed: {r.returncode}')
    json.dump({'status':'complete','profiling_only':variant=='profile','source':'replayed from out/warm-replay-20260914 with current physx/bin libraries'},open(f'{dst}/{variant}/build.json','w'))
print('probes built')
