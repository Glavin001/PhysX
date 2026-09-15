#!/usr/bin/env python3
"""Build isolated regression consumers using discovered CMake flags and a frozen solver.

Never installs/rebuilds the production SDK. Owns the shared exclusion lock during
builds; refuses to replace output. All commands and dependencies are recorded.
"""
import argparse
import fcntl
import hashlib
import json
import os
from pathlib import Path
import shlex
import shutil
import subprocess
import time

ROOT=Path(__file__).resolve().parents[2]
def sha(path):return hashlib.sha256(Path(path).read_bytes()).hexdigest()


def main():
    p=argparse.ArgumentParser(description=__doc__)
    p.add_argument('output',type=Path)
    p.add_argument('--solver-build',type=Path,required=True,help='Frozen directory with stress.o, stressgpu/ and both GPU modules')
    p.add_argument('--cmake-build',type=Path,default=ROOT/'out/destruction-sdk/reference')
    a=p.parse_args();out=a.output.resolve();build=a.cmake_build.resolve();solver=a.solver_build.resolve()
    for name in ('stress.o','stressgpu','libPhysXDestructionGpuRuntime_64.so','libPhysXGpuActivity_64.so'):
        if not (solver/name).exists():raise ValueError('Missing frozen solver artifact: '+name)
    with (ROOT/'out/destruction-ab.lock').open('a') as lock:
        fcntl.flock(lock,fcntl.LOCK_EX|fcntl.LOCK_NB)
        out.mkdir(parents=True,exist_ok=False)
        record=dict(schema=1,status='building',solver_build=str(solver),commands=[],dependencies={},outputs={})
        def save():(out/'build.json').write_text(json.dumps(record,indent=2)+'\n')
        def expand(tokens):
            result=[]
            for token in tokens:
                if token.startswith('@'):result.extend(expand(shlex.split((build/token[1:]).read_text())))
                else:result.append(token)
            return result
        def run(cmd):
            row=dict(command=cmd,cwd=str(build));record['commands'].append(row);save();start=time.monotonic()
            with (out/'build.log').open('ab') as log:result=subprocess.run(cmd,cwd=build,stdout=log,stderr=subprocess.STDOUT)
            row.update(exit_code=result.returncode,wall_seconds=time.monotonic()-start);save()
            result.check_returncode()
        targets=['native_physics_contract_test','native_gpu_resimulation_test','native_standard_scene_test','native_gpu_material_test','gpu_resident_stress_3d_test','gpu_resident_hierarchy_test']
        try:
            for name in ('libPhysXDestructionGpuRuntime_64.so','libPhysXGpuActivity_64.so'):
                shutil.copy2(solver/name,out/name);record['dependencies'][str(solver/name)]=sha(solver/name);record['outputs'][str(out/name)]=sha(out/name)
            for target in targets:
                original='native_standard_scene_test' if target=='native_physics_contract_test' else target
                base=build/'CMakeFiles'/f'{original}.dir'
                flags={k:shlex.split(v) for line in (base/'flags.make').read_text().splitlines() if ' = ' in line for k,v in [line.split(' = ',1)]}
                cuda=target=='gpu_resident_hierarchy_test';language='CUDA' if cuda else 'CXX'
                includes=flags[language+'_INCLUDES']
                if includes[:1]==['--options-file']:includes=shlex.split((build/includes[1]).read_text())
                if target.startswith('gpu_'):
                    includes=[s.replace(str(ROOT/'blast/source/sdk/extensions/stressgpu'),str(solver/'stressgpu')) for s in includes]
                source=ROOT/'demos/blast-stress-demo/tests'/(target+('.cu' if cuda else '.cpp'))
                obj=out/(target+'.o');dep=out/(target+'.d')
                cmd=['/usr/local/cuda-13.4/bin/nvcc' if cuda else '/usr/bin/clang++',*flags[language+'_DEFINES'],*includes,*flags[language+'_FLAGS'],'-MMD','-MF',str(dep),'-c',str(source),'-o',str(obj)]
                run(cmd)
                if target.startswith('native_') and not (out/'physx_scene.o').exists():
                    scene_cmd=cmd.copy();scene_cmd[scene_cmd.index('-c')+1]=str(ROOT/'demos/blast-stress-demo/physx_scene.cpp')
                    scene_cmd[scene_cmd.index('-o')+1]=str(out/'physx_scene.o')
                    scene_cmd[scene_cmd.index('-MF')+1]=str(out/'physx_scene.d');run(scene_cmd)
                    for token in shlex.split((out/'physx_scene.d').read_text().replace('\\\n',' ').split(':',1)[1]):
                        path=Path(token);path=path if path.is_absolute() else build/path
                        record['dependencies'][str(path.resolve())]=sha(path)
                for token in shlex.split(dep.read_text().replace('\\\n',' ').split(':',1)[1]):
                    path=Path(token);path=path if path.is_absolute() else build/path
                    record['dependencies'][str(path.resolve())]=sha(path)
                link=expand(shlex.split((base/'link.txt').read_text()))
                for i,token in enumerate(link):
                    if token.endswith('/tests/'+original+('.cu.o' if cuda else '.cpp.o')):link[i]=str(obj)
                    elif target.startswith('native_') and token.endswith('/physx_scene.cpp.o'):link[i]=str(out/'physx_scene.o')
                    elif 'gpu_resident_stress_test_core.dir' in token and token.endswith('.o'):link[i]=str(solver/'stress.o')
                link[link.index('-o')+1]=str(out/target)
                for token in link:
                    path=Path(token);path=path if path.is_absolute() else build/path
                    if path.is_file() and path.suffix in ('.a','.o','.so'):record['dependencies'][str(path.resolve())]=sha(path)
                run(link);record['outputs'][str(out/target)]=sha(out/target);save()
            for path,digest in record['dependencies'].items():
                if sha(path)!=digest:raise RuntimeError('Dependency changed during build: '+path)
            record['status']='built_not_gpu_qualified'
        except BaseException as error:record.update(status='failed',error=repr(error));raise
        finally:save()

if __name__=='__main__':main()
