#!/usr/bin/env python3
"""Build the isolated ownership observation against frozen selected CUDA objects."""
import argparse,fcntl,hashlib,json,shlex,shutil,struct,subprocess,time
from pathlib import Path
ROOT=Path(__file__).resolve().parents[3]
BASE=ROOT/'out/ownership-scheduling-20260915'
p=argparse.ArgumentParser(description=__doc__);p.add_argument('name');p.add_argument('--preparation',type=Path,default=BASE/'observation-preparation.json');p.add_argument('--reuse-control',type=Path);args=p.parse_args()
out=BASE/args.name;out.mkdir(exist_ok=False)
prep=json.loads(args.preparation.read_text());tree=Path(prep['source']);control=BASE/'build-v1/control-source'
sha=lambda p:hashlib.sha256(Path(p).read_bytes()).hexdigest()
record=dict(status='starting',preparation=prep,commands=[],inputs={},dependencies={},outputs={})
def save():(out/'build.json').write_text(json.dumps(record,indent=2)+'\n')
def run(cmd,cwd,label):
    row=dict(argv=cmd,cwd=str(cwd),label=label);record['commands'].append(row);save();start=time.monotonic()
    with (out/(label+'.log')).open('x') as f:
        proc=subprocess.run(cmd,cwd=cwd,stdout=f,stderr=subprocess.STDOUT,timeout=240)
    row.update(seconds=time.monotonic()-start,exit_code=proc.returncode);save()
    print(label,proc.returncode,round(row['seconds'],2),flush=True);proc.check_returncode()
recipes=json.loads((ROOT/'out/sdk-release/compile_commands.json').read_text())
prior=json.loads((ROOT/'out/n24-component-multilevel-20260912/build/build.json').read_text())
link=prior['commands'][1]['argv'];link_dir=prior['commands'][1]['cwd']
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
        for item in prior['inputs'].values():assert sha(item['copy'])==item['sha256'],item['copy']
        for token in link:
            if Path(token).is_file():record['inputs'][token]=sha(token)
        raw=link.copy();raw[raw.index('-o')+1]=str(out/'original-relink.so')
        run(raw,link_dir,'original-relink')
        record['selected_load_sections']=load_sections(selected/'libPhysXDestructionGpuRuntime_64.so')
        record['relink_load_sections']=load_sections(out/'original-relink.so')
        assert record['selected_load_sections']==record['relink_load_sections'],'Frozen objects differ from selected loaded runtime'
        recipe=next(c for c in recipes if c['file']==str(ROOT/'physx/source/gpudestruction/src/PxgDestructionRuntime.cu'))
        for arm,source in [('A',control),('B',tree)]:
            dest=out/arm;dest.mkdir()
            cmd=shlex.split(recipe['command'])
            cmd=[token.replace(str(ROOT/'physx'),str(source/'physx')).replace(str(ROOT/'blast'),str(source/'blast')) for token in cmd]
            obj=dest/'runtime.o';dep=dest/'runtime.d';cmd[cmd.index('-o')+1]=str(obj)
            cmd+=['-MD','-MF',str(dep)]
            if arm=='A' and args.reuse_control:
                prior_control=json.loads((args.reuse_control/'build.json').read_text())
                for name,digest in prior_control['dependencies'].items():
                    if str(control) in name:assert sha(name)==digest,name
                reused=args.reuse_control/'A/runtime.o';record['inputs'][str(reused)]=sha(reused)
                shutil.copy2(reused,obj);shutil.copy2(args.reuse_control/'A/runtime.d',dep)
            else:run(cmd,recipe['directory'],arm+'-runtime')
            for token in shlex.split(dep.read_text().replace('\\\n',' ').split(':',1)[1]):
                path=Path(token);path=path if path.is_absolute() else Path(recipe['directory'])/path
                record['dependencies'][str(path)]=sha(path)
            command=[str(obj) if Path(x).name=='PxgDestructionRuntime.cu.o' else x for x in link]
            output=dest/'libPhysXDestructionGpuRuntime_64.so';command[command.index('-o')+1]=str(output)
            run(command,link_dir,arm+'-link')
            shutil.copy2(selected/'libPhysXGpuActivity_64.so',dest)
            for name in ['libPhysXGpuActivity_64.so','libPhysXDestructionGpuRuntime_64.so']:record['outputs'][str(dest/name)]=sha(dest/name)
        for name,digest in {**record['inputs'],**record['dependencies']}.items():assert sha(name)==digest,name
        for name,digest in prep['changes'].items():assert sha(tree/name)==digest,name
        record['status']='built_not_gpu_qualified'
    except BaseException as e:record.update(status='failed',error=repr(e));raise
    finally:save()
print(record['status'])
