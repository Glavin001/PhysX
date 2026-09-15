#!/usr/bin/env python3
"""Run the serialization diagnostic with exact GPU/module provenance."""
import argparse
import fcntl
import importlib.util
import json
import os
from pathlib import Path
import subprocess
import time

root=Path(__file__).resolve().parents[3]
spec=importlib.util.spec_from_file_location('capture',root/'tools/scripts/run-destruction-timing.py')
c=importlib.util.module_from_spec(spec);spec.loader.exec_module(c)
parser=argparse.ArgumentParser(description=__doc__)
parser.add_argument('output',type=Path)
parser.add_argument('--binary',type=Path,required=True)
parser.add_argument('--artifacts',type=Path,required=True)
parser.add_argument('--allow-existing-graphics',action='store_true')
parser.add_argument('--allow-compute-pid',type=int,action='append',default=[])
parser.add_argument('--require-complete-shapes',action='store_true')
parser.add_argument('--sanitizer',choices=['memcheck','initcheck','synccheck'])
parser.add_argument('--profiler',choices=['nsys','ncu','pm'],help='Diagnostic first-tick capture; requires a --profile-built probe')
parser.add_argument('--ncu-kernel',default='regex:componentStressSolve',help='Target kernel function filter')
parser.add_argument('--ncu-count',type=int,default=2)
parser.add_argument('--ncu-kernel-id',help='Nsight kernel identifier; name and invocation fields support regular expressions')
parser.add_argument('--ncu-filter-mode',choices=['global','per-launch-config'],default='global')
parser.add_argument('--ncu-name-base',choices=['function','demangled','mangled'],default='function')
parser.add_argument('--ncu-mode',choices=['full','hardware'],default='full')
parser.add_argument('--ncu-replay',choices=['kernel','application'],default='kernel')
parser.add_argument('--ncu-preload',type=Path,help='Diagnostic target-only preload library; hashed in receipt')
parser.add_argument('--ncu-apply-rules',choices=['yes','no'],default='yes',help='Run optional host-side analysis rules after metric collection')
parser.add_argument('--ncu-graph',choices=['node','graph'],default='node')
parser.add_argument('--ncu-metrics',help='Explicit diagnostic metric list; recorded separately from preset')
parser.add_argument('--ncu-binary',type=Path,default=Path('/opt/nvidia/nsight-compute/2025.3.1/ncu'),help='Qualified collector; 2026.3.0 aborts on the fracture-path API trace')
parser.add_argument('--nsys-range',choices=['process','first-tick'],default='process',help='Capture full process to drain timeline events; analysis still selects only the first full tick')
parser.add_argument('--nsys-cpu',action='store_true',help='CPU DWARF samples, scheduling, OS waits and CUDA call stacks; diagnostic only')
parser.add_argument('--nsys-sampling-period',type=int,default=500000,help='CPU reference cycles per sample; increase if the kernel throttles sampling')
parser.add_argument('--nsys-allocation-trace',action='store_true',help='Separate GPU allocation/all-API diagnostic; qualify on a pilot before a campaign')
parser.add_argument('--sanitizer-blocking-launches',action='store_true',
                    help='Use the sanitizer blocking-launch diagnostic mode; never a performance capture')
parser.add_argument('--sanitizer-sync-limit',type=int,
                    help='Explicit sanitizer launch-count synchronization limit; records diagnostic API-tracking mode')
parser.add_argument('--watchdog-seconds',type=float,default=120)
parser.add_argument('--replay-prefix',type=Path)
parser.add_argument('--repetitions',type=int,default=10)
parser.add_argument('--projectile-impulse',action='store_true')
parser.add_argument('--native-args-json',type=Path,help='Capture with native demo arguments from a JSON array; output added by wrapper')
parser.add_argument('--test-args-json',type=Path,help='Run an existing native correctness command with exact JSON arguments; no output argument appended')
args=parser.parse_args()
if args.test_args_json and (args.native_args_json or args.replay_prefix or args.profiler or args.require_complete_shapes or args.projectile_impulse):
    parser.error('--test-args-json is exclusive with demo, snapshot and profiler options')
