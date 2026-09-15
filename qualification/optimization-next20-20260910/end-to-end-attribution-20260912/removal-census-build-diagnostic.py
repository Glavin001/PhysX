"""Rebuild one CUDA translation unit per arm with frozen shared link inputs."""
import hashlib,json,shlex,shutil,subprocess,time
from pathlib import Path
root=Path(__file__).resolve().parents[2];base=Path(__file__).resolve().parent
build=base/'build';build.mkdir(exist_ok=False)
source=root/'blast/source/sdk/extensions/stressgpu'
recipe=root/'out/sdk-release/sdk_gpu_source_bin/destruction-runtime/CMakeFiles/PhysXDestructionGpuRuntime.dir'
cwd=recipe.parent.parent
flags={k.strip():shlex.split(v) for line in (recipe/'flags.make').read_text().splitlines() if ' = ' in line for k,v in [line.split(' = ',1)]}
link=shlex.split((recipe/'link.txt').read_text());record=dict(status='building',commands=[],inputs={},outputs={},source_inputs={},dependencies={})
sha=lambda p:hashlib.sha256(p.read_bytes()).hexdigest()
def save():(build/'build.json').write_text(json.dumps(record,indent=2)+'\n')
def freeze(p):
    p=p.resolve()
    if str(p) in record['inputs']:return Path(record['inputs'][str(p)]['copy'])
    dst=build/'inputs'/sha(p)[:16]/p.name;dst.parent.mkdir(parents=True,exist_ok=True);shutil.copy2(p,dst)
    record['inputs'][str(p)]=dict(copy=str(dst),sha256=sha(p));assert sha(dst)==sha(p);return dst
for p in sorted(source.rglob('*')):
    if p.is_file():record['source_inputs'][str(p)]=sha(p)
for i,arg in enumerate(link):
    if arg.startswith('-') or (i and link[i-1]=='-o'):continue
    p=Path(arg) if Path(arg).is_absolute() else cwd/arg
    if p.suffix in ['.o','.a','.so'] and not p.name.endswith('NvBlastExtStressGpu.cu.o'):freeze(p)
for name in ['flags.make','link.txt']:freeze(recipe/name)
def run(argv):
    begin=time.monotonic();row=dict(argv=list(map(str,argv)),cwd=str(cwd));record['commands'].append(row);save()
    with (build/'build.log').open('ab') as log:subprocess.run(argv,cwd=cwd,stdout=log,stderr=subprocess.STDOUT,check=True)
    row['seconds']=time.monotonic()-begin;save()
try:
    prep=json.loads((base/'preparation.json').read_text());record['preparation']=prep
    for arm in ['B']:
        directory=build/arm;directory.mkdir();local=directory/'stressgpu';shutil.copytree(source,local)
        # Use the frozen selected-policy source, not unaccepted N14 history.
        for name in ['StressComponentIteration.cuh','StressNativeHierarchy.cuh']:
            original=root/'out/n14-closure-20260912'/(name+'.B')
            shutil.copy2(freeze(original),local/'detail'/name)
        for rel in prep['changed_sources']:
            shutil.copy2(freeze(base/Path(rel).name),local/'detail'/Path(rel).name)
        obj=directory/'stress.o'
        cmd=['/usr/local/cuda-13.4/bin/nvcc',*flags['CUDA_DEFINES'],'-DBLAST_GPU_COMPONENT_PHASE_PROBE','-DBLAST_GPU_COMPONENT_WORK_CAPTURE',*flags['CUDA_INCLUDES'],*flags['CUDA_FLAGS'],'-c',str(local/'NvBlastExtStressGpu.cu'),'-o',str(obj),'-MD','-MF',str(directory/'dependencies.d')]
        run(cmd)
        deps=(directory/'dependencies.d').read_text().replace('\\\n',' ');record['dependencies'][arm]={}
        for name in shlex.split(deps.split(':',1)[1]):
            p=Path(name) if Path(name).is_absolute() else cwd/name
            record['dependencies'][arm][str(p)]=sha(p)
        cmd=link.copy();out=directory/'libPhysXDestructionGpuRuntime_64.so';cmd[cmd.index('-o')+1]=str(out)
        for i,arg in enumerate(cmd):
            if arg.startswith('-') or (i and cmd[i-1]=='-o'):continue
            if arg.endswith('NvBlastExtStressGpu.cu.o'):cmd[i]=str(obj);continue
            p=(Path(arg) if Path(arg).is_absolute() else cwd/arg).resolve()
            if str(p) in record['inputs']:cmd[i]=record['inputs'][str(p)]['copy']
        run(cmd)
        activity=root/'out/snapshot-reset-20260911/local-artifacts/libPhysXGpuActivity_64.so';shutil.copy2(freeze(activity),directory/activity.name)
        for p in [out,directory/activity.name,obj]:record['outputs'][str(p)]=sha(p)
    for path,item in record['inputs'].items():assert sha(Path(path))==item['sha256']
    for path,digest in record['source_inputs'].items():assert sha(Path(path))==digest
    for arm,deps in record['dependencies'].items():
        for path,digest in deps.items():assert sha(Path(path))==digest
    record['status']='built_not_gpu_qualified'
except BaseException as exc:record.update(status='failed',error=repr(exc));save();raise
save();print(record['status'])
