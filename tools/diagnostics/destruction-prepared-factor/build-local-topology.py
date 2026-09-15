#!/usr/bin/env python3
"""Isolate the selected runtime and rebuild connectivity only in changed components."""
from pathlib import Path
import difflib
import fcntl
import hashlib
import io
import json
import shlex
import shutil
import subprocess
import tarfile
import time
import argparse

ROOT=Path(__file__).resolve().parents[3]
BASELINE='13b11af2e0aeabf4e0070931fbd8a060f383dfaf'


def sha(p):return hashlib.sha256(Path(p).read_bytes()).hexdigest()


def candidate(text):
    def replace(old,new):
        nonlocal text
        if text.count(old)!=1:raise ValueError('unexpected selected source: '+old[:90])
        text=text.replace(old,new)
    replace('float* health, unsigned n, unsigned m, unsigned* forest)\n',
            'float* health, unsigned n, unsigned m, unsigned* forest,\n'
            '    const unsigned* oldNodes=nullptr, const unsigned* oldBonds=nullptr,\n'
            '    const unsigned* changed=nullptr, const ExtStressGpuDeviceTopologyStatus* state=nullptr)\n')
    replace('    if (i < max(n, m)) identity[i] = i;\n'
            '    if (i < n) { parent[i] = inertia[i].linear > 0 ? i : kNoIsland; rootFlags[i] = 0; }\n'
            '    if (i < m) { if(forest)forest[i]=0; if(batch->mask && !batch->mask[i])health[i]=0; }',
            '    const bool local = changed && state && state->initialized;\n'
            '    // Identity is immutable. Old minimum-node roots remain valid because\n'
            '    // resident topology accepts deletions only, never merges/resurrection.\n'
            '    if (i < max(n, m) && !local) identity[i] = i;\n'
            '    if (i < n) {\n'
            '        if (!local || (oldNodes[i]!=kNoIsland && changed[oldNodes[i]]))\n'
            '            parent[i] = inertia[i].linear > 0 ? i : kNoIsland;\n'
            '        if (!changed) rootFlags[i] = 0;\n'
            '    }\n'
            '    if (i < m) {\n'
            '        if (forest && (!local || (oldBonds[i]!=kNoIsland && changed[oldBonds[i]]))) forest[i]=0;\n'
            '        if (batch->mask && !batch->mask[i]) health[i]=0;\n'
            '    }')
    replace('const float* health, const Inertia* inertia, unsigned m, unsigned* parent, unsigned* forest)\n',
            'const float* health, const Inertia* inertia, unsigned m, unsigned* parent, unsigned* forest,\n'
            '    const unsigned* oldBonds=nullptr, const unsigned* changed=nullptr,\n'
            '    const ExtStressGpuDeviceTopologyStatus* state=nullptr)\n')
    replace('    if (i >= m || health[i] <= 0) return;\n    unsigned a = node0[i], b = node1[i];',
            '    if (i >= m || health[i] <= 0) return;\n'
            '    if (changed && state && state->initialized &&\n'
            '        (oldBonds[i]==kNoIsland || !changed[oldBonds[i]])) return;\n'
            '    unsigned a = node0[i], b = node1[i];')
    replace('__global__ void flattenDeviceStressTopology(unsigned* parent, unsigned n)',
            '__global__ void flattenDeviceStressTopology(unsigned* parent, unsigned n,\n'
            '    const unsigned* oldNodes=nullptr, const unsigned* changed=nullptr,\n'
            '    const ExtStressGpuDeviceTopologyStatus* state=nullptr)')
    replace('    if (i < n && atomicAdd(parent + i, 0u) != kNoIsland)',
            '    if (i < n && changed && state && state->initialized &&\n'
            '        (oldNodes[i]==kNoIsland || !changed[oldNodes[i]])) return;\n'
            '    if (i < n && atomicAdd(parent + i, 0u) != kNoIsland)')
    start='        initializeDeviceStressTopology<<<std::max(nodeBlocks,bondBlocks),kBlockSize,0,captureStream>>>(batch,b.inertia,parent,identity,rootFlags,b.health,b.n,b.m,forest);\n'
    middle='        connectDeviceStressTopology<<<bondBlocks,kBlockSize,0,captureStream>>>(b.node0,b.node1,b.health,b.inertia,b.m,parent,forest);\n'
    end='        flattenDeviceStressTopology<<<nodeBlocks,kBlockSize,0,captureStream>>>(parent,b.n);'
    replace(start+middle+end,
            '#ifdef PHYSX_RESIDENT_DESTRUCTION\n'
            '        // Consume the old-component dirty flags before rootFlags is reused.\n'
            '        initializeDeviceStressTopology<<<std::max(nodeBlocks,bondBlocks),kBlockSize,0,captureStream>>>(batch,b.inertia,parent,identity,rootFlags,b.health,b.n,b.m,forest,b.nodeIsland,b.bondIsland,rootFlags,state);\n'
            '        connectDeviceStressTopology<<<bondBlocks,kBlockSize,0,captureStream>>>(b.node0,b.node1,b.health,b.inertia,b.m,parent,forest,b.bondIsland,rootFlags,state);\n'
            '        flattenDeviceStressTopology<<<nodeBlocks,kBlockSize,0,captureStream>>>(parent,b.n,b.nodeIsland,rootFlags,state);\n'
            '        checkCuda(cudaMemsetAsync(rootFlags,0,sizeof(unsigned)*b.n,captureStream), "clear rebuilt stress roots");\n'
            '#else\n'+start+middle+end+'\n#endif')
    return text