test_arguments=None
if args.test_args_json:
    test_arguments=json.loads(args.test_args_json.read_text())
    if not isinstance(test_arguments,list) or not all(isinstance(v,str) for v in test_arguments):
        parser.error('--test-args-json must contain a JSON array of strings')
if args.profiler and (args.sanitizer or not (args.replay_prefix or (args.native_args_json and args.profiler=='nsys'))):
    parser.error('Profiling requires file replay (or native arguments for Systems) and excludes sanitizer collection')
if args.ncu_count < 1:parser.error('Positive NCU launch count required')
build_receipt=args.binary.resolve().parent/'build.json'
if build_receipt.exists():
    build=json.loads(build_receipt.read_text())
    if build.get('profiling_only') and build.get('binary_sha256')==c.sha(args.binary) and not args.profiler:
        pass  # This dedicated frozen wrapper is diagnostic-only; never a timing candidate.

if args.sanitizer_blocking_launches and not args.sanitizer:
    parser.error('--sanitizer-blocking-launches requires --sanitizer')
if args.sanitizer_sync_limit is not None:
    if not args.sanitizer or args.sanitizer_blocking_launches or args.sanitizer_sync_limit < 1:
        parser.error('--sanitizer-sync-limit requires --sanitizer, a positive limit, and no blocking-launch option')
out=args.output.resolve();out.mkdir(parents=True,exist_ok=False)
arm=args.artifacts.resolve();binary=args.binary.resolve()
record={'command':[str(binary),str(out)],'binary_sha256':c.sha(binary),'samples':[],'status':'running',
        'diagnostic_environment':{k:v for k,v in os.environ.items() if k.startswith('PHYSX_SNAPSHOT_') or k in ('CUDA_LAUNCH_BLOCKING','CUDA_MODULE_LOADING','CUDA_DEVICE_MAX_CONNECTIONS')}}
record['performance_qualification'] = False
record['scope'] = 'Native phase instrumentation without external profiler injection; diagnostic only, not ordinary benchmark latency.'
if test_arguments is not None:
    record['command']=[str(binary),*test_arguments]
    record['test_arguments']=test_arguments
if args.native_args_json:
    if args.replay_prefix:raise ValueError('Native capture and file replay are exclusive')
    record['command']=[str(binary),*json.loads(args.native_args_json.read_text()),'--output',str(out/'native')]
if args.require_complete_shapes:record['command'].append('--require-complete-shapes')
if args.replay_prefix:
    prefix=args.replay_prefix.resolve()
    record['snapshot_inputs']={str(prefix)+suffix:c.sha(Path(str(prefix)+suffix)) for suffix in ('.pxbin','.destruction','.scene','.metadata.json') if Path(str(prefix)+suffix).exists()}
    record['command'] += ['--replay',str(prefix),'--repetitions',str(args.repetitions)]
    if args.projectile_impulse:record['command'].append('--projectile-impulse')
