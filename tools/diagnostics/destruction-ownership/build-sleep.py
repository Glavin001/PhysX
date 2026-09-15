#!/usr/bin/env python3
"""Build the isolated native sleep commit, checking the original GPU link first."""
import argparse, fcntl, hashlib, json, shlex, shutil, struct, subprocess, time
from pathlib import Path
ROOT=Path(__file__).resolve().parents[3]
BASE=ROOT/'out/ownership-scheduling-20260915'
p=argparse.ArgumentParser(description=__doc__);p.add_argument('name');args=p.parse_args()
out=BASE/args.name;out.mkdir(exist_ok=False)
tree=BASE/'sleep-source';control=BASE/'build-v1/control-source'
prep=json.loads((BASE/'sleep-preparation.json').read_text())
sha=lambda p:hashlib.sha256(Path(p).read_bytes()).hexdigest()
record=dict(status='starting',preparation=prep,commands=[],inputs={},dependencies={},outputs={})
def save():(out/'build.json').write_text(json.dumps(record,indent=2)+'\n')
def run(cmd,cwd,label):
    row=dict(argv=cmd,cwd=str(cwd),label=label);record['commands'].append(row);save();start=time.monotonic()
    with (out/(label+'.log')).open('x') as f:
        p=subprocess.run(cmd,cwd=cwd,stdout=f,stderr=subprocess.STDOUT,timeout=240)
    row.update(seconds=time.monotonic()-start,exit_code=p.returncode);save()
    print(label,p.returncode,round(row['seconds'],2),flush=True);p.check_returncode()
recipes=json.loads((ROOT/'out/sdk-release/compile_commands.json').read_text())
link_dir=ROOT/'out/sdk-release/sdk_gpu_source_bin'
link=shlex.split((link_dir/'CMakeFiles/PhysXGpu.dir/link.txt').read_text())
# CMake link.txt is shell text; direct argv invocation must remove the shell's
# dollar escape inside the RPATH token, without expanding it in Python or shell.
link=[token.replace('\\$ORIGIN','$ORIGIN') for token in link]
selected=ROOT/'out/destruction-baseline-20260913/artifacts'
def load_sections(path):
    data=Path(path).read_bytes();offset=struct.unpack_from('<Q',data,40)[0]
    count=struct.unpack_from('<H',data,60)[0];strings_index=struct.unpack_from('<H',data,62)[0]
    stride=struct.unpack_from('<H',data,58)[0]
    sections=[struct.unpack_from('<IIQQQQIIQQ',data,offset+i*stride) for i in range(count)]
    item=sections[strings_index];strings=data[item[4]:item[4]+item[5]];result={}
    for item in sections:
        name=strings[item[0]:].split(b'\0')[0].decode()
        if not item[2]&2 or name=='.note.gnu.build-id':continue
        payload=b'' if item[1]==8 else data[item[4]:item[4]+item[5]]
        result[name]=[item[1],item[2],item[3],item[5],hashlib.sha256(payload).hexdigest()]
    return result
with (ROOT/'out/destruction-ab.lock').open('a') as lease:
    fcntl.flock(lease,fcntl.LOCK_EX|fcntl.LOCK_NB)
    try:
        record['status']='building';save()
        for token in link:
            path=Path(token);path=path if path.is_absolute() else link_dir/path
            if path.is_file():record['inputs'][str(path)]=sha(path)
        # Attest reused object/archive inputs against the selected actual .so.
        raw=link.copy();raw[raw.index('-o')+1]=str(out/'original-relink.so')
        run(raw,link_dir,'original-relink')
        record['original_relink_sha256']=sha(out/'original-relink.so')
        record['selected_load_sections']=load_sections(selected/'libPhysXGpuActivity_64.so')
        record['relink_load_sections']=load_sections(out/'original-relink.so')
        # Installed GCC CRT metadata changed from .2 to .3; .comment/build-id
        # differ. Every loaded code/data/dynamic section must still match.
        assert record['selected_load_sections']==record['relink_load_sections'],'Reused GPU objects do not reproduce selected runtime sections'
        for arm,source in [('A',control),('B',tree)]:
            dest=out/arm;dest.mkdir();substitutions={}
            for name in ['PxgKernelWrangler.cpp','PxgSimulationController.cpp','updateBodiesAndShapes.cu']:
                recipe=next(c for c in recipes if c['file'].endswith('/'+name))
                cmd=shlex.split(recipe['command']);original_obj=Path(recipe['directory'])/cmd[cmd.index('-o')+1]
                cmd=[token.replace(str(ROOT/'physx'),str(source/'physx')) for token in cmd]
                obj=dest/(name+'.o');dep=dest/(name+'.d');cmd[cmd.index('-o')+1]=str(obj)
                cmd+=['-MD','-MF',str(dep)];run(cmd,recipe['directory'],arm+'-'+name)
                substitutions[str(original_obj)]=str(obj)
                for token in shlex.split(dep.read_text().replace('\\\n',' ').split(':',1)[1]):
                    path=Path(token);path=path if path.is_absolute() else Path(recipe['directory'])/path
                    record['dependencies'][str(path)]=sha(path)
            command=link.copy();output=dest/'libPhysXGpuActivity_64.so';command[command.index('-o')+1]=str(output)
            for i,token in enumerate(command):
                path=Path(token);path=path if path.is_absolute() else link_dir/path
                if str(path) in substitutions:command[i]=substitutions[str(path)]
            assert sum(x in substitutions.values() for x in command)==3
            run(command,link_dir,arm+'-link')
            shutil.copy2(selected/'libPhysXDestructionGpuRuntime_64.so',dest)
            for name in ['libPhysXGpuActivity_64.so','libPhysXDestructionGpuRuntime_64.so']:record['outputs'][str(dest/name)]=sha(dest/name)
        for name,digest in {**record['inputs'],**record['dependencies']}.items():assert sha(name)==digest,name
        for name,digest in prep['changes'].items():assert sha(tree/name)==digest,name
        record['status']='built_not_gpu_qualified'
    except BaseException as e:record.update(status='failed',error=repr(e));raise
    finally:save()
print(record['status'])