def prepared_neighbors(text):
    kernel='''// Immutable endpoints/inertia and accepted bond liveness completely define
// this adjacency product. Build it at its producer, never in a current-load solve.
__global__ void refreshDeviceStressOperatorNeighbors(const DeviceStressTopologyBatch* batch,
    const ExtStressGpuDeviceTopologyStatus* state, const unsigned* begin, const unsigned* refs,
    const unsigned* node0, const unsigned* node1, const Inertia* inertia, const float* health,
    const unsigned* oldNodes, const unsigned* changed, unsigned* neighbors, unsigned nodes)
{
    const unsigned node=blockIdx.x*blockDim.x+threadIdx.x;
    if(node>=nodes)return;
    if(state->initialized && (oldNodes[node]==kNoIsland || !changed[oldNodes[node]]))return;
    for(unsigned i=begin[node];i<begin[node+1];++i) {
        const unsigned ref=refs[i];
        if(ref==kDeadBondRef) { neighbors[i]=kNoIsland;continue; }
        const unsigned edge=ref&0x7fffffffu;
        if(health[edge]<=0 || (batch->mask && !batch->mask[edge])) { neighbors[i]=kNoIsland;continue; }
        const unsigned other=(ref>>31)?node0[edge]:node1[edge];
        const auto weight=inertia[other];
        neighbors[i]=(weight.angular==0 && weight.linear==0)?kNoIsland:other;
    }
}
'''
    marker='__global__ void initializeDeviceStressTopology('
    assert text.count(marker)==1
    text=text.replace(marker,kernel+marker)
    marker='        clearChangedStressWarmStart<<<bondBlocks,kBlockSize,0,captureStream>>>(state,b.bondIsland,rootFlags,b.impulses,b.m);'
    assert text.count(marker)==1
    return text.replace(marker,marker+'''
        refreshDeviceStressOperatorNeighbors<<<nodeBlocks,kBlockSize,0,captureStream>>>(batch,state,
            b.nodeBondBegin,b.nodeBondRef,b.node0,b.node1,b.inertia,b.health,b.nodeIsland,rootFlags,
            inverse.operatorOther,b.n);''')


