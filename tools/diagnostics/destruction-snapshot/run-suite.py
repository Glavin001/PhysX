#!/usr/bin/env python3
"""Replay the structural and city snapshot catalog with one full tick per restore."""
import argparse
import hashlib
import json
from pathlib import Path
import subprocess
import sys

root = Path(__file__).resolve().parents[3]
p = argparse.ArgumentParser(description=__doc__)
p.add_argument('output', type=Path)
p.add_argument('--structural-inputs', type=Path, required=True)
p.add_argument('--city-inputs', type=Path, required=True)
p.add_argument('--binary', type=Path, required=True)
p.add_argument('--artifacts', type=Path, required=True)
p.add_argument('--repetitions', type=int, default=20)
p.add_argument('--sanitizer', choices=['memcheck', 'initcheck', 'synccheck'])
p.add_argument('--sanitizer-blocking-launches', action='store_true')
p.add_argument('--group', choices=['all', 'structural', 'city'], default='all')
p.add_argument('--case', action='append', default=[])
p.add_argument('--allow-existing-graphics', action='store_true')
p.add_argument('--allow-compute-pid', type=int, action='append', default=[])
p.add_argument('--manifest-only', action='store_true')
a = p.parse_args()
if a.repetitions < 2:
    p.error('At least two independent restores are required for comparison')
if a.sanitizer_blocking_launches and not a.sanitizer:
    p.error('--sanitizer-blocking-launches requires --sanitizer')

profile = json.loads((root / 'tools/profiles/destruction-snapshot-suite.json').read_text())
city = json.loads((root / 'tools/profiles/destruction-snapshot-large.json').read_text())
cases = []
for case in profile['structural']:
    cases.append(dict(case, group='structural', prefix=str(a.structural_inputs.resolve() / case['scenario'])))
for grid in city['grids']:
    for state in city['states']:
        prefix = a.city_inputs.resolve() / f"capture-{grid}-{state['regime']}" / 'native' / f"snapshot-{state['step']}"
        cases.append(dict(scenario=f"city{grid*grid}-{state['id']}", group='city', purpose=state['purpose'], prefix=str(prefix)))
unknown = set(a.case) - {c['scenario'] for c in cases}
if unknown:
    p.error(f'Unknown cases: {sorted(unknown)}')
cases = [c for c in cases if (a.group == 'all' or c['group'] == a.group) and (not a.case or c['scenario'] in a.case)]
if not cases:
    p.error('No cases selected')
# Validate and freeze every input before any GPU work. City policy sidecars are mandatory.
for case in cases:
    suffixes = ['.pxbin', '.destruction'] + (['.scene', '.metadata.json'] if case['group'] == 'city' else [])
    case['input_sha256'] = {str(path): hashlib.sha256(path.read_bytes()).hexdigest()
                            for suffix in suffixes for path in [Path(case['prefix'] + suffix)]}

out = a.output.resolve()
out.mkdir(parents=True, exist_ok=False)
(out / 'manifest.json').write_text(json.dumps(dict(protocol='one-complete-tick-per-independent-restore',
    repetitions=a.repetitions, restore_timed=False, validation_timed=False,
    sanitizer=a.sanitizer, sanitizer_blocking_launches=a.sanitizer_blocking_launches,
    performance_qualification=False, scenarios=cases), indent=2) + '\n')
if a.manifest_only:
    print(f'{len(cases)} cases validated: {out / "manifest.json"}')
    raise SystemExit(0)

common = ['--binary', str(a.binary.resolve()), '--artifacts', str(a.artifacts.resolve()),
          '--watchdog-seconds', '600', '--repetitions', str(a.repetitions)]
if a.sanitizer:
    common += ['--sanitizer', a.sanitizer]
if a.sanitizer_blocking_launches:
    common += ['--sanitizer-blocking-launches']
if a.allow_existing_graphics:
    common += ['--allow-existing-graphics']
for pid in a.allow_compute_pid:
    common += ['--allow-compute-pid', str(pid)]
results = []
for case in cases:
    # A changed saved input invalidates the campaign, rather than silently changing the workload.
    for name, digest in case['input_sha256'].items():
        if hashlib.sha256(Path(name).read_bytes()).hexdigest() != digest:
            raise RuntimeError(f'Input changed after manifest creation: {name}')
    command = [sys.executable, str(Path(__file__).with_name('run-probe.py')),
               str(out / ('complete-' + case['scenario'])), *common, '--replay-prefix', case['prefix']]
    if case.get('projectile_impulse'):
        command += ['--projectile-impulse']
    print(case['scenario'], flush=True)
    result = subprocess.run(command)
    results.append(dict(scenario=case['scenario'], exit_code=result.returncode, command=command))
    (out / 'campaign.json').write_text(json.dumps(results, indent=2) + '\n')
raise SystemExit(1 if any(r['exit_code'] for r in results) else 0)
