#!/usr/bin/env python3
"""Matched GPU connectivity ownership comparison; never changes other GPU processes."""
import argparse
import gzip
import importlib.util
import json
import shutil
import subprocess
import time
from pathlib import Path

ROOT = Path(__file__).resolve().parents[2]
spec = importlib.util.spec_from_file_location('scaling', Path(__file__).with_name('run-native-scaling-profile.py'))
scaling = importlib.util.module_from_spec(spec)
spec.loader.exec_module(scaling)


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('output', type=Path)
    parser.add_argument('--seconds', type=int, default=12)
    parser.add_argument('--trials', type=int, default=3)
    args = parser.parse_args()
    if args.seconds < 6 or args.trials < 2:
        parser.error('require at least six seconds and one traced plus one untraced trial')
    args.output.mkdir(parents=True, exist_ok=False)
    binary = ROOT / 'out/destruction-sdk/reference/native_destruction_demo'
    files = [binary, *sorted((ROOT / 'physx/bin/linux.x86_64/release').glob('*.so'))]
    changed = subprocess.check_output(['git', 'ls-files', '--modified', '--others', '--exclude-standard', '-z'], cwd=ROOT).decode().split('\0')
    manifest = {
        'revision': subprocess.check_output(['git', 'rev-parse', 'HEAD'], cwd=ROOT, text=True).strip(),
        'artifacts': {str(f.relative_to(ROOT)): scaling.sha(f) for f in files},
        'modified_sources': {f: scaling.sha(ROOT/f) for f in changed if f and (ROOT/f).is_file()},
        'conditions': scaling.gpu(),
        'processes': subprocess.check_output(['nvidia-smi', '--query-compute-apps=pid,process_name,used_gpu_memory', '--format=csv'], text=True),
        'sleeping': False, 'isolated': False,
        'warmup_steps_excluded_in_analysis': 60, 'runs': []}
    cases = [('idle', 16), ('single-impact', 16), ('burst', 1), ('burst', 4), ('burst', 8)]
    for trial in range(args.trials):
        for case, grid in cases:
            # Alternate ordering to reduce systematic ordering bias.
            for owner in ([0, 1] if trial % 2 == 0 else [1, 0]):
                name = f'{case}-g{grid}-owner{owner}-t{trial}'
                output = args.output/name
                trace = trial == 0
                command = [str(binary), '--output', str(output), '--grid', str(grid), '--waves', '2',
                    '--seconds', str(args.seconds), '--workload', 'bombardment' if case == 'burst' else case,
                    '--launch-seconds', '1' if case == 'burst' else '0', '--stress-iterations', '8192',
                    '--profile-phases', str(int(trace)), '--profile-gpu', str(int(trace)),
                    '--preserve-contact-pairs', '1', '--gpu-island-repair', '1', '--gpu-pre-solve-islands', '1',
                    '--gpu-pre-solve-contacts', '1', '--gpu-pre-solve-support', '1', '--gpu-connectivity-owner', str(owner)]
                record = dict(name=name, case=case, grid=grid, owner=owner, trial=trial, trace=trace,
                              command=command, start_unix=time.time(), before=scaling.gpu())
                print('RUN', name, flush=True)
                with (args.output/(name+'.log')).open('w') as log:
                    process = subprocess.Popen(command, cwd=ROOT, stdout=log, stderr=subprocess.STDOUT)
                    samples = []
                    while process.poll() is None:
                        samples.append(scaling.gpu())
                        time.sleep(1)
                record.update(exit_code=process.returncode, end_unix=time.time(), gpu_samples=samples)
                manifest['runs'].append(record)
                for path in output.glob('*.csv'):
                    with path.open('rb') as src, gzip.open(str(path)+'.gz', 'wb', compresslevel=1) as dst:
                        shutil.copyfileobj(src, dst)
                    path.unlink()
                (args.output/'campaign.json').write_text(json.dumps(manifest, indent=2)+'\n')
                print('DONE', name, 'exit', process.returncode, flush=True)
                if process.returncode:
                    raise SystemExit('Incomplete run retained; fix before continuing comparison')


if __name__ == '__main__':
    main()