def main():
    parser=argparse.ArgumentParser(description=__doc__);parser.add_argument('output',type=Path)
    parser.add_argument('--mechanism',choices=['connectivity','neighbors'],default='connectivity')
    args=parser.parse_args();out=args.output.resolve();out.mkdir(parents=True,exist_ok=False)
    old=ROOT/'out/n24-component-multilevel-20260912';prior=json.loads((old/'build/build.json').read_text())
    record=dict(status='preparing',baseline_commit=BASELINE,mechanism=args.mechanism,commands=[],outputs={})
    def save():(out/'build.json').write_text(json.dumps(record,indent=2)+'\n')
    def run(cmd,cwd):
        row=dict(argv=cmd,cwd=str(cwd));record['commands'].append(row);save();start=time.monotonic()
        with (out/'build.log').open('ab') as log:subprocess.run(cmd,cwd=cwd,stdout=log,stderr=subprocess.STDOUT,check=True)
        row['seconds']=time.monotonic()-start;save()
    with (ROOT/'out/destruction-ab.lock').open('a') as lease:
        fcntl.flock(lease,fcntl.LOCK_EX|fcntl.LOCK_NB)
        try:
            prefix='blast/source/sdk/extensions/stressgpu'
            data=subprocess.check_output(['git','archive',BASELINE,prefix],cwd=ROOT)
            tree=out/'source';tree.mkdir()
            with tarfile.open(fileobj=io.BytesIO(data)) as archive:
                for member in archive.getmembers():
                    if member.isfile():
                        rel=Path(member.name).relative_to(prefix);dest=tree/rel
                        dest.parent.mkdir(parents=True,exist_ok=True);dest.write_bytes(archive.extractfile(member).read())
            for name,digest in prior['dependencies']['A'].items():
                path=Path(name);old_tree=old/'build/A/stressgpu'
                if path.is_relative_to(old_tree):
                    assert sha(tree/path.relative_to(old_tree))==digest
                else:assert sha(path)==digest
            path=tree/'NvBlastExtStressGpuTopology.cuh';before=path.read_text()
            after=candidate(before) if args.mechanism=='connectivity' else prepared_neighbors(before)
            path.write_text(after)
            patch=''.join(difflib.unified_diff(before.splitlines(True),after.splitlines(True),fromfile='a/'+prefix+'/'+path.name,tofile='b/'+prefix+'/'+path.name))
            if args.mechanism=='neighbors':
                relative='detail/StressComponentIteration.cuh';p=tree/relative;old_text=p.read_text()
                first=old_text.index('// Build from this solve\'s validated live CSR before iteration.')
                last=old_text.index('__global__ void componentStressSolve',first)
                new_text=old_text[:first]+old_text[last:]
                call='        cacheNativeOperatorNeighbors(a,c.nodes+begin,count);\n'
                assert new_text.count(call)==1
                new_text=new_text.replace(call,'');p.write_text(new_text)
                patch+=''.join(difflib.unified_diff(old_text.splitlines(True),new_text.splitlines(True),fromfile='a/'+prefix+'/'+relative,tofile='b/'+prefix+'/'+relative))
            (out/'candidate.patch').write_text(patch)
            record['candidate_patch_sha256']=sha(out/'candidate.patch')
            record['sources']={str(p):sha(p) for p in tree.rglob('*') if p.is_file()};record['status']='building';save()
            obj=out/'stress.o';dep=out/'dependencies.d'
            cmd=prior['commands'][0]['argv'].copy();cmd[cmd.index('-c')+1]=str(tree/'NvBlastExtStressGpu.cu');cmd[cmd.index('-o')+1]=str(obj);cmd[cmd.index('-MF')+1]=str(dep)
            run(cmd,prior['commands'][0]['cwd'])
            link=prior['commands'][1]['argv'].copy();link[link.index('-o')+1]=str(out/'libPhysXDestructionGpuRuntime_64.so')
            link=[str(obj) if a==str(old/'build/A/stress.o') else a for a in link]
            # Validate all reused runtime link inputs, not merely the stress TU.
            for token in link:
                p=Path(token)
                if p.suffix=='.o' and p!=obj:record.setdefault('reused_link_inputs',{})[str(p)]=sha(p)
            run(link,prior['commands'][1]['cwd'])
            control=ROOT/'out/destruction-baseline-20260913/artifacts/libPhysXGpuActivity_64.so'
            shutil.copy2(control,out/control.name)
            for name in ['libPhysXDestructionGpuRuntime_64.so',control.name]:record['outputs'][str(out/name)]=sha(out/name)
            record['dependencies']={name:sha(name) for name in shlex.split(dep.read_text().replace('\\\n',' ').split(':',1)[1])}
            record['status']='built_not_gpu_qualified'
        except BaseException as error:record.update(status='failed',error=repr(error));save();raise
        save()


if __name__=='__main__':main()
