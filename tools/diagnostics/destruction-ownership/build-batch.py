#!/usr/bin/env python3
"""Rebuild the ownership experiment and its control without installing an SDK."""
import argparse, difflib, fcntl, hashlib, json, shlex, shutil, subprocess, time
from pathlib import Path

ROOT=Path(__file__).resolve().parents[3]
BASE=ROOT/'out/ownership-scheduling-20260915'
sha=lambda p:hashlib.sha256(Path(p).read_bytes()).hexdigest()
p=argparse.ArgumentParser(description=__doc__);p.add_argument('name');a=p.parse_args()
out=BASE/a.name;out.mkdir(exist_ok=False)
tree=BASE/'source';control=out/'control-source';shutil.copytree(tree,control)
baseline=json.loads((BASE/'source-baseline.json').read_text())
changed={}
patch=[]
for name,original in baseline['files'].items():
    if sha(tree/name)!=original:
        raw=subprocess.check_output(['git','show',baseline['commit']+':'+name],cwd=ROOT)
        (control/name).write_bytes(raw)
        changed[name]=sha(tree/name)
        patch.extend(difflib.unified_diff(raw.decode().splitlines(True),(tree/name).read_text().splitlines(True),fromfile='a/'+name,tofile='b/'+name))
for path in tree.rglob('*'):
    if path.is_file() and str(path.relative_to(tree)) not in baseline['files']:
        name=str(path.relative_to(tree));changed[name]=sha(path)
        patch.extend(difflib.unified_diff([],path.read_text().splitlines(True),fromfile='/dev/null',tofile='b/'+name))
(out/'candidate.patch').write_text(''.join(patch))
record=dict(status='preparing',baseline_commit=baseline['commit'],source=str(tree),changed_sha256=changed,
            patch_sha256=sha(out/'candidate.patch'),commands=[],dependencies={},inputs={},outputs={})
def save():(out/'build.json').write_text(json.dumps(record,indent=2)+'\n')
def run(cmd,cwd,label):
    row=dict(argv=list(map(str,cmd)),cwd=str(cwd),label=label);record['commands'].append(row);save()
    start=time.monotonic()
    with (out/(label+'.log')).open('w') as f:
        result=subprocess.run(cmd,cwd=cwd,stdout=f,stderr=subprocess.STDOUT,timeout=300)
    row.update(seconds=time.monotonic()-start,exit_code=result.returncode);save()
    print(label,result.returncode,round(row['seconds'],2),flush=True)
    result.check_returncode()
old=json.loads((ROOT/'out/n20-requalification-20260912/build/build.json').read_text())
archive=ROOT/'out/n20-requalification-20260912/build/B/libPhysX_static_64.a'
assert sha(archive)==old['outputs'][str(archive)]
recipes=json.loads((ROOT/'out/sdk-release/compile_commands.json').read_text())
targets=['ScNPhaseCore.cpp','ScShapeSimBase.cpp','NpShapeManager.cpp','NpScene.cpp']
warm={mode:json.loads((ROOT/'out/warm-replay-20260914'/mode/'build.json').read_text()) for mode in ['plain','profile']}
test_recipes={}
for c in old['commands']:
    argv=c['argv']
    if '-o' not in argv:continue
    output=Path(argv[argv.index('-o')+1])
    if output.parent.name=='B' and output.name.startswith('native_'):test_recipes[output.name]=c

with (ROOT/'out/destruction-ab.lock').open('a') as lease:
    fcntl.flock(lease,fcntl.LOCK_EX|fcntl.LOCK_NB)
    try:
        record['status']='building';save()
        for arm in ['A','B','audit']:
            dest=out/arm;dest.mkdir();source=control if arm=='A' else tree
            local=dest/archive.name;shutil.copy2(out/'B'/archive.name if arm=='audit' else archive,local)
            for name in (['ScNPhaseCore.cpp'] if arm=='audit' else targets):
                recipe=next(c for c in recipes if c['file'].endswith('/'+name))
                cmd=shlex.split(recipe['command']);original=Path(recipe['file']);rel=original.relative_to(ROOT)
                cmd=[x.replace(str(ROOT/'physx'),str(source/'physx')) for x in cmd]
                cmd[cmd.index('-o')+1]=str(dest/(name+'.o'))
                cmd+=['-MD','-MF',str(dest/(name+'.d'))]
                if arm=='audit':cmd.insert(1,'-DPHYSX_DESTRUCTION_OWNER_BATCH_AUDIT')
                run(cmd,recipe['directory'],arm+'-'+name)
                dep=(dest/(name+'.d')).read_text().replace('\\\n',' ').split(':',1)[1]
                for token in shlex.split(dep):
                    path=Path(token);path=path if path.is_absolute() else Path(recipe['directory'])/path
                    record['dependencies'][str(path)]=sha(path)
                run(['ar','r',str(local),str(dest/(name+'.o'))],ROOT,arm+'-archive-'+name)
            for mode in ['plain','profile']:
                recipe=warm[mode];cmd=recipe['commands'][1].copy()
                for name,digest in recipe['inputs_sha256'].items():
                    assert sha(name)==digest,name
                    record['inputs'][name]=digest
                # The replay source/object and all non-PhysX dependencies are
                # exactly the qualified warm consumer. Only its host archive changes.
                for i,arg in enumerate(cmd):
                    if arg.endswith('/libPhysX_static_64.a'):cmd[i]=str(local)
                    elif Path(arg).is_file():record['inputs'][arg]=sha(arg)
                output=dest/('serialization-probe'+('-profile' if mode=='profile' else ''))
                cmd[cmd.index('-o')+1]=str(output)
                run(cmd,ROOT/'out/destruction-sdk/reference',arm+'-warm-'+mode)
                record['outputs'][str(output)]=sha(output)
            if arm!='audit':
                for name,recipe in test_recipes.items():
                    cmd=recipe['argv'].copy()
                    for i,arg in enumerate(cmd):
                        if arg.endswith('/libPhysX_static_64.a'):cmd[i]=str(local)
                        elif Path(arg).is_file():record['inputs'][arg]=sha(arg)
                    output=dest/name;cmd[cmd.index('-o')+1]=str(output)
                    run(cmd,recipe['cwd'],arm+'-'+name)
                    record['outputs'][str(output)]=sha(output)
            record['outputs'][str(local)]=sha(local)
        for name,digest in {**record['dependencies'],**record['inputs']}.items():assert sha(name)==digest,name
        for name,digest in changed.items():assert sha(tree/name)==digest,name
        record['status']='built_not_gpu_qualified'
    except BaseException as error:
        record.update(status='failed',error=repr(error));raise
    finally:save()
print(record['status'])
