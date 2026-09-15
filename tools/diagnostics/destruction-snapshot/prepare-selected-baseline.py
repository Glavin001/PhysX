#!/usr/bin/env python3
"""Freeze an analysis-only harness and the selected N13+N20 artifacts."""
import hashlib
import json
import shutil
from pathlib import Path

ROOT = Path(__file__).resolve().parents[3]
BASE = ROOT / 'out/destruction-baseline-20260913'
REPORT = ROOT / 'reports/destruction-baseline-20260913'

def sha(path):
    h = hashlib.sha256()
    with Path(path).open('rb') as f:
        for block in iter(lambda: f.read(1024 * 1024), b''):
            h.update(block)
    return h.hexdigest()

def main():
    BASE.mkdir(exist_ok=False)
    REPORT.mkdir(exist_ok=False)
    harness = BASE / 'harness'
    harness.mkdir()
    for name in ['out', 'physx', 'blast', '.toolchains']:
        (harness / name).symlink_to(ROOT / name, target_is_directory=True)
    frozen = {}
    for source in (ROOT / 'tools').rglob('*.py'):
        target = harness / source.relative_to(ROOT)
        target.parent.mkdir(parents=True, exist_ok=True)
        shutil.copy2(source, target)
        frozen[str(source.relative_to(ROOT))] = sha(source)
    shutil.copytree(ROOT / 'tools/profiles', harness / 'tools/profiles')
    scripts = harness / 'tools/diagnostics/destruction-snapshot'
    checker = ROOT / 'reports/destruction-exact-solve-reuse/evidence/physical-checker.py'
    assert sha(checker) == '6f256f04de9fd87774593cba6ef1dc5455bfbb5cbbd909779ec9e3afb0bbab31'
    shutil.copy2(checker, scripts / 'compare-observations.py')
    references = BASE / 'references'
    references.mkdir()
    prior = ROOT / 'out/n29b-cheap-rejection-20260913/full52/report.json'
    data = json.loads(prior.read_text())
    assert data['status'] == 'complete' and len(data['scenarios']) == 52
    for row in data['scenarios']:
        assert row['physical_status'] == 'passed'
        ref = Path(row['raw']['A0'])
        assert (ref / 'observation-0.json').is_file()
        (references / ('complete-' + row['scenario'])).symlink_to(ref, target_is_directory=True)
    # Private copies change only reference locations; the physical checker is frozen.
    for name in ['profile-cpu-suite.py', 'profile-graph-suite.py', 'profile-config-suite.py']:
        target = scripts / name
        text = target.read_text()
        old = "ROOT/'out/snapshot-reset-20260911/prepared-full20'"
        assert text.count(old) == 1
        target.write_text(text.replace(old, 'Path(' + repr(str(references)) + ')'))
    binaries = {
        'plain/serialization-probe': ROOT / 'out/n20-requalification-20260912/build/B/serialization-probe',
        'profile/serialization-probe': ROOT / 'out/n20-requalification-20260912/cpu-probes/B/serialization-probe',
        'native/native_destruction_demo': ROOT / 'out/n20-requalification-20260912/build/B/native_destruction_demo',
        'artifacts/libPhysXDestructionGpuRuntime_64.so': ROOT / 'out/n29b-cheap-rejection-20260913/build/A/libPhysXDestructionGpuRuntime_64.so',
        'artifacts/libPhysXGpuActivity_64.so': ROOT / 'out/n29b-cheap-rejection-20260913/build/A/libPhysXGpuActivity_64.so',
    }
    provenance = {}
    for relative, source in binaries.items():
        target = BASE / relative
        target.parent.mkdir(exist_ok=True)
        shutil.copy2(source, target)
        provenance[relative] = dict(source=str(source), path=str(target), sha256=sha(target))
        assert provenance[relative]['sha256'] == sha(source)
    assert provenance['artifacts/libPhysXDestructionGpuRuntime_64.so']['sha256'] == 'd5770a80c2f4686b0ad311edcbfc8e128d14baee64653bf5e032305c12cf9354'
    assert provenance['plain/serialization-probe']['sha256'] == data['binaries']['A']['sha256']
    (BASE / 'profile/build.json').write_text(json.dumps(dict(profiling_only=True, binary_sha256=provenance['profile/serialization-probe']['sha256']), indent=2) + '\n')
    manifest = ROOT / 'out/n29b-cheap-rejection-20260913/full52-manifest.json'
    shutil.copy2(manifest, BASE / 'manifest.json')
    args = BASE / 'warm-args'
    args.mkdir()
    for case in ['idle-256', 'impacts-256']:
        source = ROOT / 'out/end-to-end-attribution-20260912' / (case + '-warm-args.json')
        shutil.copy2(source, args / source.name)
    evidence = REPORT / 'evidence'
    evidence.mkdir()
    shutil.copy2(prior, evidence / 'selected-control-full52-source.json')
    shutil.copy2(manifest, evidence / 'scenario-manifest.json')
    shutil.copy2(checker, evidence / 'physical-checker.py')
    frozen_final = {str(p.relative_to(harness)): sha(p) for p in harness.glob('tools/**/*.py')}
    record = dict(status='prepared_not_run', source_commit='13b11af2e0aeabf4e0070931fbd8a060f383dfaf',
        runtime_changes=False, artifacts=provenance, original_harness_hashes=frozen,
        frozen_harness_hashes=frozen_final, checker_sha256=sha(checker),
        prior_control_report=dict(path=str(prior), sha256=sha(prior)),
        scenario_manifest=dict(path=str(BASE / 'manifest.json'), sha256=sha(BASE / 'manifest.json')),
        scope='Current selected control only. Rejected N29b/N30 excluded. Historical profiles with runtime 4e1318cb are separate. Frozen strict comparison does not establish full independent long-run physical acceptance.')
    (BASE / 'provenance.json').write_text(json.dumps(record, indent=2) + '\n')
    shutil.copy2(BASE / 'provenance.json', REPORT / 'provenance.json')
    print(BASE)

if __name__ == '__main__':
    main()
