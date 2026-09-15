#!/usr/bin/env python3
"""Build and run the bounded prepared-factor GPU replay under the shared lease."""
import argparse
import fcntl
import hashlib
import importlib.util
import json
from pathlib import Path
import subprocess
import time

ROOT = Path(__file__).resolve().parents[3]
SOURCE = Path(__file__).resolve().parent
spec = importlib.util.spec_from_file_location('timing', ROOT/'tools/scripts/run-destruction-timing.py')
timing = importlib.util.module_from_spec(spec)
spec.loader.exec_module(timing)


def sha(path):
    return hashlib.sha256(path.read_bytes()).hexdigest()


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('inputs', type=Path)
    parser.add_argument('output', type=Path)
    parser.add_argument('--manage-desktop', action='store_true')
    parser.add_argument('--coarse',type=Path)
    parser.add_argument('--dense',type=Path,help='Prepared inverse Cholesky directory; fixed FP32 factor products')
    parser.add_argument('--rank',type=int,choices=[32,128],default=32)
    args = parser.parse_args()
    if args.coarse and args.dense:parser.error('One preconditioner per experiment')
    inputs = args.inputs.resolve(); out = args.output.resolve()
    out.mkdir(parents=True, exist_ok=False)
    library = ROOT/'.toolchains/cudss-0.8.0.10-cuda13/libcudss-linux-x86_64-0.8.0.10_cuda13-archive'
    binary = out/'probe'
    command = ['/usr/local/cuda-13.4/bin/nvcc','-std=c++17','-O3','-lineinfo','-arch=sm_120',
               '-I'+str(library/'include'),str(SOURCE/'probe.cu'),'-L'+str(library/'lib'),
               '-Xlinker=-rpath','-Xlinker='+str(library/'lib'),'-lcudss','-lcublas','-o',str(binary)]
    record = dict(status='building', scope='standalone current-equation replay, not runtime integration',
                  sources={str(p):sha(p) for p in SOURCE.iterdir() if p.suffix in ['.py','.cu','.cuh']},
                  input_report_sha256=sha(inputs/'report.json'),build_command=command,cases=[])
    if args.coarse:
        record['coarse_preparation']=json.loads((args.coarse/'report.json').read_text())
    if args.dense:
        record['dense_preparation']=json.loads((args.dense/'report.json').read_text())
        record['dense_input_sha256']=sha(args.dense/'inverse-lower.f32')
    frozen=out/'source';frozen.mkdir()
    for path in SOURCE.iterdir():
        if path.suffix in ['.py','.cu','.cuh']:(frozen/path.name).write_bytes(path.read_bytes())
    command[command.index(str(SOURCE/'probe.cu'))]=str(frozen/'probe.cu')
    def save():
        (out/'campaign.json').write_text(json.dumps(record,indent=2)+'\n')
    desktop = False
    with (ROOT/'out/destruction-ab.lock').open('a') as lease:
        fcntl.flock(lease,fcntl.LOCK_EX|fcntl.LOCK_NB)
        try:
            save()
            with (out/'build.log').open('x') as log:
                subprocess.run(command,stdout=log,stderr=subprocess.STDOUT,check=True,timeout=180)
            record['binary_sha256'] = sha(binary)
            record['gpu_before'] = timing.gpu()
            desktop = subprocess.run(['systemctl','is-active','sddm'],capture_output=True).returncode == 0
            if desktop:
                if not args.manage_desktop:
                    desktop = False
                    raise RuntimeError('Desktop is active; use authorized --manage-desktop')
                subprocess.run(['systemctl','stop','sddm'],check=True)
            deadline = time.monotonic()+30
            while True:
                current = timing.gpu()
                if not any(g['processes'] for g in current['devices']):
                    break
                if time.monotonic()>=deadline:
                    raise RuntimeError('GPU still owned after admission timeout')
                time.sleep(.5)
            record['gpu_admitted'] = current
            record['status'] = 'running'
            save()
            for step in [0,1]:
                directory = inputs/f'solve-{step}'
                case = json.loads((directory/'manifest.json').read_text())
                A = case['matrices']['A']; B = case['matrices']['B']
                cmd = [str(binary),str(inputs/'parent'),str(directory),str(case['parent_rows']),str(case['parent_nnz']),
                       str(A['rows']),str(A['nnz']),str(B['columns']),str(B['nnz']),str(case['nrhs']),str(out/f'solve-{step}')]
                if args.coarse:cmd += [str(args.coarse.resolve()/f'solve-{step}-rank-{args.rank}'),str(args.rank)]
                if args.dense:cmd += [str(args.dense.resolve()/'inverse-lower.f32')]
                row = dict(solve=step,status='running',command=cmd,
                           inputs={str(p):sha(p) for p in directory.iterdir() if p.is_file()})
                record['cases'].append(row);save()
                start = time.monotonic()
                with (out/f'solve-{step}.log').open('x') as log:
                    result = subprocess.run(cmd,stdout=log,stderr=subprocess.STDOUT,timeout=120)
                row.update(seconds=time.monotonic()-start,exit_code=result.returncode,
                           status='completed_quality_pending' if result.returncode==0 else 'failed')
                save()
                if result.returncode:
                    raise RuntimeError(f'GPU solve {step} failed; preserved log')
                row['metrics'] = json.loads((out/f'solve-{step}.json').read_text());save()
            record['gpu_after'] = timing.gpu()
            record['status'] = 'GPU_replays_complete_quality_pending'
        except BaseException as error:
            record.update(status='failed',error=repr(error));save();raise
        finally:
            if desktop:
                record['desktop_restore_exit_code'] = subprocess.run(['systemctl','start','sddm'],capture_output=True).returncode
            save()
    print(json.dumps({k:v for k,v in record.items() if k in ['status','desktop_restore_exit_code']}))


if __name__=='__main__':
    main()
