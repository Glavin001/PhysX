#!/usr/bin/env python3
"""Replay the structural and city snapshot catalog with one full tick per restore."""
import argparse
import hashlib
import json
import os
from pathlib import Path
import subprocess
import sys
import time

started = time.monotonic()

root = Path(__file__).resolve().parents[3]
p = argparse.ArgumentParser(description=__doc__)
p.add_argument('output', type=Path)
p.add_argument('--structural-inputs', type=Path, required=True)
p.add_argument('--city-inputs', type=Path, required=True)
p.add_argument('--binary', type=Path, required=True)
p.add_argument('--artifacts', type=Path, required=True)
p.add_argument('--repetitions', type=int, help='Full-suite repeats (default 20); light uses its frozen per-case counts')
p.add_argument('--preset', choices=['full', 'light'], default='full')
p.add_argument('--sanitizer', choices=['memcheck', 'initcheck', 'synccheck'])
p.add_argument('--sanitizer-blocking-launches', action='store_true')
p.add_argument('--group', choices=['all', 'structural', 'city'], default='all')
p.add_argument('--case', action='append', default=[])
p.add_argument('--allow-existing-graphics', action='store_true')
p.add_argument('--allow-compute-pid', type=int, action='append', default=[])
p.add_argument('--manifest-only', action='store_true')
a = p.parse_args()
if a.repetitions is not None and a.repetitions < 2:
    p.error('At least two independent restores are required for comparison')
if a.sanitizer_blocking_launches and not a.sanitizer:
    p.error('--sanitizer-blocking-launches requires --sanitizer')
if a.preset == 'light' and (a.repetitions is not None or a.case or a.group != 'all'):
    p.error('The light preset has fixed cases/repetitions; use full with --case for custom runs')
light_path = root / 'tools/profiles/destruction-snapshot-light.json'
light = json.loads(light_path.read_text()) if a.preset == 'light' else None
if not light and a.repetitions is None:
    a.repetitions = 20

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
if light:
    catalog = {c['scenario']: c for c in cases}
    selected = light['scenarios']
    if len({c['scenario'] for c in selected}) != len(selected):
        p.error('Duplicate light scenario')
    for c in selected:
        if c['scenario'] not in catalog or not isinstance(c['repetitions'], int) or c['repetitions'] < 2:
            p.error('Invalid light scenario/repetition count')
    cases = [dict(catalog[c['scenario']], **{k:v for k,v in c.items() if k != 'scenario'}) for c in selected]
else:
    cases = [dict(c, repetitions=a.repetitions) for c in cases]
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
    preset=a.preset, repetitions=a.repetitions, restore_timed=False, validation_timed=False,
    preset_sha256=hashlib.sha256(light_path.read_bytes()).hexdigest() if light else None,
    target_wall_seconds=light['target_wall_seconds'] if light and not a.sanitizer else None,
    sanitizer=a.sanitizer, sanitizer_blocking_launches=a.sanitizer_blocking_launches,
    performance_qualification=False, scenarios=cases), indent=2) + '\n')
if a.manifest_only:
    print(f'{len(cases)} cases validated: {out / "manifest.json"}')
    raise SystemExit(0)

common = ['--binary', str(a.binary.resolve()), '--artifacts', str(a.artifacts.resolve()),
          '--watchdog-seconds', '600']
if a.sanitizer:
    common += ['--sanitizer', a.sanitizer]
if a.sanitizer_blocking_launches:
    common += ['--sanitizer-blocking-launches']
if a.allow_existing_graphics:
    common += ['--allow-existing-graphics']
for pid in a.allow_compute_pid:
    common += ['--allow-compute-pid', str(pid)]
results = []
environment = dict(os.environ)
if light:
    # Keep in-memory physical checks; omit large cross-build diagnostic dumps.
    environment.pop('PHYSX_SNAPSHOT_DUMP_OBSERVATIONS', None)
for case in cases:
    # A changed saved input invalidates the campaign, rather than silently changing the workload.
    for name, digest in case['input_sha256'].items():
        if hashlib.sha256(Path(name).read_bytes()).hexdigest() != digest:
            raise RuntimeError(f'Input changed after manifest creation: {name}')
    command = [sys.executable, str(Path(__file__).with_name('run-probe.py')),
               str(out / ('complete-' + case['scenario'])), *common, '--replay-prefix', case['prefix'],
               '--repetitions', str(case['repetitions'])]
    if case.get('projectile_impulse'):
        command += ['--projectile-impulse']
    print(case['scenario'], flush=True)
    result = subprocess.run(command, env=environment)
    counter_passed = True
    if light and result.returncode == 0:
        replay = json.loads((out / ('complete-' + case['scenario']) / 'replay.json').read_text())
        counter_passed = all(s[k] == v for s in replay['samples'] for k,v in case['expected_counters'].items())
    results.append(dict(scenario=case['scenario'], exit_code=result.returncode,
                        screening_counters_passed=counter_passed, command=command))
    (out / 'campaign.json').write_text(json.dumps(results, indent=2) + '\n')
passed = all(not r['exit_code'] and r['screening_counters_passed'] for r in results)
if light and passed and not a.sanitizer:
    # Reuse the existing report's full-step stages, variability and raw samples.
    report = subprocess.run([sys.executable, str(Path(__file__).with_name('report-file-replay.py')),
        str(out / 'report'), *[str(out / ('complete-' + c['scenario'])) for c in cases]])
    passed = report.returncode == 0
elapsed = time.monotonic() - started
summary = dict(passed=passed, preset=a.preset, scenarios=len(cases),
    ticks=sum(c['repetitions'] for c in cases), wall_seconds=elapsed,
    target_wall_seconds=light['target_wall_seconds'] if light and not a.sanitizer else None,
    within_target=elapsed <= light['target_wall_seconds'] if light and not a.sanitizer else None,
    performance_qualification=False)
(out / 'suite-summary.json').write_text(json.dumps(summary, indent=2) + '\n')
print(json.dumps(summary), flush=True)
raise SystemExit(0 if passed else 1)
