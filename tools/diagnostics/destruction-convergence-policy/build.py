#!/usr/bin/env python3
"""Build a private four-arm convergence policy probe from the selected baseline."""
import difflib, fcntl, hashlib, io, json, shlex, shutil, subprocess, tarfile, time
from pathlib import Path
ROOT=Path(__file__).resolve().parents[3]
OUT=ROOT/'out/destruction-convergence-policy-20260913/build'
BASE='13b11af2e0aeabf4e0070931fbd8a060f383dfaf'
def sha(p):return hashlib.sha256(Path(p).read_bytes()).hexdigest()
def main():
 OUT.mkdir(parents=True,exist_ok=False); tree=OUT/'source';tree.mkdir()
 record=dict(status='preparing',baseline_commit=BASE,commands=[],inputs={},outputs={})
 def save():(OUT/'build.json').write_text(json.dumps(record,indent=2)+'\n')
 def run(cmd,cwd):
  row=dict(argv=list(map(str,cmd)),cwd=str(cwd));record['commands'].append(row);save();t=time.monotonic()
  with (OUT/'build.log').open('ab') as f:subprocess.run(row['argv'],cwd=cwd,stdout=f,stderr=subprocess.STDOUT,check=True)
  row['seconds']=time.monotonic()-t;save()
 def edit(p,changes):
  before=p.read_text();after=before
  for old,new in changes:
   assert after.count(old)==1,(str(p),old[:100],after.count(old));after=after.replace(old,new)
  p.write_text(after)
  with (OUT/'diagnostic.patch').open('a') as f:f.write(''.join(difflib.unified_diff(before.splitlines(True),after.splitlines(True),fromfile='a/'+str(p.relative_to(tree)),tofile='b/'+str(p.relative_to(tree)))))
 with (ROOT/'out/destruction-ab.lock').open('a') as lease:
  record['status']='waiting_shared_lock';save()
  fcntl.flock(lease,fcntl.LOCK_EX)
  try:
   archive=subprocess.check_output(['git','archive',BASE,'physx/include','physx/source','physx/pvdruntime/include','blast/include','demos/blast-stress-demo'],cwd=ROOT)
   with tarfile.open(fileobj=io.BytesIO(archive)) as f:f.extractall(tree,filter='data')
   shutil.copytree(ROOT/'tools/diagnostics/destruction-snapshot',tree/'probe',ignore=shutil.ignore_patterns('__pycache__','*.py'))
   (tree/'tools/diagnostics').mkdir(parents=True)
   (tree/'tools/diagnostics/destruction-snapshot').symlink_to(tree/'probe',target_is_directory=True)
   # Private helper: no public ABI change, no altered mathematics or precision.
   helper='''// Diagnostic only. Not a production policy or a convergence certificate.
#include <cstdlib>
inline unsigned convergenceDiagnosticArm() {
    static const unsigned arm=[]() {
        const char* p=std::getenv("PHYSX_CONVERGENCE_ARM");
        if(!p || !std::strcmp(p,"strict"))return 0u;
        if(!std::strcmp(p,"tolerance"))return 1u;
        if(!std::strcmp(p,"cap32"))return 2u;
        if(!std::strcmp(p,"vibe32"))return 3u;
        throw std::runtime_error("invalid PHYSX_CONVERGENCE_ARM");
    }();
    return arm;
}
inline bool acceptCappedDiagnosticResult(){return convergenceDiagnosticArm()>=2;}
'''
   (tree/'convergence-diagnostic.h').write_text(helper)
   runtime=tree/'physx/source/gpudestruction/src/PxgDestructionRuntime.cu'
   edit(runtime,[('#include <vector>','#include <vector>\n#include "convergence-diagnostic.h"'),
    ('__global__ void requireNativeConvergence(PxDestructionStageStatus* status) {\n    if(!status->converged)status->error|=4096u;',
     '__global__ void requireNativeConvergence(PxDestructionStageStatus* status,bool acceptCapped) {\n    if(!status->converged && !acceptCapped)status->error|=4096u;'),
    ('if(mCorrectionEnabled)requireNativeConvergence<<<1,1,0,mStream>>>(mStatus);',
     'if(mCorrectionEnabled)requireNativeConvergence<<<1,1,0,mStream>>>(mStatus,acceptCappedDiagnosticResult());'),
    ('mParams={};mParams.maxIterations=d.maxIterations;mParams.tolerance=d.tolerance;mParams.warmStart=d.warmStart;',
     'mParams={};mParams.maxIterations=d.maxIterations;mParams.tolerance=d.tolerance;mParams.warmStart=d.warmStart;\n'
     '            if(convergenceDiagnosticArm()&1u)mParams.tolerance=1e-3f;\n'
     '            if(acceptCappedDiagnosticResult())mParams.maxIterations=32;')])
   native=tree/'demos/blast-stress-demo/native_destruction_main.cpp'
   edit(native,[('#include "native_phase_profiler.h"','#include "native_phase_profiler.h"\n#include <cstring>\n#include <stdexcept>\n#include "convergence-diagnostic.h"'),
    ('require(status.converged,"native demo accepted an unconverged stress solve");','require(status.converged || acceptCappedDiagnosticResult(),"native demo accepted an unconverged stress solve");')])
   probe=tree/'probe/serialization-probe.cpp'
   edit(probe,[('#include "profile-markers.h"','#include "profile-markers.h"\n#include "convergence-diagnostic.h"')])
   replay=tree/'probe/file-replay.inl'
   edit(replay,[('!status.error && status.converged && status.frame==frame+1','!status.error && (status.converged || acceptCappedDiagnosticResult()) && status.frame==frame+1'),
    ('<<",\\\"stress_iterations\\\":"<<status.iterations','<<",\\\"stress_converged\\\":"<<status.converged<<",\\\"stress_iterations\\\":"<<status.iterations')])
   record['patch_sha256']=sha(OUT/'diagnostic.patch')
   old=json.loads((ROOT/'out/n24-component-multilevel-20260912/build/build.json').read_text())
   command=old['commands'][0]['argv'].copy()
   command=[a.replace(str(ROOT)+'/physx/',str(tree)+'/physx/').replace(str(ROOT)+'/blast/include',str(tree)+'/blast/include') for a in command]
   command=['-I'+str(Path(a[2:]).resolve()) if a.startswith('-I') else a for a in command]
   command.insert(1,'-I'+str(tree));command[command.index('-c')+1]=str(runtime);command[command.index('-o')+1]=str(OUT/'runtime.o');command[command.index('-MF')+1]=str(OUT/'runtime.d')
   record['status']='building_runtime';save();run(command,old['commands'][0]['cwd'])
   link=old['commands'][1]['argv'].copy();link[link.index('-o')+1]=str(OUT/'libPhysXDestructionGpuRuntime_64.so')
   link=[str(OUT/'runtime.o') if a.endswith('/PxgDestructionRuntime.cu.o') else a for a in link]
   for a in link:
    if Path(a).is_file() and Path(a)!=OUT/'runtime.o':record['inputs'][a]=sha(a)
   run(link,old['commands'][1]['cwd'])
   shutil.copy2(ROOT/'out/destruction-baseline-20260913/artifacts/libPhysXGpuActivity_64.so',OUT/'libPhysXGpuActivity_64.so')
   flags={line.split(' = ',1)[0]:shlex.split(line.split(' = ',1)[1]) for line in (ROOT/'out/destruction-sdk/reference/CMakeFiles/native_destruction_demo.dir/flags.make').read_text().splitlines() if ' = ' in line}
   cc=['/usr/bin/clang++',*flags['CXX_DEFINES'],*flags['CXX_INCLUDES'],*flags['CXX_FLAGS'],'-I'+str(tree),'-I'+str(tree/'demos/blast-stress-demo')]
   cc=[a.replace(str(ROOT)+'/physx/',str(tree)+'/physx/').replace(str(ROOT)+'/blast/',str(tree)+'/blast/') for a in cc]
   prior=json.loads((ROOT/'out/n20-requalification-20260912/build/build.json').read_text())
   for source,name,objname in [(native,'native_destruction_demo','native_destruction_main.cpp.o'),(probe,'serialization-probe','serialization-probe.o')]:
    obj=OUT/(name+'.o');run(cc+['-MMD','-MF',str(OUT/(name+'.d')),'-c',str(source),'-o',str(obj)],ROOT)
    chosen=next(c for c in prior['commands'] if '-o' in c['argv'] and c['argv'][c['argv'].index('-o')+1].endswith('/B/'+name))
    link=[str(obj) if a.endswith('/'+objname) else a for a in chosen['argv']];link[link.index('-o')+1]=str(OUT/name)
    for a in link:
     if Path(a).is_file() and Path(a)!=obj:record['inputs'][a]=sha(a)
    run(link,chosen['cwd'])
   record['outputs']={str(OUT/n):sha(OUT/n) for n in ['libPhysXGpuActivity_64.so','libPhysXDestructionGpuRuntime_64.so','native_destruction_demo','serialization-probe']}
   record['dependencies']={}
   for dep in OUT.glob('*.d'):
    record['dependencies'][dep.name]={name:sha(name) for name in shlex.split(dep.read_text().replace('\\\n',' ').split(':',1)[1])}
   record['status']='built_not_run';save()
  except BaseException as e:record.update(status='failed',error=repr(e));save();raise
if __name__=='__main__':main()