if args.profiler:
    tool=Path('/opt/nvidia/nsight-systems/2026.3.2/bin/nsys') if args.profiler in ('nsys','pm') else args.ncu_binary.resolve()
    record['profiler']={'tool':args.profiler,'version':subprocess.check_output([str(tool),'--version'],text=True).strip(),
        'performance_qualification':False,'range':'first restored complete tick; setup excluded'}
    if args.native_args_json:record['profiler']['range']='Continuous native process; full tick bounds recorded in native.frames.csv'
    record['profiler']['binary']={'path':str(tool),'sha256':c.sha(tool)}
    if args.profiler=='ncu':
        injection=tool.parent/'target/linux-desktop-glibc_2_11_3-x64/libcuda-injection.so'
        if injection.exists():record['profiler']['injection']={'path':str(injection),'sha256':c.sha(injection)}
    if args.profiler in ('nsys','pm'):
        options=['profile','--trace=cuda,nvtx','--sample=none','--cpuctxsw=none','--cuda-graph-trace=node',
                 '-o',str(out/'trace')]
        if args.nsys_cpu:
            options=['profile','--trace=cuda,nvtx,osrt','--sample=process-tree','--cpuctxsw=process-tree',
                     '--backtrace=dwarf','--samples-per-backtrace=1','--sampling-period='+str(args.nsys_sampling_period),
                     '--cudabacktrace=all:10000','--osrt-threshold=1000','--osrt-backtrace-threshold=10000',
                     '--cuda-graph-trace=node',
                     '--resolve-symbols=true','-o',str(out/'trace')]
        if args.nsys_allocation_trace:options+=['--cuda-trace-all-apis=true','--cuda-memory-usage=true']
        record['profiler']['cpu_attribution']=args.nsys_cpu
        record['profiler']['cpu_sampling_period']=args.nsys_sampling_period if args.nsys_cpu else None
        record['profiler']['allocation_trace']=args.nsys_allocation_trace
        if args.nsys_range=='first-tick':options+=['--capture-range=cudaProfilerApi','--capture-range-end=stop']
        record['profiler']['raw_timeline_scope']=args.nsys_range
    else:
        metrics=['--set','full'] if args.ncu_mode=='full' else ['--metrics',','.join([
            'gpu__time_duration.sum','sm__warps_active.avg.pct_of_peak_sustained_active',
            'smsp__warps_eligible.avg.per_cycle_active','smsp__issue_active.avg.pct_of_peak_sustained_active',
            'sm__pipe_fp64_cycles_active.avg.pct_of_peak_sustained_elapsed','dram__bytes.sum.per_second',
            'launch__registers_per_thread','launch__occupancy_limit_registers',
            'l1tex__t_sector_hit_rate.pct','lts__t_sector_hit_rate.pct',
            'l1tex__t_sectors_pipe_lsu_mem_local_op_ld.sum','l1tex__t_sectors_pipe_lsu_mem_local_op_st.sum'])]
        record['profiler']['metric_mode']=args.ncu_mode
        if args.ncu_metrics:metrics=['--metrics',args.ncu_metrics]
        record['profiler']['explicit_metrics']=args.ncu_metrics
        record['profiler']['graph_profiling']=args.ncu_graph
        record['profiler']['replay_mode']=args.ncu_replay
        selection=['--kernel-name',args.ncu_kernel]
        if args.ncu_kernel_id:selection=['--kernel-id',args.ncu_kernel_id]
        record['profiler']['kernel_selection']={'name_base':args.ncu_name_base,'identifiers':args.ncu_kernel_id,'filter':None if args.ncu_kernel_id else args.ncu_kernel,'count':args.ncu_count,'filter_mode':args.ncu_filter_mode}
        record['profiler']['apply_rules']=args.ncu_apply_rules
        options=['--profile-from-start','off','--replay-mode',args.ncu_replay,*metrics,'--kernel-name-base',args.ncu_name_base,
                 *selection,'--filter-mode',args.ncu_filter_mode,'--launch-count',str(args.ncu_count),
                 '--graph-profiling',args.ncu_graph,'--apply-rules',args.ncu_apply_rules,'--clock-control','none','--cache-control','all','--export',str(out/'counters')]
        if args.ncu_preload:
            record['profiler']['preload']={'path':str(args.ncu_preload.resolve()),'sha256':c.sha(args.ncu_preload)}
            options+=['--preload-library',str(args.ncu_preload.resolve())]
    record['command']=[str(tool),*options,*record['command']]
    if args.profiler=='pm':
        collector=root/'out/destruction-pm-sampling-20260910/final-build/collect'
        metrics='gpu__time_duration.sum,sm__warps_active_realtime.avg.pct_of_peak_sustained_elapsed,sm__inst_executed_realtime.avg.per_cycle_elapsed,dram__bytes.sum'
        record['profiler'].update(collector_sha256=c.sha(collector),counter_scope='device-wide PM sampling; includes other GPU contexts')
        record['command']=[str(collector),str(out/'pm'),metrics,'--',*record['command']]
