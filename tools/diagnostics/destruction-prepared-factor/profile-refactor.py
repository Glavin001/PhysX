#!/usr/bin/env python3
"""Profile one already qualified equation-replay binary, preserving its inputs."""
import argparse
import fcntl
import hashlib
import importlib.util
import json
from pathlib import Path
import subprocess
import time

ROOT = Path(__file__).resolve().parents[3]
spec = importlib.util.spec_from_file_location('timing', ROOT/'tools/scripts/run-destruction-timing.py')
timing = importlib.util.module_from_spec(spec)
spec.loader.exec_module(timing)


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('run', type=Path)
    parser.add_argument('output', type=Path)
    args = parser.parse_args()
    original = json.loads((args.run/'campaign.json').read_text())
    quality = args.run/'quality-strong.json'
    if not quality.exists():
        quality = args.run/'quality.json'
    assert json.loads(quality.read_text())['passed'], 'Profile only a qualified replay'
    output = args.output.resolve()
    output.mkdir(parents=True, exist_ok=False)
    command = original['command'].copy()
    assert hashlib.sha256(Path(command[0]).read_bytes()).hexdigest() == original['binary_sha256']
    for name, digest in original['inputs'].items():
        assert hashlib.sha256(Path(name).read_bytes()).hexdigest() == digest
    command[5] = str(output)
    tool = '/opt/nvidia/nsight-systems/2026.3.2/bin/nsys'
    capture = [tool,'profile','--trace=cuda,nvtx','--sample=none','--cpuctxsw=none','-o',str(output/'trace'),*command]
    record = dict(status='running', command=capture, source=str(args.run), binary_sha256=original['binary_sha256'])
    def save():
        (output/'campaign.json').write_text(json.dumps(record, indent=2)+'\n')
    desktop = False
    with (ROOT/'out/destruction-ab.lock').open('a') as lease:
        fcntl.flock(lease, fcntl.LOCK_EX | fcntl.LOCK_NB)
        try:
            record['gpu_before'] = timing.gpu()
            desktop = subprocess.run(['systemctl','is-active','sddm'],capture_output=True).returncode == 0
            if desktop:
                subprocess.run(['systemctl','stop','sddm'],check=True)
            deadline = time.monotonic()+30
            while any(device['processes'] for device in timing.gpu()['devices']):
                if time.monotonic() > deadline:
                    raise RuntimeError('GPU admission timed out')
                time.sleep(.5)
            save()
            with (output/'capture.log').open('x') as log:
                subprocess.run(capture,stdout=log,stderr=subprocess.STDOUT,check=True,timeout=120)
            with (output/'export.log').open('x') as log:
                subprocess.run([tool,'export','--type','sqlite','--output',str(output/'trace.sqlite'),str(output/'trace.nsys-rep')],stdout=log,stderr=subprocess.STDOUT,check=True,timeout=60)
            record['status'] = 'captured_quality_pending'
        except BaseException as error:
            record.update(status='failed',error=repr(error))
            raise
        finally:
            if desktop:
                record['desktop_restore_exit_code'] = subprocess.run(['systemctl','start','sddm'],capture_output=True).returncode
            save()


if __name__ == '__main__':
    main()
