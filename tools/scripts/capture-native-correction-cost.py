#!/usr/bin/env python3
"""Capture one isolated diagnostic replay; never label it an untraced benchmark."""
import argparse
import json
from pathlib import Path
import runpy
import subprocess
import time

ROOT = Path(__file__).resolve().parents[2]
runner = runpy.run_path(str(Path(__file__).with_name('run-destruction-timing.py')))

def main():
    p = argparse.ArgumentParser(description=__doc__)
    p.add_argument('output', type=Path)
    p.add_argument('--seconds', type=int, default=30)
    args = p.parse_args()
    out = args.output.resolve(); out.mkdir(parents=True, exist_ok=False)
    config_path = ROOT / 'tools/profiles/standard-scene-bombardment-comparison.json'
    config = json.loads(config_path.read_text())
    case = next(c for c in config['cases'] if c['id'] == 'sleeping-256')
    binary = ROOT / 'out/destruction-sdk/reference/native_destruction_demo'
    artifacts = [binary, *sorted((ROOT / 'physx/bin/linux.x86_64/release').glob('*.so'))]
    cmd = [str(binary), *config['common'], *case['args'], '--seconds', str(args.seconds),
           '--output', str(out / 'simulation'), '--profile-phases', '1', '--profile-gpu', '0']
    record = dict(command=cmd, config_sha256=runner['sha'](config_path), status='running',
                  artifacts={str(f): runner['sha'](f) for f in artifacts}, samples=[],
                  revision=subprocess.check_output(['git', 'rev-parse', 'HEAD'], cwd=ROOT, text=True).strip(),
                  diagnostic_only=True)
    def save():
        (out / 'capture.json').write_text(json.dumps(record, indent=2) + '\n')
    def observe():
        sample = runner['gpu'](); record['samples'].append(sample)
        return [v for g in sample['devices'] for v in g['processes']]
    save()
    try:
        if observe():
            raise RuntimeError('GPU occupied; no services were stopped')
        with (out / 'simulation.log').open('w') as log:
            process = subprocess.Popen(cmd, cwd=ROOT, stdout=log, stderr=subprocess.STDOUT)
            try:
                while process.poll() is None:
                    observed = observe()
                    if len(observed) > 1:
                        raise RuntimeError('Multiple GPU processes appeared')
                    if observed:
                        pid = observed[0]['pid']
                        if record.get('gpu_pid', pid) != pid:
                            raise RuntimeError('GPU process changed')
                        record['gpu_pid'] = pid
                    if len(record['samples']) > 1200:
                        raise RuntimeError('Diagnostic watchdog exceeded')
                    time.sleep(.25)
                record['exit_code'] = process.returncode
            finally:
                if process.poll() is None:
                    process.terminate(); process.wait(timeout=30)
        if record['exit_code'] or observe():
            raise RuntimeError('Simulation failed or foreign GPU process at completion')
        for f, h in record['artifacts'].items():
            if runner['sha'](Path(f)) != h:
                raise RuntimeError('Artifact changed during capture')
        runner['compress_csv'](out / 'simulation')
        record['files'] = {f.name: runner['sha'](f) for f in (out / 'simulation').iterdir() if f.is_file()}
        record['status'] = 'complete'
    except BaseException as error:
        record['status'] = 'failed'; record['error'] = str(error)
        raise
    finally:
        save()
    subprocess.run(['python3', str(Path(__file__).with_name('report-native-correction-cost.py')), str(out)], check=True)

if __name__ == '__main__':
    main()