if args.sanitizer:
    sanitizer=Path('/usr/local/cuda-13.4/bin/compute-sanitizer')
    record['sanitizer']={'tool':args.sanitizer,'binary_sha256':c.sha(sanitizer),
        'version':subprocess.check_output([str(sanitizer),'--version'],text=True).strip(),
        'blocking_launches':args.sanitizer_blocking_launches,
        'force_synchronization_limit':args.sanitizer_sync_limit,'performance_qualification':False}
    options=['--force-blocking-launches'] if args.sanitizer_blocking_launches else []
    if args.sanitizer_sync_limit is not None:
        options += ['--force-synchronization-limit',str(args.sanitizer_sync_limit)]
    record['command']=[str(sanitizer),'--tool',args.sanitizer,'--error-exitcode','97',*options,*record['command']]
def owned(pid,parent):
    seen=set()
    while pid and pid not in seen:
        if pid==parent:return True
        seen.add(pid)
        try:
            fields=Path(f'/proc/{pid}/status').read_text().splitlines()
            pid=int(next(line for line in fields if line.startswith('PPid:')).split()[1])
        except (OSError,StopIteration):return False
    return False
def save():(out/'receipt.json').write_text(json.dumps(record,indent=2)+'\n')
def require_gpu_health(sample):
    if not sample.get('devices') or 'requires reset' in json.dumps(sample).lower():
        raise RuntimeError('GPU unavailable or reset required; no capture is qualified')
# A frozen baseline coordinator may own the shared lease for the whole campaign.
# Validate live ancestry AND the kernel's lock owner; never trust an env flag alone.
lease_owner = int(os.environ.get('PHYSX_BASELINE_LOCK_OWNER', '0'))
lease_path = root/'out/destruction-ab.lock'
if lease_owner:
    assert owned(os.getpid(), lease_owner), 'Lease owner is not an ancestor'
    st = lease_path.stat()
    expected = (os.major(st.st_dev), os.minor(st.st_dev), st.st_ino)
    def owned_lease(line):
        fields = line.split()
        if len(fields) < 6 or fields[1:4] != ['FLOCK', 'ADVISORY', 'WRITE'] or fields[4] != str(lease_owner):
            return False
        dev = fields[5].split(':')
        return (int(dev[0], 16), int(dev[1], 16), int(dev[2])) == expected
    assert any(owned_lease(line) for line in Path('/proc/locks').read_text().splitlines()), 'Coordinator does not hold shared benchmark lease'
    lease_path = root/'out/destruction-baseline-20260913/child-capture.lock'
