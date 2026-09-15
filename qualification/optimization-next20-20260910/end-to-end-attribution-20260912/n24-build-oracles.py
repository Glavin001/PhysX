"""Fresh existing oracle consumers, using each isolated runtime's exact stress object."""
import hashlib,json,shlex,shutil,subprocess,time
from pathlib import Path
base=Path(__file__).resolve().parent;root=base.parents[1];reference=root/'out/destruction-sdk/reference'
out=base/'oracles';out.mkdir(exist_ok=False)
record=dict(status='building',commands=[],inputs={},outputs={},dependencies={})
sha=lambda p:hashlib.sha256(Path(p).read_bytes()).hexdigest()
def save():(out/'build.json').write_text(json.dumps(record,indent=2)+'\n')
def freeze(p):
    p=Path(p).resolve();key=str(p)
    if key in record['inputs']:return Path(record['inputs'][key]['copy'])
    dst=out/'inputs'/sha(p)[:16]/p.name;dst.parent.mkdir(parents=True,exist_ok=True);shutil.copy2(p,dst)
    record['inputs'][key]=dict(sha256=sha(p),copy=str(dst));assert sha(dst)==sha(p);return dst
def run(cmd):
    row=dict(command=cmd,cwd=str(reference));record['commands'].append(row);save();start=time.monotonic()
    with (out/'build.log').open('ab') as log:subprocess.run(cmd,cwd=reference,stdout=log,stderr=subprocess.STDOUT,check=True)
    row['seconds']=time.monotonic()-start;save()
def expand(args):
    result=[]
    for a in args:
        if a.startswith('@'):result+=expand(shlex.split(freeze(reference/a[1:]).read_text()))
        else:result.append(a)
    return result
try:
    runtime=json.loads((base/'build/build.json').read_text());assert runtime['status']=='built_not_gpu_qualified'
    for arm in ['A','B']:
        directory=out/arm;directory.mkdir();local=base/'build'/arm/'stressgpu'
        stress=base/'build'/arm/'stress.o';assert sha(stress)==runtime['outputs'][str(stress)]
        freeze(stress)
        for target,extension in [('gpu_resident_stress_test','cu'),('gpu_resident_stress_3d_test','cpp'),('gpu_resident_motion_modes_test','cu')]:
            recipe=reference/'CMakeFiles'/(target+'.dir')
            flags={k.strip():shlex.split(v) for line in freeze(recipe/'flags.make').read_text().splitlines() if ' = ' in line for k,v in [line.split(' = ',1)]}
            lang='CUDA' if extension=='cu' else 'CXX';includes=flags[lang+'_INCLUDES'];expanded=[];i=0
            while i<len(includes):
                if includes[i]=='--options-file':expanded+=shlex.split(freeze(reference/includes[i+1]).read_text());i+=2
                else:expanded.append(includes[i]);i+=1
            expanded=[a.replace(str(root/'blast/source/sdk/extensions/stressgpu'),str(local)) for a in expanded]
            source=freeze(root/'demos/blast-stress-demo/tests'/(target+'.'+extension));obj=directory/(target+'.o');dep=directory/(target+'.d')
            cmd=['/usr/local/cuda-13.4/bin/nvcc' if extension=='cu' else '/usr/bin/clang++',*flags[lang+'_DEFINES'],*expanded,*flags[lang+'_FLAGS'],'-c',str(source),'-o',str(obj),'-MD','-MF',str(dep)]
            # Quoted includes in the copied test source retain their original directory.
            cmd+=['-I',str(root/'demos/blast-stress-demo/tests')]
            run(cmd)
            dependencies={}
            for name in shlex.split(dep.read_text().replace('\\\n',' ').split(':',1)[1]):
                p=Path(name) if Path(name).is_absolute() else reference/name;dependencies[str(p)]=sha(p)
            record['dependencies'][arm+'/'+target]=dependencies
            cmd=expand(shlex.split(freeze(recipe/'link.txt').read_text()));cmd[cmd.index('-o')+1]=str(directory/target)
            for i,a in enumerate(cmd):
                if a.startswith('-') or (i and cmd[i-1]=='-o'):continue
                if a.endswith('/tests/'+target+'.'+extension+'.o'):cmd[i]=str(obj)
                elif a.endswith('/NvBlastExtStressGpu.cu.o'):cmd[i]=str(stress)
                elif Path(a).suffix in ['.a','.o','.so']:cmd[i]=str(freeze(Path(a) if Path(a).is_absolute() else reference/a))
            run(cmd);record['outputs'][str(directory/target)]=sha(directory/target)
    for p,item in record['inputs'].items():assert sha(p)==item['sha256']
    for values in record['dependencies'].values():
        for p,digest in values.items():assert sha(p)==digest
    record['status']='built_not_gpu_qualified'
except BaseException as exc:record.update(status='failed',error=repr(exc));save();raise
save();print(record['status'])
