#!/usr/bin/env python3
"""Run one diagnostic native trajectory with an explicitly isolated capture library."""
import argparse
import hashlib
import importlib.util
import json
import os
from pathlib import Path
import subprocess
import time

root = Path(__file__).resolve().parents[3]
p = argparse.ArgumentParser(description=__doc__)
p.add_argument('destination', type=Path)
a = p.parse_args()
dst = a.destination.resolve()
dst.mkdir()  # Preserve earlier/failed runs.
spec = importlib.util.spec_from_file_location('timing', root/'tools/scripts/run-destruction-timing.py')
r = importlib.util.module_from_spec(spec)
spec.loader.exec_module(r)
build = dst.parent/'build'
config_path = root/'qualification/baseline-rtx5060ti-20260910/config.json'
config = json.loads(config_path.read_text())
case = next(c for c in config['cases'] if c['id']=='impacts-256')
binary = root/'out/destruction-sdk/reference/native_destruction_demo'
command = [str(binary), *config['common'], *case['args'], '--seconds', '3',
           '--output', str(dst/'scene'), '--profile-phases', '0', '--profile-gpu', '0']
env = dict(os.environ)
env['LD_LIBRARY_PATH'] = str(build) + ':' + str(root/'out/install/lib') + ':' + env.get('LD_LIBRARY_PATH', '')
env['PHYSX_LOAD_CAPTURE_DIR'] = str(dst)
initial = r.gpu()
allowed = [p for g in initial['devices'] for p in g['processes'] if p['type']=='G']
assert not r.competing_processes(initial, allowed), 'Other GPU compute job active'
receipt = dict(command=command, cwd=str(root), environment={k:env[k] for k in ['LD_LIBRARY_PATH','PHYSX_LOAD_CAPTURE_DIR']},
               initial_gpu=initial, allowed_graphics=allowed, diagnostic_only=True,
               binary_sha256=r.sha(binary), config_sha256=r.sha(config_path), samples=[], status='running')
with (dst/'run.log').open('w') as log:
    proc = subprocess.Popen(command, cwd=root, env=env, stdout=log, stderr=subprocess.STDOUT)
    receipt['pid'] = proc.pid
    started = time.monotonic()
    try:
        while proc.poll() is None:
            sample = r.gpu()
            receipt['samples'].append(sample)
            competing = r.competing_processes(sample, allowed)
            assert all(p['pid']==proc.pid for p in competing), 'Another GPU process appeared'
            maps = Path(f'/proc/{proc.pid}/maps')
            if maps.exists():
                content = maps.read_text()
                if str(build/'libPhysXDestructionGpuRuntime_64.so') in content:
                    (dst/'loaded.maps').write_text(content)
            assert time.monotonic()-started<600, 'Capture watchdog'
            (dst/'receipt.json').write_text(json.dumps(receipt,indent=2)+'\n')
            time.sleep(.5)
        receipt['exit_code'] = proc.returncode
        receipt['status'] = 'complete' if proc.returncode==0 else 'failed'
    except BaseException as exc:
        receipt['error'] = str(exc)
        receipt['status'] = 'failed'
        if proc.poll() is None:
            proc.terminate()
            proc.wait(timeout=30)
        raise
    finally:
        if (dst/'loaded.maps').exists():
            paths = {line.split()[-1] for line in (dst/'loaded.maps').read_text().splitlines() if '/' in line}
            receipt['loaded_modules'] = {s:r.sha(Path(s)) for s in sorted(paths) if Path(s).is_file()}
        receipt['capture_sha256'] = {str(f.relative_to(dst)):r.sha(f) for f in sorted(dst.glob('solve-*/*')) if f.is_file()}
        receipt['final_gpu'] = r.gpu()
        (dst/'receipt.json').write_text(json.dumps(receipt,indent=2)+'\n')
assert str(build/'libPhysXDestructionGpuRuntime_64.so') in receipt.get('loaded_modules',{}), 'Diagnostic runtime was not observed loaded'
assert proc.returncode==0, f'Native capture failed: {proc.returncode}'
assert len(list(dst.glob('solve-*/manifest.json')))==4, 'Missing frozen evaluations'
print('Native trajectory and four frozen load captures completed.')