with lease_path.open('a') as lock:
    fcntl.flock(lock,fcntl.LOCK_EX|fcntl.LOCK_NB)
    initial=c.gpu();record['before']=initial
    try:require_gpu_health(initial)
    except BaseException as error:record.update(status='failed',error=str(error));save();raise
    allowed=[p for g in initial['devices'] for p in g['processes'] if
             (args.allow_existing_graphics and p['type']=='G') or p['pid'] in args.allow_compute_pid]
    record['allowed']=allowed
    if any(p not in allowed for g in initial['devices'] for p in g['processes']):raise RuntimeError('Unlisted GPU process')
    names=['libPhysXGpuActivity_64.so','libPhysXDestructionGpuRuntime_64.so']
    def signature(path):
        st=path.stat();return st.st_dev,st.st_ino,st.st_size,st.st_mtime_ns,st.st_ctime_ns
    # Hash immutable artifacts outside the measured process, not every200ms.
    # Metadata guards detect replacement or modification during capture; final
    # hashes verify contents again before a capture can qualify.
    signatures={p:signature(p) for p in [binary,*[arm/n for n in names]]}
    module_hashes={str(arm/n):c.sha(arm/n) for n in names}
    assert c.sha(binary)==record['binary_sha256']
    assert all(signature(p)==s for p,s in signatures.items())
    mapped_pids=set()
    start=time.monotonic()
    try:
        with (out/'stdout.log').open('w') as log:
            process=subprocess.Popen(record['command'],env=dict(os.environ,LD_LIBRARY_PATH=str(arm)),stdout=log,stderr=subprocess.STDOUT)
            try:
                while process.poll() is None:
                    if any(signature(p)!=s for p,s in signatures.items()):raise RuntimeError('Artifact changed during capture')
                    sample=c.gpu();record['samples'].append(sample)
                    require_gpu_health(sample)
                    extra=[p for g in sample['devices'] for p in g['processes'] if p not in allowed]
                    if len(extra)>1 and args.profiler!='pm':raise RuntimeError('Unlisted GPU process')
                    for target in extra:
                        if not owned(target['pid'],process.pid):raise RuntimeError('GPU process is not an owned target')
                    target_pid=extra[0]['pid'] if extra else process.pid
                    if args.profiler=='pm':
                        for target in extra:
                            candidate=Path(f'/proc/{target["pid"]}/maps')
                            if candidate.exists() and 'libPhysXDestructionGpuRuntime_64.so' in candidate.read_text():target_pid=target['pid'];break
                    if extra:
                        if record.get('gpu_pid',target_pid)!=target_pid and not (args.profiler=='pm' or (args.profiler=='ncu' and args.ncu_replay=='application')):raise RuntimeError('GPU identity changed')
                        record['gpu_pid']=target_pid
                        for target in extra:
                            if target['pid'] not in record.setdefault('owned_gpu_pids',[]):record['owned_gpu_pids'].append(target['pid'])
                    maps=Path(f'/proc/{target_pid}/maps')
                    if maps.exists():
                        raw=maps.read_text()
                        if all(n in raw for n in ['libPhysXGpuActivity_64.so','libPhysXDestructionGpuRuntime_64.so']):
                            paths={line.split()[-1] for line in raw.splitlines() if '/' in line}
                            if not all(str(arm/n) in paths for n in names):raise RuntimeError('Wrong mapped modules')
                            if target_pid not in mapped_pids:
                                (out/'process.maps').write_text(raw);mapped_pids.add(target_pid)
                            record['modules']=module_hashes
                    if time.monotonic()-start>args.watchdog_seconds:raise RuntimeError('Probe watchdog')
                    time.sleep(.2)
                record['exit_code']=process.returncode
            finally:
                if process.poll() is None:process.terminate();process.wait(timeout=30)
        if record['exit_code'] or 'modules' not in record:raise RuntimeError('Probe failed or missing maps')
        if any(signature(p)!=s for p,s in signatures.items()) or c.sha(binary)!=record['binary_sha256'] or any(c.sha(Path(p))!=h for p,h in module_hashes.items()):
            raise RuntimeError('Artifact identity changed during capture')
        # NVML can briefly retain old temperature/clock values after a firmware
        # fault. A zero application exit must not silently qualify an Xid run.
        kernel_log=subprocess.run(['journalctl','-k','--since','@'+str(int(initial['unix_seconds'])),
            '--no-pager','-g','NVRM: Xid'],capture_output=True,text=True)
        record['kernel_fault_audit']={'available':kernel_log.returncode==0 or (kernel_log.returncode==1 and '-- No entries --' in kernel_log.stdout and not kernel_log.stderr.strip()),'output':kernel_log.stdout.strip(),'stderr':kernel_log.stderr.strip()}
        if kernel_log.returncode==0 and 'NVRM: Xid' in kernel_log.stdout:
            raise RuntimeError('GPU Xid during capture; inspect kernel_fault_audit')
        record['status']='complete'
    except BaseException as error:
        record.update(status='failed',error=str(error));raise
    finally:
        record['after']=c.gpu();record['elapsed_monotonic_seconds']=time.monotonic()-start;save()
print(record['status'],out)
